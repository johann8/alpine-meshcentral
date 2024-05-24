FROM alpine:3.20

LABEL maintainer="JH <jh@localhost>"

ARG BUILD_DATE
ARG NAME
ARG VCS_REF
ARG VERSION

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name=$NAME \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/johann8/alpine-meshcentral" \
      org.label-schema.version=$VERSION

ARG INCLUDE_MONGODBTOOLS="yes"

# environment variables
ENV NODE_ENV="production"
ENV CONFIG_FILE="config.json"
ENV MESHCENTRAL_VERSION 1.1.23

# environment variables for initial configuration file
ENV USE_MONGODB="false"
ENV MONGO_INITDB_ROOT_USERNAME="root"
ENV MONGO_INITDB_ROOT_PASSWORD="passWoRd1"
ENV MONGO_URL=""
ENV MONGO_MC_USERNAME="meshuser"
ENV MONGO_MC_USER_PASSWORD="PAssWoRD2"
ENV MONGO_DB_NAME="meshcentral"
ENV HOSTNAME="localhost"
ENV ALLOW_NEW_ACCOUNTS="true"
ENV ALLOWPLUGINS="false"
ENV LOCALSESSIONRECORDING="false"
ENV MINIFY="true"
ENV WEBRTC="false"
ENV IFRAME="false"
ENV SESSION_KEY=""
ENV REVERSE_PROXY="false"
ENV REVERSE_PROXY_TLS_PORT=""
ENV USE_TRAEFIK="false"
ENV ARGS=""

# add installation directories
RUN mkdir -p /opt/meshcentral/meshcentral

# meshcentral installation
WORKDIR /opt/meshcentral

RUN apk update \
    && apk add --no-cache --update tzdata nodejs npm bash python3 make gcc g++ \
    && rm -rf /var/cache/apk/*
RUN npm install -g npm@latest

# install meshcentral
RUN npm install meshcentral

RUN if ! [ -z "$INCLUDE_MONGODBTOOLS" ] \
    && [ "$INCLUDE_MONGODBTOOLS" != "yes" ] \
    && [ "$INCLUDE_MONGODBTOOLS" != "true" ]; then \
    echo -e "\e[0;31;49mInvalid value for build argument INCLUDE_MONGODBTOOLS, possible values: yes/true\e[;0m"; exit 1; \
    fi

RUN if ! [ -z "$INCLUDE_MONGODBTOOLS" ]; then apk add --no-cache mongodb-tools; rm -rf /var/cache/apk/*; fi

COPY startup.sh startup.sh
COPY config.json.template /opt/meshcentral/config.json.template

EXPOSE 80 443 4433

# volumes
VOLUME /opt/meshcentral/meshcentral-data
VOLUME /opt/meshcentral/meshcentral-files
VOLUME /opt/meshcentral/meshcentral-web
VOLUME /opt/meshcentral/meshcentral-backups

CMD ["bash", "/opt/meshcentral/startup.sh"]

