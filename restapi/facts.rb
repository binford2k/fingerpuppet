#! /opt/puppet/bin/ruby

# just a dinky script to generate a facts object. Redirect output to a file.

require 'puppet'
puts Puppet::Node::Facts.new(ARGV[0], Facter.to_hash).to_yaml
