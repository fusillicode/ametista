<?php

namespace ciao\mondo;

$b = $c = $e;
$v = '';
$$vv = 'pippo';
$a[1][2] = 'pippa';

function prova(bool $ella, int $peppa)
{
  global $a;
	$v1 = '';
	$$vv1 = 'pippo';
	$a1[1] = 'pippa';
  $a1[1] = 'aladin';
}

class mondo extends pippo {

  public static $b = 'a';

  private function ciao(int $a){
    $this->a->b = $a;
    self::$b = 'ciao';
  }

  private function hola(){

  }

  public function hi(){

  }
}

use \asd\asda\asdasdasd\bello as cizza;

function cizza() {

}
