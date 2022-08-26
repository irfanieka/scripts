#!/bin/sh
wget -O - https://raw.githubusercontent.com/nathanfleight/scripts/main/install_sockd_and_enable_it_at_boot_time.sh | bash
wget -O - https://raw.githubusercontent.com/nathanfleight/scripts/main/install_shadowsocks.sh | bash
apt -y install nethogs iftop
netstat -ntlp
apt -y upgrade;reboot
