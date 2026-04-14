#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
STATE_DIR="${HOME}/.local/state/checkpoint-copilot"
STATUS_FILE="${HOME}/.config/opencode/checkpoint-setup-status.json"
USER_ENV_FILE="${HOME}/.config/opencode/checkpoint-secrets.env"
PROMPT_SENTINEL="/tmp/checkpoint-copilot-setup-prompted-${USER}"

mkdir -p "${STATE_DIR}"

if [[ -f "${USER_ENV_FILE}" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "${USER_ENV_FILE}"
  set +a
fi

OPENCODE_PORT="${OPENCODE_PORT:-4096}"
REPORTS_PORT="${REPORTS_PORT:-8081}"
SETUP_COMPLETE="false"

if [[ -f "${STATUS_FILE}" ]] && command -v jq >/dev/null 2>&1; then
  SETUP_COMPLETE="$(jq -r '.setupComplete // false' "${STATUS_FILE}")"
fi

echo ""
echo "🚀 Check Point CoPilot terminal ready"
echo "- Instructions   : ${REPO_ROOT}/INSTRUCTIONS.md"
echo "- Guided setup   : bash scripts/first-run-checkpoint-setup.sh"
echo "- OpenCode start : after visible setup completes in this terminal"

if [[ -t 0 && -t 1 && ! -f "${PROMPT_SENTINEL}" ]]; then
  touch "${PROMPT_SENTINEL}"
  echo ""
  echo "[welcome] Running visible first-run setup now..."
  bash "${REPO_ROOT}/scripts/first-run-checkpoint-setup.sh" || true
fi

if [[ -f "${USER_ENV_FILE}" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "${USER_ENV_FILE}"
  set +a
fi

if [[ -f "${STATUS_FILE}" ]] && command -v jq >/dev/null 2>&1; then
  SETUP_COMPLETE="$(jq -r '.setupComplete // false' "${STATUS_FILE}")"
fi

echo ""
if [[ "${SETUP_COMPLETE}" == "true" ]]; then
  echo "[welcome] Setup status: complete"
else
  echo "[welcome] Setup status: pending"
  echo "[welcome] You can continue using the guided setup command above or add Codespaces secrets and open a new terminal."
fi

echo "[welcome] Starting local services..."
bash "${REPO_ROOT}/scripts/start-report-server.sh" || true
bash "${REPO_ROOT}/scripts/start-opencode-web.sh" || true
bash "${REPO_ROOT}/scripts/validate-environment.sh" --quick || true

echo ""
echo "- OpenCode UI    : http://localhost:${OPENCODE_PORT}"
echo "- Reports        : http://localhost:${REPORTS_PORT}"
echo "- Ports tip      : use the Codespaces Ports panel to open the forwarded private URLs"
