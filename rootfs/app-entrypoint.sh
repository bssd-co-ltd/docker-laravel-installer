#!/bin/bash

set -o errexit
set -o pipefail
# set -o xtrace

# Load libraries
# shellcheck disable=SC1091
. /opt/bitnami/base/functions

# Constants
INIT_SEM=/tmp/initialized.sem

# Functions

########################
# Replace a regex in a file
# Arguments:
#   $1 - filename
#   $2 - match regex
#   $3 - substitute regex
#   $4 - regex modifier
# Returns: none
#########################
replace_in_file() {
    local filename="${1:?filename is required}"
    local match_regex="${2:?match regex is required}"
    local substitute_regex="${3:?substitute regex is required}"
    local regex_modifier="${4:-}"
    local result

    # We should avoid using 'sed in-place' substitutions
    # 1) They are not compatible with files mounted from ConfigMap(s)
    # 2) We found incompatibility issues with Debian10 and "in-place" substitutions
    result="$(sed "${regex_modifier}s@${match_regex}@${substitute_regex}@g" "$filename")"
    echo "$result" >"$filename"
}

########################
# Setup the database configuration
# Arguments: none
# Returns: none
#########################
setup_db() {
    log "Configuring the database"
    php artisan migrate --force
}

print_welcome_page

if [ "${1}" == "php" ] && [ "${2}" == "-v" ]; then
    if [[ ! -d /app/app ]]; then
        log "Regenerating APP_KEY"
        php artisan key:generate --ansi
    fi

    log "Installing/Updating Laravel dependencies (composer)"
    if [[ ! -d /app/vendor ]]; then
        composer install
        log "Dependencies installed"
    else
        composer update
        log "Dependencies updated"
    fi

    log "Start migrate database"
    setup_db
    log "Initialization finished"

    log "Initial passport"
    if [[ ! -f /app/storage/oauth-private.key ]]; then
        php artisan passport:install
        log "Passport successful initial"
    else
        log "Passport installed, skip this step"
    fi
    log "Success from Laravel Installer "
else
    log "Nothing happened"
fi
exec tini -- "$@"

