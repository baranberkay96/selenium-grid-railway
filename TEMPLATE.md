# TEMPLATE: Selenium Grid 4.54 (Chrome + Firefox, Password)

Composer spec. `template.json` is the machine-readable copy.

## Services

| Field | Selenium Hub | Chrome Node | Firefox Node |
|---|---|---|---|
| Source | repo `baranberkay96/selenium-grid-railway`, root `/services/hub` (FROM `selenium/hub:4.54.0-20261123@sha256:e95b7e26…`) | `selenium/node-chrome:4.54.0-20261123@sha256:31804136…` | `selenium/node-firefox:4.54.0-20261123@sha256:2c2dea3f…` |
| Public domain | yes, 4444 | none | none |
| Healthcheck | `/readyz` (unauthenticated by design in Selenium), 300 s | `/status` on 5555, 600 s | `/status` on 5555, 600 s |
| Restart | ALWAYS | ALWAYS | ALWAYS |
| Volume | none | none | none |

Hub variables: `SE_ROUTER_USERNAME` (selenium), `SE_ROUTER_PASSWORD` (secret 32), `SE_REGISTRATION_SECRET` (secret 32), `SE_EXTERNAL_URL`, `PORT` 4444, `SE_SESSION_REQUEST_TIMEOUT` 300, `SE_ENABLE_TRACING` false, `SE_JAVA_OPTS` -Xmx512m.
Node variables: event bus host/ports (hub reference), `SE_REGISTRATION_SECRET` (hub reference), `SE_NODE_HOST` (own private domain), `SE_NODE_PORT`/`PORT` 5555, `SE_NODE_MAX_SESSIONS` 1, `SE_NODE_OVERRIDE_MAX_SESSIONS` true, `SE_NODE_SESSION_TIMEOUT` 300, screen 1920×1080, VNC/noVNC off, tracing off, `SE_JAVA_OPTS` -Xmx256m. No required inputs.

## Design

- `railway-hub.sh` validates username (fallback `selenium`), password (12–128, no spaces; otherwise random = locked), registration secret (≥16; otherwise random, nodes cannot join, logged) and port, then `exec /opt/bin/entry_point.sh` (supervisord, as in the image). Selenium enables basic auth only when a password is set, so this closes the "empty password = open grid" hole (8.29 fail closed).
- Hub `/readyz` stays unauthenticated (Selenium's own exception for liveness probes); everything else requires the login.
- Nodes use the official images unchanged; they reach the hub's event bus (4442/4443) over the private network and advertise `$RAILWAY_PRIVATE_DOMAIN:5555`.

## Improvements over market templates

- Market templates run `selenium/hub:latest` / unpinned nodes with no authentication on a public domain (an open browser farm), no registration secret and no healthchecks on the nodes. This one pins 4.54.0 by digest, enforces basic auth, adds a registration secret, healthchecks, and turns off VNC/tracing to save RAM.

## Resources

| Service | Idle RAM | Typical RAM | CPU |
|---|---|---|---|
| Selenium Hub | ≈0.25 GB (measured) | 0.3–0.5 GB | low |
| Chrome Node | ≈0.15 GB (measured) | +0.3–0.6 GB per session | 0.5–1 vCPU per active session |
| Firefox Node | ≈0.15 GB (measured) | +0.3–0.6 GB per session | 0.5–1 vCPU per active session |

Estimated: $5–8/month idle, more with active sessions. Minimum plan: Trial (one session per node); Hobby for parallel sessions.

## Verification checklist

- `/readyz` 200; `/status` without login 401, with login 200 and both nodes listed.
- A remote Chrome session and a remote Firefox session (Python client with `ClientConfig` basic auth) open a page and read its title.
- `SE_ROUTER_PASSWORD=abc` → hub SUCCESS, the old password no longer works, warning in the log.

## Open questions

- Railway's `/dev/shm` size for Chrome; see the round-13 report for what was measured.
