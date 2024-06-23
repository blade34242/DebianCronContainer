
# Docker Cron Job Setup

This repository provides a setup for running cron jobs in a Docker container. The following instructions will guide you through building the Docker image, running the container, and verifying that your cron job is running correctly.

## Prerequisites

- Docker installed on your machine
- Docker Compose installed on your machine

## Getting Started

### Build the Docker Image

To build the Docker image, use the following command:

```bash
docker-compose build
```

### Run the Container

To start the container, run the following command:

```bash
docker-compose up -d
```

The `-d` flag runs the container in detached mode.

### Verify the Cron Job

To verify that your cron job is running, check the container logs with the following command:

```bash
docker logs -f <container_name>
```

Replace `<container_name>` with the actual name of your Docker container. This command will follow the logs and display them in real-time, helping you ensure that your cron job is executed as expected.

## File Structure

```
.
├── Dockerfile
├── docker-compose.yml
├── cron
└── backup.sh
```

- **Dockerfile**: Contains the instructions to build the Docker image.
- **docker-compose.yml**: Configuration file for Docker Compose.
- **cron**: Contains the cron job schedule.
- **backup.sh**: The script to be executed by the cron job.

## Dockerfile

```Dockerfile
FROM ubuntu:latest

# Install cron
RUN apt-get update && apt-get install -y cron

# Set the timezone to Switzerland (Europe/Zurich)
ENV TZ=Europe/Zurich
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Copy the crontab file to the cron.d directory
COPY cron /etc/cron.d/cron
RUN chmod 0644 /etc/cron.d/cron

# Apply the cron job
RUN crontab /etc/cron.d/cron

# Create the log file to be able to run tail
RUN touch /var/log/backup.log

# Ensure the backup script is executable
COPY backup.sh /usr/local/bin/backup.sh
RUN chmod +x /usr/local/bin/backup.sh

# Run the command on container startup
CMD cron && tail -f /var/log/backup.log
```

## Docker Compose File (`docker-compose.yml`)

```yaml
version: '3.8'

services:
  backup:
    build: .
    volumes:
      - ./backup.sh:/usr/local/bin/backup.sh
      - ./backups:/backups
    logging:
      driver: gelf
      options:
        gelf-address: "udp://172.18.0.4:1524"
        tag: "backup-job"
    networks:
      - graylog_graylog

networks:
  graylog_graylog:
    external: true
```

## Crontab File (`cron`)

```cron
* * * * * /usr/local/bin/backup.sh >> /var/log/backup.log 2>&1
```

## Backup Script (`backup.sh`)

Ensure your `backup.sh` script is executable and contains the necessary commands:

```bash
#!/bin/bash

echo "Starting backup: $(date)"

# Example backup tasks
# Replace with your actual backup commands
# mysqldump -u user -p password database > /backups/db_backup.sql
# rsync -a /data /backups/data

echo "Backup completed: $(date)"
```

Make the script executable:

```bash
chmod +x backup.sh
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
