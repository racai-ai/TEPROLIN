<?php

class Cache {
    public $db=null;

    public function __construct($db){
        $this->db=$db;
    }

    public function getKeyHash($key,$context=null){
        $k=hash('sha512',$key);
        if($context!==null)$k.="_$context";
        return $k;
    }

    public function get($key,$context=null){
        return $this->db->get($this->getKeyHash($key,$context));
    }

    public function set($key,$value,$context=null){
        return $this->db->set($this->getKeyHash($key,$context),$value);
    }
}