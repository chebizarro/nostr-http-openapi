# Nostr HTTP Server Endpoints

This repository contains OpenAPI specifications for various Nostr-related HTTP server endpoints, including:

1. **Nostr File Storage API**: A file storage API that complies with NIP-96 and NIP-98, allowing for file uploads, downloads, and auth management through the Nostr protocol.
2. **Blossom API**: A simple server that allows storing and retrieving blobs of data on publicly accessible servers via the Blossom protocol.

The Go code for both of these APIs can be generated using the **OpenAPI v3** specification files provided in this repository.

## Requirements

Before you begin, ensure you have the following tools installed:

- **Go**: [Install Go](https://golang.org/doc/install) if you haven't already.
- **ogen-go**: A Go code generator for OpenAPI v3 specs. You can install it by running:
  
  ```bash
  go install github.com/ogen-go/ogen/cmd/ogen@latest
  ```

## Structure of the Repository

```
.
├── nip96/nip96.yaml        # OpenAPI v3 spec for the Nostr File Storage API
├── blossom/blossom.yaml    # OpenAPI v3 spec for the Blossom API
└── README.md               # This README file
```

## How to Generate Go Code

You can use **ogen-go** to generate Go code from the OpenAPI YAML files. Follow the instructions below to generate Go code for each API.

### 1. Generate Go Code for the **Nostr File Storage API**

The OpenAPI specification for the **Nostr File Storage API** is defined in `nostr-file-storage.yaml`. To generate Go server code for this API:

1. **Navigate to the repository root**:

   ```bash
   cd /path/to/repo
   ```

2. **Run the ogen-go code generator**:

   ```bash
   ogen --target api/nip96 --package nip96 nip96.yaml
   ```

   This command will:
   - **Generate** Go types and handler interfaces in the `api/nostrfilestorage/` directory.
   - **Set the package name** to `nostrfilestorage` for the generated code.

3. **Implement the Handler**:

   Once the code is generated, implement the `Handler` interface defined in the generated code. Example:

   ```go
   func (h *HandlerImpl) UploadPut(ctx context.Context, req UploadPutReq) (UploadPutRes, error) {
       // Logic for handling file upload
   }
   ```

4. **Start the Server**:

   After implementing the required handlers, start the HTTP server using the generated router and your handler implementation.

### 2. Generate Go Code for the **Blossom API**

The OpenAPI specification for the **Blossom API** is defined in `blossom.yaml`. To generate Go server code for this API:

1. **Navigate to the repository root**:

   ```bash
   cd /path/to/repo
   ```

2. **Run the ogen-go code generator**:

   ```bash
   ogen --target api --package blossom blossom/blossom.yaml
   ```

   This command will:
   - **Generate** Go types and handler interfaces in the `api/blossom/` directory.
   - **Set the package name** to `blossom` for the generated code.

3. **Implement the Handler**:

   Implement the generated `Handler` interface for the Blossom API. For example:

   ```go
   func (h *HandlerImpl) UploadPut(ctx context.Context, req UploadPutReq) (UploadPutRes, error) {
       // Logic for handling blob upload
   }
   ```

4. **Start the Server**:

   Once you have implemented the handler logic, you can start the server by initializing the router with your handler.

### 3. Integrating with Nostr

Both APIs are designed to work in compliance with Nostr’s decentralized protocol. To ensure full NIP-96 and NIP-98 compliance for the Nostr File Storage API, refer to the `.well-known/nostr/nip96.json` endpoint and implement logic for content delegation and relays as per the NIPs.

### Notes on Code Structure

The generated Go code will follow the pattern:

- **`openapi_types.go`**: Contains Go types, structs, and interfaces for request and response bodies as defined in the OpenAPI spec.
- **`handler.go`**: Defines the `Handler` interface that must be implemented with your business logic.
- **`router.go`**: Provides a router that maps API endpoints to the corresponding handler functions.

### Additional Configuration

You can customize the server configurations (such as ports, logging, etc.) by setting environment variables or using configuration files in your implementation.

### Example Directory Layout After Code Generation

```bash
.
├── api/
│   ├── nip96/
│   │   ├── openapi_types.go      # Generated Go types for Nostr File Storage API
│   │   ├── handler.go            # Generated Handler interface for Nostr File Storage API
│   ├── blossom/
│   │   ├── openapi_types.go      # Generated Go types for Blossom API
│   │   ├── handler.go            # Generated Handler interface for Blossom API
├── nip96/nip96.yaml       # OpenAPI v3 spec for Nostr File Storage API
├── blossom/blossom.yaml                  # OpenAPI v3 spec for Blossom API
└── README.md                     # This README file
```

## Running the Server

Once you have implemented the handler methods, you can start the server with Go's built-in HTTP server, or use a more advanced HTTP framework as per your needs.

```go
package main

import (
    "log"
    "net/http"
    "yourrepo/api/nostrfilestorage"
)

func main() {
    handler := &nostrfilestorage.HandlerImpl{}
    router := nostrfilestorage.NewRouter(handler)

    log.Println("Starting server on :8080")
    log.Fatal(http.ListenAndServe(":8080", router))
}
```

For the Blossom API, follow a similar pattern using the generated `blossom` package.
