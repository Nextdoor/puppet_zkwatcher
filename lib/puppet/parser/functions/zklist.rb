#!/usr/bin/ruby
#
# Copyright 2012 Nextdoor.com, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# The ZKList class is a functional class in Ruby that provides methods for getting,
# caching, and returning arrays of server lists for a given path in a Zookeeper
# quorum.
#
# Example Usage:
#   require 'zklist.rb'
#   zk = ZKList.new( server = "localhost", port = "2182", cache_timeout = 3600 )
#   children = zk.get( "/services/production/uswest1/memcache" )
#
#   children.each do |kid|
#     print "kid: " + kid + "\n" 
#   end
# 

# Require 'yaml' first .. for some reason it will not load after rubygems is loaded
require 'yaml'

# 'load' the rubygem file rather than requiring it. This loads it up, but allows
# us to re-load it later if we find our selves having to install a missing rubygem.
#load '/usr/local/lib/site_ruby/1.8/rubygems.rb'
require 'rubygems'
require 'timeout'

# Check if the required gems are available. If not, try to install them. Do not check
# for 'rubygems' or 'yaml', as those are stock and always available.
def gem_available?(name,realname)
  begin
    require "#{name}"
  rescue Exception=>e
    puts "Missing gem (#{name}), installing it..."
    `gem install #{realname} --no-ri --no-rdoc`
    Gem.clear_paths
    require "#{name}"
  end
end
gem_available?('filecache','filecache')
gem_available?('zk','zk')

## The 'zklist' class gets a list of servers from ZooKeeper under a given path
## and returns the hostname and ports listed under that service. The list is always
## ordered alphabetically, and returns either *ALL* of the servers, or the number
## supplied as COUNT.
class ZKList

  def initialize(server, port, cache_timeout)
    @server = server
    @port = port
    @cache_timeout = cache_timeout

    # the cache should always be available... 
    @cache = FileCache.new("zk","/tmp", cache_timeout)

    # When running Puppet Apply on a local puppetmaster server, the Puppet process
    # forks a whole ton of processes. Unfortunately there are known bugs with the ZK module
    # and forking processes. This is documented and patched here:
    #   https://github.com/slyphon/zk/wiki/Forking
    ZK.install_fork_hook
  end

  # get a list of objects from our zookeeper server. max ouat at X objects
  # and sort by name 
  def zk_get(path, count)
    begin
      Timeout.timeout 30 do
        @client = ZK.new(@server+":"+@port)
      end
    rescue Timeout::Error
      return false
    rescue
      return false
    end

    # Get a list of the children in the path
    children = @client.children(path)

    # give the children back now
    return children.sort.first(count)
  end

  # get a list of objets from the zookeeper server and cache them to a local
  # file. in the event that zookeeper is down,  pull from the cache instead
  def get(path, count = 99)
    hash = path + "_" + count.to_s
    begin
      children = zk_get(path,count.to_i)
      @cache.set(hash, children.to_yaml)
    rescue Exception=>e
      if @cache.get(hash) == nil
        children = nil
      else
        children = YAML::load(@cache.get(hash))
      end
    end
    return children
  end

  def close
    if @client
      @client.close!
      @client = nil
    end
  end
end
