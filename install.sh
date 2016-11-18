#!/bin/sh

set -ex

SERVICE_ACCOUNT=journald-cloudwatch-logs
SYSTEMD_GROUP=systemd-journal

useradd -s /usr/sbin/nologin -r -M -N $SERVICE_ACCOUNT -G $SYSTEMD_GROUP
mkdir -p /var/lib/journald-cloudwatch-logs
chown $SERVICE_ACCOUNT:$SYSTEMD_GROUP /var/lib/journald-cloudwatch-logs

cat <<EOF > /etc/systemd/system/journald-cloudwatch.service
[Unit]
Description=journald-cloudwatch-logs
Wants=basic.target
After=basic.target network.target

[Service]
User=$SERVICE_ACCOUNT
Group=$SYSTEMD_GROUP
ExecStart=/usr/local/bin/journald-cloudwatch-logs /etc/journald-cloudwatch.conf
KillMode=process
Restart=on-failure
RestartSec=42s

[Install]
WantedBy=getty.target
EOF

chmod 644 /etc/systemd/system/journald-cloudwatch.service

cat <<EOF > /etc/journald-cloudwatch.conf
log_group = "/journald-logs"
state_file = "/var/lib/journald-cloudwatch-logs/state"
log_priority = "info"
EOF

systemctl enable journald-cloudwatch.service
systemctl start journald-cloudwatch.service

systemctl status journald-cloudwatch.service
