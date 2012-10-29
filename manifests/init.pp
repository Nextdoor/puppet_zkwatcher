# =Module: zk_watcher
#
# Simple Puppet module to install the 'zk_watcher' python daemon
# and configure it to monitor any number of services on a host.
#
# =Parameters:
# - _none_
#
# =Actions:
# - Installs 'zk_watcher'
# - Creates a config directory (/etc/zk)
# - Creates the config file header with Concat
#
# =Sample Usage:
#   include zk
#
class zk_watcher {
  # Install python packages required for Zookeeper communication
  $wantedpippackages = [ 'zk_watcher' ]

  package { $wantedpippackages:
    ensure   => present,
    provider => pip,
    require  => Class['python'];
  }

  # Copy up the private key
  file {
    '/etc/zk':
    ensure  => directory,
    owner   => root,
    group   => root,
    recurse => true,
    purge   => true,
    force   => true,
    require => Package[$wantedpippackages];
  }

  # Load up the concat module to help generate our documen
  include concat::setup

  # Create a concat config file. Start it out empty.
  concat { '/etc/zk/config.cfg':
    owner   => root,
    group   => root,
    mode    => '0600',
    require => File['/etc/zk'];
  }

  # Make sure that there's a header in our ZK config file
  concat::fragment{ '/etc/zk/config.cfg-header':
    target  => '/etc/zk/config.cfg',
    content => '# zookeeper config file is managed by puppet.\n',
    order   => 1;
  }
}
