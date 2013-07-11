# ruby-bootstrap

This script bootstraps [rvm](https://rvm.io/), [Ruby](http://www.ruby-lang.org/en/), [bundler](http://bundler.io/) and
any defined gems in a Ruby project directory.

Tested with Bash shell on RHEL/CentOS 6, Mac OS X 10.8 and Amazon Linux AMI images (on AWS/EC2).


## Usage

    $ curl -L https://raw.github.com/miguno/ruby-bootstrap/master/ruby-bootstrap.sh | bash -s

![Using ruby-bootstrap](images/ruby-bootstrap-1000px.png?raw=true)


## FAQ

### Detect desired Ruby version?

The script tries to find `.ruby-version` in the current directory.  If there is none, it recursively traverses from
the current directory to its parent directories and picks the first match.  For example, if you run the script from
the directory `foo/bar/quux/` then `foo/bar/quux/.ruby-version` would be picked before `foo/bar/.ruby-version`, which
in turn would be picked before `foo/.ruby-version` and so on.  This behavior matches rvm's.


### Error: import read failed (EPEL gpg key)?

Problem:

    error: /home/vagrant/.rvm/archives/RPM-GPG-KEY-EPEL-6: import read failed(2).
    error: open of /home/vagrant/.rvm/archives/epel-release-6-8.noarch.rpm failed: No such file or directory

This may happen when ``rvm`` tries to install Ruby on RHEL-compatible OS'es (e.g. Amazon Linux AMI images) that do not
have [EPEL](http://fedoraproject.org/wiki/EPEL) installed.  ``rvm`` requires EPEL to install build dependencies for
Ruby.


Fix:

    $ sudo rpm -Uhv https://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm


## License

Copyright © 2013 Michael G. Noll

See [LICENSE](LICENSE) for licensing information.
