$(document).ready( function () {
                       document.title = "APC - Documents";
                       
                        var dataTable = $('#documentsList').DataTable({
                        dom: "<'row'<'col-sm-2'l><'col-sm-4'><'col-sm-6'f>>" +
                                                         "<'row'<'col-sm-5'i><'col-sm-7'p>>" +
                                                         "<'row'<'col-sm-12'tr>>" +
                                                         "<'row'<'col-sm-5'i><'col-sm-7'p>>",
                        //scrollY:        "600px",
                        scrollX:        false,
                        scrollCollapse: true,
                        paging: true,
                        pageLength: 50,
                        lengthMenu: [[25, 50, 100, 200, -1], [25, 50, 100, 200, "All"]],
                        ajax: {
                               url: "/documents/list/json"
                               , dataSrc: "data"
                           },
                       columns: [
                                        { data: 'id' },
                                        { data: 'title'},
                                        { data: 'provenance' },
                                          { data: 'area' },
                                          { data: 'datingNotBefore' },
                                          { data: 'datingNotAfter' },
                                          { data: 'tmNo' },
                                          { data: 'edition' },
                                          { data: 'otherId' }
 
                                      ],   
                        columnDefs: [{
                                                       "type": "any-number", targets: [0]
                                                       
                                                   },
                                                 {
                                                       width: 400, targets: [1]
                                                       
                                                   },  
                                                   
                                                   {
                                                       "type": "any-number", targets: [4]
                                                       
                                                   },
                                                   {
                                                       "type": "any-number", targets: [5]
                                                       
                                                   },
                                                   {
                                                       targets: [ 6 ],
                                                       visible: false
                                                   },
                                                   {
                                                       targets: [7],
                                                       width: 10
                                                   },
                                                   {
                                                       targets: [8],
                                                       visible: false
                                                   },
                                                ],
                        fixedColumns: true,
                          language: {
                                            search: "",
                                            searchPlaceholder: "Search by title, TM no., EDCS no., or other identifiers..."
                                                },
                            
                                        });
                                        
                        
                        
                            $('.filter').click(
                                    function(){
                                            var regex ="";
                                            $(this).toggleClass("btn-primary");
                                            $(this).toggleClass("btn-default");
                                            
                                            $(".filter").each(function(){
                                            if( $(this).hasClass("btn-primary")){
                                            regex = regex + "|" + $(this).val()}
                                            regex = regex.replace(/^\|/g, "");
                                            console.log(regex);
                                            dataTable.columns(3).search(regex, true, false, true).draw();                            
                                            
                                    });
                                });                                        
                    
                  
                                         
                        
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
    
    
                                        
                                    } );
                                    
                                   



//* Custom filtering function which will search data in 2 columns between two values */
$.fn.dataTable.ext.search.push(
    function( settings, data, dataIndex ) {
        var min = parseInt( $('#min').val(), 10 );
        var max = parseInt( $('#max').val(), 10 );
        var notBefore = parseFloat( data[4] ) || 0;
        var notAfter = parseFloat( data[5] ) || 0; 
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
