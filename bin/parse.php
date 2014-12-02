<?php

include_once dirname(dirname(__FILE__)).'/vendor/autoload.php';

$redis_daemon = new Ametista\RedisDaemon();
$channel = new Ametista\RedisChannel();
$parser = new Ametista\Parser();
$dumper = new Ametista\Dumper();

$redis_daemon->start();
$channel->connect();
$channel->clear();

$root_directory = $argv[1];
$recursive_directory_iterator = new RecursiveDirectoryIterator($root_directory);
foreach (new RecursiveIteratorIterator($recursive_directory_iterator) as $file_name => $file) {
  if ($file->getExtension() !== 'php') {
    continue;
  }
  $ast = $parser->parse($file->getPathname());
  $channel->push($ast);
  $dumper->dump($file_name, $ast);
}
$channel->push("THAT'S ALL FOLKS!");

?>
