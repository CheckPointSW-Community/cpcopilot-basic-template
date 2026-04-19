# Check Point OpenCode Copilot

The main purpose of this repository is to provide a ready-to-use environment for demonstrating the value of the Check Point MCP servers, while also providing a small framework for building a basic AI copilot for any Check Point environment.

It uses the OpenCode tool as the foundation for the chat interface and agent management, and it includes a Check Point-focused agent with a set of skills for interacting with the Check Point MCP servers and documentation.

It supports both traditional on-premises Check Point management servers and Smart-1 Cloud management.

Learning and lab use only. This repository is designed to support research, proof-of-concept work, and internal experimentation. It is not presented as production-ready software and does not by itself ensure legal compliance.

This environment works with:

- GitHub Codespaces
- native Debian/Ubuntu machines or VMs

It starts the OpenCode Web UI, installs the Check Point MCP tools, provides a Check Point-focused agent and skill set, and runs a web server for HTML reports created by OpenCode agents.

See [EU-AI-SOFTWARE-NOTICE.md](EU-AI-SOFTWARE-NOTICE.md) for practical EU-facing guidance on responsible use, software/AI liability expectations, data handling, and escalation triggers.


## Before you start

The easiest way to use this repository for a demo is to use Check Point SmartConsole in "Demo Mode" with the public demo server.

1. Open the latest version of Check Point SmartConsole and select "Demo Mode".
2. Click "Next" to start a new demo session or use an existing one.
3. Click "Login" to enter the demo environment.
4. Once logged in, you can access the Check Point management server details from the middle of the dark bar at the bottom of SmartConsole by clicking "Cloud Demo Server". Then select "Demo Server Information" to copy the server IP address or DNS name.
  - Note: We have seen issues using the DNS name in some environments, so the IP address is currently recommended.
5. For simplicity, we will use the default demo credentials below, but you can also create a new user with an API key and publish the changes.
   - Username: `admin`
   - Password: `demo123`

**WARNING!** You can also use your own Check Point lab environment if you have one available, but the default setup in this environment will use free tools and models and may expose your data to the model provider. Please be careful before connecting any production environment or using personal data, customer data, incident data, or other sensitive material.

You will also need to create a free service account for the Check Point documentation tool to get the required client ID and secret key for documentation lookups.

Those same documentation portal credentials are also used by the Spark Management MCP server, so Spark support does not require any additional setup.

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

1. If you want to use Codespaces secrets, add the required values before creating the Codespace, as explained below.
   - If you do not know what Codespaces secrets are, read below, or enter the values during guided setup instead and skip this step.
2. Create a new Codespace from this repository using the green "Use this template" button in the top-right corner, then click "Open in Codespaces".
3. Wait 2–3 minutes for the Codespace to initialize.
4. When the Codespace is ready, follow the instructions in [INSTRUCTIONS.md](INSTRUCTIONS.md), which are shown in the main Codespace view, for the next steps.

Expected result:

- OpenCode is reachable
- reports index is reachable
- setup status shows `complete`

### If you want to create variables within Codespaces

GitHub Codespaces supports encrypted secrets that can be used as environment variables in your Codespace. This is a good option if you want to avoid entering credentials during guided setup or if you want to keep them stored securely in GitHub.

See the GitHub documentation for details:
https://docs.github.com/en/codespaces/managing-your-codespaces/managing-your-account-specific-secrets-for-github-codespaces

Collect the required values first.

- Either:
  - `CHECKPOINT_MGMT_HOST` for on-premises management
  - or `CHECKPOINT_MGMT_URL` for Smart-1 Cloud
- Authentication:
  - Smart-1 Cloud requires `CHECKPOINT_API_KEY`
  - on-premises can use `CHECKPOINT_API_KEY`
  - or `CHECKPOINT_USERNAME` + `CHECKPOINT_PASSWORD`
- `CHECKPOINT_DOC_CLIENT_ID`
- `CHECKPOINT_DOC_SECRET_KEY`

Optional values if you need to override defaults:

- `CHECKPOINT_MGMT_PORT` (default `443`, on-premises only)
- `CHECKPOINT_DOC_REGION` (default `EU`)
- `CHECKPOINT_DOC_AUTH_URL`
- `OPENCODE_SERVER_USERNAME` (default `opencode`)
- `OPENCODE_SERVER_PASSWORD` (default blank, which disables OpenCode Web UI auth)
- `OPENCODE_PORT` (default `4096`)
- `REPORTS_PORT` (default `8081`)

## Quick start on Debian/Ubuntu

Log into a Debian/Ubuntu machine with Internet access and follow the instructions below.

If Git is not already installed, see https://github.com/git-guides/install-git or https://git-scm.com/install/linux.

### Start it

1. Clone this repository onto a current Debian/Ubuntu machine.
  - `git clone https://github.com/CheckPointSW-Community/cpcopilot-basic-template.git && cd cpcopilot-basic-template`  
2. Run:
   - `bash scripts/bootstrap-local-debian.sh`
3. Complete the guided setup if prompted.
4. Open the OpenCode URL printed by the script.
5. Open the Reports URL printed by the script.
6. In OpenCode, select the session for this repository if prompted.
7. Ask the `CheckPoint-copilot` agent questions or request reports about your Check Point environment, policies, logs, threat prevention, HTTPS inspection, and documentation, or just start with a simple "hey" to confirm that it's working.
8. See [INSTRUCTIONS.md](INSTRUCTIONS.md) for more detailed instructions and troubleshooting.

Outside Codespaces, the startup scripts prefer the machine's local network IP and fall back to `localhost` when needed.

## Smart-1 Cloud notes

- In guided setup, the first management prompt accepts either an on-premises DNS/IP value or a Smart-1 Cloud URL.
- If a Smart-1 Cloud URL is detected, setup requires `CHECKPOINT_API_KEY` and skips the on-premises username/password and port prompts.
- Example Smart-1 Cloud URL: `https://cloudinfra-gw-us.portal.checkpoint.com/your-tenant-id/web_api`

## What this repository includes

- OpenCode Web UI on port `4096`
- reports server on port `8081`
- Check Point MCP packages:
  - `@chkp/quantum-management-mcp`
  - `@chkp/spark-management-mcp`
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

## Disclaimer and trademarks

This repository is provided as a public template and helper environment for working with Check Point-related workflows.

- Check Point names, product names, and marks are trademarks or registered trademarks of their respective owner.
- Use any official logos, screenshots, or brand assets only with appropriate permission and in line with applicable brand guidelines.
- Before connecting any non-demo environment, review the privacy, security, data-handling, and liability implications for your organization.
- The MIT license for this repository does not by itself remove statutory liability or regulatory obligations that may apply under EU or Member State law.
- Nothing in this repository should be read as a claim of EU legal compliance, certification, CE marking, or legal guarantee.
- Review [EU-AI-SOFTWARE-NOTICE.md](EU-AI-SOFTWARE-NOTICE.md) and [LAB-GOVERNANCE.md](LAB-GOVERNANCE.md) before production, customer-facing, or commercial use.

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
