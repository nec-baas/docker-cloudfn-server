NECモバイルバックエンド基盤 Dockerfile
====================================

NECモバイルバックエンド基盤サーバ Cloud Functions (Cloudfn) サーバマネージャ用のDockerfile

以下イメージを含む。

* necbaas/cloudfn-server

起動例
------

    $ docker pull necbaas/cloudfn-server
    $ docker run -d -e AMQP_URI=amqp://rabbitmq:rabbitmq@rabbitmq1.example.com:5672 necbaas/cloudfn-server

なお、動作検証に、RabbitMQ サーバが必要の場合は、Docker Hub のオフィシャルコンテナーを利用してください。

RabbitMQ サーバ コンテナーの起動方法

    $ docker run -d --hostname baas-rabbitmq --name baas-rabbitmq-server -e RABBITMQ_DEFAULT_USER=rabbitmq -e RABBITMQ_DEFAULT_PASS=rabbitmq rabbitmq:3-alpine

cloudfn-server　の環境変数 AMQP_URI にある hostname　を 下記のコマンドで取得した IPAddress に置き換えます。

    $ docker inspect --format="{{ .NetworkSettings.IPAddress }}" baas-rabbitmq-server

環境変数
--------

Cloudfn サーバ 実行時には以下の環境変数が参照される。

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

本イメージのロジックサーバの実行環境(Nodejs v8/OpenJDK11)になる。
