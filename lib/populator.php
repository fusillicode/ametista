<?php

include_once dirname(dirname(__FILE__)).'/vendor/autoload.php';

class Populator
{
  public function __construct($server_path = 'vendor/redis-2.8.5/src/',
                              $server_executable = 'redis-server',
                              $address = '', $parser = null, $lexer = null,
                              $traverser = null, $visitors = array(),
                              $memory_limit = 1024)
  {
    $this->startRedisServer($server_path, $server_executable);
    $this->connectTo($address);
    $this->initialize();
    $this->setParser($parser, $lexer);
    $this->setTraverser($traverser);
    $this->setVisitors(array(new PHPParser_NodeVisitor_NameResolver()));
    // con 128M e 256M l'analisi del di file con 30000 LOC da un errore...l'errore è legato alla chiamata
    // token_get_all() all'interno del Lexer
    ini_set('memory_limit', (int)$memory_limit.'M');
  }

  private function startRedisServer($server_path, $server_executable)
  {
    exec("pgrep {$server_executable}", $output, $return);
    if ($return == 0) {
      echo "{$server_path}{$server_executable} is already running\n";
    } else {
      shell_exec("nohup {$server_path}{$server_executable} > /dev/null & echo $!");
      echo "{$server_path}{$server_executable} started\n";
    }
  }

  public function connectTo($address = '')
  {
    try {
      $this->_redis = new Predis\Client();
      $this->_redis->connect();
      echo "Successfully connected to Redis server\n";
    } catch (Exception $e) {
      exit("Couldn't connected to Redis server\n{$e->getMessage()}\n");
    }
  }

  public function initialize()
  {
    $this->clear();
  }

  public function setVisitors(array $visitors)
  {
    foreach ($visitors as $key => $visitor) {
      $interfaces = class_implements($visitor);
      if (isset($interfaces['PHPParser_NodeVisitor'])) {
        $this->traverser->addVisitor($visitor);
      } else {
        echo "You're trying to add a visitor that doesn't have the proper interface\n";
      }
    }
  }

  public function setParser(PHPParser_Parser $parser = null, PHPParser_Lexer $lexer = null)
  {
    return $this->parser = $parser ? $parser : new PHPParser_Parser($this->setLexer($lexer));
  }

  public function setLexer(PHPParser_Lexer $lexer = null)
  {
    return $this->lexer = $lexer ? $lexer : new PHPParser_Lexer_Emulative;
  }

  public function setTraverser(PHPParser_NodeTraverser $traverser = null)
  {
    return $this->traverser = $traverser ? $traverser : new PHPParser_NodeTraverser;
  }

  public function clear()
  {
    return $this->_redis->flushall();
  }

  public function get()
  {
    return $this->_redis;
  }

  public function populate($path, $recursive = true)
  {
    $files = $this->getFiles($path, $recursive);
    $this->node_dumper = new PHPParser_NodeDumper;
    $this->serializer = new PHPParser_Serializer_XML;
    foreach ($files as $file)
      $this->populateForFile($file);
  }

  public function populateForFile($file)
  {
    try {
      echo "{$file}\n";
      $source_code = file_get_contents($file);
      $statements = $this->traverser->traverse($this->parser->parse($source_code));
      $xml = $this->serializer->serialize($statements);
      $this->_redis->set("{$file}", $this->serializer->serialize($statements));
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
        if ($content === '.' || $content === '..') continue;
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
