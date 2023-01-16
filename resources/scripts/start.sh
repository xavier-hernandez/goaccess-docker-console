#!/bin/bash
source $(dirname "$0")/funcs/environment.sh
source $(dirname "$0")/logs/npm.sh

goan_version="GOAC v0.0.1"
goan_log_path="/opt/log"

goaccess_ping_interval=15
goaccess_debug_file=/goaccess-logs/goaccess.debug
goaccess_invalid_file=/goaccess-logs/goaccess.invalid

echo -e "\n${goan_version}\n"

# BEGIN PROXY LOGS
echo -e "\n\nNPM INSTANCE SETTING UP..."
npm
# END PROXY LOGS

#Leave container running
wait -n