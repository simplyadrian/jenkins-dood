# vim: ft=dockerfile
###############################################################################
# Jenkins with DooD (Docker outside of Docker)
# http://github.com/axltxl/docker-jenkins-dood
# Author: Alejandro Ricoveri <me@axltxl.xyz>
# Based on:
# * http://container-solutions.com/2015/03/running-docker-in-jenkins-in-docker
# * http://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci
###############################################################################

FROM jenkinsci/jenkins:2.78
MAINTAINER the internet

ENV docker_version 17.06.0
# Install necessary packages
USER root
ADD ./git-lfs_1.4.4_amd64.deb /git-lfs_1.4.4_amd64.deb
RUN apt-get update &&\
    apt-get upgrade -y -o DPkg::Options::=--force-confold &&\
    apt-get install -qq -y --no-install-recommends --no-install-suggests \
	                apt-transport-https \
                    ca-certificates \
                    gnupg2 \
                    software-properties-common \
                    git \
	                sudo &&\
    dpkg -i /git-lfs_1.4.4_amd64.deb &&\
    apt-get install -f &&\
	curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - &&\
    add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/debian \
    $(lsb_release -cs) \
    stable" &&\
	apt-get update &&\
    apt-get -y install docker-ce=${docker_version}~ce-0~debian &&\
    apt-get install -y python-pip python-virtualenv &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/*

# Install initial plugins
USER jenkins
COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN cat /usr/share/jenkins/plugins.txt | /usr/local/bin/install-plugins.sh
RUN mkdir "$JENKINS_HOME"/.ssh && ssh-keyscan -t rsa github.com >> "$JENKINS_HOME"/.ssh/known_hosts
CMD /usr/local/bin/jenkins.sh
