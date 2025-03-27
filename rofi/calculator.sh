#!/usr/bin/env bash

DIR="$(dirname "${0}")"
source "${DIR}/lib.sh"

CACHEDIR=${XDG_CACHE_HOME:-/tmp}
HIST_FILE=$(cfg_file "${CACHEDIR}/rofi-calc/calculator.history")
ACTION="$(gui_menu "calc" "$(cat "${HIST_FILE}" || true)")"

# Chosen backend, one of 'bc', 'giac' or 'qalc'
BACKEND='giac'

# bc backend
do_calc_bc()
{
	answer=$(echo "${ACTION}" | bc -l)
	fmt=$(printf "%s = %s\n" "${ACTION}" "${answer}" | cat - "${HIST_FILE}")
	printf "%s" "${fmt}" > "${HIST_FILE}"
	return 0
}

# Giac (Xcas) backend
do_calc_giac()
{
	answer=$(echo "${ACTION}" | giac 2>/dev/null | head -n -1 | tail -n -1)
	fmt=$(printf "%s = %s\n" "${ACTION}" "${answer}" | cat - "${HIST_FILE}")
	printf "%s" "${fmt}" > "${HIST_FILE}"
	return 0
}

# Qalc backend
do_calc_qalc()
{
	answer=$(qalc "${ACTION}")
	fmt=$(printf "%s\n" "${answer}" | cat - "${HIST_FILE}")
	printf "%s" "${fmt}" > "${HIST_FILE}"
	return 0
}

case ${ACTION} in
	*clear*) rm "${HIST_FILE}" && $0 ;;
	"") ;;
	*) case ${BACKEND} in
		'bc') do_calc_bc "${ACTION}" && $0 ;;
		'giac') do_calc_giac "${ACTION}" && $0 ;;
		'qalc') do_calc_qalc "${ACTION}" && $0 ;;
		*) notify_err "Unknown backend: '${BACKEND}'" ;;
	esac ;;
esac
