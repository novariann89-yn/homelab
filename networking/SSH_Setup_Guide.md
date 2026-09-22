# SSH Setup Guide

How passwordless SSH was set up from host (ThinkPad) to Debian VM at `192.168.56.101`.

## Steps

1. Generate keypair (host): `ssh-keygen -t ed25519`
2. Copy public key to server: `ssh-copy-id vboxuser@192.168.56.101` (prompts for password once)
3. Test passwordless login: `ssh vboxuser@192.168.56.101`
4. Harden: edit `/etc/ssh/sshd_config`, set `PermitRootLogin no`, `PasswordAuthentication no`, `sudo systemctl restart sshd`
5. Verify: `sudo ss -tlnp | grep ssh` shows port 22 listening

## Troubleshooting

- **Permission denied (publickey)**: VM not yet at expected IP; check with `VBoxManage showvminfo "debian for homelab"` and wait for DHCP lease
- **Wi-Fi bridged packet drop**: some routers isolate client-to-client traffic; use host-only networking instead

## Networking Notes

- Host-only = VM gets IP in `192.168.56.101–254` range; no NAT needed
- Bridged = VM gets its own LAN IP on real network; client isolation can block SSH
