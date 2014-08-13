require_relative 'initializer'

class MongoDaemon

  extend Initializer
  initialize_with ({
    path: './vendor/mongodb/bin/mongod',
    database: './database',
    port: 27017,
    log: './database/mongod.log',
    pid: nil
  })

  def start
    @pid = Process.spawn "#{path} --fork --dbpath #{database} --logpath #{log} > /dev/null"
  end

  def stop
    Process.kill('TERM', pid) unless pid
  end

end
