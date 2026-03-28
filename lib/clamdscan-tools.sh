#!/usr/bin/env bash

CTS_CONFIG_FILE="/etc/clamdscan-tools/clamdscan-tools.conf"
CTS_EXCLUDES_FILE="/etc/clamdscan-tools/excludes.conf"
CTS_PRUNE_PATHS_FILE="/etc/clamdscan-tools/prune-paths.conf"

# shellcheck disable=SC2034
# shellcheck disable=SC2034
CTS_TRACKER_PAUSED=0

cts_log_info() {
  printf '[INFO] %s\n' "$*"
}

cts_log_warn() {
  printf '[WARN] %s\n' "$*" >&2
}

cts_log_error() {
  printf '[ERROR] %s\n' "$*" >&2
}

cts_is_root() {
  [ "$(id -u)" -eq 0 ]
}

cts_effective_state_home() {
  if [ -n "${XDG_STATE_HOME:-}" ]; then
    printf '%s\n' "$XDG_STATE_HOME"
  else
    printf '%s\n' "$HOME/.local/state"
  fi
}

cts_effective_data_home() {
  if [ -n "${XDG_DATA_HOME:-}" ]; then
    printf '%s\n' "$XDG_DATA_HOME"
  else
    printf '%s\n' "$HOME/.local/share"
  fi
}

cts_path_is_writable_or_creatable() {
  local target="$1"
  local probe="$target"

  while [ "$probe" != "/" ] && [ ! -e "$probe" ]; do
    probe="$(dirname -- "$probe")"
  done

  [ -w "$probe" ]
}

cts_use_user_runtime_dirs_if_needed() {
  local state_home data_home

  if cts_is_root; then
    return 0
  fi

  if cts_path_is_writable_or_creatable "$CTS_LOG_DIR" &&
     cts_path_is_writable_or_creatable "$CTS_STATE_DIR" &&
     cts_path_is_writable_or_creatable "$CTS_INFECTED_DIR"; then
    return 0
  fi

  state_home="$(cts_effective_state_home)"
  data_home="$(cts_effective_data_home)"

  CTS_LOG_DIR="${state_home}/clamdscan-tools/log"
  CTS_STATE_DIR="${state_home}/clamdscan-tools/state"
  CTS_INFECTED_DIR="${data_home}/clamdscan-tools/infected"
}

cts_load_config() {
  local script_dir local_config local_excludes local_prune_paths

  script_dir="$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
  local_config="${script_dir}/../config/clamdscan-tools.conf"
  local_excludes="${script_dir}/../config/excludes.conf"
  local_prune_paths="${script_dir}/../config/prune-paths.conf"

  if [ -f "$CTS_CONFIG_FILE" ]; then
    # shellcheck source=config/clamdscan-tools.conf
    . "$CTS_CONFIG_FILE"
  elif [ -f "$local_config" ]; then
    # shellcheck source=config/clamdscan-tools.conf
    . "$local_config"
    CTS_CONFIG_FILE="$local_config"
    CTS_EXCLUDES_FILE="$local_excludes"
    CTS_PRUNE_PATHS_FILE="$local_prune_paths"
  fi

  : "${CTS_DEFAULT_TARGETS:=/home}"
  : "${CTS_SYSTEM_TARGETS:=/home /oldhome /etc /var /opt}"
  : "${CTS_LOG_DIR:=/var/log/clamdscan-tools}"
  : "${CTS_STATE_DIR:=/var/lib/clamdscan-tools/state}"
  : "${CTS_INFECTED_DIR:=/var/lib/clamdscan-tools/infected}"
  : "${CTS_USE_NICE:=yes}"
  : "${CTS_USE_IONICE:=yes}"
  : "${CTS_CLAMD_SERVICE:=clamav-daemon}"
  : "${CTS_USE_TRACKER:=yes}"

  cts_use_user_runtime_dirs_if_needed
}

cts_split_words_into_array() {
  local __var_name="$1"
  local __input="$2"
  # shellcheck disable=SC2086
  eval "$__var_name=( $__input )"
}

cts_ensure_runtime_dirs() {
  mkdir -p "$CTS_LOG_DIR" "$CTS_STATE_DIR" "$CTS_INFECTED_DIR"
}

cts_start_clamav_daemon_if_possible() {
  if command -v systemctl >/dev/null 2>&1; then
    if cts_is_root; then
      systemctl start "$CTS_CLAMD_SERVICE" >/dev/null 2>&1 || true
    else
      cts_log_warn "sin root no se intentará iniciar $CTS_CLAMD_SERVICE"
    fi
  fi
}

cts_tracker_command() {
  if command -v tracker3 >/dev/null 2>&1; then
    printf '%s\n' tracker3
    return 0
  fi

  if command -v tracker >/dev/null 2>&1; then
    printf '%s\n' tracker
    return 0
  fi

  return 1
}

cts_tracker_pause_if_available() {
  if [ "$CTS_USE_TRACKER" != "yes" ]; then
    return 0
  fi

  local tracker_cmd
  if ! tracker_cmd="$(cts_tracker_command)"; then
    cts_log_info "Tracker no disponible; se continúa sin pausa"
    return 0
  fi

  cts_log_info "Pausando Tracker con $tracker_cmd..."
  if [ "$tracker_cmd" = "tracker3" ]; then
    if tracker3 daemon -p >/dev/null 2>&1; then
      # shellcheck disable=SC2034
      CTS_TRACKER_PAUSED=1
    fi
  else
    if tracker daemon -p >/dev/null 2>&1; then
      # shellcheck disable=SC2034
      CTS_TRACKER_PAUSED=1
    fi
  fi
}

cts_tracker_resume_if_needed() {
  local tracker_cmd
  if ! tracker_cmd="$(cts_tracker_command)"; then
    return 0
  fi

  cts_log_info "Reanudando Tracker con $tracker_cmd..."
  if [ "$tracker_cmd" = "tracker3" ]; then
    tracker3 daemon -r >/dev/null 2>&1 || true
  else
    tracker daemon -r >/dev/null 2>&1 || true
  fi
}

cts_read_nonempty_lines() {
  local file_path="$1"

  if [ ! -f "$file_path" ]; then
    return 0
  fi

  grep -vE '^[[:space:]]*#|^[[:space:]]*$' "$file_path" || true
}

cts_build_find_command_args() {
  local -a prune_dir_paths=()
  local -a prune_dir_names=()
  local -a exclude_file_patterns=()
  local -a exclude_files=()

  prune_dir_paths+=(
    "/proc"
    "/sys"
    "/dev"
    "/run"
    "/tmp"
    "/var/run"
    "/snap"
    "/var/lib/snapd"
    "$HOME/snap"
    "$HOME/.cache"
    "$HOME/.local/share/Trash"
    "$HOME/.gvfs"
    "$HOME/.steam"
    "$HOME/.var/app"
    "$HOME/VirtualBox VMs"
    "$HOME/.dropbox"
    "$HOME/.dbus"
    "$HOME/.npm"
    "$HOME/.nvm"
    "$HOME/.pnpm-store"
    "$HOME/.cargo"
    "$HOME/.rustup"
    "$HOME/.sdkman"
    "$HOME/.local/share/containers"
    "$HOME/.thumbnails"
    "$HOME/.config/Code/CachedExtensionVSIXs"
    "$HOME/.config/Code/Cache"
    "$HOME/.config/Code/Service Worker/CacheStorage"
    "$HOME/.config/Code/User/workspaceStorage"
    "$CTS_INFECTED_DIR"
  )

  prune_dir_names+=(
    ".git"
    ".cache"
    "node_modules"
    ".venv"
    "venv"
    "dist"
    "build"
    ".next"
    ".nuxt"
    "coverage"
    "htmlcov"
    ".mypy_cache"
    ".pytest_cache"
    ".ruff_cache"
    ".tox"
    "__pycache__"
    "gvfs-metadata"
  )

  exclude_file_patterns+=(
    "*.lock"
    "*.iso"
    "*.img"
    "*.qcow2"
    "*.vdi"
  )

  exclude_files+=(
    "/swapfile"
  )

  while IFS= read -r line; do
    prune_dir_names+=( "$line" )
  done < <(cts_read_nonempty_lines "$CTS_EXCLUDES_FILE")

  while IFS= read -r line; do
    prune_dir_paths+=( "$line" )
  done < <(cts_read_nonempty_lines "$CTS_PRUNE_PATHS_FILE")

  local -a expr=()
  local first=1
  local path_item
  local name_item
  local file_pattern

  expr+=( "(" )

  for path_item in "${prune_dir_paths[@]}"; do
    if [ -z "$path_item" ]; then
      continue
    fi

    if [ "$first" -eq 0 ]; then
      expr+=( "-o" )
    fi

    expr+=( "-path" "$path_item" "-o" "-path" "$path_item/*" )
    first=0
  done

  for name_item in "${prune_dir_names[@]}"; do
    if [ -z "$name_item" ]; then
      continue
    fi

    if [ "$first" -eq 0 ]; then
      expr+=( "-o" )
    fi

    expr+=( "-type" "d" "-name" "$name_item" )
    first=0
  done

  expr+=( ")" "-prune" "-o" "(" "-type" "f" )

  for file_pattern in "${exclude_file_patterns[@]}"; do
    expr+=( "!" "-name" "$file_pattern" )
  done

  for path_item in "${exclude_files[@]}"; do
    if [ -e "$path_item" ]; then
      expr+=( "!" "-samefile" "$path_item" )
    fi
  done

  expr+=( "-print0" ")" )

  # shellcheck disable=SC2034
  CTS_FIND_ARGS=( "${expr[@]}" )
}

cts_run_clamdscan_file_root() {
  local file_path="$1"
  local -a cmd=(clamdscan --no-summary --fdpass --move="$CTS_INFECTED_DIR" -- "$file_path")

  if [ "$CTS_USE_NICE" = "yes" ] && [ "$CTS_USE_IONICE" = "yes" ] && command -v ionice >/dev/null 2>&1; then
    nice -n 10 ionice -c2 -n7 "${cmd[@]}"
    return
  fi

  if [ "$CTS_USE_NICE" = "yes" ]; then
    nice -n 10 "${cmd[@]}"
    return
  fi

  "${cmd[@]}"
}

cts_run_clamdscan_file_user() {
  local file_path="$1"
  local -a cmd=(clamdscan --no-summary -- "$file_path")

  if [ "$CTS_USE_NICE" = "yes" ] && [ "$CTS_USE_IONICE" = "yes" ] && command -v ionice >/dev/null 2>&1; then
    nice -n 10 ionice -c2 -n7 "${cmd[@]}"
    return
  fi

  if [ "$CTS_USE_NICE" = "yes" ]; then
    nice -n 10 "${cmd[@]}"
    return
  fi

  "${cmd[@]}"
}
