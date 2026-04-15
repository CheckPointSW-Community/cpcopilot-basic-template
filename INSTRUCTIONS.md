# Check Point CoPilot — User Instructions

Welcome to the Check Point-focused OpenCode environment for Codespaces or local Linux. If you can see this file displayed in the Codespace, you're in the right place!

## What to do first

1. Complete the guided setup shown in the terminal if prompted.
    - When you enter or paste secrets, they will not be shown for security reasons, but they are still being recorded. Press Enter after each one to continue. Default values are shown in parentheses when applicable and can be accepted by pressing Enter without typing anything.
2. After setup finishes, OpenCode and the reports server start automatically for you in Codespaces.
3. Open the Reports link shown in the terminal. It should be empty at first because you have not generated any reports yet.
4. Open the OpenCode link shown in the terminal and log in with the credentials you provided during setup (default: `admin` / `demo123`).
5. In the OpenCode browser tab, select the session for this repository to open the chat.
   - In the OpenCode Web UI, you can close the right-side pane to make more room for the conversation by clicking the second icon at the top of that pane.
6. Ask the `CheckPoint-copilot` agent questions or request reports about your Check Point environment, policies, logs, threat prevention, HTTPS inspection, and documentation, or just start with a simple "hey" to confirm that it's working.

## What to do next

Tip #1: You can also ask the agent to create reports for you. For example, you can ask it to review a specific policy layer and generate an HTML report with findings and recommendations. Reports are saved in the `reports/` directory in your Codespace, and you can view them by opening the Reports tab. You might need to refresh the Reports tab after new reports are generated before they appear in the list.

Tip #2: If you want to start over with a new conversation, click the "New Conversation" button in the top-left corner of the OpenCode Web UI. This creates a new session and clears the conversation history in the current one. You can switch back to the previous session at any time to review it or continue where you left off.

Tip #3: You can manually configure other providers or models from the settings cog icon in the lower-left corner.

Tip #4: If you are signed in to a GitHub account with a GitHub Copilot subscription, you can also choose one of the GitHub Copilot models from the lower-left panel and have the agent use that model for responses. This can improve privacy because your data will not be sent to external providers, and it can also improve relevance because GitHub Copilot models are trained on code and technical content.

Here are some example prompts to try:

- "List access policy layers"
- "Review the rules in the Datacenter layer and evaluate PCI 4.0 compliance. Create a detailed HTML report with findings and recommendations."
- "Inspect access policy for broad allow rules and summarize top risk findings."
- "Investigate drops to 192.168.0.0/16 over the last 24h and identify likely root causes."
- "Summarize threat-prevention profiles and exceptions, then identify coverage gaps by severity."
- "Generate an HTML report in reports/ with findings, sources used, and next steps."
