#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")/../.." && pwd)"
DIST_DIR="${ROOT_DIR}/dist/tarball"
PACKAGE="${PACKAGE:-clamdscan-tools}"
BASE_VERSION="$(dpkg-parsechangelog -S Version | sed 's/[+~].*$//')"
TARBALL_VERSION="${TARBALL_VERSION:-${BASE_VERSION}}"
ARCHIVE_BASENAME="${PACKAGE}-${TARBALL_VERSION}"
ARCHIVE_PATH="${DIST_DIR}/${ARCHIVE_BASENAME}.tar.gz"

if [ -n "$(git -C "${ROOT_DIR}" status --short)" ]; then
  echo "ERROR: el repositorio tiene cambios sin commit." >&2
  echo "ERROR: make source-tarball exporta HEAD; committeá primero lo que querés publicar." >&2
  exit 1
fi

rm -rf "${DIST_DIR}"
mkdir -p "${DIST_DIR}"

git -C "${ROOT_DIR}" archive \
  --format=tar.gz \
  --prefix="${ARCHIVE_BASENAME}/" \
  -o "${ARCHIVE_PATH}" \
  HEAD

echo "[INFO] Tarball generado en ${ARCHIVE_PATH}"
