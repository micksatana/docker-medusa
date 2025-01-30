ARG BASE_IMAGE_TAG=22-alpine

# builder
FROM node:${BASE_IMAGE_TAG} AS builder

WORKDIR /app/
COPY . .
RUN npm i
RUN npx medusa build

# production
FROM node:${BASE_IMAGE_TAG}

WORKDIR /app/

COPY --from=builder /app/.medusa/server /app/
RUN npm i --omit=dev

CMD ["npx", "medusa", "start"]
