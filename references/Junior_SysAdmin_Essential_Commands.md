# Junior SysAdmin Essential Commands

6-category cheatsheet built from Phase 0–5 homelab practice.

## System Info & Health

| Command | What it does |
|---|---|
| `uptime` | How long system's been up, load averages |
| `free -h` | RAM usage (human-readable) |
| `df -h` | Disk space usage per filesystem |
| `uname -a` | Kernel version, arch, hostname |

## systemd

| Command | What it does |
|---|---|
| `systemctl list-units --type=service` | All running services |
| `systemctl status nginx` | Service status, last start time |
| `journalctl -u nginx -f` | Live Nginx logs |
| `sudo systemctl daemon-reload` | Reload systemd after unit file changes |
| `sudo systemctl enable --now nginx` | Enable + start immediately |

## Logs

| Command | What it does |
|---|---|
| `journalctl -u nginx` | Nginx logs since boot |
| `journalctl -p err` | Errors and above (critical, error, warning) |
| `grep <pattern> /var/log/syslog` | Search syslog for keyword |

## Networking

| Command | What it does |
|---|---|
| `ip a` | Network interfaces and IPs |
| `ss -tlnp` | List listening TCP sockets with process |
| `curl http://192.168.56.101` | Fetch web page from host |
| `nmap -p- <ip>` | Scan all ports (from Kali or host) |

## Users & Permissions

| Command | What it does |
|---|---|
| `sudo usermod -aG sudo vbox` | Add user to sudo group |
| `su -` | Switch to root with full env |
| `sudo adduser <name> sudo` | Add user to sudo group (newer) |

## Files & Search

| Command | What it does |
|---|---|
| `find / -name "*.log" -type f 2>/dev/null` | Find files by name |
| `grep -r "uptime" /etc/ 2>/dev/null` | Search recursively, ignore errors |
| `> file.txt` | Overwrite file |
| `>> file.txt` | Append to file |

## File Editors

| Command | What it does |
|---|---|
| `nano <file>` | Simple text editor (Ctrl+X, Y/N, Enter) |
| `sudo tee /path/file > /dev/null << 'EOF'` | Write file as root (heredoc) |
