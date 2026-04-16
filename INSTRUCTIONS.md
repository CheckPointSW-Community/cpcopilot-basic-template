# Check Point CoPilot — User Instructions

Welcome to the Check Point-focused OpenCode environment for Codespaces or local Linux. If you can see this file displayed in the Codespace, you're in the right place!

## What to do first

1. Complete the guided setup shown in the terminal if prompted. This will ask you for the required values to connect to the Check Point management server and to configure the OpenCode and reports servers. If you have already set these values as Codespaces secrets, they will already be available to the setup script, so you may be able to continue with little or no input.
2. After setup finishes, OpenCode and the reports server start automatically for you in Codespaces.
3. Open the Reports link shown in the terminal. It should be empty at first because you have not generated any reports yet.
4. Open the OpenCode link shown in the terminal and log in with the credentials you provided during setup (default: `admin` / `demo123`).
5. In the OpenCode browser tab, select the session for this repository to open the chat. It is usually named after the repository (for example, `cpcopilot-basic`).
   - In the OpenCode Web UI, you can close the right-side pane to make more room for the conversation by clicking the second icon at the top of that pane.
6. Ask the `CheckPoint-copilot` agent questions or request reports about your Check Point environment, policies, logs, threat prevention, HTTPS inspection, and documentation, or just start with a simple "hey" to confirm that it's working.

## What to do next

Here are some example prompts to try:

- "List access policy layers"
- "Why can't users in InternalZone access applications at www.block.com?"
- "Review the rules in the Datacenter layer and evaluate PCI 4.0 compliance. Create a detailed HTML report with findings and recommendations."
- "Inspect access policy for broad allow rules and summarize top risk findings."
- "Summarize threat-prevention profiles and exceptions, then identify coverage gaps by severity."
- "Generate an HTML report in reports/ with findings, sources used, and next steps."

## Tips

*Tip #1:* You can also ask the agent to create reports for you. For example, you can ask it to review a specific policy layer and generate an HTML report with findings and recommendations. Reports are saved in the `reports/` directory in your Codespace, and you can view them in the Reports browser tab. You might need to refresh the Reports tab after new reports are generated before they appear in the list.

*Tip #2:* If you want to start over with a new conversation, click the "New Conversation" button in the top-left corner of the OpenCode Web UI. This creates a new session and clears the conversation history in the current one. You can switch back to the previous session at any time to review it or continue where you left off.

*Tip #3:* If you are signed in to a GitHub account with a GitHub Copilot subscription, you can also choose one of the GitHub Copilot models from the lower-left panel in the OpenCode Web UI and have the agent use that model for responses. This can improve privacy because your data will not be sent to free providers, and it can also improve speed and response quality by using GitHub Copilot's commercial models.

*Tip #4:* You can also manually configure other providers or models from the settings cog icon in the lower-left corner of the OpenCode Web UI.
