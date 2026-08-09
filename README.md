# Offen Fair Web Analytics on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/offen-fair-analytics)

A privacy-friendly [Offen Fair Web Analytics](https://www.offen.dev/) deployment pinned to `v1.4.2`. The wrapper runs migrations, creates the first operator idempotently, and connects Offen to a persistent Railway PostgreSQL service.

## Architecture

- **Offen**: public analytics collector, consent UI, and operator console.
- **PostgreSQL**: private metadata and event storage with a persistent volume.

The Offen service owns the public domain. Its deterministic root account ID is `6194a127-70e8-4af8-9f4c-31eab3c60cf9`.

## After deployment

1. Open the generated Offen domain and log in with `OFFEN_ADMIN_EMAIL` and `OFFEN_ADMIN_PASSWORD`.
2. Add the tracker to your site:

   ```html
   <script async src="https://YOUR-OFFEN-DOMAIN/script.js" data-account-id="6194a127-70e8-4af8-9f4c-31eab3c60cf9"></script>
   ```

3. Visit the tracked site, make a consent choice, and verify events in the operator console.
4. Configure SMTP if you need reliable invitations or password-reset email.

`OFFEN_SECRET` is generated as base64 key material. `DATABASE_URL` is a live PostgreSQL service reference. Do not replace either with values copied from a validation project.

## Important limitations

- Transactional email is unreliable until SMTP is configured.
- This template deploys one Offen web process; it is not a multi-region or high-availability topology.
- Analytics correctness depends on keeping the account ID and tracker domain unchanged.
- Back up PostgreSQL before version upgrades.

## Updating

Update the Offen tag and immutable digest in `Dockerfile`, then test migration, operator login, collection, reporting, and restart persistence. Source auto-deploys update the wrapper, not the pinned Offen image.

## Upstream

- Source: https://github.com/offen/offen
- Documentation: https://docs.offen.dev/
- Release: https://github.com/offen/offen/releases/tag/v1.4.2
- License: [Apache License 2.0](LICENSE)
