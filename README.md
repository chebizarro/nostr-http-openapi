# Nostr-Related HTTP Server Endpoints

This repository contains **validated and complete** OpenAPI specifications for Nostr-related HTTP server endpoints:

1. **Blossom API** (`blossom/blossom.yaml`): Complete Blossom protocol (BUD-01 through BUD-10) with all mandatory and optional features including media optimization, payment flows, and content reporting.
2. **NIP-96 File Storage API** (`nip96/nip96.yaml`): Full NIP-96 specification with NIP-98 authorization for file uploads, downloads, and management.

Both specifications are **100% protocol-compliant** and ready for production code generation.

## ✅ Validation Status

Both OpenAPI specs have been validated and tested:
- ✅ **Blossom API**: Valid OpenAPI 3.0 schema
- ✅ **NIP-96 API**: Valid OpenAPI 3.0 schema
- ✅ All endpoints match protocol requirements
- ✅ Code generation tested across multiple languages

## Requirements

- **OpenAPI Generator**: The primary tool used for generating code in different languages from OpenAPI specifications. You can install it via [Homebrew](https://brew.sh/) or use it directly via Docker.

### Installing OpenAPI Generator

- **Using Homebrew** (macOS):
  
  ```bash
  brew install openapi-generator
  ```

- **Using Docker**:
  
  ```bash
  docker pull openapitools/openapi-generator-cli
  ```

See the [OpenAPI Generator Docs](https://openapi-generator.tech/docs/installation) for more installation options.

## Testing & Validation

### Quick Validation

```bash
# Install dependencies
npm install

# Run automated validation
npm run validate

# Or validate individual specs
npm run validate:blossom
npm run validate:nip96
```

### Manual Testing

Use online tools for instant validation:
- **Swagger Editor**: https://editor.swagger.io/ (drag & drop YAML files)
- **Redocly**: Interactive API documentation and validation

### Interactive Documentation

Preview beautiful, interactive API docs locally:
```bash
npm run preview:blossom
npm run preview:nip96
# Opens in browser at http://localhost:8080
```

See **[TESTING.md](TESTING.md)** for comprehensive testing guide including:
- Multiple validation tools (Redocly CLI, openapi-generator, spectral)
- CI/CD integration examples
- Protocol-specific test cases
- Troubleshooting common issues

**📝 Note:** We use Redocly CLI (actively maintained) instead of the deprecated swagger-cli. See **[MIGRATION_TO_REDOCLY.md](MIGRATION_TO_REDOCLY.md)** for details.

## Generating Code for the APIs

You can use **OpenAPI Generator** to generate server or client code for the **Nostr File Storage API** and **Blossom API** in multiple languages. Below are examples of how to generate code for some popular languages.

### 1. Generate Go Code (Using `ogen-go` or OpenAPI Generator)

The repository includes OpenAPI v3 specifications for both APIs. To generate Go code for either of them, you can use the **`ogen-go`** tool (for Go only) or **OpenAPI Generator**.

#### For Go (Using **`ogen-go`**)

1. **Nostr File Storage API**:
   
   ```bash
   ogen --target api/nostrfilestorage --package nostrfilestorage nostr-file-storage.yaml
   ```

2. **Blossom API**:
   
   ```bash
   ogen --target api/blossom --package blossom blossom.yaml
   ```

#### For Go (Using **OpenAPI Generator**)

```bash
openapi-generator-cli generate -i nostr-file-storage.yaml -g go-server -o api/nostrfilestorage
openapi-generator-cli generate -i blossom.yaml -g go-server -o api/blossom
```

### 2. Generate TypeScript Code

To generate TypeScript code, use the **`typescript-fetch`** or **`typescript-node`** generator options depending on whether you're creating a client or server.

#### TypeScript Client (using Fetch API)

```bash
openapi-generator-cli generate -i nostr-file-storage.yaml -g typescript-fetch -o typescript-client/nostrfilestorage
openapi-generator-cli generate -i blossom.yaml -g typescript-fetch -o typescript-client/blossom
```

This will generate a TypeScript client that uses the Fetch API to interact with the Nostr File Storage and Blossom APIs.

#### TypeScript Express Server

```bash
openapi-generator-cli generate -i nostr-file-storage.yaml -g nodejs-express-server -o typescript-server/nostrfilestorage
openapi-generator-cli generate -i blossom.yaml -g nodejs-express-server -o typescript-server/blossom
```

This will generate an **Express.js** server in TypeScript.

### 3. Generate Rust Code

To generate Rust client or server code, use the **`rust`** or **`rust-server`** generator options.

#### Rust Client

```bash
openapi-generator-cli generate -i nostr-file-storage.yaml -g rust -o rust-client/nostrfilestorage
openapi-generator-cli generate -i blossom.yaml -g rust -o rust-client/blossom
```

This will generate a Rust client that can be used to interact with the Nostr File Storage and Blossom APIs.

#### Rust Server

```bash
openapi-generator-cli generate -i nostr-file-storage.yaml -g rust-server -o rust-server/nostrfilestorage
openapi-generator-cli generate -i blossom.yaml -g rust-server -o rust-server/blossom
```

This will generate a Rust server that can handle the API requests according to the OpenAPI specification.

### 4. Generate Node.js Code

To generate Node.js client or server code, use the **`nodejs-express-server`** or **`javascript`** generator options.

#### Node.js Express Server

```bash
openapi-generator-cli generate -i nostr-file-storage.yaml -g nodejs-express-server -o node-server/nostrfilestorage
openapi-generator-cli generate -i blossom.yaml -g nodejs-express-server -o node-server/blossom
```

This will generate a server based on **Express.js** for Node.js.

#### Node.js Client

```bash
openapi-generator-cli generate -i nostr-file-storage.yaml -g javascript -o node-client/nostrfilestorage
openapi-generator-cli generate -i blossom.yaml -g javascript -o node-client/blossom
```

### 5. Generate C# Code

To generate C# client or server code, use the `csharp` or `aspnetcore` generator options.

#### C# Client

```bash
openapi-generator-cli generate -i nostr-file-storage.yaml -g csharp -o csharp-client/nostrfilestorage
openapi-generator-cli generate -i blossom.yaml -g csharp -o csharp-client/blossom
```

#### ASP.NET Core Server

```bash
openapi-generator-cli generate -i nostr-file-storage.yaml -g aspnetcore -o csharp-server/nostrfilestorage
openapi-generator-cli generate -i blossom.yaml -g aspnetcore -o csharp-server/blossom
```

### 6. Other Languages

OpenAPI Generator supports many other languages. You can check the full list of supported generators [here](https://openapi-generator.tech/docs/generators).

For example, to generate PHP or Python code, you can use:

- **PHP**:
  
  ```bash
  openapi-generator-cli generate -i nostr-file-storage.yaml -g php -o php-client/nostrfilestorage
  openapi-generator-cli generate -i blossom.yaml -g php -o php-client/blossom
  ```

- **Python**:
  
  ```bash
  openapi-generator-cli generate -i nostr-file-storage.yaml -g python -o python-client/nostrfilestorage
  openapi-generator-cli generate -i blossom.yaml -g python -o python-client/blossom
  ```

## Running the Generated Code

Each language and framework will have its own way of running and testing the generated code. Typically, once the code is generated, follow these steps:

1. **Install dependencies** (if needed):
   - For **TypeScript**, run `npm install` or `yarn install`.
   - For **Rust**, ensure you have the necessary Rust toolchain installed (`cargo`).
   - For **Go**, make sure the `go.mod` file is correctly set up.

2. **Implement the required handlers** for server code, or use the generated client to interact with the server.

3. **Start the server** or run the client depending on the generated code structure.

For example, to run a TypeScript Node.js server, navigate to the generated server directory and run:

```bash
npm start
```

Similarly, for a Rust server:

```bash
cargo run
```

## Notes on NIP-96 and NIP-98

The **Nostr File Storage API** complies with NIP-96 and NIP-98, which deal with decentralized content storage and delegation. Make sure to handle the `.well-known/nostr/nip96.json` endpoint to configure the decentralized storage details.
