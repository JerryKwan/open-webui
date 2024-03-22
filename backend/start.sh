#!/usr/bin/env bash

# Get the INCLUDE_OLLAMA_ENV environment variable whcih is set in the Dockerfile
# This includes the ollama in the image
INCLUDE_OLLAMA=${INCLUDE_OLLAMA_ENV:-false}

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR" || exit

KEY_FILE=.webui_secret_key

PORT="${PORT:-8080}"
if test "$WEBUI_SECRET_KEY $WEBUI_JWT_SECRET_KEY" = " "; then
  echo "No WEBUI_SECRET_KEY provided"

  if ! [ -e "$KEY_FILE" ]; then
    echo "Generating WEBUI_SECRET_KEY"
    # Generate a random value to use as a WEBUI_SECRET_KEY in case the user didn't provide one.
    echo $(head -c 12 /dev/random | base64) > "$KEY_FILE"
  fi

  echo "Loading WEBUI_SECRET_KEY from $KEY_FILE"
  WEBUI_SECRET_KEY=$(cat "$KEY_FILE")
fi

if [ "$INCLUDE_OLLAMA" = "true" ]; then
    echo "INCLUDE_OLLAMA is set to true, starting ollama serve."
    ollama serve &
fi

WEBUI_SECRET_KEY="$WEBUI_SECRET_KEY" exec uvicorn main:app --host 0.0.0.0 --port "$PORT" --forwarded-allow-ips '*'
