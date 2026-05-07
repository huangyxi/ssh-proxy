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
	if id -u "${user}" >/dev/null 2>&1; then
		continue
	fi
	echo "Creating user '${user}'..."
	adduser -D -s /sbin/nologin "${user}"
	echo -n "${user}:*" | chpasswd -e
	mkdir -m 700 -p "/home/${user}/.ssh"
	chown "${user}:" "/home/${user}/.ssh"
	echo "User '${user}' created successfully."
done

# Start SSH daemon
exec /usr/sbin/sshd -D -e
