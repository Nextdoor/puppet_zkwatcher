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
# The 'zkget' function is a Puppet Parser Function that leverages the ZKList class in
# zklist.rb to return an array or string to a puppet manifest. The format for custom
# puppet functions is documented here: http://docs.puppetlabs.com/guides/custom_functions.html 
#
# Example Usage:
#   $servers = zkget("/services/production/uswest1/memcache", 2, 10)
#
# Retursn:
#   $servers = [ 'serverA:80', 'serverB:80' ]
#
require File.join(File.dirname(__FILE__), 'zklist.rb')

module Puppet::Parser::Functions
  newfunction(:zkget, :type => :rvalue) do |args|
    path  = args[0]
    min = args[1].to_i
    max = args[2].to_i
    zk = ZKList.new(server="localhost", port="2182", cache_timeout=172800)

    begin
      # Get a list of servers from zk.get.
      servers = zk.get(path,max)

      # Now, if the server array is smaller than our 'min' arguments,
      # completely bail out and don't even let the Puppet manifest compile.
      if servers.kind_of?(Array)
        # Assuming that the results came back in an array, make sure that the count
        # is at least as many as 'min'...
        if servers.count < min
          raise Puppet::ParseError, "Could not retreive at least [#{min}] servers from ZooKeeper at path [#{path}]. Exiting loudly."
        end

        # If servers.count and min are both 0, return a blank string..
        if servers.count == 0 and min == 0
          return false
        end
      else
        # If the results are NOT in an array, then we either have a 'nil' result,
        # or wer have a single string. Either way, if 'min' is 0, then we return
        # the data. If 'min' is 1 AND there is string data, then we return it.Lastly
        # either min is > 1, and we know to fail because we're already pas the array
        # sanity check above.
        if min == 0 
          return false
        elsif min == 1 and not servers.nil?
          return servers
        else
          raise Puppet::ParseError, "Could not retreive at least [#{min}] servers from ZooKeeper at path [#{path}]. Returned data was: [#{servers}]."
        end
      end

      # If we're here, we must have the list. Retrun it
      return servers
    ensure
      zk.close if zk
    end
  end
end
