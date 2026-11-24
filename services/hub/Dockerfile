# Selenium Grid hub for Railway: the official image plus a start wrapper that
# makes sure the hub never runs without its login (basic auth) and node
# registration secret.
#
# selenium/hub:4.54.0-20261123 (Selenium 4.54.0), multi-arch index digest,
# checked 2026-11-24. To upgrade, change tag and digest here and the node
# image tags in template.json together (hub and nodes must match).
FROM selenium/hub:4.54.0-20261123@sha256:e95b7e26ea772c391a8c9f47fe04cf5ebb3eb53084eb7a00469d52739f7f40b8

# /opt/bin exists in the base image (scripts of docker-selenium live there).
COPY --chmod=0755 railway-hub.sh /opt/bin/railway-hub.sh

EXPOSE 4444 4442 4443
CMD ["/opt/bin/railway-hub.sh"]
