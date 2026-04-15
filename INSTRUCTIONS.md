# Check Point CoPilot — User Instructions

Welcome to the Check Point-focused OpenCode Codespace.

## What to do first

1. Open the first visible bash terminal in the Codespace.
2. Complete the guided setup shown in that terminal if prompted.
3. After setup finishes, OpenCode and the reports server are started for you.
4. Open the forwarded **OpenCode Web UI** port: `4096`
5. Open the forwarded **HTML Reports** port: `8081`

When running inside GitHub Codespaces, the terminal welcome flow prints the forwarded URLs directly using the documented `CODESPACE_NAME` and `GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN` environment variables. Outside Codespaces, it prints `localhost` URLs instead.

## Required secrets

Set these as GitHub Codespaces secrets for the repository or your account:

- `CHECKPOINT_MGMT_HOST`
- `CHECKPOINT_API_KEY` (optional; preferred when available)
- `CHECKPOINT_USERNAME` (used if `CHECKPOINT_API_KEY` is blank)
- `CHECKPOINT_PASSWORD` (used if `CHECKPOINT_API_KEY` is blank; defaults to `demo123` during guided setup)
- `CHECKPOINT_DOC_CLIENT_ID`
- `CHECKPOINT_DOC_SECRET_KEY`

Optional values that guided setup will also ask for if missing:

- `CHECKPOINT_MGMT_PORT` (default `443`)
- `CHECKPOINT_DOC_REGION` (default `EU`)
- `CHECKPOINT_DOC_AUTH_URL`
- `OPENCODE_SERVER_USERNAME` (default `admin`)
- `OPENCODE_SERVER_PASSWORD` (default `demo123`)
- `OPENCODE_PORT` (default `4096`)
- `REPORTS_PORT` (default `8081`)

## What this environment is optimized for

Use this Codespace primarily for:

- Check Point policy inspection
- object and rule review
- management log analysis
- threat prevention review
- HTTPS inspection analysis
- documentation-backed troubleshooting
- HTML report generation into `reports/`

## Default OpenCode agent

This repository configures a primary OpenCode agent named `CheckPoint-copilot` and sets it as the default active agent.

That agent is tuned to:

- operate in Check Point scope by default
- use the configured Check Point MCP servers first
- avoid direct raw API calls unless explicitly requested or required for troubleshooting
- generate structured internal HTML reports when useful

## Default model

This repository preconfigures OpenCode with the free OpenCode Zen model:

- `opencode/big-pickle`

Important:

- this only works after the user has authenticated OpenCode to the `opencode` provider / OpenCode Zen
- if no OpenCode Zen credentials are connected yet, OpenCode may fall back to connection/setup steps before the model can be used

## Web UI notes

- There is currently no officially documented OpenCode setting for forcing the Web UI right file panel closed by default, so this template does **not** apply a brittle UI-state hack for that.
- Guided setup asks for a Check Point API key first. If you leave it blank, the flow falls back to username/password with defaults of `admin` / `demo123`.
- Guided setup then keeps the documentation fields together, asks for the OpenCode username before the OpenCode password, and prompts for the optional port-related env vars with their defaults.

## Important behavior expectations

- Prefer the configured Check Point MCP tools over raw API calls.
- Do **not** use direct `curl`, ad-hoc Python requests, or custom raw API calls to the Check Point management server unless you are explicitly troubleshooting MCP or the user explicitly requests raw API behavior.
- Clearly separate facts, inferences, and recommendations.
- Do not print or store secrets in outputs or reports.

## Useful local commands

- Guided setup: `bash scripts/first-run-checkpoint-setup.sh`
- Start OpenCode: `bash scripts/start-opencode-web.sh`
- Start reports server: `bash scripts/start-report-server.sh`
- Re-run welcome flow: `bash scripts/terminal-welcome.sh`
- Validate environment: `bash scripts/validate-environment.sh`

## Success checklist

You are in a good state when:

- OpenCode is reachable on port `4096`
- the reports server is reachable on port `8081`
- setup status is `complete`
- OpenCode can see the configured MCP servers without slow package-install retries

## Suggested first prompts

- "Inspect access policy for broad allow rules and summarize top risk findings."
- "Investigate drops to 10.20.30.40 over the last 24h and identify likely root causes."
- "Summarize threat-prevention profiles and exceptions, then identify coverage gaps by severity."
- "Generate an HTML report in reports/ with findings, sources used, and next steps."
