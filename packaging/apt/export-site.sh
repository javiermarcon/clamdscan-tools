#!/usr/bin/env bash
set -euo pipefail

: "${APTLY_ROOT:=${HOME}/.aptly}"
: "${APTLY_DISTRIBUTION:=stable}"
: "${APT_SITE_DIR:=site/apt}"
: "${KEYS_SITE_DIR:=site/keys}"
: "${PUBLIC_KEY_SOURCE:=packaging/apt/public-gpg-key.asc}"
: "${PUBLIC_KEY_TARGET:=clamdscan-tools-archive-key.asc}"

if [ ! -d "${APTLY_ROOT}/public" ]; then
  echo "ERROR: no existe ${APTLY_ROOT}/public; primero ejecutá la publicación de aptly" >&2
  exit 1
fi

if [ ! -f "${PUBLIC_KEY_SOURCE}" ]; then
  echo "ERROR: no existe ${PUBLIC_KEY_SOURCE}" >&2
  exit 1
fi

if [ ! -f "${APTLY_ROOT}/public/dists/${APTLY_DISTRIBUTION}/Release" ]; then
  echo "ERROR: no existe ${APTLY_ROOT}/public/dists/${APTLY_DISTRIBUTION}/Release; la publicación de aptly no terminó bien" >&2
  exit 1
fi

rm -rf "${APT_SITE_DIR}" "${KEYS_SITE_DIR}"
mkdir -p "${APT_SITE_DIR}" "${KEYS_SITE_DIR}"

cp -a "${APTLY_ROOT}/public/." "${APT_SITE_DIR}/"
cp "${PUBLIC_KEY_SOURCE}" "${KEYS_SITE_DIR}/${PUBLIC_KEY_TARGET}"

echo "[INFO] Exportado repo APT a ${APT_SITE_DIR}"
echo "[INFO] Exportada clave pública a ${KEYS_SITE_DIR}/${PUBLIC_KEY_TARGET}"
