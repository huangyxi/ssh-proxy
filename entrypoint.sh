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

# Start SSH daemon
exec /usr/sbin/sshd -D -e
