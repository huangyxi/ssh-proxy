FROM alpine:latest AS builder

RUN	apk add --no-cache openssh-server

COPY	sshd_config /etc/ssh/sshd_config

RUN	mkdir -p /etc/ssh/sshd_config.d

COPY	entrypoint.sh /entrypoint.sh
RUN	chmod +x /entrypoint.sh


FROM scratch

COPY --from=builder / /

ENV	BIND_IPS=
ENV	SSH_USERS=proxy

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
