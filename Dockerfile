FROM alpine:latest AS builder

RUN	apk add --no-cache openssh-server

RUN	<<EOL
	adduser -D -s /sbin/nologin proxy
	echo -n "proxy:*" | chpasswd -e
	mkdir -m 700 -p ~proxy/.ssh
	chown proxy: ~/proxy/.ssh
EOL

COPY	sshd_config /etc/ssh/sshd_config

RUN	mkdir -p /etc/ssh/sshd_config.d

COPY	entrypoint.sh /entrypoint.sh
RUN	chmod +x /entrypoint.sh


FROM scratch

COPY --from=builder / /

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
