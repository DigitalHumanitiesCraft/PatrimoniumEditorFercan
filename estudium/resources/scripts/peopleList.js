$(document).ready( function () {
                        $("#btn-regenerate").click(function(ev) {
                            ev.preventDefault();
                            regenerate();
                        });                                                
                                                document.title = "APC - People";
                                                
                                                var dataTable = $('#peopleList').DataTable({
                                                dom: "<'row'<'col-sm-2'l><'col-sm-4'><'col-sm-6'f>>" +
                                                         "<'row'<'col-sm-5'i><'col-sm-7'p>>" +
                                                         "<'row'<'col-sm-12'tr>>" +
                                                         "<'row'<'col-sm-5'i><'col-sm-7'p>>",
                                                order: [[ 1, "asc" ]],
                                                //scrollY:        "600px",
                                                scrollX:        false,
                                                scrollCollapse: true,
                                                responsive: true,
                                                paging: true,
                                                pageLength: 200,
                                                lengthMenu: [[50, 100, 200, -1], [50, 100, 200, "All"]],
                                                ajax: {
                                                       url: "/people/list/json"
                                                       , dataSrc: "data"
                                                   },
                                               columns: [
                                                                { data: 'id' }, //0
                                                                { data: 'name'}, //1
                                                                { data: 'sex' }, //2
                                                                { data: 'personalStatus' }, //3
                                                                { data: 'personalStatusUri' },
                                                                { data: 'citizenship' },// 4 == 5
                                                                { data: 'citizenshipUri' },
                                                                { data: 'socialStatus' },// 5 == 7
                                                                { data: 'socialStatusUri' }, 
                                                                { data: 'functions' }, //6 == 8
                                                                { data: 'temporalRangeStart' }, //7 == 9
                                                                { data: 'temporalRangeEnd' }, // 9 == 10
                                                                { data: 'exactMatch' }, // 10 == 12
                                                                { data: 'biblio'}
                         
                                                              ],   
                                                columnDefs: [{
                                                                               "type": "any-number", targets: [0],
                                                                               "width": "5em",
                                                                               "render": function ( data, type, full, meta ) {
                                                                            return '<span class="spanLink" onclick="displayPersonRecord('+ full.id +')">' + data + '</span>';    }
                                                                               
                                                                           },
                                                                         {
                                                                               "width": "100em", 
                                                                               targets: [1],
                                                                               "render": function ( data, type, full, meta ) {
                                                                            return '<span class="spanLink" onclick="displayPersonRecord('+ full.id +')">' + data + '</span>';    }
                                                                               
                                                                           },
                                                                           {
                                                                           "width": "3em",
                                                                               targets: [ 2 ]
                                                                           },
                                                                           {"width": "10em",
                                                                               targets: [ 3 ]
                                                                            //"render": function ( data, type, full, meta ) {
                                                                           // return ' <a href="'+ full.personalStatusUri +'" target="_blank" title="Open concept ' + full.personalStatusUri + '"  class="tableLink">' + data + '</span>';    }
                                                                           },
                                                                           {
                                                                               targets: [ 4 ],
                                                                               visible: false
                                                                           },
                                                                           {"width": "10em",
                                                                               targets: [ 5 ]
                                                                                //"render": function ( data, type, full, meta ) {
                                                                                //    return ' <a href="'+ full.citizenshipUri +'" target="_blank" title="Open concept ' + full.citizenshipUri + '"  class="tableLink">' + data + '</span>';    }
                                                                           },
                                                                           {
                                                                               targets: [ 6 ],
                                                                               visible: false,
                                                                               
                                                                           },
                                                                           { "width": "10em",
                                                                           targets: [ 7 ]
                                                                           //"render": function ( data, type, full, meta ) {
                                                                           //         return ' <a href="'+ full.socialStatusUri +'" target="_blank" title="Open concept ' + full.socialStatusUri + '"  class="tableLink">' + data + '</span>';    }
                                                                           },
                                                                           {
                                                                               targets: [ 8 ],
                                                                               visible: false,
                                                                               
                                                                           },
                                                                           {
                                                                           "width": "4em",
                                                                               targets: [9],
                                                                               "type": "any-number",
                                                                               visible: true
                                                                           },
                                                                           {"width": "4em",
                                                                               targets: [10],
                                                                               "type": "num-fmt",
                                                                               visible: true
                                                                           },
                                                                           {
                                                                               targets: [11],
                                                                               "type": "num-fmt",
                                                                               visible: true,
                                                                               "width": "10em"
                                                                           },
                                                                        ],
                                                fixedColumns: true,
                                                //autoWidth: false,
                                                  language: {
                                                                    search: "",
                                                                    searchPlaceholder: "Filter by name, status, function, TM no."
                                                                        },
                                                    
                                                                });
                                                                
                                                 dataTable.on( 'select', function ( e, dt, type, indexes ) {
                                                                console.log(type);
                                                                if ( type === 'row' ) {
                                                                    var uri = table.rows( indexes ).data().pluck( 'uri' );
                                                                    var id = table.rows( indexes ).data().pluck( 'id' );
                                                                      console.log(id);
                                                                     $("#personRecord").load("/people/get-person-record/" + id);
                                                                    history.pushState(null, null,  "/people/" + id);
                                                                    document.title = "People " + " - " + id;  
                                                                    
                                                                }
                                                            } );           
                                                            
                                                            $( "#slider-range" ).slider({
                                range: true,
                                min: -50,
                                max: 500,
                                values: [ -50, 500 ],
                                slide: function( event, ui ) {
                                  //console.log("date: " + $( "#amount" ).val( "$" + ui.values[ 0 ] + " - $" + ui.values[ 1 ] ));
                                  var notBefore = ui.values[ 0 ];
                                  var notAfter = ui.values[ 1 ];
                                  //console.log("notBefore= " + notBefore + " NotAfter= " + notAfter);
                                  $('#min').val(notBefore);
                                  $('#max').val(notAfter)
                                  
                                  
                                  
                                  dataTable.draw();
                                }
                              });
                                                            
                                                            } ); //End of document.ready
                                                            
                                                            
                                                            function displayPersonRecord(id){
                                                                    var url = "/people/" + id;
                                                                    window.open(url, "_blank");
                                                                    //console.log("here!!");
                                                                    //$("#personRecord").html();
                                                                    //$("#loaderBig").show();
                                                                    //$("#personRecord").load("/people/get-person-record/" + id, function(){
                                                                    //$("#loaderBig").hide();
                                                                    //});
                                                                    //history.pushState(null, null,  "/people/" + id);
                                                                    //document.title = "People " + " - " + id;
                                                                    
                                                                    };
                                                                    

                                            





//* Custom filtering function which will search data in 2 columns between two values */
$.fn.dataTable.ext.search.push(
    function( settings, data, dataIndex ) {
        var min = parseInt( $('#min').val(), 10 );
        var max = parseInt( $('#max').val(), 10 );
        var notBefore = parseFloat( data[9] ) || 0;
        var notAfter = parseFloat( data[10] ) || 0; 
     /*       console.log(notBefore);
            console.log("( isNaN( min ) && isNaN( max )  ==> " + ( isNaN( min ) && isNaN( max )));
            console.log("( isNaN( min ) && notBefore <= max ) ==> " +( isNaN( min ) && notBefore <= max ));
            console.log("( min => notBefore   && isNaN( max ) ) ==> " + ( min => notBefore   && isNaN( max ) ));*/
        if ( ( isNaN( min ) && isNaN( max ) ) ||
             ( isNaN( min ) && notAfter <= max ) ||
             ( min <= notBefore   && isNaN( max ) ) 
             ||
             ( min <= notBefore && notAfter <= max ) 
             )
        {
            return true;
        }
        
        return false;
    }
);
function regenerate() {
console.log("Start regenerating list");
    $("#messages").empty();
    $("#btn-regenerate").attr("disabled", true);
    $("#f-load-indicator").removeClass('hidden');
    $("#messages").text("The list of documents is being regenerated. Page will be reloaded once this process is finished...");
    $.ajax({
        type: "POST",
        dataType: "json",
        url: "/people/update-list/",
        success: function (data) {
        console.log(data);
            $("#f-load-indicator").addClass("hidden");
            $("#messages").text("Please wait while page is reloading");
            $("#btn-regenerate").attr("disabled", false);
            if (data.status == "failed") {
                $("#messages").text(data.message);
            } else {
                window.location.href = ".";
            }
        }
    });
}
function reindexDatesAndBiblio() {
console.log("Start regenerating list");
    $("#messages").empty();
    $("#btn-regenerate").attr("disabled", true);
    $("#f-load-indicator").removeClass('hidden');
    $("#messages").text("Dating and Edition data is being updated in People's records");
    $.ajax({
        type: "POST",
        dataType: "json",
        url: "/people/update-list/",
        success: function (data) {
        console.log(data);
            $("#f-load-indicator").addClass("hidden");
            $("#messages").text("Dating and Edition data updated. Please consider regenerating list");
            $("#btn-regenerate").attr("disabled", false);
            if (data.status == "failed") {
                $("#messages").text(data.message);
            } else {
                window.location.href = ".";
            }
        }
    });
}