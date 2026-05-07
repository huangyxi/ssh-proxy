#!/bin/sh

# Generate unique host keys on first boot
ssh-keygen -A

# Add requested IPv4 and IPv6 addresses to the loopback interface
if [ -n "$BIND_IPS" ]; then
	for ip in $BIND_IPS; do
		echo "Assigning IP $ip to loopback interface (lo)..."
		ip addr add "$ip" dev lo || echo "Warning: Failed to add $ip. Ensure you pass --cap-add=NET_ADMIN."
	done
fi

# Secure authorized_keys if mapped by the user
if [ -f "/authorized_keys" ]; then
	cp /authorized_keys /home/proxy/.ssh/authorized_keys
	chown proxy:proxy /home/proxy/.ssh/authorized_keys
	chmod 600 /home/proxy/.ssh/authorized_keys
fi

# Start SSH daemon
exec /usr/sbin/sshd -D -e
