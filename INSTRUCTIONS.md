# Check Point CoPilot — User Instructions

Welcome to the Check Point-focused OpenCode environment for Codespaces or local Linux. If you can see this file displayed in the Codespace, you're in the right place!

This repository is intended for learning, lab testing, research, proof-of-concept work, and internal experimentation. It is not presented as production-ready software and does not by itself ensure legal compliance. See [EU-AI-SOFTWARE-NOTICE.md](EU-AI-SOFTWARE-NOTICE.md) for practical guidance.

## What to do first

1. Complete the guided setup shown in the terminal if prompted. This will ask you for the required values to connect to the Check Point management server and to configure the OpenCode and reports servers. The first management prompt accepts either an on-premises DNS/IP value or a Smart-1 Cloud URL. It also offers optional API key prompts for the Reputation Service and Threat Emulation MCP servers. If you have already set these values as Codespaces secrets, they will already be available to the setup script, so you may be able to continue with little or no input.
   - Use demo, synthetic, anonymized, or carefully redacted inputs whenever possible. Do not treat this environment as a safe default for personal data, customer data, or production secrets.
   - If you skip either optional MCP API key, that MCP stays disabled in OpenCode until you add the key and rerun setup.
2. After setup finishes, OpenCode and the reports server start automatically for you in Codespaces.
3. *Open the Reports link shown in the terminal.*
   - It should be empty at first because you have not generated any reports yet.
4. *Open the OpenCode link shown in the terminal.*
   - By default, OpenCode starts without a login prompt. If you provided a non-empty OpenCode password during setup, log in with the credentials you configured (default username: `opencode`).
5. In the OpenCode browser tab, open a new session by clicking the recent project shown in the middle of the screen. It is usually named after the repository, such as `/workspaces/cpcopilot-basic-template`.
   - In the OpenCode Web UI, you can close the right-side pane to make more room for the conversation by clicking the second icon at the top of that pane.
   - In the OpenCode Web UI, you can also click the icon in the top-left corner to open the sessions list and switch between sessions later.
6. Ask the `CheckPoint-copilot` agent questions or request reports about your Check Point environment, policies, logs, threat prevention, HTTPS inspection, reputation checks, threat emulation, and documentation, or just start with a simple "hey" to confirm that it's working.
   - Treat generated answers and reports as analysis support. They require human validation before operational use. AI-generated content may be inaccurate, incomplete, or misleading, and it does not by itself ensure legal compliance or safe outcomes.

## What to do next

Here are some example prompts to try:

- "List access policy layers"
- "Why can't users in InternalZone access applications at www.block.com?"
- "Review the rules in the Datacenter layer and evaluate PCI 4.0 compliance. Create a detailed HTML report with findings and recommendations."
- "Inspect access policy for broad allow rules and summarize top risk findings."
- "Summarize threat-prevention profiles and exceptions, then identify coverage gaps by severity."
- "Generate an HTML report in reports/ with findings, sources used, and next steps."
- "List my Spark gateways and summarize any management or connectivity issues you find."
- "Connect to my Smart-1 Cloud management URL and list the available policy layers."
- "Check the reputation of gmil.com and explain what Check Point knows about it."
- "Check the reputation of IP 103.243.240.249 and summarize the risk."
- "Analyze this suspicious file with Threat Emulation and summarize the verdict."

## Tips

*Tip #1:* You can also ask the agent to create reports for you. For example, you can ask it to review a specific policy layer and generate an HTML report with findings and recommendations. Reports are saved in the `reports/` directory in your Codespace, and you can view them in the Reports browser tab. You might need to refresh the Reports tab after new reports are generated before they appear in the list.

*Tip #2:* If you want to start over with a new conversation, click the "New Conversation" button in the top-left corner of the OpenCode Web UI. This creates a new session and clears the conversation history in the current one. You can switch back to the previous session at any time to review it or continue where you left off.

*Tip #3:* If you are signed in to a GitHub account with a GitHub Copilot subscription, you can also choose one of the GitHub Copilot models from the lower-left panel in the OpenCode Web UI and have the agent use that model for responses. This can improve privacy because your data will not be sent to free providers, and it can also improve speed and response quality by using GitHub Copilot's commercial models.

*Tip #4:* You can also manually configure other providers or models from the settings cog icon in the lower-left corner of the OpenCode Web UI.
