# Check Point OpenCode Copilot

Check Point-focused OpenCode environment for:

- GitHub Codespaces
- native Debian/Ubuntu machines

It starts OpenCode web, installs the Check Point MCP tools, provides a Check Point-focused agent/skills set, and serves HTML reports from `reports/`.

## Quick start in GitHub Codespaces

### Before you create the Codespace

Collect the required values first.

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

1. Create a new Codespace from this repository.
2. If you use Codespaces secrets, add the required values before creating the Codespace. You can also enter them during guided setup.
3. Open the first visible bash terminal.
4. Complete the guided setup if prompted.
5. Open the forwarded OpenCode port (`4096`).
6. Open the forwarded Reports port (`8081`).

Expected result:

- OpenCode is reachable
- reports index is reachable
- setup status shows `complete`

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
