<?php

namespace Ametista;

use Predis\Client;

class RedisChannel
{
  use Initializer;

  private function defaults()
  {
    return $this->defaults = array(
      'client' => new Client([
        'scheme' => 'tcp',
        'host'   => 'localhost',
        'port'   => 6379
      ]),
      'channel'  => 'xmls_asts',
      'wait'     => 3,
      'attempts' => 5
    );
  }

  public function __construct(array $args = array())
  {
    $this->initializePublicProperties($args);
    return $this;
  }

  public function connect()
  {
    try {
      $this->client->connect();
      echo "Successfully connected to daemon\n";
    } catch (\Exception $e) {
      echo "Couldn't connected to daemon\n{$e->getMessage()}\n";
      $this->update_attempts();
      $this->try_again();
    }
  }

  public function try_again($wait = null)
  {
    $this->check_attempts();
    $wait = $wait ? $wait : $this->wait;
    echo "Trying again after ${wait} seconds\n";
    sleep($wait);
    $this->connect();
  }

  public function update_attempts()
  {
    $this->attempts--;
    echo "{$this->attempts} attempts remaining\n";
  }

  public function check_attempts()
  {
    if ($this->attempts === 0) {
      echo "{$this->attempts} reached, exiting now\n";
      exit(1);
    }
  }

  public function push($data)
  {
    $this->client->lpush($this->channel, $data);
  }

  public function clear()
  {
    return $this->client->flushall();
  }
}

?>
