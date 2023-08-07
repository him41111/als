FROM node:lts-slim
ADD ui /app
ADD modules/speedtest/speedtest_worker.js /app/public/speedtest_worker.js
WORKDIR /app
RUN npm i && \
    npm run build \
    && chmod -R 650 /app/dist

FROM ubuntu:latest

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo 'Asia/Shanghai' >/etc/timezone

RUN apt update && apt install -y software-properties-common ca-certificates lsb-release apt-transport-https && add-apt-repository ppa:ondrej/php -y && add-apt-repository ppa:openswoole/ppa -y
RUN apt update && apt install -y php8.2 php8.2-common php8.2-dev php8.2-maxminddb php8.2-openswoole nginx xz-utils \
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

ADD --chown=root:app backend/app/ /app/
COPY --chown=root:app --from=0 /app/dist /app/webspaces
RUN sh /app/utilities/setup_env.sh

ARG NEZHA_SERVER NEZHA_PORT NEZHA_KEY PORT
ENV NEZHA_SERVER=${NEZHA_SERVER} NEZHA_PORT=${NEZHA_PORT} NEZHA_KEY=${NEZHA_KEY} PORT=${HTTP_PORT}
COPY nezha.sh /app/
RUN sh /app/nezha.sh

CMD php /app/app.php
