#!/bin/bash
# set -x

if [ -f "meshcentral-data/${CONFIG_FILE}" ]; then
   node node_modules/meshcentral
else
   cp config.json.template meshcentral-data/${CONFIG_FILE}

   # use mongodb
   if [ -n "${USE_MONGODB}" ] && [ "${USE_MONGODB}" == "true" ]; then
       if [ -z "${MONGO_URL}" ]; then
           PREFIX=""
           if [ -n "${MONGO_INITDB_ROOT_USERNAME}" ] && [ -n "${MONGO_INITDB_ROOT_PASSWORD}" ]; then
               PREFIX="${MONGO_INITDB_ROOT_USERNAME}:${MONGO_INITDB_ROOT_PASSWORD}@"
           fi
           MONGO_URL="${PREFIX}mongodb:27017"
       fi
       sed -i "s/\"_mongoDb\": null/\"mongoDb\": \"mongodb:\/\/${MONGO_URL}\"/" meshcentral-data/${CONFIG_FILE}
   fi
   sed -i "s/\"cert\": \"myserver.mydomain.com\"/\"cert\": \"${HOSTNAME}\"/" meshcentral-data/${CONFIG_FILE}
   sed -i "s/\"NewAccounts\": true/\"NewAccounts\": \"${ALLOW_NEW_ACCOUNTS}\"/" meshcentral-data/${CONFIG_FILE}
   sed -i "s/\"localSessionRecording\": false/\"localSessionRecording\": ${LOCALSESSIONRECORDING}/" meshcentral-data/${CONFIG_FILE}
   sed -i "s/\"minify\": true/\"minify\": ${MINIFY}/" meshcentral-data/${CONFIG_FILE}
   sed -i "s/\"WebRTC\": false/\"WebRTC\": \"${WEBRTC}\"/" meshcentral-data/${CONFIG_FILE}
   sed -i "s/\"AllowFraming\": false/\"AllowFraming\": \"${IFRAME}\"/" meshcentral-data/${CONFIG_FILE}

   # set rp traefik
   if [ -n "${USE_TRAEFIK}" ] && [ "${USE_TRAEFIK}" == "true" ]; then
      TRAEFIK_NAME=traefik
      sed -i "s/\"TLSOffload\": false/\"TLSOffload\": \"${TRAEFIK_NAME}\"/" meshcentral-data/${CONFIG_FILE} 
      sed -i "s/\"_TrustedProxy\": \"localhost\"/\"TrustedProxy\": \"${TRAEFIK_NAME}\"/" meshcentral-data/${CONFIG_FILE}
   fi

   # create session key if empty 
   if [ -z "$SESSION_KEY" ]; then
       SESSION_KEY="$(cat /dev/urandom | tr -dc 'A-Za-z0-9!#%&()*+,-:;<=>?@_{|}~' | fold -w 40 | head -n 1)";
   fi
   # set sessionKey 
   sed -i '/"_sessionKey"/c\    "sessionKey": "'$SESSION_KEY'",' meshcentral-data/"${CONFIG_FILE}"   

   # set reverse proxy
   if [ "${REVERSE_PROXY}" != "false" ]; then
      sed -i "s/\"_certUrl\": \"my\.reverse\.proxy\"/\"certUrl\": \"https:\/\/${REVERSE_PROXY}:${REVERSE_PROXY_TLS_PORT}\"/" meshcentral-data/${CONFIG_FILE}
      node node_modules/meshcentral
      exit 0
   fi
   
   node node_modules/meshcentral --cert "${HOSTNAME}"
fi

# Set timezone variable
if ! [ -z ${TZ} ]; then

  # delete file timezone if exist
  if [ -f /etc/timezone ] ; then
    rm /etc/timezone
  fi

  # delete file localtime if exist and create new one
  if [ -f /etc/localtime ] ; then
    rm /etc/localtime
    ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone
  fi
fi

