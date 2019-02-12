<?php
require '../models/OrderBilletModel.php';

$model = new OrderBilletModel;
$steels = $model->GetInvoice();
?>


