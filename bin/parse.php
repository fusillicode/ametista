<?php

include_once dirname(dirname(__FILE__)).'/lib/parser.php';

$parser = new Parser();

$parser->parse('./test_simple_file');

?>
