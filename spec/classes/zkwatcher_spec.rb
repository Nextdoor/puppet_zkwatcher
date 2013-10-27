require 'spec_helper'

describe 'zk_watcher', :type => :class do
  context "On Debian system" do
    let :facts do
      {
        :osfamily               => 'Debian',
        :concat_basedir         => '/dne'
      }
    end
    it { should create_class('zk_watcher')}
  end
end

