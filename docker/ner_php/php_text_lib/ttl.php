<?php

class TTL {
	var $client = null; 
	var $msd_ctag = null; 
	public $cache=null;

	public function  __construct($cache=null) {
		global $LIB_PATH;
		$this -> client = new SoapClient(
			$LIB_PATH."/ttlws.wsdl", 
			array(
				'location' => "http://ws.racai.ro:8080/pdk/ttlws",
				'encoding' => 'utf-8', 
				'trace' => true
			)
		); 
		$this->cache=$cache;
	}

	public function getSentences($text) {
		if($this->cache!==null){
			$c=$this->cache->get($text,"getSentences");
			if($c!==false)return $c;
		}
		$sgml = $this -> client -> __soapCall("UTF8toSGML", array($text)); 
		$sent = $this -> client -> __soapCall("SentenceSplitter", array("ro", $sgml)); 
		$ret = $this -> client -> __soapCall("SGMLtoUTF8", array($sent)); 
		$ret = str_replace("\r", "", $ret); 
		$ret = mb_ereg_replace("<entity[^>]+>([^<]+)</entity>", "\\1", $ret); 
		if($this->cache!==null){
			$this->cache->set($text,$ret,"getSentences");
		}
		return $ret; 
	}


	public function getTokens($text) {
		if($this->cache!==null){
			$c=$this->cache->get($text,"getTokens");
			if($c!==false)return $c;
		}
		$sgml = $this -> client -> __soapCall("UTF8toSGML", array($text)); 
		$sent = $this -> client -> __soapCall("Tokenizer", array("ro", $sgml)); 
		$ret = $this -> client -> __soapCall("SGMLtoUTF8", array($sent)); 
		$ret = str_replace("\r", "", $ret); 
		if($this->cache!==null){
			$this->cache->set($text,$ret,"getTokens");
		}
		return $ret; 
	}

	public function processPhrase($phrase) {
		if($this->cache!==null){
			$c=$this->cache->get($phrase,"processPhrase");
			if($c!==false)return $c;
		}
		$sgml = $this -> client -> __soapCall("UTF8toSGML", array($phrase)); 
		$tok = $this -> client -> __soapCall("Tokenizer", array("ro", $sgml)); 
		$tag = $this -> client -> __soapCall("Tagger", array("ro", $tok)); 
		$lem = $this -> client -> __soapCall("Lemmatizer", array("ro", $tag)); 
		$ret = $this -> client -> __soapCall("SGMLtoUTF8", array($lem)); 
		$ret = str_replace("\r", "", $ret); 
		if($this->cache!==null){
			$this->cache->set($phrase,$ret,"processPhrase");
		}
		return $ret; 
	}

	public function processTokens($tokArr) {
		$tokString = implode("\r\n", $tokArr); 
		if($this->cache!==null){
			$c=$this->cache->get($tokString,"processTokens");
			if($c!==false)return $c;
		}
		$tok = $this -> client -> __soapCall("UTF8toSGML", array($tokString)); 
		$tag = $this -> client -> __soapCall("Tagger", array("ro", $tok)); 
		$lem = $this -> client -> __soapCall("Lemmatizer", array("ro", $tag)); 
		$ret = $this -> client -> __soapCall("SGMLtoUTF8", array($lem)); 
		$ret = str_replace("\r", "", $ret); 
		if($this->cache!==null){
			$this->cache->set($tokString,$ret,"processTokens");
		}
		return $ret; 
	}

	public function makeArray($data) {
		$ret = str_replace("\r", "", $data); 
		$arr = explode("\n", $ret); 
		$ret_arr = array(); 
		foreach ($arr as $line) {
			$current = explode("\t", $line); 

			// eliminare (0.43)lemma sau (wf)lemma
			$pos = strpos($current[2], ")"); 
			if (strpos($current[2], "(") === 0 && $pos !== false) {
			$current[2] = substr($current[2], $pos + 1); 
			}

			// daca se returneaza o lista de taguri
			$pos = strpos($current[1], ","); 
			if ($pos !== false)$current[1] = substr($current[1], 0, $pos); 

			$ret_arr[] = $current; 
		}
		return $ret_arr; 
	}

	public function loadMSDtoCTAG(){
		global $LIB_PATH;
		foreach(explode("\n",file_get_contents($LIB_PATH."/msdtag.ro.map")) as $line){
			$line=trim($line);
			$d=explode("\t",$line);
			if(count($d)!==2)continue;
			$this->msd_ctag[$d[0]]=$d[1];
		}
	}

	public function makeArrayAssoc($data){
		if($this->msd_ctag===null)$this->loadMSDtoCTAG();

		$arr=$this->makeArray($data);
		$ret=array();
		foreach($arr as $td){
			$current=array();
			$current['word']=$td[0];
			$current['pos']=$td[1];
			if(!isset($this->msd_ctag[$td[1]]))$ctag=$td[1];
			else $ctag=$this->msd_ctag[$td[1]];
			$current['ctag']=$ctag;
			$current['lemma']=$td[2];

			/*if(strpos($td[0],"_")>0){
				$expr=explode("_",$td[0]);
				$wordsClean[count($wordsClean)-1]=$expr[0];
				for($i=1;$i<count($expr);$i++){
					$wordsClean[]=$expr[$i];
					$lemma[]=$lemma[count($lemma)-1];
					$pos[]=$pos[count($pos)-1];
					$ctag[]=$ctag[count($ctag)-1];
				}
			}*/

			$ret[]=$current;
		}

		return $ret;
	
	}

}