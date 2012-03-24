require 'posix-spawn'

pid = POSIX::Spawn::spawn 'rake update_git_svn'

at_exit do
  system "kill #{pid}"
end
