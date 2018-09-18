#!/usr/bin/env bash

#
# Derived from https://github.com/kubernetes/kubernetes/issues/52172#issuecomment-346075080
#
set -eu
if [ ! -d /var/lib/docker/containers ]; then
    echo "/var/lib/docker/containers doesn't exist; aborting" 1>&2
    exit 1
fi

cd /var/lib/docker/containers

while true ; do
    for DOCKER_ID in *; do
        CONTAINER="$(cat ${DOCKER_ID}/config.v2.json | jq '{Labels:.Config.Labels, LogPath, ID}')"
        CONTAINER_ID="$(echo ${CONTAINER} | jq -r .ID)"
        CONTAINER_NAME="$(echo ${CONTAINER} | jq -r '.Labels["io.kubernetes.container.name"]')"
        LOG_PATH="$(echo ${CONTAINER} | jq -r .LogPath)"
        POD_NAME="$(echo ${CONTAINER} | jq -r '.Labels["io.kubernetes.pod.name"]')"
        POD_NAMESPACE="$(echo ${CONTAINER} | jq -r '.Labels["io.kubernetes.pod.namespace"]')"
        LINK1_NAME="$(printf "%s_%s_%s-%s" "$POD_NAME" "$POD_NAMESPACE" "$CONTAINER_NAME" "$CONTAINER_ID" | cut -c 1-251)"
        LINK1_FILENAME=$(printf "/var/log/containers/%s.log" "$LINK1_NAME")
        LINK2_FILENAME=$(echo ${CONTAINER} | jq -r '.Labels["io.kubernetes.container.logpath"]')

        if [ -n "${LINK1_FILENAME}" -a ! -e "${LINK1_FILENAME}" -a -e "${LOG_PATH}" ] ; then
            echo "Missing log symlink ${LINK1_FILENAME} for ${LOG_PATH}, creating it now"
            ln -s ${LOG_PATH} ${LINK1_FILENAME}
        fi

        if [ "${LINK2_FILENAME}" = "null" ] ; then
            LINK2_FILENAME=""
        fi
        if [ -n "${LINK2_FILENAME}" -a ! -e "${LINK2_FILENAME}" -a -e "${LINK1_FILENAME}" ] ; then
            echo "Missing log symlink ${LINK2_FILENAME} for ${LINK1_FILENAME}, creating it now"
            if [ ! -d "$(dirname ${LINK2_FILENAME})" ] ; then
                mkdir -p "$(dirname ${LINK2_FILENAME})"
            fi
            ln -s ${LINK1_FILENAME} ${LINK2_FILENAME}
        fi
    done

    sleep 60
done

