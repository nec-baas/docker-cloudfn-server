#!/bin/sh -x

# 環境変数
SYSTEM_TYPE=${SYSTEM_TYPE:-direct}
AMQP_URI=${AMQP_URI:-amqp://rabbitmq:rabbitmq@rabbitmq.local:5672}
SYSTEM_NO_CHARGE_KEY=${SYSTEM_NO_CHARGE_KEY:-tC0br8ciFAZmYdUHfS1JeJy4c}
USER_CODE_HOST_DIR=${USER_CODE_HOST_DIR:-/var/cloudfn/usercode}
NODE_REPO_TAG=${NODE_REPO_TAG:-necbaas/node-logic-server:8}
JAVA_REPO_TAG=${JAVA_REPO_TAG:-necbaas/java-logic-server:11}
NODE_HOST_DIR=${NODE_HOST_DIR:-/opt/cloudfn/node-server/package}
JAVA_HOST_DIR=${JAVA_HOST_DIR:-/opt/cloudfn/java-server}
LOG_LEVEL=${LOG_LEVEL:-INFO}
LOG_FLUENT_HOST=${LOG_FLUENT_HOST:-}
LOG_FLUENT_PORT=${LOG_FLUENT_PORT:-24224}
JAVA_OPTS=${JAVA_OPTS:-}

# コンテナー内 PATH 設定
CMD_PATH_DOCKER=/opt/emitter
CMD_NODE_PATH_DIRECT=/opt/cloudfn/node-server/package
CMD_JAVA_PATH_DIRECT=/opt/cloudfn/java-server

# 設定ファイル生成
cat /etc/baas/cloudfn-server-manager.template.yaml \
    | sed "s/%SYSTEM_TYPE%/$SYSTEM_TYPE/" \
    | sed "s#%AMQP_URI%#$AMQP_URI#" \
    | sed "s/%SYSTEM_NO_CHARGE_KEY%/$SYSTEM_NO_CHARGE_KEY/" \
    | sed "s#%USER_CODE_HOST_DIR%#$USER_CODE_HOST_DIR#" \
    > /etc/baas/cloudfn-server-manager.template2.yaml

# logback設定ファイル生成
cat /etc/baas/logback.template.properties \
    | sed "s/%LOG_LEVEL%/$LOG_LEVEL/" \
    > /etc/baas/logback.template2.properties

if [ ! -n "$LOG_FLUENT_HOST" ]; then
# 設定ファイル生成
    echo "Not set fluent"

# logback設定ファイル生成
    cat /etc/baas/logback.template2.properties \
        | sed "s/%LOG_TYPES%/STDOUT,FILE/" \
        > /etc/baas/cloudfn-server-manager-logback.properties

else
    echo "Set fluent"
# 設定ファイル生成
    cat /etc/baas/cloudfn-server-manager.template2.yaml \
        | sed "s/#fluentd:/fluentd:/" \
        | sed "s/#  address: %LOG_FLUENT_HOST%:%LOG_FLUENT_PORT%/  address: %LOG_FLUENT_HOST%:%LOG_FLUENT_PORT%/" \
        > /etc/baas/cloudfn-server-manager.template.yaml
    cat /etc/baas/cloudfn-server-manager.template.yaml \
        | sed "s/%LOG_FLUENT_HOST%/$LOG_FLUENT_HOST/" \
        | sed "s/%LOG_FLUENT_PORT%/$LOG_FLUENT_PORT/" \
        > /etc/baas/cloudfn-server-manager.template2.yaml

# logback設定ファイル生成
    cat /etc/baas/logback.template2.properties \
        | sed "s/%LOG_TYPES%/STDOUT,FILE,FLUENT/" \
        | sed 's/#logback.fluent.host=%LOG_FLUENT_HOST%/logback.fluent.host=%LOG_FLUENT_HOST%/' \
        | sed 's/#logback.fluent.port=%LOG_FLUENT_PORT%/logback.fluent.port=%LOG_FLUENT_PORT%/' \
        > /etc/baas/logback.template.properties
    cat /etc/baas/logback.template.properties \
        | sed "s/%LOG_FLUENT_HOST%/$LOG_FLUENT_HOST/" \
        | sed "s/%LOG_FLUENT_PORT%/$LOG_FLUENT_PORT/" \
        > /etc/baas/cloudfn-server-manager-logback.properties
fi

if [ "$SYSTEM_TYPE" = "docker" ]; then
# spec 設定の作成
    cat /etc/baas/cloudfn-server-manager.template2.yaml \
        | sed "s/#docker:/docker:/" \
        | sed "s/#  uri:/  uri:/" \
        | sed "s/#    repoTag:/    repoTag:/" \
        | sed "s/#    volume:/    volume:/" \
        > /etc/baas/cloudfn-server-manager.template.yaml
    cat /etc/baas/cloudfn-server-manager.template.yaml \
        | sed "s#%NODE_REPO_TAG%#$NODE_REPO_TAG#" \
        | sed "s#%JAVA_REPO_TAG%#$JAVA_REPO_TAG#" \
        | sed "s#%NODE_HOST_DIR%#$NODE_HOST_DIR#" \
        | sed "s#%JAVA_HOST_DIR%#$JAVA_HOST_DIR#" \
        | sed "s#%NODE_CMD_PAH%#$CMD_PATH_DOCKER#" \
        | sed "s#%JAVA_CMD_PAH%#$CMD_PATH_DOCKER#" \
        > /etc/baas/cloudfn-server-manager-config.yaml
else
    cat /etc/baas/cloudfn-server-manager.template2.yaml \
        | sed "s#%NODE_CMD_PAH%#$CMD_NODE_PATH_DIRECT#" \
        | sed "s#%JAVA_CMD_PAH%#$CMD_JAVA_PATH_DIRECT#" \
        > /etc/baas/cloudfn-server-manager-config.yaml
fi

# 起動
exec java -jar ${JAVA_OPTS} /opt/cloudfn/bin/cloudfn-server-manager.jar /etc/baas/cloudfn-server-manager-config.yaml
