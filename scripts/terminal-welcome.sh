#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=./lib/url_helpers.sh
source "${SCRIPT_DIR}/lib/url_helpers.sh"

STATE_DIR="${HOME}/.local/state/checkpoint-copilot"
STATUS_FILE="${HOME}/.config/opencode/checkpoint-setup-status.json"
USER_ENV_FILE="${HOME}/.config/opencode/checkpoint-secrets.env"

mkdir -p "${STATE_DIR}"

if [[ -f "${USER_ENV_FILE}" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "${USER_ENV_FILE}"
  set +a
fi

OPENCODE_PORT="${OPENCODE_PORT:-4096}"
REPORTS_PORT="${REPORTS_PORT:-8081}"
OPENCODE_URL="$(service_url_for_port "${OPENCODE_PORT}")"
REPORTS_URL="$(service_url_for_port "${REPORTS_PORT}")"
SETUP_COMPLETE="false"

if [[ -f "${STATUS_FILE}" ]] && command -v jq >/dev/null 2>&1; then
  SETUP_COMPLETE="$(jq -r '.setupComplete // false' "${STATUS_FILE}")"
fi

echo ""
echo "🚀 Check Point CoPilot terminal ready"
echo "- Instructions   : ${REPO_ROOT}/INSTRUCTIONS.md"
echo "- Guided setup   : bash scripts/first-run-checkpoint-setup.sh"
echo "- OpenCode start : after visible setup completes in this terminal"

if [[ -t 0 && -t 1 && "${SETUP_COMPLETE}" != "true" ]]; then
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
  echo "[welcome] Required values are still missing, so OpenCode will not be started yet."
  echo "[welcome] Re-run: bash scripts/first-run-checkpoint-setup.sh"
  echo ""
  echo "- OpenCode UI    : not started yet"
  echo "- Reports        : not started yet"
  echo "- Ports tip      : finish setup first, then re-run this welcome flow to print the preferred service URLs"
  exit 0
fi

echo "[welcome] Starting local services..."
bash "${REPO_ROOT}/scripts/start-opencode-web.sh" || true
bash "${REPO_ROOT}/scripts/start-report-server.sh" || true
bash "${REPO_ROOT}/scripts/validate-environment.sh" --quick || true

echo ""
echo "- OpenCode UI    : ${OPENCODE_URL}"
echo "- Reports        : ${REPORTS_URL}"
echo "- Stop services  : bash scripts/stop-services.sh"
echo "- Restart        : bash scripts/restart-services.sh"
if [[ -n "${CODESPACE_NAME:-}" && -n "${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-}" ]]; then
  echo "- Ports tip      : these forwarded URLs were derived from CODESPACE_NAME and GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN"
else
  echo "- Ports tip      : Codespaces forwarding variables were not detected, so localhost URLs are shown"
fi
