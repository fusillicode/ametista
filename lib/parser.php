<?php

include_once dirname(dirname(__FILE__)).'/vendor/autoload.php';

trait Initializer
{
  private function initializePublicProperties($args = array())
  {
    $this->args = $args;
    $public_properties = array_merge($this->defaults, $args);
    foreach ($public_properties as $public_property => $value) {
      $this->$public_property = $value;
    }
  }
}

class RedisDaemon
{
  use Initializer;

  public $defaults = array(
    'server_path' => 'vendor/redis/src/',
    'server_executable' => 'redis-server',
    'port' => 6379
  );

  public function __construct($args = array())
  {
    $this->initializePublicProperties($args);
    return $this;
  }

  public function start()
  {
    if ($this->isDaemonAlreadyRunning()) {
      echo "{$this->server_path}{$this->server_executable} is already running\n";
    } else {
      shell_exec("nohup {$this->server_path}{$this->server_executable} > /dev/null & echo $!");
      echo "{$this->server_path}{$this->server_executable} started\n";
    }
  }

  public function isDaemonAlreadyRunning()
  {
    exec("netstat -ln | grep {$this->port}", $output, $return);
    return $output;
  }
}

class DataStore
{
  public $defaults = array(
    'client' => new Predis\Client(
      'scheme' => 'tcp',
      'host'   => 'localhost',
      'port'   => 6379
    )
  );

  public function __construct($args = array())
  {
    $this->initializePublicProperties($args);
    return $this;
  }

  public function connectTo()
  {
    try {
      $this->client->connect();
      echo "Successfully connected to daemon\n";
    } catch (Exception $e) {
      exit("Couldn't connected to daemon\n{$e->getMessage()}\n");
    }
  }

  public function clear()
  {
    return $this->client->flushall();
  }
}

class Parser
{
  public $defaults = array(
    'lexer' => new PHPParser_Lexer_Emulative(),
    'parser' => new PHPParser_Parser($this->defaults['lexer']),
    'traverser' => new PHPParser_NodeTraverser(),
    'visitors' => array(new PHPParser_NodeVisitor_NameResolver()),
    'node_dumper' => new PHPParser_NodeDumper(),
    'serializer' => new PHPParser_Serializer_XML(),
    // con 128M e 256M l'analisi del di file con 30000 LOC da un errore...l'errore è legato alla chiamata
    // token_get_all() all'interno del Lexer
    'memory_limit' => '512M',
    'data_store' => new DataStore()
  );

  public function __construct($args = array())
  {
    $this->initializePublicProperties();
    $this->addVisitors();
  }

  public function set_memory_limit()
  {
    ini_set('memory_limit', (int)$this->memory_limit.'M');
  }

  public function addVisitors(array $visitors)
  {
    $this->args['visitors'] = array_merge($this->args['visitors'], $visitors);
    foreach ($this->args['visitors'] as $key => $visitor) {
      $interfaces = class_implements($visitor);
      if (isset($interfaces['PHPParser_NodeVisitor'])) {
        $this->traverser->addVisitor($visitor);
      } else {
        echo "You're trying to add a visitor that doesn't have the proper interface\n";
      }
    }
  }

  public function parse($path, $recursive = true)
  {
    if (is_file($path)) {
      $this->parseFile($path);
    } elseif (is_dir($path)) {
      $this->parseDirectory($path, $recursive);
    } else {
      echo "There is no directory nor file named {$path}\n";
    }
    $this->_redis->lpush('xmls_asts', "THAT'S ALL FOLKS!");
  }

  public function parseDirectory($directory, $recursive)
  {
    $files = $this->getFiles($directory, $recursive);
    foreach ($files as $file) {
      $this->parseFile($file);
    }
  }

  public function parseFile($file)
  {
    try {
      echo "{$file}\n";
      $source_code = file_get_contents($file);
      $statements = $this->traverser->traverse($this->parser->parse($source_code));
      $xml = $this->serializer->serialize($statements);
      $this->_redis->lpush('xmls_asts', $this->serializer->serialize($statements));
      file_put_contents('./test_codebase_xml/'.$this->replaceExtension($file, 'xml'), $xml);
    } catch (PHPParser_Error $e) {
      echo "Parse Error: {$e->getMessage()}";
    }
  }

  private function replaceExtension($file_path, $new_extension)
  {
    $path_information = pathinfo($file_path);
    return "{$path_information['filename']}.{$new_extension}";
  }

  private function getFiles($root_directory, $recursive)
  {
    if (!file_exists($root_directory) && !is_dir($root_directory)) {
      echo "Directory \"{$root_directory}\" not found\n";
      return array();
    }
    $files = array();
    $stack[] = $root_directory;
    while ($stack) {
      $current_directory = array_pop($stack);
      $directory_content = scandir($current_directory);
      foreach ($directory_content as $content) {
        if ($content === '.' || $content === '..') {
          continue;
        }
        $current_element = "{$current_directory}/{$content}";
        $extension = pathinfo($current_element, PATHINFO_EXTENSION);
        if (is_file($current_element) && is_readable($current_element) && $extension === 'php') {
          $files[] = $current_element;
        } elseif (is_dir($current_element) && $recursive) {
          $stack[] = $current_element;
        }
      }
    }
    return $files;
  }

}

?>
