<?php

$b = $c = $e;

// namespace ciao\mondo;

$v = '';
$$vv = 'pippo';
$a[1][2] = 'pippa';

function prova(bool $ella, int $peppa)
{
  global $a, $b, $c;
  $GLOBALS['a'] = 1;
  $GLOBALS['a']['b'] = 2;
  $GLOBALS['a'] = 1;
	$a = '';
	$$vv1 = 'pippo';
	$a1[1] = 'pippa';
  $a1[1] = 'aladin';
}

class mondo extends pippo {

  public static $b = 'a';

  private function ciao(int $a){
    $GLOBALS['a']['b'] = 2;
    global $a, $b, $c;
    $this->a->b = $a;
    self::$b = 'ciao';
    $GLOBALS['a']['b'] = 2;
    $GLOBALS['a'] = 1;
  }

  private function hola(){

  }

  public function hi(){

  }
}

use \asd\asda\asdasdasd\bello as cizza;

function cizza() {

}

$a = 'aasdasd';
