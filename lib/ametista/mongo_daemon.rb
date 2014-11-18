require_relative 'utilities'

class MongoDaemon

  extend Initializer
  initialize_with ({
    executable: './vendor/mongodb/bin/mongod',
    config_file: './mongodb.conf',
    pid: nil
  })

  def start
    @pid = Process.spawn "#{executable} --config #{config_file} > /dev/null"
  end

  def stop
    Process.kill('TERM', pid) unless pid
  end

end
