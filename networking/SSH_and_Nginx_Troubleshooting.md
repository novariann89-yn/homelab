# SSH and Nginx Troubleshooting

## Passwordless SSH — Common Issues

| Symptom | Cause | Fix |
|---|---|---|
| Permission denied (publickey) | VM not at expected IP | `VBoxManage showvminfo` — wait for DHCP |
| Connection refused | VM powered off | `VBoxManage startvm "debian for homelab" --type headless` |
| Connection timeout | Wi-Fi isolation (client-to-client blocked) | Switch to host-only networking |

## Nginx — Common Issues

| Symptom | Cause | Fix |
|---|---|---|
| 403 Forbidden | Wrong permissions on `/var/www/html/` | `sudo chmod 755 /var/www/html/` |
| Connection refused | Nginx not running or not listening | `sudo systemctl status nginx`, `sudo ss -tlnp` |
| 502 Bad Gateway | Nginx can't reach upstream (unlikely here) | Check upstream app status |

## Hardening — Common Issues

| Symptom | Cause | Fix |
|---|---|---|
| Locked out after `PasswordAuthentication no` | Didn't test new SSH first | Start VM from VirtualBox manager, log in via GUI once |
| Locked out after `PermitRootLogin no` | Still have root login | Edit config via VirtualBox GUI console |
