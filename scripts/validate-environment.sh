#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
NPM_GLOBAL_BIN="${HOME}/.local/npm-global/bin"

export PATH="${NPM_GLOBAL_BIN}:${PATH}"

QUICK_MODE=false
if [[ "${1:-}" == "--quick" ]]; then
  QUICK_MODE=true
fi

PASS_COUNT=0
FAIL_COUNT=0
HAS_JQ=false

pass() {
  echo "[PASS] $1"
  PASS_COUNT=$((PASS_COUNT + 1))
}

fail() {
  echo "[FAIL] $1"
  FAIL_COUNT=$((FAIL_COUNT + 1))
}

skip() {
  echo "[SKIP] $1"
}

check_cmd() {
  local name="$1"
  if command -v "$name" >/dev/null 2>&1; then
    pass "${name} is installed"
  else
    fail "${name} is missing"
  fi
}

echo "===== Validation: Check Point OpenCode Codespaces Template ====="

check_cmd node
check_cmd npm
check_cmd npx
check_cmd jq
if command -v jq >/dev/null 2>&1; then
  HAS_JQ=true
fi
check_cmd python3
check_cmd opencode

for mcp_bin in quantum-management-mcp spark-management-mcp management-logs-mcp threat-prevention-mcp https-inspection-mcp reputation-service-mcp threat-emulation-mcp documentation-mcp; do
  if [[ -x "${NPM_GLOBAL_BIN}/${mcp_bin}" ]]; then
    pass "${mcp_bin} is installed locally"
  else
    fail "${mcp_bin} is not installed locally"
  fi
done

if [[ -f "${REPO_ROOT}/.devcontainer/devcontainer.json" ]]; then
  pass "devcontainer config exists"
else
  fail "devcontainer config missing"
fi

if [[ "${HAS_JQ}" == "true" ]]; then
  if jq -e '.forwardPorts | index(4096)' "${REPO_ROOT}/.devcontainer/devcontainer.json" >/dev/null 2>&1; then
    pass "OpenCode web port forwarding is configured"
  else
    fail "OpenCode web port forwarding missing"
  fi

  if jq -e '.forwardPorts | index(8081)' "${REPO_ROOT}/.devcontainer/devcontainer.json" >/dev/null 2>&1; then
    pass "Reports port forwarding is configured"
  else
    fail "Reports port forwarding missing"
  fi
else
  skip "Port forwarding JSON checks skipped (jq unavailable)"
fi

if [[ -f "${REPO_ROOT}/AGENTS.md" ]]; then
  pass "AGENTS.md exists"
else
  fail "AGENTS.md is missing"
fi

if [[ -f "${REPO_ROOT}/INSTRUCTIONS.md" ]]; then
  pass "INSTRUCTIONS.md exists"
else
  fail "INSTRUCTIONS.md is missing"
fi

if [[ -f "${HOME}/.config/opencode/skills/checkpoint-copilot/SKILL.md" ]] || [[ -f "${REPO_ROOT}/.opencode/skills/checkpoint-copilot/SKILL.md" ]]; then
  pass "checkpoint-copilot skill exists"
else
  fail "checkpoint-copilot skill missing"
fi

if [[ -f "${HOME}/.config/opencode/skills/checkpoint-brand-webui/SKILL.md" ]] || [[ -f "${REPO_ROOT}/.opencode/skills/checkpoint-brand-webui/SKILL.md" ]]; then
  pass "checkpoint-brand-webui skill exists"
else
  fail "checkpoint-brand-webui skill missing"
fi

if [[ -d "${REPO_ROOT}/reports" ]]; then
  pass "reports directory exists"
else
  fail "reports directory missing"
fi

if grep -q "start-report-server.sh" "${REPO_ROOT}/scripts/terminal-welcome.sh" 2>/dev/null; then
  pass "report server startup is configured"
else
  fail "report server startup not configured"
fi

if grep -q "checkpoint-shell-hook.sh" "${REPO_ROOT}/scripts/setup-opencode.sh" 2>/dev/null; then
  pass "foreground terminal guidance is configured"
else
  fail "foreground terminal guidance is not configured"
fi

if grep -q "opencode web" "${REPO_ROOT}/scripts/start-opencode-web.sh" 2>/dev/null; then
  pass "OpenCode web startup is configured"
else
  fail "OpenCode web startup not configured"
fi

if [[ -f "${REPO_ROOT}/templates/opencode/checkpoint-mcp-fragment.json" ]]; then
  if [[ "${HAS_JQ}" == "true" ]]; then
    for srv in management spark-management management-logs threat-prevention https-inspection reputation-service threat-emulation documentation-tool; do
      if jq -e --arg s "$srv" '.mcp[$s]' "${REPO_ROOT}/templates/opencode/checkpoint-mcp-fragment.json" >/dev/null 2>&1; then
        pass "MCP entry exists for ${srv}"
      else
        fail "MCP entry missing for ${srv}"
      fi
    done
  else
    skip "MCP JSON entry checks skipped (jq unavailable)"
  fi
else
  fail "MCP fragment template missing"
fi

if [[ "${QUICK_MODE}" == "false" ]]; then
  # Heuristic secret leak checks in env-style files only.
  if command -v git >/dev/null 2>&1 && git -C "${REPO_ROOT}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    if git -C "${REPO_ROOT}" grep -nE '^(CHECKPOINT_API_KEY|CHECKPOINT_PASSWORD|CHECKPOINT_DOC_SECRET_KEY|CHECKPOINT_REPUTATION_SERVICE_API_KEY|CHECKPOINT_THREAT_EMULATION_API_KEY|OPENCODE_SERVER_PASSWORD)=.+$' -- '.env*' ':!.env.example' >/dev/null 2>&1; then
      fail "Potential secret values detected in tracked env files"
    else
      pass "No obvious secret assignments found in tracked env files"
    fi
  else
    if find "${REPO_ROOT}" -maxdepth 2 -type f -name '.env*' ! -name '.env.example' -print0 | \
      xargs -0 grep -nE '^(CHECKPOINT_API_KEY|CHECKPOINT_PASSWORD|CHECKPOINT_DOC_SECRET_KEY|CHECKPOINT_REPUTATION_SERVICE_API_KEY|CHECKPOINT_THREAT_EMULATION_API_KEY|OPENCODE_SERVER_PASSWORD)=.+$' >/dev/null 2>&1; then
      fail "Potential secret values detected in env files"
    else
      pass "No obvious secret assignments found in env files"
    fi
  fi
fi

echo "===== Validation Summary ====="
echo "Passed: ${PASS_COUNT}"
echo "Failed: ${FAIL_COUNT}"

if [[ ${FAIL_COUNT} -gt 0 ]]; then
  exit 1
fi
