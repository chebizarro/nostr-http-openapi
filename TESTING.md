# OpenAPI Validation & Testing Guide

This document explains how to validate and test the Blossom and NIP-96 OpenAPI specifications.

## Quick Start

### Install Dependencies
```bash
npm install
```

### Run Validation
```bash
# Automated validation script
npm run validate

# Or run directly
./validate.sh
```

---

## Validation Methods

### 1. Redocly CLI (Recommended)

**Install:**
```bash
npm install -g @redocly/cli
```

**Validate:**
```bash
# Individual files
npm run validate:blossom
npm run validate:nip96

# Or directly
redocly lint blossom/blossom.yaml
redocly lint nip96/nip96.yaml
```

**Bundle (dereference $ref):**
```bash
npm run bundle:blossom
npm run bundle:nip96

# Output to dist/ folder
```

**Preview docs (interactive):**
```bash
npm run preview:blossom
npm run preview:nip96

# Opens browser with interactive API documentation
```

**What it checks:**
- ✅ YAML syntax
- ✅ OpenAPI 3.0 schema compliance
- ✅ $ref resolution
- ✅ Required fields
- ✅ Type consistency
- ✅ Best practices and style guide

### 2. OpenAPI Generator Validation

**Install:**
```bash
npm install -g @openapitools/openapi-generator-cli
```

**Validate:**
```bash
openapi-generator-cli validate -i blossom/blossom.yaml
openapi-generator-cli validate -i nip96/nip96.yaml
```

**What it checks:**
- ✅ OpenAPI spec structure
- ✅ Path parameter consistency
- ✅ Response schema validity
- ⚠️ Warnings for best practices

### 3. Spectral Linting (Alternative Advanced Linting)

**Install:**
```bash
npm install -g @stoplight/spectral-cli
```

**Lint:**
```bash
# Spectral provides different rules than Redocly
spectral lint blossom/blossom.yaml
spectral lint nip96/nip96.yaml
```

**What it checks:**
- ✅ OpenAPI best practices
- ✅ Consistency rules
- ✅ Documentation completeness
- ✅ Naming conventions
- ⚠️ Style warnings

**Note:** Redocly CLI now provides similar functionality with better performance and is actively maintained.

### 4. Code Generation Test

**Most practical validation** - if code generates, spec is valid:

```bash
# Go server
npm run generate:go-blossom
npm run generate:go-nip96

# TypeScript client
npm run generate:ts-blossom
npm run generate:ts-nip96
```

**Other languages:**
```bash
# Python
openapi-generator-cli generate -i blossom/blossom.yaml -g python -o generated/python/blossom

# Rust
openapi-generator-cli generate -i blossom/blossom.yaml -g rust-server -o generated/rust/blossom

# Java
openapi-generator-cli generate -i blossom/blossom.yaml -g spring -o generated/java/blossom

# See all generators
openapi-generator-cli list
```

---

## Online Validation

### Swagger Editor (Best for Quick Testing)
1. Go to https://editor.swagger.io/
2. **File → Import File**
3. Select `blossom/blossom.yaml` or `nip96/nip96.yaml`
4. See instant validation results in the UI
5. View interactive API documentation

**Pros:**
- ✅ No installation needed
- ✅ Instant validation
- ✅ Interactive preview
- ✅ Try endpoints with mock data

### Redocly Playground
- https://redocly.com/docs/
- Visual API documentation
- Advanced linting rules

### OpenAPI.tools
- https://openapi.tools/
- Collection of validators and tools

---

## Automated Testing Script

The `validate.sh` script runs multiple validators:

```bash
./validate.sh
```

**What it does:**
1. ✅ Validates with `swagger-cli`
2. ✅ Validates with `openapi-generator-cli`
3. ✅ Tests code generation (Go)
4. ✅ Reports results with color coding

**Exit codes:**
- `0` = All tests passed
- `1` = Validation failed

---

## Common Validation Errors

### 1. Invalid $ref
```yaml
# ❌ Wrong
$ref: '#/components/schemas/BlobDescriptor'

# ✅ Correct
$ref: '#/components/schemas/BlobDescriptor'
```

**Fix:** Ensure referenced schema exists in `components.schemas`

### 2. Missing Required Fields
```yaml
# ❌ Missing required fields in schema
properties:
  url:
    type: string

# ✅ Include required array
required:
  - url
properties:
  url:
    type: string
```

### 3. Path Parameter Mismatch
```yaml
# ❌ Parameter not in path
paths:
  /users/{id}:
    get:
      parameters:
        - name: userId  # Should be 'id'

# ✅ Matching names
paths:
  /users/{id}:
    get:
      parameters:
        - name: id
```

### 4. Invalid Schema Type
```yaml
# ❌ Invalid type
type: number
pattern: '^[0-9]+$'  # Regex only works with string

# ✅ Correct
type: string
pattern: '^[0-9]+$'
```

### 5. Circular $ref
```yaml
# ❌ Schema references itself
components:
  schemas:
    Node:
      properties:
        children:
          type: array
          items:
            $ref: '#/components/schemas/Node'  # Circular

# ✅ Use allOf or description to break cycle
```

---

## Protocol-Specific Testing

### Blossom Authorization (kind 24242)

**Test event structure:**
```json
{
  "kind": 24242,
  "pubkey": "abc123...",
  "created_at": 1702389123,
  "tags": [
    ["t", "upload"],
    ["x", "b1674191a88ec5cdd733e4240a81803105dc412d6c6708d53ab94fc248f4f553"],
    ["expiration", "1702475523"]
  ],
  "content": "Upload blob",
  "sig": "..."
}
```

**Validate:**
1. ✅ `kind` is 24242
2. ✅ `t` tag present with valid verb
3. ✅ `x` tag matches blob hash
4. ✅ `expiration` tag is in future
5. ✅ Valid nostr signature

### NIP-96 Authorization (kind 27235)

**Test event structure:**
```json
{
  "kind": 27235,
  "pubkey": "abc123...",
  "created_at": 1702389123,
  "tags": [
    ["u", "https://server.com/upload"],
    ["method", "POST"],
    ["payload", "abc123..."]
  ],
  "content": "",
  "sig": "..."
}
```

**Validate:**
1. ✅ `kind` is 27235
2. ✅ `u` tag matches request URL exactly
3. ✅ `method` tag matches HTTP method
4. ✅ `payload` tag (if present) matches SHA256(body)
5. ✅ `created_at` within time window (60s)

---

## CI/CD Integration

### GitHub Actions

Create `.github/workflows/validate.yml`:

```yaml
name: Validate OpenAPI Specs

on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install dependencies
        run: npm install
      
      - name: Validate Blossom
        run: npm run validate:blossom
      
      - name: Validate NIP-96
        run: npm run validate:nip96
      
      - name: Test code generation
        run: |
          npm run generate:go-blossom
          npm run generate:go-nip96
```

### GitLab CI

Create `.gitlab-ci.yml`:

```yaml
validate:
  image: node:18
  script:
    - npm install
    - npm run validate
    - npm run generate:go-blossom
    - npm run generate:go-nip96
```

---

## Manual Testing Checklist

### Both Specs
- [ ] YAML syntax is valid
- [ ] All $ref references resolve
- [ ] No circular dependencies
- [ ] All required fields present
- [ ] Response codes documented
- [ ] Security schemes defined
- [ ] Examples provided

### Blossom Specific
- [ ] NostrAuth security scheme uses `Nostr` scheme
- [ ] BlobDescriptor schema complete
- [ ] All endpoints have CORS headers
- [ ] X-Reason headers on errors
- [ ] File extensions in path parameters
- [ ] Payment 402 responses where applicable
- [ ] Optional endpoints (media, report) included

### NIP-96 Specific
- [ ] Nip98Auth uses `Nostr` scheme (not JWT)
- [ ] Nip94Event schema matches NIP-94
- [ ] All form fields present (including size, content_type, no_transform)
- [ ] Discovery endpoint (/.well-known/nostr/nip96.json)
- [ ] ServerInfo schema complete
- [ ] Processing status endpoint (202/201)
- [ ] List endpoint at root with query params

---

## Troubleshooting

### redocly not found
```bash
npm install -g @redocly/cli
# Or use npx
npx @redocly/cli lint blossom/blossom.yaml
```

### openapi-generator-cli not found
```bash
npm install -g @openapitools/openapi-generator-cli
# Or use npx
npx @openapitools/openapi-generator-cli validate -i blossom/blossom.yaml
```

### spectral not found
```bash
npm install -g @stoplight/spectral-cli
# Or use npx
npx @stoplight/spectral-cli lint blossom/blossom.yaml
```

### Permission denied on validate.sh
```bash
chmod +x validate.sh
```

### YAML parse errors
- Check indentation (use spaces, not tabs)
- Validate basic YAML syntax: https://www.yamllint.com/
- Use VS Code YAML extension for real-time validation

---

## VS Code Integration

### Recommended Extensions

1. **OpenAPI (Swagger) Editor**
   - Extension ID: `42Crunch.vscode-openapi`
   - Real-time validation
   - IntelliSense

2. **YAML**
   - Extension ID: `redhat.vscode-yaml`
   - YAML syntax validation
   - Schema validation

3. **REST Client**
   - Extension ID: `humao.rest-client`
   - Test endpoints directly in VS Code

### Settings

Add to `.vscode/settings.json`:

```json
{
  "yaml.schemas": {
    "https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.0/schema.json": [
      "blossom/*.yaml",
      "nip96/*.yaml"
    ]
  },
  "openapi.validate": true,
  "openapi.lint": true
}
```

---

## What Gets Validated

| Tool | YAML Syntax | OpenAPI Schema | Best Practices | Code Gen | Maintained |
|------|-------------|----------------|----------------|----------|------------|
| redocly | ✅ | ✅ | ✅ | ❌ | ✅ Active |
| openapi-generator | ✅ | ✅ | ⚠️ | ✅ | ✅ Active |
| spectral | ✅ | ✅ | ✅ | ❌ | ✅ Active |
| Online editors | ✅ | ✅ | ✅ | ⚠️ | N/A |

**Recommendation:** Use Redocly CLI for validation + OpenAPI Generator for code generation testing.

---

## Next Steps After Validation

1. ✅ **Generate code** in your target language
2. ✅ **Test authorization** with real Nostr events
3. ✅ **Deploy test server** and verify endpoints
4. ✅ **Run integration tests** with clients
5. ✅ **Document any implementation quirks**

---

## Resources

- [OpenAPI Specification](https://spec.openapis.org/oas/v3.0.3)
- [Swagger Tools](https://swagger.io/tools/)
- [OpenAPI Generator Docs](https://openapi-generator.tech/docs/usage)
- [Spectral Documentation](https://meta.stoplight.io/docs/spectral/)
- [Blossom Protocol](https://github.com/hzrd149/blossom)
- [NIP-96](https://github.com/nostr-protocol/nips/blob/master/96.md)
- [NIP-98](https://github.com/nostr-protocol/nips/blob/master/98.md)
