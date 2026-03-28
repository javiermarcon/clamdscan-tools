#!/usr/bin/env bash
set -euo pipefail

: "${APTLY_REPO_NAME:=clamdscan-tools}"
: "${APTLY_DISTRIBUTION:=stable}"
: "${APTLY_COMPONENT:=main}"
: "${APTLY_PREFIX:=.}"
: "${APTLY_ARCHITECTURES:=amd64,all}"
: "${APTLY_ORIGIN:=clamdscan-tools}"
: "${APTLY_LABEL:=clamdscan-tools}"
: "${APTLY_GPG_KEY_ID:=}"
: "${APTLY_GPG_PASSPHRASE:=}"

if ! command -v aptly >/dev/null 2>&1; then
  echo "ERROR: aptly no está instalado" >&2
  exit 1
fi

if [ -z "${APTLY_GPG_KEY_ID}" ] || [ -z "${APTLY_GPG_PASSPHRASE}" ]; then
  echo "ERROR: faltan APTLY_GPG_KEY_ID o APTLY_GPG_PASSPHRASE" >&2
  exit 1
fi

version="$(dpkg-parsechangelog -S Version)"
snapshot_suffix="${GITHUB_RUN_ID:-$(date +%Y%m%d%H%M%S)}"
snapshot_name="${APTLY_SNAPSHOT_NAME:-${APTLY_REPO_NAME}-${version}-${snapshot_suffix}}"

aptly snapshot create "${snapshot_name}" from repo "${APTLY_REPO_NAME}"

published_ref=". ${APTLY_PREFIX}/${APTLY_DISTRIBUTION}"
if [ "${APTLY_PREFIX}" = "." ]; then
  published_ref=". ${APTLY_DISTRIBUTION}"
fi

if aptly publish list -raw | grep -Fqx "${published_ref}"; then
  aptly publish switch \
    -batch \
    -component="${APTLY_COMPONENT}" \
    -gpg-key="${APTLY_GPG_KEY_ID}" \
    -passphrase="${APTLY_GPG_PASSPHRASE}" \
    "${APTLY_DISTRIBUTION}" "${APTLY_PREFIX}" "${snapshot_name}"
else
  aptly publish snapshot \
    -batch \
    -architectures="${APTLY_ARCHITECTURES}" \
    -distribution="${APTLY_DISTRIBUTION}" \
    -component="${APTLY_COMPONENT}" \
    -origin="${APTLY_ORIGIN}" \
    -label="${APTLY_LABEL}" \
    -acquire-by-hash \
    -gpg-key="${APTLY_GPG_KEY_ID}" \
    -passphrase="${APTLY_GPG_PASSPHRASE}" \
    "${snapshot_name}" "${APTLY_PREFIX}"
fi

if [ "${APTLY_PREFIX}" = "." ]; then
  echo "[INFO] Repo publicado bajo ~/.aptly/public/"
else
  echo "[INFO] Repo publicado bajo ~/.aptly/public/${APTLY_PREFIX}"
fi
