#FROM openjdk:8-alpine
FROM gitlab-registry.cern.ch/industrial-controls/sw-infra/cc7-oraclejava:latest
MAINTAINER pablogo

# Setup useful environment variables
ENV CONF_HOME     /var/atlassian/confluence
ENV CONF_INSTALL  /opt/atlassian/confluence
ENV CONF_VERSION  6.15.7

ARG MYSQL_VERSION=5.1.42
ENV MYSQL_VERSION ${MYSQL_VERSION}

ARG PROXY_NAME=test-confluence-it.web.cern.ch
ENV PROXY_NAME ${PROXY_NAME}
ENV PROXY_PORT=443
ENV PROXY_SCHEME=https

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Install Atlassian Confluence and helper tools and setup initial home
# directory structure.
RUN set -x \
    && yum                     update -y \
    && yum                     install -y apr apr-util rsync xmlstarlet tar graphviz wget openssh-clients \
    && yum 		       install -y ghostscript dejavu-fonts-common dejavu-sans-fonts dejavu-sans-mono-fonts motif \
    && yum                     clean all \
    && mkdir -p                "${CONF_HOME}" \
    && mkdir -p                "${CONF_INSTALL}/conf" \
    && curl -Ls                "https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-${CONF_VERSION}.tar.gz" | tar -xz --directory "${CONF_INSTALL}" --strip-components=1 --no-same-owner \
    && curl -Ls                "http://cern.ch/maven/releases/mysql-connector-java-${MYSQL_VERSION}.tar.gz" | tar -xz --directory "${CONF_INSTALL}/confluence/WEB-INF/lib" --strip-components=1 --no-same-owner "mysql-connector-java-${MYSQL_VERSION}/mysql-connector-java-${MYSQL_VERSION}-bin.jar" \
    && chmod -R 777            "${CONF_INSTALL}/conf" \
    && chmod -R 777            "${CONF_INSTALL}/temp" \
    && chmod -R 777            "${CONF_INSTALL}/logs" \
    && chmod -R 777            "${CONF_INSTALL}/work" \
    && echo -e                 "\nconfluence.home=$CONF_HOME" >> "${CONF_INSTALL}/confluence/WEB-INF/classes/confluence-init.properties" \
    && xmlstarlet              ed --inplace \
        --delete               "Server/@debug" \
        --delete               "Server/Service/Connector/@debug" \
        --delete               "Server/Service/Connector/@useURIValidationHack" \
        --delete               "Server/Service/Connector/@minProcessors" \
        --delete               "Server/Service/Connector/@maxProcessors" \
        --delete               "Server/Service/Engine/@debug" \
        --delete               "Server/Service/Engine/Host/@debug" \
        --delete               "Server/Service/Engine/Host/Context/@debug" \
	--insert               "Server/Service/Connector" -t attr -n "proxyName" -v "${PROXY_NAME}" \
        --insert               "Server/Service/Connector" -t attr -n "proxyPort" -v "${PROXY_PORT}" \
        --insert               "Server/Service/Connector" -t attr -n "scheme" -v "${PROXY_SCHEME}" \
                               "${CONF_INSTALL}/conf/server.xml" \
    && touch -d "@0"           "${CONF_INSTALL}/conf/server.xml" 

RUN set -x \
    && sed -i                             's/export CATALINA_OPTS/CATALINA_OPTS="-Dconfluence.upgrade.recovery.file.enabled=false -Dconfluence.clickjacking.protection.disable=true -server -Xms1536m -Xmx4536m -XX:NewSize=256m -XX:MaxNewSize=256m -XX:+DisableExplicitGC ${CATALINA_OPTS}"\n\n\nexport CATALINA_OPTS/' "${CONF_INSTALL}/bin/setenv.sh" \
    && touch -d "@0"                      "${CONF_INSTALL}/bin/setenv.sh"

# Expose default HTTP connector port.
EXPOSE 8090 8091

# Set volume mount points for installation and home directory. Changes to the
# home directory needs to be persisted as well as parts of the installation
# directory due to eg. logs.
#VOLUME ["/var/atlassian/confluence"]

# Set the default working directory as the Confluence home directory.
WORKDIR /var/atlassian/confluence

#COPY docker-entrypoint.sh /
#ENTRYPOINT ["/docker-entrypoint.sh"]

# Run Atlassian Confluence as a foreground process by default.
CMD ["/opt/atlassian/confluence/bin/start-confluence.sh", "-fg"]
