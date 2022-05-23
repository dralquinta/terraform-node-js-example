FROM ubuntu:latest

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package*.json ./

RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment
RUN echo "LANG=en_US.UTF-8" >> /etc/environment
RUN echo "NODE_ENV=development" >> /etc/environment
RUN more "/etc/environment"
#RUN locale-gen en_US en_US.UTF-8
#RUN dpkg-reconfigure locales

RUN apt-get update
#RUN apt-get upgrade -y
#RUN apt-get dist-upgrade -y
RUN apt-get install curl htop git zip nano ncdu build-essential chrpath libssl-dev libxft-dev pkg-config glib2.0-dev libexpat1-dev gobject-introspection apt-transport-https libgirepository1.0-dev libtiff5-dev libjpeg-turbo8-dev libgsf-1-dev fail2ban nginx -y

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash
RUN apt-get install --yes nodejs
RUN node -v
RUN npm -v
RUN npm i -g nodemon
RUN nodemon -v

# Cleanup
RUN apt-get update && apt-get upgrade -y && apt-get autoremove -y

# Bundle app source
COPY . .

WORKDIR /oci-cli

RUN apt-get update \
    && apt-get install -y --no-install-recommends unzip

RUN set -ex \
    && wget -qO- -O oci-cli.zip "https://github.com/oracle/oci-cli/releases/download/v${CLI_VERSION}/oci-cli-${CLI_VERSION}.zip" \
    && unzip oci-cli.zip -d .. \
    && rm oci-cli.zip \
    && pip install oci_cli-*-py2.py3-none-any.whl

RUN yes | oci setup autocomplete

EXPOSE 8000
CMD [ "node", "terra-apply.js" ]