#!/usr/bin/env bash
#
# File:         ruby-bootstrap.sh
# Description:  This script bootstraps rvm, Ruby, bundler and any defined gems in a Ruby project directory.
# Homepage:     https://github.com/miguno/ruby-bootstrap
#
# Tested with Bash shell on RHEL/CentOS 6 and Mac OS X 10.8.

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
if [ "$OS" = "$OS_MAC" ]; then
  red='\x1B[1;31m'
  green='\x1B[1;32m'
  yellow='\x1B[1;33m'
  blue='\x1B[1;34m'
  nocolor='\x1B[0m'
else
  red='\e[1;31m'
  green='\e[1;32m'
  yellow='\e[1;33m'
  blue='\e[1;34m'
  nocolor='\e[0m'
fi

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
function find_ruby_version_file() {
  local filename=".ruby-version"
  local curr_dir=$1
  curr_dir=`cd "$curr_dir"; pwd`
  local candidate_file="$curr_dir/$filename"
  while [ ! -f "$candidate_file" ]; do
    parent_dir=`cd ..; pwd`
    if [ "$parent_dir" = "$curr_dir" ]; then
      # We have reached /, we can't go up any further.
      candidate_file=""
      break
    else
      curr_dir="$parent_dir"
      candidate_file="$curr_dir/$filename"
    fi
  done
  echo $candidate_file
}

function detect_desired_ruby_version() {
  local desired_ruby_version=""
  ruby_version_file=`find_ruby_version_file $(pwd)`
  if [ -n "$ruby_version_file" ]; then
    desired_ruby_version=`head -n 1 $ruby_version_file`
  fi
  echo $desired_ruby_version
}

puts -n "Detecting desired Ruby version: "
DESIRED_RUBY_VERSION=`detect_desired_ruby_version`
if [ -z $DESIRED_RUBY_VERSION ]; then
  warn "FAILED (could not find .ruby-version)"
  puts "Installing latest stable Ruby version locally via rvm..."
  rvm install ruby
else
  success "OK"
  rvm install $DESIRED_RUBY_VERSION
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
puts "Installing gems (if any)"
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

puts "Thanks for using ruby-bootstrap.  Happy hacking!"
