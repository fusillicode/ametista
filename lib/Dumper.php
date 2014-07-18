<?php

class Dumper
{
  use Initializer;

  private function defaults()
  {
    return $this->defaults = array(
      'location' => './test_codebase_xml/',
      'new_extension' => 'xml'
    );
  }

  public function __construct(array $args = array())
  {
    $this->initializePublicProperties($args);
    return $this;
  }

  public function dump($file_name, $content)
  {
    file_put_contents($this->getPath($file_name), $content);
  }

  public function getPath($file_name)
  {
    return $this->location.$this->replaceExtension($file_name);
  }

  public function replaceExtension($file_name)
  {
    $info = pathinfo($file_name);
    return $info['filename'].$this->new_extension;
  }
}

?>
