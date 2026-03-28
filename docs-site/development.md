# Development

This project has three documentation surfaces and they should not be confused:

- `README.md`: repository landing page and quick install guidance
- `docs/`: package-facing docs already used for manpages, Texinfo and GNU info
- `docs-site/`: MkDocs web documentation for GitHub Pages

Do not mix `docs-site/` content into `docs/`, and do not reuse `docs/` as a
MkDocs source tree.

## Local development workflow

### Lint shell code

```bash
make lint
```

### Sync versioned docs from `debian/changelog`

```bash
make build
```

This target updates version references in:

- `README.md`
- `docs/clamdscan-tools.texi`
- `docs/clamdscan-tools.info`
- `docs/clamdscan-progress.1`
- `docs/clamdscan-watch.1`

### Build the Debian package

```bash
make package
```

Important behavior:

- `dpkg-buildpackage` still writes standard build outputs in the parent directory
- the project then copies `.deb`, `.buildinfo` and `.changes` into `dist/`
- `dist/` is ignored by git because it is generated output

## MkDocs web documentation

Preview locally:

```bash
python -m pip install mkdocs-material
mkdocs serve
```

Build statically:

```bash
mkdocs build --strict
```

The generated site goes to:

```text
site/
```

That directory is also ignored by git.

## Static APT publishing locally

Requirements:

- `aptly`
- `gnupg`
- a signing key already imported into your local GPG keyring

Flow:

```bash
make package
bash packaging/apt/init-repo.sh
bash packaging/apt/add-packages.sh dist
APTLY_GPG_KEY_ID=22B4D63898D3A00D \
APTLY_GPG_PASSPHRASE='YOUR_PASSPHRASE' \
bash packaging/apt/publish-repo.sh
mkdocs build --strict
bash packaging/apt/export-site.sh
```

After that:

- `site/` contains the web docs
- `site/apt/` contains the published static APT repo
- `site/keys/` contains the public archive key

## GitHub Actions model

### Existing workflow

`build-deb.yml` already:

- builds with `make package`
- uploads `dist/*.deb` as an artifact
- publishes GitHub Releases on tags `v*`

### New workflow

`publish-pages-apt.yml`:

- builds the package again with `make package`
- imports the APT signing key from secrets
- publishes the signed aptly repo
- builds MkDocs
- deploys the combined site to GitHub Pages

This is intentionally separate from `build-deb.yml`.

## Required GitHub secrets

- `APTLY_GPG_PRIVATE_KEY`
- `APTLY_GPG_KEY_ID`
- `APTLY_GPG_PASSPHRASE`

## Suggested release flow

1. update `debian/changelog`
2. run `make lint`
3. run `make package`
4. commit changes
5. push `main`
6. create and push tag `vX.Y.Z`
7. let `build-deb.yml` publish the release asset
8. let `publish-pages-apt.yml` publish the Pages site and APT repo
