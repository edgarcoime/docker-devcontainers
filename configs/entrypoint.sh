#!/usr/bin/dumb-init /bin/sh

# Fill in runtime values for configuration
# https://www.warp.dev/terminus/dockerfile-run-sh

# .env
sed -e "s|@ENV_PORT@|$ENV_PORT|g" \
    -e "s|@ENV_SECRET@|$ENV_SECRET|g" \
    -e "s|@ENV_TOKEN_SECRET@|$ENV_TOKEN_SECRET|g" \
    /usr/app/configs/.env.tpl > /usr/app/configs/.env


# config.json
sed -e "s|@ENV_USER@|$ENV_USER|g" \
    -e "s|@ENV_PASS@|$ENV_PASS|g" \
    /usr/app/configs/config.json.tpl > /usr/app/configs/config.json

# Run the main container command
# APPLICATION ENTRY POINT
dumb-init node /usr/app/client/server.js