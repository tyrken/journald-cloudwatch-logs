#!/bin/sh

set -ex

SERVICE_ACCOUNT=journald-cloudwatch-logs
SYSTEMD_GROUP=systemd-journal
LOG_LEVEL_TO_SHIP=info
LOG_GROUP_NAME=/journald

curl -fsSL https://github.com/tyrken/journald-cloudwatch-logs/releases/download/v1.0-addons-1/journald-cloudwatch-logs -o /usr/local/bin/journald-cloudwatch-logs
chmod a+x /usr/local/bin/journald-cloudwatch-logs

if getent passwd $SERVICE_ACCOUNT > /dev/null 2>&1; then
    echo "$SERVICE_ACCOUNT already exists, using..."
else
    useradd -s /usr/sbin/nologin -r -M -N $SERVICE_ACCOUNT -G $SYSTEMD_GROUP
fi

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
log_group = "$LOG_GROUP_NAME"
state_file = "/var/lib/journald-cloudwatch-logs/state"
log_priority = "$LOG_LEVEL_TO_SHIP"
EOF

systemctl enable journald-cloudwatch.service
systemctl start journald-cloudwatch.service

systemctl status journald-cloudwatch.service
