# UpTime Report Service

systemd oneshot service that writes server uptime and load averages to `/var/www/html/uptime.txt`, served by Nginx.

## Files

| File | Purpose |
|---|---|
| `/usr/local/bin/uptime-report.sh` | Bash script: asks kernel via `uptime -p` + `/proc/loadavg`, writes to `/var/www/html/uptime.txt` |
| `/etc/systemd/system/uptime-report.service` | systemd unit: `Type=oneshot`, `ExecStart=/usr/local/bin/uptime-report.sh`, `After=network.target`, `WantedBy=multi-user.target` |

## How It Works

1. Kernel keeps boot time in memory
2. `uptime -p` reads it → returns string like "up 2 days, 4 hours"
3. Script writes via `>` to `/uptime.txt` (overwrite) then `>>` to append loadavg
4. Nginx serves `/uptime.txt` at `http://192.168.56.101/uptime.txt`

## Troubleshooting

- **exit-code errors after enable --now**: check shebang `#!/bin/bash` is the first line; missing shebang = 203/EXEC
- **CURLOPT verbose output**: manual `sudo /usr/local/bin/uptime-report.sh` writes the file directly, so curl shows stale data even if systemd run failed
- **Expected result**: `curl http://192.168.56.101/uptime.txt` shows two lines (uptime + loadavg)

## Verification

```bash
curl -s http://192.168.56.101/uptime.txt
# Output:
# Server online since: up X days, Y hours
# Average load: 0.01 0.03 0.05
```
