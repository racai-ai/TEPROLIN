<?php

class FileDB {
	public $db = null; 

	public function __construct($db_path) {
		$this -> db = $db_path; 
	}

	public static function isValidKey($key) {
		if (strlen($key) === 0)return false; 
		if (preg_match("/[,;<>?\\/'\"\\\\|{}[\]()*&^%\$#@!\\+=~`]/",$key)===1)return false;
		return true;
	}

    public function getBasePath($key){
		return $this->db."/".mb_substr($key,0,1)."/".mb_substr($key,0,2);
    }
    
    public function getPath($key){
		return $this->getBasePath($key)."/".$key;
    }
    
    public function getCount($key){
		$path=$this->getPath($key);
    
        $fname_count="$path.count";
		if(!is_file($fname_count))return null;
	
		$max_count=intval(file_get_contents($fname_count));
		return $max_count;
    }
    
    public function getEntries($key,$start,$count){
		if(!self::isValidKey($key))return null;
    
		$max_count=$this->getCount($key);
		if($max_count===null || $start>=$max_count)return null;

		$path=$this->getPath($key);
	
		$last=min($start+$count,$max_count);
		$ret=array();
		$current=array();
		while($start<$last){
			$fname_data="$path.".intval($start/1000).".php";
			if(!is_file($fname_data))break;
			eval("\$data = array(".file_get_contents($fname_data)."); ");
			$s=$start % 1000;
			$ret=array_merge($ret,array_slice($data,$s,min(count($data)-$s,$last-$start)));
			$start+=1000-$s;
		}
		return array("total_count"=>$max_count,"data"=>$ret);
    }
    
    public function add($key,$value){
		$path=$this->getBasePath($key);
		@mkdir($path,0777,true);
		$count=$this->getCount($key);
		if($count===null){
			$count=1;
		}else $count++;
		$fname_count="$path/$key.count";
		file_put_contents($fname_count,"$count");
		
		$fcount=intval($count/1000);
		$fname_out="$path/$key.$fcount.php";
		file_put_contents($fname_out,"$value,\n",FILE_APPEND);
	}
	
	public function set($key,$value){
		$path=$this->getBasePath($key);
		@mkdir($path,0777,true);
		$fname_out="$path/$key";
		file_put_contents($fname_out,$value);
		return true;
	}

	public function get($key){
		$path=$this->getBasePath($key);
		$fname_out="$path/$key";
		if(is_file($fname_out))return file_get_contents($fname_out);
		return false;
	}
}
