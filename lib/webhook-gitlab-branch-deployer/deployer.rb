require 'json'

class Deployer
  LOCAL_REPO_BASE_PATH = '/opt/git'

  def initialize(params)

    @puppet_path = params[:puppet_path]
    @repository = params[:msg]['repository']['url']
    @repository_name = params[:msg]['repository']['name']
    @branch = params[:msg]['ref'].split('refs/heads/')[-1]
    @branch_path = local_repo_path + '/' + @branch
    @response = :ok
    @emails = params[:msg]['commits'].map {|a| a['author']['email']}.uniq

    if params[:msg]['after'].gsub('0', '').empty? #delete branch
      @action = :delete
    else
      if params[:msg]['before'].gsub('0', '').empty? #new branch
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
      when :update then 
        update_branch
	puppet_run
      when :add then 
        add_branch
	puppet_run
      when :delete then delete_branch
      else @response = :error
    end
  end

  def local_repo_path
    LOCAL_REPO_BASE_PATH + '/' + @repository_name
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

  def add_branch
    puts 'Adding branch'
    Dir.chdir(local_repo_path)
    cmd = "git clone --depth 1 -o origin -b #{@branch} #{@repository} #{@branch}"
    system(cmd)
    puts "add #{@branch} from #{@repository} => #{@branch_path}"
  end

  def puppet_manifest
    "#{@puppet_path}/#{@repository_name}.pp"
  end

  def puppet_run
    if File.exists?(puppet_manifest) then
      puts "Applying Puppet manifest #{puppet_manifest}"
      cmd = "puppet apply #{puppet_manifest}"
      system(cmd)
      cmd = "Manifest #{puppet_manifest} applied"
    else
      puts "No Puppet manifest found @ #{puppet_manifest} "
    end
  end
end
