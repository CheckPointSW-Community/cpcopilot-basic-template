#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
STATUS_FILE="${HOME}/.config/opencode/checkpoint-setup-status.json"
USER_ENV_FILE="${HOME}/.config/opencode/checkpoint-secrets.env"

mkdir -p "${HOME}/.local/state/checkpoint-copilot" "${REPO_ROOT}/reports"

if [[ -f "${USER_ENV_FILE}" ]]; then
	set -a
	# shellcheck source=/dev/null
	source "${USER_ENV_FILE}"
	set +a
fi

SETUP_COMPLETE="false"
if [[ -f "${STATUS_FILE}" ]] && command -v jq >/dev/null 2>&1; then
	SETUP_COMPLETE="$(jq -r '.setupComplete // false' "${STATUS_FILE}")"
fi

if [[ "${SETUP_COMPLETE}" == "true" ]]; then
	bash "${REPO_ROOT}/scripts/start-report-server.sh" || true
	bash "${REPO_ROOT}/scripts/start-opencode-web.sh" || true
fi

exit 0
