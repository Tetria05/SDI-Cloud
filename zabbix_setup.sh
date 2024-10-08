#! /bin/bash
# contributers: Guus, Noa, Bodhi
# https://www.zabbix.com/download?zabbix=7.0&os_distribution=ubuntu&os_version=22.04&components=agent&db=&ws=

IP=$(hostname -I | awk '{print $1}')
SERVER_IP=10.24.14.6
SERVER_NAME=$(hostname)

echo ---------- Install Zabbix ----------
wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-2+ubuntu22.04_all.deb
dpkg -i zabbix-release_7.0-2+ubuntu22.04_all.deb
apt update 

apt install zabbix-agent -y

systemctl restart zabbix-agent
systemctl enable zabbix-agent 


echo ---------- Zabbix config ----------
sed -i "s/ServerActive=127.0.0.1/ServerActive=${SERVER_IP}/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/Hostname=Zabbix server/Hostname=${SERVER_NAME}/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/# HostMetadata=/HostMetadata=Linux servers/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/# HostInterface=/HostInterface=${IP}/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/Server=127.0.0.1/Server=${SERVER_IP}/" /etc/zabbix/zabbix_agentd.conf

echo ---------- Restart Zabbix_agent ----------
systemctl restart zabbix-agent