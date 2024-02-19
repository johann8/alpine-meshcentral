#!/bin/bash

# set variables
_VERSION=1.1.21
_TAG=alpine-meshcentral

# create build
docker build -t johann8/${_TAG}:${_VERSION} . 2>&1 | tee ./build.log
_BUILD=$?
if ! [ ${_BUILD} = 0 ]; then
   echo "ERROR: Docker Image build was not successful"
   exit 1
else
   echo "Docker Image build successful"
   docker images -a 
   docker tag johann8/${_TAG}:${_VERSION} johann8/${_TAG}:latest
fi

#push image to dockerhub
if [ ${_BUILD} = 0 ]; then
   echo "Pushing docker images to dockerhub..."
   docker push johann8/${_TAG}:latest
   docker push johann8/${_TAG}:${_VERSION}
   _PUSH=$?
   docker images -a |grep meshcentral
fi

if [ ${_PUSH} = 0 ]; then
   echo "Pushing docker image \"${_TAG}\" was successfull."
else
   echo "ERROR: Pushing docker image \"${_TAG}\" was not successfull."
fi


#delete build
if [ ${_PUSH=} = 0 ]; then
   echo "Deleting docker images..."
   docker rmi johann8/${_TAG}:latest
   docker rmi johann8/${_TAG}:${_VERSION}

   docker images -a
fi

