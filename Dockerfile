FROM hypriot/rpi-java
MAINTAINER Brandon Gulla

# Environment Vars used for building docker
ENV MAVEN_URL http://apache.mirrors.hoobly.com/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
ENV ALEXA_HOME /opt/alexa

# Configure nodejs source
RUN curl -sL https://deb.nodesource.com/setup | sudo bash -

# Install Packages
RUN apt-get update && apt-get install -y -q \
    libasound2-dev \
    memcached \
    mpg123 \
    python-alsaaudio \
    python-pip curl \
    nodejs git python-setuptools opensssl vlc-nox vlc-data \
    --no-install-recommends

#    rm -rf /var/lib/apt/lists/*

# Setup VLC env vars
ENV LD_LIBRARY_PATH=/usr/lib/vlc
ENV VLC_PLUGIN_PATH=/usr/lib/vlc/plugins

# Configure Maven
RUN wget ${MAVEN_URL} && tar zxvf apache-maven-3.3.9-bin.tar.gz -C /opt && rm -rf apache-maven-3.3.9-bin.tar.gz
ENV M2_HOME=/opt/apache-maven-3.3.9
ENV PATH=$PATH:$M2_HOME/bin

# Pull down the alexa files from github
RUN git config --global http.sslVerify false && git clone https://github.com/amzn/alexa-avs-raspberry-pi.git ${ALEXA_HOME} # TODO make this more secure

# CERTIFICATE STUFF
RUN chmod +x ${ALEXA_HOME}/samples/javaclient/generate.sh && chmod +x ${ALEXA_HOME}/samples/javaclient/install-java8.sh 
RUN sed -i -e 's/YOUR_COUNTRY_NAME/US/g' ${ALEXA_HOME}/samples/javaclient/ssl.cnf && cat ${ALEXA_HOME}/samples/javaclient/ssl.cnf
RUN sed -i -e 's/YOUR_STATE_OR_PROVINCE/MD/g' ${ALEXA_HOME}/samples/javaclient/ssl.cnf && cat ${ALEXA_HOME}/samples/javaclient/ssl.cnf
RUN sed -i -e 's/YOUR_CITY/BALTIMORE/g' ${ALEXA_HOME}/samples/javaclient/ssl.cnf && cat ${ALEXA_HOME}/samples/javaclient/ssl.cnf
RUN sed -i -e 's/YOUR_ORGANIZATION/foo/g' ${ALEXA_HOME}/samples/javaclient/ssl.cnf && cat ${ALEXA_HOME}/samples/javaclient/ssl.cnf
RUN sed -i -e 's/YOUR_ORGANIZATIONAL_UNIT/bar/g' ${ALEXA_HOME}/samples/javaclient/ssl.cnf && cat ${ALEXA_HOME}/samples/javaclient/ssl.cnf

# generate certificates
RUN ${ALEXA_HOME}/samples/javaclient/generate.sh

# modify Config.js
RUN sed -i -e 's/sslKey: \x27/sslKey: \x27${ALEXA_HOME}/samples/javaclient/certs/server/node.key/g'
RUN sed -i -e 's/sslCert: \x27/sslCert: \x27${ALEXA_HOME}/samples/javaclient/certs/server/node.crt\/g'
RUN sed -i -e 's/sslCaCert: \x27/sslCaCert: \x27${ALEXA_HOME}/samples/javaclient/certs/ca/ca.crt\/g'
# modify Config.json
RUN sed -i -e 's/"sslClientKeyStore":""/"sslClientKeyStore":"${ALEXA_HOME}/samples/javaclient/certs/client/client.pkcs12"/g' ${ALEXA_HOME}/samples/javaclient/config.json 
RUN sed -i -e 's/"sslKeyStore":""/"sslKeyStore":"${ALEXA_HOME}/samples/javaclient/certs/server/jetty.pkcs12"/g' ${ALEXA_HOME}/samples/javaclient/config.json 

# Setup the supervisord
RUN pip install supervisor
COPY ./conf/supervisor.cnf /etc/supervisor.cnf

# compile the nodejs client
WORKDIR ["{ALEXA_HOME}/samples/companionService"]
RUN npm install 

RUN echo " STILL NOT DONE NOR FUNCTIONAL"
