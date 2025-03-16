#!/usr/bin/env bash

notify_err()
{
	notify-send "Error: ${1}"
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
	res=$(printf "%s" "${2}" | rofi -dmenu -p "$1")

	printf "%s" "${res}"
}
