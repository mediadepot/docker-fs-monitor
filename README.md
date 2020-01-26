
# Requirements


# Environmental
The following environmental variables must be populated, when running container
- SMARTD_WEBHOOK_URL
- SCORCH_WEBHOOK_URL
- PUSHOVER_USER_KEY

# Ports
The following ports must be mapped, when running container


# Volumes
The following volumes must be mapped, when running container

- /opt/mediadepot/smartmontools/smartd.conf:/etc/smartd.conf:ro
- /srv/fs-monitor/scorch
- /srv/fs-monitor/smartd

