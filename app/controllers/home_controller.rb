require 'grit'
require 'posix-spawn'
require 'mongo'

class HomeController < ApplicationController

  def index
  end

  def commits
      head = repo.my_branch
      commits = repo.commits(head.name, params[:max].to_i).reverse

      render :json => to_json(commits)
  end

  def newcommits
    last_known_commit = params[:last_known_commit]
    new_commits = repo.commits_between last_known_commit, repo.latest_commit
    render :json => to_json(new_commits)
  end

  private
  def to_json commits
    commits.reject { |commit| commit.is_bamboo? }.map { |commit| commit.to_json }
  end

  def repo
    Grit::Repo.new(ENV["HACK_REPO_DIR"])
  end
end

module CommitMixin
  def is_bamboo?
    self.author.name == 'bamboo'
  end

  def to_json
    author_details = commit_author;
    commit_stats = stats()
    {
        :id => id,
        :author => author_details['name'],
        :date => self.committed_date,
        :message => trim_git_svn_msg(self.message),
        :additions => commit_stats.additions,
        :deletions => commit_stats.deletions,
        :svn => svn_revision,
        :avatar_img => author_details['avatar']
    }
  end

  private
  def svn_revision
    message.match(/git-svn-id: .+@(\d+) /) { |capture_groups|
      capture_groups.length > 1 ? capture_groups[1] : ''
    }
  end

  def trim_git_svn_msg(commit_msg)
    commit_msg.gsub(/\n\ngit\-svn\-id\: .*$/m, "")
  end

  def commit_author
    @commit_author ||= $users.find_one({'aliases'=>author.name}) || default_author
  end

  def default_author
    { 'name' => author.name, 'avatar' => avatar_img }
  end

  def avatar_img
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
