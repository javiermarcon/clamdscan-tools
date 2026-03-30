# clamdscan-tools

![Build](https://img.shields.io/github/actions/workflow/status/javiermarcon/clamdscan-tools/build-deb.yml)
![License](https://img.shields.io/github/license/javiermarcon/clamdscan-tools)
![Platform](https://img.shields.io/badge/platform-linux-blue)
![Package](https://img.shields.io/badge/package-deb-green)

Advanced wrapper for `clamdscan` providing:

- Progress tracking
- Resume capability
- Configurable exclusions
- Centralized logs and state
- Optional Tracker (GNOME) integration
- Proper behavior with and without root privileges
- Debian package support (.deb)
- Static signed APT repository support
- MkDocs documentation site for GitHub Pages
- Manual pages and GNU info documentation

---

## Why

ClamAV (`clamdscan`) does not provide:

- Progress visibility
- Resume support
- Flexible exclusions

This tool solves those limitations while remaining lightweight and portable.

---

## Features

- Progress visualization (CLI)
- Resume interrupted scans
- Configurable exclusions (path + directory name)
- Optional integration with Tracker (tracker3 / tracker)
- Safe cleanup on interruption (CTRL+C)
- Works with and without sudo
- Structured logs and state files
- Debian-compliant packaging

---

## Installation

### Install from .deb

```bash
sudo apt install ./clamdscan-tools_0.2.1_all.deb
```

### Install from the project APT repository

Import the signing key:

```bash
curl -fsSL https://javiermarcon.github.io/clamdscan-tools/keys/clamdscan-tools-archive-key.asc \
  | sudo gpg --dearmor -o /usr/share/keyrings/clamdscan-tools-archive-keyring.gpg
```

Add the repository:

```bash
echo "deb [signed-by=/usr/share/keyrings/clamdscan-tools-archive-keyring.gpg] https://javiermarcon.github.io/clamdscan-tools/apt stable main" \
  | sudo tee /etc/apt/sources.list.d/clamdscan-tools.list >/dev/null
```

Install:

```bash
sudo apt update
sudo apt install clamdscan-tools
```

### Future Launchpad PPA

Launchpad PPA publication is planned for Ubuntu users, but not enabled yet.
Until then, use either the GitHub Release `.deb` or the project APT repository.

### Remove

```bash
sudo apt remove clamdscan-tools
```

### Remove completely (including config and state)

```bash
sudo apt purge clamdscan-tools
```

---

## Installed Paths

### Binaries

- /usr/bin/clamdscan-progress
- /usr/bin/clamdscan-watch

### Library

- /usr/lib/clamdscan-tools/clamdscan-tools.sh

### Documentation

- /usr/share/man/man1/clamdscan-progress.1.gz
- /usr/share/man/man1/clamdscan-watch.1.gz
- /usr/share/info/clamdscan-tools.info.gz

### Configuration

- /etc/clamdscan-tools/clamdscan-tools.conf
- /etc/clamdscan-tools/excludes.conf
- /etc/clamdscan-tools/prune-paths.conf
- /etc/clamdscan-tools/exclude-file-patterns.conf
- /etc/clamdscan-tools/exclude-files.conf

### Runtime

- /var/log/clamdscan-tools/
- /var/lib/clamdscan-tools/state/
- /var/lib/clamdscan-tools/infected/
- ~/.local/state/clamdscan-tools/log
- ~/.local/state/clamdscan-tools/state
- ~/.local/share/clamdscan-tools/infected

---

## Usage

### Default scan

```bash
sudo clamdscan-progress
```

### System scan

```bash
sudo clamdscan-progress --system
```

### Scan specific directory

```bash
clamdscan-progress ~/Descargas
```

### Resume scan

```bash
sudo clamdscan-progress --resume /var/lib/clamdscan-tools/state/scan_TIMESTAMP.state
```

---

## Log Monitoring

### Show last log

```bash
clamdscan-watch
```

### Follow log

```bash
clamdscan-watch --follow
```

---

## Root vs Non-root Behavior

### With sudo

- Uses `--fdpass`
- Can scan protected paths
- Moves infected files
- Attempts to start `clamav-daemon`

### Without sudo

- Scans only readable files
- Does not move infected files
- Does not require daemon start
- Falls back to per-user runtime directories if `/var/log/clamdscan-tools` or `/var/lib/clamdscan-tools` are not writable

---

## Configuration

All scan behavior is configured from files under `/etc/clamdscan-tools/`.
The script only falls back to the repo-local `config/` defaults when those
files do not exist.

### Main config

`/etc/clamdscan-tools/clamdscan-tools.conf`

```bash
CTS_DEFAULT_TARGETS="/home"
CTS_SYSTEM_TARGETS="/home /etc /var /opt"

CTS_LOG_DIR="/var/log/clamdscan-tools"
CTS_STATE_DIR="/var/lib/clamdscan-tools/state"
CTS_INFECTED_DIR="/var/lib/clamdscan-tools/infected"

CTS_USE_NICE="yes"
CTS_USE_IONICE="yes"
CTS_USE_TRACKER="yes"
```

When running without `sudo`, the configured runtime directories are used only if the current user can write there. Otherwise the tool automatically falls back to:

```bash
CTS_LOG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/clamdscan-tools/log"
CTS_STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/clamdscan-tools/state"
CTS_INFECTED_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/clamdscan-tools/infected"
```

---

### Directory exclusions

`/etc/clamdscan-tools/excludes.conf`

```text
.git
.cache
gvfs-metadata
node_modules
venv
__pycache__
```

---

### Path exclusions

`/etc/clamdscan-tools/prune-paths.conf`

```text
/proc
/sys
/dev
$HOME/.cache
$CTS_INFECTED_DIR
```

---

### File-pattern exclusions

`/etc/clamdscan-tools/exclude-file-patterns.conf`

```text
*.lock
*.iso
*.img
```

---

### Exact-file exclusions

`/etc/clamdscan-tools/exclude-files.conf`

```text
/swapfile
```

---

## Tracker Integration

- If `tracker3` exists → used
- Else if `tracker` exists → used
- Else → ignored

Tracker is paused before scan and resumed after.

---

## Generated Files

Each run produces:

- Log file
- State file (resume)
- File list
- Find errors log

As root, these files are stored under `/var/log/clamdscan-tools` and `/var/lib/clamdscan-tools/state`.
Without `sudo`, if those paths are not writable, they are stored under `~/.local/state/clamdscan-tools/`.

When installed from the `.deb`, system-managed runtime files are maintained automatically:

- `/var/log/clamdscan-tools/*.log` is rotated by `logrotate` weekly, keeping 8 compressed archives
- `/home/*/.local/state/clamdscan-tools/log/*.log` is also rotated by `logrotate` weekly, keeping 8 compressed archives
- `/var/lib/clamdscan-tools/state/` is cleaned by `systemd-tmpfiles`, removing files older than 30 days

Automatic cleanup of `~/.local/state/clamdscan-tools/state/` is not installed, because per-user state files are not managed by `systemd-tmpfiles` at the system package level.

---

## Build (.deb)

```bash
sudo apt install devscripts debhelper build-essential texinfo
make package
```

Direct alternative:

```bash
dpkg-buildpackage -us -uc -b
```

`make package` remains the single source of truth to generate the `.deb`.
It uses Debian packaging normally, then copies the resulting artifacts into
`dist/` inside the repo for release and APT publishing workflows.
It also validates that the latest git tag `v*` matches the version declared in
`debian/changelog`.

To create the expected release tag from the changelog version:

```bash
make release-tag
```

---

## Development

### Lint

```bash
make lint
```

### Update changelog and release version

Use the repo helper instead of invoking `dch` bare, so maintainer identity is
always provided explicitly:

```bash
make changelog NEW_VERSION=0.2.1 MSG="Fix CI workflow opt-in to Node 24 runtime"
make build
make release-tag
```

`make release-tag` intentionally stays separate from `dch`: release tags should
point to committed repository state, not to a half-edited working tree.

If you prefer calling `dch` directly, configure it in your user environment:

```bash
cat >> ~/.devscripts <<'EOF'
DEBFULLNAME="Javier Marcon"
DEBEMAIL="javiermarcon@gmail.com"
EOF
```

### Build web docs locally

```bash
python -m pip install mkdocs-material
mkdocs serve
```

### Build signed static APT repo locally

Assumptions:

- `aptly` is installed
- `gnupg` is installed
- your private signing key is already imported locally

```bash
make package
bash packaging/apt/init-repo.sh
bash packaging/apt/add-packages.sh dist
APTLY_GPG_KEY_ID="22B4D63898D3A00D" \
APTLY_GPG_PASSPHRASE="YOUR_PASSPHRASE" \
bash packaging/apt/publish-repo.sh
mkdocs build --strict
bash packaging/apt/export-site.sh
```

This generates:

- `site/` for GitHub Pages
- `site/apt/` for the static APT repository
- `site/keys/clamdscan-tools-archive-key.asc` for client key import

### GitHub Actions secrets for APT publishing

The Pages/APT workflow requires these repository secrets:

- `APTLY_GPG_PRIVATE_KEY`
- `APTLY_GPG_KEY_ID`
- `APTLY_GPG_PASSPHRASE`

Expected values:

- `APTLY_GPG_PRIVATE_KEY`: ASCII-armored private key
- `APTLY_GPG_KEY_ID`: `22B4D63898D3A00D`
- `APTLY_GPG_PASSPHRASE`: passphrase for the private key

---

## Limitations

- Resume does not detect modified files
- No persistent cache yet
- No systemd timer (optional future feature)

---

## Roadmap

- Persistent scan cache (mtime/size)
- Systemd timer support
- Lockfile support
- CLI exclusions
- Tests (bats)

---

## License

See LICENSE file.
