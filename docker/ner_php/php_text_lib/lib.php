<?php
session_start();

$LIB_PATH=dirname(__FILE__);
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

date_default_timezone_set("Europe/Bucharest");

setlocale(LC_CTYPE,"ro_RO.UTF-8");
mb_internal_encoding("UTF-8");
mb_regex_encoding("UTF-8");

require_once "${LIB_PATH}/mb_additionals.php";
require_once "${LIB_PATH}/FileDB.php";
require_once "${LIB_PATH}/Cache.php";
require_once "${LIB_PATH}/ttl.php";
require_once "${LIB_PATH}/align_TTL_to_PHS.php";

?>