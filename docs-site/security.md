# Security

`clamdscan-tools` improves operational usability, but it does not replace basic
security hygiene around malware scanning, package signing or repository trust.

## Package trust model

There are three trust layers in this repository:

- Git commits and Git tags
- GitHub Release assets
- the signed static APT repository

The APT repository is signed with:

- Key ID: `22B4D63898D3A00D`
- Fingerprint: `5E3B821774D744578613925922B4D63898D3A00D`

Users should verify they imported the expected archive key before trusting the
APT source.

## GPG secrets in CI

The Pages/APT publishing workflow requires these secrets:

- `APTLY_GPG_PRIVATE_KEY`
- `APTLY_GPG_KEY_ID`
- `APTLY_GPG_PASSPHRASE`

Good practice:

- store them only in GitHub Actions secrets
- do not commit private key material into the repository
- rotate the key if exposure is suspected
- keep the public key checked into the repo only for user distribution

## Root vs non-root scanning

### Root scans

Pros:

- broader filesystem visibility
- can scan protected locations
- can quarantine infected files

Cons:

- broader filesystem impact if misconfigured
- greater trust in runtime path ownership and log handling

### User scans

Pros:

- narrower blast radius
- safer for personal directory sweeps
- no daemon startup attempt

Cons:

- limited to readable files
- cannot act on privileged areas

Choose the mode that matches the purpose of the scan.

## Exclusions are operational, not security absolution

Excluding noisy caches and lock files is often the right tradeoff, but it
always means those files are not scanned.

Use exclusions only when:

- the files are operational noise
- the content is transient and low-value for antivirus scanning
- scanning them creates repeated false operational failures

Do not exclude important application data just to make logs quieter.

## GitHub Pages APT repo caveat

The static APT repo is simple and practical, but you still need to think about:

- key rotation
- compromised Pages publishing credentials
- stale package metadata after failed deployments
- ensuring the published site and Release artifacts correspond to the same tag

## Sensitive local artifacts

Generated directories such as `dist/` and `site/` are intentionally ignored by
git. They may contain:

- release candidates
- repository metadata
- local package builds

That is convenient, but it also means you should be deliberate when sharing
files from those directories manually.
