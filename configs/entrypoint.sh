#!/bin/sh -x

# .env
sed -e "s|env_port|$OS_ENV_PORT|g" \
    -e "s|env_secret|$OS_ENV_SECRET|g" \
    -e "s|env_token_secret|$OS_ENV_TOKEN_SECRET|g" \
    .env.tpl > .env


# config.json
sed -e "s|env_user|$OS_ENV_USER|g" \
    -e "s|env_pass|$OS_ENV_PASS|g" \
    config.json.tpl > config.json