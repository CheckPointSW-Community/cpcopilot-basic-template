#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[services] Restarting all services..."
bash "${SCRIPT_DIR}/stop-services.sh"
bash "${SCRIPT_DIR}/start-opencode-web.sh"
bash "${SCRIPT_DIR}/start-report-server.sh"
echo "[services] All services restarted."
