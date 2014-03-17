<?php

include_once dirname(dirname(__FILE__)).'/lib/populator.php';

$populator = new Populator();

$populator->populate('./test_codebase');

?>
