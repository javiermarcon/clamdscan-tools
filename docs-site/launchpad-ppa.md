# Launchpad PPA

The project now has a Launchpad PPA upload target:

```text
ppa:javiermarcon/clamdscan-tools
```

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
- source-package helpers now exist for Launchpad uploads

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

Launchpad expects source uploads, not only binary `.deb` files. This repo now
provides helpers for that:

```bash
make ppa-source
make ppa-upload
```

### Versioning strategy

The helper defaults to PPA-style versions such as:

```text
0.2.1+ppa1~noble1
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
4. bump `~ppaN` when publishing a new source package for the same upstream release
5. Document which Ubuntu releases are officially supported

## User-facing expectation

Ubuntu users can now choose the PPA first, while Debian systems may still
prefer the project APT repo or the release `.deb`.
