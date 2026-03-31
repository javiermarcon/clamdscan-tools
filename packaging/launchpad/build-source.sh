#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")/../.." && pwd)"
DIST_DIR="${ROOT_DIR}/dist/launchpad"
SOURCE_DIR="${DIST_DIR}/source-tree"

DEBFULLNAME="${DEBFULLNAME:-Javier Marcon}"
DEBEMAIL="${DEBEMAIL:-javiermarcon@gmail.com}"
DEBSIGN_KEYID="${DEBSIGN_KEYID:-5E3B821774D744578613925922B4D63898D3A00D}"
UBUNTU_SERIES="${UBUNTU_SERIES:-noble}"
BASE_VERSION="$(dpkg-parsechangelog -S Version | sed 's/~.*$//')"
PPA_VERSION="${PPA_VERSION:-${BASE_VERSION}+ppa1~${UBUNTU_SERIES}1}"
PPA_CHANGELOG_MSG="${PPA_CHANGELOG_MSG:-Launchpad PPA upload for Ubuntu ${UBUNTU_SERIES}.}"

if ! command -v debuild >/dev/null 2>&1; then
  echo "ERROR: debuild no está instalado" >&2
  exit 1
fi

if ! command -v dch >/dev/null 2>&1; then
  echo "ERROR: dch no está instalado" >&2
  exit 1
fi

if [ -n "$(git -C "${ROOT_DIR}" status --short)" ]; then
  echo "ERROR: el repositorio tiene cambios sin commit." >&2
  echo "ERROR: make ppa-source exporta HEAD; committeá primero lo que querés subir al PPA." >&2
  exit 1
fi

rm -rf "${DIST_DIR}"
mkdir -p "${DIST_DIR}" "${SOURCE_DIR}"

git -C "${ROOT_DIR}" archive --format=tar HEAD | tar -xf - -C "${SOURCE_DIR}"

(
  cd "${SOURCE_DIR}"
  DEBFULLNAME="${DEBFULLNAME}" DEBEMAIL="${DEBEMAIL}" \
    dch -v "${PPA_VERSION}" --distribution "${UBUNTU_SERIES}" "${PPA_CHANGELOG_MSG}"
  debuild -S -sa -k"${DEBSIGN_KEYID}"
)

find "${SOURCE_DIR}/.." -maxdepth 1 -type f \
  \( -name '*.changes' -o -name '*.dsc' -o -name '*.tar.*' -o -name '*.buildinfo' \) \
  -exec sh -c '
    for src do
      dest="'"${DIST_DIR}"'/$(basename "$src")"
      if [ "$(readlink -f "$src")" = "$(readlink -f "$dest")" ]; then
        continue
      fi
      cp -f "$src" "$dest"
    done
  ' sh {} +

echo "[INFO] Source package generado en ${DIST_DIR}"
