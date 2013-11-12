require 'json'

class Deployer
  LOCAL_REPO_PATH = '/opt/git'

  def initialize(msg)
    @repository = msg['repository']['url']
    @repository_name = msg['repository']['name']
    @branch = msg['ref'].split('refs/heads/')[-1]
    @branch_path = LOCAL_REPO_PATH + '/' +  @branch
    @response = :ok
    @emails = msg['commits'].map {|a| a['author']['email']}.uniq

    if msg['after'].gsub('0', '').empty? #delete branch
      @action = :delete
    else
      if msg['before'].gsub('0', '').empty? #new branch
        if Dir.exists?(@branch_path)
          @action = :update
        else
          @action = :add
        end
      else #probably update
        if Dir.exists?(@branch_path)
          @action = :update
        else
          @action = :add
        end
      end
    end
  end

  def response
    case @action
      when  :ok then [200, { 'Content-Type' => 'text/plain' }, ['OK']]
      else  [400, { 'Content-Type' => 'text/plain' }, ['Bad request']]
    end
  end

  def local_update
    if @branch.empty?
      @response = :error 
      return
    end
    case @action
      when :update then update_branch
      when :add then add_branch
      when :delete then delete_branch
      else @response = :error
    end
  end

  def update_branch
    puts 'Updating branch'
    Dir.chdir(@branch_path)
    system("git checkout -f #{@branch}")
    system('git clean -fdx')
    system("git fetch origin #{@branch}")
    system('git reset --hard FETCH_HEAD')
    puts "updated #{@branch} from #{@repository} => #{@branch_path}"
  end

  def remove_branch
    puts "remove #{@branch}"
  end

  def add_branch(cfg)
    puts 'Adding branch'
    Dir.chdir(LOCAL_REPO_PATH)
    cmd = "git clone --depth 1 -o origin -b #{@branch} #{@repository} #{@branch}"
    system(cmd)
    puts "add #{@branch} from #{@repository} => #{@branch_path}"
  end
end
