---
tags: [homelab, sysadmin, systemd, phase4]
---

# PHASE 4 — Write Your Own systemd Service

> Goal: create a script that reports server uptime, register it as a real systemd service, and have Nginx serve the file it writes.

**Concept first:** systemd is the "master manager" (PID 1) that boots and supervises everything. A `.service` file in `/etc/systemd/system/` is a *recipe card* telling it: what (Description), how (ExecStart), and when (After / WantedBy).

---

## STEP 1 — Create the script

**Run:** `sudo nano /usr/local/bin/uptime-report.sh`
- `sudo` = run as root (that folder needs admin to write into).
- `/usr/local/bin/` = standard home for your own custom admin scripts.
- `nano` = simple terminal text editor.

Paste this inside nano:
```bash
#!/bin/bash
echo "Server online since: $(uptime -p)" > /var/www/html/uptime.txt
echo "Load average:" >> /var/www/html/uptime.txt
cat /proc/loadavg >> /var/www/html/uptime.txt
```
- `#!/bin/bash` = say "run me with the Bash shell".
- `uptime -p` = print uptime in human form ("up 2 hours").
- `> file` = write (overwrite) the file; `>> file` = append to it.
- `/proc/loadavg` = kernel's live load (1/5/15-min CPU pressure).

Save & exit nano: press **Ctrl+O** then **Enter**, then **Ctrl+X**.

---

## STEP 2 — Make it executable

**Run:** `sudo chmod +x /usr/local/bin/uptime-report.sh`
- `chmod` = change file mode (permissions).
- `+x` = add "eXecute" permission. Linux won't run a script as a program without it.

**Test it manually (should succeed silently):**
`sudo /usr/local/bin/uptime-report.sh`
- Then check output: `cat /var/www/html/uptime.txt`

---

## STEP 3 — Create the systemd unit file

**Run:** `sudo nano /etc/systemd/system/uptime-report.service`
- `/etc/systemd/system/` = where custom services live.

Paste this inside:
```ini
[Unit]
Description=Write uptime report
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/uptime-report.sh

[Install]
WantedBy=multi-user.target
```
- `[Unit]` = description + ordering. `After=network.target` = "only run once network is up".
- `[Service] Type=oneshot` = script runs once and exits (not a long-running daemon).
- `[Install] WantedBy=multi-user.target` = "start me when the system reaches normal (multi-user) boot state" — this is what makes `enable` work.

Save & exit: **Ctrl+O**, **Enter**, **Ctrl+X**.

---

## STEP 4 — Load, enable, run, verify

```bash
sudo systemctl daemon-reload        # re-scan disk for new/changed unit files
sudo systemctl enable --now uptime-report   # enable=start on boot, --now=also start immediately
systemctl status uptime-report      # should show finished successfully
journalctl -u uptime-report         # see the log of what it did
sudo systemctl start uptime-report  # force a run right now (updates the file)
```

**The Golden Test (from your ThinkPad):**
- Browser → `http://192.168.56.101/uptime.txt`
- or ThinkPad terminal: `curl http://192.168.56.101/uptime.txt`

If Nginx serves the file with live "Server online since" data — **you built and automated a service. That's administration.**

---

### What each command does (quick recap)
| Command | What it does |
|---|---|
| `sudo systemctl daemon-reload` | systemd re-reads unit files from disk (needed after editing/creating one) |
| `sudo systemctl enable --now <svc>` | Start on boot AND start immediately (combines enable + start) |
| `systemctl status <svc>` | Live dashboard: state, PID, recent log lines |
| `journalctl -u <svc>` | Show the full log history for that one service |

---

## Phase 4 — Summary of what I actually got done

**Built & automated a real service:**
- Created my own bash script `/usr/local/bin/uptime-report.sh` that writes server uptime + load average into `/var/www/html/uptime.txt`.
- Registered it as a `systemd` unit (`/etc/systemd/system/uptime-report.service`, `Type=oneshot`).
- Enabled + started it, verified with `systemctl status` and served it live over Nginx via `curl http://192.168.56.101/uptime.txt`.

**Bugs I hit and fixed (real sysadmin lessons):**
1. `[install]` vs `[Install]` — section header is **case-sensitive**. Lowercase meant systemd *ignored* the whole block → error "unit files have no installation config". Fix: capital `I`.
2. Script name typo in `ExecStart` (`upptime-report.sh` vs `uptime-report.sh`) — a small typo in the path = service can't find its script.
3. **Missing shebang `#!/bin/bash`** → `status=203/EXEC` (systemd can't find an interpreter to run the script). My manual run worked by fallback; systemd is strict. Fix: add shebang as first line.

**Key mental models:**
- `systemctl status` showing `inactive (dead)` for a `oneshot` service after a run = **success** (runs once, exits on purpose), not a crash.
- `enable` needs a valid `[Install]` + `WantedBy=`; without it, `enable` refuses to work.
- `curl` (web client) works from **both** the VM itself and the host — anything that can reach the IP. Test from the host to prove real network reachability.

**Next topics (noted, to learn soon):** network connection modes — **NAT vs Bridged vs Host-only** — and how each changes reachability (relevant to real-world deployments).

---

## How the script actually works (simple version)

```bash
#!/bin/bash
echo "service online since: $(uptime -p)" > /var/www/html/uptime.txt
echo "load average:"                    >> /var/www/html/uptime.txt
cat /proc/loadavg                        >> /var/www/html/uptime.txt
```

**The chain — 3 simple steps:**

1. **Ask the kernel** → `uptime -p` reads how long the system has been running from the kernel. `$( ... )` grabs that answer and plugs it into the message.
2. **Write a file** → `>` puts the text into `/var/www/html/uptime.txt` (overwrites). `>>` then *adds* more lines to the file instead of wiping it. `/proc/loadavg` is a "live" kernel file; `cat` dumps it into the file too.
3. **Nginx delivers it** → the file is inside Nginx's web folder. Anyone who opens `http://192.168.56.101/uptime.txt` gets served that file. **The script never "calls" you — it writes a file, and Nginx sends it to whoever asks.**

**The whole point in one line:**
> script asks the kernel for info → script saves it as a file in the web folder → Nginx serves that file to you.

**Two things worth remembering:**
- `>` = overwrite, `>>` = append to the end.
- systemd is strict: the script must start with `#!/bin/bash` (the interpreter line) or it can't run.

---

## What an "interpreter" is (simple version)

- A script is just a **list of instructions** — it's not a finished program. The kernel doesn't understand those instructions by itself.
- The **interpreter** is the program that reads your script **line by line** and turns each line into a real action. For this script, the interpreter is **`bash`** (the same shell you type commands into).
- A `.sh` file could be made for different interpreters: `bash`, `python3`, `node`, etc. They all read text, but each speaks a different language. The kernel needs to know *which one* to use.
- **`#!/bin/bash`** is the label that says "this is a Bash script — run it with the Bash interpreter." That's the whole point of the shebang line.
- **Why missing shebang fails:** the kernel sees a script with no interpreter label and can't guess → `203/EXEC`. Your terminal guesses "bash" when you run by hand, but systemd refuses to guess — you must state it explicitly.