============================================
Puppet Plugin: ZooKeeper Watcher Integration
============================================

This Puppet module and plugin serves two functions. It provides a method for
building Puppet manifests with dynamically-obtained ZooKeeper server lists. It
also provides a method for configuring [zk_watcher](http://github.com/Nextdoor/zkwatcher) to monitor one or many
services on a particular host, and register them with ZooKeeper.

zkget: Retrieving dynamic server lists
--------------------------------------

The `zkget` function in thie module allows the Puppet Master server to ask
a ZooKeeper service for a list of servers at a particular path, and provides
that list in an array-form for your puppet manifests. This allwos you to
dynamically configure parts of your infrastructure without hard-coding server
hostnames or data.

In the Puppet manifest, get the list of servers. This retrieves a list of no
less than 1 server, and no more than 10:

    $servers = zkget('/services/memcache', 1, 10)

`note:` This function relies on servers being listed by their hostname and port,
which is how the `zk_watcher` daemon registers them.
    
zkwatcher: Puppet Client Module
-------------------------------

The `zkwatcher` class installs the [zk_watcher](http://github.com/Nextdoor/zkwatcher) pip module, configures an
Upstart job to start up the service, and provides a definition that can be used
throughout your Puppet classes to register different services with Apache ZooKeeper
in a method that allows the above `zkget` function to be used.

Example usage:

    zk::add { 'pgpool':
      port    => 5432,
      cmd     => 'service pgpool status',
      path    => "/services/production/pgpool",
      refresh => '120';
    }

Installation
------------
Installation is simple... checkout this Git repository into a new module in your
Puppet modules path, and create the configuration file ::

    cd <your puppet path>/modules
    git clone git@github.com:Nextdoor/puppet_zkwatcher.git zk_watcher
