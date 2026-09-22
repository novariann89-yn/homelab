# VM Setup Notes

## Debian 13 "debian for homelab"

| Setting | Value |
|---|---|
| Name | `debian for homelab` |
| OS | Linux/Debian (64-bit) |
| CPU | 2 cores |
| RAM | 2GB |
| Disk | 20GB VDI, dynamically allocated |
| Network | Host-only Adapter (vboxnet0) |
| IP | 192.168.56.101 (DHCP, assigned by VirtualBox) |
| User | `vboxuser` (sudo group) |
| SSH port | 22 |
| Kernel | 6.12.107+deb13-amd64 |
| VM UUID | 13cd9c0f-3425-413c-bd91-4859126bb1a8 |

## VBoxManage Commands (Host)

```bash
# Start headless
VBoxManage startvm "debian for homelab" --type headless

# Stop
VBoxManage controlvm "debian for homelab" poweroff

# Status
VBoxManage showvminfo "debian for homelab" | grep "State:"
```

## VirtualBox Network Modes (Learning Notes)

| Mode | How it works | Use case |
|---|---|---|
| NAT | VM shares host's internet, hidden | Outbound only, no inbound |
| Bridged | VM gets its own LAN IP | Full network access, like a real device |
| Host-only | Private network host↔VM only | Isolated lab, no real internet |

Host-only is what we use here — VM gets 192.168.56.101, host gets 192.168.56.1, no NAT needed.
