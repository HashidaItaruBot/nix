# Feature Landscape: OpenHands on macOS

**Domain:** AI-driven development environment
**Researched:** 2026-03-20

## Table Stakes

Features users expect. Missing = product feels incomplete.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| **Web UI Access** | Primary interaction mode | Low | Port 3000, React SPA |
| **Workspace Persistence** | Work must survive container restarts | Low | Volume mount `~/.openhands` |
| **LLM Integration** | Core functionality | Low | Environment variable config |
| **Code Execution Sandbox** | Safe code execution | Medium | Built-in to OpenHands image |
| **File Read/Write** | Agent must modify files | Low | Volume mount to workspace |
| **Git Integration** | Commit/push changes | Medium | Requires SSH key or token |
| **Conversation History** | Continue previous sessions | Low | Auto-saved to `~/.openhands` |
| **WebSocket Real-time Updates** | Live agent progress | Low | Built-in, port 3001 |

## Differentiators

Features that set this setup apart. Not expected, but valued.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| **Multi-LLM Routing via litellm** | Fallback providers, cost optimization | Medium | litellm proxy sidecar |
| **Aliyun Bailian Native Support** | China-region LLM access, lower latency | Low | Qwen, Kimi models |
| **Podman (vs Docker)** | No daemon, lighter, open source | Low | Drop-in replacement |
| **Nix-Managed Stack** | Reproducible, declarative | Medium | Integrated with existing Darwin config |
| **Container-to-Host Git SSH Forwarding** | Use macOS SSH keys from container | Medium | SSH agent socket mount |
| **Custom Sandbox Resource Limits** | Prevent runaway containers | Low | Podman `--memory`, `--cpus` flags |

## Anti-Features

Features to explicitly NOT build.

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| Docker Desktop dependency | Subscription requirements, daemon overhead | Use Podman (daemonless) |
| Hardcoded API keys | Security risk, no rotation | Environment variables or `.env` files |
| Complex orchestration (Kubernetes) | Overkill for single-user macOS | Single container or Podman pod |
| Custom LLM proxy (if litellm works) | Reinventing the wheel | Use litellm's existing provider support |
| GUI application for management | Extra installation, platform-specific | Web UI + CLI commands |
| Local LLM inference (Ollama, etc.) | Resource intensive, setup complexity | Cloud LLM APIs only for v1.3 |

## Feature Dependencies

```
Web UI Access ← LLM Integration ← Conversation History
     ↓
Workspace Persistence ← File Read/Write
     ↓
Git Integration ← SSH Key Forwarding (optional)

litellm Proxy ← Multi-LLM Routing
```

## MVP Recommendation

Prioritize:
1. **Podman Installation + Machine VM** - Foundation for everything
2. **OpenHands Container Run** - Basic agent functionality
3. **LLM Configuration (Aliyun Bailian)** - Primary model access
4. **Workspace + Persistence Volumes** - Work must persist

Defer:
- **litellm Proxy** - Add after direct LLM integration works
- **Git SSH Forwarding** - Nice-to-have, not core to agent functionality
- **Multi-container Pod setups** - Single container sufficient for v1.3

## Phase Feature Mapping

### Phase 1: Podman Installation
- [ ] Homebrew install of Podman
- [ ] `podman machine init`
- [ ] `podman machine start`
- [ ] Verification: `podman info`

### Phase 2: OpenHands Container Definition
- [ ] Basic `podman run` command
- [ ] Port mapping (3000:3000)
- [ ] Volume mount: `~/.openhands`
- [ ] Volume mount: `./workspace`
- [ ] Environment variables: `LLM_MODEL`, `LLM_API_KEY`

### Phase 3: LLM Backend Configuration
- [ ] Aliyun DashScope API key setup
- [ ] Correct provider identifier (`alibaba/qwen-plus`)
- [ ] Base URL configuration
- [ ] Test LLM connectivity

### Phase 4: Workspace + Persistence
- [ ] Verify conversation history saves
- [ ] Test file read/write in workspace
- [ ] Container restart preserves state
- [ ] Optional: Git SSH key forwarding

## Sources

- [OpenHands Documentation](https://docs.openhands.dev/)
- [OpenHands GitHub Repository](https://github.com/All-Hands-AI/OpenHands)
- [Podman Documentation](https://podman.io/docs)
- [litellm Documentation](https://docs.litellm.ai/)
