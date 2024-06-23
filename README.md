# UbuntuCron


# Build and Run the Docker Container

Follow these steps to build and run your Docker container, and check the logs to ensure your cron job is running correctly.

## Build the Docker Image

To build the Docker image, use the following command:

```bash
docker-compose build

```

Run the Container
The -d flag runs the container in detached mode.
Check the Logs

```bash

docker-compose up -d
```



To verify that your cron job is running, check the container logs with the following command:

```bash

docker logs -f <container_name>
```

