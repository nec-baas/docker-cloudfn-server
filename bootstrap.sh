#!/bin/sh

# 環境変数
AMQP_URI=${AMQP_URI:-amqp://rabbitmq:rabbitmq@rabbitmq.local:5672}
SYSTEM_NO_CHARGE_KEY=${SYSTEM_NO_CHARGE_KEY:-tC0br8ciFAZmYdUHfS1JeJy4c}
LOG_LEVEL=${LOG_LEVEL:-INFO}
LOG_FLUENT_HOST=${LOG_FLUENT_HOST:-}
LOG_FLUENT_PORT=${LOG_FLUENT_PORT:-24224}
JAVA_OPTS=${JAVA_OPTS:-}

# 設定ファイル生成
cat /etc/baas/cloudfn-server-manager.template.yaml \
    | sed "s#%AMQP_URI%#$AMQP_URI#" \
    | sed "s/%SYSTEM_NO_CHARGE_KEY%/$SYSTEM_NO_CHARGE_KEY/" \
    > /etc/baas/cloudfn-server-manager.template2.yaml

# logback設定ファイル生成
cat /etc/baas/logback.template.properties \
    | sed "s/%LOG_LEVEL%/$LOG_LEVEL/" \
    > /etc/baas/logback.template2.properties

if [ ! -n "$LOG_FLUENT_HOST" ]; then
    echo "Not set fluent"
# 設定ファイル生成
    cat /etc/baas/cloudfn-server-manager.template2.yaml \
        > /etc/baas/cloudfn-server-manager-config.yaml

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
        > /etc/baas/cloudfn-server-manager-config.yaml

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

# 起動
java -jar ${JAVA_OPTS} /opt/cloudfn/bin/cloudfn-server-manager.jar /etc/baas/cloudfn-server-manager-config.yaml
