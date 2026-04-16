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

# Kill any orphaned MCP processes that OpenCode may have left behind.
# These accumulate across restarts when nohup prevents clean child reaping.
MCP_PATTERNS=(
  "quantum-management-mcp"
  "spark-management-mcp"
  "management-logs-mcp"
  "threat-prevention-mcp"
  "https-inspection-mcp"
  "documentation-mcp"
)

orphans_found=false
for pattern in "${MCP_PATTERNS[@]}"; do
  if pgrep -f "${pattern}" >/dev/null 2>&1; then
    pkill -f "${pattern}" 2>/dev/null || true
    echo "[services] MCP orphans killed: ${pattern}"
    orphans_found=true
  fi
done

if [[ "${orphans_found}" == "false" ]]; then
  echo "[services] No orphaned MCP processes found."
fi
