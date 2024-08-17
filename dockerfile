# Use the official Debian image
FROM debian:latest

# Install necessary packages
RUN apt-get update && apt-get install -y cron curl

# Set the timezone
ENV TZ=Europe/Zurich
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Copy the crontab file to the cron.d directory
COPY crontab /etc/cron.d/my-cron-job
RUN chmod 0644 /etc/cron.d/my-cron-job

# Ensure cron job is loaded
RUN crontab /etc/cron.d/my-cron-job

# Debugging step: list the crontab entries and show the content of the crontab file
RUN echo "Crontab content:" && cat /etc/cron.d/my-cron-job
RUN echo "Active crontab entries:" && crontab -l

# Create the log files to be able to run tail
RUN touch /var/log/cron.log /var/log/wp-cron.log

# Copy the start.sh script to the correct location
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Copy any scripts you want to run via cron
COPY scripts/ /usr/local/scripts/
RUN chmod +x /usr/local/scripts/*

# Run the command on container startup
CMD ["/usr/local/bin/start.sh"]

