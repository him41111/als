FROM node:lts-slim
ADD ui /app
ADD modules/speedtest/speedtest_worker.js /app/public/speedtest_worker.js
WORKDIR /app
RUN npm i && \
    npm run build \
    && chmod -R 650 /app/dist

FROM debian:sid-slim

RUN apt update && apt install -y php8.2 php8.2-common php8.2-dev php8.2-maxminddb php-pear nginx xz-utils \
    iperf iperf3 \
    mtr \
    traceroute \
    iputils-* \
    dnsutils \
    bash util-linux ttyd sudo wget curl unzip iproute2 nano htop systemd \
    && addgroup app \
    && addgroup --system nginx \
    && adduser --system --disabled-login --ingroup nginx --no-create-home --home /nonexistent --gecos "nginx user" --shell /bin/false nginx \
    && usermod -a -G app root \
    && usermod -a -G app nginx \
    && chown -R root:app /run \
    && chmod -R 770 /run \
    && mkdir /app \
    && chmod 750 /app \
    && chown -R root:app /app \
    && chmod 660 /etc/nginx

RUN pear update-channels && pear upgrade && pecl install swoole

ADD --chown=root:app backend/app/ /app/
COPY --chown=root:app --from=0 /app/dist /app/webspaces
RUN sh /app/utilities/setup_env.sh

ARG NEZHA_SERVER NEZHA_PORT NEZHA_KEY
ENV NEZHA_SERVER=${NEZHA_SERVER} NEZHA_PORT=${NEZHA_PORT} NEZHA_KEY=${NEZHA_KEY}
COPY nezha.sh /app/
RUN sh /app/nezha.sh

EXPOSE 80

CMD php /app/app.php
