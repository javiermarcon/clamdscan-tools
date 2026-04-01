# Configuration

All runtime behavior is driven by files under `/etc/clamdscan-tools/`. The
script only falls back to the repo-local `config/` directory if those files are
missing, which is mainly useful during development or packaging work.

## Main config

File:

```text
/etc/clamdscan-tools/clamdscan-tools.conf
```

Important variables:

```bash
CTS_DEFAULT_TARGETS="/home"
CTS_SYSTEM_TARGETS="/home /oldhome /etc /var /opt"

CTS_LOG_DIR="/var/log/clamdscan-tools"
CTS_STATE_DIR="/var/lib/clamdscan-tools/state"
CTS_INFECTED_DIR="/var/lib/clamdscan-tools/infected"

CTS_USE_NICE="yes"
CTS_USE_IONICE="yes"
CTS_CLAMD_SERVICE="clamav-daemon"
CTS_USE_TRACKER="yes"
```

## Runtime path fallback

When running without `sudo`, the configured runtime directories are used only
if the current user can write to them. If not, the tool falls back to:

```bash
${XDG_STATE_HOME:-$HOME/.local/state}/clamdscan-tools/log
${XDG_STATE_HOME:-$HOME/.local/state}/clamdscan-tools/state
${XDG_DATA_HOME:-$HOME/.local/share}/clamdscan-tools/infected
```

This keeps non-root scans usable without weakening permissions on `/var`.

## Directory exclusions

File:

```text
/etc/clamdscan-tools/excludes.conf
```

This file defines directory names that should be pruned anywhere in the tree.

Examples:

```text
.git
.cache
gvfs-metadata
node_modules
.venv
venv
__pycache__
```

Use this for noisy directory names that are not useful to scan, regardless of
their exact parent path.

## Path exclusions

File:

```text
/etc/clamdscan-tools/prune-paths.conf
```

This file lists absolute paths or expanded variables that should be skipped
entirely.

Examples:

```text
/proc
/sys
/dev
$HOME/.cache
$HOME/.local/share/Trash
$CTS_INFECTED_DIR
```

Variable expansion is supported for values such as `$HOME` and
`$CTS_INFECTED_DIR`.

## Excluded file patterns

File:

```text
/etc/clamdscan-tools/exclude-file-patterns.conf
```

Use this for transient or oversized patterns that create operational noise.

Examples:

```text
*.lock
*.iso
*.img
*.qcow2
*.vdi
```

## Exact excluded files

File:

```text
/etc/clamdscan-tools/exclude-files.conf
```

Use this for singleton files that should never be scanned, for example:

```text
/swapfile
```

## How exclusions are combined

At scan time, the tool combines:

- directory-name exclusions
- path prunes
- file-pattern exclusions
- exact-file exclusions

This means you can keep broad filesystem noise in one place and exact special
cases in another, instead of cramming everything into a single file format.

## Editing strategy

Recommended approach:

1. Put broad directory names in `excludes.conf`
2. Put absolute or variable-expanded paths in `prune-paths.conf`
3. Put transient file patterns in `exclude-file-patterns.conf`
4. Put one-off exact files in `exclude-files.conf`

Then validate with:

```bash
clamdscan-progress --dry-run ~/Descargas
```

## Debian and Ubuntu notes

- Debian systems typically match the package defaults most closely
- Ubuntu usually works the same for local installs, but Launchpad PPA
  publication still benefits from Ubuntu-specific packaging validation
- none of these configuration files depend on GitHub Releases vs APT repo vs PPA
  vs source tarball; those are distribution channels, not different runtime
  behaviors
