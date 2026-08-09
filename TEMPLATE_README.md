# Deploy and Host Offen Fair Web Analytics on Railway

## About Hosting Offen Fair Web Analytics

Offen is a fair and privacy-friendly web analytics platform. It provides consent-aware event collection, a user-facing auditorium, and an operator console without depending on a hosted analytics vendor. This template pins Offen `v1.4.2`.

## Common Use Cases

- Privacy-respecting website analytics
- First-party traffic and conversion reporting
- Consent-aware analytics for small teams
- Self-hosted alternatives to centralized tracking platforms

## Dependencies for Offen Fair Web Analytics Hosting

### Deployment Dependencies

The template creates a public **Offen** service and a private **PostgreSQL** service with persistent storage. `DATABASE_URL` is a cross-service reference and must not be replaced with a serialized credential.

### Implementation Details

The Offen service owns the public domain and exposes `/healthz`. It waits for PostgreSQL, runs migrations, and creates the first operator from `OFFEN_ADMIN_EMAIL`, `OFFEN_ADMIN_PASSWORD`, and `OFFEN_ACCOUNT_NAME`. Setup is idempotent across redeploys. The root analytics account uses ID `6194a127-70e8-4af8-9f4c-31eab3c60cf9`.

`OFFEN_SECRET` is generated as valid base64 key material. Add `/script.js` from the generated Offen domain to your site with the root account ID. SMTP is optional but required for dependable password-reset and invitation email.

### Why Deploy Offen Fair Web Analytics on Railway?

Railway supplies managed HTTPS, private service networking, persistent PostgreSQL, generated secrets, and health-driven deploys. The result is a small, reproducible analytics stack with deliberate upstream upgrades.
