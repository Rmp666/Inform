<?php
require "PdoConnect.php";

class OrderBilletModel 
{
    protected $pdo;
    
    function __construct()
    {  
        $this->pdo = PdoConnect::getConnection();
    }
    
    public function GetReference()
    {
        $query = $this->pdo->prepare("SELECT * FROM prod_constraint_v");
        $query->execute();
        $data = array();
        while ($row = $query->fetch()) {
            $data[] = $row;
        }
        return $data;
    }
    
    public function GetSteels()
    {
        $query = $this->pdo->prepare("SELECT mark_steel FROM steels");
        $query->execute();
        $data = $query->fetchAll(PDO::FETCH_COLUMN);
        return $data;
    }
    
    public function GetCustomers()
    {
        $query = $this->pdo->prepare("SELECT cust_name, cust_id FROM customers");
        $query->execute();
        $data = array();
        while ($row = $query->fetch()) {
            $data[] = $row;
        }
        return $data;
    }
    
    public function SetOrderItems($customer, $orderItems)
    {
        try 
        {  
            // Добавление данных о заказе
            $this->pdo->beginTransaction();
            $query = $this->pdo->prepare("INSERT INTO  orders(cust_id) VALUES(:cust_id)");
            $query->bindParam("cust_id", $customer);
            $query->execute();
            $id_order = $this->pdo->lastInsertId();
            
            // Упорядочиваем номера позиций в заказе
            $items = array_values($orderItems['item']);
            foreach ($items as $item => $value)
            {
                // Добавление данных для каждой позиции в заказе и расчет веса в calc_total_weight
                $query = $this->pdo->prepare("INSERT INTO  order_items(num_items, num_ord, type_prod, mark_steel, width_d, height, length) VALUES(:num_items, :num_ord,  :type_prod, :mark_steel, :width_d, :height, :length)");
                $query->bindParam("num_items", ++$item);
                $query->bindParam("num_ord", $id_order);
                $query->bindParam("type_prod", $value['type_prod']);
                $query->bindParam("mark_steel", $value['mark']);
                $query->bindParam("width_d", $value['D']);
                $h = $value['H']?? NULL;
                $query->bindParam(":height", $h);
                $query->bindParam("length", $value['L']);
                $query->execute();
                
                $query = $this->pdo->prepare("SELECT calc_total_weight(:num_items, :num_prod) result");
                $query->bindParam("num_items", $item);
                $query->bindParam("num_prod", $id_order);
                $query->execute();
                $result = $query->fetch();
                
                if ($result['result'] != '') 
                {
                    $this->pdo->rollBack();
                    echo json_encode(['error'=>"Ошибка: В позиции {$item} некорректные размеры: ".$result['result']]);
                    exit();
                } 
            }
            $this->pdo->commit(); 
            echo json_encode(['result' => 'Ваш заказ принят']);
            exit();
            
        } catch (Exception $e) 
        {
            $this->pdo->rollBack();
            echo "Ошибка: " . $e->getMessage();
        }        
    }
    
    public function GetInvoice()
    {
        
        $query = $this->pdo->prepare("SELECT max(num_ord) id FROM orders");
        $query->execute();
        $lastId = $query->fetch();
        $query = $this->pdo->prepare
        (
            "SELECT o.num_ord, p.name_type, i.mark_steel, i.width_d, i.height, i.length, i.total_weight, c.cust_name FROM order_items i
            JOIN orders o ON(o.num_ord = i.num_ord)
            JOIN customers c  ON(c.cust_id = o.cust_id)
            JOIN prod_type p ON (p.code_type = i.type_prod)
            WHERE i.num_ord = {$lastId['id']}"
        );
            
        $query->execute();   
        $data = array();
        while ($row = $query->fetch()) {
            $data[] = $row;
        }
        echo json_encode($data);
        exit();
    }
    
}
