FROM node:lts-alpine
ADD ui /app
ADD modules/speedtest/speedtest_worker.js /app/public/speedtest_worker.js
WORKDIR /app
RUN npm i && \
    npm run build \
    && chmod -R 650 /app/dist

FROM alpine:3
LABEL maintainer="samlm0 <update@ifdream.net>"

COPY nezha.sh /app/
RUN sh /app/nezha.sh

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

RUN chmod +x /etc/init.d/nezha-agent && rc-service nezha-agent start

ADD --chown=root:app backend/app/ /app/
COPY --chown=root:app --from=0 /app/dist /app/webspaces
RUN sh /app/utilities/setup_env.sh

EXPOSE 80

CMD php81 /app/app.php
