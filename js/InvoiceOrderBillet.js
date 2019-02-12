    $(document).ready(function () {
        getInvoiceOrderBillet(); 
    });
    
    function getInvoiceOrderBillet() 
    {
        $.ajax({
            type: 'POST',
            url: "../controllers/GetInvoiceOrderBillet.php",
            success: function(details){
                var details = JSON.parse(details);
                console.log(details);
                var tHead =  "<thead><tr><th>"+details[0].cust_name+"</th></tr><tr><th>Номер заказа</th><th>Позиция</th>";
                tHead += "<th>Вид изделия</th><th>Размеры</th><th>Вес, кг</th></tr></thead>";
                $('#table').append(tHead);
                
                for (var i = 0; i < details.length; i++)
                {
                    var position = i + 1;
                    var size = ((details[i].height === null)? details[i].length+"x"+details[i].width_d : details[i].length+"x"+details[i].width_d+"x"+details[i].height);
                    var contentTable =  "<tr><td>"+details[i].num_ord+"</td><td>"+position+"</td><td>"+details[i].name_type+"</td>";
                    contentTable += "<td>"+size+"</td><td>"+details[i].total_weight+"</td></tr>";
                    $('#table').append(contentTable);
                }
            },
            error: function(){

            }
        });
    }