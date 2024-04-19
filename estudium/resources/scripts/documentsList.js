$(document).ready( function () {
                    $("#btn-regenerate").click(function(ev) {
                            ev.preventDefault();
                            regenerate();
                        });
                        
                        document.title = "APC - Documents";
                       
        var dataTable = $('#documentsList').DataTable({
                        dom: 
                        //"<'row'<'col-sm-12'B>>" +
                        //+
                        "<'row'<'col-sm-2'l><'col-sm-4'B><'col-sm-6'f>>" +
                                                         "<'row'<'col-sm-5'i><'col-sm-7'p>>" +
                                                         "<'row'<'col-sm-12'tr>>" +
                                                         "<'row'<'col-sm-5'i><'col-sm-7'p>>",
                        //scrollY:        "600px",
                        
        buttons: [
            {
                extend: 'csv',
                className: 'exportButton',
                text: '<i class="glyphicon glyphicon-export"/> csv'
                },
                {
                extend: 'excel',
                className: 'exportButton',
                text: '<i class="glyphicon glyphicon-export"/> excel'
                },
                {
                extend: 'copy',
                className: 'exportButton',
                text: '<i class="glyphicon glyphicon-copy"/> copy'
                },
            //, 'excel', 'pdf', 'print'
        ],
                        
                        scrollX:        false,
                        scrollCollapse: true,
                        responsive: true,
                        paging: true,
                        pageLength: 50,
                        lengthMenu: [[25, 50, 100, 200, -1], [25, 50, 100, 200, "All"]],
                        ajax: {
                               url: "/documents/list/json"
                               , dataSrc: "data"
                           },
                       columns: [
                                        { data: 'id' },     //0
                                        { data: 'title'},   //1
                                        { data: 'uri'},
                                        { data: 'provenance' },     //2
                                        { data: 'provenanceUri'},
                                        { data: 'provenanceCoordinates'},
                                          { data: 'provinceName' },    //3
                                          { data: 'provinceUri' },
                                          { data: 'datingNotBefore' },   //4
                                          { data: 'datingNotAfter' },    //5
                                          { data: 'tmNo' },   // 6
                                          { data: 'edition' },    //7
                                          { data: 'otherId' },    //8
                                          { data: 'keywords' },
                                          { data: 'provenanceAltNames' }  
 
                                      ],   
                        columnDefs: [{
                                                       "type": "any-number",
                                                       targets: 0,
                                                       width: 5,
                                                       "render": function ( data, type, full, meta ) {
                                                                            return '<a href="'+ full.uri +'" target="_blank" title="Open document ' + full.id+ '"  class="tableLink" >' + data + '</span>';    }
                                                       
                                                   },
                                                 {
                                                       
                                                       targets: 1,
                                                       width: 150,
                                                       "render": function ( data, type, full, meta ) {
                                                                            return '<a href="'+ full.uri +'" target="_blank" title="Open document ' + full.id + '"  class="tableLink" >' + data + '</span>';    }
                                                       
                                                   },
                                                   {
                                                       targets:  2,
                                                       visible: false
                                                   },  
                                                   {
                                                       targets: 3,
                                                       width: 20,
                                                       "render": function ( data, type, full, meta ) {
                                                                    var link;
                                                                    if(data != null){link = ' <a href="'+ full.provenanceUri +'" target="_blank" title="Open place ' + full.provenanceUri + '"  class="tableLink" >' + data + '</span>'
                                                                    +'<span class="hidden placeNameWithoutDiacritics">' + removeDiacritics(data) + '</span>';    }
                                                                
                                                                    else{link = " "}
                                                                    return link    }
                                                       
                                                   },
                                                   {
                                                       targets: 4,
                                                       visible: false
                                                   },
                                                   {
                                                       targets: 5,
                                                       visible: false
                                                   },
                                                   {
                                                       targets: 6, width: 20,
                                                       "render": function ( data, type, full, meta ) {
                                                            var link;
                                                       if(data != null) {
                                                                           link = ' <a href="'+ full.provinceUri +'" target="_blank" title="Open place ' + full.provinceUri + '"  class="tableLink">' + data + '</span>';
                                                                            } else{  
                                                                            link = " "}
                                                                            return link}
                                                   },
                                                   {
                                                       targets: 7,
                                                       visible: false
                                                   },
                                                   {
                                                       "type": "num-fmt"
                                                       ,
                                                       className: 'dt-body-right', targets: 8, width: 5,
                                                       
                                                   },
                                                   {
                                                       "type": "num-fmt", className: 'dt-body-left', targets: 9, width: 5,
                                                       
                                                   },
                                                  {
                                                       targets: 10,
                                                       visible: false
                                                   },
                                                   {
                                                       targets: 11,
                                                       width: 10
                                                   },
                                                   {
                                                       targets: 12,
                                                       visible: false
                                                   },
                                                   {
                                                       targets: 13,
                                                       visible: true, 
                                                       width: 30
                                                    },
                                                    {
                                                        targets: 14,
                                                        visible: false
                                                     }
                                                ],
                        fixedColumns: {
            leftColumns: 14
        },
                        //autoWidth: true,
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
                                            //console.log(regex);
                                            dataTable.columns(6).search(regex, true, false, true).draw();                            
                                            
                                    });
                                });                                        
                        $('#resetFilters').click(
                                    function(){
                                            
                                            $(".filter").each(function(){
                                            if( $(this).hasClass("btn-primary")){
                                                $(this).toggleClass("btn-primary");
                                                $(this).toggleClass("btn-default");
                                                }
                                                
                                                dataTable.columns(6).search("", true, false, true).draw();                            
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
        var maxMin = -50;
        var maxMax = 500;
        var min = parseInt( $('#min').val(), 10 );
        var max = parseInt( $('#max').val(), 10 );
/*        console.log(min + " " + max)*/
     //if((min = maxMin) && (max = maxMax)) {}
     //else
     //{   
        var notBefore = parseFloat( data[8] ) || 0;
        var notAfter = parseFloat( data[9] ) || 0; 
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
    //}
    }
);

function regenerate() {
console.log("Starting regenerating list");
    $("#messages").empty();
    $("#btn-regenerate").attr("disabled", true);
    $("#f-load-indicator").removeClass('hidden');
    $("#messages").text("The list of documents is being regenerated. Page will be reloaded once this process is finished...");
    $.ajax({
        type: "POST",
        dataType: "json",
        url: "/documents/update-list/",
        success: function (data) {
        console.log(data);
            $("#f-load-indicator").addClass("hidden");
            
            $("#btn-regenerate").attr("disabled", false);
            if (data.status == "failed") {
                $("#messages").text(data.message);
            } else {
                window.location.href = ".";
            }
        }
    });
}