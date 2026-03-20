#!/usr/bin/env bash
set -e

echo "=== Podman Validation ==="

echo "1. Checking version..."
podman --version

echo "2. Checking machine state..."
podman machine ls
STATE=$(podman machine ls --format '{{.State}}' | head -1)
if [[ "$STATE" != "Running" ]]; then
  echo "ERROR: Machine not running (state: $STATE)"
  exit 1
fi

echo "3. Running hello-world test..."
podman run --rm hello-world

echo "4. Checking container listing..."
podman ps

echo "=== All checks passed ==="
