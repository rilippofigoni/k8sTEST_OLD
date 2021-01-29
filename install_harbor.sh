#!/bin/bash

# This script will install Harbor 2 on CentOS 8
# It will install Harbor using the Online Version which pulls images from DockerHub

echo Please enter FQDN for Harbor:
read fqdn

# Pre-reqs
yum install wget -y

# Docker
sudo yum install -y yum-utils
sudo yum-config-manager     --add-repo     https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io
sudo systemctl enable docker

# Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo  ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Add registry to host
echo "{" >  /etc/docker/daemon.json
echo "insecure-registries" : ["$fqdn:5000", "0.0.0.0"] >> /etc/docker/daemon.json
echo "}" >> /etc/docker/daemon.json

# Start Docker
sudo systemctl start docker

# Install Harbor
cd /opt
wget https://github.com/goharbor/harbor/releases/download/v2.0.5/harbor-online-installer-v2.0.5.tgz
tar xvf harbor-online-installer-v2.0.5.tgz
cd harbor
cp harbor.yml.tmpl harbor.yml

sed -i "s/reg.mydomain.com/$fqdn/g" harbor.yml
sed -i 's/port: 443//g' harbor.yml
sed -e '/https:/ s/^#*/#/' -i harbor.yml
sed -e '/certificate:/ s/^#*/#/' -i harbor.yml
sed -e '/private_key:/ s/^#*/#/' -i harbor.yml

sudo sh install.sh --with-trivy
