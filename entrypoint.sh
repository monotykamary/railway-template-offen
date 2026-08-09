#!/bin/sh
set -eu

require() {
  name="$1"
  eval "value=\${$name:-}"
  if [ -z "$value" ]; then
    printf 'Required variable %s is not set.\n' "$name" >&2
    exit 1
  fi
}

for name in \
  DATABASE_URL \
  RAILWAY_PUBLIC_DOMAIN \
  OFFEN_SECRET \
  OFFEN_ADMIN_EMAIL \
  OFFEN_ADMIN_PASSWORD \
  OFFEN_ACCOUNT_NAME
do
  require "$name"
done

case "$OFFEN_ADMIN_EMAIL" in
  *@*) ;;
  *)
    printf 'OFFEN_ADMIN_EMAIL must be an email address.\n' >&2
    exit 1
    ;;
esac

if [ "${#OFFEN_SECRET}" -lt 32 ] || ! printf '%s' "$OFFEN_SECRET" | base64 -d >/dev/null 2>&1; then
  printf 'OFFEN_SECRET must be valid base64 containing at least 24 bytes.\n' >&2
  exit 1
fi

if [ "${#OFFEN_ADMIN_PASSWORD}" -lt 16 ]; then
  printf 'OFFEN_ADMIN_PASSWORD must contain at least 16 characters.\n' >&2
  exit 1
fi

admin_email="$OFFEN_ADMIN_EMAIL"
admin_password="$OFFEN_ADMIN_PASSWORD"
account_name="$OFFEN_ACCOUNT_NAME"

: "${PORT:=8080}"
export OFFEN_SERVER_PORT="$PORT"
export OFFEN_SERVER_REVERSEPROXY=true
export OFFEN_DATABASE_DIALECT=postgres
export OFFEN_DATABASE_CONNECTIONSTRING="$DATABASE_URL"
export OFFEN_DATABASE_CONNECTIONRETRIES=10
export OFFEN_APP_SINGLENODE=true
export OFFEN_SERVER_AUTHTOKEN="$OFFEN_SECRET"
export OFFEN_SERVER_COOKIEEXCHANGESECRET="$OFFEN_SECRET"
root_account_id=6194a127-70e8-4af8-9f4c-31eab3c60cf9
export OFFEN_APP_ROOTACCOUNT="$root_account_id"
export OFFEN_SERVER_DOMAIN="${OFFEN_SERVER_DOMAIN:-${RAILWAY_PUBLIC_DOMAIN}}"

unset OFFEN_ADMIN_PASSWORD

attempt=1
until offen migrate >/tmp/offen-migrate.log 2>&1; do
  if [ "$attempt" -ge 60 ]; then
    printf 'Offen database migrations did not succeed after 120 seconds.\n' >&2
    exit 1
  fi
  attempt=$((attempt + 1))
  sleep 2
done

if offen setup \
  -email "$admin_email" \
  -name "$account_name" \
  -password "$admin_password" \
  -forceid "$root_account_id" \
  >/tmp/offen-setup.log 2>&1; then
  printf 'Created the initial Offen operator account.\n'
elif grep -Fq 'action would overwrite existing data - not allowed' /tmp/offen-setup.log; then
  printf 'The Offen operator account is already initialized.\n'
else
  printf 'Could not create the initial Offen operator account.\n' >&2
  exit 1
fi

unset admin_password OFFEN_ADMIN_EMAIL OFFEN_ACCOUNT_NAME
exec offen
