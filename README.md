Cloud Functions Server: Dockerfile
==================================

NECモバイルバックエンド基盤 Cloud Functions (Cloudfn) サーバ用の Dockerfile。

以下の２種類の Tag があります。

* [version]-direct : Dockerレスモード(Directモード)
    * 同一コンテナ内でサーバマネージャ、ロジックサーバ(Java, Node.js)をすべて動作させるモードです。
    * サーバマネージャのシステム起動タイプは "direct" です。
    * 本イメージは上記3サーバをすべて含みます。

* [version]-docker : Dockerモード
    * サーバマネージャ、ロジックサーバ(Java, Node.js)をすべて異なるコンテナで動作させるモードです。
    * 本イメージにはサーバマネージャのみを含み、ホスト側の dockerd を使用してロジックサーバを起動します。いわゆる dind (Docker in Docker) 動作となります。
    * Java Logic Server, Node.js Logic Server のイメージが別途必要です。
    * サーバマネージャのシステム起動タイプは "docker" です。

使用方法
--------

### Docker ホストの設定（システム起動タイプが docker の場合のみ実施）

「Dockerモード」を使用する場合、Docker ホスト側にユーザコードの格納ディレクトリ、ロジックサーバ バイナリ格納ディレクトリを作成し、
バイナリを格納しておきます。

    $ sudo ./cloudfn_setup_docker_host.sh

### RabbitMQ サーバ起動

動作検証用に RabbitMQ サーバをコンテナで起動する手順を示します。
ここでは、Docker Hub のオフィシャルコンテナを利用しています。

    $ docker run -d --hostname baas-rabbitmq --name baas-rabbitmq-server \
      -e RABBITMQ_DEFAULT_USER=rabbitmq -e RABBITMQ_DEFAULT_PASS=rabbitmq rabbitmq:3-alpine

RabbitMQ サーバの IP アドレスは以下コマンドで確認してください。

    $ docker inspect --format="{{ .NetworkSettings.IPAddress }}" baas-rabbitmq-server

以下、cloudfn-server 起動時の AMQP_URI のホスト名には上記 IP アドレスを指定してください。

### Cloud Functions サーバ起動

詳細は Makefile を確認してください。

#### Dockerレスモードの場合

AMQP_URI に RabbitMQ サーバの URI を指定して cloudfn-server を起動します。

    $ docker pull necbaas/cloudfn-server:7.5-direct
    $ docker run -d \
      -e AMQP_URI=amqp://rabbitmq:rabbitmq@rabbitmq1.example.com:5672 \
      necbaas/cloudfn-server:7.5-direct

#### Dockerモードの場合
 
ロジックサーバのイメージを取得します。
   
    $ docker pull necbaass/node-logic-server:8
    $ docker pull necbaass/java-logic-server:11

cloudfn-server を起動します。

    $ docker pull necbaas/cloudfn-server:7.5-docker
    $ docker run -d \
      -v /var/cloudfn/usercode:/var/cloudfn/usercode \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -e AMQP_URI=amqp://rabbitmq:rabbitmq@rabbitmq1.example.com:5672 \
      necbaas/cloudfn-server:7.5-docker

* Docker ホストのユーザコード格納ディレクトリ（/var/cloudfn/usercode）の VOLUME を指定します。
* Docker UNIX 通信ソケット（/var/run/docker.sock）の VOLUME を指定します。サーバマネージャがこのソケットを利用し、Docker ホスト上の dockerd と通信します。
* 環境変数 AMQP_URI の指定は、前述と同様です。
         
環境変数
--------

Cloudfn サーバ 実行時には以下の環境変数が参照されます。

### Java 関連

* JAVA_OPTS : Java VM オプション (default: なし)

### Cloudfn Server 関連

* AMQP_URI : AMQP URI (default: amqp://rabbitmq:rabbitmq@rabbitmq.local:5672)
* SYSTEM_NO_CHARGE_KEY : APIカウント対象外キー (default： 詳細は略)

以下はシステム起動タイプが 'docker' の場合のみ設定可能です。

* USER_CODE_HOST_DIR: Docker ホストのユーザコードの格納先（default: /var/cloudfn/usercode）
* NODE_REPO_TAG: Nodejs タイプのロジックサーバのイメージタグ（default: necbaas/node-logic-server:8}
* JAVA_REPO_TAG: Java Logic Server のイメージタグ（default: necbaas/java-logic-server:11}
* NODE_HOST_DIR: Docker ホストのロジックサーバ バイナリ格納先（default: /opt/cloudfn/node-server/package）
* JAVA_HOST_DIR: Docker ホストのロジックサーバ バイナリ格納先（default: /opt/cloudfn/java-server）

ログを fluentd に出力する場合は、以下を指定します。

* LOG_FLUENT_HOST : Fluentd サーバアドレス (default: "")
* LOG_FLUENT_PORT : Fluentd ポート番号 (default: 24224)

### ロギング

* LOG_LEVEL: ログレベル (default: INFO)

注意事項
---------

本イメージのロジックサーバの実行環境は Node.js v8 / OpenJDK 11 となります。
また、spec 名はそれぞれ "node", "java" となります。
