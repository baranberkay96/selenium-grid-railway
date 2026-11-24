# NOTICE: Selenium Grid template

This is a community template. It is not made, endorsed or supported by the Selenium project, Software Freedom Conservancy or Railway. Selenium is a trademark of Software Freedom Conservancy. Google Chrome and Firefox are trademarks of Google LLC and the Mozilla Foundation.

## Components

| Component | Source | License | How it is used |
|---|---|---|---|
| docker-selenium 4.54.0-20261123: `selenium/hub`, `selenium/node-chrome`, `selenium/node-firefox` (pinned by digest) | https://github.com/SeleniumHQ/docker-selenium | Apache-2.0 | Official images, unmodified; the hub gets a start wrapper |
| Selenium Grid 4.54.0 | https://github.com/SeleniumHQ/selenium | Apache-2.0 | Inside the images |
| Google Chrome, Mozilla Firefox, chromedriver, geckodriver | Inside the node images | Google Chrome Terms of Service; MPL-2.0 (Firefox, geckodriver); BSD-3-Clause (chromedriver) | Shipped by the official images; this template does not redistribute them itself |

## Files written for this template

`services/hub/Dockerfile`, `services/hub/railway-hub.sh` and the documentation were written for this template and are offered under the MIT License.

## Upstream files checked

- docker-selenium 4.54.0-20261123: `Hub/start-selenium-grid-hub.sh` (`SE_ROUTER_USERNAME`/`SE_ROUTER_PASSWORD` → `--username/--password`, `SE_REGISTRATION_SECRET`), `NodeBase/generate_config`, `Base/entry_point.sh`, the hub image config (CMD `/opt/bin/entry_point.sh`, user 1200).
- selenium-4.54.0: `java/src/org/openqa/selenium/grid/commands/Hub.java` (basic auth filter, unauthenticated `/readyz`).

## Market templates

The Selenium templates on the Railway marketplace (`NG8OnB`, `XXPeWN`, `ycktxy`) were reviewed for features only. No files or text were copied.
