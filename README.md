# Deploy and Host Selenium Grid with Railway

Selenium Grid 4 on Railway: a hub with a public HTTPS endpoint that requires a login, and a Chrome node and a Firefox node on the private network. Point your WebDriver tests or scrapers-for-your-own-sites at one URL and the hub routes each session to a matching browser.

## About Hosting Selenium Grid

Selenium Grid lets WebDriver clients run browsers on remote machines: a hub (router, distributor, session map and queue) accepts new-session requests and hands them to nodes, each running real browsers. Hosting it means keeping the hub reachable, the nodes registered over the event bus, enough RAM per browser, and, above all, not leaving it open: an unauthenticated grid is a free browser for anyone. This community template runs the official docker-selenium 4.54 images, turns on the hub's basic authentication with a generated password (a wrapper never lets the hub start without one), requires a registration secret for nodes, keeps nodes private, and disables VNC and tracing to save RAM.

## Common Use Cases

- Run Selenium end-to-end tests from CI (GitHub Actions, GitLab) against real Chrome and Firefox
- Cross-browser checks of your own web apps without maintaining browser machines
- Scheduled browser automation of your own systems (reports, smoke tests, monitoring)
- A shared grid for a QA team, scaled by adding node services

## Dependencies for Selenium Grid Hosting

- Selenium Hub (docker-selenium `selenium/hub` 4.54.0 with a start wrapper), public domain
- Chrome Node (`selenium/node-chrome` 4.54.0) and Firefox Node (`selenium/node-firefox` 4.54.0), private
- A Selenium client 4.x in your tests (Java, Python, JavaScript, C#, Ruby)

### Deployment Dependencies

- [Selenium Grid documentation](https://www.selenium.dev/documentation/grid/)
- [docker-selenium](https://github.com/SeleniumHQ/docker-selenium)
- [Grid basic authentication](https://www.selenium.dev/documentation/grid/configuration/cli_options/#router)
- [Railway Fair Use Policy](https://railway.com/legal/fair-use)

### Implementation Details

| Service | What runs inside | Volume | Port |
|---|---|---|---|
| Selenium Hub | Hub (router, distributor, queue, event bus), Grid UI | none | 4444 public; 4442/4443 event bus private |
| Chrome Node | Google Chrome + chromedriver, 1 session | none | 5555 private |
| Firefox Node | Firefox + geckodriver, 1 session | none | 5555 private |

**Connecting**

The login is `SE_ROUTER_USERNAME` (`selenium`) and `SE_ROUTER_PASSWORD` (generated) on the Selenium Hub service. The Grid UI is at `https://{your-domain}/ui` (the browser asks for the login). In Python:

```python
from selenium import webdriver
from selenium.webdriver.remote.client_config import ClientConfig

config = ClientConfig(remote_server_addr="https://{your-domain}", username="selenium", password="{your-password}")
driver = webdriver.Remote(command_executor="https://{your-domain}", options=webdriver.ChromeOptions(), client_config=config)
driver.get("https://example.com"); print(driver.title); driver.quit()
```

In Java use `ClientConfig.defaultConfig().baseUri(...).authenticateAs(new UsernameAndPassword(...))`; most other clients accept `https://selenium:{your-password}@{your-domain}` as the remote URL. Use `webdriver.FirefoxOptions()` for Firefox. Always call `quit()`: abandoned sessions hold a browser until `SE_NODE_SESSION_TIMEOUT` (300 s) closes them.

**Security**

Every WebDriver and UI request needs the login; only `/readyz` (Railway's healthcheck) is open. If `SE_ROUTER_PASSWORD` is empty or shorter than 12 characters, the hub starts locked with a random password and the log says how to fix it. Nodes have no public domain and need `SE_REGISTRATION_SECRET` (generated, shared by reference) to join.

**Scaling**

More parallel sessions: raise `SE_NODE_MAX_SESSIONS` on a node (each Chrome or Firefox session needs roughly 0.3–0.6 GB more RAM and some CPU), or duplicate a node service in the Railway canvas (keep the variables; each copy registers by itself). Remove the Firefox node if you only need Chrome. An Edge node works the same way with `selenium/node-edge` and the same variables. Versions are pinned (hub tag in `services/hub/Dockerfile`, node tags and digests on the node services); upgrade hub and nodes together.

**Resources**

Measured on Railway: hub about 0.25 GB, each idle node about 0.15 GB; a running Chrome or Firefox session adds roughly 0.3–0.6 GB to its node. Trial's 1 GB per service fits one session per node; use Hobby for more. Cost is roughly $5–8/month idle plus the RAM and CPU your sessions use.

**Fair use**

Use the grid for testing and automating sites you own or may automate. Railway's Fair Use Policy does not allow scraping that bypasses protections, account farming or other abusive automation.

### Why Deploy Selenium Grid on Railway?

Railway runs the hub and the browser nodes as separate services on one private network, gives the hub HTTPS, and lets you add browsers by duplicating a service. You get a password-protected Selenium Grid in one deploy and pay for the RAM your browsers use. This is a community template, not affiliated with the Selenium project.
