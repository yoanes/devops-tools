#!/bin/bash

GIT_VERSION='2.12.2'
DOCKER_MACHINE_VERSION='0.13.0'
DOCKER_COMPOSE_VERSION='1.19.0'

pvcreate /dev/sdb
pvscan
vgcreate docker /dev/sdb
lvcreate -y -l 1%VG -n thinpoolmeta docker
lvcreate -y -l 95%VG -n thinpool docker
lvconvert -y --zero n --thinpool docker/thinpool --poolmetadata docker/thinpoolmeta

cat <<EOF > /etc/lvm/profile/docker-thinpool.profile
activation {
  thin_pool_autoextend_threshold = 80
  thin_pool_autoextend_percent = 20
}
EOF

lvchange --metadataprofile docker-thinpool docker/thinpool

# Install ansible
yum install -q -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm 
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

# Install awscli
pip install awscli

# Install cfn-init
easy_install --script-dir /usr/bin https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.tar.gz
chown root:vagrant /var/log
chmod 774 -R /var/log

# Install utility
yum install -y -q bind-utils telnet net-tools wget unzip iproute util-linux-ng expect yum-utils jq nc vim-enhanced

# Install java
# yum install -y --disablerepo=* /vagrant/jdk-8u73-linux-x64.rpm

# Install ruby
yum install -y ruby ruby-devel
gem install --no-user-install bundler hitimes foundation compass jruby-rack gherkin rake

# s3fs tools 
yum install -y automake fuse fuse-devel gcc-c++ git libcurl-devel libxml2-devel make openssl-devel

# Do update
yum update -y -q

# Set timezone
timedatectl set-timezone Australia/Melbourne

# setup s3fs for workspace
curl -vkL https://github.com/s3fs-fuse/s3fs-fuse/archive/master.zip -o /tmp/s3fs.zip
mkdir -p /opt/google/
unzip /tmp/s3fs.zip -d /opt/google/
cd /opt/google/s3fs*
./autogen.sh && ./configure --prefix=/usr --with-openssl
make && make install
rm -f /tmp/s3fs.zip

mkdir -p /mnt/backup
chown vagrant:vagrant /mnt/backup
AWS_ACCESS_KEY=$(tail -n 1 /home/vagrant/AWS/accessKeys.csv | cut -f 1 -d ',')
AWS_ACCESS_PWD=$(tail -n 1 /home/vagrant/AWS/accessKeys.csv | cut -f 2 -d ',')
echo $AWS_ACCESS_KEY:$AWS_ACCESS_PWD > /etc/passwd-s3fs
chmod 600 /etc/passwd-s3fs
echo "yk-irexchange /mnt/backup fuse.s3fs auto,rw,_netdev,allow_other,endpoint=ap-southeast-2 0 0" >> /etc/fstab
mount -a

SYSD_OVERRIDE='/etc/systemd/system/docker.service.d/'

# Install docker
if [ ! -f /etc/yum.repos.d/docker-main.repo ]; then
   curl -sSL https://get.docker.com/ | sh
   usermod -aG docker vagrant
  
   systemctl stop firewalld
   systemctl disable firewalld
fi

if [ ! -f "$SYSD_OVERRIDE/override.conf" ]; then
   systemctl stop docker
   rm -rf /var/lib/docker
   mkdir -p $SYSD_OVERRIDE

   cat <<EOF > $SYSD_OVERRIDE/override.conf
[Service]
Environment="DOCKER_OPTS=--storage-driver devicemapper --storage-opt dm.thinpooldev=/dev/mapper/docker-thinpool --storage-opt dm.use_deferred_removal=true --storage-opt dm.use_deferred_deletion=true"
EOF

   sed -i '/^ExecStart=/ s/$/ \$DOCKER_OPTS/' /usr/lib/systemd/system/docker.service
   systemctl daemon-reload
   systemctl start docker
   systemctl enable docker
fi

# Install docker compose 
if [ ! -f /usr/bin/docker-compose ]; then
   curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/bin/docker-compose
   chmod +x /usr/bin/docker-compose
fi

# Install docker machine
if [ ! -f /usr/bin/docker-machine ]; then
   curl -L https://github.com/docker/machine/releases/download/v${DOCKER_MACHINE_VERSION}/docker-machine-`uname -s`-`uname -m` > /usr/bin/docker-machine
   chmod +x /usr/bin/docker-machine
fi

# Install nvm
if [ ! -e nvm ]; then
   su vagrant -c "curl https://raw.githubusercontent.com/creationix/nvm/v0.30.1/install.sh | bash"
fi

# Install GIT
yum groupinstall -y "Development Tools"
yum install -y gettext-devel openssl-devel perl-CPAN perl-devel zlib-devel
curl -L https://github.com/git/git/archive/v${GIT_VERSION}.tar.gz -o /tmp/git-${GIT_VERSION}.tar.gz
cd /tmp && tar xzf /tmp/git-${GIT_VERSION}.tar.gz &&  cd git-${GIT_VERSION}
make configure
./configure --prefix=/usr/local
make install
git --version

# Setup VIM
mkdir -m 700 -p /home/vagrant/.vim/colors
chown -R vagrant:vagrant /home/vagrant/.vim
curl -L http://www.vim.org/scripts/download_script.php?src_id=4055 -o /home/vagrant/.vim/colors/desert256.vim
curl -L http://www.vim.org/scripts/download_script.php?src_id=2249 -o /home/vagrant/.vim/yaml.vim
cat <<EOT > /home/vagrant/.vimrc
set t_Co=256
au BufNewFile,BufRead *.yaml,*.yml so ~/.vim/yaml.vim
syntax on
colorscheme desert256
set incsearch
set hlsearch
EOT

# Setup SSH AGENT
cat <<EOT >> /home/vagrant/.bash_profile
alias ws='cd /home/vagrant/workspace'

if [ \$(pidof ssh-agent) == "" ]; then
  eval $(ssh-agent -s)
  find /home/vagrant/.ssh -name '*.key' | xargs -I {} ssh-add {}
fi
EOT
