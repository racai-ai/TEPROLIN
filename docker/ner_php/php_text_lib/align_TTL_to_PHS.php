<?php

function align_TTL_to_PHS($ttl,$phs){
	$ret=[];
	$pos=0;
	for($i=0;$i<count($ttl);$i++){
		$w=mb_strtolower($ttl[$i]);
	
		if($pos<count($phs) && $w===$phs[$pos]){
			$ret[$i]=$pos;
			$pos++;
		}else	if($pos<count($phs)-1 && $w===$phs[$pos+1]){
			$ret[$i]=$pos+1;
			$pos+=2;
		}else{
			$w1=trim($w,"-+.,<>?/;:'\"\\|[]{}=)(*&^%\$#@!`~");
			if($pos<count($phs) && strlen($w1)>0 && strpos($phs[$pos],$w1)>=0){
				$ret[$i]=$pos;
			}else{
				 $ret[$i]=-1;
			}
		}
	}
	return $ret;
}
