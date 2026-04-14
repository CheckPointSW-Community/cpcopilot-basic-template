#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

NPM_GLOBAL_DIR="${HOME}/.local/npm-global"
OPENCODE_CONFIG_DIR="${HOME}/.config/opencode"
SKILL_SRC="${REPO_ROOT}/templates/skills/checkpoint-copilot/SKILL.md"
SKILL_DEST_DIR="${OPENCODE_CONFIG_DIR}/skills/checkpoint-copilot"
SKILL_DEST="${SKILL_DEST_DIR}/SKILL.md"
SHELL_HOOK_FILE="${OPENCODE_CONFIG_DIR}/checkpoint-shell-hook.sh"

mkdir -p "${NPM_GLOBAL_DIR}/bin" "${OPENCODE_CONFIG_DIR}" "${SKILL_DEST_DIR}" "${HOME}/.local/state/checkpoint-copilot"

if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
  echo "[setup] Node.js/npm are required but not found. Ensure devcontainer build installs Node 20+."
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "[setup] jq is required but not found. Ensure the devcontainer image installs jq."
  exit 1
fi

npm config set prefix "${NPM_GLOBAL_DIR}" >/dev/null 2>&1 || true

PATH_LINE='export PATH="$HOME/.local/npm-global/bin:$PATH"'
if ! grep -Fq "$PATH_LINE" "${HOME}/.bashrc" 2>/dev/null; then
  echo "$PATH_LINE" >> "${HOME}/.bashrc"
fi
if ! grep -Fq "$PATH_LINE" "${HOME}/.profile" 2>/dev/null; then
  echo "$PATH_LINE" >> "${HOME}/.profile"
fi

export PATH="${NPM_GLOBAL_DIR}/bin:${PATH}"

echo "[setup] Installing/updating OpenCode and Check Point MCP packages..."
npm install -g \
  opencode-ai@latest \
  @chkp/quantum-management-mcp \
  @chkp/management-logs-mcp \
  @chkp/threat-prevention-mcp \
  @chkp/https-inspection-mcp \
  @chkp/documentation-mcp >/dev/null

if [[ -f "${SKILL_SRC}" ]]; then
  cp "${SKILL_SRC}" "${SKILL_DEST}"
fi

cat > "${SHELL_HOOK_FILE}" <<EOF
#!/usr/bin/env bash
[[ \$- != *i* ]] && return 0

[[ -n "\${CHECKPOINT_COPILOT_SUPPRESS_WELCOME:-}" ]] && return 0

export CHECKPOINT_COPILOT_REPO_ROOT="${REPO_ROOT}"
if [[ -z "\${PWD:-}" || "\${PWD}" != "${REPO_ROOT}"* ]]; then
  return 0
fi

if [[ -n "\${CHECKPOINT_COPILOT_WELCOME_SHOWN:-}" ]]; then
  return 0
fi
export CHECKPOINT_COPILOT_WELCOME_SHOWN=1

bash "${REPO_ROOT}/scripts/terminal-welcome.sh"
EOF
chmod 755 "${SHELL_HOOK_FILE}"

SHELL_HOOK_LINE='[ -f "$HOME/.config/opencode/checkpoint-shell-hook.sh" ] && source "$HOME/.config/opencode/checkpoint-shell-hook.sh"'
if ! grep -Fq "$SHELL_HOOK_LINE" "${HOME}/.bashrc" 2>/dev/null; then
  echo "$SHELL_HOOK_LINE" >> "${HOME}/.bashrc"
fi

mkdir -p "${REPO_ROOT}/reports"

cat <<'MSG'
[setup] OpenCode runtime prepared.
[setup] Global skill installed: checkpoint-copilot
[setup] Interactive terminal welcome hook installed.
[setup] Run scripts/first-run-checkpoint-setup.sh to complete Check Point MCP setup if needed.
MSG
