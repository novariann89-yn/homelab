---
tags: [homelab, sysadmin, firewall, ufw, phase5]
---

# PHASE 5 — Firewall (UFW) + verify with nmap

> Goal: only SSH (22) and Nginx (80) are reachable from outside; everything else is blocked.

**⚠️ READ FIRST — the lockout danger:**
UFW denies everything by default when you `enable` it. If you enable it **before** allowing SSH, you lose remote access. So the order matters: **allow, THEN enable** (that's what the commands below do). This is exactly why the sequence below is safe.

---

## Step 1 — Install UFW

```bash
sudo apt install ufw -y
```
**What:** installs the Uncomplicated FireWall.
**Why `-y`:** automatically answers "yes" to the install prompt so it doesn't hang.

---

## Step 2 — Allow SSH (BEFORE enabling!)

```bash
sudo ufw allow OpenSSH
```
**What:** opens the firewall rule for SSH (port 22), using the app profile name "OpenSSH".
**Why FIRST:** this rule is on before the firewall turns on, so you can never lock yourself out.

---

## Step 3 — Allow Nginx

```bash
sudo ufw allow 'Nginx Full'
```
**What:** opens ports for Nginx — both **80** (HTTP) and **443** (HTTPS).
**Why `'Nginx Full'` (with quotes):** the profile name has a space, so quotes tell bash to treat "Nginx Full" as one name.

---

## Step 4 — Turn the firewall ON

```bash
sudo ufw enable
```
**What:** switches UFW on. From this moment, everything NOT explicitly allowed is denied.
**Why:** the two `allow` rules above are already in, so SSH + Nginx stay reachable; everything else (like CUPS printing on 631, any future service) is now blocked from the network.

*(It will ask to proceed — type `y` and Enter.)*

---

## Step 5 — Verify

```bash
sudo ufw status verbose
```
**What:** shows the firewall rule table in detail.
**Why:** proves what's allowed ("OpenSSH" and "Nginx Full") and confirms the default incoming policy is "deny".

---

## Step 6 — Prove it from your Kali box (making Kali useful!)

On your Kali machine, run:
```bash
nmap -p- 192.168.56.101
```
**What:** scans ALL 65535 ports on your Debian server.
**Why:** should now show ONLY **22** and **80** open — confirming the firewall is real. Before UFW, other things (like 631) were exposed.

> If this phase works: your server now answers requests only on SSH and the web. That's the safe, minimal-exposure state of a real server.

---

## ✅ Phase 5 verified (2026-09-16)

From the host:
```
nmap -n -Pn -p- 192.168.56.101
→ 22/tcp open ssh
  80/tcp open http
  all other ports closed
```

**Problem hit + real cause:** scan printed "cannot connect to dns" / "host may be down" / "No route to host" — and the root cause was **NOT** the network type and **NOT** the firewall. The Debian homelab VM was simply **powered off**. Fixed by:
```bash
VBoxManage startvm "debian for homelab" --type headless
```
*(`--headless` boots it without a GUI window — ideal for a server you manage over SSH.)*

**Key answers locked in:**
- **Host-only is fine for nmap — NAT is NOT needed.** Host-only gives direct IP reachability, which is all a port scan requires.
- **`cannot connect to dns` / `dns seems down`** = cosmetic noise. nmap tries to reverse-DNS scan targets; with no DNS server on host-only, the lookup fails. Silent, harmless. Fix: `-n` (skip DNS).
- **`host may be down`** = nmap's ping probe got no reply. With UFW enabled, ICMP ping is blocked by default. Fix: `-Pn` (skip ping discovery, scan ports directly).
- **`No route to host`** = the VM is off/unreachable at the network layer — a real problem, not DNS. Check it's actually running.

**nmap flags worth remembering:**
- `-p-` scan all 65535 ports
- `-n` skip DNS reverse-lookup
- `-Pn` skip ping discovery (host may block ping)
- `-sV` (bonus) service version detection

---

## 📌 Phase 5 — Complete summary (what I actually did)

**Set up a working firewall (verified):**
1. Installed UFW (`sudo apt install ufw -y`)
2. Allowed SSH (`sudo ufw allow OpenSSH`) — **first**, so no lockout
3. Allowed Nginx (`sudo ufw allow 'Nginx Full'`)
4. Enabled it (`sudo ufw enable`) — everything else now denied by default
5. Verified with nmap → **only 22 (ssh) + 80 (http) open, all others closed** ✓

**The debugging journey (this was the real learning):**
The scan printed scary messages — `cannot connect to dns`, `host may be down`, `No route to host`. I learned these are three DIFFERENT things:
- **DNS warnings** → cosmetic (nmap does reverse-DNS; host-only has no DNS server). Fix: `-n`.
- **host may be down** → UFW blocks ICMP ping. Fix: `-Pn`.
- **No route to host** → the VM was actually **powered off**. Fix: `VBoxManage startvm "debian for homelab" --type headless`.
- **Root cause was NOT NAT and NOT the network type.** Host-only gives all the reachability nmap needs.

**Key net result:** host-only = fine, no NAT needed. Use `nmap -n -Pn -p- <ip>` for reliable scans. Server is now locked down — exactly the minimal-exposure state of a real production server.

**Still open (host issue, not this phase):** garbled/auto-repeating keyboard typing inside kitty terminal on Wayland (`f` → `fastfetchlllll`, Backspace adds chars). Did not resolve via VM restart or `QT_QPA_PLATFORM=xcb`. Suspected kitty-on-Wayland input bug; try `LINUX_DISPLAY=:0 kitty --detach` (XWayland) or a different terminal to isolate. Not blocking the homelab — SSH still works to run anything.