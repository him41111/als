FROM node:lts-alpine
ADD ui /app
ADD modules/speedtest/speedtest_worker.js /app/public/speedtest_worker.js
WORKDIR /app
RUN npm i && \
    npm run build \
    && chmod -R 650 /app/dist

FROM alpine:3.16
LABEL maintainer="samlm0 <update@ifdream.net>"

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
    && apk add --no-cache php81 php81-pecl-maxminddb php81-ctype php81-pecl-swoole nginx xz \
    iperf iperf3 \
    mtr \
    traceroute \
    iputils \
    bind-tools \
    bash runuser ttyd cpulimit shadow \
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

CMD php81 /app/app.php
