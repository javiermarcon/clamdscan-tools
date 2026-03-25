# clamdscan-tools

![Build](https://img.shields.io/github/actions/workflow/status/TU_USUARIO/clamdscan-tools/build-deb.yml)
![License](https://img.shields.io/github/license/TU_USUARIO/clamdscan-tools)
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
sudo apt install ./clamdscan-tools_0.1.0_all.deb
```

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

### Configuration
- /etc/clamdscan-tools/clamdscan-tools.conf
- /etc/clamdscan-tools/excludes.conf
- /etc/clamdscan-tools/prune-paths.conf

### Runtime
- /var/log/clamdscan-tools/
- /var/lib/clamdscan-tools/state/
- /var/lib/clamdscan-tools/infected/

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

---

## Configuration

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

---

### Directory exclusions

`/etc/clamdscan-tools/excludes.conf`

```text
.git
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

---

## Build (.deb)

```bash
sudo apt install devscripts debhelper build-essential
make package
```

Direct alternative:

```bash
dpkg-buildpackage -us -uc -b
```

---

## Development

### Lint

```bash
make lint
```

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
