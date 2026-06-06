#!/bin/bash

# Determine which env file to use (defaults to de)
ENV_TYPE=${1:-de}

if [ "$ENV_TYPE" = "sm" ]; then
    ENV_FILE=".env.sm"
elif [ "$ENV_TYPE" = "de" ]; then
    ENV_FILE=".env.de"
else
    echo "Unknown environment type: $ENV_TYPE. Using 'de' default."
    ENV_FILE=".env.de"
fi

if [ -f "$ENV_FILE" ]; then
    # Load and export all variables in the selected env file
    export $(grep -v '^#' "$ENV_FILE" | xargs)
    echo "Successfully loaded environment from $ENV_FILE"
else
    echo "Error: $ENV_FILE not found!"
    return 1 2>/dev/null || exit 1
fi
