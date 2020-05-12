#!/bin/bash

#=================================================
# PERSONAL HELPERS
#=================================================
ynh_add_systemd_config_custom () {
	# Declare an array to define the options of this helper.
	local legacy_args=st
	declare -Ar args_array=( [s]=service= [t]=template= [u]=unitType=)
	local service
	local template
	local unitType

	# Manage arguments with getopts
	ynh_handle_getopts_args "$@"
	local service="${service:-$app}"
	local template="${template:-systemd.service}"
	local unitType="${unitType:-service}"

	finalsystemdconf="/etc/systemd/system/$service.$unitType"
	ynh_backup_if_checksum_is_different --file="$finalsystemdconf"
	sudo cp ../conf/$template "$finalsystemdconf"

	# To avoid a break by set -u, use a void substitution ${var:-}. If the variable is not set, it's simply set with an empty variable.
	# Substitute in a nginx config file only if the variable is not empty
	if test -n "${final_path:-}"; then
		ynh_replace_string --match_string="__FINALPATH__" --replace_string="$final_path" --target_file="$finalsystemdconf"
	fi
	if test -n "${app:-}"; then
		ynh_replace_string --match_string="__APP__" --replace_string="$app" --target_file="$finalsystemdconf"
	fi
	if test -n "${interface:-}"; then
		ynh_replace_string --match_string="__INTERFACE__" --replace_string="$interface" --target_file="$finalsystemdconf"
	fi

	ynh_store_file_checksum --file="$finalsystemdconf"

	sudo chown root: "$finalsystemdconf"
	sudo systemctl enable $service
	sudo systemctl daemon-reload
}

# Remove the dedicated systemd config
#
# usage: ynh_remove_systemd_config [--service=service]
# | arg: -s, --service - Service name (optionnal, $app by default)
#
# Requires YunoHost version 2.7.2 or higher.
ynh_remove_systemd_config_custom () {
	# Declare an array to define the options of this helper.
	local legacy_args=s
	declare -Ar args_array=( [s]=service= [u]=unitType=)
	local service
	local unitType
	# Manage arguments with getopts
	ynh_handle_getopts_args "$@"
	local service="${service:-$app}"
	local unitType="${unitType:-service}"

	local finalsystemdconf="/etc/systemd/system/$service.$unitType"
	if [ -e "$finalsystemdconf" ]; then
		ynh_systemd_action --service_name=$service --action=stop
		systemctl disable $service
		ynh_secure_remove --file="$finalsystemdconf"
		systemctl daemon-reload
	fi
}

#=================================================
# EXPERIMENTAL HELPERS
#=================================================

#=================================================
# FUTURE OFFICIAL HELPERS
#=================================================
