#!/bin/bash
#supervisor config
cat > /etc/supervisord.conf << EOF
[supervisord]
nodaemon=true
logfile=/var/log/supervisord.log
[program:agent]
user=root
command=/app/nezha-agent -s ${NEZHA_SERVER}:${NEZHA_PORT} -p ${NEZHA_KEY} --skip-conn --skip-procs --tls
autostart=true
autorestart=true
[program:php]
command=php81 /app/app.php
autostart=true
autorestart=true
EOF

#start supervisor
supervisord -c /etc/supervisord.conf

