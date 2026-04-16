#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="${HOME}/.local/state/checkpoint-copilot"

stop_service() {
  local label="$1"
  local pid_file="$2"

  if [[ ! -f "${pid_file}" ]]; then
    echo "[services] ${label}: no PID file found, assuming not running."
    return 0
  fi

  local pid
  pid="$(cat "${pid_file}")"

  if kill -0 "${pid}" 2>/dev/null; then
    kill "${pid}"
    echo "[services] ${label}: stopped (pid ${pid})."
  else
    echo "[services] ${label}: not running (stale PID file removed)."
  fi

  rm -f "${pid_file}"
}

stop_service "OpenCode"      "${STATE_DIR}/opencode-web.pid"
stop_service "Report server" "${STATE_DIR}/report-server.pid"
