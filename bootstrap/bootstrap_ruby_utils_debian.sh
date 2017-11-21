#!/usr/bin/env bash
set -x

if [[ $(id -u) -ne 0 ]]
  then echo "Please run as root"
  exit 1
fi

echo "Bootstrapping cgminer-ruby-utils"
apt-get update
apt-get install -y ruby ruby-dev gem
gem install rake bundler
(cd && git clone 'https://github.com/cmdallas/cgminer-ruby-utils.git')
rake -f ~/cgminer-ruby-utils/Rakefile build:all
bundle install --system --gemfile=$app_dir/Gemfile
echo "Finished"
exit 0
