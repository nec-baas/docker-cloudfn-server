FROM necbaas/openjdk

# Install Nodejs
ENV NODE_VERSION 8.12.0
RUN curl -SLO http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz \
  && tar zxf node-v$NODE_VERSION-linux-x64.tar.gz -C /opt \
  && ln -s /opt/node-v$NODE_VERSION-linux-x64/bin/node /usr/bin/node \
  && /bin/rm node-*.tar.gz

# Install Cloud Functions submodules
ENV CLOUDFN_VERSION 7.5.0
ADD files/cloudfn-servers-$CLOUDFN_VERSION/ /dist

RUN mkdir -p /opt/cloudfn/bin /opt/cloudfn/node-server /opt/cloudfn/java-server
RUN mv /dist/server-manager/bin/cloudfn-server-manager.jar /opt/cloudfn/bin/
RUN mv /dist/java/cloudfn-java-server.jar /opt/cloudfn/java-server/
RUN tar xvzf /dist/node/cloudfn-node-server-*.tgz -C /opt/cloudfn/node-server/

# Add config files
RUN mkdir /etc/baas /var/cloudfn /var/log/cloudfn
ADD cloudfn-server-manager.template.yaml /etc/baas/
ADD logback.template.properties /etc/baas/

# Fix permission
RUN chmod -R ugo+rwx /etc/baas /opt/cloudfn /var/cloudfn /var/log/cloudfn /tmp

# Add startup script
ADD bootstrap.sh /
RUN chmod +x /bootstrap.sh

# Volume options
VOLUME ["/var/log/cloudfn"]
 
CMD /bootstrap.sh

