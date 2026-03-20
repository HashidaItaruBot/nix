#!/usr/bin/env bash
set -e

echo "=== Podman Machine Initialization ==="

# 检查 machine 是否已存在
if podman machine ls 2>/dev/null | grep -q "podman.*Running"; then
  echo "Machine already running, nothing to do"
  exit 0
fi

# 如果 machine 存在但未运行，启动它
if podman machine ls 2>/dev/null | grep -q "podman"; then
  echo "Starting existing machine..."
  podman machine start
  exit 0
fi

# 首次初始化，带资源配置
echo "Initializing Podman machine with 8GB RAM, 4 CPUs..."
podman machine init --cpus 4 --memory 8192 --disk-size 100

echo "Starting machine..."
podman machine start

echo "=== Initialization complete ==="
