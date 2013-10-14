<?php

namespace foo;
use My\Full\Classname as Another;

// this is the same as use My\Full\NSname as NSname
use My\Full\NSname;

// importing a global class
use ArrayObject;

$obj = new namespace\Another; // instantiates object of class foo\Another
$obj = new Another; // instantiates object of class My\Full\Classname
function func()
{

}
NSname\subns\func(); // calls function My\Full\NSname\subns\func
$a = new ArrayObject(array(1)); // instantiates object of class ArrayObject
// without the "use ArrayObject" we would instantiate an object of class foo\ArrayObject

namespace Ciao;

use als;

$a = "ciao" + "1.2";
$a = 'ciao1' + 1;
// $a = 'ciao1' + array(1);
// $a = 1 + array(1);
// $a = "1" + array(1);

interface Pape
{
	public function leggi();
}

class asd extends Pippo\Asd {

}

class topo
{

}

class FrontController extends topo implements Pape
{
	public function leggi ()
	{
		echo 'ciao';
	}
}

$a = new Pluto();
$b = new topo();
var_dump(get_class($a), get_class($b));
