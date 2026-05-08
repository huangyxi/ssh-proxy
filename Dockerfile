FROM alpine:latest

RUN	apk add --no-cache openssh-server

COPY	sshd_config /etc/ssh/sshd_config

COPY	entrypoint.sh /entrypoint.sh
RUN	chmod +x /entrypoint.sh

ENV	BIND_IPS=
ENV	SSH_USERS=proxy

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
