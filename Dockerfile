FROM hypriot/rpi-java
MAINTAINER Brandon Gulla


RUN apt-get update && apt-get install -y -q \
    libasound2-dev \
    memcached \
    mpg123 \
    python-alsaaudio \
    python-pip curl \
    --no-install-recommends

#    rm -rf /var/lib/apt/lists/*

ENV LD_LIBRARY_PATH=/usr/lib/vlc
ENV VLC_PLUGIN_PATH=/usr/lib/vlc/plugins

RUN curl -sL https://deb.nodesource.com/setup | sudo bash -
RUN apt-get install -y nodejs git
RUN wget http://apache.mirrors.hoobly.com/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz && tar zxvf apache-maven-3.3.9-bin.tar.gz -C /opt && rm -rf apache-maven-3.3.9-bin.tar.gz
ENV M2_HOME=/opt/apache-maven-3.3.9
ENV PATH=$PATH:$M2_HOME/bin
RUN git config --global http.sslVerify false && git clone https://github.com/amzn/alexa-avs-raspberry-pi.git /opt/alexa
RUN apt-get install -y python-setuptools && pip install supervisor
RUN chmod +x /opt/alexa/samples/javaclient/generate.sh && chmod +x /opt/alexa/samples/javaclient/install-java8.sh 
RUN sed -i -e 's/YOUR_COUNTRY_NAME/US/g' /opt/alexa/samples/javaclient/ssl.cnf && cat /opt/alexa/samples/javaclient/ssl.cnf
RUN sed -i -e 's/YOUR_STATE_OR_PROVINCE/MD/g' /opt/alexa/samples/javaclient/ssl.cnf && cat /opt/alexa/samples/javaclient/ssl.cnf
RUN sed -i -e 's/YOUR_CITY/BALTIMORE/g' /opt/alexa/samples/javaclient/ssl.cnf && cat /opt/alexa/samples/javaclient/ssl.cnf
RUN sed -i -e 's/YOUR_ORGANIZATION/foo/g' /opt/alexa/samples/javaclient/ssl.cnf && cat /opt/alexa/samples/javaclient/ssl.cnf
RUN sed -i -e 's/YOUR_ORGANIZATIONAL_UNIT/bar/g' /opt/alexa/samples/javaclient/ssl.cnf && cat /opt/alexa/samples/javaclient/ssl.cnf

RUN apt-get install -y openssl && /opt/alexa/samples/javaclient/generate.sh

# Config.js

RUN sed -i -e 's/sslKey: \x27/sslKey: \x27/opt/alexa/samples/javaclient/certs/server/node.key/g'
RUN sed -i -e 's/sslCert: \x27/sslCert: \x27/opt/alexa/samples/javaclient/certs/server/node.crt\/g'
RUN sed -i -e 's/sslCaCert: \x27/sslCaCert: \x27/opt/alexa/samples/javaclient/certs/ca/ca.crt\/g'

# Config.json
RUN sed -i -e 's/"sslClientKeyStore":""/"sslClientKeyStore":"/opt/alexa/samples/javaclient/certs/client/client.pkcs12"/g' /opt/alexa/samples/javaclient/config.json 
RUN sed -i -e 's/"sslKeyStore":""/"sslKeyStore":"/opt/alexa/samples/javaclient/certs/server/jetty.pkcs12"/g' /opt/alexa/samples/javaclient/config.json 

