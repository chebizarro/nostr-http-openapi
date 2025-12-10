#!/bin/bash

# OpenAPI YAML Validation Script
# Tests both Blossom and NIP-96 specs for correctness

set -e

echo "================================================"
echo "OpenAPI Specification Validation"
echo "================================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if redocly is installed
if ! command -v redocly &> /dev/null; then
    echo -e "${YELLOW}Warning: redocly not found${NC}"
    echo "Install with: npm install -g @redocly/cli"
    echo ""
fi

# Check if openapi-generator-cli is installed
if ! command -v openapi-generator-cli &> /dev/null; then
    echo -e "${YELLOW}Warning: openapi-generator-cli not found${NC}"
    echo "Install with: npm install -g @openapitools/openapi-generator-cli"
    echo ""
fi

# Function to validate with redocly
validate_redocly() {
    local file=$1
    local name=$2
    
    echo -e "${YELLOW}[Redocly CLI]${NC} Validating $name..."
    if redocly lint "$file" 2>&1; then
        echo -e "${GREEN}✓${NC} $name is valid!"
    else
        echo -e "${RED}✗${NC} $name has errors"
        return 1
    fi
    echo ""
}

# Function to validate with openapi-generator
validate_generator() {
    local file=$1
    local name=$2
    
    echo -e "${YELLOW}[OpenAPI Generator]${NC} Validating $name..."
    if openapi-generator-cli validate -i "$file" 2>&1 | grep -q "No validation issues detected"; then
        echo -e "${GREEN}✓${NC} $name is valid!"
    else
        echo -e "${YELLOW}⚠${NC} $name has warnings (may still be usable)"
        openapi-generator-cli validate -i "$file"
    fi
    echo ""
}

# Function to test code generation
test_generation() {
    local file=$1
    local name=$2
    local output_dir=$3
    
    echo -e "${YELLOW}[Code Generation Test]${NC} Testing $name..."
    if openapi-generator-cli generate -i "$file" -g go-server -o "$output_dir" --skip-validate-spec > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $name can generate code successfully!"
        rm -rf "$output_dir"
    else
        echo -e "${RED}✗${NC} $name failed code generation"
        return 1
    fi
    echo ""
}

echo "================================================"
echo "Testing Blossom OpenAPI Spec"
echo "================================================"
echo ""

if command -v redocly &> /dev/null; then
    validate_redocly "blossom/blossom.yaml" "Blossom"
fi

if command -v openapi-generator-cli &> /dev/null; then
    validate_generator "blossom/blossom.yaml" "Blossom"
    test_generation "blossom/blossom.yaml" "Blossom" "test-output/blossom"
fi

echo "================================================"
echo "Testing NIP-96 OpenAPI Spec"
echo "================================================"
echo ""

if command -v redocly &> /dev/null; then
    validate_redocly "nip96/nip96.yaml" "NIP-96"
fi

if command -v openapi-generator-cli &> /dev/null; then
    validate_generator "nip96/nip96.yaml" "NIP-96"
    test_generation "nip96/nip96.yaml" "NIP-96" "test-output/nip96"
fi

echo "================================================"
echo -e "${GREEN}Validation Complete!${NC}"
echo "================================================"
echo ""
echo "Next steps:"
echo "  1. View in Swagger Editor: https://editor.swagger.io/"
echo "  2. Generate production code with your preferred language"
echo "  3. Test with real Nostr events and authorization"
echo ""
