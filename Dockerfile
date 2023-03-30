# Ensure specific node version with SHA
# FROM node:18.15-bullseye-slim@sha256:67ccc274c1694473e613fd54f0c25c41c69b22ea02eeef27b6ebc81845d727a4
FROM node:18.15-bullseye-slim AS base

FROM base as deps
WORKDIR /usr/app
RUN apt-get update && \ 
    apt-get install -y --no-install-recommends

# Install client requirements
COPY ./client ./client
RUN cd client && \
    yarn install --frozen-lockfile 
# other requirements here...


# Create a builder to build code
FROM base as builder
WORKDIR /usr/app
COPY --from=deps /usr/app . 
RUN cd client && yarn build


# Create a runner to run the app 
# For this to work needs NEXT STANDALONE
# https://nextjs.org/docs/advanced-features/output-file-tracing
# https://github.com/vercel/next.js/blob/canary/examples/with-docker/Dockerfile
FROM base as runner
WORKDIR /usr/app/production
ENV NODE_ENV production

COPY --from=builder /usr/app/client/public ./public
# leverage output traces
COPY --from=builder --chown=node:node /usr/app/client/.next/standalone ./
COPY --from=builder --chown=node:node /usr/app/client/.next/static ./.next/static

USER node

EXPOSE 3000
ENV PORT 3000

CMD ["node", "server.js"]