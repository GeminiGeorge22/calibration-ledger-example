# calibration-ledger-example

One-command **lookup** example for [`publicrecords/calibration-ledger`](https://apify.com/publicrecords/calibration-ledger) (`nff3bVHTmDFCfkTDA`) via Apify MCP `/mcp`.

Place one institutional claim (OECD EO, IMF WEO, Fed SEP, SPF, …) in that organization's track record — error distribution, intervals, bias, band coverage, worst misses with source links — or honest "no coverage" (free). Organizations only, never people.

**Manifest-only repo — no Actor source.**

## MCP pin (`/mcp`)

```
https://mcp.apify.com/?tools=publicrecords/calibration-ledger
```

Auth: your own Apify token (`Authorization: Bearer $APIFY_TOKEN`). Runs bill on your Apify account.

## Lookup input (from Store listing)

Same fields as the Store example / input schema prefills — do not invent extras:

```json
{
  "mode": "lookup",
  "source": "oecd_eo",
  "series": "RGDP_GROWTH_A",
  "geo": "CAN",
  "target_period": "2027",
  "point": "1.8",
  "published_at": "2026-06-01"
}
```

Also in `input.json`.

| Field | Value |
|---|---|
| `mode` | `lookup` |
| `source` | `oecd_eo` |
| `series` | `RGDP_GROWTH_A` |
| `geo` | `CAN` |
| `target_period` | `2027` |
| `point` | `1.8` |
| `published_at` | `2026-06-01` |

## Call via Apify MCP `/mcp`

Requires `APIFY_TOKEN`. Scripted handshake + `call-actor`:

```bash
chmod +x call-mcp.sh
./call-mcp.sh
```

Or curl the hosted MCP endpoint (Streamable HTTP). After `initialize` + `notifications/initialized`, POST:

```bash
curl -sS -X POST \
  "https://mcp.apify.com/?tools=publicrecords/calibration-ledger" \
  -H "Authorization: Bearer $APIFY_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -H "Mcp-Session-Id: $SESSION_ID" \
  -d '{
    "jsonrpc": "2.0",
    "id": 2,
    "method": "tools/call",
    "params": {
      "name": "call-actor",
      "arguments": {
        "actor": "publicrecords/calibration-ledger",
        "input": {
          "mode": "lookup",
          "source": "oecd_eo",
          "series": "RGDP_GROWTH_A",
          "geo": "CAN",
          "target_period": "2027",
          "point": "1.8",
          "published_at": "2026-06-01"
        },
        "waitSecs": 45
      }
    }
  }'
```

`call-actor` returns run status + storage IDs; use `get-dataset-items` on the returned `datasetId` for rows.

### Cursor / Claude (pin only)

```json
{
  "mcpServers": {
    "calibration-ledger": {
      "url": "https://mcp.apify.com/?tools=publicrecords/calibration-ledger"
    }
  }
}
```

Then ask: *Look up OECD EO Canada RGDP growth 1.8 for 2027 published 2026-06-01.*

## Alternate: Apify CLI

```bash
apify call publicrecords/calibration-ledger --input '{
  "mode": "lookup",
  "source": "oecd_eo",
  "series": "RGDP_GROWTH_A",
  "geo": "CAN",
  "target_period": "2027",
  "point": "1.8",
  "published_at": "2026-06-01"
}'
```

## Pricing (as of Oct 28, 2026)

Pay per event, billed on your Apify account ([Store pricing](https://apify.com/publicrecords/calibration-ledger/pricing)). Free-plan list prices.

- Actor start: **0.5¢**
- Lookup: **2¢** (place one claim in its record; 1.6¢ on Silver and up)
- Score: **2¢** · Text: **3¢** · Compare / Issuer: **5¢**
- Coverage / honest "no coverage": free

## What this repo is not

- Not Actor implementation / Docker / truth sets
- Not a public Store task (skip when storages is null)

Disclosure: I maintain these Actors on Apify Store (publicrecords).
