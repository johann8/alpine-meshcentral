#!/bin/bash
# set -x

# functions
welcome() {
   echo "+----------------------------------------------------------+"
   echo "|                                                          |"
   echo "|              Welcome to Meshcentral Docker!              |"
   echo "|                                                          |"
   echo "+----------------------------------------------------------+"
}

# Set timezone variable
if ! [ -z ${TZ} ]; then

  # delete file timezone if exist
  if [ -f /etc/timezone ] ; then
    rm /etc/timezone
  fi

  # delete file localtime if exist and create new one
  if [ -f /etc/localtime ] ; then
    rm /etc/localtime
    echo -n "Setting timezone...               "
    ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone
    echo "[DONE]"
  fi
fi

# configure config.json
if [ -f "meshcentral-data/${CONFIG_FILE}" ]; then
   welcome
   node node_modules/meshcentral
else
   echo -n "Coping config.json.template...     "
   cp config.json.template meshcentral-data/${CONFIG_FILE}
   echo "[DONE]"

   # use mongodb
   if [ -n "${USE_MONGODB}" ] && [ "${USE_MONGODB}" == "true" ]; then
       if [ -z "${MONGO_URL}" ]; then
           PREFIX=""
           if [ -n "${MONGO_MC_USERNAME}" ] && [ -n "${MONGO_MC_USER_PASSWORD}" ]; then
               PREFIX="${MONGO_MC_USERNAME}:${MONGO_MC_USER_PASSWORD}@"
           fi
           MONGO_URL="${PREFIX}mongodb:27017/${MONGO_DB_NAME}"
       fi
       echo -n "Setting mongodb URL...               "
       sed -i "s+\"_mongoDb\": null+\"mongoDb\": \"mongodb:\/\/${MONGO_URL}\"+" meshcentral-data/${CONFIG_FILE} 
       echo "[DONE]"

       echo -n "Setting mongodb URL...               "
       sed -i "s/\"_MongoDbName\": \"meshcentral\"/\"MongoDbName\": \"${MONGO_DB_NAME}\"/" meshcentral-data/${CONFIG_FILE}
       echo "[DONE]"

       echo -n "Setting mongodb colections...        "
       sed -i "s/\"_Mongodbcol\": \"meshcentral\"/\"Mongodbcol\": \"${MONGO_DB_NAME}\"/" meshcentral-data/${CONFIG_FILE}
       echo "[DONE]"

       echo -n "Setting mongodb bulk operations...   "
       sed -i "s/\"_MongoDbBulkOperations\": true/\"MongoDbBulkOperations\": true/" meshcentral-data/${CONFIG_FILE}
       echo "[DONE]"

       DB_ENCRYPT_KEY=$(cat /dev/urandom | tr -dc 'A-Za-z0-9!#-' | fold -w 55 | head -n 1)
       echo -n "Setting mongodb encrypt key...       "
       sed -i "s/\"_DbEncryptKey\": \"MySuperString123\"/\"DbEncryptKey\": \"${DB_ENCRYPT_KEY}\"/" meshcentral-data/${CONFIG_FILE}
       echo "[DONE]"
   fi

   # set parameters 
   sed -i "s/\"cert\": \"myserver.mydomain.com\"/\"cert\": \"${HOSTNAME_MC}\"/" meshcentral-data/${CONFIG_FILE}
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
      welcome
      node node_modules/meshcentral
      exit 0
   fi
   welcome
   node node_modules/meshcentral
   #node node_modules/meshcentral --cert "${HOSTNAME_MC}"
fi

