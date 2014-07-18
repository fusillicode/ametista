<?php

include_once dirname(dirname(__FILE__)).'/vendor/autoload.php';

$redis_daemon = new RedisDaemon();
$channel = new Channel();
$parser = new Parser();
$dumper = new Dumper();
$root_directory = './test_codebase';

$redis_daemon->start();
$channel->connect();

$recursive_directory_iterator = new RecursiveDirectoryIterator($root_directory);
foreach (new RecursiveIteratorIterator($recursive_directory_iterator) as $file_name => $file) {
  if ($file->getExtension() !== 'php') {
    continue;
  }
  $ast = $parser->parse($file->getPathname());
  $channel->push($ast);
  $dumper->dump($file_name, $ast);
}
$channel->clear();

?>
