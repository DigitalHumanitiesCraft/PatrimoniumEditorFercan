$(document).ready(function () {
console.log("eeeeezzzze");
var dataTable = $('#peopleList').DataTable({
    dom: "<'row'<'col-sm-2'l><'col-sm-4'><'col-sm-6'f>>" +
             "<'row'<'col-sm-5'i><'col-sm-7'p>>" +
             "<'row'<'col-sm-12'tr>>",
    order: [[ 1, "asc" ]],
    //scrollY:        "600px",
    scrollX:        false,
    scrollCollapse: true,
    responsive: true,
    paging: true,
    pageLength: 200,
    lengthMenu: [[50, 100, 200, -1], [50, 100, 200, "All"]],
    
   columns: [
                    { data: 'id' }, //0
                    { data: 'name'}, //1
                   
                    { data: 'personalStatus' }, //2
                    { data: 'personalStatusUri' },//3
                    
                    { data: 'socialStatus' },// 4 
                    { data: 'socialStatusUri' }, //5
                   
                    { data: 'temporalRangeStart' }, //6
                    { data: 'temporalRangeEnd' }, // 7
                    
                    { data: 'biblio'}//8

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
                               
                               {
                                   targets: [ 3 ],
                                   visible: false
                               },
                             
                               {
                                   targets: [ 5 ],
                                   visible: false,
                                   
                               },
                               
                               {"width": "4em",
                                   targets: [6],
                                   "type": "num-fmt",
                                   visible: true
                               },
                               {
                                   targets: [7],
                                   "type": "num-fmt",
                                   visible: true,
                                   "width": "10em"
                               },
                               {
                                "width": "100em", 
                                targets: [8],
                                "render": function ( data, type, full, meta ) {
                             return $("div").html(data) ;    }
                                
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
    dataTable.draw();
    console.log("Check");
});//End of document ready