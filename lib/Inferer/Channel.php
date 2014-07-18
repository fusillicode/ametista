<?php

namespace Inferer;

use Predis\Client;

class Channel
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
      'channel' => 'xmls_asts'
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
    } catch (Exception $e) {
      exit("Couldn't connected to daemon\n{$e->getMessage()}\n");
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
