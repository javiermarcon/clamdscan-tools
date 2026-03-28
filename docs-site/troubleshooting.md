# Troubleshooting

This page collects realistic problems you are likely to see when scanning large
user trees or publishing the package infrastructure.

## `find.err` is empty but the scan shows `ERROR: N`

This is expected if `find` itself succeeded.

- `*.find.err` stores only `find` stderr
- scan errors from `clamdscan` are written in the main log

Check:

```bash
grep -n 'ERROR\|msg:' /var/log/clamdscan-tools/scan_TIMESTAMP.log
```

## Non-root scan fails before scanning

Common cause:

- system runtime dirs under `/var/log/clamdscan-tools` or `/var/lib/clamdscan-tools`
  are not writable

Current behavior:

- the tool falls back to `~/.local/state/clamdscan-tools/` and
  `~/.local/share/clamdscan-tools/` when needed

If it still fails, inspect:

```bash
clamdscan-progress --dry-run ~/Descargas
```

and verify the configured runtime paths.

## Too many noisy access errors

Typical examples:

- `.cache`
- `.lock`
- `gvfs-metadata`

Use:

- `/etc/clamdscan-tools/excludes.conf`
- `/etc/clamdscan-tools/prune-paths.conf`
- `/etc/clamdscan-tools/exclude-file-patterns.conf`
- `/etc/clamdscan-tools/exclude-files.conf`

Validate with `--dry-run` after editing.

## Resume count looks strange

Resume tracks completed file paths, not file content changes. If files changed
between runs, the counters may still look valid while the content is no longer
the same as the original scan start.

If that matters, start a fresh scan instead of resuming.

## `clamdscan-watch` shows nothing useful

Check whether:

- you actually have logs in `/var/log/clamdscan-tools/`
- or, for user-mode runs, in `~/.local/state/clamdscan-tools/log/`

You can also inspect a specific file directly:

```bash
clamdscan-watch --log /var/log/clamdscan-tools/scan_TIMESTAMP.log
```

## GitHub Pages deploy works but APT install fails

Common causes:

- wrong key imported on the client
- stale source list URL
- signing key secrets missing in GitHub Actions
- repository metadata published but not copied into `site/apt/`

Check that these URLs exist after deployment:

- `/apt/dists/stable/Release`
- `/keys/clamdscan-tools-archive-key.asc`

## GitHub Actions fails during signing

Check the three required secrets:

- `APTLY_GPG_PRIVATE_KEY`
- `APTLY_GPG_KEY_ID`
- `APTLY_GPG_PASSPHRASE`

Also check that:

- the private key really matches the key ID
- the passphrase is correct
- the private key is armored and complete

## `make package` puts files outside the repo

That is normal Debian tooling behavior. `dpkg-buildpackage` writes to the parent
directory by default. The project then copies the relevant artifacts into
`dist/` so workflows and local users have a stable in-repo location.

## MkDocs site is missing the APT repo

Remember the order:

1. build docs with `mkdocs build --strict`
2. then run `bash packaging/apt/export-site.sh`

If you rebuild MkDocs after exporting, `site/apt/` and `site/keys/` may be
replaced by the docs build.
