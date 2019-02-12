<?php
require '../models/OrderBilletModel.php';

$model = new OrderBilletModel;
$steels = $model->GetSteels();
$customers = $model->GetCustomers();
$referenceRaw = $model->GetReference();

$reference=[];

foreach ($referenceRaw as $row => $constraint)
{
    
    if(!key_exists($constraint['code_type'], $reference))
    {
        $reference[$constraint['code_type']] = 
        [
            'name_type' => $constraint['name_type'],
            'id_type' => $constraint['id_type'],
            'constraint' => []
        ];
    }
    
    $reference[$constraint['code_type']]['constraint'][$constraint['code_constr']] = 
    [
        'id_constr' => $constraint['id_constr'],
        'name_constr' => $constraint['name_constr'],
        'min' => $constraint['min_constr'],
        'max' => $constraint['max_constr']
    ];  
}

echo json_encode(['reference' => $reference, 'steels' => $steels, 'customers' => $customers]); 
?>