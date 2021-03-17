<?php

function processNER($tokData){
    $url="http://127.0.0.1:8011/ner";
    
    $curl = curl_init();
    
    //$url_data = http_build_query($data);
    
    $boundary = uniqid();
    $delimiter = '-------------' . $boundary;
    $eol = "\r\n";
    $data="";
    $data .= "--" . $delimiter . $eol
                . 'Content-Disposition: form-data; name="text"'.$eol.$eol
                . $tokData . $eol;
    $data .= "--" . $delimiter . "--".$eol;

    curl_setopt_array($curl, array(
        CURLOPT_URL => $url,
        CURLOPT_RETURNTRANSFER => 1,
        CURLOPT_MAXREDIRS => 10,
        CURLOPT_TIMEOUT => 30,
        //CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
        CURLOPT_CUSTOMREQUEST => "POST",
        CURLOPT_POST => 1,
        CURLOPT_POSTFIELDS => $data,
        CURLOPT_HTTPHEADER => array(
          //"Authorization: Bearer $TOKEN",
          "Content-Type: multipart/form-data; boundary=" . $delimiter,
          "Content-Length: " . strlen($data)
      
        ),
    ));

    $response = curl_exec($curl);
    curl_close($curl);
    return $response;
}

function getCompleteData($ner,$tokDataComplete){
    $rArr=explode("\n",$ner);
    $tokArr=explode("\n",$tokDataComplete);
    $data=[];
    for($i=0;$i<min(count($rArr),count($tokArr));$i++){
    
        $t=explode("\t",$tokArr[$i]);
        $r=explode("\t",$rArr[$i]);
    
        if(count($r)!=3){continue;}
    
        $data[]=[
            "word"=>$t[0],
            "lemma"=>$t[1],
            "msd"=>$t[2],
            "msd2"=>$t[3],
            "ctag"=>$t[4],
            "ner"=>$r[2]
        ];
    
        /*$t[]=$r[2];
        $disp=implode("\t",$t);
        //$disp=str_replace("null","",$disp);
        $disp=htmlspecialchars($disp);
        echo $disp."\n";*/
    }
    
    return $data;
}


?>