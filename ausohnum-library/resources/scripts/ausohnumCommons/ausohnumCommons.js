$(document).ready(function() {

   if(document.getElementById("editionDivForLoading")
        && (getDocType()==="epigraphic" || getDocType()==="literary")){
            console.log(getDocType());
            var fullTextPreview = ""; 
            $('.editionTextPart').each(function(index){
                    var no = parseInt(index) + 1;
                    var textPartSubtype ="";
                    var textPartLabel = "";
                    if($(this).attr("subtype")) { textPartSubtype = $(this).attr("subtype")};
                    if($(this).attr("n")){ textPartLabel = $(this).attr("n")};
                    textPartHeader = '<strong class="textPartHeader">' + textPartSubtype.charAt(0).toUpperCase() + textPartSubtype.slice(1) + " " + textPartLabel + "</strong>"
                    convertedText = tei2Html4Preview(this.value);
                    $("#textPreviewHTML-9999").children(".transcriptionPanel").first().append(textPartHeader);
                    $("#textPreviewHTML-9999").children(".transcriptionPanel").first().append(convertedText);
                    });
    };
    
    editor_options ={
    enableBasicAutocompletion: true,
                    enableSnippets: true,
                    enableLiveAutocompletion: true,
    
        //mergeUndoDeltas: "always",
                    //maxLines: Infinity,
                    behavioursEnabled: true, // autopairing of brackets and tags
                    wrapBehavioursEnabled: true,
                    showLineNumbers: true, 
                    wrap: 'free',
                    showPrintMargin: false,
                    printMarginColumn: false,
                    printMargin: false,
                    //fadeFoldWidgets: true,
                    //showFoldWidgets: true,
                    showInvisibles: true,
                    showGutter: true, // hide or show the gutter 
                    displayIndentGuides: false,
                    cursorStyle: "wide",
                    //navigateWithinSoftTabs: false,
                    highlightGutterLine: true,
                    
                    //printMarginColumn: 20,
                    //printMargin: 70,
                    fontSize: 14,
                    fixedWidthGutter: false,
                    //showInvisibles: false,
                    newLineMode: 'auto',
                    maxLines: 300,
                    minLines: 10,
                    //enableBlockSelect: true
                    //printMarginColumn: true,
//                    printMarginColumn: false,
                    readOnly: true,
                    
                    highlightSelectedWord: true
                 
                    
                    //tabSize: 15
                    
};
    if($("#xmlFile").length){
var editor4File = ace.edit("xmlFile");
      editor4File.session.setMode("ace/mode/xml");
      
      editor4File.setOptions({
            maxLines: Infinity,
            readOnly: true,
            behavioursEnabled: true, // autopairing of brackets and tags
                    wrapBehavioursEnabled: true
            });
      }


                                if($('#placesListSimple').length){
                                                var dataTable = $('#placesListSimple').DataTable({
                                                dom: "<'row'<'col-sm-12'f>>" +
                                                         "<'row'<'col-sm-12'tr>>" +
                                                         "<'row'<'col-sm-5'i><'col-sm-7'p>>",
                                                scrollY:        "400",
                                                scrollX:        false,
                                                scrollCollapse: true,
                                                paging: true,
                                                pageLength: 50,
                                                lengthMenu: [[50, 100, 200, -1], [50, 100, 200, "All"]],
                                                order: [[ 1, "asc" ]],
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
                                                                { data: 'productionType' },
                                                                { data: 'exactMatch' }
                                                              ],   
                                                columnDefs: [{
                                                                               "type": "any-number", targets: [0]
                                                                        //       "render": function ( data, type, full, meta ) {{
                                                                        //    return
                                                                        //    '<span class="spanLink" onclick="showPlaceOnMapAndDisplayRecord('+ full.uri +')">' + data + '</span>';
                                                                        //    }}
                                                                               
                                                                           },
                                                                         {
                                                                               //width: 200,
                                                                               targets: [1],
                                                                                    "render": function ( data, type, full, meta ) {
                                                                                    return '<span class="spanLink" onclick="showPlaceOnMapAndDisplayRecord('+ "'" + full.uri + "'" +')">' + data + '</span>'
                                                                                    +'<span class="hidden placeNameWithoutDiacritics">' + removeDiacritics(data) + '</span>';}
                                                                
                                                                           },
                                                                           {
                                                                               targets: [ 2 ],
                                                                               visible:false
                                                                        //   "render": function ( data, type, full, meta ) {{
                                                                        //    return '<span class="spanLink" onclick="showPlaceOnMapAndDisplayRecord('+ full.id +')">' + data + '</span>';    }}
                                                                           },
                                                                           {
                                                                               targets: [ 3 ],
                                                                               visible: false},
                                                                           {
                                                                               targets: [ 4 ],
                                                                               visible: false
                                                                           },
                                                                           {
                                                                               targets: [ 5 ],
                                                                               visible: false
                                                                           },
                                                                           {
                                                                               targets: [ 6 ],
                                                                               visible: false
                                                                               
                                                                           }
                                                                        ],
                         //                       fixedColumns: false,
                                                  language: {
                                                                    search: "",
                                                                    searchPlaceholder: "Filter by name, type, Pleiades or TM no."}
                                                    
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
                 }//En of if for datatable $('#placesList')


}); // End of $(document).ready(function() {

function displaySemanticAnnotations(type, index){
    buttonId = "display" + type + "Button";
    $(document.getElementById(buttonId)).children('i').toggleClass('glyphicon-eye-open');
    $(document.getElementById(buttonId)).children('i').toggleClass('glyphicon-eye-close');
    htmlPreviewId = "textPreviewHTML-" + index;
    classNameCss = "teiPreview" + type;
    classNameType = "." + type;
    annotationTagClass =  ".annotationTag" + type;
    console.log("className = " + classNameCss + "// htmlPreview = " + htmlPreviewId + "; buttonId = " + buttonId + "; AnnoationTagNma = " + annotationTagClass);
    
    $(document.getElementById(htmlPreviewId)).find(classNameType).toggleClass(classNameCss);
    $(document.getElementById(htmlPreviewId)).find(classNameType).children(annotationTagClass).toggleClass('hidden');
    $(document.getElementById(htmlPreviewId)).find(".teiPreviewIcon"+ type).toggleClass('hidden');
    /*if ($(document.getElementById(htmlPreviewId)).find(classNameType).children('teiPreviewIcon').hasClass('hidden') === true) {
                                $(document.getElementById(htmlPreviewId)).find(classNameType).children('teiPreviewIcon').toggleClass("hidden");
                                
                         
                            } else {
                        $(document.getElementById(htmlPreviewId)).find(classNameType).children('teiPreviewIcon').addClass('hidden');                                            
                         };
    */
    

    };



function displayPlaceRecord(id){
                        //$("#loaderBig").removeClass("hidden");
                        //console.log("id: " + id);
                        if($("#placeRecordContainer").length) {
                            $("#placeRecordContainer").removeClass("hidden");
                            };
                        $("#placeRecord").load("/places/get-place-record/" + id,
                            function( ) {
                          
                              $("#loaderBig").hide();
  
});
                        document.title = "Place " + " - " + id;
                        
};

function closePlaceRecord(){    $("#placeRecordContainer").addClass("hidden");};
function closeAtlasSearchPanel(){    $("#atlasSearchPanel").addClass("hidden");};
function getDocType(){return $("#docType").text()}


