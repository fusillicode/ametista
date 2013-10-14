<?php

namespace Ciao;

$a = "ciao" + "1.2";
$a = 'ciao1' + 1;
// $a = 'ciao1' + array(1);
// $a = 1 + array(1);
// $a = "1" + array(1);

interface Pape
{
	public function leggi();
}

class topo
{

}

class Pluto extends topo implements Pape
{
	public function leggi ()
	{
		echo 'ciao';
	}
}


$a = new Pluto();
$b = new topo();
var_dump(get_class($a), get_class($b));
