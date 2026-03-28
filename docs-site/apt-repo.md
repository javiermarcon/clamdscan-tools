# Static APT repository

This project includes a second distribution layer beyond GitHub Releases: a
static APT repository generated with `aptly`, signed with GPG and published as
static files under GitHub Pages.

## Why use a static APT repo

A GitHub Release with a `.deb` is enough for manual installs, but an APT repo
adds:

- standard `apt update` and `apt upgrade` behavior
- signed repository metadata
- easy installation across multiple hosts
- a stable URL structure suitable for documentation and automation

## Layout in this repository

Scripts live under:

```text
packaging/apt/
```

Key files:

- `packaging/apt/init-repo.sh`
- `packaging/apt/add-packages.sh`
- `packaging/apt/publish-repo.sh`
- `packaging/apt/export-site.sh`
- `packaging/apt/public-gpg-key.asc`

## GPG identity used for signing

- Key ID: `22B4D63898D3A00D`
- Fingerprint: `5E3B821774D744578613925922B4D63898D3A00D`

The public key is copied into the published site at:

```text
site/keys/clamdscan-tools-archive-key.asc
```

## Publishing flow

The static repo is meant to be produced from the already-built Debian package.
The source of truth remains:

```bash
make package
```

Then the APT flow is:

```bash
bash packaging/apt/init-repo.sh
bash packaging/apt/add-packages.sh dist
bash packaging/apt/publish-repo.sh
mkdocs build --strict
bash packaging/apt/export-site.sh
```

### What each script does

#### `init-repo.sh`

- ensures `aptly` exists
- creates the local repo if it does not exist yet
- keeps the same repo name for future updates

#### `add-packages.sh`

- adds all `dist/*.deb` packages into the aptly local repo
- uses `-force-replace` to support reruns where the same file path is added again

#### `publish-repo.sh`

- creates a snapshot from the local aptly repo
- signs published metadata with the configured GPG key
- first run: publishes a new repo
- later runs: switches the existing published distribution to the new snapshot

#### `export-site.sh`

- copies `~/.aptly/public/` into `site/apt/`
- copies `packaging/apt/public-gpg-key.asc` into `site/keys/`

## Secrets required in GitHub Actions

These must exist in repository or organization secrets for the Pages/APT
workflow:

- `APTLY_GPG_PRIVATE_KEY`
- `APTLY_GPG_KEY_ID`
- `APTLY_GPG_PASSPHRASE`

### Secret expectations

#### `APTLY_GPG_PRIVATE_KEY`

ASCII-armored private key content, for example the output of:

```bash
gpg --armor --export-secret-keys 22B4D63898D3A00D
```

#### `APTLY_GPG_KEY_ID`

The key ID used for signing:

```text
22B4D63898D3A00D
```

#### `APTLY_GPG_PASSPHRASE`

The passphrase protecting the private key. The workflow passes it to `aptly`
for non-interactive signing.

## Client installation from the published repo

Import the key:

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

## Assumptions and limits

The scripts assume:

- `aptly` is installed
- `gnupg` is installed
- the signing key is available in the local GPG home
- `make package` has already produced `dist/*.deb`
- Pages publishing is meant for static hosting, not a dynamic package mirror

This is a practical static repo for a small project, not a full Debian archive
management platform.
