<?php

include_once dirname(dirname(__FILE__)).'/vendor/autoload.php';

$redis_daemon = new Inferer\RedisDaemon();
$channel = new Inferer\Channel();
$parser = new Inferer\Parser();
$dumper = new Inferer\Dumper();

$redis_daemon->start();
$channel->connect();
$channel->clear();

$root_directory = './test_simple_file';
$recursive_directory_iterator = new RecursiveDirectoryIterator($root_directory);
foreach (new RecursiveIteratorIterator($recursive_directory_iterator) as $file_name => $file) {
  if ($file->getExtension() !== 'php') {
    continue;
  }
  $ast = $parser->parse($file->getPathname());
  $channel->push($ast);
  $dumper->dump($file_name, $ast);
}

?>
