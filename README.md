Cloud Functions Server: Dockerfile
==================================

NECモバイルバックエンド基盤 Cloud Functions (Cloudfn) サーバ用の Dockerfile。

以下イメージを含みます。

* necbaas/cloudfn-server

本イメージはサーバマネージャ、Java Logic Server, Node.js Logic Server をすべて含みます。

起動例
------

### RabbitMQ サーバ起動

動作検証用に RabbitMQ サーバをコンテナで起動する手順を示します。
ここでは、Docker Hub のオフィシャルコンテナを利用しています。

    $ docker run -d --hostname baas-rabbitmq --name baas-rabbitmq-server \
      -e RABBITMQ_DEFAULT_USER=rabbitmq -e RABBITMQ_DEFAULT_PASS=rabbitmq rabbitmq:3-alpine

RabbitMQ サーバの IP アドレスは以下コマンドで確認してください。

    $ docker inspect --format="{{ .NetworkSettings.IPAddress }}" baas-rabbitmq-server

以下、cloudfn-server 起動時の AMQP_URI のホスト名には上記 IP アドレスを指定してください。

### Cloud Functions サーバ起動

AMQP_URI に RabbitMQ サーバの URI を指定して cloudfn-server を起動します。

    $ docker pull necbaas/cloudfn-server
    $ docker run -d -e AMQP_URI=amqp://rabbitmq:rabbitmq@rabbitmq1.example.com:5672 necbaas/cloudfn-server

環境変数
--------

Cloudfn サーバ 実行時には以下の環境変数が参照されます。

### Java 関連

* JAVA_OPTS : Java VM オプション (default: なし)

### Cloudfn Server 関連

* AMQP_URI : AMQP URI (default: amqp://rabbitmq:rabbitmq@rabbitmq.local:5672)
* SYSTEM_NO_CHARGE_KEY : APIカウント対象外キー (default： 詳細は略)

ログを fluentd に出力する場合は、以下を指定します。
* LOG_FLUENT_HOST : Fluentd サーバアドレス (default: "")
* LOG_FLUENT_PORT : Fluentd ポート番号 (default: 24224)

### ロギング

* LOG_LEVEL: ログレベル (default: INFO)

注意事項
---------

本イメージのロジックサーバの実行環境は Node.js v8 / OpenJDK 11 となります。
また、spec 名はそれぞれ "node", "java" となります。