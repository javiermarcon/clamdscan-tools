#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)"

NEW_VERSION="${NEW_VERSION:-}"
MSG="${MSG:-}"
RELEASE_COMMIT_MSG="${RELEASE_COMMIT_MSG:-}"
RELEASE_TAG_MSG="${RELEASE_TAG_MSG:-}"
RELEASE_PPA_SOURCE="${RELEASE_PPA_SOURCE:-1}"

if [ -z "${NEW_VERSION}" ]; then
  echo "ERROR: usá make release NEW_VERSION=X.Y.Z MSG='texto del changelog'" >&2
  exit 1
fi

if [ -z "${MSG}" ]; then
  echo "ERROR: usá make release NEW_VERSION=X.Y.Z MSG='texto del changelog'" >&2
  exit 1
fi

if [ -n "$(git -C "${ROOT_DIR}" status --short)" ]; then
  echo "ERROR: el repositorio no está limpio." >&2
  echo "ERROR: make release hace commit y tag; limpiá o committeá cambios previos primero." >&2
  exit 1
fi

if git -C "${ROOT_DIR}" rev-parse "v${NEW_VERSION}" >/dev/null 2>&1; then
  echo "ERROR: el tag v${NEW_VERSION} ya existe." >&2
  exit 1
fi

if [ -z "${RELEASE_COMMIT_MSG}" ]; then
  RELEASE_COMMIT_MSG="Release v${NEW_VERSION}"
fi

if [ -z "${RELEASE_TAG_MSG}" ]; then
  RELEASE_TAG_MSG="Release v${NEW_VERSION}"
fi

cd "${ROOT_DIR}"

echo "[INFO] Actualizando changelog a ${NEW_VERSION}"
make changelog NEW_VERSION="${NEW_VERSION}" MSG="${MSG}"

echo "[INFO] Sincronizando documentación versionada"
make build

echo "[INFO] Cerrando entrada de release en debian/changelog"
DEBFULLNAME="${DEBFULLNAME:-Javier Marcon}" \
DEBEMAIL="${DEBEMAIL:-javiermarcon@gmail.com}" \
  dch -r --no-force-save-on-release ""

echo "[INFO] Creando commit de release"
git add \
  debian/changelog \
  README.md \
  docs/clamdscan-tools.texi \
  docs/clamdscan-tools.info \
  docs/clamdscan-progress.1 \
  docs/clamdscan-watch.1 \
  docs-site/install.md
git commit -m "${RELEASE_COMMIT_MSG}"

echo "[INFO] Creando tag v${NEW_VERSION}"
git tag -a "v${NEW_VERSION}" -m "${RELEASE_TAG_MSG}"

echo "[INFO] Generando paquete Debian"
make package

echo "[INFO] Generando tarball portable"
make source-tarball

if [ "${RELEASE_PPA_SOURCE}" = "1" ]; then
  echo "[INFO] Generando source package para Launchpad"
  make ppa-source
fi

cat <<EOF
[INFO] Release preparada.
[INFO] Commit: ${RELEASE_COMMIT_MSG}
[INFO] Tag: v${NEW_VERSION}
[INFO] Artefactos:
[INFO]   - dist/
[INFO] Si corresponde, hacé push del commit y del tag:
[INFO]   git push origin HEAD
[INFO]   git push origin v${NEW_VERSION}
EOF
