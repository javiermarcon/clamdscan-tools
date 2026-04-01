# FAQ

## Is the `.deb` in GitHub Releases enough?

Yes, if you only need manual installs. The APT repository is useful when you
want normal `apt` updates across one or more machines.

## Is there a source tarball for non-Debian systems?

Yes. The repository can export a versioned source tarball with:

```bash
make source-tarball
```

That artifact is meant for systems such as Slackware, or for maintainers who
need to stage files into another packaging format.

## Why keep `docs/` and `docs-site/` separate?

Because they serve different outputs:

- `docs/` is for package documentation: manpages, Texinfo and GNU info
- `docs-site/` is for MkDocs web documentation

Mixing them would make maintenance harder and risk breaking packaging.

## Why does `make package` still use `dpkg-buildpackage`?

Because the Debian package remains the single source of truth. GitHub Releases,
APT publishing and future PPA work all build on top of that package.

## Why are build outputs copied into `dist/` if Debian already writes them to the parent directory?

Because `dist/` is a stable in-repo handoff point for:

- GitHub Actions artifacts
- release upload steps
- aptly ingestion

It improves automation without changing the Debian packaging toolchain itself.

## Why does GitHub show “Packages” even if releases already contain the `.deb`?

GitHub Releases and GitHub Packages are different systems. Release assets are
attached to a tag-based release. GitHub Packages is a package registry for
other package ecosystems. For this project, release assets and the static APT
repo are the relevant distribution channels.

## Does the static APT repo replace GitHub Releases?

No. It complements Releases.

- Releases are great for direct downloads
- the APT repo is better for repeat installs and upgrades

## Is Launchpad PPA already supported?

Not yet. The repository is prepared and documented for it, but Launchpad source
uploads and Ubuntu validation still need to be implemented.

## Can I use the project on Ubuntu today?

Often yes, through the release `.deb` or the static APT repo, as long as
dependencies resolve correctly on your Ubuntu version. The future PPA would make
that path more Ubuntu-native.

## Where do scan logs go?

Normally:

- `/var/log/clamdscan-tools/`

For non-root fallback runs:

- `~/.local/state/clamdscan-tools/log/`

## Where do I configure exclusions?

Under `/etc/clamdscan-tools/`:

- `excludes.conf`
- `prune-paths.conf`
- `exclude-file-patterns.conf`
- `exclude-files.conf`

## Why do I still see scan errors when `find.err` is empty?

Because `find.err` only stores `find` stderr. Actual `clamdscan` file errors
are written in the main scan log.
