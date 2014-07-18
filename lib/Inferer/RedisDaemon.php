<?php

namespace Inferer;

class RedisDaemon
{
  use Initializer;

  private function defaults()
  {
    return $this->defaults = array(
      'server_path' => 'vendor/redis/src/',
      'server_executable' => 'redis-server',
      'port' => 6379
    );
  }

  public function __construct(array $args = array())
  {
    $this->initializePublicProperties($args);
    return $this;
  }

  public function start()
  {
    if ($this->isAlreadyRunning()) {
      echo "{$this->server_path}{$this->server_executable} is already running\n";
    } else {
      shell_exec("nohup {$this->server_path}{$this->server_executable} > /dev/null & echo $!");
      echo "{$this->server_path}{$this->server_executable} started\n";
    }
  }

  public function isAlreadyRunning()
  {
    exec("netstat -ln | grep {$this->port}", $output, $return);
    return $output;
  }
}


?>
