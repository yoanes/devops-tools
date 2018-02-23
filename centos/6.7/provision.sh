#!/bin/bash

# Install ansible
yum install -q -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm --disablerepo=*
yum install -q -y ansible

# Install pip
yum install -q -y python-pip
pip install --upgrade pip

# Install pywinrm
pip install "pywinrm>=0.1.1"

# Install Kerberos
yum -y -q install python-devel krb5-devel krb5-libs krb5-workstation
pip install kerberos

# Install boto
pip install boto

# Install utility
yum install -y -q bind-utils telnet

# Do update
yum update -y -q

# Set timezone
mv /etc/localtime /etc/localtime.orig
ln -s /usr/share/zoneinfo/Australia/Melbourne /etc/localtime

# Copy hosts file
cp /home/vagrant/anz_setup/hosts /etc/hosts

# Copy kerberos config
cp /vagrant/krb5.conf /etc/krb5.conf

# Install docker
if [ ! -f /etc/yum.repos.d/docker-main.repo ]; then
   curl -sSL https://get.docker.com/ | sh
   usermod -aG docker vagrant
   chkconfig docker on

   cat <<EOT >> /etc/sysconfig/docker
other_args="--dns=8.8.8.8 --dns=192.168.1.1 --insecure-registry 52.64.57.81:5000"
EOT

   chkconfig iptables off
   service iptables stop

   service docker start
fi

if [ ! -f /usr/local/bin/docker-compose ]; then
   curl -L https://github.com/docker/compose/releases/download/1.5.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
   chmod +x /usr/local/bin/docker-compose
fi

if [ ! -f /usr/local/bin/docker-machine ]; then 
   curl -L https://github.com/docker/machine/releases/download/v0.5.5/docker-machine_linux-amd64 > /usr/local/bin/docker-machine  
   chmod +x /usr/local/bin/docker-machine
fi

