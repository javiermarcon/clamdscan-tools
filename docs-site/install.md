# Installation

`clamdscan-tools` targets Linux systems where `clamdscan`, GNU `find` and a
standard `/etc` + `/var` filesystem layout are available. Debian-family
packaging is the primary distribution channel, but a portable `tar.gz` source
install path also exists for non-Debian systems.

## Install from GitHub Release `.deb`

This is the fastest path when you only want to install a released build.

1. Download the `.deb` attached to the desired GitHub Release.
2. Install it with `apt` so dependencies are resolved cleanly.

```bash
sudo apt install ./clamdscan-tools_0.2.2_all.deb
```

Expected installed paths include:

- `/usr/bin/clamdscan-progress`
- `/usr/bin/clamdscan-watch`
- `/usr/lib/clamdscan-tools/clamdscan-tools.sh`
- `/etc/clamdscan-tools/`
- `/usr/share/man/man1/`
- `/usr/share/info/clamdscan-tools.info.gz`

## Install from source `tar.gz`

This is the preferred path for distributions such as Slackware, or when you
want to package the project outside the Debian toolchain.

1. Download the release tarball.
2. Extract it.
3. Run the generic installer with your desired prefix.

```bash
tar -xzf clamdscan-tools-0.2.2.tar.gz
cd clamdscan-tools-0.2.2
sudo PREFIX=/usr bash packaging/tarball/install.sh
```

The installer copies:

- `/usr/bin/clamdscan-progress`
- `/usr/bin/clamdscan-watch`
- `/usr/lib/clamdscan-tools/clamdscan-tools.sh`
- `/etc/clamdscan-tools/`
- `/usr/share/man/man1/`
- `/usr/share/info/clamdscan-tools.info`

For package builders, you can stage into a package root:

```bash
DESTDIR="$PKG" PREFIX=/usr bash packaging/tarball/install.sh
```

## Install dependencies first

On a fresh system, make sure ClamAV and runtime tooling exist:

```bash
sudo apt update
sudo apt install clamav-daemon tracker3
```

`tracker3` is optional; the tools work without it.

Outside Debian-family systems, install the equivalent runtime pieces manually:

- Bash
- ClamAV with `clamdscan`
- GNU `find`, `grep`, `sed`, `awk`
- `python3`, `procps`, `util-linux`
- `tracker3` optionally

## Install from the project APT repository

The project also supports a static APT repository signed with GPG and published
under GitHub Pages.

### Import the archive key

```bash
curl -fsSL https://javiermarcon.github.io/clamdscan-tools/keys/clamdscan-tools-archive-key.asc \
  | sudo gpg --dearmor -o /usr/share/keyrings/clamdscan-tools-archive-keyring.gpg
```

### Add the source list

```bash
echo "deb [signed-by=/usr/share/keyrings/clamdscan-tools-archive-keyring.gpg] https://javiermarcon.github.io/clamdscan-tools/apt stable main" \
  | sudo tee /etc/apt/sources.list.d/clamdscan-tools.list >/dev/null
```

### Install

```bash
sudo apt update
sudo apt install clamdscan-tools
```

This method is preferable when you want normal `apt update` / `apt upgrade`
behavior instead of manually downloading every `.deb`.

## Install from Launchpad PPA

Ubuntu users can install directly from the published PPA:

```bash
sudo add-apt-repository ppa:javiermarcon/clamdscan-tools
sudo apt update
sudo apt install clamdscan-tools
```

This is the most Ubuntu-native distribution path for the project.

## Remove or purge

Remove the binaries but keep configuration:

```bash
sudo apt remove clamdscan-tools
```

Remove binaries, config and package-managed state:

```bash
sudo apt purge clamdscan-tools
```

Note that purge removes package-owned configuration, but does not remove
arbitrary files you may have added manually under your own home directory.

## Choose the right channel

### GitHub Release `.deb`

Use this when:

- you only need a single host install
- you want the exact file from a tagged release
- you do not need repository metadata

### Project APT repo

Use this when:

- you want standard APT upgrades
- you manage several machines
- you prefer an archive key plus source entry over manual downloads

### Launchpad PPA

Use this when:

- you want Ubuntu-native package installation
- you want a familiar Ubuntu packaging channel
- you prefer Launchpad builds over manually downloaded `.deb` files

### Source `tar.gz`

Use this when:

- you are on a non-Debian distribution such as Slackware
- you need a generic source artifact instead of a Debian package
- you want to stage files into another packaging system with `DESTDIR`
