require 'rack'
require 'json'

LOCAL_REPO_PATH = '/opt/git'

app = Proc.new do |env|
  Rack::Request.new(env)
  msg = JSON.parse env['rack.input'].read
  repository = msg['repository']['url']
  branch_to_update = msg['ref'].split('refs/heads/')[-1]
  # TODO, split by '; ' why??
  return error_response if branch_to_update.empty?
  ok_response
  branch_deletion = msg['after'].gsub('0', '').empty?
  branch_addition = msg['before'].gsub('0', '').empty?
  if branch_addition
    add_branch(branch: branch_to_update, repository: repository)
  else
    if branch_deletion
      remove_branch(branch_to_update)
    else
      update_branch(branch: branch_to_update, repository: repository)
    end
  end
  ok_response
end

def ok_response
  [200, { 'Content-Type' => 'text/plain' }, ['OK']]
end

def error_response
  [400, { 'Content-Type' => 'text/plain' }, ['Bad request']]
end

def update_branch(cfg)
  puts 'Updating branch'
  p cfg
  branch = cfg[:branch]
  repository = cfg[:repository]
  branch_path = LOCAL_REPO_PATH + '/' +  branch
  if Dir.exists?(branch_path)
    Dir.chdir(branch_path)
    system("git checkout -f #{branch}")
    system('git clean -fdx')
    system("git fetch origin #{branch}")
    system('git reset --hard FETCH_HEAD')
    puts "updated #{branch} from #{repository} => #{branch_path}"
  else
    add_branch(cfg)
  end
end

def remove_branch(branch)
  puts "remove #{branch}"
end

def add_branch(cfg)
  puts 'Adding branch'
  p cfg
  Dir.chdir(LOCAL_REPO_PATH)
  branch = cfg[:branch]
  repository = cfg[:repository]
  branch_path = LOCAL_REPO_PATH + '/' +  branch
  if Dir.exists?(branch_path)
    update_branch(cfg)
  else
    cmd = "git clone --depth 1 -o origin -b #{branch} #{repository} #{branch}"
    system(cmd)
    puts "add #{branch} from #{repository} => #{branch_path}"
  end
end

Rack::Handler::Thin.run(app, Port: 3000, threaded: true)
