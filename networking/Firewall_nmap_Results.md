# Firewall Setup — nmap Results

## Initial State

When `nmap -p- 192.168.56.101` returned `host may be down`, two issues were diagnosed:

1. **DNS warnings**: host-only networking has no DNS server; fix: use `-n` flag
2. **Ping blocked by UFW**: UFW drops ICMP by default; fix: use `-Pn` flag
3. **Actual problem**: VM was powered OFF — `VBoxManage showvminfo` showed `powered off`

## Verified Result

```bash
nmap -n -Pn -p- 192.168.56.101
# PORT   STATE SERVICE
# 22/tcp  open  ssh
# 80/tcp  open  http
```

Only 22 (SSH) + 80 (HTTP) open. All 65,533 other ports filtered (closed by UFW default-deny).

## nmap Flags Reference

| Flag | Meaning |
|---|---|
| `-p-` | Scan all 65535 ports |
| `-n` | Skip DNS reverse-lookup |
| `-Pn` | Skip ping discovery (host may block ICMP) |
| `-sV` | Service version detection |
