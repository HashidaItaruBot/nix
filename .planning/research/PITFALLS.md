# Domain Pitfalls

**Domain:** MicroVM on NixOS
**Researched:** 2026-03-19
**Confidence:** MEDIUM (based on microvm.nix official documentation and handbook)

## Critical Pitfalls

Mistakes that cause rewrites or major issues.

### Pitfall 1: Writable Nix Store Overlay on Incompatible Filesystems

**What goes wrong:** Users attempt to use a 9p or virtiofs share as the writable overlay for `/nix/store`, but the Linux overlay filesystem rejects these filesystem types. The VM builds successfully but after reboot, all installed packages disappear because the overlay fails to mount.

**Why it happens:** The Linux overlayfs driver is extremely picky about underlying filesystems. According to microvm.nix documentation: "The Linux overlay filesystem is very picky about the filesystems that can be the upper (writable) layer. 9p/virtiofs shares don't work currently."

**Consequences:**
- All packages built inside the VM are lost after reboot
- `/nix/store` becomes read-only with no fallback
- Users may accidentally fill up root filesystem if overlay mounts to wrong location

**Prevention:**
```nix
{ config, ... }:
{
  microvm.writableStoreOverlay = "/nix/.rw-store";

  microvm.volumes = [ {
    image = "nix-store-overlay.img";
    mountPoint = config.microvm.writableStoreOverlay;
    size = 2048;  # MB
  } ];
}
```

**Detection:**
- Run `mount | grep overlay` inside VM to verify overlay is active
- Check `dmesg | grep overlay` for mount errors
- After reboot, run `nix-store --verify` to detect missing store paths

**Phase to address:** Phase 2 (Storage & Persistence)

---

### Pitfall 2: Nix Database Forgetting Packages After Reboot

**What goes wrong:** Even with a writable overlay configured, the Nix database inside the VM forgets all packages built or installed after the VM was created. After reboot, `nix-env -q` shows only the original packages.

**Why it happens:** The Nix database (`/nix/var/nix/db`) state is not properly persisted across the overlay. The microvm.nix documentation explicitly states: "The Nix database will forget all built packages after a reboot, containing only what is needed for the VM's NixOS system."

**Consequences:**
- Garbage collection may delete "unregistered" packages even though files exist
- `nix-env` operations fail with "not found" errors for existing packages
- Confusion about where packages are installed

**Prevention:**
- Delete and recreate the overlay after each MicroVM shutdown or before startup
- Use the host's `/nix/store` share to avoid building inside the VM:
```nix
microvm.shares = [ {
  tag = "ro-store";
  source = "/nix/store";
  mountPoint = "/nix/.ro-store";
  proto = "virtiofs";
} ];
```
- Build packages on the host and deploy to VM instead of building inside VM

**Detection:**
- Compare `nix-store -q --references /run/current-system` before and after reboot
- Check if `nix-env -q` output changes after reboot

**Phase to address:** Phase 2 (Storage & Persistence)

---

### Pitfall 3: TAP Interface Permission Denied at Boot

**What goes wrong:** MicroVM fails to start during boot with "permission denied" errors on TAP network interfaces, even though the same configuration works when started manually.

**Why it happens:** TAP interfaces must be created before the MicroVM starts, and the systemd service order matters. The `microvm-tap-interfaces@.service` must complete before `microvm@.service` starts. Additionally, TAP interfaces need the `multi_queue` flag if the VM has multiple CPU cores.

**Consequences:**
- MicroVM fails to start on boot
- Network connectivity missing even if VM starts
- Silent fallback to user-mode networking (if available)

**Prevention:**
- Use the `microvm.nixosModules.host` module which handles systemd dependencies
- Create TAP interfaces with proper flags:
```bash
# For multi-core VMs (vcpu > 1)
sudo ip tuntap add vm-a1 mode tap multi_queue user $(whoami)
```
- Ensure `microvm.autostart` is configured on host:
```nix
microvm.autostart = [ "my-microvm" ];
```

**Detection:**
- Check `systemctl status microvm@my-microvm` for dependency failures
- Run `ip tuntap show` to verify TAP interfaces exist
- Check `journalctl -u microvm-tap-interfaces@my-microvm`

**Phase to address:** Phase 3 (Networking)

---

### Pitfall 4: virtiofs on ZFS Without Required Options

**What goes wrong:** virtiofs shares fail to mount or behave erratically when the underlying host directory is on a ZFS dataset without extended attribute and ACL configuration.

**Why it happens:** virtiofs requires POSIX ACLs and extended attributes. ZFS defaults to `xattr=off` and `acltype=off` on many distributions.

**Consequences:**
- virtiofs shares fail to mount
- Permission errors on shared directories
- Silent data corruption if partial mounts succeed

**Prevention:**
Configure ZFS dataset with required options:
```bash
zfs set xattr=sa pool/dataset
zfs set acltype=posixacl pool/dataset
```

Or in NixOS:
```nix
boot.zfs.devNodes = "/dev/disk/by-uuid";  # Ensure proper device paths
```

**Detection:**
- Check ZFS properties: `zfs get xattr,acltype pool/dataset`
- Test virtiofs mount manually before VM startup
- Monitor `journalctl -u microvm-virtiofsd@my-microvm`

**Phase to address:** Phase 2 (Storage & Persistence)

---

## Moderate Pitfalls

### Pitfall 5: Insufficient Memory Allocation

**What goes wrong:** MicroVM is configured with default 512MB RAM which is insufficient for running services with Nix store access, causing OOM kills during package operations or service startup.

**Why it happens:** The default `microvm.mem = 512` is appropriate for minimal appliances but not for services that need to run Nix operations or maintain multiple processes.

**Consequences:**
- Services crash with OOM errors
- Nix operations fail mid-build
- VM becomes unresponsive under load

**Prevention:**
```nix
microvm.mem = 2048;  # For services with Nix operations
microvm.vcpu = 2;    # Match TAP interface multi_queue if needed
```

Enable memory ballooning for dynamic adjustment:
```nix
microvm.balloon = true;
```

**Detection:**
- Monitor `dmesg | grep -i oom` inside VM
- Use `microvm-balloon` tool to check memory pressure
- Check systemd service restart counts

**Phase to address:** Phase 1 (Basic Setup)

---

### Pitfall 6: NAT Port Forwarding Not Configured for Public Services

**What goes wrong:** MicroVM service is running and listening on ports internally, but external traffic cannot reach it because NAT forwarding was not configured on the host.

**Why it happens:** When using bridge networking with NAT (the recommended isolated setup), the host must explicitly forward ports to MicroVM internal IPs.

**Consequences:**
- Services accessible internally but not externally
- Confusion about firewall vs NAT issues
- Debugging time wasted on wrong layer

**Prevention:**
Configure host NAT forwarding:
```nix
networking.nat = {
  enable = true;
  externalInterface = "eth0";
  internalInterfaces = [ "microvm" ];
  forwardPorts = [ {
    proto = "tcp";
    sourcePort = 8080;
    destination = "10.0.0.2";  # MicroVM IP
  } ];
};
```

**Detection:**
- Test connectivity from host: `curl http://10.0.0.2:8080`
- Test from external: `curl http://host-ip:8080`
- Check `iptables -t nat -L` for forwarding rules

**Phase to address:** Phase 3 (Networking)

---

### Pitfall 7: Hypervisor Selection Mismatch with Feature Requirements

**What goes wrong:** User selects a hypervisor (e.g., firecracker) that doesn't support required features like 9p/virtiofs shares, then wonders why share configuration is ignored.

**Why it happens:** Different hypervisors have different capability restrictions:

| Hypervisor | 9p Shares | virtiofs Shares | Control Socket |
|------------|-----------|-----------------|----------------|
| qemu       | Yes       | Yes             | Yes            |
| firecracker| No        | No              | Yes            |
| cloud-hypervisor | No  | Yes             | Yes            |
| kvmtool    | No        | No              | No             |
| vfkit (macOS) | No     | Built-in        | Limited        |

**Consequences:**
- Share mounts silently fail
- No control socket for clean shutdown
- Configuration ignored without error

**Prevention:**
- Use `qemu` for maximum compatibility during development
- Match hypervisor to requirements:
  - Need 9p shares: qemu, kvmtool
  - Need virtiofs: qemu, cloud-hypervisor, alioth
  - Need control socket: avoid kvmtool, stratovirt, alioth

**Detection:**
- Check hypervisor restrictions in microvm.nix documentation
- Verify shares mount: `mount | grep 9p` or `mount | grep virtiofs`
- Test shutdown via control socket

**Phase to address:** Phase 1 (Basic Setup)

---

## Minor Pitfalls

### Pitfall 8: machineId Not Set for Centralized Logging

**What goes wrong:** When sharing journal logs with the host, all MicroVM logs appear under the same machine ID, making it impossible to distinguish which VM generated which log entries.

**Why it happens:** systemd identifies hosts by `/etc/machine-id`. Without setting `microvm.machineId`, all VMs may share the same or randomly generated ID.

**Consequences:**
- Journal entries from multiple VMs interleave
- Cannot filter logs by VM
- Log analysis tools show incorrect hostnames

**Prevention:**
```nix
microvm.machineId = "unique-hex-id-for-this-vm";
```

Or derive from hostname:
```nix
networking.hostName = "openclaw-vm";
microvm.machineId = lib.fixedWidthString 32 "0" (builtins.hashString "md5" config.networking.hostName);
```

**Phase to address:** Phase 4 (Observability) - optional

---

### Pitfall 9: sops-nix Secrets Disappear on Host Update

**What goes wrong:** When using sops-nix with virtiofs-shared secrets, the `/run/secrets` directory disappears or becomes stale after host system updates.

**Why it happens:** sops-nix cleans up old generations in `/run/secrets.d/`, but virtiofs shares may not update atomically. The FAQ notes this is a known issue.

**Consequences:**
- Services lose access to secrets after host rebuild
- Manual VM reboot required to refresh secrets
- Potential secret exposure if old generations not cleaned

**Prevention:**
```nix
sops.keepGenerations = 0;  # Stop sops-nix from removing old generations
```

Note: This means VMs must be rebooted to adapt updated secrets.

**Phase to address:** Phase 4 (Security & Secrets) - if using sops-nix

---

### Pitfall 10: Declarative VM Definition Increases Host Build Time

**What goes wrong:** Adding `microvm.vms` with inline `config` causes host system rebuilds to take 2-5x longer and closure size to balloon.

**Why it happens:** Building MicroVMs together with the host means every host rebuild also rebuilds all MicroVM configurations.

**Consequences:**
- `nixos-rebuild switch` takes much longer
- Larger system closure
- Hydra/CI build times increase

**Prevention:**
Use declarative deployment mode instead of fully declarative:
```nix
microvm.vms.my-microvm = {
  flake = self;
  updateFlake = "git+file:///etc/nixos";
};
```

Then update with `microvm -u my-microvm` instead of full rebuild.

**Phase to address:** Phase 1 (Basic Setup)

---

## Phase-Specific Warnings

| Phase Topic | Likely Pitfall | Mitigation |
|-------------|---------------|------------|
| Basic MicroVM Setup | Hypervisor mismatch with requirements | Choose qemu for development, verify feature support |
| Basic MicroVM Setup | Insufficient memory for services | Set `microvm.mem >= 1024` for any service workload |
| Storage & Persistence | Writable overlay on 9p/virtiofs | Use volume (block device) for writableStoreOverlay |
| Storage & Persistence | Nix DB forgets packages | Plan for host-based builds or accept rebuilds |
| Storage & Persistence | ZFS + virtiofs incompatibility | Set `xattr=sa acltype=posixacl` on ZFS dataset |
| Networking | TAP interface permission denied | Use host module, ensure systemd ordering |
| Networking | NAT port forwarding missing | Explicitly configure `networking.nat.forwardPorts` |
| Networking | multi_queue flag missing for multi-core | Add `multi_queue` to TAP creation if vcpu > 1 |
| Autostart | VM doesn't start on boot | Configure `microvm.autostart` on host |
| Security | Over-permissive device access | Use custom udev rules, not `users.users.microvm.extraGroups = ["disk"]` |

---

## Sources

- [microvm.nix Handbook - Shares](https://github.com/microvm-nix/microvm.nix/blob/main/doc/src/shares.md)
- [microvm.nix Handbook - Network interfaces](https://github.com/microvm-nix/microvm.nix/blob/main/doc/src/interfaces.md)
- [microvm.nix Handbook - Preparing a host](https://github.com/microvm-nix/microvm.nix/blob/main/doc/src/host.md)
- [microvm.nix Handbook - Declarative MicroVMs](https://github.com/microvm-nix/microvm.nix/blob/main/doc/src/declarative.md)
- [microvm.nix Handbook - Advanced network setup](https://github.com/microvm-nix/microvm.nix/blob/main/doc/src/advanced-network.md)
- [microvm.nix Handbook - FAQ](https://github.com/microvm-nix/microvm.nix/blob/main/doc/src/faq.md)
- [microvm.nix Handbook - systemd services](https://github.com/microvm-nix/microvm.nix/blob/main/doc/src/host-systemd.md)
- [microvm.nix Options reference](https://github.com/microvm-nix/microvm.nix/blob/main/nixos-modules/microvm/options.nix)
