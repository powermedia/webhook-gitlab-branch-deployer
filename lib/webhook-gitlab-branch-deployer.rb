require 'rack'
require 'webhook-gitlab-branch-deployer/deployer.rb'

app = Proc.new do |env|
  Rack::Request.new(env)
  msg = JSON.parse env['rack.input'].read
  deploy = Deployer.new(msg)
  # TODO, split by '; ' why??
  deploy.local_update
  deploy.response
end

