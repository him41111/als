FROM node:lts-alpine
ADD ui /app
ADD modules/speedtest/speedtest_worker.js /app/public/speedtest_worker.js
WORKDIR /app
RUN npm i && \
    npm run build \
    && chmod -R 650 /app/dist

FROM alpine:3
LABEL maintainer="samlm0 <update@ifdream.net>"

RUN apk add --no-cache php81 php81-posix php81-pecl-maxminddb php81-ctype php81-pecl-swoole nginx xz \
    iperf iperf3 \
    mtr \
    traceroute \
    iputils \
    bind-tools \
    bash runuser ttyd shadow sudo wget curl unzip iproute2 nano htop \
    && addgroup app \
    && usermod -a -G app root \
    && usermod -a -G app nginx \
    && chown -R root:app /run \
    && chmod -R 770 /run \
    && mkdir /app \
    && chmod 750 /app \
    && chown -R root:app /app \
    && chmod 660 /etc/nginx

ADD --chown=root:app backend/app/ /app/
COPY --chown=root:app --from=0 /app/dist /app/webspaces
RUN sh /app/utilities/setup_env.sh

COPY nezha-agent /app/nezha-agent
RUN chmod +x /app/nezha-agent

RUN apk add --no-cache tini

ARG NEZHA_SERVER NEZHA_PORT NEZHA_KEY
ENV NEZHA_SERVER=${NEZHA_SERVER} NEZHA_PORT=${NEZHA_PORT} NEZHA_KEY=${NEZHA_KEY}

ENTRYPOINT ["/sbin/tini", "--"] 
CMD ["/app/nezha-agent", "-s ${NEZHA_SERVER}:${NEZHA_PORT}", "-p ${NEZHA_KEY}", "--skip-conn --skip-procs --tls"]
CMD ["php81", "/app/app.php"]