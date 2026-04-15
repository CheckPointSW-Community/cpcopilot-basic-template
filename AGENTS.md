# AGENTS.md — Check Point OpenCode CoPilot Environment

## What this repository is for

This repository is a GitHub Codespaces template that bootstraps a **Check Point-focused OpenCode environment**.

It is designed for operational analysis and assistant workflows centered on:

- Check Point policy inspection
- object and rule review
- management logs investigation
- threat prevention analysis
- HTTPS inspection analysis
- documentation lookup and change planning

## What the `checkpoint-copilot` skill does

A global OpenCode skill named `checkpoint-copilot` is installed at Codespace startup and guides OpenCode to:

- prioritize Check Point MCP tools and documentation
- use MCP tools instead of direct raw management API calls whenever possible
- stay in Check Point operational context
- label facts vs recommendations/inference clearly
- request confirmation before production-impacting actions
- avoid exposing secrets
- generate professional HTML reports in `reports/` when useful

## How OpenCode is started

OpenCode is started automatically in web mode by:

- `scripts/start-opencode-web.sh`

Startup command pattern:

- `opencode web --hostname 0.0.0.0 --port ${OPENCODE_PORT}`

`OPENCODE_SERVER_USERNAME` and `OPENCODE_SERVER_PASSWORD` are honored if provided.

## How to open the OpenCode Web UI

- Open the forwarded port for `OPENCODE_PORT` (default `4096`) in Codespaces.
- In a real Codespace, the forwarded URL pattern is `https://$CODESPACE_NAME-$OPENCODE_PORT.$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN`.
- Outside Codespaces, use the local URL inside the container, such as `http://localhost:4096`.

## How to open generated HTML reports

- Reports are served by `scripts/start-report-server.sh`.
- Default port is `8081`.
- Open the forwarded `8081` port in Codespaces.
- In a real Codespace, the forwarded URL pattern is `https://$CODESPACE_NAME-8081.$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN`.
- Reports are written to `reports/`.

## Secrets and credential handling

Provide these via Codespaces secrets:

- `CHECKPOINT_MGMT_HOST`
- `CHECKPOINT_API_KEY` (optional; preferred when available)
- `CHECKPOINT_USERNAME` (used when `CHECKPOINT_API_KEY` is blank)
- `CHECKPOINT_PASSWORD` (used when `CHECKPOINT_API_KEY` is blank)
- `CHECKPOINT_DOC_CLIENT_ID`
- `CHECKPOINT_DOC_SECRET_KEY`
- `OPENCODE_SERVER_USERNAME` (defaults to `admin` during guided setup)
- `OPENCODE_SERVER_PASSWORD` (defaults to `demo123` during guided setup)

Never place real secrets in tracked files.

## First-run setup behavior

On start, `scripts/first-run-checkpoint-setup.sh`:

1. loads values from environment and prior user-scoped setup
2. detects missing mandatory values
3. prompts interactively when possible
4. asks for a Check Point API key first; when left blank it falls back to username/password
5. prompts for optional management/doc/port settings using the same env names as the template
6. defaults the Check Point username suggestion to `admin`
7. defaults the OpenCode username to `admin`
8. defaults both the Check Point password and OpenCode password to `demo123` when left blank
9. writes user-scoped runtime values under `~/.config/opencode/checkpoint-secrets.env`
10. updates global OpenCode config (`~/.config/opencode/opencode.json`) without duplicating MCP entries
11. prints a **redacted** setup summary

If startup is non-interactive and values are missing, run manually:

- `bash scripts/first-run-checkpoint-setup.sh`

When you open a terminal in Codespaces, the environment also prints a short welcome message and will guide you through pending setup interactively.

## Effective prompting tips

For best results, include:

- management domain/scope (policy package, gateway, object names)
- expected outcome (audit, comparison, root-cause, recommended actions)
- desired output format (summary table, prioritized findings, HTML report)

## Example prompts

### Policy inspection

- "Inspect access policy for broad allow rules and summarize top risk findings."

### Rule review

- "Review rulebase for shadowed, disabled, or over-permissive rules and suggest safe cleanup candidates."

### Object analysis

- "Analyze objects used in internet-facing rules and flag stale or overly broad network/service objects."

### Logs investigation

- "Investigate drops to 10.20.30.40 over the last 24h and identify likely root causes."

### Threat prevention review

- "Summarize threat-prevention profiles and exceptions, then identify coverage gaps by severity."

### HTTPS inspection troubleshooting

- "Find HTTPS inspection exclusions that may weaken certificate validation and explain operational impact."

### Documentation lookup

- "Use documentation-tool to find official guidance for tuning HTTPS inspection exceptions in R81.20+."

### Change planning

- "Propose a low-risk phased plan to tighten rulebase exposure for internet-facing services, with rollback points."

### Report generation

- "Generate an HTML incident-style report in reports/ for today’s threat-prevention review with findings and next steps."

## Report output location

- Repository path: `reports/`
- Served over port `8081` (forwarded URL in Codespaces, localhost elsewhere)

## Security guidance

- Never include raw credentials in prompts, responses, or reports.
- Prefer redacted values in summaries.
- Validate proposed production changes before implementation.

## Limitations and supported scope

Supported:

- Check Point MCP-backed analysis and recommendations
- Documentation-backed operational guidance

Not primary scope:

- non-Check-Point ecosystems or unrelated infrastructure domains (unless explicitly requested)
