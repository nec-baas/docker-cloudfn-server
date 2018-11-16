#!/bin/sh

CLOUDFN_VERSION=7.5.0

if [ ! -e files/cloudfn-servers-$CLOUDFN_VERSION ]; then
    wget --no-check-certificate https://github.com/nec-baas/cloudfn-server/releases/download/v$CLOUDFN_VERSION/cloudfn-servers-$CLOUDFN_VERSION.tar.gz
    tar xvzf cloudfn-servers-$CLOUDFN_VERSION.tar.gz -C files/
fi
