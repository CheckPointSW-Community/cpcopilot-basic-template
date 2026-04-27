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
    # Kill the whole process group to catch child processes that detach
    # from the wrapper (e.g. the actual opencode binary spawned by nohup)
    local pgid
    pgid="$(ps -o pgid= -p "${pid}" 2>/dev/null | tr -d ' ')" || true
    if [[ -n "${pgid}" && "${pgid}" != "0" && "${pgid}" != "1" ]]; then
      kill -- "-${pgid}" 2>/dev/null || true
    fi
    kill "${pid}" 2>/dev/null || true
    echo "[services] ${label}: stopped (pid ${pid})."
  else
    echo "[services] ${label}: not running (stale PID file removed)."
  fi

  rm -f "${pid_file}"
}

stop_service "OpenCode"      "${STATE_DIR}/opencode-web.pid"
stop_service "Report server" "${STATE_DIR}/report-server.pid"

# Also explicitly kill the opencode binary by name, since it may have
# detached from the wrapper process and survived the PGID kill above.
pkill -f "\.opencode web" 2>/dev/null || true

# Kill any orphaned MCP processes that OpenCode may have left behind.
# These accumulate across restarts when nohup prevents clean child reaping.
MCP_PATTERNS=(
  "quantum-management-mcp"
  "spark-management-mcp"
  "management-logs-mcp"
  "threat-prevention-mcp"
  "https-inspection-mcp"
  "reputation-service-mcp"
  "threat-emulation-mcp"
  "documentation-mcp"
)

orphans_found=false
for pattern in "${MCP_PATTERNS[@]}"; do
  if pgrep -f "${pattern}" >/dev/null 2>&1; then
    pkill -f "${pattern}" 2>/dev/null || true
    orphans_found=true
  fi
done

if [[ "${orphans_found}" == "true" ]]; then
  echo "[services] Waiting for MCP processes to exit..."
  sleep 2
  # Force-kill any that did not respond to SIGTERM
  for pattern in "${MCP_PATTERNS[@]}"; do
    if pgrep -f "${pattern}" >/dev/null 2>&1; then
      pkill -9 -f "${pattern}" 2>/dev/null || true
      echo "[services] MCP force-killed: ${pattern}"
    fi
  done
  echo "[services] MCP processes stopped."
else
  echo "[services] No orphaned MCP processes found."
fi
