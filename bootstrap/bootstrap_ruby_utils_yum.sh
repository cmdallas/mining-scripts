#!/usr/bin/env bash
set -x

if [[ $(id -u) -ne 0 ]]
  then echo "Please run as root"
  exit 1
fi

bootstrap_ruby_utils() {
  echo "Bootstrapping cgminer-ruby-utils"
  cd && git clone 'https://github.com/cmdallas/cgminer-ruby-utils.git'
  rake -f ~/cgminer-ruby-utils/Rakefile build:all
  bundle install --system --gemfile=~/cgminer-ruby-utils/Gemfile
  echo "Finished"
  exit 0
}

bootstrap_ruby_utils

exit $?
