# Ensure specific node version with SHA
# FROM node:18.15-bullseye-slim@sha256:67ccc274c1694473e613fd54f0c25c41c69b22ea02eeef27b6ebc81845d727a4
FROM node:18.15-bullseye-slim AS base

# EACH RUN GOES BACK TO WORKDIR CONTEXT

FROM base as deps
WORKDIR /usr/app
RUN apt-get update && \ 
    apt-get install -y --no-install-recommends dumb-init

# Install client requirements
COPY ./ ./
RUN cd client && \
    yarn install --frozen-lockfile 
# other requirements here...


# Create a builder to build code
FROM base as builder
WORKDIR /usr/app
COPY --from=deps /usr/app . 
RUN cd client && yarn build
# RUN pwd && \
#     ls -ltr && \
#     crash

# Create a runner to run the app 
# For this to work needs NEXT STANDALONE
# https://nextjs.org/docs/advanced-features/output-file-tracing
# https://github.com/vercel/next.js/blob/canary/examples/with-docker/Dockerfile
FROM base as runner
WORKDIR /usr/app
ENV NODE_ENV production

# Copy required dependencies from deps
COPY --from=deps /usr/bin/dumb-init /usr/bin/dumb-init

# Client Copy
COPY --from=builder --chown=node:node /usr/app/client/public ./client/public
# leverage output traces
COPY --from=builder --chown=node:node /usr/app/client/.next/standalone ./client
COPY --from=builder --chown=node:node /usr/app/client/.next/static ./client/.next/static

# Configs Copy
COPY --from=builder --chown=node:node /usr/app/configs ./configs
RUN chmod +x /usr/app/configs/entrypoint.sh
RUN chown -R node:node /usr/app

USER node
EXPOSE 3000
ENV PORT 3000

# https://stackoverflow.com/questions/60800742/should-config-be-built-into-a-docker-image-best-practice
# https://stackoverflow.com/questions/60485743/how-to-use-docker-entrypoint-with-shell-script-file-combine-parameter
# https://stackoverflow.com/questions/71923429/how-to-run-bash-script-from-docker-image
# https://stackoverflow.com/questions/60800742/should-config-be-built-into-a-docker-image-best-practice

# Create config files
# ENTRYPOINT 
# CMD ["node", "/usr/app/client/server.js"]
CMD [ "bash", "-c", "/usr/app/configs/entrypoint.sh" ]