#!/bin/bash

set -e

# Update checker
if [ -f /etc/tecsafe_version ]; then
  LATEST_VERSION=$(curl -s https://api.github.com/repos/TECSAFE/rabbit-mq/commits/main | jq -r .sha || echo "unknown")
  if [ "$LATEST_VERSION" == "unknown" ]; then
    echo "Warning: Failed to fetch the latest version"
  elif [ "$(cat /etc/tecsafe_version)" == "$LATEST_VERSION" ]; then
    echo "MessageQueue is up to date"
  else
    echo "MessageQueue is outdated. Sleeping for 10 seconds just to annoy you into updating it."
    echo "Try: docker pull ghcr.io/tecsafe/rabbit-mq:latest"
    sleep 10
  fi
else
  echo "No version file found, skipping version check"
fi

if [ "$1" != 'rabbitmq-server' ]; then
  if [ -z "$2" ]; then
    exec /usr/local/bin/docker-entrypoint.sh $@
    exit 0
  fi
fi

/usr/local/bin/docker-entrypoint.sh rabbitmq-server &
PID=$!

until rabbitmqctl status > /dev/null 2>&1; do
  echo "Waiting for RabbitMQ to start..."
  sleep 5
done

function cleanup {
  echo "Stopping RabbitMQ..."
  rabbitmqctl stop
}

trap cleanup SIGTERM SIGINT EXIT

echo "Importing definitions..."
rabbitmqctl import_definitions /etc/rabbitmq/definitions.json
echo "RabbitMQ ready!"
wait $PID
