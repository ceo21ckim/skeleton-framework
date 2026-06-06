#!/bin/bash

# Determine which env file to use or keep existing environment
if [ -n "$1" ]; then
    ENV_TYPE=$1
    if [ "$ENV_TYPE" = "sm" ]; then
        ENV_FILE=".env.sm"
    elif [ "$ENV_TYPE" = "de" ]; then
        ENV_FILE=".env.de"
    else
        echo "Unknown environment type: $ENV_TYPE. Using 'de' default."
        ENV_FILE=".env.de"
    fi

    if [ -f "$ENV_FILE" ]; then
        export $(grep -v '^#' "$ENV_FILE" | xargs)
        echo "Loaded environment from explicitly specified $ENV_FILE"
    else
        echo "Error: $ENV_FILE not found!"
        exit 1
    fi
else
    # No argument passed: check if environment is already active in parent shell
    if [ -n "$FRONT_PORT" ] || [ -n "$BACK_PORT" ] || [ -n "$FRONT_URL" ]; then
        echo "Detected existing active environment variables (Port: $FRONT_PORT). Bypassing automatic reload."
    else
        # Default fallback to .env.de
        ENV_FILE=".env.de"
        if [ -f "$ENV_FILE" ]; then
            export $(grep -v '^#' "$ENV_FILE" | xargs)
            echo "No active environment detected. Loaded default $ENV_FILE"
        else
            echo "Error: Default $ENV_FILE not found!"
            exit 1
        fi
    fi
fi

# Kill any existing Django backend processes running on port 8000
pkill -9 -f 8000 || true

# Start Django Backend Server with ultra low-memory flags to prevent OOM Killer
python3 backend/manage.py runserver 0.0.0.0:8000 --noreload --nothreading --skip-checks
