    $(document).ready(function () {
        form.bind();
        form.get();
    });

    var form = (function() {

        
        var constraints = {};
        var item = 1; // Номер позиции в заказе
        var itemClone = {};

        // Привязка событий
        function  bind() 
        {
            $('body').on('click', 'button[link="delete"]', deleteItem);
            $('#save-order').on('click', validate);
            $('body').on('change', 'select[link="change"]', inputTagReference);
            $('#add-item').on('click', addClone);
        } 

        // Получаем данные для формирования формы
        function getOrderBillet() {
            $.ajax({
                url:'../controllers/GetOrderBillet.php',
                type:'GET',
                cache:false,
                data:{},
                dataType:'html',
                success: function(data) {
                    var data = JSON.parse(data)
                    console.log(data);
                    for (var i = 0; i <  data.customers.length; i++) 
                    {
                        $('#customers').append($('<option>', {text:data.customers[i].cust_name, value:data.customers[i].cust_id}));
                    }

                    for (var type in data.reference)
                    {
                        $('#type_prod').attr({name:'item['+item+'][type_prod]', 'data-item':item});
                        $('#type_prod').append($('<option>', {text:data.reference[type].name_type, value:type}));
                    }

                    for (var i = 0; i <  data.steels.length; i++) 
                    {
                        $('#steels').attr({name:'item['+item+'][mark]', 'data-item':item});
                        $('#steels').append($('<option>', {text:data.steels[i]}));
                    }

                    // Клонируем часть сформированной формы
                    itemClone = $("#row-item-1").clone();

                    // Данные необходимые для отрисовки iputs и их валидации
                    constraints = data.reference;

                    // Отрисовываем inputs для ввода размеров
                    $('select[link="change"]').trigger('change');                
                },
                error: function(err) {

                }
           });
        }

        // Вводимые размеры
        function inputTagReference (e)
        {
            // Чистим div с размерами и hr
            var thisItem = $(e.currentTarget).data('item');
            $('#constraint'+thisItem).remove();
            $('#HR'+thisItem).remove();

            var selectedType= $(e.currentTarget).val(); // square or round

            var rowForTypeConstr = $('<div>', {class:'input-group', id:'constraint'+thisItem});
            var row = $('<div>', {class:'row mt-3'});
            var deleteItem = $('#row-item-'+thisItem).find('.delete'); // кнопка delete, относящаяся к item

            for (var type in constraints[selectedType].constraint)
            {
                var label = $('<label>', {class:'control-label col-form-label mr-1', text:constraints[selectedType].constraint[type].name_constr+':'});
                var divInput = $('<input>', {type:'text', class:'form-control maxWidth mr-2', link:"validateText", 'data-min':constraints[selectedType].constraint[type].min, 'data-max':constraints[selectedType].constraint[type].max, name:'item['+thisItem+']['+type+']'});

                row.append(label, divInput);
                rowForTypeConstr.append(row);
                rowForTypeConstr.insertBefore(deleteItem);
            }
        }

        function addClone () 
        {
            ++item;
            var localClone = itemClone.clone();
            // Меняем id клона на ++item
            localClone.attr('id', 'row-item-'+item);
            // Меняем у всех элементов клона name на ++item
            var forChangeName = localClone.find('[name *= "item[1]"]');
            forChangeName.each(function() 
            {
                $(this).data('item', item);
                var newAttr = $(this).attr('name');
                newAttr = newAttr.replace('1', item);
                $(this).attr('name', newAttr);
            });
            // Вставляем перед кнопкой сохранить и добавляем input с размерами
            localClone.insertBefore($('#save-order'));
            $('[name="item['+item+'][type_prod]"]').trigger('change'); 

        }

        function deleteItem (e) 
        {
            $(this).parent().parent().remove();
        }

        // Считываем данные из data-max и data-min, записанные при формировании input в inputTagReference
        function  validate() 
        {
            var errors = false;
            var inputs = $('body').find('[link="validateText"]');
            inputs.each(function()
            {
                var max = $(this).data('max');
                var min = $(this).data('min');
                var value = $(this).val();
                if (+value<min || +value>max)
                {
                    errors = true;
                    $(this).focus().attr('title', 'Значение должно находиться в промежутке от '+min+' до '+max); 
                }
            });

            if (!errors) saveOrderBillet();
        }

        function saveOrderBillet() 
        {

            $.ajax({
                type: 'POST',
                url: "../controllers/SaveOrderBillet.php",
                data: $('form').serializeArray(),
                success: function(message){
                    var message = JSON.parse(message);
                    if(message['result'] !== undefined)
                    {
                        alert(message['result']);
                        window.location.replace('http://'+DIR+'/views/InvoiceOrderBillet.php');
                    }else 
                    {
                        alert(message['error']);
                    }
                },
                error: function(){}
            });
        }

        return{
            bind: bind,
            get:  getOrderBillet
        }
    })();

