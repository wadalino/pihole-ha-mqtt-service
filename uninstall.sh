systemctl stop mqtt-ha.service
systemctl disable mqtt-ha.service
rm -rf /etc/systemd/system/mqtt-ha.service
systemctl daemon-reload

rm -rf /root/ha-mqtt-service
rm -rf /root/outFiles
rm -f /etc/ha-mqtt-environment
