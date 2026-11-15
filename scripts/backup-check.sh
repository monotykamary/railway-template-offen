#!/bin/sh
set -eu
export PGPASSWORD="${POSTGRES_PASSWORD:?}"
user="${POSTGRES_USER:?}"; database="${POSTGRES_DB:?}"; scratch=railway_validation_restore
file="/tmp/offen-validation-$$.dump"
cleanup() { dropdb -U "$user" --if-exists "$scratch" >/dev/null 2>&1 || true; rm -f "$file"; }
trap cleanup EXIT HUP INT TERM
cleanup
case "${SMOKE_PHASE:?}" in upgrade|redeploy) reindexdb -U "$user" "$database" ;; esac
pg_dump -U "$user" -Fc -f "$file" "$database"
createdb -U "$user" "$scratch"
pg_restore -U "$user" --exit-on-error --no-owner -d "$scratch" "$file"
count=$(psql -U "$user" -d "$scratch" -Atc 'SELECT count(*) FROM events;')
[ "$count" -ge 2 ]
printf '{"ok":true,"phase":"%s","full_backup_restore_verified":true,"restored_analytics_events":%s}\n' "$SMOKE_PHASE" "$count"
