#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")/../.." && pwd)"

PREFIX="${PREFIX:-/usr/local}"
DESTDIR="${DESTDIR:-}"
SYSCONFDIR="${SYSCONFDIR:-/etc}"
LOCALSTATEDIR="${LOCALSTATEDIR:-/var}"
BINDIR="${BINDIR:-${PREFIX}/bin}"
LIBDIR="${LIBDIR:-${PREFIX}/lib/clamdscan-tools}"
MANDIR="${MANDIR:-${PREFIX}/share/man}"
INFODIR="${INFODIR:-${PREFIX}/share/info}"
TMPFILESDIR="${TMPFILESDIR:-${PREFIX}/lib/tmpfiles.d}"
CONFIG_MODE="${CONFIG_MODE:-preserve}"

install_file() {
  local mode="$1"
  local source="$2"
  local destination="$3"

  install -Dm"${mode}" "${ROOT_DIR}/${source}" "${DESTDIR}${destination}"
}

install_config() {
  local source="$1"
  local destination="$2"

  if [ "${CONFIG_MODE}" = "preserve" ] && [ -e "${DESTDIR}${destination}" ]; then
    echo "[INFO] Preservando ${destination}"
    return
  fi

  install_file 644 "${source}" "${destination}"
}

case "${CONFIG_MODE}" in
  preserve|overwrite)
    ;;
  *)
    echo "ERROR: CONFIG_MODE debe ser preserve u overwrite" >&2
    exit 1
    ;;
esac

install_file 755 "bin/clamdscan-progress" "${BINDIR}/clamdscan-progress"
install_file 755 "bin/clamdscan-watch" "${BINDIR}/clamdscan-watch"
install_file 644 "lib/clamdscan-tools.sh" "${LIBDIR}/clamdscan-tools.sh"

install_config "config/clamdscan-tools.conf" "${SYSCONFDIR}/clamdscan-tools/clamdscan-tools.conf"
install_config "config/excludes.conf" "${SYSCONFDIR}/clamdscan-tools/excludes.conf"
install_config "config/prune-paths.conf" "${SYSCONFDIR}/clamdscan-tools/prune-paths.conf"
install_config "config/exclude-file-patterns.conf" "${SYSCONFDIR}/clamdscan-tools/exclude-file-patterns.conf"
install_config "config/exclude-files.conf" "${SYSCONFDIR}/clamdscan-tools/exclude-files.conf"

install_file 644 "docs/clamdscan-progress.1" "${MANDIR}/man1/clamdscan-progress.1"
install_file 644 "docs/clamdscan-watch.1" "${MANDIR}/man1/clamdscan-watch.1"
install_file 644 "docs/clamdscan-tools.info" "${INFODIR}/clamdscan-tools.info"
install_file 644 "debian/clamdscan-tools.tmpfiles" "${TMPFILESDIR}/clamdscan-tools.conf"

install -d -m 755 \
  "${DESTDIR}${LOCALSTATEDIR}/log/clamdscan-tools" \
  "${DESTDIR}${LOCALSTATEDIR}/lib/clamdscan-tools" \
  "${DESTDIR}${LOCALSTATEDIR}/lib/clamdscan-tools/state" \
  "${DESTDIR}${LOCALSTATEDIR}/lib/clamdscan-tools/infected"

cat <<EOF
[INFO] Instalacion completada.
[INFO] Binarios: ${DESTDIR}${BINDIR}
[INFO] Configuracion: ${DESTDIR}${SYSCONFDIR}/clamdscan-tools
[INFO] Runtime: ${DESTDIR}${LOCALSTATEDIR}/log/clamdscan-tools y ${DESTDIR}${LOCALSTATEDIR}/lib/clamdscan-tools
[INFO] Si instalaste sobre el sistema real, revisa que existan las dependencias de ClamAV antes de ejecutar clamdscan-progress.
EOF
