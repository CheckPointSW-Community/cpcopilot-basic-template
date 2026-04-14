#!/usr/bin/env bash
set -euo pipefail

USER_ENV_FILE="${HOME}/.config/opencode/checkpoint-secrets.env"
STATE_DIR="${HOME}/.local/state/checkpoint-copilot"
SEED_STATE_FILE="${STATE_DIR}/opencode-intro-seeded"
SEED_INFO_FILE="${STATE_DIR}/opencode-intro-session.json"

mkdir -p "${STATE_DIR}"

if [[ -f "${USER_ENV_FILE}" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "${USER_ENV_FILE}"
  set +a
fi

OPENCODE_PORT="${OPENCODE_PORT:-4096}"
OPENCODE_SERVER_USERNAME="${OPENCODE_SERVER_USERNAME:-opencode}"
OPENCODE_SERVER_PASSWORD="${OPENCODE_SERVER_PASSWORD:-}"
SEED_TITLE="Check Point CoPilot Intro"
SEED_PROMPT="Tell me about yourself"
SEED_AGENT_PREFERRED="CheckPoint-copilot"
SERVER_PORT="${OPENCODE_PORT}"

export PATH="${HOME}/.local/npm-global/bin:${PATH}"

curl_json() {
  local method="$1"
  local url="$2"
  local body="${3:-}"

  if [[ -n "${OPENCODE_SERVER_PASSWORD}" ]]; then
    if [[ -n "${body}" ]]; then
      curl -sS -u "${OPENCODE_SERVER_USERNAME}:${OPENCODE_SERVER_PASSWORD}" -H 'Content-Type: application/json' -X "$method" "$url" -d "$body"
    else
      curl -sS -u "${OPENCODE_SERVER_USERNAME}:${OPENCODE_SERVER_PASSWORD}" -X "$method" "$url"
    fi
  else
    if [[ -n "${body}" ]]; then
      curl -sS -H 'Content-Type: application/json' -X "$method" "$url" -d "$body"
    else
      curl -sS -X "$method" "$url"
    fi
  fi
}

json_build_title() {
  python3 - "$1" <<'PY'
import json, sys
print(json.dumps({"title": sys.argv[1]}))
PY
}

json_build_message() {
  python3 - "$1" "$2" <<'PY'
import json, sys
print(json.dumps({
  "agent": sys.argv[2],
    "noReply": True,
    "parts": [{"type": "text", "text": sys.argv[1]}],
}))
PY
}

json_extract_session_id() {
  python3 - "$1" <<'PY'
import json, sys
try:
    data = json.loads(sys.argv[1])
except Exception:
    print("")
    raise SystemExit(0)
for key in ("id", "ID", "sessionID"):
    value = data.get(key)
    if value:
        print(value)
        raise SystemExit(0)
info = data.get("info") or {}
print(info.get("id", ""))
PY
}

json_extract_session_slug() {
  python3 - "$1" <<'PY'
import json, sys
try:
    data = json.loads(sys.argv[1])
except Exception:
    print("")
    raise SystemExit(0)
print(data.get("slug", ""))
PY
}

json_find_session_id() {
  python3 - "$1" "$2" <<'PY'
import json, sys
try:
  sessions = json.loads(sys.argv[1])
except Exception:
  sessions = []
title = sys.argv[2]
for session in sessions:
  current = (session.get("title") or ((session.get("info") or {}).get("title")) or "")
  if current != title:
    continue
  for key in ("id", "ID", "sessionID"):
    value = session.get(key)
    if value:
      print(value)
      raise SystemExit(0)
  info = session.get("info") or {}
  print(info.get("id", ""))
  raise SystemExit(0)
print("")
PY
}

json_find_session_slug() {
  python3 - "$1" "$2" <<'PY'
import json, sys
try:
  sessions = json.loads(sys.argv[1])
except Exception:
  sessions = []
title = sys.argv[2]
for session in sessions:
  current = (session.get("title") or ((session.get("info") or {}).get("title")) or "")
  if current == title:
    print(session.get("slug", ""))
    raise SystemExit(0)
print("")
PY
}

json_message_exists() {
  python3 - "$1" "$2" <<'PY'
import json, sys
try:
    messages = json.loads(sys.argv[1])
except Exception:
    messages = []
needle = sys.argv[2]
for message in messages:
    for part in message.get("parts") or []:
        if part.get("type") == "text" and part.get("text") == needle:
            raise SystemExit(0)
raise SystemExit(1)
PY
}

json_resolve_agent_name() {
  python3 - "$1" "$2" <<'PY'
import json, sys

try:
  agents = json.loads(sys.argv[1])
except Exception:
  agents = []

preferred = sys.argv[2]
preferred_lower = preferred.lower()

for agent in agents:
  name = (agent or {}).get("name", "")
  if name == preferred:
    print(name)
    raise SystemExit(0)

for agent in agents:
  name = (agent or {}).get("name", "")
  if name.lower() == preferred_lower:
    print(name)
    raise SystemExit(0)

for agent in agents:
  name = (agent or {}).get("name", "")
  if "copilot" in name.lower():
    print(name)
    raise SystemExit(0)

print(preferred)
PY
}

write_seed_info() {
  local session_id="$1"
  local session_slug="$2"

  python3 - "$SEED_INFO_FILE" "$session_id" "$session_slug" "$OPENCODE_PORT" <<'PY'
import json, sys
from pathlib import Path

target = Path(sys.argv[1])
session_id = sys.argv[2]
session_slug = sys.argv[3]
port = sys.argv[4]
path = f"/{session_slug}/session/{session_id}" if session_slug else ""
payload = {
    "id": session_id,
    "slug": session_slug,
    "path": path,
    "url": f"http://localhost:{port}{path}" if path else f"http://localhost:{port}",
}
target.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
PY
}

wait_for_health() {
  local port="$1"
  for _ in $(seq 1 30); do
    if curl_json GET "http://127.0.0.1:${port}/global/health" >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  return 1
}

if ! wait_for_health "${SERVER_PORT}"; then
  echo "[seed] OpenCode server is not reachable yet; skipping intro session seed."
  exit 0
fi

agents_json="$(curl_json GET "http://127.0.0.1:${SERVER_PORT}/agent" || echo '[]')"
seed_agent_name="$(json_resolve_agent_name "${agents_json}" "${SEED_AGENT_PREFERRED}")"

sessions_json="$(curl_json GET "http://127.0.0.1:${SERVER_PORT}/session" || echo '[]')"
session_id="$(json_find_session_id "${sessions_json}" "${SEED_TITLE}")"
session_slug="$(json_find_session_slug "${sessions_json}" "${SEED_TITLE}")"

if [[ -z "${session_id}" ]]; then
  create_body="$(json_build_title "${SEED_TITLE}")"
  session_json="$(curl_json POST "http://127.0.0.1:${SERVER_PORT}/session" "${create_body}" || true)"
  session_id="$(json_extract_session_id "${session_json}")"
  session_slug="$(json_extract_session_slug "${session_json}")"
fi

if [[ -z "${session_id}" ]]; then
  echo "[seed] Could not create intro session; skipping."
  exit 0
fi

messages_json="$(curl_json GET "http://127.0.0.1:${SERVER_PORT}/session/${session_id}/message" || echo '[]')"
if json_message_exists "${messages_json}" "${SEED_PROMPT}"; then
  write_seed_info "${session_id}" "${session_slug}"
  touch "${SEED_STATE_FILE}"
  echo "[seed] OpenCode intro session is already ready."
  exit 0
fi

message_body="$(json_build_message "${SEED_PROMPT}" "${seed_agent_name}")"
curl_json POST "http://127.0.0.1:${SERVER_PORT}/session/${session_id}/message" "${message_body}" >/dev/null 2>&1 || true

messages_json="$(curl_json GET "http://127.0.0.1:${SERVER_PORT}/session/${session_id}/message" || echo '[]')"
if json_message_exists "${messages_json}" "${SEED_PROMPT}"; then
  write_seed_info "${session_id}" "${session_slug}"
  touch "${SEED_STATE_FILE}"
  echo "[seed] OpenCode intro session created."
  exit 0
fi

echo "[seed] Intro session exists, but the welcome prompt was not confirmed. It will be retried later."
