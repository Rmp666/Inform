<?php
require '../models/OrderBilletModel.php';

$customer = $_POST['customers'];
unset($_POST['customers']);
$orderItems = $_POST;

$model = new OrderBilletModel;
$result = $model->SetOrderItems((int)$customer, $orderItems);