#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

OPENCODE_CONFIG_DIR="${HOME}/.config/opencode"
OPENCODE_CONFIG_FILE="${OPENCODE_CONFIG_DIR}/opencode.json"
USER_ENV_FILE="${OPENCODE_CONFIG_DIR}/checkpoint-secrets.env"
STATUS_FILE="${OPENCODE_CONFIG_DIR}/checkpoint-setup-status.json"
MCP_FRAGMENT_FILE="${REPO_ROOT}/templates/opencode/checkpoint-mcp-fragment.json"

DEFAULT_CHECKPOINT_USERNAME="admin"
DEFAULT_CHECKPOINT_PASSWORD="demo123"
DEFAULT_OPENCODE_PASSWORD="demo123"

mkdir -p "${OPENCODE_CONFIG_DIR}" "${HOME}/.local/state/checkpoint-copilot"

if [[ -f "${USER_ENV_FILE}" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "${USER_ENV_FILE}"
  set +a
fi

CHECKPOINT_MGMT_HOST="${CHECKPOINT_MGMT_HOST:-}"
CHECKPOINT_API_KEY="${CHECKPOINT_API_KEY:-}"
CHECKPOINT_USERNAME="${CHECKPOINT_USERNAME:-}"
CHECKPOINT_PASSWORD="${CHECKPOINT_PASSWORD:-}"
CHECKPOINT_DOC_CLIENT_ID="${CHECKPOINT_DOC_CLIENT_ID:-}"
CHECKPOINT_DOC_SECRET_KEY="${CHECKPOINT_DOC_SECRET_KEY:-}"
CHECKPOINT_MGMT_PORT="${CHECKPOINT_MGMT_PORT:-443}"
CHECKPOINT_DOC_REGION="${CHECKPOINT_DOC_REGION:-EU}"
CHECKPOINT_DOC_AUTH_URL="${CHECKPOINT_DOC_AUTH_URL:-}"
OPENCODE_PORT="${OPENCODE_PORT:-4096}"
REPORTS_PORT="${REPORTS_PORT:-8081}"
OPENCODE_SERVER_PASSWORD="${OPENCODE_SERVER_PASSWORD:-}"

is_interactive=false
if [[ -t 0 && -t 1 ]]; then
  is_interactive=true
fi

prompt_if_missing() {
  local var_name="$1"
  local prompt_text="$2"
  local default_value="${3:-}"
  local is_secret="${4:-false}"

  local current_value="${!var_name:-}"
  if [[ -n "${current_value}" ]]; then
    return
  fi

  if [[ "${is_interactive}" != "true" ]]; then
    return
  fi

  if [[ "${is_secret}" == "true" ]]; then
    read -r -s -p "${prompt_text} " input_value
    echo
  else
    if [[ -n "${default_value}" ]]; then
      read -r -p "${prompt_text} [${default_value}] " input_value
      input_value="${input_value:-${default_value}}"
    else
      read -r -p "${prompt_text} " input_value
    fi
  fi

  printf -v "${var_name}" '%s' "${input_value}"
}

prompt_secret_with_default() {
  local var_name="$1"
  local prompt_text="$2"
  local default_value="${3:-}"

  local current_value="${!var_name:-}"
  if [[ -n "${current_value}" ]]; then
    return
  fi

  if [[ "${is_interactive}" != "true" ]]; then
    printf -v "${var_name}" '%s' "${default_value}"
    return
  fi

  local input_value=""
  if [[ -n "${default_value}" ]]; then
    read -r -s -p "${prompt_text} [${default_value}] " input_value
    echo
    input_value="${input_value:-${default_value}}"
  else
    read -r -s -p "${prompt_text} " input_value
    echo
  fi

  printf -v "${var_name}" '%s' "${input_value}"
}

prompt_optional_secret() {
  local var_name="$1"
  local prompt_text="$2"

  local current_value="${!var_name:-}"
  if [[ -n "${current_value}" || "${is_interactive}" != "true" ]]; then
    return
  fi

  local input_value=""
  read -r -s -p "${prompt_text} " input_value
  echo
  printf -v "${var_name}" '%s' "${input_value}"
}

write_env_line() {
  local key="$1"
  local value="$2"
  printf '%s=' "${key}"
  printf '%q' "${value}"
  printf '\n'
}

prompt_if_missing "CHECKPOINT_MGMT_HOST" "Check Point management host (DNS/IP):"
prompt_optional_secret "CHECKPOINT_API_KEY" "Check Point management API key (press Enter to use username/password instead):"

if [[ -z "${CHECKPOINT_API_KEY}" ]]; then
  prompt_if_missing "CHECKPOINT_USERNAME" "Check Point username:" "${DEFAULT_CHECKPOINT_USERNAME}"
  prompt_secret_with_default "CHECKPOINT_PASSWORD" "Check Point password" "${DEFAULT_CHECKPOINT_PASSWORD}"
fi

if [[ -z "${CHECKPOINT_USERNAME}" ]]; then
  CHECKPOINT_USERNAME="${DEFAULT_CHECKPOINT_USERNAME}"
fi

if [[ -z "${CHECKPOINT_API_KEY}" && -z "${CHECKPOINT_PASSWORD}" ]]; then
  CHECKPOINT_PASSWORD="${DEFAULT_CHECKPOINT_PASSWORD}"
fi

prompt_if_missing "CHECKPOINT_DOC_CLIENT_ID" "Documentation tool CLIENT_ID:"
prompt_if_missing "CHECKPOINT_DOC_SECRET_KEY" "Documentation tool SECRET_KEY:" "" true

prompt_secret_with_default "OPENCODE_SERVER_PASSWORD" "OpenCode web password" "${DEFAULT_OPENCODE_PASSWORD}"

if [[ "${is_interactive}" == "true" && -z "${CHECKPOINT_DOC_AUTH_URL}" ]]; then
  read -r -p "Optional documentation AUTH_URL (press Enter to skip): " auth_url_input
  CHECKPOINT_DOC_AUTH_URL="${auth_url_input:-}"
fi

{
cat <<EOF
# User-scoped secrets/state for Check Point OpenCode Codespaces setup.
# File permissions are restricted and this file is intentionally not tracked by git.
EOF
write_env_line "CHECKPOINT_MGMT_HOST" "${CHECKPOINT_MGMT_HOST}"
write_env_line "CHECKPOINT_API_KEY" "${CHECKPOINT_API_KEY}"
write_env_line "CHECKPOINT_USERNAME" "${CHECKPOINT_USERNAME}"
write_env_line "CHECKPOINT_PASSWORD" "${CHECKPOINT_PASSWORD}"
write_env_line "CHECKPOINT_MGMT_PORT" "${CHECKPOINT_MGMT_PORT}"
write_env_line "CHECKPOINT_DOC_CLIENT_ID" "${CHECKPOINT_DOC_CLIENT_ID}"
write_env_line "CHECKPOINT_DOC_SECRET_KEY" "${CHECKPOINT_DOC_SECRET_KEY}"
write_env_line "CHECKPOINT_DOC_REGION" "${CHECKPOINT_DOC_REGION}"
write_env_line "CHECKPOINT_DOC_AUTH_URL" "${CHECKPOINT_DOC_AUTH_URL}"
write_env_line "OPENCODE_SERVER_PASSWORD" "${OPENCODE_SERVER_PASSWORD}"
write_env_line "OPENCODE_PORT" "${OPENCODE_PORT}"
write_env_line "REPORTS_PORT" "${REPORTS_PORT}"
} > "${USER_ENV_FILE}"
chmod 600 "${USER_ENV_FILE}"

BASE_CONFIG_JSON="$(mktemp)"
cat > "${BASE_CONFIG_JSON}" <<EOF
{
  "\$schema": "https://opencode.ai/config.json",
  "server": {
    "port": ${OPENCODE_PORT},
    "hostname": "0.0.0.0"
  },
  "share": "manual"
}
EOF

MERGED_JSON="$(mktemp)"
if [[ -f "${OPENCODE_CONFIG_FILE}" ]] && jq empty "${OPENCODE_CONFIG_FILE}" >/dev/null 2>&1; then
  jq -s '.[0] * .[1] * .[2]' "${OPENCODE_CONFIG_FILE}" "${BASE_CONFIG_JSON}" "${MCP_FRAGMENT_FILE}" > "${MERGED_JSON}"
else
  if [[ -f "${OPENCODE_CONFIG_FILE}" ]]; then
    cp "${OPENCODE_CONFIG_FILE}" "${OPENCODE_CONFIG_FILE}.bak.invalid"
  fi
  jq -s '.[0] * .[1]' "${BASE_CONFIG_JSON}" "${MCP_FRAGMENT_FILE}" > "${MERGED_JSON}"
fi

mv "${MERGED_JSON}" "${OPENCODE_CONFIG_FILE}"

setup_complete=true
if [[ -z "${CHECKPOINT_MGMT_HOST}" || -z "${CHECKPOINT_DOC_CLIENT_ID}" || -z "${CHECKPOINT_DOC_SECRET_KEY}" ]]; then
  setup_complete=false
fi

if [[ -z "${CHECKPOINT_API_KEY}" && ( -z "${CHECKPOINT_USERNAME}" || -z "${CHECKPOINT_PASSWORD}" ) ]]; then
  setup_complete=false
fi

redact() {
  local value="$1"
  if [[ -z "$value" ]]; then
    echo "<missing>"
  else
    local len=${#value}
    if (( len <= 4 )); then
      echo "****"
    else
      echo "${value:0:2}***${value:len-2:2}"
    fi
  fi
}

cat > "${STATUS_FILE}" <<EOF
{
  "setupComplete": ${setup_complete},
  "opencodePort": "${OPENCODE_PORT}",
  "reportsPort": "${REPORTS_PORT}"
}
EOF

echo ""
echo "===== Check Point Codespace Setup Summary (redacted) ====="
echo "Management auth mode     : $( [[ -n "${CHECKPOINT_API_KEY}" ]] && echo "api-key" || echo "username/password" )"
echo "Management host         : $(redact "${CHECKPOINT_MGMT_HOST}")"
echo "Management API key      : $(redact "${CHECKPOINT_API_KEY}")"
echo "Management username     : $(redact "${CHECKPOINT_USERNAME}")"
echo "Management password     : $(redact "${CHECKPOINT_PASSWORD}")"
echo "Doc CLIENT_ID           : $(redact "${CHECKPOINT_DOC_CLIENT_ID}")"
echo "Doc SECRET_KEY          : $(redact "${CHECKPOINT_DOC_SECRET_KEY}")"
echo "Doc AUTH_URL            : $(redact "${CHECKPOINT_DOC_AUTH_URL}")"
echo "OpenCode password       : $(redact "${OPENCODE_SERVER_PASSWORD}")"
echo "OpenCode config file    : ${OPENCODE_CONFIG_FILE}"
echo "Setup complete          : ${setup_complete}"

echo ""
if [[ "${setup_complete}" != "true" ]]; then
  echo "[setup] Setup is incomplete. Add missing Codespaces secrets and re-run: bash scripts/first-run-checkpoint-setup.sh"
fi

rm -f "${BASE_CONFIG_JSON}"
