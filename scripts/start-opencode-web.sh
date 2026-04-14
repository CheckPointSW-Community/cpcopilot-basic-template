#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

USER_ENV_FILE="${HOME}/.config/opencode/checkpoint-secrets.env"
STATE_DIR="${HOME}/.local/state/checkpoint-copilot"
PID_FILE="${STATE_DIR}/opencode-web.pid"
LOG_FILE="${STATE_DIR}/opencode-web.log"
SEED_INFO_FILE="${STATE_DIR}/opencode-intro-session.json"

mkdir -p "${STATE_DIR}"

if [[ -f "${USER_ENV_FILE}" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "${USER_ENV_FILE}"
  set +a
fi

OPENCODE_PORT="${OPENCODE_PORT:-4096}"

export PATH="${HOME}/.local/npm-global/bin:${PATH}"
export BROWSER="/bin/true"

if ! command -v opencode >/dev/null 2>&1; then
  echo "[opencode] binary not found. Run scripts/setup-opencode.sh first."
  exit 1
fi

if [[ -f "${PID_FILE}" ]] && kill -0 "$(cat "${PID_FILE}")" 2>/dev/null; then
  echo "[opencode] already running on port ${OPENCODE_PORT}."
  exit 0
fi

cd "${REPO_ROOT}"
nohup env -C "${REPO_ROOT}" opencode web --hostname 0.0.0.0 --port "${OPENCODE_PORT}" </dev/null >"${LOG_FILE}" 2>&1 &
echo $! > "${PID_FILE}"

bash "${REPO_ROOT}/scripts/seed-opencode-session.sh" || true

echo "[opencode] web mode started on 0.0.0.0:${OPENCODE_PORT}."
echo "[opencode] local URL: http://localhost:${OPENCODE_PORT}"
if [[ -f "${SEED_INFO_FILE}" ]] && command -v jq >/dev/null 2>&1; then
  intro_url="$(jq -r '.url // empty' "${SEED_INFO_FILE}")"
  intro_path="$(jq -r '.path // empty' "${SEED_INFO_FILE}")"
  if [[ -n "${intro_url}" ]]; then
    echo "[opencode] intro session URL: ${intro_url}"
  elif [[ -n "${intro_path}" ]]; then
    echo "[opencode] intro session path: ${intro_path}"
  fi
fi
echo "[opencode] log file : ${LOG_FILE}"
