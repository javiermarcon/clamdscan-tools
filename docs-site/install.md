# Installation

`clamdscan-tools` targets Debian-family systems where `clamav-daemon`,
`clamdscan`, GNU `find`, systemd-compatible layouts and Debian packaging are
normal operational choices.

## Install from GitHub Release `.deb`

This is the fastest path when you only want to install a released build.

1. Download the `.deb` attached to the desired GitHub Release.
2. Install it with `apt` so dependencies are resolved cleanly.

```bash
sudo apt install ./clamdscan-tools_0.2.0_all.deb
```

Expected installed paths include:

- `/usr/bin/clamdscan-progress`
- `/usr/bin/clamdscan-watch`
- `/usr/lib/clamdscan-tools/clamdscan-tools.sh`
- `/etc/clamdscan-tools/`
- `/usr/share/man/man1/`
- `/usr/share/info/clamdscan-tools.info.gz`

## Install dependencies first

On a fresh system, make sure ClamAV and runtime tooling exist:

```bash
sudo apt update
sudo apt install clamav-daemon tracker3
```

`tracker3` is optional; the tools work without it.

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
