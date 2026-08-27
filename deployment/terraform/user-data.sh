#!/bin/bash

set -e

dnf update -y

dnf install -y docker awscli

systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user

echo "Docker and AWS CLI installation completed" > /tmp/setup.log