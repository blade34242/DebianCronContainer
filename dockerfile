FROM ubuntu:latest

# Install cron
RUN apt-get update && apt-get install -y cron

# Set the timezone
ENV TZ=Europe/Zurich
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Copy the crontab file to the cron.d directory
COPY cron /etc/cron.d/cron
RUN chmod 0644 /etc/cron.d/cron

# Apply the cron job
RUN crontab /etc/cron.d/cron

# Create the log file to be able to run tail
RUN touch /var/log/backup.log

# Run the command on container startup
CMD cron && tail -f /var/log/backup.log

