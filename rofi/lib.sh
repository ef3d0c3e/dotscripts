#!/usr/bin/env bash

# 'rofi' or 'dmenu' (default)
GUI_MENU='rofi'

notify_err()
{
	notify-send "Error: ${1}"
}

notify_msg()
{
	notify-send "${1}"
}

cfg_file()
{
	dir=$(dirname "${1}")

	if [[ ! -d "${dir}" ]]
	then
		echo "Creating directory: '${1}'.."
		if ! mkdir -p -- "${dir}"
		then
			notify_err "Failed to create directory for file: '${1}'"
			exit 1
		fi
	fi

	if [[ ! -f "${1}" ]]
	then
		if ! touch -- "${1}"
		then
			notify_err "Failed to create file: '${1}'"
			exit 1
		fi
	fi

	printf "%s" "${1}"
}

gui_menu()
{
	if [[ "${GUI_MENU}" == 'rofi' ]]
	then
		res=$(printf "%s" "${2}" | rofi -dmenu -p "${1}")
	else
		res=$(printf "%s" "${2}" | dmenu -p "${1}")
	fi

	printf "%s" "${res}"
}

gui_menu_markup()
{
	if [[ "${GUI_MENU}" == 'rofi' ]]
	then
		res=$(printf "%s" "${2}" | rofi -dmenu -markup-rows -p "${1}")
	else
		res=$(printf "%s" "${2}" | dmenu -p "${1}")
	fi

	printf "%s" "${res}"
}

colored_text()
{
	if [[ "${GUI_MENU}" == 'rofi' ]]
	then
		printf "<span color='%s'>%s</span>\n" "${1}" "${2}"
	else
		printf '%s\n' "${2}"
	fi
}
