#!/bin/sh -x

# 環境変数
export SYSTEM_TYPE=${SYSTEM_TYPE:-direct}

export AMQP_URI=${AMQP_URI:-amqp://rabbitmq:rabbitmq@rabbitmq.local:5672}
export SYSTEM_NO_CHARGE_KEY=${SYSTEM_NO_CHARGE_KEY:-tC0br8ciFAZmYdUHfS1JeJy4c}

export USER_CODE_HOST_DIR=${USER_CODE_HOST_DIR:-/var/cloudfn/usercode}

export NODE_REPO_TAG=${NODE_REPO_TAG:-necbaas/node-logic-server:8}
export JAVA_REPO_TAG=${JAVA_REPO_TAG:-necbaas/java-logic-server:11}
export NODE_HOST_DIR=${NODE_HOST_DIR:-/opt/cloudfn/node-server/package}
export JAVA_HOST_DIR=${JAVA_HOST_DIR:-/opt/cloudfn/java-server}

export LOG_LEVEL=${LOG_LEVEL:-INFO}
export LOG_FLUENT_HOST=${LOG_FLUENT_HOST:-}
export LOG_FLUENT_PORT=${LOG_FLUENT_PORT:-24224}

export JAVA_OPTS=${JAVA_OPTS:-}

# server manager 設定ファイル生成
cat /etc/baas/cloudfn-server-manager.$SYSTEM_TYPE.template.yaml | envsubst > /tmp/csm.yaml

if [ ! -n "$LOG_FLUENT_HOST" ]; then
    cp /tmp/csm.yaml /etc/baas/cloudfn-server-manager-config.yaml
else
    cat /tmp/csm.yaml \
        | sed "s/#fluentd:/fluentd:/" \
        | sed "s/#  address:/  address:/" \
        > /etc/baas/cloudfn-server-manager-config.yaml
fi

# logback 設定ファイル生成
if [ ! -n "$LOG_FLUENT_HOST" ]; then
    export LOG_TYPES=STDOUT,FILE
else
    export LOG_TYPES=STDOUT,FILE,FLUENT
fi
cat /etc/baas/logback.template.properties | envsubst > /etc/baas/cloudfn-server-manager-logback.properties

# 起動
exec java -jar ${JAVA_OPTS} /opt/cloudfn/bin/cloudfn-server-manager.jar /etc/baas/cloudfn-server-manager-config.yaml
