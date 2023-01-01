FROM ubuntu:20.04

LABEL maintainer="Bibin Wilson <bibinwilsonn@gmail.com>"

ARG DEBIAN_FRONTEND=noninteractive

# Make sure the package repository is up to date.
RUN apt-get update
RUN    apt-get -qy full-upgrade
RUN    apt-get install -qy git
# Install a basic SSH server
RUN    apt-get install -qy openssh-server
RUN    sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd
RUN    mkdir -p /var/run/sshd
# Install JDK 11
RUN    apt-get install -qy default-jdk
# Install maven
RUN    apt-get install -qy maven
# Add user jenkins to the image
RUN    adduser --quiet jenkins
# Install docker
RUN    sudo apt update
RUN    sudo apt install apt-transport-https ca-certificates curl software-properties-common
RUN    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
RUN    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
RUN    sudo apt install docker-ce
RUN    sudo usermod -aG docker jenkins
# Cleanup old packages
RUN    apt-get -qy autoremove
# Set password for the jenkins user (you may want to alter this).
RUN    echo "jenkins:jenkins" | chpasswd
RUN    mkdir /home/jenkins/.m2

#ADD settings.xml /home/jenkins/.m2/
# Copy authorized keys
COPY .ssh/authorized_keys /home/jenkins/.ssh/authorized_keys

RUN chown -R jenkins:jenkins /home/jenkins/.m2/
RUN chown -R jenkins:jenkins /home/jenkins/.ssh/

# Standard SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
