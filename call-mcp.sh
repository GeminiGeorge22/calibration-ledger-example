#!/usr/bin/env bash
# Minimal working example: Apify hosted MCP (/mcp transport) + lookup input.
# Requires: APIFY_TOKEN, curl, python3
set -euo pipefail

: "${APIFY_TOKEN:?Set APIFY_TOKEN}"

ROOT="$(cd "$(dirname "$0")" && pwd)"
MCP_URL="https://mcp.apify.com/?tools=publicrecords/calibration-ledger"
INPUT_JSON="$(cat "${ROOT}/input.json")"

rpc() {
  local body="$1"
  local sid="${2:-}"
  local -a headers=(
    -H "Authorization: Bearer ${APIFY_TOKEN}"
    -H "Content-Type: application/json"
    -H "Accept: application/json, text/event-stream"
  )
  if [[ -n "$sid" ]]; then
    headers+=(-H "Mcp-Session-Id: ${sid}")
  fi
  curl -sS -D /tmp/mcp-headers.txt -X POST "$MCP_URL" "${headers[@]}" -d "$body"
}

parse_sse() {
  python3 -c '
import sys
text = sys.stdin.read()
for line in text.splitlines():
    if line.startswith("data:"):
        print(line[5:].strip())
        break
else:
    if text.strip():
        print(text.strip())
'
}

echo "1) initialize → ${MCP_URL}" >&2
INIT_RESP="$(rpc '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"calibration-ledger-example","version":"1.0"}}}')"
SID="$(grep -i '^mcp-session-id:' /tmp/mcp-headers.txt | awk '{print $2}' | tr -d '\r' || true)"
echo "$INIT_RESP" | parse_sse >/dev/null || true

echo "2) notifications/initialized (session=${SID:-none})" >&2
rpc '{"jsonrpc":"2.0","method":"notifications/initialized"}' "$SID" >/dev/null || true

CALL_PAYLOAD="$(INPUT_JSON="$INPUT_JSON" python3 <<'PY'
import json, os
inp = json.loads(os.environ["INPUT_JSON"])
print(json.dumps({
  "jsonrpc": "2.0",
  "id": 2,
  "method": "tools/call",
  "params": {
    "name": "call-actor",
    "arguments": {
      "actor": "publicrecords/calibration-ledger",
      "input": inp,
      "waitSecs": 45,
    },
  },
}))
PY
)"

echo "3) tools/call call-actor with Store lookup input" >&2
rpc "$CALL_PAYLOAD" "$SID" | parse_sse
