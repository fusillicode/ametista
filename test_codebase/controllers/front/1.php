<?php


// $b = $c = $e;

// $v = '';
// $$vv = 'pippo';
// $a[1][2] = 'pippa';

function prova(bool $ella = 1, int $peppa)
{
  // $a = 1;
  // $a[1] = 1;
  // $a[1][1] = 1;

  $this->a = 1;
  $this->a->b = 1;
  $this->a[1]->b = 1;
  $this->a->b[1] = 1;
  $this->a[1][1]->b = 1;
  $this->a->b[1][1] = 1;
  $this->a[1]->b[1] = 1;

  // $c->a = 1;
  // $c->a->b = 1;
  // $c->a[1]->b = 1;
  // $c->a->b[1] = 1;
  // $c->a[1][1]->b = 1;
  // $c->a->b[1][1] = 1;
  // $c->a[1]->b[1] = 1;

  // self::$a = 1;
  // self::$a->b = 1;
  // self::$a[1]->b = 1;
  // self::$a->b[1] = 1;
  // self::$a[1][1]->b = 1;
  // self::$a->b[1][1] = 1;
  // self::$a[1]->b[1] = 1;

  AClass::$a = 1;
  AClass::$a->b = 1;
  AClass::$a[1]->b = 1;
  AClass::$a->b[1] = 1;
  AClass::$a[1][1]->b = 1;
  AClass::$a->b[1][1] = 1;
  AClass::$a[1]->b[1] = 1;

  $GLOBALS['a'] = 1;
  $GLOBALS['a']->b = 1;
  $GLOBALS['a']->b[1] = 1;
  $GLOBALS['a']->b[1][1] = 1;
  $GLOBALS['a'][1]->b = 1;
  $GLOBALS['a'][1][1]->b = 1;
  $GLOBALS['b'][1]->b[1] = 1;

  /////////////////////////////////////////
  global $a, $b, $c;

  // NON VIENE SUPPORTATO PRATICAMENTE DA NESSUNO...questo qui sotto (i.e. variabile di variabile) significa che la variabile avente nome uguale a valore contenuto nella variabile $vv1 assume valore 'pippo'
	// $$vv1 = 'pippo';

}

class mondo extends pippo {

  public static $a = '12';

  private function ciao(int $a){

  }

  private function hola(){

  }

  public function hi(){

  }
}

use \asd\asda\asdasdasd\bello as cizza;

function cizza() {

}

