require 'mongo'
require 'posix-spawn'

def start_mongod
  puts "Starting database at: #{ENV["HACK_DB_DIR"]}"
  system "mkdir -p ./db"
  pid = POSIX::Spawn::spawn "mongod --dbpath #{ENV["HACK_DB_DIR"]} > /dev/null"

  at_exit do
    system "kill #{pid}"
  end
end

for i in 0..5
  begin
    db = Mongo::Connection.new.db('hacktivity')
  rescue Mongo::ConnectionFailure
    start_mongod if i == 0
    sleep 1
  end
end

$users = db['users']
