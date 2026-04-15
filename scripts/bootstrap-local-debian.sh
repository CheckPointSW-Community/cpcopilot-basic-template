#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

if ! command -v apt-get >/dev/null 2>&1; then
  echo "[bootstrap] This helper is intended for Debian/Ubuntu systems with apt-get."
  echo "[bootstrap] Install Node.js 20+, npm, jq, python3, git, curl, and ca-certificates manually, then run scripts/setup-opencode.sh."
  exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
  echo "[bootstrap] sudo is required for package installation."
  exit 1
fi

echo "[bootstrap] Installing base packages..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl git jq python3

need_node_install=true
if command -v node >/dev/null 2>&1; then
  node_major="$(node -p 'process.versions.node.split(".")[0]')"
  if [[ "${node_major}" -ge 20 ]]; then
    need_node_install=false
  fi
fi

if [[ "${need_node_install}" == "true" ]]; then
  echo "[bootstrap] Installing Node.js 20.x from NodeSource..."
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt-get install -y nodejs
else
  echo "[bootstrap] Node.js 20+ already present."
fi

echo "[bootstrap] Preparing OpenCode runtime..."
bash "${REPO_ROOT}/scripts/setup-opencode.sh"

echo "[bootstrap] Running guided welcome/setup flow..."
bash "${REPO_ROOT}/scripts/terminal-welcome.sh"