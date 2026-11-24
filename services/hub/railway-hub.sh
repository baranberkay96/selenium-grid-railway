#!/usr/bin/env bash
# Start the Selenium Grid hub on Railway.
#
# Selenium only asks for a login when SE_ROUTER_PASSWORD is set, so an empty
# value would leave the grid open to anyone who finds the URL. This wrapper
# never lets that happen and never fails the deploy over a variable: an
# unusable value is replaced by a random one nobody knows (the grid is then
# locked) and the log says how to fix it. Then the image's own entry point runs.
set -u

log() { echo "[railway-hub] $*"; }
warn() { echo "[railway-hub] WARNING: $*" >&2; }
random() { od -An -N24 -tx1 /dev/urandom | tr -d ' \n'; }

user=${SE_ROUTER_USERNAME:-}
if [[ ! "$user" =~ ^[A-Za-z0-9._@-]{1,64}$ ]]; then
  warn "SE_ROUTER_USERNAME='$user' is empty or has characters other than A-Z a-z 0-9 . _ @ -; using 'selenium'"
  user=selenium
fi

password=${SE_ROUTER_PASSWORD:-}
if [[ ${#password} -lt 12 || ${#password} -gt 128 || "$password" == *[[:space:]]* ]]; then
  warn "SE_ROUTER_PASSWORD is empty, shorter than 12, longer than 128 characters or contains spaces."
  warn "The grid is LOCKED with a random password nobody knows. Set SE_ROUTER_PASSWORD"
  warn "(12-128 characters) on the Selenium Hub service and redeploy it."
  password=$(random)
fi

secret=${SE_REGISTRATION_SECRET:-}
if [[ ${#secret} -lt 16 || "$secret" == *[[:space:]]* ]]; then
  warn "SE_REGISTRATION_SECRET is empty, shorter than 16 characters or contains spaces; nodes cannot register"
  warn "until it is fixed (the nodes read it from this service). Using a random secret."
  secret=$(random)
fi

port=${SE_HUB_PORT:-4444}
if [[ ! "$port" =~ ^[0-9]{2,5}$ ]]; then
  warn "SE_HUB_PORT='$port' is not a port number; using 4444"
  port=4444
fi

export SE_ROUTER_USERNAME=$user SE_ROUTER_PASSWORD=$password SE_REGISTRATION_SECRET=$secret SE_HUB_PORT=$port
log "Grid login required (user $user); nodes register with the registration secret; port $port"
exec /opt/bin/entry_point.sh
