#!/usr/bin/env bash
set -euo pipefail

: "${APTLY_REPO_NAME:=clamdscan-tools}"
PACKAGE_SOURCE="${1:-dist}"

if ! command -v aptly >/dev/null 2>&1; then
  echo "ERROR: aptly no está instalado" >&2
  exit 1
fi

shopt -s nullglob
packages=( "${PACKAGE_SOURCE}"/*.deb )
shopt -u nullglob

if [ "${#packages[@]}" -eq 0 ]; then
  echo "ERROR: no se encontraron .deb en ${PACKAGE_SOURCE}" >&2
  exit 1
fi

aptly repo add -force-replace "${APTLY_REPO_NAME}" "${PACKAGE_SOURCE}"

echo "[INFO] Paquetes agregados a ${APTLY_REPO_NAME} desde ${PACKAGE_SOURCE}"
