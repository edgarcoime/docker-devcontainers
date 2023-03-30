# Ensure specific node version with SHA
# FROM node:18.15-bullseye-slim@sha256:67ccc274c1694473e613fd54f0c25c41c69b22ea02eeef27b6ebc81845d727a4

# Seperate concerns from build image and production image



# Ensure that the version used is EXACT
FROM node:18.15-bullseye-slim AS base


# install client dependencies when needed (image & node)
FROM base as deps_client
WORKDIR /usr/app/client
RUN apt-get update && \ 
    apt-get install -y --no-install-recommends
# Update and get yarn
RUN npm install -g -y yarn
# Copy package.json and yarn.lock to install deps
COPY /client/package*.json /client/yarn.lock* ./
RUN yarn install --frozen-lockfile


# Rebuild the source code only when needed
FROM base as builder
WORKDIR /usr/app
COPY --from=deps_client /usr/app/client/node_modules /client
RUN yarn build


# Create a runner to run the app
FROM base as runner
WORKDIR /usr/app
ENV NODE_ENV production

RUN addgroup --system --gid 1001 nodejs
RUN addgroup --system --uid 1001 nextjs

COPY --from=builder /client/public /client/public

COPY --from=builder --chown=nextjs:nodejs /usr/app/client/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /usr/app/client/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT 3000

CMD ["node", "server.js"]









# # Optimize Node.js tooling for production
# ENV NODE_ENV production

# # Setup work directory and copy contents
# WORKDIR /usr/app
# COPY . /usr/app/

# # Navigate to client and ensure dependencies
# # Ensure only production dependencies are installed
# RUN cd client \ 
#     yarn install --production 

# # Don't run containers as root
# USER node
# CMD "yarn" "start"