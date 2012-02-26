require 'grit'

class HomeController < ApplicationController
  def index

    repo = Grit::Repo.new("~/hacktivity-git-repos")
    @commits = repo.commits('master', 300).map do |commit|
      {:author => commit.author.name,
       :date => commit.committed_date,
       :message => trim_git_svn_msg(commit.message),
       :svn_rev => svn_revision(commit.message)
      }
    end
  end

  def trim_git_svn_msg(commit_msg)
    commit_msg.gsub(/\n\ngit\-svn\-id\: .*$/m, "")
  end

  def svn_revision(commit_msg)
    commit_msg.match(/git-svn-id: .+@(\d+) /)[1]
  end


end