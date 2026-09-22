---
tags: [tech, homelab, sysadmin, linux, roadmap]
type: guide-node
created: 2026-09-07
status: active
next-action: "Phase 1 - install Debian server VM"
---

# Homelab Roadmap — Junior System Administrator

> Target: build a self-hosted Linux server VM, configure it end-to-end, and publish it as a public GitHub project. The proof-of-work that turns "self-taught, trust me" into "here's the box I built."

## The rule (this time)
**Write everything down.** Last time you blindly followed Kali install steps and kept nothing. This time every command goes into this note (or a daily journal) so you understand *why* each thing works — and you'll have documentation you can reuse.

## Distro choice
**Debian 12 (Bookworm, Server edition)** — lightweight, classic sysadmin base, no GUI. Your existing Kali VM stays as a "practice/experiment box" (handy later for nmap tests). You do the homelab on Debian, not Kali. Commands below assume Debian (apt == Ubuntu's apt, so they're identical).

---

## PHASE 0 — Virtualization concepts (why VirtualBox)
Nothing to install; learn the concepts.

- A **VM** = a computer simulated in software. You give it virtual CPU, RAM, disk, and network.
- VirtualBox specifics you'll configure: CPU cores, RAM, **virtual disk (VDI)**, and **network mode**.
- **Network modes (THE key concept):**
  - **NAT** — VM shares your laptop's internet, hidden behind it. Default. Good for *outbound* only.
  - **Bridged Adapter** — VM gets its own LAN IP, behaves like a real device on your network. → use this for the homelab so your phone/other devices can reach it.
  - **Host-only** — private network only between your laptop and the VM.
- **Snapshot** = save the VM's full state so you can roll back. **Do one before every big risky change.** This is your safety net.
- The VM isn't a toy — the same concepts (virtualization: KVM, Proxmox, ESXi) run real production servers. Learn the concepts on VirtualBox, they transfer.

### ✔ Phase 0 exit check
- [x] Explain in one sentence what a VM is.
- [x] Explain NAT vs Bridged.
- [x] Took a snapshot at least once.

---

## PHASE 1 — Install the Debian server (Day 1-2)
1. Download **Debian netinst** (network install, ~700MB) ISO from debian.org.
2. In VirtualBox: New VM → name `homelab` → Linux/Debian (64-bit) → at least **2 CPU, 2GB RAM, 20GB VDI**.
3. Settings → Network → **Bridged Adapter** (so it gets its own LAN IP).
4. Boot the ISO → **Install** (not Graphical) → SSH server: **yes** → standard system utilities: yes.
5. No desktop. Server edition. Terminal only — this *is* the job.
6. Post-install: set hostname `homelab`, timezone Asia/Jakarta.

Learn (don't just type):
- `apt update` (refresh package list) vs `apt upgrade` (apply updates).
- `/etc/` = where all config lives. `cat /etc/hostname`, `cat /etc/os-release`.

### ✔ Phase 1 exit check
- [x] Debian boots to a login prompt (no desktop).
- [x] `apt update && apt upgrade` runs clean.
- [x] IP reachable: note `ip a` — you've got a LAN IP.

---

## PHASE 2 — SSH into it (Day 2-3) ← THE golden skill
Goal: log in from your ThinkPad **without a password, securely**.

```bash
# 1. From your ThinkPad (host): generate a keypair if you don't have one
ls ~/.ssh/id_ed25519.pub  2>/dev/null || ssh-keygen -t ed25519

# 2. Copy your public key to the server
ssh-copy-id user@SERVER_IP        # prompts for password once

# 3. Test passwordless login
ssh user@SERVER_IP
```

Then HARDEN (the classic junior-sysadmin task). Edit the server's config:
```bash
nano /etc/ssh/sshd_config
```
Change:
```ini
PermitRootLogin no
PasswordAuthentication no
```
Restart: `sudo systemctl restart ssh`. **BEFORE logging out, test a NEW ssh session works** — or you lock yourself out. (Snapshot from Phase 0 is your escape.)

### ✔ Phase 2 exit check
- [ ] `ssh user@SERVER_IP` works with NO password (keys only).
- [ ] Root login disabled, password auth disabled.
- [ ] You can explain why key auth > password.

---

## PHASE 3 — Run a real service: Nginx (Day 3-4)
```bash
sudo apt install nginx -y
sudo systemctl enable nginx   # start on boot
sudo systemctl start nginx
sudo systemctl status nginx   # should say "active (running)"
```
- Check it: from your laptop, open `http://SERVER_IP` → Debian welcome page.
- Understand: **port 80** is now listening → `sudo ss -tlnp` shows it.
- Pointer: `curl localhost` returns the page.

### ✔ Phase 3 exit check
- [ ] Nginx serves a page reachable from your laptop's browser.
- [ ] It stays up after `sudo reboot` (enable did it).
- [ ] You know which port it listens on.

---

## PHASE 4 — systemd & write YOUR OWN service (Day 4-5) ← most "sysadmin" item
Understand: **systemd** runs everything at boot. `systemctl` is your control.

```bash
systemctl list-units --type=service   # all running services
systemctl status nginx
journalctl  -u nginx    -f    # live logs Nginx
```

Now write your own service. Create a script:
```bash
sudo nano /usr/local/bin/uptime-report.sh
```
```bash
#!/bin/bash
echo "Server online since: $(uptime -p)" > /var/www/html/uptime.txt
```
```bash
chmod +x /usr/local/bin/uptime-report.sh
```

Create a unit:
```bash
sudo nano /etc/systemd/system/uptime-report.service
```
```ini
[Unit]
Description=Write uptime report
After=network.target

[Service]
ExecStart=/usr/local/bin/uptime.sh
```
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now uptime-report
journalctl -u uptime-report      # see it run
```
Now Nginx can serve `http://SERVER_IP/uptime.txt`. You built + automated a service. That's administration.

### ✔ Phase 4 exit check
- [ ] Your own service `uptime-report` shows in `systemctl list-units`.
- [ ] `https://SERVER_IP/uptime.txt` returns live data.
- [ ] You can explain what a unit file describes.

---

## PHASE 5 — Firewall + verify (Day 5)
```bash
sudo apt install ufw -y
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw enable
sudo ufw status verbose    # active, only ssh+nginx, everything else denied
```
Verify from your Kali box (making Kali finally useful):
```bash
nmap -p- SERVER_IP    # only 22 + 80 should appear open you should→ only 22,80 open
```

### ✔ Phase 5 exit check
- [ ] `ufw status` shows only OpenSSH + Nginx allowed.
- [ ] nmap shows no unexpected open ports.

---

## PHASE 6 — Logs, README, publish (Day 6)
- Logs: `journalctl -u nginx`, `journalctl -p err` (errors only). Mention `grep`.
- **README.md** (the star — recruiters read it): architecture (plain text or Mermaid), what each service does, exact commands to reproduce.
- Publish:
```bash
cd path/to/homelab/docs
git init
git add README.md
git commit -m "homelab documentation"
git remote add origin git@github.com:USERNAME/homelab.git
git push -u origin main
```
Make the repo **public**.

### ✔ Phase 6 exit check
- [ ] Public GitHub repo named `homelab` with a real README.
- [ ] README has architecture + exact reproduction commands.
- [ ] Resume PROJECTS section updated to point at the live link.

---

## Priority order if hours are short
**SSH hardening (P2) > Nginx (P3) > systemd service (P4) > README + GitHub (P6).**
Firewall (P5) + logs = garnish. Four items alone = a complete, credible project.

## Skill set you'll have = resume bullets
- Linux server administration (Debian)
- SSH key-based auth + hardening
- systemd service management
- Nginx web server config
- UFW firewall
- journalctl log management
- VirtualBox virtualization
- Git + GitHub publishing

## Open items for me (assistant)
- [ ] GitHub username for the note
- [ ] When server is live: update resume PROJECTS from "in progress" to real link