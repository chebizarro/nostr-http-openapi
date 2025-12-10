# Nostr HTTP APIs - Quick Reference

## All Available Specs

| Spec | File | Endpoints | Auth | Purpose |
|------|------|-----------|------|---------|
| **Blossom** | `blossom/blossom.yaml` | 10 endpoints | Kind 24242 | Blob storage with media optimization, payments, reporting |
| **NIP-96** | `nip96/nip96.yaml` | 5 endpoints | Kind 27235 | File upload/download/management |
| **NIP-05** | `nip05/nip05.yaml` | 1 endpoint | None | Identifier to pubkey mapping |
| **NIP-11** | `nip11/nip11.yaml` | 1 endpoint | None | Relay metadata discovery |
| **NIP-57** | `nip57/nip57.yaml` | 2 endpoints | None | Lightning zaps via LNURL |
| **NIP-86** | `nip86/nip86.yaml` | 1 endpoint (17 methods) | Kind 27235 | Relay management API |

---

## Quick Commands

### Validation
```bash
# All specs
npm run validate:all

# Individual
npm run validate:blossom
npm run validate:nip96
npm run validate:nip05
npm run validate:nip11
npm run validate:nip57
npm run validate:nip86
```

### Interactive Docs
```bash
npm run preview:blossom    # http://localhost:8080
npm run preview:nip96
npm run preview:nip05
npm run preview:nip11
npm run preview:nip57
npm run preview:nip86
```

### Code Generation
```bash
# Go server
openapi-generator-cli generate -i <spec>.yaml -g go-server -o generated/go/<name>

# TypeScript client
openapi-generator-cli generate -i <spec>.yaml -g typescript-fetch -o generated/ts/<name>

# Python client
openapi-generator-cli generate -i <spec>.yaml -g python -o generated/python/<name>
```

---

## Endpoint Quick Lookup

### File Storage

**Blossom:**
- `GET /{sha256}` - Download blob
- `HEAD /{sha256}` - Check blob exists
- `DELETE /{sha256}` - Delete blob
- `HEAD /upload` - Check upload requirements
- `PUT /upload` - Upload blob
- `GET /list/{pubkey}` - List user's blobs
- `PUT /mirror` - Mirror from URL
- `HEAD /media` - Check media optimization
- `PUT /media` - Optimize media (optional)
- `PUT /report` - Report blob (optional)

**NIP-96:**
- `GET /.well-known/nostr/nip96.json` - Discovery
- `POST /upload` - Upload file
- `GET /{hash}` - Download file
- `DELETE /{hash}` - Delete file
- `GET /` - List files
- `GET /processing/{id}` - Check processing status

### Identity & Discovery

**NIP-05:**
- `GET /.well-known/nostr.json?name=<user>` - Lookup identifier

**NIP-11:**
- `GET /` (with `Accept: application/nostr+json`) - Relay info

### Lightning

**NIP-57:**
- `GET /.well-known/lnurlp/{username}` - LNURL discovery
- `GET /lnurlp/callback?amount=X&nostr=...` - Get zap invoice

### Management

**NIP-86:**
- `POST /` (JSON-RPC methods):
  - `banpubkey`, `allowpubkey`, `listbannedpubkeys`
  - `banevent`, `allowevent`, `listbannedevents`
  - `allowkind`, `disallowkind`, `listallowedkinds`
  - `blockip`, `unblockip`, `listblockedips`
  - `changerelayname`, `changerelaydescription`, `changerelayicon`

---

## Authorization Headers

### Blossom (Kind 24242)
```http
Authorization: Nostr <base64-event>
```
Event tags:
- `t`: verb (get, upload, list, delete)
- `x`: blob hash(es)
- `expiration`: future timestamp

### NIP-96 & NIP-86 (Kind 27235)
```http
Authorization: Nostr <base64-event>
```
Event tags:
- `u`: full URL with query params
- `method`: HTTP method
- `payload` (optional/required): SHA256 of body

---

## Response Schemas

### BlobDescriptor (Blossom)
```json
{
  "url": "https://cdn.example.com/{hash}.ext",
  "sha256": "64-char-hex",
  "size": 12345,
  "type": "image/png",
  "uploaded": 1702389123,
  "nip94": [...]
}
```

### NIP-94 Event (NIP-96)
```json
{
  "tags": [
    ["url", "https://..."],
    ["ox", "original-hash"],
    ["x", "transformed-hash"],
    ["m", "mime-type"],
    ["dim", "1920x1080"]
  ],
  "content": "description",
  "created_at": 1702389123
}
```

### Relay Info (NIP-11)
```json
{
  "name": "RelayName",
  "supported_nips": [1, 9, 11, ...],
  "limitation": {
    "max_message_length": 16384,
    "auth_required": false
  },
  "fees": {
    "subscription": [{"amount": 3000, "unit": "sats"}]
  }
}
```

---

## Common Patterns

### CORS Headers (NIP-05, NIP-11)
Always include:
```yaml
headers:
  Access-Control-Allow-Origin:
    schema:
      type: string
      example: "*"
```

### Error Responses
```yaml
headers:
  X-Reason:
    schema:
      type: string
    example: "Detailed error message"
```

### File Extensions (Blossom, NIP-96)
```
/{sha256}          # No extension
/{sha256}.pdf      # With extension
/{sha256}.jpg
```

### Pagination (Blossom)
```
GET /list/{pubkey}?cursor={hash}&limit=50
```

---

## Testing Checklist

- [ ] Validate OpenAPI schema
- [ ] Generate code in target language
- [ ] Test with real Nostr events
- [ ] Verify authorization handling
- [ ] Test error cases
- [ ] Check CORS headers
- [ ] Validate response schemas
- [ ] Test file extensions
- [ ] Verify hash formats
- [ ] Test pagination (if applicable)

---

## Common Issues

### NIP-98 Auth
❌ Don't use `Bearer` or `JWT`  
✅ Use `Nostr` scheme with base64 event

### File Extensions
❌ Don't require extensions  
✅ Support optional extensions: `/{hash}(.ext)`

### CORS
❌ Don't forget CORS headers  
✅ Always set `Access-Control-Allow-Origin: *`

### Hash Format
❌ Don't use npub format  
✅ Use 64-character lowercase hex

### Pagination
❌ Don't use offset-based (Blossom)  
✅ Use cursor-based with blob hash

---

## Generator Flags

```bash
# Show all generators
openapi-generator-cli list

# Show generator options
openapi-generator-cli config-help -g go-server

# Common options
-g <generator>              # Generator name
-i <input-spec>            # Input OpenAPI spec
-o <output-dir>            # Output directory
--additional-properties    # Generator-specific options
--skip-validate-spec       # Skip validation
```

---

## Resources

- **Specs:** All `.yaml` files in this repo
- **Docs:** `ADDITIONAL_NIPS.md`, `VALIDATION_REPORT.md`, `TESTING.md`
- **NIPs:** https://github.com/nostr-protocol/nips
- **Blossom:** https://github.com/hzrd149/blossom
- **LNURL:** https://github.com/lnurl/luds
