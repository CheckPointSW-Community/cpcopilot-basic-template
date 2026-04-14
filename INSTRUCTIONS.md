# Check Point CoPilot — User Instructions

Welcome to the Check Point-focused OpenCode Codespace.

## What to do first

1. Open the first visible bash terminal in the Codespace.
2. Complete the guided setup shown in that terminal if prompted.
3. After setup finishes, OpenCode and the reports server are started for you.
4. Open the forwarded **OpenCode Web UI** port: `4096`
5. Open the forwarded **HTML Reports** port: `8081`

## Required secrets

Set these as GitHub Codespaces secrets for the repository or your account:

- `CHECKPOINT_MGMT_HOST`
- `CHECKPOINT_USERNAME`
- `CHECKPOINT_PASSWORD`
- `CHECKPOINT_DOC_CLIENT_ID`
- `CHECKPOINT_DOC_SECRET_KEY`
- `OPENCODE_SERVER_PASSWORD` (optional but recommended)

## What this environment is optimized for

Use this Codespace primarily for:

- Check Point policy inspection
- object and rule review
- management log analysis
- threat prevention review
- HTTPS inspection analysis
- documentation-backed troubleshooting
- HTML report generation into `reports/`

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
