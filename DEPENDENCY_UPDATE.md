# PostgreSQL 17 maintenance candidate — 2026-11-15

Keep Offen v1.4.2 and its exact image unchanged. Advance only PostgreSQL 17.11 to stable 17.12 by exact image digest, retaining the published volume at `/var/lib/postgresql/data`. Official PostgreSQL 17.12 notes state that dump/restore is not required from 17.X. They also advise reviewing index-corruption fixes and taking a fresh full backup rather than trusting existing incremental backups.

This candidate does not change PostgreSQL major version. The release gate requires a full logical backup restored into an isolated scratch database, real encrypted opt-in analytics ingestion, visitor decryption/counts and operator access, opt-out suppression, visitor purge, and original-event survival after in-place upgrade/redeploy. Validation reindexes after upgrade and verifies a new full backup. Operators must retain their own pre-update backup and review the upstream REINDEX guidance; test data does not certify arbitrary pre-existing index health.

All production application FROM references remain exact version/digest pairs; no validation credentials are template defaults. Public HTTPS and live Railway validation remain required before publication.
