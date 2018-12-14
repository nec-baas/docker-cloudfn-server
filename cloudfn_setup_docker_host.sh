#!/bin/sh

mkNewDir() {
    if [ -e $1 ]; then
        rm -rf $1
    fi
    mkdir -p $1
}

# Define vars
CLOUDFN_VERSION=7.5.1
dist=files/cloudfn-servers-$CLOUDFN_VERSION
USER_CODE_DIR=${USER_CODE_DIR:-/var/cloudfn/usercode}
NODE_LOGIC_SERVER_DIR=${NODE_LOGIC_SERVER_DIR:-/opt/cloudfn/node-server}
JAVA_LOGIC_SERVER_DIR=${JAVA_LOGIC_SERVER_DIR:-/opt/cloudfn/java-server}

### main program ###

mkNewDir $USER_CODE_DIR
mkNewDir $NODE_LOGIC_SERVER_DIR
mkNewDir $JAVA_LOGIC_SERVER_DIR

tar xvzf $dist/node/cloudfn-node-server-*.tgz -C $NODE_LOGIC_SERVER_DIR/
cp $dist/dist/java/cloudfn-java-server.jar $JAVA_LOGIC_SERVER_DIR/


