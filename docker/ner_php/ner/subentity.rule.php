<?php


function findSubEntities($data){
    $entities=[];
    $currentEnt="O";
    $currentStart=0;
    $currentData="";
    for($i=0;$i<count($data);$i++){
        $str=$data[$i];
        if($str['ner']!=$currentEnt){
            if($currentEnt!='O'){
                $entities[]=["start"=>$currentStart,"end"=>$i,"ent"=>$currentEnt,"data"=>trim($currentData)];
            }
            $currentEnt=$str['ner'];
            $currentStart=$i;
            $currentData=$str['word'];
        }else if($currentEnt!='O'){
            $currentData.=" ".$str['word'];
        }
    }
    
    for($i=0;$i<count($entities);$i++){
        $ent1=$entities[$i];
        for($j=0;$j<count($entities);$j++){
            $ent2=$entities[$j];
            if($i!=$j && $ent2['ent']=='PER' && $ent1['ent']!='PER' && strpos($ent2['data'],$ent1['data'])!==false){
                $entities[$i]['change']='PER';
            }
        }
    }
    
    $ret=[];
    $cEnt=0;
    for($i=0;$i<count($data);$i++){
        $str=$data[$i];
        if($cEnt<count($entities)){
          if($i>=$entities[$cEnt]['start'] && $i<$entities[$cEnt]['end']){
              if(isset($entities[$cEnt]['change']))$str['ner']=$entities[$cEnt]['change'];
          }else if($i>=$entities[$cEnt]['end'])$cEnt++;
        }
        $ret[]=$str;
    }

    return $ret;
}

?>