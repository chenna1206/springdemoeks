#!/bin/bash

set -e

echo "Starting EC2 setup..." > /tmp/setup.log

apt-get update -y

apt-get install -y docker.io awscli

systemctl enable docker
systemctl start docker

usermod -aG docker ubuntu

echo "Docker and AWS CLI installation completed" >> /tmp/setup.log