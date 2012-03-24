require 'grit'
require 'posix-spawn'


class HomeController < ApplicationController

  def index
  end

  def commits
      repo = Grit::Repo.new(ENV["REPO_DIR"])
      head = repo.my_branch
      commits = repo.commits(head.name, params[:max].to_i).reverse

      render :json => to_json(commits)
  end


  def newcommits
    repo = Grit::Repo.new(ENV["REPO_DIR"])
    last_known_commit = params[:last_known_commit]
    new_commits = repo.commits_between last_known_commit, repo.latest_commit
    render :json => to_json(new_commits)
  end

  def to_json commits
    commits.reject { |commit| commit.is_bamboo? }.map { |commit| commit.to_json }
  end
end

module CommitMixin
  def is_bamboo?
    self.author.name == 'bamboo'
  end

  def to_json
    {
        :id => id,
        :author => author.name,
        :date => self.committed_date,
        :message => trim_git_svn_msg(self.message),
        :svn => svn_revision,
        :avatar_img => avatar_img
    }
  end

  def svn_revision
    message.match(/git-svn-id: .+@(\d+) /) { |capture_groups|
      capture_groups.length > 1 ? capture_groups[1] : ''
    }
  end

  def trim_git_svn_msg(commit_msg)
    commit_msg.gsub(/\n\ngit\-svn\-id\: .*$/m, "")
  end

  def avatar_img
    return 'brainstorming.png' if author.name == 'stephens'
    return 'process.png' if author.name == 'rens'

    return ["business-contact.png",
     "config.png",
     "free-for-job.png",
     "future-projects.png",
     "hire-me.png",
     "illustration.png",
     "lightbulb.png",
     "my-account.png",
     "product-163.png",
     "user.png"].sample
  end
end

class Grit::Commit
  include CommitMixin
end

module RepoMixin
  def latest_commit
    commits(my_branch.name).first
  end

  def my_branch
    head || branches[0]
  end
end

class Grit::Repo
  include RepoMixin
end
