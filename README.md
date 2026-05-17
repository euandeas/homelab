# Homelab

Personal homelab configuration for **Fedora Server**, running containers via **Podman** with **systemd Quadlets**.

This repository contains my container definitions and configurations for networking, media, and utility services. Everything is managed as systemd user units through Podman Quadlets and deployed using the included `symlink.sh` script.

## Quick Start

### 1. Clone and Link

Clone the repository and run the symlink script to link all Quadlet directories into `~/.config/containers/systemd/`:

```
cd ~
git clone https://github.com/euandeas/homelab
cd homelab
./setup.sh
```

### 2. Configure

Before deploying, do a project-wide find-and-replace with your own details:

| Placeholder | Replace with |
| --- | --- |
| `example.com` | Your domain name |
| `/home/user/` | Your home directory path |
| `user@.host` | Your systemd username (for `--machine`) |
| `Player1` | Your Minecraft username |
| `192.168.0.0/24` | Your local subnet |
| `192.168.0.100` | Your local DNS server IP |

### 3. Create Environment File

Some containers require environment variables. Create a `.env` file in the repository root:

```
touch ~/homelab/.env
```

Add any required keys (e.g. `TAILSCALE_AUTH_KEY`, API tokens for DDNS, etc.).

### 4. Start Services

Reload systemd and enable the containers you need:

```
systemctl --user daemon-reload
systemctl --user enable --now glance.service
systemctl --user enable --now minecraft.service
```

### 5. Open Firewall

Allow web traffic through the firewall for Caddy and other web-facing services:

```
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --add-service=https --permanent
sudo firewall-cmd --reload
```

### 6. SELinux

Some containers require specific SELinux booleans to be enabled:

```
sudo semanage boolean -m --on container_use_devices
sudo semanage boolean -m --on virt_sandbox_use_all_caps
sudo semanage boolean -m --on virt_use_nfs
```

## Useful Commands

| Action | Command |
| --- | --- |
| Reload after changes | `systemctl --user daemon-reload` |
| Check status | `systemctl --user status <name>.service` |
| Follow logs | `journalctl --user -u <name>.service -f` |
| List running containers | `podman ps` |

## Extra Setup

### DNS over TLS Certificate

The Technitium container mounts a `.pfx` certificate from `networking/dns/certs/` for DNS over TLS. After generating or renewing the cert, fix the permissions (requires sudo due to SELinux context):

```
sudo chcon -Rt container_file_t ~/homelab/networking/dns/certs/
sudo chmod 644 ~/homelab/networking/dns/certs/cert.pfx
```

### Setup DNS

Make sure that the server is using technitium DNS.

```
sudo tee /etc/systemd/resolved.conf.d/dns.conf << 'EOF'
[Resolve]
DNS=127.0.0.1
FallbackDNS=1.1.1.1#cloudflare-dns.com 9.9.9.9#dns.quad9.net
EOF

sudo systemctl restart systemd-resolved
```

### Cockpit Behind a Reverse Proxy

To serve Cockpit behind Caddy, create `/etc/cockpit/cockpit.conf`:

```
[WebService]
Origins = https://cockpit.example.com https://192.168.0.100:9090 wss://cockpit.example.com
ProtocolHeader = X-Forwarded-Proto
```

## References

- Technitium + Cloudflare DoH: https://ambientnode.uk/setting-up-dns-over-https-on-technitium-with-cloudflare/
