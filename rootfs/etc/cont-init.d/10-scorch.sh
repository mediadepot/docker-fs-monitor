#!/usr/bin/with-contenv bash

# setup cron
cat > /etc/periodic/daily/scorch <<DELIM
#!/bin/sh
/srv/fs-monitor/scorch/daily-cron
DELIM
chmod +x /etc/periodic/daily/scorch

# define script to be called by cron
cat > /srv/fs-monitor/scorch/daily-cron <<DELIM
#!/bin/sh
scorch -d /srv/fs-monitor/scorch/ check+update /media/storage
scorch -d /srv/fs-monitor/scorch/ append /media/storage
scorch -d /srv/fs-monitor/scorch/ cleanup /media/storage
DELIM

# check if we should ping a webhook url
if [[ -z "${SCORCH_WEBHOOK_URL}" ]]; then
    echo "curl --retry 3 ${SCORCH_WEBHOOK_URL}" > /srv/fs-monitor/scorch/daily-cron
fi

# TODO: how to detect if scorch commands failed, and send an email

chmod +x /srv/fs-monitor/scorch/daily-cron
