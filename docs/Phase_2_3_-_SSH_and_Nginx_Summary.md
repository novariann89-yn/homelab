---
source_title: "Homelab Phase 2 & 3 — SSH Hardening and Nginx Web Server"
source_origin: "Hermes Session Chat & Linux Troubleshooting"
date_summarized: "2026-09-11"
tags: [summary, homelab, sysadmin, ssh, nginx, systemd, networking]
---

# Homelab Phase 2 & 3 — SSH Hardening & Nginx Deployment

## 1. Core Milestone Accomplished
> Fully hardened SSH to reject passwords and root logins, deployed Nginx web server on Debian, and served a custom dark-themed dashboard over the private network.

---

## 2. Phase 2 (Completion): SSH Hardening Journey

### Actions Taken:
1. **Configured `/etc/ssh/sshd_config`:**
   - Set `PermitRootLogin no` (blocks root user from logging in via SSH directly).
   - Set `PasswordAuthentication no` (blocks password guessing bots; forces key-only access).
2. **Reloaded Daemon:**
   - Ran `sudo systemctl restart ssh`.
   - Learned **The Rule of Silence**: in Linux, successful execution produces zero output.
3. **Verified Authentication Behavior:**
   - Handled `Permission denied (publickey)` by explicitly using `-i ~/.ssh/id_ed25519`.
   - Confirmed key authentication succeeded without prompting for passwords.

---

## 3. Phase 3: Nginx Installation & Customization

### Actions Taken:
1. **Installed Web Serv
   - `sudo apt update && sudo apt install nginx -y`.
   - Discovered that on Debian/Ubuntu, `apt` automatically starts and enables services upon installation.
2. **Verified Service & Socket:**
   - `sudo systemctl status nginx` confirmed `active (running)`.
   - `sudo ss -tlnp` confirmed Nginx listening on Port `80` (HTTP).
3. **Deployed Custom Dashboard:**
   - Backed up original page: `sudo cp /var/www/html/index.nginx-debian.html ...backup`.
   - Injected custom dark-mode dashboard into `/var/www/html/index.html`.
   - Verified live page from ThinkPad browser at `http://192.168.56.101`.

---

## 4. Commands Used & Concise Explanations

| Command | Concise Explanation |
|---|---|
| `sudo nano /etc/ssh/sshd_config` | Opens SSH server configuration in terminal text editor as root. |
| `sudo sshd -t` | Tests SSH config file for syntax errors before restarting. |
| `sudo systemctl restart ssh` | Restarts the SSH background daemon to apply newly modified rules. |
| `ssh -i <key> <user>@<ip>` | Connects via SSH forcing the use of a specific private key file. |
| `sudo apt install nginx -y` | Downloads and installs Nginx web server without asking for confirmation. |
| `sudo systemctl enable nginx` | Registers Nginx to start automatically on system boot. |
| `sudo systemctl start nginx` | Starts Nginx service immediately. |
| `sudo systemctl status nginx` | Shows live runtime status, PID, and recent logs of Nginx. |
| `sudo ss -tlnp` | Lists all active listening TCP ports along with process names. |
| `curl -I <url>` | Requests only HTTP headers from a web server to verify connectivity. |
| `sudo cp <src> <dst>` | Copies file as root (used to create safety backups before editing). |
| `sudo tee <file>` | Writes standard input into a root-owned file from the terminal. |
| `sudo chmod +w <file>` | Grants write permission to a file if it was marked read-only. |
