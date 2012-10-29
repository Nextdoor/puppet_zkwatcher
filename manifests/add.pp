# =Definition: zk_watcher::add
#
# Registers a host as providing a particular 'service' in ZooKeeper
#
# =Parameters:
# - _name_: This is the service you want to register... ie 'prod_memcache_uswest1'
# - _port_: This is the local port that the service listens to
# - _refresh_: This is how often to run the service check
# - _path_: Fully qualified path the register the service under
# - _cmd_: The service check command itself. Must return 0 to register the service.
# - _data_: An array (or item) of equals-separated data pairs. ie (key=value)
#
# =Actions:
# - Adds another line to the update.sh zookeeper script
#
# =Sample Usage:
#   zk_watcher::add { 'memcache':
#     port    => '11211',
#     cmd     => 'pgrep memcached',
#     path    => '/services/production/uswest1/memcache',
#     data    => 'zone=uswest1a',
#     refresh => '60';
#   }
#
define zk_watcher::add (
  $port,
  $cmd,
  $path,
  $data = '',
  $refresh = 30
){
  include zk_watcher, zk_watcher::service

  # Add our zookeeper command to the update.sh script
  concat::fragment{ "/etc/zk/config.cfg-${name}":
    target  => '/etc/zk/config.cfg',
    content => template('zk/config.cfg.erb'),
    order   => 10,
    notify  => Class['zk_watcher::service'];
  }
}
