#!/usr/bin/ruby19
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

  options[:port] = 3000
  opts.on( '-p', '--port String',  "Listen on port (default #{options[:port]})" ) do |l|
    options[:port] = l
  end

  options[:puppet] = '/etc/gitlab-deployer'
  opts.on( '-m', '--puppet String',  "Puppet manifests path (default #{options[:puppet]})" ) do |l|
    options[:puppet] = l
  end

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
  app = Proc.new do |env|
    Rack::Request.new(env)
    msg = JSON.parse env['rack.input'].read
    deploy = Deployer.new(msg,options[:puppet])
    # TODO, split by '; ' why??
    deploy.local_update
    deploy.response
  end

  Rack::Handler::Thin.run(app, Port: options[:port], threaded: true)
end

