# A docker image for the node-red with fission.

FROM node:8.1.3

ARG NODE_ENV
ENV NODE_ENV $NODE_ENV

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY package.json /usr/src/app/
RUN npm install

COPY Gruntfile.js red.js settings.js .jshintrc .npmignore ./
COPY editor editor
COPY nodes nodes
COPY red red
COPY test test

RUN npm run build

RUN mkdir -p /root/.node-red
WORKDIR /root/.node-red
COPY deploy/package.json deploy/settings.js ./
RUN npm install

RUN echo 'log6' > log
RUN git clone https://github.com/yqf3139/node-red-contrib-fission.git /root/node-red-contrib-fission
WORKDIR /root/node-red-contrib-fission
RUN git fetch origin k8s
RUN git checkout origin/k8s
RUN npm install
RUN npm link

WORKDIR /usr/src/app
RUN npm link node-red-contrib-fission

EXPOSE 1880
CMD [ "npm", "start" ]