#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")/../.." && pwd)"
DIST_DIR="${ROOT_DIR}/dist/launchpad"
PPA_TARGET="${PPA_TARGET:-ppa:javiermarcon/clamdscan-tools}"

if ! command -v dput >/dev/null 2>&1; then
  echo "ERROR: dput no está instalado" >&2
  exit 1
fi

latest_changes="$(find "${DIST_DIR}" -maxdepth 1 -type f -name '*_source.changes' | sort | tail -n 1)"

if [ -z "${latest_changes}" ]; then
  echo "ERROR: no se encontró ningún *_source.changes en ${DIST_DIR}" >&2
  exit 1
fi

dput "${PPA_TARGET}" "${latest_changes}"
