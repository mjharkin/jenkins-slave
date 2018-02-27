ARG ALPINE_DOCKER_VER=3.7_17.09.0
FROM mjha/alpine-docker:${ALPINE_DOCKER_VER}

LABEL MAINTAINER="Mark Harkin"

USER root

ENV JENKINS_AGENT_HOME /var/jenkins_home

# Jenkins user 
RUN addgroup -S jenkins \
 && adduser -S -g jenkins jenkins \
 && passwd -u jenkins

# Create docker-sock group
RUN addgroup -S docker-sock 

# Add jenkins to docker and docker-sock group
RUN apk add --no-cache --virtual .build-dependencies shadow \
 &&  usermod -a -G docker jenkins \
 && usermod -a -G docker-sock jenkins \
 && apk del .build-dependencies


# Slave Dependencies
RUN apk add --no-cache bash ca-certificates wget curl shadow openjdk8 git

# Set default shell for jenkins user
RUN chsh -s /bin/bash jenkins

# Setup SSH server
RUN apk add --no-cache openssh \
 && sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config \
 && sed -i 's/#RSAAuthentication.*/RSAAuthentication yes/' /etc/ssh/sshd_config \
 && sed -i 's/#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config \
 && sed -i 's/#SyslogFacility.*/SyslogFacility AUTH/' /etc/ssh/sshd_config \
 && sed -i 's/#LogLevel.*/LogLevel INFO/' /etc/ssh/sshd_config \
 && mkdir /var/run/sshd

# Docker Compose
RUN apk add --no-cache py2-pip=9.0.1-r1 \
  && pip install docker-compose==1.16.1

EXPOSE 22

VOLUME "${JENKINS_AGENT_HOME}"
WORKDIR "${JENKINS_AGENT_HOME}"

COPY entrypoint.sh /
RUN chmod 777 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ""
