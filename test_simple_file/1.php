<?php

class Semplice extends Complesso {

  public function malla() {

  }

}

$a = 1.2;

$GLOBALS['ingrassia'] = 'asdasda';

$a[1]->b[1][1]->d = 1; $b + $c;
$$vv = 'pippo'; $b = pippo($a = 'pluto', $c = 'parperino');
$a[1][2] = 'pippa';
AClass::$a = 1;
$_POST['a'] = 1;

// $GLOBALS['a'][1][1]->b = 1;
// $GLOBALS[AClass::$asd + 1] = $a = 1;
// $GLOBALS[AClass::$asd] = $a = 1;
// $GLOBALS[] = 1;
// $GLOBALS[$a->$b] = 1;
// $GLOBALS[12] = 1;
// $GLOBALS['a'] = 1;
// $GLOBALS['a']->b = 1;
// $GLOBALS['a']->b[1] = 1;
// $GLOBALS['a']->b[1][1] = 1;
// $GLOBALS['a'][1]->b = 1;
// $GLOBALS['a'][1][1]->b = 1;
// $GLOBALS['b'][1]->b[1] = 1;


// $GLOBALS['a'] = $a = 1;
// $GLOBALS[] = 1;
// $GLOBALS[12] = 1;
// $GLOBALS['a'] = 1;
// $GLOBALS['a']->b = 1;
// $GLOBALS['a']->b[1] = 1;
// $GLOBALS['a']->b[1][1] = 1;
// $GLOBALS['a'][1]->b = 1;
// $GLOBALS['a'][1][1]->b = 1;
// $GLOBALS['b'][1]->b[1] = 1;


class Sole {

  function soleggia(Ciccio $a = 1, Ciccia $b)
  {
    // Stmt_Foreach
    foreach ($variable as $key => $value) {
      # code...
    }
    // Stmt_For
    for ($i=0; $i < 10; $i++) {
      # code...
    }
    // Stmt_While
    while ($i <= 10) {
      # code...
    }
    // Stmt_Do
    do {

      // Stmt_If
    } while (true);
    // Stmt_If
    if (true) {
      # code...
    }
    // Stmt_If
    if (true) {
      # code...
      // Stmt_Else
    } else {
      # code...
    }
    // Stmt_If
    if (true) {
      # code...
    // Stmt_Elseif
    } elseif(null) {
      # code...
      // Stmt_Else
    } else {
      $GLOBALS['ciccio'] = 12;
      # code...
    }
    // Expr_Ternary
    $retVal = (true) ? a : b ;
    // Stmt_Switch
    switch (variable) {
      // Stmt_Case
      case 'value':
        # code...
        break;
      // Stmt_Case
      default:
        # code...
        break;
    }

    $GLOBALS['a'] = 1;
    $GLOBALS['a']->b = 1;
    $GLOBALS['a']->b[1] = 1;

    global $a, $b, $$a, $_POST;
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
    $a[1]->b[1][1]->d = 1;
    $b = $c = $e;
    $$vv = 'pippo';
    $a[1][2] = 'pippa';

    $this->context->cookie['a']->{$this->table.'_pagination'} = $limit;
    // $this->context->cookie['a'][1]->{$this->table.'_pagination'} = $limit;
    // $this->context->{$this->table.'_pagination'}->cookie = $limit;
    // $this->context->{$this->table.'_pagination'}->cookie['1'] = $limit;
    // $this->context->{$this->table.'_pagination'}->cookie['1']->a = $limit;
    // $this->context->cookie->{$this->table.'_pagination'} = $limit;
  }

}

// true, false, null, 1, 1.3, 'asd', array(1,2)

function prova($ella = __NAMESPACE__, A $peppa)
{

  return $ciao;
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

  // USARE self:: IN UN A FUNZIONE NON HA SENSO MA HO MESSO QUESTE COSE COME PROVA (il corretto utilizzo è quello nel metodo soleggia nella classe Sole)
  self::$a = 1;
  self::$a->b = 1;
  self::$a[1]->b = 1;
  self::$a->b[1] = 1;
  self::$a[1][1]->b = 1;
  self::$a->b[1][1] = 1;
  self::$a[1]->b[1] = 1;

  static::$a = 1;
  static::$a = 1;
  static::$a->b = 1;
  static::$a[1]->b = 1;
  static::$a->b[1] = 1;
  static::$a[1][1]->b = 1;
  static::$a->b[1][1] = 1;
  static::$a[1]->b[1] = 1;

  parent::$a = 1;
  parent::$a = 1;
  parent::$a->b = 1;
  parent::$a[1]->b = 1;
  parent::$a->b[1] = 1;
  parent::$a[1][1]->b = 1;
  parent::$a->b[1][1] = 1;
  parent::$a[1]->b[1] = 1;

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

  return $ciao;

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

  private function ciao(A $a){

  }

  private function hola(){

  }

  public function hi(){

  }
}

function cizza() {

}

