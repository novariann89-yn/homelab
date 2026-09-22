# homelab

**Junior System Administrator homelab:** Debian 13 server with SSH, Nginx, systemd service, and UFW firewall.

| | |
|---|---|
| **Server** | Debian 13 (Bookworm, Server), kernel 6.12, headless VM |
| **Network** | VirtualBox Host-Only (vboxnet0), IP `192.168.56.101` |
| **SSH** | OpenSSH, ed25519 key-based auth, root + password login disabled |
| **Web** | Nginx (port 80), custom "Nova's Homelab" page |
| **Service** | `uptime-report` — systemd oneshot that writes kernel boot time + loadavg to `/var/www/html/uptime.txt` |
| **Firewall** | UFW, only 22 (SSH) + 80 (HTTP) open |
| **Verified** | `nmap -n -Pn -p- 192.168.56.101` → only 22 + 80 open |

---

## Quick Start — Reproduce This Server

### 1. Install Debian VM (VirtualBox)

Download Debian 13 netinst ISO. VirtualBox: New VM → Linux/Debian (64-bit) → 2 CPU, 2GB RAM, 20GB VDI. Network → Host-only Adapter (vboxnet0). Boot ISO → Install (not Graphical) → SSH server: YES, standard utilities: YES. Post-install: `sudo hostnamectl set-hostname homelab`.

### 2. SSH Key Setup

From host — generate keypair if needed: `ls ~/.ssh/id_ed25519.pub 2>/dev/null || ssh-keygen -t ed25519`. Copy public key to Debian VM: `ssh-copy-id vboxuser@192.168.56.101`.

### 3. Harden SSH

```bash
ssh vboxuser@192.168.56.101
sudo nano /etc/ssh/sshd_config
# Change: PermitRootLogin no, PasswordAuthentication no
sudo systemctl restart sshd
# Test: new SSH session (no password) → disconnect old one
```

### 4. Nginx

```bash
ssh vboxuser@192.168.56.101
sudo apt update && sudo apt install nginx -y
sudo systemctl enable --now nginx
# From host: open http://192.168.56.101
```

### 5. Custom Welcome Page

```bash
ssh vboxuser@192.168.56.101
sudo tee /var/www/html/index.html > /dev/null << 'EOF'
<!DOCTYPE html>
<html><head><title>Nova's Homelab</title>
<style>body{background:#1a1a2e;color:#eee;font-family:sans-serif;text-align:center;padding:80px}
h1{color:#e94560}</style></head>
<body><h1>Nova's Homelab</h1><p>Debian 13 · SSH · Nginx · systemd · UFW</p></body></html>
EOF
# Verify from host: curl http://192.168.56.101
```

### 6. systemd Service (Uptime Report)

```bash
ssh vboxuser@192.168.56.101
sudo nano /usr/local/bin/uptime-report.sh
# Content:
#!/bin/bash
echo "Server online since: $(uptime -p)" > /var/www/html/uptime.txt
echo "Average load: $(cat /proc/loadavg | awk '{print $1,$2,$3}')" >> /var/www/html/uptime.txt

sudo chmod +x /usr/local/bin/uptime-report.sh

sudo tee /etc/systemd/system/uptime-report.service > /dev/null << 'EOF'
[Unit]
Description=Write uptime report
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/uptime-report.sh

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now uptime-report
journalctl -u uptime-report --no-pager
# Verify: curl http://192.168.56.101/uptime.txt
```

### 7. UFW Firewall

```bash
ssh vboxuser@192.168.56.101
sudo apt install ufw -y
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw enable
sudo ufw status verbose
# From host (Kali): nmap -n -Pn -p- 192.168.56.101
# → only 22 (ssh) + 80 (http) should appear open
```

---

## Directory Structure

```
homelab/
├── README.md                          ← This file
├── docs/
│   ├── Homelab Roadmap - Junior System Admin.md
│   ├── Phase 1 - Debian Server Setup.md
│   ├── Phase 2 - SSH and Networking.md
│   ├── Phase 3 - Nginx Setup.md
│   ├── Phase 4 - systemd Service Setup.md
│   ├── Phase 5 - UFW Firewall Setup.md
│   └── Phase 6 - GitHub Publish.md     ← This project
├── services/
│   ├── uptime-report.service          ← systemd unit file
│   └── uptime-report.sh               ← Bash script
├── networking/
│   ├── SSH Setup Guide.md
│   └── Firewall nmap results.md
├── references/
│   └── Junior SysAdmin Essential Commands.md
└── vm/
    └── Debian VM setup notes.md
```

---

## Service Status

| Service | Status | Port | Description |
|---|---|---|---|
| `nginx` | Active | 80 | Web server, custom "Nova's Homelab" page |
| `uptime-report` | Active (last ran) | — | Writes uptime + loadavg to `/uptime.txt` |

## Logs

```bash
journalctl -u nginx -f
journalctl -u uptime-report --no-pager
journalctl -p err --no-pager
```

## What This Proves

- Debian server administration: installed, configured, hardened
- SSH key-based auth + hardening: password auth disabled, root login disabled
- systemd service management: wrote a oneshot unit with proper `[Unit]`, `[Service]`, `[Install]` sections
- Nginx web server: custom welcome page, file serving
- UFW firewall: stateful, default-deny, verified with nmap
- VirtualBox virtualization: host-only networking, headless operation
- Networking fundamentals: TCP/IP, host-only routing, DNS bypass (`-n`), ping bypass (`-Pn`)

## Roadmap

```
Phase 0 — Virtualization concepts
Phase 1 — Install Debian server VM
Phase 2 — SSH into it (hardened)
Phase 3 — Nginx web server
Phase 4 — systemd & your own service
Phase 5 — UFW firewall
Phase 6 — Logs, README, publish ← THIS PROJECT
```
