#!/bin/sh

# Generate unique host keys on first boot
ssh-keygen -A

# Add requested IPv4 and IPv6 addresses to the loopback interface
BIND_IPS="${BIND_IPS:-}"
for ip in ${BIND_IPS}; do
	echo "Assigning IP '${ip}' to loopback interface (lo)..."
	ip addr add "${ip}" dev lo || echo "Warning: Failed to add '${ip}'. Ensure you pass --cap-add=NET_ADMIN."
done

# Create and setup SSH users if they don't exist
SSH_USERS="${SSH_USERS:-}"
for user in ${SSH_USERS}; do
	if ! id -u "${user}" >/dev/null 2>&1; then
		echo "Creating user '${user}'..."
		adduser -D -s /sbin/nologin "${user}"
		echo -n "${user}:*" | chpasswd -e
	fi
	home=$(getent passwd "${user}" | cut -d: -f6)
	if [ -d "${home}" ] && [ ! -d "${home}/.ssh" ]; then
		echo "Creating .ssh directory for user '${user}'..."
		mkdir -m 700 -p "${home}/.ssh"
		chown "${user}:" "${home}/.ssh"
	fi
done

# Bind SSH to the container's primary IP address,
# to allow listening on 22/tcp for all assigned IPs (including those added to lo)
ssh_ip=$(hostname -i | awk '{print $1}')
exec /usr/sbin/sshd -D -e -o "ListenAddress ${ssh_ip}"
