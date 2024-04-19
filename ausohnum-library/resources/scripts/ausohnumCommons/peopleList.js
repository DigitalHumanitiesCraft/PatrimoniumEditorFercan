$(document).ready( function () {
                                                
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
                                                paging: true,
                                                pageLength: 200,
                                                lengthMenu: [[50, 100, 200, -1], [50, 100, 200, "All"]],
                                                ajax: {
                                                       url: "/people/list/json"
                                                       , dataSrc: "data"
                                                   },
                                               columns: [
                                                                { data: 'id' },
                                                                { data: 'name'},
                                                                { data: 'sex' },
                                                                { data: 'personalStatus' },
                                                                { data: 'citizenship' },
                                                                { data: 'socialStatus' },
                                                                { data: 'functions' },
                                                                { data: 'temporalRangeStart' },
                                                                { data: 'temporalRangeEnd' },
                                                                { data: 'exactMatch' }
                         
                                                              ],   
                                                columnDefs: [{
                                                                               "type": "any-number", targets: [0],
                                                                               "render": function ( data, type, full, meta ) {
                                                                            return '<span class="spanLink" onclick="displayPersonRecord('+ full.id +')">' + data + '</span>';    }
                                                                               
                                                                           },
                                                                         {
                                                                               width: 200, targets: [1],
                                                                               "render": function ( data, type, full, meta ) {
                                                                            return '<span class="spanLink" onclick="displayPersonRecord('+ full.id +')">' + data + '</span>';    }
                                                                               
                                                                           },
                                                                           {
                                                                               targets: [ 2 ]
                                                                           },
                                                                           {
                                                                               targets: [ 3 ]
                                                                           },
                                                                           {
                                                                               targets: [ 4 ]
                                                                           },
                                                                           {
                                                                               targets: [ 5 ]
                                                                           },
                                                                           {
                                                                               targets: [ 6 ],
                                                                               visible: true,
                                                                               
                                                                           },
                                                                           {
                                                                               targets: [7],
                                                                               "type": "any-number",
                                                                               visible: true
                                                                           },
                                                                           {
                                                                               targets: [8],
                                                                               "type": "any-number",
                                                                               visible: true
                                                                           },
                                                                           {
                                                                               targets: [9],
                                                                               visible: true
                                                                           },
                                                                        ],
                         //                       fixedColumns: false,
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
        var notBefore = parseFloat( data[7] ) || 0;
        var notAfter = parseFloat( data[8] ) || 0; 
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
