# Check Point OpenCode Copilot

Check Point-focused OpenCode environment for:

- GitHub Codespaces
- native Debian/Ubuntu machines

It starts OpenCode web, installs the Check Point MCP tools, provides a Check Point-focused agent/skills set, and serves HTML reports from `reports/`.


## Before you start

The easiest way to use this repository for a demo is to use Check Point SmartConsole in "Demo Mode" with the public demo server.

1. Open the latest version of SmartConsole and select "Demo Mode".
2. Click "Next" to start a new demo session or use an existing one.
3. Click "Login" to enter the demo environment.
4. Once logged in, you can access the Check Point management server details by going to the middle of the button bar and clicking on "Cloud Demo Server". Select "Demo Server Information" to copy the server DNS name or IP address.
5. For simplicity, we will use the default demo credentials below, but you can also create a new user with an API key and publish the changes.
   - Username: `admin`
   - Password: `demo123`

**WARNING!** You can also use your own Check Point lab environment if you have one available, but the default setup in this environment will use free tools and models and may expose your data to the model provider, so please be careful and consider the implications before connecting a production environment or sensitive data.

You will also need to create a free Check Point documentation tool service account to get the required client ID and secret key for documentation lookups.

1. Navigate to https://portal.checkpoint.com/ and log in with your account.
2. Select an account/tenant where you are an administrator.
3. Click the cog-wheel settings icon in the middle of the top bar.
4. Select the "API Keys" menu.
5. Click "New" → "New User API Key".
6. Select your user, set an expiration time, add a description, and click "Create".
7. Save the credentials: copy the generated `CLIENT_ID` and `SECRET_KEY`.

More details can be found here: https://github.com/CheckPointSW/mcp-servers/tree/main/packages/documentation-tool

## Quick start in GitHub Codespaces

### Start it

1. If you use Codespaces secrets, add the required values before creating the Codespace, as explained below. You can also enter them during guided setup (easier).
2. Create a new Codespace from this repository.
3. Wait for 2-3 minutes for the Codespace to initialize.
4. Complete the guided setup in the terminal if prompted.
5. Open the forwarded OpenCode port (`4096`).
6. Open the forwarded Reports port (`8081`).

Expected result:

- OpenCode is reachable
- reports index is reachable
- setup status shows `complete`

### If you want to create variables within Codespaces

Collect the required values first.

- `CHECKPOINT_MGMT_HOST`
- Either:
  - `CHECKPOINT_API_KEY`
  - or `CHECKPOINT_USERNAME` + `CHECKPOINT_PASSWORD`
- `CHECKPOINT_DOC_CLIENT_ID`
- `CHECKPOINT_DOC_SECRET_KEY`

Optional values if you need to override defaults:

- `CHECKPOINT_MGMT_PORT` (default `443`)
- `CHECKPOINT_DOC_REGION` (default `EU`)
- `CHECKPOINT_DOC_AUTH_URL`
- `OPENCODE_SERVER_USERNAME` (default `admin`)
- `OPENCODE_SERVER_PASSWORD` (default `demo123`)
- `OPENCODE_PORT` (default `4096`)
- `REPORTS_PORT` (default `8081`)

## Quick start on Debian/Ubuntu

### Before you start

Collect the same required values:

- `CHECKPOINT_MGMT_HOST`
  - Placeholder: **[Add your internal instructions here for how to find the Check Point management DNS name or IP]**
- Either:
  - `CHECKPOINT_API_KEY`
  - or `CHECKPOINT_USERNAME` + `CHECKPOINT_PASSWORD`
  - Placeholder: **[Add your internal instructions here for how to obtain the API key or management credentials]**
- `CHECKPOINT_DOC_CLIENT_ID`
- `CHECKPOINT_DOC_SECRET_KEY`
  - Placeholder: **[Add your internal instructions here for how to obtain the documentation tool client ID and secret key]**

Optional values if you need to override defaults:

- `CHECKPOINT_MGMT_PORT` (default `443`)
- `CHECKPOINT_DOC_REGION` (default `EU`)
- `CHECKPOINT_DOC_AUTH_URL`
- `OPENCODE_SERVER_USERNAME` (default `admin`)
- `OPENCODE_SERVER_PASSWORD` (default `demo123`)
- `OPENCODE_PORT` (default `4096`)
- `REPORTS_PORT` (default `8081`)

### Start it

1. Clone this repository onto a current Debian/Ubuntu machine.
2. Run:
   - `bash scripts/bootstrap-local-debian.sh`
3. Complete the guided setup if prompted.
4. Open the OpenCode URL printed by the script.
5. Open the Reports URL printed by the script.

Outside Codespaces, the startup scripts prefer the machine's local network IP and fall back to `localhost` when needed.

## What this repository includes

- OpenCode web on port `4096`
- reports server on port `8081`
- Check Point MCP packages:
  - `@chkp/quantum-management-mcp`
  - `@chkp/management-logs-mcp`
  - `@chkp/threat-prevention-mcp`
  - `@chkp/https-inspection-mcp`
  - `@chkp/documentation-mcp`
- default primary agent: `CheckPoint-copilot`
- default model: `opencode/big-pickle`
- project-local skills under `.opencode/skills/`:
  - `checkpoint-copilot`
  - `checkpoint-brand-webui`

## Where settings are stored

- runtime environment values: `~/.config/opencode/checkpoint-secrets.env`
- runtime status: `~/.config/opencode/checkpoint-setup-status.json`
- global OpenCode config: `~/.config/opencode/opencode.json`
- project config: `opencode.json`

No real credentials are stored in tracked files.

## Useful commands

- Debian/Ubuntu bootstrap: `bash scripts/bootstrap-local-debian.sh`
- guided setup: `bash scripts/first-run-checkpoint-setup.sh`
- start OpenCode: `bash scripts/start-opencode-web.sh`
- start reports server: `bash scripts/start-report-server.sh`
- rerun welcome flow: `bash scripts/terminal-welcome.sh`
- validate environment: `bash scripts/validate-environment.sh`

## Troubleshooting

### Setup stays pending

One or more required values are still missing.

Run:

- `bash scripts/first-run-checkpoint-setup.sh`

### OpenCode is not reachable

Run:

- `bash scripts/start-opencode-web.sh`

Then open the preferred URL printed in the terminal.

### Reports are not reachable

Run:

- `bash scripts/start-report-server.sh`

Then open the preferred URL printed in the terminal.

### OpenCode asks for provider setup

The default model is `opencode/big-pickle`, but OpenCode Zen still needs to be connected.

### MCP startup is slow

Rerun:

- `bash scripts/setup-opencode.sh`

or on Debian/Ubuntu:

- `bash scripts/bootstrap-local-debian.sh`
