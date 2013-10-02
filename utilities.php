<?php

function getFilesAlternative($root_directory)
{
  $files = array();
  $stack[] = $root_directory;
  while ($stack) {
    $current_directory = array_pop($stack);
    $handle = opendir($current_directory);
    while ($content = readdir($handle)) {
      if ($content === '.' || $content === '..') continue;
      $current_element = "{$current_directory}/{$content}";
      $extension = pathinfo($current_element, PATHINFO_EXTENSION);
      if (is_file($current_element) && is_readable($current_element) && $extension === 'php')
        $files[] = $current_element;
      elseif (is_dir($current_element))
        $stack[] = $current_element;
    }
    closedir($handle);
  }
  return $files;
}

function getFiles($root_directory)
{
  $files = array();
  $stack[] = $root_directory;
  while ($stack) {
    $current_directory = array_pop($stack);
    $directory_content = scandir($current_directory);
    foreach ($directory_content as $content) {
      if ($content === '.' || $content === '..') continue;
      $current_element = "{$current_directory}/{$content}";
      $extension = pathinfo($current_element, PATHINFO_EXTENSION);
      if (is_file($current_element) && is_readable($current_element) && $extension === 'php')
        $files[] = $current_element;
      elseif (is_dir($current_element))
        $stack[] = $current_element;
    }
  }
  return $files;
}

function printJudyObject(Judy $judy_object, $level = 0)
{
  foreach ($judy_object as $key => $value) {
    echo "level {$level} {$key}\n";
    if ($value instanceof Judy)
      printJudyObject($value, $level+1);
    elseif ($value instanceof PHPParser_Node)
      echo var_dump($value), "\n";
    elseif (is_string($value))
      echo "{$value}\n";
  }
}

function checkJudyExtension()
{
  if (extension_loaded('judy')) return true;
  if (!dl('judy.so')) return false;
  return true;
}

function replaceExtension($file_name, $new_extension)
{
  $path_information = pathinfo($file_name);
  return "{$path_information['file_name']}.{$new_extension}";
}

?>
