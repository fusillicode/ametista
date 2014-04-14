<?php


// $b = $c = $e;

// $v = '';
// $$vv = 'pippo';
// $a[1][2] = 'pippa';

namespace ciao\asd\asdasdasd\iei;

$GLOBALS['a'] = 1;
$GLOBALS['a']->b = 1;
$GLOBALS['a']->b[1] = 1;
$GLOBALS['a']->b[1][1] = 1;
$GLOBALS['a'][1]->b = 1;
$GLOBALS['a'][1][1]->b = 1;
$GLOBALS['b'][1]->b[1] = 1;

class Sole {

  function soleggia()
  {
    $GLOBALS['a'] = 1;
    $GLOBALS['a']->b = 1;
    $GLOBALS['a']->b[1] = 1;
    $GLOBALS['a']->b[1][1] = 1;
    $GLOBALS['a'][1]->b = 1;
    $GLOBALS['a'][1][1]->b = 1;
    $GLOBALS['b'][1]->b[1] = 1;
    self::$a = 1;
    self::$a->b = 1;
    self::$a[1]->b = 1;
    self::$a->b[1] = 1;
    self::$a[1][1]->b = 1;
    self::$a->b[1][1] = 1;
    self::$a[1]->b[1] = 1;
    $this->a = 1;
    $this->a->b = 1;
    $this->a[1]->b = 1;
    $this->a->b[1] = 1;
    $this->a[1][1]->b = 1;
    $this->a->b[1][1] = 1;
    $this->a[1]->b[1] = 1;
    $locale = 1;

    $this->context->cookie['a']->{$this->table.'_pagination'} = $limit;
    // $this->context->cookie['a'][1]->{$this->table.'_pagination'} = $limit;
    // $this->context->{$this->table.'_pagination'}->cookie = $limit;
    // $this->context->{$this->table.'_pagination'}->cookie['1'] = $limit;
    // $this->context->{$this->table.'_pagination'}->cookie['1']->a = $limit;
    // $this->context->cookie->{$this->table.'_pagination'} = $limit;
  }

}

// true, false, null, 1, 1.3, 'asd', array(1,2)

function prova($ella = __NAMESPACE__, int $ella)
{
  $a = 1;
  $a[1] = 1;
  $a[1][1] = 1;

  // USARE $this IN UN A FUNZIONE NON HA SENSO MA HO MESSO QUESTE COSE COME PROVA (il corretto utilizzo è quello nella funzione soleggia nella classe Sole)
  $this->a = 1;
  $this->a->b = 1;
  $this->a[1]->b = 1;
  $this->a->b[1] = 1;
  $this->a[1][1]->b = 1;
  $this->a->b[1][1] = 1;
  $this->a[1]->b[1] = 1;

  $c->a = 1;
  $c->a->b = 1;
  $c->a[1]->b = 1;
  $c->a->b[1] = 1;
  $c->a[1][1]->b = 1;
  $c->a->b[1][1] = 1;
  $c->a[1]->b[1] = 1;

  // USARE self:: IN UN A FUNZIONE NON HA SENSO MA HO MESSO QUESTE COSE COME PROVA (il corretto utilizzo è quello nella funzione soleggia nella classe Sole)
  self::$a = 1;
  self::$a->b = 1;
  self::$a[1]->b = 1;
  self::$a->b[1] = 1;
  self::$a[1][1]->b = 1;
  self::$a->b[1][1] = 1;
  self::$a[1]->b[1] = 1;

  AClass::$a = 1;
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

  $_POST['a'] = 1;
  $_POST['a']->b = 1;
  $_POST['a']->b[1] = 1;
  $_POST['a']->b[1][1] = 1;
  $_POST['a'][1]->b = 1;
  $_POST['a'][1][1]->b = 1;
  $_POST['b'][1]->b[1] = 1;

  /////////////////////////////////////////
  global $a;
  global $b, $c;

  // NON VIENE SUPPORTATO PRATICAMENTE DA NESSUNO...questo qui sotto (i.e. variabile di variabile) significa che la variabile avente nome uguale a valore contenuto nella variabile $vv1 assume valore 'pippo'
	// $$vv1 = 'pippo';

  return $this->ad;

}

class mondo extends pippo {

  public static $a = '12';
  private $b = 'asd';

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

