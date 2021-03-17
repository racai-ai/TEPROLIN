<?php

class EntityDB {

  public $data;
  public $knownEntities;
  public $links;
  public $thresh;

  public function __contruct($thresh){
      $this->data=[];
      $this->knownEntities=[];
      $this->links=[];
      $this->thresh=$thresh;
  }
  
  public function load($fname){
      $this->data=[];
      $this->knownEntities=[];
      $this->links=[];
      if(is_file($fname)){
          $this->data=json_decode(file_get_contents($fname),true);
          if(isset($this->data['entities'])){
            foreach($this->data['entities'] as $ent){
                $this->knownEntities[$ent['entity']]=$ent;
            }
          }

          if(isset($this->data['links'])){
            foreach($this->data['links'] as $lnk){
                $this->links[$lnk['sub']]=$lnk;
            }
          }          
      }
  }
  
  public function save($fname){
      $this->data=[
          "entities"=>array_values($this->knownEntities),
          "links"=>array_values($this->links)
      ];
      @file_put_contents($fname,json_encode($this->data));
  }
  
  public function getEntitiesFromTokens($sent){
      $entities=[];
      $currentEnt="O";
      $currentStart=0;
      $currentData="";
      for($i=0;$i<count($sent);$i++){
          $str=$sent[$i];
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
      
      return $entities; 
  }

  public function processSent($sent){
      $entities=$this->getEntitiesFromTokens($sent);
            
      foreach($entities as $ent){
          if(!isset($this->knownEntities[$ent['data']])){
              $this->knownEntities[$ent['data']]=["entity"=>$ent['data'], "len"=>$ent['end']-$ent['start'],"toks"=>[]];
              for($i=$ent['start'];$i<$ent['end'];$i++)$this->knownEntities[$ent['data']]['toks'][]=$sent[$i];              
          }
          if(!isset($this->knownEntities[$ent['data']][$ent['ent']]))
              $this->knownEntities[$ent['data']][$ent['ent']]=0;
          $this->knownEntities[$ent['data']][$ent['ent']]++;
      }     
  }

  public function addEntities($tokens){
      $sent=[];
      foreach($tokens as $tok){
          $sent[]=$tok;
          if($tok['word']=='</s>'){
            $this->processSent($sent);
            $sent=[];          
          }
      }
  }
  
  // Entitate catalogata gresit
  public function correctWrongEntity(&$tokens,&$entities,$classes){
      foreach($entities as &$ent){
          if(isset($this->knownEntities[$ent['data']])){
              $d=$this->knownEntities[$ent['data']];
              foreach($classes as $c){
                  if(isset($d[$c])){
                      if((!isset($d[$ent['ent']]) || $d[$c]>=$d[$ent['ent']]+$this->thresh) && $d[$c]>$this->thresh){
                          // corectare
                          for($i=$ent['start']; $i<$ent['end'];$i++)
                              $tokens[$i]['ner']=$c;
                          $ent['ent']=$c;
                      }
                  }
              }
          }
      }
      
  }
  
  public function correctSubEntity(&$tokens, &$entities, $classes){
      // Sub-entitate
      foreach($entities as &$ent){
          $len=$ent['end']-$ent['start'];
          foreach($this->knownEntities as $e=>$d){
              if(count($d['toks'])>$len){
                  $j=0;
                  $numFound=0;
                  for($i=$ent['start'];$i<$ent['end'];$i++){
                      for(;$j<count($d['toks']);$j++)
                          if(strcasecmp($tokens[$i]['word'],$d['toks'][$j]['word'])==0){
                              $numFound++;
                              break;
                          }
                  }
                  
                  if($numFound==$len){
                      $this->links[$ent['data']]=["sub"=>$ent['data'],"ent"=>$e];
                      
                      foreach($classes as $c){
                          if(isset($d[$c])){
                              if((!isset($d[$ent['ent']]) || $d[$c]>=$d[$ent['ent']]+$this->thresh) && $d[$c]>$this->thresh){
                                  // corectare
                                  for($i=$ent['start']; $i<$ent['end'];$i++)
                                      $tokens[$i]['ner']=$c;
                                  $ent['ent']=$c;
                              }
                          }
                      }
                  
                      break;
                  }
              
              }
          }
      }
  
  }
  
  public function correctBigEntity(&$tokens, &$entities, $classes){
      // Entitate mare formata din mai multe entitati
      foreach($entities as &$ent){
          $len=$ent['end']-$ent['start'];
          
          $matches=[];
          
          foreach($this->knownEntities as $e=>$d){
              if(count($d['toks'])<$len){
                  $j=0;
                  $numFound=0;
                  for($i=$ent['start'];$i<$ent['end'];$i++){
                      $found=true;
                      for($j=0;$j<count($d['toks']);$j++)
                          if(strcasecmp($tokens[$i+$j]['word'],$d['toks'][$j]['word'])!=0){
                              $found=false;
                              break;
                          }
                      if($found){
                          $entType=false; $entCount=0;
                          foreach($classes as $c)
                              if(isset($d[$c]) && $d[$c]>$entCount){$entType=$c;$entCount=$d[$c];}
                          $matches[]=["start"=>$i,"end"=>$i+count($d['toks']),"data"=>$e,"ent"=>$entType];
                      }
                  }
              }
          }
          
          $solutions=[];
          $current=[];
          $pos=0;
          while($pos>=0){         
              if(!isset($current[$pos]))$current[$pos]=0;
              else{
                  $current[$pos]++;
                  if($current[$pos]>=count($matches)){unset($current[$pos]);$pos--;continue;}
              }
              
              // is valid ?
              $valid=true;
              for($i=0;$i<$pos && $valid;$i++){
                  for($j=$i+1;$j<$pos;$j++){
                      if($current[$i]==$current[$j]){$valid=false;break;}
                      $m1_start=$match[$current[$i]]['start'];
                      $m1_end=$match[$current[$i]]['end'];
                      $m1_ent=$match[$current[$i]]['ent'];
                      
                      $m2_start=$match[$current[$j]]['start'];
                      $m2_end=$match[$current[$j]]['end'];
                      $m2_ent=$match[$current[$j]]['ent'];

                      if($m1_start<=$m2_start && $m2_start<$m1_end || $m2_start<=$m1_start && $m1_start<$m2_end){
                          $valid=false;break;
                      }
                      
                      if(($m1_start == $m2_end || $m2_start==$m1_end) && $m1_ent==$m2_ent){
                          $valid=false;break;
                      }                      
                  }
              }
              
              if(!$valid)continue;
              
              // is solution ?
              $solution=true;
              for($i=$ent['start'];$i<$ent['start']+$len && $solution;$i++){
                  $found=false;
                  for($j=0;$j<$pos && !$found;$j++){
                      $m_start=$match[$current[$j]]['start'];
                      $m_end=$match[$current[$j]]['end'];

                      if($m_start<=$i && $i<$m_end)$found=true;                  
                  }
                  
                  if(!$found){
                      $w=mb_strtolower($tokens[$i]['word']);
                      $allowed=array_flip([',','.',';','și','sau','al']);
                      if(!isset($allowed[$w]))$solution=false;
                  }
              }
              
              if($solution)$solutions[]=$current;              
              
          }
          
          //if(count($solutions)>0){
              
              echo "********************\n";
              echo "Solutions for entity: [".$ent['data']."]\n";
              var_dump($matches);
              var_dump($solutions);
              
              foreach($solutions as $sol){
                  foreach($sol as $s){
                      echo $matches[$s]["data"]."/".$matches[$s]["ent"]." ";
                  }
                  echo "\n";
              }
          //}          
                  
      }
  }
  
  public function correctEntities(&$tokens){
      $entities=$this->getEntitiesFromTokens($tokens);
      $classes=['PER','ORG','TIME','LOC','O'];
      
      $this->correctWrongEntity($tokens,$entities,$classes);
      $this->correctSubEntity($tokens,$entities,$classes);
      $this->correctBigEntity($tokens,$entities,$classes);
      
      return $tokens;
      
      
  }

}
