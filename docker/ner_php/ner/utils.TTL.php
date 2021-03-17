<?php

function processTTL($text,&$tokData,&$tokDataComplete){
    $ttl=new TTL();
    $sentences=$ttl->getSentences($text);
    $tokData="";
    $tokDataComplete="";
    foreach(explode("\n",$sentences) as $sent){
        $sent=trim($sent);
        if(strlen($sent)==0)continue;
    
        $tokData.="<s>\t<s>\t<s>\n";
        $tokDataComplete.="<s>\t<s>\t<s>\t<s>\t<s>\n";
    
        $p=$ttl->processPhrase($sent);
        $tok=$ttl->makeArrayAssoc($p);
        foreach($tok as $t){
          	if($t['pos']=='X')continue;
          	$tokData.="${t['word']}\t${t['lemma']}\t${t['ctag']}\n";
          	$tokDataComplete.="${t['word']}\t${t['lemma']}\t${t['pos']}\t".substr($t['pos'],0,2)."\t${t['ctag']}\n";
        }
    
        $tokData.="</s>\t</s>\t</s>\n";
        $tokDataComplete.="</s>\t</s>\t</s>\t</s>\t</s>\n";
    }
}

function processTTL_alreadyTokenized(&$tokData,$tokDataComplete){
    foreach(explode("\n",$tokDataComplete) as $tok){
        $tok=trim($tok);
        if(strlen($tok)==0)continue;
        
        $t=explode("\t",$tok);
        if(count($t)<5)continue;
    
       	$tokData.="${t[0]}\t${t[1]}\t${t[4]}\n";
    }

}

?>