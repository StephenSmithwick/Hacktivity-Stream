require "mongo"
require 'posix-spawn'

begin
  db = Mongo::Connection.new.db('hacktivity')

rescue Mongo::ConnectionFailure
  puts "Starting database at: #{ENV["HACK_DB_DIR"]}"
  system "mkdir -p ./db"
  pid = POSIX::Spawn::spawn "mongod --dbpath #{ENV["HACK_DB_DIR"]} > /dev/null"
  sleep 1
  db = Mongo::Connection.new.db('hacktivity')

  at_exit do
    system "kill #{pid}"
  end
end



$users = db['users']
