# Architecture Patterns: OpenHands on macOS with Podman

**Domain:** Container-based AI development environment
**Researched:** 2026-03-20

## Recommended Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      macOS Host                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Podman Machine VM (Linux)              │   │
│  │  ┌──────────────────┐  ┌─────────────────────────┐  │   │
│  │  │  OpenHands       │  │  Sandbox Runtime        │  │   │
│  │  │  Container       │  │  Container              │  │   │
│  │  │  - Port 3000    │  │  - User code execution  │  │   │
│  │  │  - WebSocket    │  │  - File operations      │  │   │
│  │  │  - REST API     │  │  - Shell commands       │  │   │
│  │  └────────┬─────────┘  └───────────┬─────────────┘  │   │
│  │           │                        │                 │   │
│  │           └──────────┬─────────────┘                 │   │
│  │                      │                               │   │
│  │           ┌──────────▼───────────┐                   │   │
│  │           │  Podman Network      │                   │   │
│  │           │  (NAT to host)       │                   │   │
│  │           └──────────┬───────────┘                   │   │
│  └──────────────────────┼───────────────────────────────┘   │
│                          │                                   │
│  ┌───────────────────────▼──────────────────────────────┐   │
│  │  Volume Mounts                                       │   │
│  │  - ~/.openhands → /:openhands (persistence)         │   │
│  │  - ./workspace → /opt/workspace_base (work files)   │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
              ┌─────────────────────────┐
              │  External LLM APIs      │
              │  - Aliyun DashScope     │
              │  - Anthropic            │
              │  - OpenAI               │
              └─────────────────────────┘
```

## Component Boundaries

| Component | Responsibility | Communicates With |
|-----------|---------------|-------------------|
| **Podman Machine VM** | Linux environment for containers | macOS host (via virtualization) |
| **OpenHands Container** | Main application server, agent logic, WebSocket handler | Sandbox Runtime, LLM APIs, Host volumes |
| **Sandbox Runtime Container** | Isolated code execution, file operations | OpenHands Container (internal network) |
| **Host macOS** | User interface (browser), file storage, API keys | Browser → OpenHands UI, Volume mounts |
| **External LLM APIs** | Language model inference | OpenHands Container (outbound HTTPS) |

## Data Flow

1. **User Input:** User types instruction in browser → WebSocket → OpenHands Container
2. **Agent Processing:** OpenHands agent processes instruction → generates action plan
3. **LLM Call:** OpenHands → HTTPS → External LLM API → returns completion
4. **Code Execution:** Agent sends code → Sandbox Runtime → executes → returns output
5. **File Operations:** Agent reads/writes → Host volume mount → files persist on macOS
6. **Response:** Agent output → WebSocket → Browser UI

## Patterns to Follow

### Pattern 1: Single Container for Simple Setup

**What:** Run OpenHands as a single container with built-in sandbox.

**When:** Development, personal use, single-user scenarios.

**Example:**
```bash
podman run -it --rm \
  -p 3000:3000 \
  -v ~/.openhands:/.openhands \
  -v ./workspace:/opt/workspace_base:Z \
  -e LLM_MODEL="alibaba/qwen-plus" \
  -e LLM_API_KEY="${DASHSCOPE_API_KEY}" \
  ghcr.io/openhands/openhands:latest
```

### Pattern 2: Pod for Multi-Container Architecture

**What:** Use Podman pod to group OpenHands + Sandbox Runtime containers.

**When:** Production-like setups, isolation requirements, multi-agent scenarios.

**Example:**
```bash
# Create pod with shared network
podman pod create -p 3000:3000 openhands-pod

# Run main OpenHands container
podman run --pod openhands-pod \
  -e SANDBOX_REMOTE_RUNTIME_API_URL="http://localhost:8000" \
  ... openhands:latest

# Run sandbox runtime separately
podman run --pod openhands-pod \
  -e WORKSPACE_BASE=/opt/workspace_base \
  ... sandbox-runtime:latest
```

### Pattern 3: litellm Proxy for Multi-LLM Routing

**What:** Run litellm as sidecar proxy for unified LLM interface.

**When:** Multiple LLM providers, fallback strategies, cost optimization.

**Example:**
```bash
# Run litellm proxy
podman run -p 4000:4000 \
  -v ./litellm_config.yaml:/app/config.yaml \
  ghcr.io/berriai/litellm:main-latest \
  --config /app/config.yaml

# Configure OpenHands to use litellm
-e LLM_MODEL="litellm_proxy/qwen-max"
-e LLM_BASE_URL="http://host.docker.internal:4000"
```

## Anti-Patterns to Avoid

### Anti-Pattern 1: Running Podman Without Machine VM

**What:** Attempting to run `podman run` without `podman machine start`.

**Why bad:** All operations fail with connection errors.

**Instead:**
```bash
# Always initialize and start machine first
podman machine init
podman machine start
podman machine ls  # Verify "Running" status
```

### Anti-Pattern 2: Hardcoding API Keys in Config Files

**What:** Storing `LLM_API_KEY` directly in compose files or config.

**Why bad:** Credentials in version control, no rotation mechanism.

**Instead:**
```bash
# Use environment variable substitution
-e LLM_API_KEY="${LLM_API_KEY}"

# Or use .env file (gitignored)
--env-file .env.local
```

### Anti-Pattern 3: Mounting Non-Shared Directories

**What:** Mounting paths outside `/Users` or `/home` on macOS.

**Why bad:** Podman VM cannot access these paths; mount fails.

**Instead:**
```bash
# Good - inside shared zone
-v /Users/username/project:/workspace:Z

# Bad - outside shared zone
-v /opt/project:/workspace:Z  # Will fail
```

### Anti-Pattern 4: Binding to localhost Instead of 0.0.0.0

**What:** Container binds to 127.0.0.1 instead of 0.0.0.0.

**Why bad:** Not accessible from macOS host due to NAT.

**Instead:**
- OpenHands defaults to `0.0.0.0` (correct)
- If customizing, ensure `HOST=0.0.0.0`

## Scalability Considerations

| Concern | At 1 user (default) | At 10 users (multi-agent) | At 100+ users (enterprise) |
|---------|---------------------|---------------------------|----------------------------|
| **Container** | Single OpenHands container | Multiple agent containers | Kubernetes cluster |
| **Memory** | 8GB Podman VM | 16-32GB Podman VM | Dedicated VM per agent |
| **Storage** | Local ~/.openhands | Shared NFS volume | Object storage (S3) |
| **LLM Access** | Direct API calls | litellm proxy with rate limiting | Enterprise LLM gateway |
| **Network** | NAT via podman machine | Bridge network | Service mesh |
| **Persistence** | Local file store | Database (PostgreSQL) | Distributed database |

## macOS-Specific Considerations

### Virtualization Layer

```
macOS (Darwin kernel)
    │
    ▼
Apple Hypervisor / Virtualization Framework
    │
    ▼
Podman Machine VM (Linux + systemd)
    │
    ▼
Podman Engine (rootless by default)
    │
    ▼
OpenHands Container
```

### Network Translation

| Layer | Network | Accessible From |
|-------|---------|-----------------|
| Container | 10.x.x.x/16 | Podman VM, sibling containers |
| Podman VM | 192.168.x.x | macOS host (NAT) |
| macOS Host | LAN IP | Local network |

### Volume Mount Path Requirements

```bash
# Must be under /Users or /home for automatic sharing
/Users/username/workspace  # ✓ Works
/Users/shared/project     # ✓ Works
/opt/workspace            # ✗ Requires manual sharing
/private/var/data         # ✗ Requires manual sharing
```

## Sources

- [Podman Architecture on macOS](https://podman.io/docs/overview)
- [OpenHands Container Structure](https://github.com/All-Hands-AI/OpenHands/blob/main/docker-compose.yml)
- [Podman Machine Documentation](https://podman.io/docs/podman-machine)
- [OpenHands Sandbox Architecture](https://github.com/All-Hands-AI/OpenHands/blob/main/openhands/core/config/sandbox_config.py)
