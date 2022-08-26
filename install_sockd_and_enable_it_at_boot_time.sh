#!/bin/sh
apt update;apt -y install gcc cmake binutils build-essential net-tools
ifaceName=$(ip link | awk -F: '$0 !~ "lo|vir|wl|^[^0-9]"{print $2;getline}')
wget https://www.inet.no/dante/files/dante-1.4.3.tar.gz
tar -xf dante-1.4.3.tar.gz
cd dante-1.4.3
./configure
make
make install

cat > /etc/sockd.conf <<EOF
logoutput: /var/log/socks.log

internal: $ifaceName port = 1080
external: $ifaceName

socksmethod: username

user.unprivileged: nobody
user.privileged: root

client pass {
from: 0.0.0.0/0 to: 0.0.0.0/0
log: error
}

socks pass {
from: 0.0.0.0/0 to: 0.0.0.0/0
command: connect
log: error
socksmethod: username
protocol: tcp udp
}
EOF

/usr/local/sbin/sockd -D &

useradd --shell /usr/sbin/nologin mikrotik999
echo "mikrotik999:Elibawnos" | chpasswd

netstat -ntlp

cat > /etc/systemd/system/startsockd.service <<EOL
[Unit]
Description=start sockd at boot time
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=1
User=root
ExecStartPre=
ExecStart=/bin/bash -c '/usr/local/sbin/sockd -D &'
ExecStartPost
ExecStop=
ExecReload=

[Install]
WantedBy=multi-user.target
EOL

systemctl daemon-reload
systemctl enable startsockd.service
systemctl start startsockd.service
systemctl status startsockd.service


