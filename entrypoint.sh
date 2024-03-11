#!/bin/bash

INSTALL=${INSTALL:-0}
CHECK_TIME=${CHECK_TIME:-30}

# exit on error
set -e

if [ $INSTALL -eq 1 ]; then
    subgit install /subgit/repo.git
else
    # start subgit fetch
    subgit fetch --async /subgit/repo.git
fi

# Register SIGTERM to stop service
trap "subgit shutdown /subgit/repo.git" SIGTERM

# log output
tail -f -F /subgit/repo.git/subgit/logs/daemon.0.log &

# wait until terminated
while true; do
    DAEMON_PID=$(head -1 /subgit/repo.git/subgit/daemon.pid)
    if [ -z "$DAEMON_PID" ]; then
        echo "Unable to get the PID of the subgit daemon"
        exit 1
    fi

    kill -0 $DAEMON_PID
    if [ $? -ne 0 ]; then
        echo "subgit daemon is dead"
        exit 1
    fi

    /sync.sh

    sleep $CHECK_TIME
done
