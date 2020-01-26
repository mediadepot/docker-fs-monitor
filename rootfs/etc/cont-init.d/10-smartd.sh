#!/usr/bin/with-contenv bash
# smart has its own daemon & notification system
# we will add custom notification script that pings our webhook server, and trigger it using the
# smartd test function, via a cron job. This will help ensure that smartd daemon is working??

# check if we should ping a webhook url
if [[ ! -z "${SMARTD_WEBHOOK_URL}" ]]; then
    # setup cron
cat > /etc/periodic/daily/smartd <<DELIM
#!/bin/sh
/srv/fs-monitor/smartd/daily-cron
DELIM
    chmod +x /etc/periodic/daily/smartd

    echo "/dev/sdc -m @webhook_test -M test" > /etc/smartd.conf.test

    # define script to be called by cron daily
cat > /srv/fs-monitor/smartd/daily-cron <<DELIM
#!/bin/sh
smartd -c /etc/smartd.conf.test -q onecheck
DELIM

    # define the smartd webhook handler script for testing
cat > /etc/smartd_warning.d/webhook_test <<DELIM
#!/bin/sh
curl --retry 3 ${SMARTD_WEBHOOK_URL}
DELIM

chmod +x /srv/fs-monitor/smartd/daily-cron
chmod +x /etc/smartd_warning.d/webhook_test
fi


# if a PUSHOVER_USER_KEY is provided, we should configure smartd to notify Pushover when a failure occurs

if [[ ! -z "${PUSHOVER_USER_KEY}" ]]; then
cat > /etc/smartd_warning.d/pushover <<DELIM
#!/usr/bin/env python

import sys
import os
import platform
import httplib
import urllib
import yaml

if __name__ == '__main__':

    # see https://pushover.net/api#messages for a list of priorities and messages
    payload = {
        'token': 'aNiH7or6Q5F1ennDtQpSvhbtY4ot6C', # this is the pushover depot app token.
        'user': '${PUSHOVER_USER_KEY}',
        'title': os.environ['SMARTD_SUBJECT'],
        'message': "Alert on %s (%s)\n%s" % (os.environ['SMARTD_DEVICE'], platform.node(), os.environ['SMARTD_MESSAGE'] ),
        'priority': 1
    }

    body = urllib.urlencode(payload)
    headers = { 'Content-type': 'application/x-www-form-urlencoded' }

    conn = httplib.HTTPSConnection('api.pushover.net:443')
    conn.request('POST', '/1/messages.json', body, headers)
    conn.getresponse()

DELIM
chmod +x /etc/smartd_warning.d/pushover
fi
