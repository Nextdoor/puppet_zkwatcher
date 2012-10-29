# =Module: zk_watcher::service
#
# Configures the 'zk_watcher' daemon to start up and restarts it
# any time the config.cfg file is updated.
#
# =Parameters:
# - _none_
#
# =Actions:
# - Creates an upstart job for zk_watcher
# - Symlinks /etc/init.d/zk_watcher for convenience
# - Makes sure the service is running.
#
# =Sample Usage:
#   include zk_watcher::service
#
class zk_watcher::service {
  include zk_watcher

  # Push our zk_watcher upstart job
  file {
    '/etc/init/zk_watcher.conf':
    ensure  => present,
    source  => 'puppet:///modules/zk/upstart',
    notify  => Service['zk_watcher'],
    require => Class['zk'];

    '/etc/init.d/zk_watcher':
    ensure  => symlink,
    target  => '/lib/init/upstart-job',
    require => File['/etc/init/zk_watcher.conf'];
  }

  service { 'zk_watcher':
    ensure     => running,
    provider   => upstart,
    hasstatus  => true,
    subscribe  => Class['zk_watcher'],
    require    => Class['zk_watcher'];
  }
}
