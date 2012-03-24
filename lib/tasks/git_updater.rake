desc "Update Git repository from svn"
task :update_git_svn do
  while true do
    pid = POSIX::Spawn::spawn 'git svn rebase', :chdir => File.expand_path(ENV["REPO_DIR"])
    Process::waitpid(pid)
    sleep 5
  end
end
