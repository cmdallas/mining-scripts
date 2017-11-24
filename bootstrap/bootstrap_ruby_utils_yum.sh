#!/usr/bin/env bash
set -x

if [[ $(id -u) -ne 0 ]]
  then echo "Please run as root"
  exit 1
fi

echo "Bootstrapping cgminer-ruby-utils"
yum update
yum install -y ruby gem
gem install rake bundler aws-sdk-sns aws-adk-cloudwatch aws-sdk-ec2
(cd && git clone 'https://github.com/cmdallas/cgminer-ruby-utils.git')
rake -f ~/cgminer-ruby-utils/Rakefile build:all
bundle install --system --gemfile= ~/cgminer-ruby-utils/Gemfile
echo "Finished"
exit 0
