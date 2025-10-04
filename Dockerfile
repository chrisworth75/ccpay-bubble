FROM node:18-alpine as base

ENV WORKDIR /opt/app
WORKDIR ${WORKDIR}

# Enable corepack for yarn
RUN corepack enable

# Copy package files first for better caching
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn

# Install dependencies
RUN yarn workspaces focus --all --production \
  && yarn cache clean

# Copy application code
COPY . .

EXPOSE 3000
CMD [ "yarn", "start" ]
