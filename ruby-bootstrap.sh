#!/usr/bin/env bash
#
# File:         ruby-bootstrap.sh
# Description:  This script bootstraps rvm, Ruby, bundler and any defined Ruby gems.
#
# Tested on RHEL/CentOS 6 and Bash shell.

MYSELF=`which $0`
MYDIR=`dirname $0`
RVM_FRESH_INSTALL=0 # 0=false, 1=true

###
### Helper variables and functions
###

# Make the operating system of this host available as $OS.
OS_UNKNOWN="os-unknown"
OS_MAC="mac"
OS_LINUX="linux"
case `uname` in
  Linux*)
    OS=$OS_LINUX
    ;;
  Darwin*)
    OS=$OS_MAC
    ;;
  *)
    OS=$OS_UNKNOWN
    ;;
esac

# Colors for shell output
red='\e[1;31m'
green='\e[1;32m'
yellow='\e[1;33m'
blue='\e[1;34m'
nocolor='\e[0m'

function puts() {
  local opts=''
  if [ "$1" = "-n" ]; then
    opts='-n'
    shift
  fi
  msg="$@"
  echo -e $opts "${blue}${msg}${nocolor}"
}

function warn() {
  local opts=''
  if [ "$1" = "-n" ]; then
    opts='-n'
    shift
  fi
  msg="$@"
  echo -e $opts "${yellow}${msg}${nocolor}"
}

function error() {
  local opts=''
  if [ "$1" = "-n" ]; then
    opts='-n'
    shift
  fi
  msg="$@"
  echo -e $opts "${red}${msg}${nocolor}"
}

function success() {
  local opts=''
  if [ "$1" = "-n" ]; then
    opts='-n'
    shift
  fi
  msg="$@"
  echo -e $opts "${green}${msg}${nocolor}"
}


###
### rvm bootstrap
###
puts -n "Checking for rvm: "
which rvm &>/dev/null
if [ $? -ne 0 ]; then
  error "NOT INSTALLED"
  puts "Installing latest stable version of rvm..."
  curl -L https://get.rvm.io | bash -s stable --ruby --autolibs=enable --ignore-dotfiles
  RVM_FRESH_INSTALL=1
else
  success "OK"
fi


###
### Ruby bootstrap
###
function detect_installed_ruby_version() {
  local ruby_version=`ruby --version 2>/dev/null | awk '{ print \$2 }' | sed -rn 's/^([[:digit:]](\.[[:digit:]])+)(p.+)?$/\1-\3/p' | sed 's/-$//'`
  echo $ruby_version
}

function detect_desired_ruby_version() {
  ruby_version_file=$MYDIR/.ruby-version
  DESIRED_RUBY_VERSION=`head -n 1 $ruby_version_file`
  echo $DESIRED_RUBY_VERSION
}

function install_ruby() {
  version=$1
  puts "Installing Ruby locally via rvm: "
  rvm install $version
}

puts -n "Checking for Ruby: "
INSTALLED_RUBY_VERSION=`detect_installed_ruby_version`
DESIRED_RUBY_VERSION=`detect_desired_ruby_version`
if [ -z $INSTALLED_RUBY_VERSION ]; then
  error "NOT INSTALLED"
  install_ruby $DESIRED_RUBY_VERSION
elif [ $INSTALLED_RUBY_VERSION != $DESIRED_RUBY_VERSION ]; then
  warn -n "INCORRECT VERSION"
  puts " ($INSTALLED_RUBY_VERSION but we need $DESIRED_RUBY_VERSION)"
  install_ruby $DESIRED_RUBY_VERSION
else
  success "OK"
fi


###
### bundler bootstrap
###
puts -n "Checking for bundler: "
if [ $? -ne 0 ]; then
  error "NOT INSTALLED"
  puts "Installing bundler locally via rvm..."
  gem install bundler
else
  success "OK"
fi

# Install gems
bundle install


###
### post install
###
if [ $RVM_FRESH_INSTALL -eq 1 ]; then
  warn "Important: We performed a fresh install of rvm for you."
  warn "           This means you manually perform two tasks now."
  warn
  warn "Task 1 of 2:"
  warn "------------"
  warn "Please run the following command in all your open shell windows to"
  warn "start using rvm.  In rare cases you need to reopen all shell windows."
  warn
  warn "    source ~/.rvm/scripts/rvm"
  warn
  warn
  warn "Task 2 of 2:"
  warn "------------"
  warn "Permanently update your shell environment to source/add rvm."
  warn "The example below shows how to do this for Bash."
  warn
  warn "Add the following two lines to your ~/.bashrc:"
  warn
  warn "    PATH=\$PATH:\$HOME/.rvm/bin # Add RVM to PATH for scripting"
  warn "    [[ -s \"\$HOME/.rvm/scripts/rvm\" ]] && source \"\$HOME/.rvm/scripts/rvm\" # Load RVM into a shell session *as a function*"
  warn
  warn "That's it!  Sorry for the extra work but this is the safest"
  warn "way to update your environment without breaking anything."
fi
