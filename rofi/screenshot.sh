#!/usr/bin/env bash

DIR="$(dirname "${0}")"
source "${DIR}/lib.sh"

CONFIGDIR=${XDG_CONFIG_HOME:-/tmp}
CACHEDIR=${XDG_CACHE_HOME:-/tmp}
CFG_FILE=$(cfg_file "${CONFIGDIR}/rofi-screenshot/scrot.conf")

# Default opts
CFG_BACKEND='deepin'
CFG_DELAY=0
CFG_SAVEFOLDER="${XDG_PICTURES_DIR}/Screenshots"
CFG_UPLOAD='Catbox'

output_config()
{
	printf 'backend=%s\n' "${CFG_BACKEND}"
	printf 'delay=%s\n' "${CFG_DELAY}"
	printf 'savefolder=%s\n' "${CFG_SAVEFOLDER}"
	printf 'uploadmode=%s\n' "${CFG_UPLOAD}"
}

load_config()
{
	if [[ ! -s "${CFG_FILE}" ]]
	then
		notify_msg "Creating configuration file: '${CFG_FILE}'"
		output_config > "${CFG_FILE}"
		return 1
	fi

	CFG_BACKEND="$(awk -F "=" '/backend/ {print $2}' "${CFG_FILE}")"
	CFG_DELAY="$(awk -F "=" '/delay/ {print $2}' "${CFG_FILE}")"
	CFG_SAVEFOLDER="$(awk -F "=" '/savefolder/ {print $2}' "${CFG_FILE}")"
	CFG_UPLOAD="$(awk -F "=" '/uploadmode/ {print $2}' "${CFG_FILE}")"

	return 0
}

cfg_backend()
{
	ANSWER=$(gui_menu "scrot/backend" \
"< Back
deepin
maim")
	case "${ANSWER}" in
		''|'< Back') ;;
		'deepin'|'maim') CFG_BACKEND="${ANSWER}" ;;
		*) notify_err "Unknown scrot backend: '${ANSWER}'" ;;
	esac
}

cfg_delay()
{
	ANSWER=$(gui_menu "scrot/delay" \
"< Back")
	case "${ANSWER}" in
		''|'< Back') ;;
		*[!0-9]) notify_err "Invalid delay: '${ANSWER}'" ;;
		*) CFG_DELAY="${ANSWER}" ;;
	esac
}

cfg_savefolder()
{
	ANSWER=$(gui_menu "scrot/savefolder" \
"< Back")
	case "${ANSWER}" in
		''|'< Back') return 0 ;;
		*) ;;
	esac

	if [[ ! -d "${ANSWER}" ]]
	then
		notify_err "Folder '${ANSWER}' does not exist"
	elif [[ ! -w "${ANSWER}" ]]
	then
		notify_err "Folder '${ANSWER}' is not writeable"
	else
		CFG_SAVEFOLDER="${ANSWER}"
	fi
}

cfg_upload()
{
	ANSWER=$(gui_menu "scrot/upload" \
"< Back
Catbox
0x0")
	case "${ANSWER}" in
		''|'< Back') ;;
		'Catbox'|'0x0'|'Imgur') CFG_UPLOAD="${ANSWER}" ;;
		*) notify_err "Unknown upload method: '${ANSWER}'" ;;
	esac
}

take_scrot()
{
	filename="${CFG_SAVEFOLDER}/$(date +%Y)-$(date +%m)-$(date +%d)-$(date +%H):$(date +%M):$(date +%S)"
	sleep "${CFG_DELAY}"

	if [[ -f "${filename}.png" ]]
	then
		i=1
		while [[ -f "${filename}_${i}.png" ]]
		do
			i=$((${i}+1))
		done
		filename="${filename}_${i}.png"
	else
		filename="${filename}.png"
	fi

	case "${CFG_BACKEND}" in
		'deepin') deepin-screen-recorder -n -s "${filename}" ;;
		'maim') maim -s "${filename}" ;;
		*) notify_err "Unknown backend '${CFG_BACKEND}'" && return 1 ;;
	esac
	if [[ ! -f "${filename}" ]]
	then
		notify_err "Failed to save '${filename}'"
	fi
}

upload_scrot()
{
	filename="${CACHEDIR}/scrot.png"
	sleep "${CFG_DELAY}"

	case "${CFG_BACKEND}" in
		'deepin') deepin-screen-recorder -n -s "${filename}" ;;
		'maim') maim -s "${filename}" ;;
		*) notify_err "Unknown backend '${CFG_BACKEND}'" && return 1 ;;
	esac
	if [[ ! -f "${filename}" ]]
	then
		notify_err "Failed to save '${filename}'"
	fi

	if [[ "${CFG_UPLOAD}" == "Catbox" ]]
	then
		url="$(curl -compressed --connect-timeout 5 -m 120 --retry 1 -F "reqtype=fileupload" -F "fileToUpload=@${filename}" "https://catbox.moe/user/api.php")"

		notify_msg "$(printf "Screenshot uploaded! %s\n" "${url}")"
		printf '%s\n' "${url}" | xsel -i -b
	elif [[ "${CFG_UPLOAD}" == "0x0" ]]
	then
		url="$(curl -compressed --connect-timeout 5 -m 120 --retry 1 -F "file=@${filename}" "https://0x0.st")"

		notify_msg "$(printf "Screenshot uploaded! %s\n" "${url}")"
		printf '%s\n' "${url}" | xsel -i -b
	else
		notify_err "Unknown backend '${CFG_BACKEND}'"
	fi
}

show_menu()
{
	ANSWER=$(gui_menu_markup 'scrot' \
"$(colored_text orange 'Take screenshot' || true)
$(colored_text orange 'Upload screenshot' || true)
$(printf 'Backend: %s' "${CFG_BACKEND}")
$(printf 'Delay: %ss' "${CFG_DELAY}")
$(printf 'Save folder: %s' "${CFG_SAVEFOLDER}")
$(printf 'Upload to: %s' "${CFG_UPLOAD}")
$(colored_text cyan 'Save settings' || true)")

	if [[ "${ANSWER}" =~ "Take screenshot" ]]
	then
		take_scrot
	elif [[ "${ANSWER}" =~ "Upload screenshot" ]]
	then
		upload_scrot
	elif [[ "${ANSWER}" =~ "Backend:"(.*) ]]
	then
		cfg_backend
		show_menu
	elif [[ "${ANSWER}" =~ "Delay:"(.*) ]]
	then
		cfg_delay
		show_menu
	elif [[ "${ANSWER}" =~ "Save folder:"(.*) ]]
	then
		cfg_savefolder
		show_menu
	elif [[ "${ANSWER}" =~ "Upload to:"(.*) ]]
	then
		cfg_upload
		show_menu
	elif [[ "${ANSWER}" =~ "Save settings" ]]
	then
		output_config > "${CFG_FILE}"
		show_menu
	fi
}

load_config
show_menu
