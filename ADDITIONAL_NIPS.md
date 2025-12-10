# Additional Nostr HTTP Protocols

**Date:** December 10, 2024  
**Status:** ✅ Complete - NIP-05, NIP-11, NIP-57, NIP-86 OpenAPI specs implemented

## Overview

This document describes the four additional Nostr HTTP protocol specifications that have been added to this repository:

1. **NIP-05** - Internet identifier to pubkey mapping
2. **NIP-11** - Relay information document
3. **NIP-57** - Lightning zaps via LNURL
4. **NIP-86** - Relay management API

All specs are validated, protocol-compliant, and ready for code generation.

---

## NIP-05: Nostr Identifier Lookup

**Spec:** `nip05/nip05.yaml`  
**Protocol:** Maps email-like identifiers (e.g., `bob@example.com`) to Nostr public keys

### Endpoints

#### `GET /.well-known/nostr.json`

**Purpose:** Look up Nostr public key by internet identifier

**Query Parameters:**
- `name` (optional): Local-part of identifier (e.g., "bob" for bob@example.com)

**Response:**
```json
{
  "names": {
    "bob": "b0635d6a9851d3aed0cd6c495b282167acf761729078d975fc341b22650b07b9"
  },
  "relays": {
    "b0635d6a9851d3aed0cd6c495b282167acf761729078d975fc341b22650b07b9": [
      "wss://relay.example.com"
    ]
  }
}
```

### Key Requirements

- ✅ MUST set `Access-Control-Allow-Origin: *` for JavaScript compatibility
- ✅ MUST NOT return HTTP redirects
- ✅ Local-part restricted to `[a-z0-9-_.]` characters
- ✅ `_` represents root identifier (e.g., `_@example.com` displays as `example.com`)
- ✅ Optional `relays` object maps pubkeys to relay URLs

### Use Cases

- **User discovery:** Type "bob@example.com" in search to find user
- **Identity verification:** Verify user owns domain
- **Contact exchange:** Share identifier instead of raw pubkey

### Code Generation

```bash
# Go server
openapi-generator-cli generate -i nip05/nip05.yaml -g go-server -o generated/nip05

# TypeScript client
openapi-generator-cli generate -i nip05/nip05.yaml -g typescript-fetch -o generated/ts/nip05
```

---

## NIP-11: Relay Information Document

**Spec:** `nip11/nip11.yaml`  
**Protocol:** Relay metadata served via HTTP for capability discovery

### Endpoints

#### `GET /` with `Accept: application/nostr+json`

**Purpose:** Get relay metadata including capabilities, policies, and limitations

**Response:**
```json
{
  "name": "JellyFish",
  "description": "Stay Immortal!",
  "pubkey": "bf2bee5281149c7c350f5d12ae32f514c7864ff10805182f4178538c2c421007",
  "supported_nips": [1, 9, 11, 13, 17, 40, 42],
  "software": "https://github.com/dezh-tech/immortal",
  "version": "immortal - 0.0.9",
  "limitation": {
    "max_message_length": 16384,
    "max_subscriptions": 20,
    "auth_required": false,
    "payment_required": true
  },
  "retention": [
    {"kinds": [0, 1], "time": 3600}
  ],
  "fees": {
    "subscription": [
      {"amount": 3000, "unit": "sats", "period": 2628003}
    ]
  }
}
```

### Key Fields

**Basic Info:**
- `name`: Relay name (< 30 chars recommended)
- `description`: Plain-text description
- `pubkey`: Admin contact for support
- `supported_nips`: Array of NIP numbers implemented

**Server Info:**
- `software`: URL to project homepage
- `version`: Software version
- `icon`/`banner`: Image URLs for UI

**Limitations:**
- `max_message_length`: Max WebSocket frame size
- `max_subscriptions`: Max active subs per connection
- `max_limit`: Server clamps filter limits to this
- `auth_required`: NIP-42 auth required
- `payment_required`: Payment required

**Retention Policies:**
- `time`: Retention seconds (null = infinity, 0 = not stored)
- `count`: Max number of events
- `kinds`: Event kinds or ranges this applies to

**Fees:**
- `admission`: One-time admission fees
- `subscription`: Recurring subscription fees
- `publication`: Per-event publication fees

### Use Cases

- **Client setup:** Discover relay capabilities before connecting
- **Feature detection:** Check if relay supports specific NIPs
- **Policy display:** Show users relay rules and costs
- **Relay discovery:** Filter relays by features

### Code Generation

```bash
# Python client
openapi-generator-cli generate -i nip11/nip11.yaml -g python -o generated/python/nip11

# Rust server
openapi-generator-cli generate -i nip11/nip11.yaml -g rust-server -o generated/rust/nip11
```

---

## NIP-57: Lightning Zaps

**Spec:** `nip57/nip57.yaml`  
**Protocol:** Lightning payments with Nostr event context via LNURL

### Endpoints

#### `GET /.well-known/lnurlp/{username}`

**Purpose:** LNURL pay endpoint discovery with nostr support info

**Response:**
```json
{
  "callback": "https://example.com/lnurlp/callback",
  "minSendable": 1000,
  "maxSendable": 100000000,
  "tag": "payRequest",
  "allowsNostr": true,
  "nostrPubkey": "9630f464cca6a5147aa8a35f0bcdd3ce485324e732fd39e09233b1d848238f31"
}
```

#### `GET /lnurlp/callback`

**Purpose:** Request invoice with zap metadata

**Query Parameters:**
- `amount` (required): Amount in millisats
- `nostr` (optional): URI-encoded, JSON-encoded zap request event (kind 9734)
- `lnurl` (optional): Recipient's lnurl

**Response:**
```json
{
  "pr": "lnbc10u1p3unwfu...",
  "successAction": {...}
}
```

### Protocol Flow

1. **Discovery:** Client fetches `/.well-known/lnurlp/{username}`
2. **Check support:** If `allowsNostr: true`, use NIP-57 flow
3. **Create zap request:** Kind 9734 event with tags:
   - `relays`: Where to publish zap receipt
   - `amount`: Millisats as string
   - `p`: Recipient pubkey
   - `e` (optional): Event being zapped
4. **Get invoice:** Send zap request to `callback` as `nostr` query param
5. **Validate:** Server validates zap request signature and tags
6. **Pay:** Client pays BOLT-11 invoice
7. **Receipt:** Server publishes kind 9735 zap receipt to specified relays

### Zap Request Event (kind 9734)

```json
{
  "kind": 9734,
  "content": "Great post!",
  "tags": [
    ["relays", "wss://relay.damus.io"],
    ["amount", "21000"],
    ["lnurl", "lnurl1dp68gurn..."],
    ["p", "04c915daefee38317fa734444acee390a8269fe5810b2241e5e6dd343dfbecc9"],
    ["e", "9ae37aa68f48645127299e9453eb5d908a0cbb6058ff340d528ed4d37c8994fb"]
  ],
  "pubkey": "97c70a44366a6535c145b333f973ea86dfdc2d7a99da618c40c64705ad98e322",
  "created_at": 1679673265,
  "id": "...",
  "sig": "..."
}
```

### Zap Receipt Event (kind 9735)

Published by LNURL server after invoice is paid:

```json
{
  "kind": 9735,
  "pubkey": "9630f464cca6a5147aa8a35f0bcdd3ce485324e732fd39e09233b1d848238f31",
  "tags": [
    ["p", "32e1827635450ebb3c5a7d12c1f8e7b2b514439ac10a67eef3d9fd9c5c68e245"],
    ["P", "97c70a44366a6535c145b333f973ea86dfdc2d7a99da618c40c64705ad98e322"],
    ["e", "3624762a1274dd9636e0c552b53086d70bc88c165bc4dc0f9e836a1eaf86c3b8"],
    ["bolt11", "lnbc10u1p3unwfu..."],
    ["description", "{...zap request event...}"],
    ["preimage", "5d006d2cf1e73c..."]
  ],
  "content": "",
  "created_at": 1674164545
}
```

### Validation Requirements

Server MUST validate zap requests:
1. Valid Nostr signature
2. Has tags
3. Only one `p` tag
4. 0 or 1 `e` tags
5. Has `relays` tag
6. If `amount` tag present, equals amount query param
7. If `a` tag present, is valid event coordinate

### Use Cases

- **Tipping:** Send lightning payment with social context
- **Proof of payment:** Zap receipts visible on relays
- **Spam deterrence:** Require payment to post
- **Value exchange:** Pay for content or services

### Code Generation

```bash
# Java client
openapi-generator-cli generate -i nip57/nip57.yaml -g java -o generated/java/nip57

# Node.js server
openapi-generator-cli generate -i nip57/nip57.yaml -g nodejs-express-server -o generated/node/nip57
```

---

## NIP-86: Relay Management API

**Spec:** `nip86/nip86.yaml`  
**Protocol:** JSON-RPC relay administration with NIP-98 auth

### Endpoint

#### `POST /` with `Content-Type: application/nostr+json+rpc`

**Purpose:** Execute relay management methods via JSON-RPC

**Authorization:** REQUIRED - NIP-98 kind 27235 event with `payload` tag

**Request:**
```json
{
  "method": "banpubkey",
  "params": ["3bf0c63fcb93463407af97a5e5ee64fa883d107ef9e558472c4eb9aaaefa459d", "spam"]
}
```

**Response:**
```json
{
  "result": true
}
```

Or on error:
```json
{
  "error": "Unauthorized: invalid signature"
}
```

### Supported Methods

#### Key Management
- `banpubkey(pubkey, reason)` - Ban a public key
- `listbannedpubkeys()` - List banned keys
- `allowpubkey(pubkey, reason)` - Add key to allowlist
- `listallowedpubkeys()` - List allowed keys

#### Event Management
- `allowevent(event_id, reason)` - Allow specific event
- `banevent(event_id, reason)` - Ban specific event
- `listbannedevents()` - List banned events
- `listeventsneedingmoderation()` - List flagged events

#### Relay Configuration
- `changerelayname(name)` - Change relay name
- `changerelaydescription(description)` - Change description
- `changerelayicon(icon_url)` - Change icon

#### Kind Management
- `allowkind(kind)` - Allow event kind
- `disallowkind(kind)` - Disallow event kind
- `listallowedkinds()` - List allowed kinds

#### IP Management
- `blockip(ip, reason)` - Block IP address
- `unblockip(ip)` - Unblock IP
- `listblockedips()` - List blocked IPs

#### Discovery
- `supportedmethods()` - List available methods

### Authorization (NIP-98)

All requests MUST include Authorization header:

```
Authorization: Nostr eyJpZCI6ImZlOTY0ZTc1ODkwMzM2MGYyOGQ4NDI0ZDA5MmRhODQ5NGVkMjA3Y2Jh...
```

Event requirements:
- `kind`: 27235
- `u` tag: Relay URL
- `method` tag: "POST"
- `payload` tag: SHA256 hash of request body (REQUIRED for NIP-86)
- `created_at`: Within time window

### Example Implementation

```typescript
async function banPubkey(relayUrl: string, pubkey: string, reason: string) {
  // Create request
  const request = {
    method: "banpubkey",
    params: [pubkey, reason]
  };
  
  // Create NIP-98 auth event
  const authEvent = await createNip98Event({
    u: relayUrl,
    method: "POST",
    payload: sha256(JSON.stringify(request))
  });
  
  // Send request
  const response = await fetch(relayUrl, {
    method: "POST",
    headers: {
      "Content-Type": "application/nostr+json+rpc",
      "Authorization": `Nostr ${btoa(JSON.stringify(authEvent))}`
    },
    body: JSON.stringify(request)
  });
  
  const result = await response.json();
  if (result.error) {
    throw new Error(result.error);
  }
  return result.result;
}
```

### Use Cases

- **Moderation:** Ban spam accounts and content
- **Access control:** Manage allowlists and rate limits
- **Configuration:** Update relay settings remotely
- **Monitoring:** Check moderation queue

### Code Generation

```bash
# C# ASP.NET server
openapi-generator-cli generate -i nip86/nip86.yaml -g aspnetcore -o generated/csharp/nip86

# PHP client
openapi-generator-cli generate -i nip86/nip86.yaml -g php -o generated/php/nip86
```

---

## NIP-98: HTTP Authentication (Shared Component)

**Note:** NIP-98 is not a standalone API but an authentication mechanism used by other protocols (notably NIP-86).

### Security Scheme Definition

All specs using NIP-98 auth include this security scheme:

```yaml
securitySchemes:
  Nip98Auth:
    type: http
    scheme: Nostr
    description: |
      NIP-98 HTTP Auth: Base64-encoded kind 27235 event.
      Format: 'Authorization: Nostr <base64-encoded-event>'
      
      Event requirements:
      - kind: 27235
      - u tag: Full request URL including query params
      - method tag: HTTP method (GET, POST, etc.)
      - payload tag (optional): SHA256 hash of request body
      - created_at: Within time window (60s recommended)
```

### Usage

When a protocol requires NIP-98 auth:

```http
POST /api/endpoint HTTP/1.1
Host: example.com
Authorization: Nostr eyJpZCI6ImZlOTY0ZTc1ODkwMzM2MGYyOGQ4NDI0ZDA5MmRhODQ5...
Content-Type: application/json

{"data": "..."}
```

### Validation

Servers MUST validate:
1. `kind` is 27235
2. `created_at` within time window (suggest 60s)
3. `u` tag exactly matches request URL
4. `method` tag matches HTTP method
5. If body present, `payload` tag matches SHA256(body)

---

## Testing & Validation

All specs have been validated:

```bash
# Validate all new specs
npm run validate:all

# Validate individually
npm run validate:nip05
npm run validate:nip11
npm run validate:nip57
npm run validate:nip86

# Preview interactive docs
npm run preview:nip05
npm run preview:nip11
npm run preview:nip57
npm run preview:nip86
```

### Validation Results

```
✅ nip05/nip05.yaml: validated
✅ nip11/nip11.yaml: validated
✅ nip57/nip57.yaml: validated
✅ nip86/nip86.yaml: validated
```

---

## Protocol Coverage Summary

| Protocol | Endpoints | Auth | Status |
|----------|-----------|------|--------|
| NIP-05 | 1 (`/.well-known/nostr.json`) | None | ✅ Complete |
| NIP-11 | 1 (relay root with Accept header) | None | ✅ Complete |
| NIP-57 | 2 (LNURL discovery + callback) | None | ✅ Complete |
| NIP-86 | 1 (JSON-RPC management) | NIP-98 | ✅ Complete |
| NIP-98 | N/A (auth mechanism) | N/A | ✅ Documented |

---

## Code Generation Examples

### Generate All Specs

```bash
# Go servers for all protocols
for spec in nip05 nip11 nip57 nip86; do
  openapi-generator-cli generate \
    -i ${spec}/${spec}.yaml \
    -g go-server \
    -o generated/go/${spec}
done

# TypeScript clients for all protocols
for spec in nip05 nip11 nip57 nip86; do
  openapi-generator-cli generate \
    -i ${spec}/${spec}.yaml \
    -g typescript-fetch \
    -o generated/typescript/${spec}
done
```

### Docker-based Generation

```bash
docker run --rm -v "${PWD}:/local" openapitools/openapi-generator-cli generate \
  -i /local/nip05/nip05.yaml \
  -g python \
  -o /local/generated/python/nip05
```

---

## Implementation Notes

### NIP-05
- Servers should support both static JSON files and dynamic generation
- CORS is critical - JavaScript clients depend on it
- Consider caching responses for performance

### NIP-11
- Response format may evolve - clients must ignore unknown fields
- All fields optional - document what your relay supports
- Consider implementing fees/limitations even if not charging yet

### NIP-57
- Integrates LNURL pay protocol - review LUD-06 specification
- Zap request validation is critical for security
- Consider implementing comment support (LUD-12)

### NIP-86
- Authorization is mandatory - no unauthenticated access
- Payload tag verification is critical for security
- Implement method filtering to limit admin capabilities

---

## Resources

### Official Specifications
- [NIP-05](https://github.com/nostr-protocol/nips/blob/master/05.md)
- [NIP-11](https://github.com/nostr-protocol/nips/blob/master/11.md)
- [NIP-57](https://github.com/nostr-protocol/nips/blob/master/57.md)
- [NIP-86](https://github.com/nostr-protocol/nips/blob/master/86.md)
- [NIP-98](https://github.com/nostr-protocol/nips/blob/master/98.md)

### LNURL Specs (for NIP-57)
- [LUD-06: LNURL Pay](https://github.com/lnurl/luds/blob/luds/06.md)
- [LUD-12: Comments](https://github.com/lnurl/luds/blob/luds/12.md)
- [LUD-16: Lightning Address](https://github.com/lnurl/luds/blob/luds/16.md)

### Tools
- [OpenAPI Generator](https://openapi-generator.tech/)
- [Redocly CLI](https://redocly.com/docs/cli/)
- [Swagger Editor](https://editor.swagger.io/)

---

## Next Steps

1. **Generate code** for your target language
2. **Implement handlers** for each endpoint
3. **Test with real Nostr clients** (Damus, Amethyst, etc.)
4. **Deploy and advertise** your implementation
5. **Contribute improvements** back to this repository

All specs are production-ready and extensively documented. Happy building! 🚀
