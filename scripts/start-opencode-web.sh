#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=./lib/url_helpers.sh
source "${SCRIPT_DIR}/lib/url_helpers.sh"

USER_ENV_FILE="${HOME}/.config/opencode/checkpoint-secrets.env"
STATE_DIR="${HOME}/.local/state/checkpoint-copilot"
PID_FILE="${STATE_DIR}/opencode-web.pid"
LOG_FILE="${STATE_DIR}/opencode-web.log"

mkdir -p "${STATE_DIR}"

if [[ -f "${USER_ENV_FILE}" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "${USER_ENV_FILE}"
  set +a
fi

OPENCODE_PORT="${OPENCODE_PORT:-4096}"
OPENCODE_SERVER_USERNAME="${OPENCODE_SERVER_USERNAME:-}"
OPENCODE_SERVER_PASSWORD="${OPENCODE_SERVER_PASSWORD:-}"

export PATH="${HOME}/.local/npm-global/bin:${PATH}"
export BROWSER="/bin/true"

PREFERRED_URL="$(service_url_for_port "${OPENCODE_PORT}")"
LOCAL_URL="http://localhost:${OPENCODE_PORT}"

if ! command -v opencode >/dev/null 2>&1; then
  echo "[opencode] binary not found. Run scripts/setup-opencode.sh first."
  exit 1
fi

read_proc_env_value() {
  local pid="$1"
  local key="$2"

  if [[ ! -r "/proc/${pid}/environ" ]]; then
    return 1
  fi

  tr '\0' '\n' < "/proc/${pid}/environ" | sed -n "s/^${key}=//p" | head -n 1
}

if [[ -f "${PID_FILE}" ]] && kill -0 "$(cat "${PID_FILE}")" 2>/dev/null; then
  existing_pid="$(cat "${PID_FILE}")"
  running_username="$(read_proc_env_value "${existing_pid}" "OPENCODE_SERVER_USERNAME" || true)"
  running_password="$(read_proc_env_value "${existing_pid}" "OPENCODE_SERVER_PASSWORD" || true)"

  if [[ "${running_username}" == "${OPENCODE_SERVER_USERNAME}" && "${running_password}" == "${OPENCODE_SERVER_PASSWORD}" ]]; then
    echo "[opencode] already running on port ${OPENCODE_PORT}."
    exit 0
  fi

  echo "[opencode] existing process is running with different auth settings; restarting."
  kill "${existing_pid}" 2>/dev/null || true
  rm -f "${PID_FILE}"
fi

rm -f "${STATE_DIR}/opencode-intro-seeded" "${STATE_DIR}/opencode-intro-session.json"

cd "${REPO_ROOT}"
nohup env -C "${REPO_ROOT}" opencode web --hostname 0.0.0.0 --port "${OPENCODE_PORT}" </dev/null >"${LOG_FILE}" 2>&1 &
echo $! > "${PID_FILE}"

echo "[opencode] web mode started on 0.0.0.0:${OPENCODE_PORT}."
echo "[opencode] preferred URL: ${PREFERRED_URL}"
if [[ "${PREFERRED_URL}" != "${LOCAL_URL}" ]]; then
  echo "[opencode] local URL    : ${LOCAL_URL}"
fi
echo "[opencode] log file : ${LOG_FILE}"
