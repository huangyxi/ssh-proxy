# SSH Proxy Docker

A lightweight, containerized SSH proxy server built on Alpine Linux. This image provides a secure SSH gateway that can bind to multiple IP addresses and support multiple users, making it suitable for SSH tunneling, port forwarding, and reverse-access workflows.

## Features

- **Multi-IP Binding**: Bind SSH to multiple IPv4/IPv6 addresses on the loopback interface
- **SSH Tunneling Ready**: Use with `ssh -J` for simple jump-host tunneling without extra sshd changes
- **Long-Lived Connections**: Preconfigured keep-alive (15-second intervals) for stable, persistent SSH tunnels
- **Fine-Tuned Security**: Custom `sshd_config` with key-based auth, TCP forwarding, and reverse tunnel support

## Quick Setup

> [!CAUTION]
> Do NOT use `network_mode: host`
>
> This container requires network isolation. Using host network mode will cause IP binding to fail and may expose security vulnerabilities. Always use bridge mode (Docker's default).

See [docker-compose.yml.example](docker-compose.yml.example) for a complete, self-contained example with all configuration options.

Minimum requirements:
- Docker/Docker Compose
- SSH public key(s) for `authorized_keys`

## Usage

### Use as a simple SSH jump host

1. Start the jump host:
```bash
cp docker-compose.yml.example docker-compose.yml
cat ~/.ssh/id_ed25519.pub > authorized_keys # add all allowed client and server public keys to this file
docker-compose up -d
```

2. Create a server-side reverse tunnel:
```bash
ssh -CNR server-ip:22:localhost:22 -N proxy@proxy-host
```
*See [Capabilities](#capabilities) and [sysctl settings](#sysctl-settings) in [Configuration](#configuration) for IP binding and non-root binding to privileged ports.*

3. Configure the client jump host:

```conf
# .ssh/config snippet for jump host
Host JumpHost
	HostName proxy-host
	User proxy
	Port 2222
```

```bash
# When normal SSH access is available
ssh -J JumpHost user@server-ip
```

## Configuration

All configuration options are documented in [docker-compose.yml.example](docker-compose.yml.example):

### Environment variables
- `BIND_IPS`: Additional IP addresses to bind (separated by spaces)
- `SSH_USERS`: SSH users to create (separated by spaces)

### Volume mounts
- `/home/proxy/.ssh/authorized_keys`: SSH public keys for authentication (use matching paths for additional users in `SSH_USERS`)
- `/etc/ssh/sshd_config.d`: Additional SSH daemon configuration files (optional)

### Capabilities
- `NET_ADMIN` capability (required for IP binding)

### sysctl settings
- `net.ipv4.ip_unprivileged_port_start` and `net.ipv6.ip_unprivileged_port_start` to allow non-root binding to ports below 1024 (Linux kernel 4.11+ required)

## Security

The SSH daemon is pre-configured with:
- Key-based authentication only
- TCP forwarding and reverse tunnels enabled
- No interactive shell, TTY, X11 forwarding, or agent forwarding
- Keep-alive (15-second intervals) to detect dead connections

See [sshd_config](sshd_config) for details.
