# Launchpad PPA roadmap

The project is not published to Launchpad yet, but the repository is now
documented so the next packaging step is clear instead of implicit.

## Why Launchpad PPA is different

GitHub Releases and the static APT repo work well for Debian-family systems in
general, but a Launchpad PPA adds Ubuntu-native distribution:

- built on Launchpad infrastructure
- integrated with `add-apt-repository`
- expected by many Ubuntu users
- versioned per Ubuntu series

## What is already prepared

- Debian packaging exists and builds with `make package`
- runtime paths and configuration are documented
- release artifacts are generated from version tags
- APT repository signing and publication flow already exist

These pieces reduce the amount of work needed to add a PPA later.

## What still needs to be done for Launchpad

### Ubuntu package build validation

You need to validate the package on supported Ubuntu series, not only Debian.
Typical concerns:

- dependency names or versions
- ClamAV service naming expectations
- tracker availability and packaging differences
- build dependencies on Launchpad builders

### Source package publication

Launchpad expects source uploads, not only binary `.deb` files. That means
you will need a source-oriented upload flow, typically using:

```bash
debuild -S
dput ppa:YOUR_PPA_HERE ../clamdscan-tools_VERSION_source.changes
```

### Versioning strategy

PPAs often use version suffixes such as:

```text
0.2.0-0ubuntu1~ppa1
```

That lets you distinguish:

- upstream release version
- Ubuntu packaging revision
- PPA-specific upload iteration

### Changelog discipline

`debian/changelog` becomes even more important once Ubuntu uploads are added,
because it drives package versioning across GitHub releases, APT repo
publication and potential PPA uploads.

## Recommended future workflow

1. Keep `make package` and Debian packaging healthy on main
2. Add source-package validation in CI
3. Test on Ubuntu LTS releases
4. Introduce Launchpad-specific version suffixes only when needed
5. Document which Ubuntu releases are officially supported

## User-facing expectation

Until a PPA exists, Ubuntu users should install through:

- GitHub Release `.deb`
- or the static APT repository if the package dependencies resolve cleanly

Once the PPA exists, Ubuntu instructions can point there first while Debian
systems may continue to prefer the project APT repo or release `.deb`.
