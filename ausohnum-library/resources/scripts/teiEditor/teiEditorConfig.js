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
                    //readOnly: true,
                    
                    highlightSelectedWord: true
                 
                    
                    //tabSize: 15
                    
};
editor_session_options = {
    
       // indentedSoftWrap: false,  //indent when line is split 
                    firstLineNumber: 1,
                    overwrite: false,
                    //newLineMode: false, 
                    useWorker: true,  //syntax checking
                    useSoftTabs: false,
                    tabSize: 0,
                    wrap: true,
                    wrapMethod: "word"
                    
};

/*CONFIG for pseudo-leiden*/
pseudoLeiden_options ={
    
        //mergeUndoDeltas: "always",
                    //maxLines: Infinity,
                    
                    behavioursEnabled: true, // autopairing of brackets and tags
                    wrapBehavioursEnabled: true,
                    showLineNumbers: true, 
                    wrap: 45,
                    showPrintMargin: false,
                    printMarginColumn: false,
                    printMargin: false,
                    //fadeFoldWidgets: true,
                    //showFoldWidgets: true,
                    showInvisibles: true,
                    showGutter: true, // hide or show the gutter 
                    displayIndentGuides: true,
                    cursorStyle: "wide",
                    //navigateWithinSoftTabs: false,
                    highlightGutterLine: true,
                    
                    //printMarginColumn: 20,
                    //printMargin: 70,
                    fontSize: 14,
                    fixedWidthGutter: true,
                    //showInvisibles: false,
                    newLineMode: 'auto',
                     maxLines: 25,
                    minLines: 10
                    //enableBlockSelect: true
                    //printMarginColumn: true,
//                    printMarginColumn: false,
                    //readOnly: true,
                    
                    
                    
                    //tabSize: 15
    
};


      var editor4File = ace.edit("xml-editor-file");
      editor4File.session.setMode("ace/mode/xml");
      editor4File.setOptions({
            maxLines: Infinity,
            behavioursEnabled: true, // autopairing of brackets and tags
                    wrapBehavioursEnabled: true
            });
      var importEditor = ace.edit("text2importInputEditor").setOptions(editor_options);
      var text2importXMLPreview = ace.edit("text2importXMLPreview").setOptions(editor_options);
           
      
      var xftextarea = $("#ancientText-value");          
      var url = window.location.href;
      /*if( url.includes("sandbox-editor")){
         var resource = "apc-d-1a"}
      else {*/
      var resource = url.substr(url.lastIndexOf('/') + 1)
      
      //};
      
      
$(document).ready(function() {
                  
  ace.require("ace/ext/language_tools");
            
            xml = $("#editionDivForLoading").html();
/*                          console.log("XML: " +JSON.stringify(xml));*/
                                var xmlEditorArray = [];
                                var pseudoLeidenEditorArray = [];
                                var fullTextPreview = ""; 
                                var textPreviewHTMLArray =  $('.textPreviewHTML');
/*                                var xmlText = new XMLSerializer().serializeToString(xml);*/
/*                                console.log("xml: " + xml);*/
/*                                console.log("xmlText: " + xmlText);*/
/*                                $("#textPreviewHTML-9999").html(tei2Html4Preview(xmlText));*/
                                        /*console.log("IN AJAX *Loading text************************"
                                         + "\n" +  xmlText);*/
                                $(xml).find('div').each(function(index){
                                        var no = parseInt(index) + 1;
                                        var textPartSubtype ="";
                                        var textPartLabel = "";
                                        if($(this).attr("subtype")) { textPartSubtype = $(this).attr("subtype")};
                                        if($(this).attr("n")){ textPartLabel = $(this).attr("n")};
                                        var textPartHeader = '<strong class="textPartHeader">' + textPartSubtype.charAt(0).toUpperCase() + textPartSubtype.slice(1)
                                        + " " + textPartLabel + "</strong>" 
                                        //+ "<br/>"                                  
    /*                                    XML Editor*/
                                        var xmlEditorName = "xml-editor-" + no ;
                                        xmlEditorArray[index] = ace.edit(xmlEditorName);
                                        xmlEditorArray[index].setOptions(editor_options);  
                                        
                                        
                                        //xmlEditorArray[index].setShowPrintMargin(false);
                                        xmlEditorArray[index].getSession().setOptions(editor_session_options);
                                        xmlEditorArray[index].setTheme("ace/theme/cobalt");
                                        xmlEditorArray[index].getSession().setMode("ace/mode/xml");
                                        xmlEditorArray[index].setAutoScrollEditorIntoView(true);
                                        xmlEditorArray[index].getSession().setUseWorker(true);
                                        
                                        
    /*                                    Pseudo-Leiden+ Editor*/
                                        var pseudoLeidenEditorName = "pseudoLeiden-editor-" + no ;
                                        /*pseudoLeidenEditorArray[index] = ace.edit(pseudoLeidenEditorName);
                                        pseudoLeidenEditorArray[index].setOptions(editor_options);  
                                        pseudoLeidenEditorArray[index].setShowPrintMargin(false);
                                        pseudoLeidenEditorArray[index].getSession().setOptions(editor_session_options);
                                        pseudoLeidenEditorArray[index].setTheme("ace/theme/twilight");
                                        pseudoLeidenEditorArray[index].getSession().setMode("ace/mode/html");
                                        */
                                        
                                        var textPreviewHTMLName = "textPreviewHTML-" + no ;
                                        //textPreviewHTMLArray[index] = ace.edit(textPreviewHTMLName);
                                        //textPreviewHTMLArray[index].getSession().setMode("ace/mode/html");
                                        
/*                                        var xmlText = new XMLSerializer().serializeToString(this);*/
                                                    /*console.log("Text in laoding************************"
                                                    + "\n" +  xmlText.substring(41, xmlText.length-5)
                                                    );*/
                                        
                                         //editorArray[index].setValue(xmlText, -1);
                                         xmlText = xmlEditorArray[index].getValue();
                                         $(textPreviewHTMLArray[index]).html(tei2Html4Preview(xmlText));
                                         fullTextPreview = fullTextPreview  + textPartHeader 
                                              + '<div class="textPartDiv">'
                                              + tei2Html4Preview(xmlText)
                                              +'</div>'
                                         //+ "<br/>";
                                         
    /*                                         Before change for taking textpart subtype and number*/
                                            /*fullTextPreview = fullTextPreview  +  tei2Html4Preview(xmlText);*/


                                         //xmlEditorArray[index].setValue($.trim(xmlText.substring(41, xmlText.length-5)), -1);
                                        //pseudoLeidenEditorArray[index].setValue(tei2leiden(xmlEditorArray[index].getValue()), -1);
                                       
                                       
                                       
/*                                        xmlEditorArray[index].blur();*/
                                        
                                        
                                    //var node = $.parseXML(this);
                                    window.scrollTo(0,0);
                                     
                                     
  
                                     
                                     
                                    });

                                     $("#textPreviewHTML-9999").html(fullTextPreview);
                           
            
  
     window.addEventListener("keydown", function(e) { 
           /*if (e.keyCode===8) {
                e.preventDefault();
                console.log("Backspace");}*/ 
            }, true)  
        }
        );
 
 
 