FROM ubuntu:22.04

EXPOSE 4200 7357 9222
CMD ["ember serve"]

ENV INSTALL_PATH /app
RUN mkdir -p $INSTALL_PATH
RUN export DEBIAN_FRONTEND=noninteractive; apt-get -y update; apt-get -y install wget
RUN wget -qO- https://deb.nodesource.com/setup_18.x > node_setup.sh
RUN bash node_setup.sh
RUN apt-get -y install nodejs
RUN npm install -g ember-cli@latest

WORKDIR $INSTALL_PATH

COPY package.json .

RUN npm install

COPY . .