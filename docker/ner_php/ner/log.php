<?php


function logNer($msg){
    $path="logs";  @mkdir($path);
    $path.="/".date("Y");  @mkdir($path);
    $path.="/".date("m");  @mkdir($path);
    $path.="/".date("d");
    
    @file_put_contents($path,"*****************\n".date("c")." Message:\n".$msg."\n",FILE_APPEND);

}

?>