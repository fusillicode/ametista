<?php

namespace Inferer;

class Parser
{
  use Initializer;

  private function defaults()
  {
    $this->defaults = array(
      'lexer' => new PHPParser_Lexer_Emulative(),
      'traverser' => new PHPParser_NodeTraverser(),
      'visitors' => array(new PHPParser_NodeVisitor_NameResolver()),
      'serializer' => new PHPParser_Serializer_XML(),
      // con 128M e 256M l'analisi del di file con 30000 LOC da un errore...l'errore è legato alla chiamata
      // token_get_all() all'interno del Lexer
      'memory_limit' => '512M'
    );
    $this->defaults['parser'] = new PHPParser_Parser($this->defaults['lexer']);
    return $this->defaults;
  }

  public function __construct(array $args = array())
  {
    $this->initializePublicProperties($args);
    $this->addVisitors($this->args['visitors']);
    return $this;
  }

  public function set_memory_limit()
  {
    ini_set('memory_limit', (int)$this->memory_limit.'M');
  }

  public function addVisitors(array $visitors)
  {
    $this->visitors = array_merge($this->visitors, $visitors);
    foreach ($this->visitors as $key => $visitor) {
      $this->addVisitor($visitor);
    }
  }

  public function addVisitor(PHPParser_NodeVisitor $visitor)
  {
    $this->traverser->addVisitor($visitor);
  }

  public function parse($file_path)
  {
    try {
      echo "{$file_path}\n";
      $source_code = file_get_contents($file_path);
      $statements = $this->traverser->traverse($this->parser->parse($source_code));
      return $this->serializer->serialize($statements);
    } catch (PHPParser_Error $e) {
      echo "Parse Error: {$e->getMessage()}";
    }
  }
}

?>
