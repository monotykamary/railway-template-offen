FROM offen/offen:v1.4.2@sha256:4a69f8cbcdbff26505e728ad803a9b8ff6752bd10330749633bc507276e52c5d

USER root
COPY entrypoint.sh /usr/local/bin/railway-entrypoint
RUN chmod 755 /usr/local/bin/railway-entrypoint

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/railway-entrypoint"]
