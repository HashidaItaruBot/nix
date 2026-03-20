# Technology Stack

**Project:** v1.3 Podman + OpenHands on macOS
**Researched:** 2026-03-20

## Recommended Stack

### Core Runtime

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| **Podman** | 5.x (via Homebrew) | Container runtime | Officially supported on macOS, Docker API compatible, no daemon required |
| **Podman Machine VM** | bundled | macOS VM backend | Podman on macOS requires a Linux VM; `podman machine init` + `podman machine start` |
| **OpenHands** | ghcr.io/openhands/openhands:latest | AI agent container | Official image, actively maintained, MIT licensed |
| **litellm** | 1.80.0 (nixpkgs) | LLM abstraction | Optional standalone proxy for multi-LLM routing, supports 100+ providers |

### Supporting Tools

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `podman-desktop` | 1.23.1 | GUI management | Optional - for visual container/Kubernetes management |
| `cockpit-podman` | 122 | Web UI | Optional - if you prefer Cockpit web interface |

## Installation

### Option A: Homebrew (Recommended for macOS)

```bash
# Core Podman
brew install podman

# Initialize and start the VM (required on macOS)
podman machine init
podman machine start

# Verify
podman info
```

### Option B: Nix (Alternative)

```nix
# darwin/packages/default.nix
{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    podman      # Container runtime
    podlet      # Optional: generate Quadlet files from compose/dockerfile
  ];
}
```

**Note:** Podman via Nix on Darwin requires the Podman machine VM to be initialized separately.

### OpenHands Container Run Command

```bash
# Basic run with Podman
podman run -it --rm \
  -p 3000:3000 \
  -v ~/.openhands:/.openhands \
  -v ${PWD}/workspace:/opt/workspace_base \
  -e LLM_MODEL="anthropic/claude-3-7-sonnet-20250219" \
  -e LLM_API_KEY="${ANTHROPIC_API_KEY}" \
  ghcr.io/openhands/openhands:latest
```

### Using docker-compose (Podman compatible)

```yaml
# compose.yaml
services:
  openhands:
    image: ghcr.io/openhands/openhands:latest
    container_name: openhands-app
    environment:
      - LLM_MODEL=anthropic/claude-3-7-sonnet-20250219
      - LLM_API_KEY=${ANTHROPIC_API_KEY}
      - WORKSPACE_BASE=/opt/workspace_base
    ports:
      - "3000:3000"
    volumes:
      - ~/.openhands:/.openhands
      - ./workspace:/opt/workspace_base
    extra_hosts:
      - "host.docker.internal:host-gateway"
```

```bash
podman compose up -d
```

## Environment Variables

### Required LLM Configuration

| Variable | Example | Description |
|----------|---------|-------------|
| `LLM_MODEL` | `anthropic/claude-3-7-sonnet-20250219` | Model identifier (litellm format) |
| `LLM_API_KEY` | `sk-...` | API key for the LLM provider |
| `LLM_BASE_URL` | `https://api.anthropic.com` | Custom API endpoint (optional) |
| `LLM_API_VERSION` | `2024-01-01` | API version (for Azure) |

### Aliyun Bailian (Qwen/Kimi) via litellm

```bash
# For Qwen (Alibaba Cloud)
export LLM_MODEL="together_ai/Qwen/Qwen2.5-72B-Instruct"
export LLM_BASE_URL="https://dashscope.aliyuncs.com/compatible-mode/v1"
export LLM_API_KEY="${DASHSCOPE_API_KEY}"

# Or using litellm proxy directly
export LLM_MODEL="litellm_proxy/qwen-max"
```

### Sandbox Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `SANDBOX_USER_ID` | `0` (root) | User ID inside sandbox |
| `WORKSPACE_BASE` | `./workspace` | Host workspace path |
| `WORKSPACE_MOUNT_PATH_IN_SANDBOX` | `/opt/workspace_base` | Mount path in container |

### File Store

| Variable | Default | Description |
|----------|---------|-------------|
| `FILE_STORE` | `local` | Storage backend |
| `FILE_STORE_PATH` | `~/.openhands` | Local storage path |

## Volume Management

### Required Volumes

```bash
# Persistence for conversations and settings
-v ~/.openhands:/.openhands

# Workspace for agent to work on
-v ./workspace:/opt/workspace_base
```

### Volume Permissions

Podman on macOS runs containers in a VM. The default `SANDBOX_USER_ID=0` (root) works for most cases. If you need non-root:

```bash
# Set specific user ID
-e SANDBOX_USER_ID=1000
# Ensure ~/.openhands is readable/writable by UID 1000
```

## Network/Port Configuration

| Port | Protocol | Purpose |
|------|----------|---------|
| `3000` | HTTP | Web UI (React SPA) |
| `3001` | HTTP | WebSocket (real-time updates) |

### Accessing the UI

After starting the container:
- Open `http://localhost:3000` in your browser
- WebSocket connects automatically to `ws://localhost:3001`

### Extra Hosts Configuration

For container-to-host communication (e.g., Docker socket, local API):

```yaml
extra_hosts:
  - "host.docker.internal:host-gateway"
```

This enables `SANDBOX_LOCAL_RUNTIME_URL=http://host.docker.internal`

## litellm Proxy Integration (Optional)

For advanced LLM routing (e.g., Aliyun Bailian + fallback providers):

### Installation via Nix

```nix
# darwin/packages/default.nix
{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    litellm  # v1.80.0
  ];
}
```

### litellm Configuration

```yaml
# litellm_config.yaml
model_list:
  - model_name: "qwen-max"
    litellm_params:
      model: "together_ai/Qwen/Qwen2.5-72B-Instruct"
      api_key: "os.environ/DASHSCOPE_API_KEY"
      api_base: "https://dashscope.aliyuncs.com/compatible-mode/v1"

  - model_name: "kimi-k2-5"
    litellm_params:
      model: "together_ai/moonshotai/Kimi-K2-Instruct"
      api_key: "os.environ/MOONSHOT_API_KEY"
```

```bash
# Run litellm proxy
litellm --config litellm_config.yaml --port 4000
```

Then configure OpenHands:
```bash
-e LLM_MODEL="litellm_proxy/qwen-max"
-e LLM_BASE_URL="http://host.docker.internal:4000"
```

## Alternatives Considered

| Category | Recommended | Alternative | Why Not |
|----------|-------------|-------------|---------|
| Container Runtime | Podman | Docker Desktop | Docker Desktop requires subscription for large companies; Podman is daemonless and lighter |
| Container Runtime | Podman | OrbStack | OrbStack is paid for commercial use; Podman is fully open source |
| LLM Layer | litellm (standalone) | Direct API | litellm provides unified interface + routing + retries |
| Image Source | ghcr.io/openhands | docker.io/openhands | ghcr.io is primary; docker.io may be mirror/slower |

## Sources

- [Podman Installation Documentation](https://podman.io/docs/installation)
- [OpenHands GitHub Repository](https://github.com/All-Hands-AI/OpenHands)
- [OpenHands docker-compose.yml](https://github.com/All-Hands-AI/OpenHands/blob/main/docker-compose.yml)
- [litellm in nixpkgs](https://search.nixos.org/packages?channel=unstable&show=litellm)
- [OpenHands LLM Configuration (legacy)](https://github.com/All-Hands-AI/OpenHands/blob/main/openhands/core/config/llm_config.py)
- [OpenHands Sandbox Configuration](https://github.com/All-Hands-AI/OpenHands/blob/main/openhands/core/config/sandbox_config.py)
