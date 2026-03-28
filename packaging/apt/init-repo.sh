#!/usr/bin/env bash
set -euo pipefail

: "${APTLY_ROOT:=${HOME}/.aptly}"
: "${APTLY_REPO_NAME:=clamdscan-tools}"
: "${APTLY_DISTRIBUTION:=stable}"
: "${APTLY_COMPONENT:=main}"

if ! command -v aptly >/dev/null 2>&1; then
  echo "ERROR: aptly no está instalado" >&2
  exit 1
fi

mkdir -p "${APTLY_ROOT}"

if aptly repo show "${APTLY_REPO_NAME}" >/dev/null 2>&1; then
  echo "[INFO] Repo aptly existente: ${APTLY_REPO_NAME}"
  exit 0
fi

aptly repo create \
  -distribution="${APTLY_DISTRIBUTION}" \
  -component="${APTLY_COMPONENT}" \
  -comment="clamdscan-tools APT repository" \
  "${APTLY_REPO_NAME}"

echo "[INFO] Repo aptly creado: ${APTLY_REPO_NAME}"
