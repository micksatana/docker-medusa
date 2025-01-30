ARG BASE_IMAGE_TAG=22-alpine

# Base image
FROM node:${BASE_IMAGE_TAG} AS base

# Dependencies
FROM base AS deps

WORKDIR /app/
COPY package.json /app/
RUN npm i

# Builder
FROM base AS builder

WORKDIR /app/
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npx medusa build

# Runner
FROM base AS runner

RUN addgroup -g 1001 -S medusa
RUN adduser -S medusa -u 1001

COPY --from=builder --chown=medusa:medusa /app/node_modules /app/node_modules
COPY --from=builder --chown=medusa:medusa /app/.medusa/server /app

USER medusa

WORKDIR /app
RUN npx medusa telemetry --disable

CMD ["npx", "medusa", "start"]
