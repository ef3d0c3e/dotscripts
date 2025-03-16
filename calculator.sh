#!/usr/bin/env bash

DIR="$(dirname "${0}")"
source "${DIR}/lib.sh"

CACHEDIR=${XDG_CACHE_HOME:-/tmp}
HIST_FILE=$(cfg_file "${CACHEDIR}/rofi-calc/calculator.history")
ACTION="$(gui_menu "calc" "$(cat "${HIST_FILE}" || true)")"

do_calc()
{
	answer=$(echo "${ACTION}" | giac 2>/dev/null | head -n -1 | tail -n -1)
	printf "%s = %s\n" "${ACTION}" "${answer}" >> "${HIST_FILE}"
	return 0
}

case ${ACTION} in
	clear) rm "${HIST_FILE}" && $0 ;;
	"") ;;
	*) do_calc "${ACTION}" && $0 ;;
esac
