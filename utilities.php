<?php

function getFilesAlternative($rootDirectory)
{
  $files = array();
  $stack[] = $rootDirectory;
  while ($stack) {
    $currentDirectory = array_pop($stack);
    $handle = opendir($currentDirectory);
    while ($content = readdir($handle)) {
      if ($content === '.' || $content === '..') continue;
      $currentElement = "{$currentDirectory}/{$content}";
      $extension = pathinfo($currentElement, PATHINFO_EXTENSION);
      if (is_file($currentElement) && is_readable($currentElement) && $extension === 'php')
        $files[] = $currentElement;
      elseif (is_dir($currentElement))
        $stack[] = $currentElement;
    }
    closedir($handle);
  }
  return $files;
}

function getFiles($rootDirectory)
{
  $files = array();
  $stack[] = $rootDirectory;
  while ($stack) {
    $currentDirectory = array_pop($stack);
    $directoryContent = scandir($currentDirectory);
    foreach ($directoryContent as $content) {
      if ($content === '.' || $content === '..')
        continue;
      $currentElement = "{$currentDirectory}/{$content}";
      $extension = pathinfo($currentElement, PATHINFO_EXTENSION);
      if (is_file($currentElement) && is_readable($currentElement) && $extension === 'php')
        $files[] = $currentElement;
      elseif (is_dir($currentElement))
        $stack[] = $currentElement;
    }
  }
  return $files;
}

function printJudyObject(Judy $judyObject, $level = 0)
{
  foreach ($judyObject as $key => $value) {
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

function replaceExtension($fileName, $newExtension)
{
  $pathInformation = pathinfo($fileName);
  return "{$pathInformation['filename']}.{$newExtension}";
}

?>
