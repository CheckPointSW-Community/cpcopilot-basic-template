#!/usr/bin/env bash

codespaces_forwarded_base_url() {
  local port="${1:-}"

  if [[ -z "${port}" ]]; then
    return 1
  fi

  if [[ -n "${CODESPACE_NAME:-}" && -n "${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-}" ]]; then
    printf 'https://%s-%s.%s' "${CODESPACE_NAME}" "${port}" "${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
    return 0
  fi

  return 1
}

local_network_ip() {
  local detected_ip=""

  if command -v ip >/dev/null 2>&1; then
    detected_ip="$(ip route get 1.1.1.1 2>/dev/null | awk '/src/ {for (i=1; i<=NF; i++) if ($i == "src") {print $(i+1); exit}}')"
  fi

  if [[ -z "${detected_ip}" ]] && command -v hostname >/dev/null 2>&1; then
    detected_ip="$(hostname -I 2>/dev/null | awk '{for (i=1; i<=NF; i++) if ($i !~ /^127\./) {print $i; exit}}')"
  fi

  if [[ -n "${detected_ip}" ]]; then
    printf '%s' "${detected_ip}"
    return 0
  fi

  return 1
}

service_url_for_port() {
  local port="${1:-}"
  local path="${2:-}"
  local base_url

  if base_url="$(codespaces_forwarded_base_url "${port}")"; then
    printf '%s%s' "${base_url}" "${path}"
  elif base_url="$(local_network_ip)"; then
    printf 'http://%s:%s%s' "${base_url}" "${port}" "${path}"
  else
    printf 'http://localhost:%s%s' "${port}" "${path}"
  fi
}
