#!/bin/bash

touch /var/log/wp_cron.log
echo "Instance started" >> /var/log/cron-docker-refresher.log

# Apply the cron job from the crontab file
crontab /etc/cron.d/my-cron-job


# Start cron
cron



# Tail the log files
tail -f /var/log/cron-docker-refresher.log
