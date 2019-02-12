<?php
require_once '../config.php';
class PdoConnect 
{
    private static $link= null;
    
    const connect = DB_1['driver'].':host='.DB_1['host'].'; dbname='.DB_1['db'].'; charset='.DB_1['charset'];
    
    const options = 
    [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ];
    
    public static function getConnection()
    {
        if (self::$link === null) 
        {
            try 
            {
                self::$link = new PDO(self::connect, DB_1['user'], DB_1['password'], self::options);
            }catch (PDOException $e) 
            {
                throw new Exception('Ошибка соединения с базой данных '.$e->getMessage());
            }
        }
        return self::$link;
    }
            
    private function __construct() {}
    private function __clone() {}
}
?>