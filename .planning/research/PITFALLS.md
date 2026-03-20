# Domain Pitfalls: OpenHands with Podman on macOS

**Domain:** Container Development Environment on macOS
**Researched:** 2026-03-20
**Confidence:** MEDIUM (based on WebSearch patterns, official documentation gaps)

---

## Critical Pitfalls

These mistakes cause complete failures or require full reconfiguration.

### Pitfall 1: Using `podman run` Without Podman Machine

**What goes wrong:**
Podman on macOS requires a Linux VM (podman machine) to run containers. Users attempt to run containers directly without initializing and starting the VM first.

**Why it happens:**
- Docker Desktop auto-starts its backend; Podman does not
- `podman machine init` must be run manually after installation
- `podman machine start` must be running before any container operation

**Consequences:**
```bash
Error: cannot connect to Podman. Is podman machine running?
```
All container operations fail.

**Prevention:**
```bash
# Required setup sequence (one-time)
podman machine init
podman machine start

# Verify before running containers
podman machine ls  # Should show "Running"

# Before any container work, ensure machine is started
podman machine start
```

**Detection:**
Run `podman machine ls` — if not "Running", no container operations will work.

**Phase to address:** Phase 0 (Podman Installation & Setup)

---

### Pitfall 2: Volume Mount Path Mismatch on macOS

**What goes wrong:**
Podman on macOS runs containers inside a VM. When mounting host directories, the path must be accessible from the VM, not just from macOS.

**Why it happens:**
- Podman VM has limited shared directories (typically `/Users` or `/home`)
- Users mount paths outside shared zones (e.g., `/private/var`, `/opt`)
- OpenHands requires `WORKSPACE_BASE` to be accessible inside the container

**Consequences:**
```bash
Error: failed to mount volume: access denied
Container starts but cannot read workspace files
OpenHands agent reports "workspace not accessible"
```

**Prevention:**
```bash
# Good - inside shared zone
podman run -v /Users/username/projects/myapp:/workspace:z ...

# Bad - outside shared zone
podman run -v /opt/myapp:/workspace:z ...  # Will fail

# For OpenHands specifically
export WORKSPACE_BASE=/Users/username/my-project
podman run \
  -v "$WORKSPACE_BASE:/workspace:z" \
  -e WORKSPACE_BASE=/workspace \
  ghcr.io/all-hands-ai/openhands:latest
```

**Key requirements for OpenHands:**
- `WORKSPACE_BASE` must be absolute path
- Path must exist on host before mounting
- Use `:z` or `:Z` SELinux label for Podman (see Pitfall 4)

**Detection:**
```bash
# Test mount accessibility
podman run --rm -v /your/path:/test alpine ls -la /test
```

**Phase to address:** Phase 1 (OpenHands Container Definition)

---

### Pitfall 3: Port Binding — `localhost` vs `0.0.0.0` on macOS

**What goes wrong:**
Podman on macOS uses a VM with NAT. Containers binding to `localhost` (127.0.0.1) inside the VM are NOT accessible from macOS `localhost`.

**Why it happens:**
- OpenHands server binds to `0.0.0.0` by default (correct)
- Custom configurations may bind to `127.0.0.1`
- Podman machine uses NAT, not direct loopback

**Consequences:**
```bash
# Container is running
podman ps  # Shows container

# But cannot access from macOS browser
# http://localhost:3000 — Connection refused
```

**Prevention:**
Ensure OpenHands binds to `0.0.0.0`:
```bash
# Correct port mapping syntax
podman run -p 3000:3000 ...  # Maps all interfaces

# If using podman pod
podman pod create -p 3000:3000 openhands-pod
podman run --pod openhands-pod ...

# Verify binding inside container
podman exec -it <container> netstat -tlnp
# Should show 0.0.0.0:3000, NOT 127.0.0.1:3000
```

**OpenHands specific:**
- Default port: 3000 (web UI)
- Default bind: `0.0.0.0` (correct)
- If using custom config, ensure HOST=0.0.0.0

**Detection:**
```bash
# From macOS, test connectivity
curl -v http://localhost:3000

# Check podman machine network config
podman machine inspect | jq '.[0].HostUser.NetworkMode'
```

**Phase to address:** Phase 1 (OpenHands Container Definition)

---

### Pitfall 4: SELinux Label Omission on Volume Mounts

**What goes wrong:**
Podman enforces SELinux labeling on volume mounts. Without the `:z` or `:Z` suffix, containers cannot access mounted files.

**Why it happens:**
- Docker silently handles this; Podman requires explicit labels
- Documentation often omits SELinux labels in examples
- Error messages are cryptic ("permission denied" without context)

**Consequences:**
```bash
Error: OCI permission denied
Error: open /workspace/file.txt: permission denied
OpenHands agent cannot read or write workspace files
```

**Prevention:**
```bash
# Always use SELinux label for shared volumes
podman run -v /host/path:/container/path:z ...

# :z = shared content (multiple containers can access)
# :Z = private content (only this container can access)

# For OpenHands workspace (private to container)
podman run -v "$WORKSPACE_BASE:/workspace:Z" ...

# For shared configs (multiple containers)
podman run -v "$CONFIG_DIR:/config:z" ...
```

**Detection:**
```bash
# Check SELinux context on host directory
ls -Z /your/path

# If container logs show "permission denied" on mounted files
# SELinux label is likely missing
```

**Phase to address:** Phase 1 (OpenHands Container Definition)

---

### Pitfall 5: LLM API Configuration — Wrong Provider Name or Base URL

**What goes wrong:**
OpenHands requires specific provider identifiers. Aliyun DashScope (阿里百炼) must be configured with correct provider name, API key format, and base URL.

**Why it happens:**
- Provider names are case-sensitive (`alibaba`, `Alibaba`, `ALIYUN`?)
- Base URL format varies (`https://dashscope.aliyuncs.com` vs `https://dashscope.aliyun.com`)
- API key format confusion (DashScope uses `sk-` prefix keys)

**Consequences:**
```bash
LLM initialization failed
Error: Invalid provider: aliyun
Error: API authentication failed
OpenHands starts but cannot complete any tasks
```

**Prevention:**
```bash
# Correct OpenHands LLM configuration for Aliyun DashScope
export LLM_MODEL="alibaba/qwen-plus"  # or alibaba/qwen-turbo
export LLM_API_KEY="sk-xxxxxxxxxxxxx"  # DashScope API key
export LLM_BASE_URL="https://dashscope.aliyuncs.com/compatible-mode/v1"

# Alternative: config.toml format
cat > ~/.openhands/config.toml << EOF
[core]
llm_model = "alibaba/qwen-plus"
llm_api_key = "sk-xxxxxxxxxxxxx"
llm_base_url = "https://dashscope.aliyuncs.com/compatible-mode/v1"
EOF
```

**Valid Aliyun models in OpenHands:**
- `alibaba/qwen-plus` — General purpose
- `alibaba/qwen-turbo` — Faster, cheaper
- `alibaba/qwen-max` — Most capable

**Detection:**
```bash
# Test API key validity
curl -X POST https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions \
  -H "Authorization: Bearer sk-xxxxx" \
  -H "Content-Type: application/json" \
  -d '{"model":"qwen-plus","messages":[{"role":"user","content":"test"}]}'
```

**Phase to address:** Phase 2 (LLM Backend Configuration)

---

### Pitfall 6: Insufficient Podman Machine Resources

**What goes wrong:**
Default Podman machine settings (2GB RAM, 2 CPUs) are insufficient for OpenHands, which runs:
- Main OpenHands server
- Sandbox runtime container
- LLM API calls (memory for context)

**Why it happens:**
- `podman machine init` creates VM with minimal defaults
- OpenHands has no explicit resource requirements documented
- Container OOM (Out of Memory) kills the process silently

**Consequences:**
```bash
Container starts then immediately exits
podman ps shows container repeatedly restarting
Container logs show "OOMKilled" or memory errors
OpenHands agent times out during task execution
```

**Prevention:**
```bash
# Stop existing machine
podman machine stop

# Reinitialize with adequate resources
podman machine init --memory 8192 --cpus 4 --disk-size 100

# Or modify existing machine (Podman 4+)
podman machine set --memory 8192 --cpus 4

# Start with new settings
podman machine start

# Verify
podman machine inspect | jq '.[0].VMType, .[0].Memory, .[0].CPUs'
```

**Recommended minimum for OpenHands:**
- Memory: 8GB (4GB absolute minimum)
- CPUs: 4 (2 absolute minimum)
- Disk: 50GB+

**Detection:**
```bash
# Check if container was OOM killed
podman inspect <container> | jq '.[0].State.OOMKilled'

# Monitor machine resources
podman machine ssh top
```

**Phase to address:** Phase 0 (Podman Installation & Setup)

---

## Moderate Pitfalls

These cause partial failures or degraded functionality.

### Pitfall 7: Workspace Directory Does Not Exist Before Mount

**What goes wrong:**
Podman does not auto-create host directories for volume mounts. If `WORKSPACE_BASE` path doesn't exist, mount fails silently or creates empty directory.

**Prevention:**
```bash
# Always create workspace directory first
mkdir -p /Users/username/my-project
export WORKSPACE_BASE=/Users/username/my-project

# Verify before running container
ls -la "$WORKSPACE_BASE"

# Then run container
podman run -v "$WORKSPACE_BASE:/workspace:Z" ...
```

**Phase to address:** Phase 1

---

### Pitfall 8: Not Using Podman Pod for Multi-Container Setup

**What goes wrong:**
OpenHands architecture may require multiple containers (main app + sandbox runtime). Running them separately without pod networking causes inter-container communication failures.

**Prevention:**
```bash
# Create pod with shared network namespace
podman pod create -p 3000:3000 openhands-pod

# Run main container in pod
podman run --pod openhands-pod -e ... openhands:latest

# Sandbox container shares pod network automatically
podman run --pod openhands-pod ... sandbox-runtime
```

**Phase to address:** Phase 1

---

### Pitfall 9: API Key Not Exported to Container Environment

**What goes wrong:**
LLM API keys set on host shell are not automatically available inside containers. Must explicitly pass via `-e`.

**Prevention:**
```bash
# Host shell
export LLM_API_KEY="sk-xxxxx"

# Pass to container
podman run \
  -e LLM_API_KEY="$LLM_API_KEY" \
  -e LLM_MODEL="alibaba/qwen-plus" \
  ...
```

**Detection:**
OpenHands starts but all LLM calls fail with authentication errors.

**Phase to address:** Phase 2

---

## Minor Pitfalls

### Pitfall 10: Not Cleaning Up Stopped Machines

**What goes wrong:**
Old Podman machines accumulate, consuming disk space and causing confusion about which machine is active.

**Prevention:**
```bash
# List all machines
podman machine ls

# Remove unused
podman machine rm old-machine-name
```

**Phase to address:** Any phase (maintenance)

---

### Pitfall 11: Using Relative Paths for WORKSPACE_BASE

**What goes wrong:**
`WORKSPACE_BASE` with relative path resolves differently inside container vs host.

**Prevention:**
Always use absolute paths:
```bash
# Bad
export WORKSPACE_BASE="./my-project"

# Good
export WORKSPACE_BASE="$(pwd)/my-project"
# or
export WORKSPACE_BASE="/Users/username/my-project"
```

**Phase to address:** Phase 1

---

## Phase-Specific Warnings

| Phase Topic | Likely Pitfall | Mitigation |
|-------------|---------------|------------|
| Podman Installation | Machine not initialized | Run `podman machine init && start` before any container work |
| Resource Allocation | Insufficient RAM/CPU | Set 8GB+ RAM, 4+ CPUs during `machine init` |
| Container Setup | Volume mount failures | Use absolute paths, `:z`/`:Z` labels, pre-create directories |
| Network Configuration | Port not accessible | Bind to `0.0.0.0`, use `-p` flags correctly |
| LLM Configuration | Wrong provider name/URL | Use `alibaba/*` prefix, correct DashScope base URL |
| Environment Variables | API keys not passed | Explicitly `-e LLM_API_KEY="$LLM_API_KEY"` |

---

## Sources

- Podman machine initialization patterns: WebSearch results on `podman machine init setup macOS`
- Volume mount permission issues: WebSearch on `podman volume mount permissions macOS`, SELinux labeling requirements
- Network binding on macOS: WebSearch on `podman mac network port binding localhost`
- OpenHands container requirements: WebSearch on `OpenHands docker run command environment variables`
- Aliyun DashScope configuration: WebSearch on `阿里百炼 dashscope API base URL`, `OpenHands LLM configuration`
- Resource allocation patterns: WebSearch on `podman machine set memory CPU disk`

---

## Research Confidence Assessment

| Pitfall Category | Confidence | Notes |
|-----------------|------------|-------|
| Podman machine setup | HIGH | Well-documented in Podman docs |
| Volume mounts & SELinux | HIGH | Consistent across sources |
| Network/port binding | MEDIUM | Inferred from Podman architecture |
| OpenHands LLM config | MEDIUM | Based on general OpenHands patterns, specific Aliyun integration unverified |
| Resource requirements | LOW | OpenHands resource requirements not explicitly documented |

**Validation needed in Phase 0/1:**
- Confirm exact OpenHands Docker image name and tag
- Verify Aliyun DashScope provider identifier in OpenHands (`alibaba/*` vs `dashscope/*`)
- Test actual resource consumption with typical workloads
