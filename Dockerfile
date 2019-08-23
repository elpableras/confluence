#FROM openjdk:8-alpine
FROM gitlab-registry.cern.ch/industrial-controls/sw-infra/cc7-oraclejava:8.0.2
MAINTAINER pablogo

# Setup useful environment variables
ENV CONF_HOME     /var/atlassian/confluence
ENV CONF_INSTALL  /opt/atlassian/confluence
ENV CONF_VERSION  6.15.7

ARG MYSQL_VERSION=5.1.42
ENV MYSQL_VERSION ${MYSQL_VERSION}

ENV JAVA_CACERTS  $JAVA_HOME/jre/lib/security/cacerts
ENV CERTIFICATE   $CONF_HOME/certificate

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
    && chmod -R 700            "${CONF_HOME}" \
    && chown daemon:daemon     "${CONF_HOME}" \
    && mkdir -p                "${CONF_INSTALL}/conf" \
    && curl -Ls                "https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-${CONF_VERSION}.tar.gz" | tar -xz --directory "${CONF_INSTALL}" --strip-components=1 --no-same-owner \
    && curl -Ls                "http://cern.ch/maven/releases/mysql-connector-java-${MYSQL_VERSION}.tar.gz" | tar -xz --directory "${CONF_INSTALL}/confluence/WEB-INF/lib" --strip-components=1 --no-same-owner "mysql-connector-java-${MYSQL_VERSION}/mysql-connector-java-${MYSQL_VERSION}-bin.jar" \
    && chmod -R 700            "${CONF_INSTALL}/conf" \
    && chmod -R 700            "${CONF_INSTALL}/temp" \
    && chmod -R 700            "${CONF_INSTALL}/logs" \
    && chmod -R 700            "${CONF_INSTALL}/work" \
    && chown -R daemon:daemon  "${CONF_INSTALL}/conf" \
    && chown -R daemon:daemon  "${CONF_INSTALL}/temp" \
    && chown -R daemon:daemon  "${CONF_INSTALL}/logs" \
    && chown -R daemon:daemon  "${CONF_INSTALL}/work" \
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
        --insert               "Server/Service/Connector" -t attr -n "proxyPort" -v "443" \
        --insert               "Server/Service/Connector" -t attr -n "scheme" -v "https" \
                               "${CONF_INSTALL}/conf/server.xml" \
    && touch -d "@0"           "${CONF_INSTALL}/conf/server.xml" 
    #&& chown daemon:daemon     "${JAVA_CACERTS}"

# Use the default unprivileged account. This could be considered bad practice
# on systems where multiple processes end up being executed by 'daemon' but
# here we only ever run one process anyway.
USER daemon:daemon

# Expose default HTTP connector port.
EXPOSE 8090 8091

# Set volume mount points for installation and home directory. Changes to the
# home directory needs to be persisted as well as parts of the installation
# directory due to eg. logs.
VOLUME ["/var/atlassian/confluence", "/opt/atlassian/confluence/logs"]

# Set the default working directory as the Confluence home directory.
WORKDIR /var/atlassian/confluence

#COPY docker-entrypoint.sh /
#ENTRYPOINT ["/docker-entrypoint.sh"]

# Run Atlassian Confluence as a foreground process by default.
CMD ["/opt/atlassian/confluence/bin/start-confluence.sh", "-fg"]