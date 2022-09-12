$(document).ready( function () {
                                                document.title = "APC - Places";                                                                                                
                                                var dataTable = $('#placesList').DataTable({
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
                                                       url: "/places/list/json/public"
                                                       , dataSrc: "data"
                                                   },
                                               columns: [
                                                                { data: 'id' },
                                                                { data: 'name'},
                                                                { data: 'uri' },
                                                                { data: 'geoCoord' },
                                                                { data: 'type' },
                                                                //{ data: 'productionType' },
                                                                { data: 'productionTypeLink' },
                                                                { data: 'provinceName' },
                                                                { data: 'provinceUri' },
                                                                { data: 'exactMatch' },
                                                                { data: 'altNames'}
                                                                
                                                              ],   
                                                columnDefs: [{
                                                                               "type": "any-number", targets: [0],
                                                                               "render": function ( data, type, full, meta ) {
                                                                            return '<span class="spanLink" onclick="openPlaceRecord('+ full.id +')">' + data + '</span>';    }
                                                                               
                                                                           },
                                                                         {
                                                                               width: 300, targets: [1],
                                                                               "render": function ( data, type, full, meta ) {
                                                                            return '<span class="spanLink" onclick="openPlaceRecord('+ full.id +')">' + data + '</span>';    }
                                                                               
                                                                           },
                                                                           {
                                                                               targets: [ 2 ],
                                                                           visible: false
                                                                           },
                                                                           {
                                                                               targets: [ 3 ],
                                                                               visible: false},
                                                                           {
                                                                               targets: [ 4 ]
                                                                                //,
                                                                                //"render": function ( data, type, full, meta ) {
                                                                                //return '<span class="spanLink" onclick="displayPlaceRecord('+ full.id +')">' + data + '</span>';    }
                                                                           },
                                                                           {
                                                                               targets: [ 5 ]
                                                                               //,
                                                                                //"render": function ( data, type, full, meta ) {
                                                                                //return '<span class="spanLink" onclick="displayPlaceRecord('+ full.id +')">' + data + '</span>';    }
                                                                           },
                                                                           {
                                                                               targets: [ 6 ],
                                                                               //visible: true
                                                                               
                                                                               "render": function ( data, type, full, meta ) {
                                                                               return '<a href="'+ full.provinceUri + '" title="Open record in a new window" target="_blank">' 
                                                                               + data + '</a>';    },
                                                                               },
                                                                               {
                                                                               targets: [ 7 ],
                                                                               visible: false
                                                                           }
                                                                        ],
                                                fixedColumns: true,
                                                  language: {
                                                                    search: "",
                                                                    searchPlaceholder: "Filter by name, type, production..."
                                                                        },
                                                    
                                                                });
                                                                
                                                 dataTable.on( 'select', function ( e, dt, type, indexes ) {
                                                                console.log(type);
                                                                if ( type === 'row' ) {
                                                                $("#loaderBig").removeClass("hidden");
                                                                    var uri = table.rows( indexes ).data().pluck( 'uri' );
                                                                    var id = table.rows( indexes ).data().pluck( 'id' );
                                                                      console.log(id);
                                                                     $("#placeRecord").load("/place/get-place-record/" + id);
                                                                    
                                                                    document.title = "Place " + " - " + id;  
                                                                $("#loaderBig").addClass("hidden");    
                                                                }
                                                            } );           
                                                          
                                                          } ); //End of document.ready
                                                            
                                                            
                                                            function openPlaceRecord(id){
                                                                    var url = "/places/" + id;
                                                                    window.open(url, "_blank");
                                                                    console.log(url);
                                                                    //$("#loaderBig").removeClass("hidden");
                                                                    //$("#placeRecord").load("/places/get-place-record/" + id);
                                                                    //document.title = "Place " + " - " + id;
                                                                    //$("#loaderBig").addClass("hidden");
                                                                    };
                                                                    