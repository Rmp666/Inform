<?php
include_once '../config.php';
include_once '../layout/header.php';
include_once  '../layout/footer.php';
?>
<div class="col-md-12 mt-3">
    <form>
        <div class="form-group row ml-2">
            <div class="input-group">
                <div  class="row">
                    <label class="control-label col-form-label">Заказчик:</label>
                    <select class="form-control" id="customers" name="customers"></select>
                </div>
            </div>
        </div>
        <hr class="hrAttr">
        <div class="form-group row ml-2" id="row-item-1">
            <div class="input-group">
                <div class = "row">
                    <label class="control-label col-form-label">Вид:</label>
                    <select class="form-control" link="change"  id="type_prod"></select>
                    <label class="control-label col-form-label">Марка:</label>
                    <select class="form-control" id="steels"></select>
                </div>
            </div>
            <div class="input-group mt-3 delete">
                <button class="btn btn-danger" link="delete" onclick="return false;">Удалить</button>
            </div>
            <hr class="hrAttr">
        </div>

        <button class="btn btn-success" id="save-order" onclick="return false;">Cохранить</button>
        <button class="btn btn-warning" id="add-item" onclick="return false;">Добавить позицию</button>
    </form>
</div>
<script>var DIR = "<?php echo APP;?>";</script>
<script src="../js/OrderBillet.js"> </script>
