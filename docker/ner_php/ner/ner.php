<?php

require "../php_text_lib/lib.php";
require "utils.TTL.php";
require "utils.NER.php";
require "utils.string.php";
require "tag_rules.php";
require "subentity.rule.php";
require "EntityDB.php";
require "log.php";

//echo "<pre>\n";
$rules=[];
loadRules($rules,"rules/1_general_rules.json");
loadRules($rules,"rules/1_TIME_rules.json");
loadRules($rules,"rules/1_ORG_rules.json");
loadRules($rules,"rules/1_PER_rules.json");
loadRules($rules,"rules/1_LOC_rules.json");

$tokData="";
$tokDataComplete="";

if(isset($_REQUEST['text'])){
    $text=$_REQUEST['text'];
    
    $text=str_replace(
      ["„" ,"”" ,'“','ã','Ã','ţ','Ţ','Ş','ş','`',],
      ["\"","\"",'"','ă','Ă','ț','Ț','Ș','ș',' '],
      $text
    );
    
    processTTL($text,$tokData,$tokDataComplete);
}else if(isset($_REQUEST['tokens'])){
    $tokDataComplete=$_REQUEST['tokens'];
    logNer($tokDataComplete);
    processTTL_alreadyTokenized($tokData,$tokDataComplete);
}else die("Invalid call");

$ner=processNER($tokData);
$data=getCompleteData($ner,$tokDataComplete);

prepareRules($rules);
$ret=applyRules($data,$rules);

$rules=[];
loadRules($rules,"rules/2_general_rules.json");
loadRules($rules,"rules/2_TIME_rules.json");
loadRules($rules,"rules/2_ORG_rules.json");
loadRules($rules,"rules/2_PER_rules.json");
loadRules($rules,"rules/2_LOC_rules.json");
if(count($rules)>0){
    for($i=0;$i<2;$i++){
      prepareRules($rules);
      $data=$ret;
      $ret=applyRules($data,$rules);
    }
}

$rules=[];
loadRules($rules,"rules/2_general_rules.json");
if(count($rules)>0){
    prepareRules($rules);
    $data=$ret;
    $ret=applyRules($data,$rules);
}

$rules=[];
loadRules($rules,"rules/3_LOC_rules.json");
loadRules($rules,"rules/3_ORG_rules.json");
loadRules($rules,"rules/3_TIME_rules.json");
loadRules($rules,"rules/3_PER_rules.json");
if(count($rules)>0){
    for($i=0;$i<2;$i++){
      prepareRules($rules);
      $data=$ret;
      $ret=applyRules($data,$rules);
    }
}


$rules=[];
loadRules($rules,"rules/4_general_rules.json");
if(count($rules)>0){
    for($i=0;$i<2;$i++){
      prepareRules($rules);
      $data=$ret;
      $ret=applyRules($data,$rules);
    }
}

$ret=findSubEntities($ret);

$EntityDB=new EntityDB();
$EntityDB->load("db/entities.db.json");
$EntityDB->addEntities($ret);
@mkdir("db");
$EntityDB->save("db/entities.db.json");

if(isset($_REQUEST['text'])){
    echo "WORD\tLEMMA\tMSD\tMSD2\tCTAG\tNER\n";
}

foreach($ret as $str){
    echo "${str['word']}\t${str['lemma']}\t${str['msd']}\t${str['msd2']}\t${str['ctag']}\t${str['ner']}\n";
}
