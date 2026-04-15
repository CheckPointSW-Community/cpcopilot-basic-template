# Check Point OpenCode Copilot Codespaces Template

Template repository for spinning up a Check Point-focused OpenCode environment in GitHub Codespaces.

It also supports running directly on a current Debian/Ubuntu machine outside Codespaces with a more manual startup flow.

> ✅ **First-run success target:** after Codespace startup, both OpenCode (`4096`) and reports (`8081`) are reachable and setup status prints `complete`.

When a Codespace starts from this template, it:

- installs OpenCode automatically
- configures Node.js/npm runtime support for Check Point MCP servers
- runs OpenCode in web mode
- forwards the OpenCode web port and report server port
- provisions a global `checkpoint-copilot` OpenCode skill
- provisions a global `checkpoint-brand-webui` OpenCode skill for branded reports and web UI
- sets a `CheckPoint-copilot` primary OpenCode agent as the default active agent
- sets the default model to the free OpenCode Zen model `opencode/big-pickle`
- runs first-run setup for required secrets (with interactive prompts when possible)
- shows a terminal welcome/instructions flow when you open the first visible bash terminal
- validates setup and prints a redacted summary

## Required Codespaces secrets

Set these in your repository/user Codespaces secrets before creating a Codespace:

- `CHECKPOINT_MGMT_HOST`
- `CHECKPOINT_API_KEY` (optional; preferred when available)
- `CHECKPOINT_USERNAME` (used when `CHECKPOINT_API_KEY` is blank)
- `CHECKPOINT_PASSWORD` (used when `CHECKPOINT_API_KEY` is blank)
- `CHECKPOINT_DOC_CLIENT_ID`
- `CHECKPOINT_DOC_SECRET_KEY`

Optional:

- `CHECKPOINT_MGMT_PORT` (default `443`)
- `CHECKPOINT_DOC_REGION` (default `EU`)
- `CHECKPOINT_DOC_AUTH_URL`
- `OPENCODE_SERVER_USERNAME` (default `admin`)
- `OPENCODE_SERVER_PASSWORD` (default `demo123`)
- `OPENCODE_PORT` (default `4096`)
- `REPORTS_PORT` (default `8081`)

A non-secret template is provided in `.env.example`.

Guided setup asks for a Check Point API key first. If you leave it blank, the setup falls back to username/password with defaults of `admin` / `demo123`. It also prompts for the OpenCode web username/password with defaults of `admin` / `demo123`, plus the optional management/doc/port values in the same env-var order used by the template.

## MCP servers preconfigured

Based on the official Check Point MCP packages:

- `management` → `@chkp/quantum-management-mcp`
- `management-logs` → `@chkp/management-logs-mcp`
- `threat-prevention` → `@chkp/threat-prevention-mcp`
- `https-inspection` → `@chkp/https-inspection-mcp`
- `documentation-tool` → `@chkp/documentation-mcp`

## Included OpenCode skills

- `checkpoint-copilot` for Check Point operational workflows
- `checkpoint-brand-webui` for HTML reports, dashboards, and web UI that should follow Check Point 2026 brand styling

These are stored in the project under `.opencode/skills/`, so OpenCode can discover them directly from the current repository folder.

## Runtime flow

- `postCreateCommand` runs `scripts/setup-opencode.sh` and quick validation.
- `postCreateCommand` runs `scripts/setup-opencode.sh`.
- `postStartCommand` runs `scripts/post-start.sh` for lightweight background preparation only.
- The first visible bash terminal runs `scripts/terminal-welcome.sh` through a shell hook, and that visible terminal flow:
  1. runs first-run setup (`scripts/first-run-checkpoint-setup.sh`)
  2. starts the reports server (`scripts/start-report-server.sh`)
  3. starts OpenCode web (`scripts/start-opencode-web.sh`)
  4. runs quick validation (`scripts/validate-environment.sh --quick`)
- On later Codespace restarts/resumes, `postStartCommand` automatically starts OpenCode and the reports server again if setup had already completed.

If secrets are missing and startup is non-interactive, setup remains pending and you can complete it manually:

- `bash scripts/first-run-checkpoint-setup.sh`

## Local Debian/Ubuntu usage

For a native Debian/Ubuntu machine outside Codespaces:

1. Clone the repository.
2. Run `bash scripts/bootstrap-local-debian.sh` to install prerequisites, prepare the OpenCode runtime, run the guided setup, and start the services.

Default local connection URLs are printed by the terminal startup scripts. Outside Codespaces they now prefer the machine's local network IP (for example `http://192.168.1.50:4096`) and still fall back to `localhost` when needed.

The shell hook and guided setup also work locally when you open a new interactive bash shell from the repository root.

## Access URLs in Codespaces

- OpenCode Web UI: forwarded `4096`
- HTML reports server: forwarded `8081`

In a real Codespace, the terminal can derive the forwarded hostname from the documented default variables `CODESPACE_NAME` and `GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN`, producing URLs like:

- `https://$CODESPACE_NAME-4096.$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN`
- `https://$CODESPACE_NAME-8081.$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN`

Outside Codespaces, the scripts fall back to `http://localhost:PORT`.

## Reports

Save generated HTML reports in `reports/`.

The local report server publishes this directory for easy sharing/review within the Codespace session.

## Security notes

- No real credentials are stored in this repository.
- Secrets can come from Codespaces secrets, normal environment variables, or the guided setup prompts, and are stored only in user-scoped runtime files under `~/.config/opencode`.
- Validation output is redacted and does not print secrets.

## Quick troubleshooting

### Setup shows `pending`

- Cause: one or more mandatory secrets are missing.
- Fix: add the missing environment values and run `bash scripts/first-run-checkpoint-setup.sh`.

### OpenCode UI is not reachable

- Cause: OpenCode process did not start or port forwarding was not opened yet.
- Fix: run `bash scripts/start-opencode-web.sh`, then open the preferred URL printed in the terminal (forwarded in Codespaces, localhost elsewhere).

### Reports URL is not reachable

- Cause: local HTML server is not running.
- Fix: run `bash scripts/start-report-server.sh`, then open the preferred URL printed in the terminal (forwarded in Codespaces, localhost elsewhere).

### MCP checks feel slow at OpenCode startup

- Cause: MCP packages may not be locally installed/cached yet.
- Fix: rerun `bash scripts/setup-opencode.sh` once, or `bash scripts/bootstrap-local-debian.sh` on Debian/Ubuntu. This template installs the Check Point MCP packages locally and launches them via local binaries instead of `npx -y`.

### Big Pickle is configured but OpenCode still asks for provider setup

- Cause: the default model is `opencode/big-pickle`, but OpenCode Zen authentication has not been completed yet.
- Fix: connect OpenCode to the `opencode` provider / OpenCode Zen, then restart OpenCode.

### Web UI panel layout is not exactly as desired

- Cause: OpenCode's official config/docs do not currently document a supported setting to force the right file panel closed on Web UI open.
- Fix: use the default agent/model setup; panel-layout forcing is intentionally not hacked into the template.
