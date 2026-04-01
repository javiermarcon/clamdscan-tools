# clamdscan-tools

`clamdscan-tools` is a Linux wrapper around `clamdscan` that adds progress
reporting, resumable state, configurable exclusions, log inspection and
packaging suitable for Debian-family systems plus a portable `tar.gz` install
path for other distributions.

## What it solves

Raw `clamdscan` is useful, but on real systems it has a few operational gaps:

- no progress counter while scanning large trees
- no resumable state for interrupted runs
- no centralized runtime files for logs, state and file lists
- no project-level exclusion model for noisy caches and transient files
- no helper command to inspect the latest scan log

`clamdscan-tools` keeps the ClamAV daemon and scanner as the engine, while
adding a more practical CLI layer for daily desktop or workstation use.

## Main commands

### `clamdscan-progress`

Runs a scan over one or more targets, shows textual progress, stores a state
file for resume, writes a log and records `find` diagnostics separately.

Typical uses:

```bash
sudo clamdscan-progress
sudo clamdscan-progress --system
clamdscan-progress ~/Descargas
sudo clamdscan-progress --resume /var/lib/clamdscan-tools/state/scan_TIMESTAMP.state
```

### `clamdscan-watch`

Displays or follows the latest scan log, or a specific log file.

Typical uses:

```bash
clamdscan-watch
clamdscan-watch --follow
clamdscan-watch --log /var/log/clamdscan-tools/scan_TIMESTAMP.log
```

## Distribution channels

The project is prepared to be distributed through more than one channel:

- GitHub Releases with `.deb` artifacts attached to version tags
- a static, signed APT repository published under GitHub Pages
- a Launchpad PPA for Ubuntu users
- a portable source tarball for manual installs and non-Debian packaging

The Debian-family channels share the same package source of truth:

```bash
make package
```

For portable source distribution, the repo also exports a tarball directly from
committed `HEAD`:

```bash
make source-tarball
```

That tarball is intended for manual installs and packaging work on systems that
do not consume `.deb` artifacts directly.

## Documentation map

- [Installation](install.md): install from release `.deb`, source `tar.gz`, APT repo or Launchpad PPA
- [Usage](usage.md): scan modes, resume workflow and log inspection
- [Configuration](configuration.md): how `/etc/clamdscan-tools/` is structured
- [APT Repository](apt-repo.md): how the signed static repo is built and consumed
- [Launchpad PPA](launchpad-ppa.md): how the PPA fits alongside Releases and the static APT repo
- [Development](development.md): local build, validation and publishing workflow
- [Troubleshooting](troubleshooting.md): realistic operational failures and fixes
- [Security](security.md): trust model, GPG handling and scanning caveats
- [FAQ](faq.md): short answers to common operational questions
