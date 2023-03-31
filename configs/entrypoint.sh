#!/bin/sh -x

# .env
sed -e "s|env_port|$P9K_TTY|g" \
    -e "s|env_secret|$TERM_PROGRAM|g" \
    -e "s|env_token_secret|$WSL_DISTRO_NAME|g" \
    .env.tpl > .env



# config.json
sed -e "s|env_user|$P9K_TTY|g" \
    -e "s|env_pass|$TERM_PROGRAM|g" \
    config.json.tpl > config.json