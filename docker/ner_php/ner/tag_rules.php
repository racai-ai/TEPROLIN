<?php

date_default_timezone_set("Europe/Bucharest");

setlocale(LC_CTYPE,"ro_RO.UTF-8");
mb_internal_encoding("UTF-8");
mb_regex_encoding("UTF-8");


function loadRules(&$ret,$fname_rules){
    if(!is_file($fname_rules))return false;
    $rules=json_decode(file_get_contents($fname_rules),true);
    if($rules===NULL){
        echo "Error reading rules json [${fname_rules}]: \n";
        switch (json_last_error()) {
            case JSON_ERROR_NONE:
                echo ' - No errors';
            break;
            case JSON_ERROR_DEPTH:
                echo ' - Maximum stack depth exceeded';
            break;
            case JSON_ERROR_STATE_MISMATCH:
                echo ' - Underflow or the modes mismatch';
            break;
            case JSON_ERROR_CTRL_CHAR:
                echo ' - Unexpected control character found';
            break;
            case JSON_ERROR_SYNTAX:
                echo ' - Syntax error, malformed JSON';
            break;
            case JSON_ERROR_UTF8:
                echo ' - Malformed UTF-8 characters, possibly incorrectly encoded';
            break;
            default:
                echo ' - Unknown error';
            break;
        }
        echo "\n";
        die();
    }
    
    if(isset($ret['rules'])){
        $ret['rules']=array_merge($ret['rules'],$rules['rules']);
    }else $ret['rules']=$rules['rules'];
    
    return $ret;
}

function isMatchWord($m,$w,$ignoreCase){
    if($m=='*')return true;
    if(strcasecmp($m,"::NUMBER")==0){
        return is_numeric($w);
    }
    
    if(strcasecmp($m,"::LOWERCASE")==0){
        return $w==mb_strtolower($w);
    }

    if(strcasecmp($m,"::DATE")==0){
        $ret=preg_match('/(?:(?:31(\/|-|\.)(?:0?[13578]|1[02]))\1|(?:(?:29|30)(\/|-|\.)(?:0?[1,3-9]|1[0-2])\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:29(\/|-|\.)0?2\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:0?[1-9]|1\d|2[0-8])(\/|-|\.)(?:(?:0?[1-9])|(?:1[0-2]))\4(?:(?:1[6-9]|[2-9]\d)?\d{2})/',$w);
        if($ret==1)return true;
        
        $ret=preg_match("/^(?:2[0-3]|[01][0-9]):[0-5][0-9]$/", $w);
        if($ret==1)return true;
        
        return false;
    }

    if(strncasecmp($m,"::SUFFIX:",9)==0){
        $suff=substr($m,9);
        return endsWith(mb_strtolower($w),mb_strtolower($suff));
    }

    if(strncasecmp($m,"::PREFIX:",9)==0){
        $suff=substr($m,9);
        return startsWith(mb_strtolower($w),mb_strtolower($suff));
    }

    if(strncasecmp($m,"::_:",4)==0){
        return isMatchWord(substr($m,4),$w,$ignoreCase);
    }

    if($ignoreCase)
        return mb_strtolower($m)==mb_strtolower($w);
    //else 
    return $m==$w;
}

function matchPart($match,$c,$ignoreCase){
//$c=mb_strtolower($c);

      if(strpos($c,"_")!==false && !is_array($match) && strncasecmp($match,':',1)!=0 && strncasecmp($match,"!:",2)!=0){
          $cdata=explode("_",$c);
          $is_match=false;
          if($match[0]=='!')
              $is_match=true;
          foreach($cdata as $cd){
              if($match[0]=='!'){
                  $is_match&=matchPart($match,$cd,$ignoreCase);
                  if(!$is_match)break;
              }else{
                  $is_match|=matchPart($match,$cd,$ignoreCase);
                  if($is_match)break;
              }
          }

          return $is_match;      
      }

      $is_match=true;
      
      if(!is_array($match)){
          if($match[0]=='!' && strlen($match)>1){
              $m=substr($match,1);
              $is_match=!isMatchWord($m,$c,$ignoreCase);
              //if(substr($match,1)==$c){$is_match=false;}
          }else $is_match=isMatchWord($match,$c,$ignoreCase);// if($match!='*' && $match!=$c)$is_match=false;
      }else{
          $found=false;
          foreach($match as $w){
              if($w[0]=='!' && strlen($w)>1){
                  $m=substr($w,1);
                  $is_match=!isMatchWord($m,$c,$ignoreCase);
                  if(!$is_match){$found=false;break;}
                  else $found=true;
                  //if(substr($w,1)==$c){$is_match=false;break;}
              }else if(isMatchWord($w,$c,$ignoreCase)){$found=true;break;}    //$w=='*' || $w==$c){$found=true;break;}
          }
          if(!$found)$is_match=false;
      }

      //var_dump($match);var_dump($c);var_dump($is_match);

      return $is_match;
}

function isWPart($match){
      $is_match=true;
      
      if(!is_array($match)){
          if($match!='*' && ($match[0]!='!' && strlen($match)>1))$is_match=false;
      }else{
          $found=false;
          foreach($match as $w){
              if($w=='*' || $w[0]=='!' && strlen($w)>1){$found=true;break;}
          }
          if(!$found)$is_match=false;
      }

      return $is_match;
}

function isMatch($c,$match){
      $is_match=true;
      
      if($is_match && isset($match['ner']))$is_match=matchPart($match['ner'],$c['ner'],false);
      if($is_match && isset($match['word']))$is_match=matchPart($match['word'],$c['word'],true);
      if($is_match && isset($match['lemma']))$is_match=matchPart($match['lemma'],$c['lemma'],true);
      if($is_match && isset($match['msd']))$is_match=matchPart($match['msd'],$c['msd'],false);
      if($is_match && isset($match['msd2']))$is_match=matchPart($match['msd2'],$c['msd2'],false);
      if($is_match && isset($match['ctag']))$is_match=matchPart($match['ctag'],$c['ctag'],false);
      
      if($is_match && isset($match['or'])){
          $is_match=false;
          foreach($match['or'] as $m){
              $is_match=isMatch($c,$m);
              if($is_match)break;
          }
          
      }

      if($is_match && isset($match['and'])){
          $is_match=false;
          foreach($match['and'] as $m){
              $is_match=isMatch($c,$m);
              if(!$is_match)break;
          }
          
      }

      
      return $is_match;
}

function isWildcard($c,$match){
      $isw=true;
      
      if($isw && isset($match['ner']))$isw=isWPart($match['ner']);
      if($isw && isset($match['word']))$isw=isWPart($match['word']);
      if($isw && isset($match['lemma']))$isw=isWPart($match['lemma']);
      if($isw && isset($match['msd']))$isw=isWPart($match['msd']);
      if($isw && isset($match['msd2']))$isw=isWPart($match['msd2']);
      if($isw && isset($match['ctag']))$isw=isWPart($match['ctag']);

      return $isw;
}

function validateMatch($sent,&$rule,$start){

    for($i=count($rule['match'])-1;$i>=0;$i--){
        if($rule['match'][$i]['n_matches']>0){
            if(isset($rule['match'][$i]['final']) && !$rule['match'][$i]['final']){
                $rule['match'][$i]['n_matches']=0;
            }else break;
        }
    }

    return true;
}

function getResType($sent,$rule,$start,$res){
    if(strncasecmp($res['type'],":",1)===0){
        $id=substr($res['type'],1);
        foreach($rule['match'] as $m){
            if(isset($m['id']) && $m['id']==$id){
                return $sent[$start]["ner"];
            }
            $start+=$m['n_matches'];
        }

        return "O";        
    }
    return $res['type'];
}

function displayMatch(&$sent,&$rule,$start){
    if(!validateMatch($sent,$rule,$start))return false;
    //var_dump($rule);
    
    $origstart=$start;
    
    if(isset($rule['debug']) && $rule['debug']){
        var_dump($rule);
        var_dump($sent);
        var_dump($start);
    }
    
    foreach($rule['match'] as $m){
        if(isset($m['id'])){
            foreach($rule['result'] as $res){
                if($m['id']==$res['id']){
                    for($i=$start;$i<$start+$m['n_matches'];$i++){
                        $sent[$i]["ner"]=getResType($sent,$rule,$origstart,$res);
                    }
                }
            }
        }
        $start+=$m['n_matches'];
    }
    
    if(isset($rule['debug']) && $rule['debug']){
        var_dump($sent);
    }

}

function prepareMatch(&$m){
            if(isset($m['word']) && is_string($m['word']) && strpos($m['word'],"|")!==false)
                $m['word']=explode("|",$m['word']);
            if(isset($m['ner']) && is_string($m['ner']) && strpos($m['ner'],"|")!==false)
                $m['ner']=explode("|",$m['ner']);
            if(isset($m['lemma']) && is_string($m['lemma']) && strpos($m['lemma'],"|")!==false)
                $m['lemma']=explode("|",$m['lemma']);
            if(isset($m['msd']) && is_string($m['msd']) && strpos($m['msd'],"|")!==false)
                $m['msd']=explode("|",$m['msd']);
            if(isset($m['msd2']) && is_string($m['msd2']) && strpos($m['msd2'],"|")!==false)
                $m['msd2']=explode("|",$m['msd2']);
            if(isset($m['ctag']) && is_string($m['ctag']) && strpos($m['ctag'],"|")!==false)
                $m['ctag']=explode("|",$m['ctag']);
                
            if(isset($m['or'])){
                foreach($m['or'] as &$m1)
                  prepareMatch($m1);
            }
}

function prepareRules(&$rules){
    // Prepare rules
    foreach($rules['rules'] as &$rule){
        $rule['is_match']=true;
        $rule['current_match']=0;
        $rule['last_match']=0;
        foreach($rule['match'] as &$m){
            $m['n_matches']=0;
            if(!isset($m['min']))$m['min']=1;
            prepareMatch($m);
                
        }
    }
}


function applyRules($data,&$rules){
    $currentSent=[];
    $currentEntType="O";
    $currentEnt="";
    $words=[];
    $ret=[];
                        
    foreach($data as $str){
        $currentSent[]=$str;
        
        if($str["word"]=="</s>"){
            foreach($rules['rules'] as &$rule){
                $rule['is_match']=true;
                $rule['current_match']=0;
                $rule['last_match']=0;
                foreach($rule['match'] as &$m){
                    $m['n_matches']=0;
                    if(!isset($m['min']))$m['min']=1;
                }
            }
            
            $currentSent[]=["word"=>"</s>","lemma"=>"</s>","ner"=>"</s>","msd"=>"</s>","msd2"=>"</s>","ctag"=>"</s>"];
    
            //var_dump($currentSent);
    
            // Try to match in current sentence
            for($i=0;$i<count($currentSent);$i++){
            //if($i>10){var_dump($i);var_dump($rules);var_dump($currentSent);die();}
                foreach($rules['rules'] as &$rule){
                    $rule['is_match']=true;
                    $rule['current_match']=0;
                    if(!isset($rule['last_match']))$rule['last_match']=0;
                    foreach($rule['match'] as &$m){
                        $m['n_matches']=0;
                        if(!isset($m['min']))$m['min']=1;
                    }
                }
                
                //var_dump($i);
                
                for($j=$i;$j<count($currentSent);$j++){
                    foreach($rules['rules'] as &$rule){
                        if(!$rule['is_match'] || $rule['last_match']>$i)continue;
                        
                        $repeat=true;
                        while($repeat && $rule['is_match']){
                            $repeat=false;
                            $match=$rule['match'][$rule['current_match']];
                            
                            $c=$currentSent[$j];
                            
                            $is_match=isMatch($c,$match);
        
        //if($i==10 && isset($rule['debug'])){var_dump($c);var_dump($match);var_dump($is_match);die();}
        
                            if(!$is_match){
                                if($match['min']<=$match['n_matches']){
                                    $rule['current_match']++;
                                    $repeat=true;
                                    if($rule['current_match']>=count($rule['match'])){
                                        //echo "Match\n";
                                        $rule['is_match']=false;
                                        $rule['last_match']=$j;
                                        $repeat=false;
                                        //var_dump($rule);
                                        displayMatch($currentSent,$rule,$i);
                                    }
                                }else $rule['is_match']=false;
                            }else{
                                if(isWildcard($c,$match) && $rule['current_match']<count($rule['match'])-1 && isMatch($c,$rule['match'][$rule['current_match']+1])){
                                    $rule['current_match']++;
                                    $repeat=true;
                                }else if(isset($match['max']) && $match['max']<=$match['n_matches']){
                                    $rule['current_match']++;
                                    $repeat=true;
                                    if($rule['current_match']>=count($rule['match'])){
                                        $rule['last_match']=$j;
                                        $repeat=false;
                                        displayMatch($currentSent,$rule,$i);
                                    }
                                }else{
                                    $rule['match'][$rule['current_match']]['n_matches']++;
                                }
                            }
                         
                           //echo "$i => $j => ${rule['current_match']} R:[$repeat] M:[$is_match]\n";
       
                        }
                        
                    }
                }
            }
    
            unset($currentSent[count($currentSent)-1]);
    
            foreach($currentSent as $s){
                $ret[]=$s;
                //fwrite($fout,"${str['word']}\t${str['lemma']}\t${str['msd']}\t${str['msd2']}\t${str['ctag']}\t${str['ner']}\n");
            }
    
            $currentSent=[];
    
    
        }else{
            //$currentSent[]=$str;
         }            
    
    }

    return $ret;
}


?>