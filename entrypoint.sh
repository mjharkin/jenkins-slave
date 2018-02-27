#!/bin/bash

set -ex

export DOCKER_GID=`stat -c "%g" /var/run/docker.sock`

groupmod -g $DOCKER_GID docker-sock

write_key() {
	mkdir -p "/home/jenkins/.ssh"
	echo "$1" > "/home/jenkins/.ssh/authorized_keys"
	chown -Rf jenkins:jenkins "/home/jenkins/.ssh"
	chmod 0700 -R "/home/jenkins/.ssh"
}


write_key "${JENKINS_SLAVE_SSH_PUBKEY}"

ssh-keygen -A
exec /usr/sbin/sshd -D -e

