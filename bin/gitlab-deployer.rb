#!/usr/bin/ruby19
#
require 'rubygems'
require 'daemons'
require 'optparse'
require "webhook-gitlab-branch-deployer"

options = {}
optparse = OptionParser.new do |opts|
  # Set a banner, displayed at the top
  # of the help screen.
  opts.banner = "Usage: command [options]"

  options[:verbose] = false
    opts.on( '-v', '--verbose', 'Output more information' ) do
    options[:verbose] = true
  end

  opts.on( '-p', '--port String', :required,  "Listen on port (default 3000)" ) do|l|
    options[:port] = l
  end
  options[:port] ||= 3000

  opts.on( '-m', '--puppet String', :required,  "Puppet manifests path" ) do|l|
    options[:puppet] = l
  end
  options[:puppet] ||= '/etc/gitlab-deployer'

  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end
optparse.parse!

Daemons.run_proc(
  'gitlab-deployer',
  :dir => '/var/run',
  :backtrace => true,
  :log_dir => '/var/log',
  :log_output => true
) do
  Rack::Handler::Thin.run(app, Port: options[:port], threaded: true)
end

