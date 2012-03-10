require 'grit'
require 'posix-spawn'

class HomeController < ApplicationController
  def index
    @commits = find_commits().reject { |commit| commit[:author] == "bamboo" }
  end

  def newcommits
    repo_dir = "~/hacktivity-git-repos"
    git_svn_rebase repo_dir

    repo = Grit::Repo.new(repo_dir)
    last_known_commit = params[:last_known_commit]
    new_commits = repo.commits_between last_known_commit, repo.commits.first
    
    render :json => to_hash(new_commits)
  end

  def find_commits
    repo_dir = "~/hacktivity-git-repos"
    git_svn_rebase repo_dir

    repo = Grit::Repo.new(repo_dir)
    branch = repo.head.name

    to_hash repo.commits(branch, 50)
  end

  def to_hash commits
      commits.map do |commit|
          {
              :id => commit.id,
              :author => commit.author.name,
              :date => commit.committed_date,
              :message => trim_git_svn_msg(commit.message),
              :svn_rev => svn_revision(commit.message)
          }
      end
  end

  def git_svn_rebase repo_dir
    # pid = POSIX::Spawn::spawn 'git svn rebase', :chdir => File.expand_path(repo_dir)
    # uncomment the line below to wait for svn rebase to complete
    # Process::waitpid(pid)
  end

  def trim_git_svn_msg(commit_msg)
    commit_msg.gsub(/\n\ngit\-svn\-id\: .*$/m, "")
  end

  def svn_revision(commit_msg)
    commit_msg.match(/git-svn-id: .+@(\d+) /) { |capture_groups|
        capture_groups.length > 1 ? capture_groups[1] : ''
    }
  end


end
