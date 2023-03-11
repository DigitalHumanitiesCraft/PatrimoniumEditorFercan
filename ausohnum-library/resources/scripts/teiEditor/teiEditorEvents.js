function getCurrentDocId(){        return $('#currentDocId').html() };
function getCurrentProject(){        return $('#currentProject').html() };

/*Subforms in dialogs are submitted through submitHandler*/



/*$.validator.setDefaults( {
			submitHandler: function () {
/\*			    var test = form.find('id').val();*\/

				console.log("submitted!" );
			}
		} );
*/

/*document.getElementById("addBiblioForm").addEventListener("submit", function(event){
  event.preventDefault()
});*/
$(".addBiblioForm").click(function(event){
  event.preventDefault();
});


function openDialog(dialogId){
    dialogId = "#" + dialogId;
    $(dialogId).modal('show');
  };
  
function closeDialog(dialogId){
    dialogId = "#" + dialogId;
    $(dialogId).modal('hide');
    $(".modal-backdrop").hide();
    $('body').removeClass('modal-open');
  };  

function openTextImporter(index){
        $("#currentEditorIndexVariable").val(index);
        $('#dialogTextTmport').modal('show');
        
        var xmlEditorArray = [];
        var xmlEditorName = "xml-editor-" + index ;
        xmlEditorArray[index] = ace.edit(xmlEditorName);
        var xmlEditorSession = xmlEditorArray[index].getSession();
        var selectedText = "";
        selectedText = xmlEditorArray[index].getSelectedText();
        var editorContent = xmlEditorArray[index].getValue();
        console.log("editorContent: " +editorContent);
        
        ace.edit('text2importInputEditor').session.setValue(selectedText);
        
        if(editorContent ===""){$("#textImportMode").val("newText");}
                        else {$("#textImportMode").val("insertion");};
        
/*        xmlEditorArray[currentEditorIndex].session.setValue(text2import);*/
};

function getSelectedText(){
/*    console.log(window.getSelection());*/
};



        if (!window.x) {x = {};        }
        x.Selector = {};
        x.Selector.getSelected = function() {
                var t = '';
                if (window.getSelection) {
                    t = window.getSelection();
                    /*console.log("w: "
                    + $(t).parent().parent().text());*/
                } else if (document.getSelection) {
                    t = document.getSelection();
            /*        console.log("t: " + $(t).get());*/
                } else if (document.selection) {
                    t = document.selection.createRange().text;
                }
                return t;
            }
!

function toggleFullScreenEditionPane(index){
    var divId = "#editionPane-" + index;
    $(divId).toggleClass("fullscreen");
/*    console.log("fullscreen on " + divId);*/
};

function importText(index){
/*console.log("Here I am");*/
            var xmlEditorArray = [];
            var currentEditorIndex = $("#currentEditorIndexVariable").val();
            console.log("currentEditorIndex: " + currentEditorIndex);
               /*var xmlEditorName = "xml-editor-" + $('input[name="editorIndex"]').val();*/
               var xmlEditorName = "xml-editor-" + currentEditorIndex;
               xmlEditorArray[currentEditorIndex] = ace.edit(xmlEditorName);
               xmlPreviewEditor = ace.edit("text2importXMLPreview");
               var text2import = xmlPreviewEditor.getValue();
               //console.log("Editor: " + xmlEditorName);
              ace.edit("text2importInputEditor").session.setValue("");
              
              $('#dialogTextTmport').modal('hide');
              //console.log("text qui va être inséré = " + text2import);
              
              
/*              xmlEditorArray[currentEditorIndex].session.setValue(text2import);*/



/*xmlEditorArray[index] = ace.edit(xmlEditorName);*/
    var xmlEditorSession = xmlEditorArray[currentEditorIndex].getSession();

xmlEditorSession.replace(xmlEditorArray[currentEditorIndex].selection.getRange(), text2import);
};

function editValue(teiElementNickname, index, cardinality){
/*          teiElementNickname --> used as prefix of input name
 *          index -->   index no of corresponding TEI div/@type='textpart'; default = 1
 *          cardinality  --> used when a cardinality of field is > 1
 * */

        if(cardinality != null) {var card = "_" + cardinality} else{var card =""};
        console.log("card : " + card);
        console.log("Input Element Value: " + "#" +teiElementNickname+"_display_"+ index + card);
        console.log("Input Element Input: " + "#" +teiElementNickname+"_edit_" + index + card);
        var idElementValue= "#" +teiElementNickname+"_display_"+ index + card;
        var idElementInput= "#" +teiElementNickname+"_edit_" + index + card;
        /*console.log("idElementValue= " + idElementValue);
        console.log("idElementInput= " + idElementInput);*/
        $(idElementValue).toggleClass("teiElementHidden");
        $(idElementInput).toggleClass("teiElementHidden");

};


function cancelEdit(teiElementNickname, index, originalValue, type, cardinality){
        console.log("Cancel edit")
        if(index == null) { ind =""} else {var ind = index}
        if(cardinality != null) {var card = "_" + cardinality} else{var card =""};
        var idElementDisplay= "#" +teiElementNickname+"_display_"+ ind + card;
        var idElementEdit= "#" +teiElementNickname+"_edit_" + ind + card;
        var elementInput= $("#" + teiElementNickname + "_" + ind + card);
        /*console.log("idElementValue= " + idElementValue);
        console.log("idElementInput= " + idElementInput);*/
        console.log ("idElementDisplay: " + idElementDisplay);
        $(idElementDisplay).toggleClass("teiElementHidden");
        $(idElementEdit).toggleClass("teiElementHidden");
        if(type=='input'){
        elementInput.val(originalValue);
        elementInput.html(originalValue);
        }

};

function cancelAddItem(element){
        
        if($(element).parents().closest('.teiElementAddItem')) {$(element).parents().closest('.teiElementAddItem').toggleClass("teiElementHidden");}
        if($(element).parents().closest('.teiElementAddGroup')) {$(element).parents().closest('.teiElementAddGroup').toggleClass("teiElementHidden");}
/*        $(idElementEdit).toggleClass("teiElementHidden");*/
        
};
function addData(   element,
                    docId,
                    input,
                    teiElementNickname,
                    xpath,
                    contentType,
                    index,
                    topConceptId)
{
    //CP:
    console.log("CP was here addData");
    console.log("element (normally this): " + element);

      switch(contentType){
                      case "textNodeAndAttribute":
                            var elementGroup = $(element).parents().closest('.teiElementGroup');
                            var elementInput =$("#" + input).find(".elementWithValue");
                            console.log("elementGroup: " + $(elementGroup).attr('id'));
                            console.log("input varaible: " + input);
                            
                            var tagName = elementInput.prop("tagName");
                          break;
                      default:
                      
                        if($("#lang_" + teiElementNickname + "_add"))
                            {var lang =$("#lang_" + teiElementNickname + "_add option:selected").text().trim();}
                            
                         console.log("test select: " + lang);
                        
                        
                        console.log($('#' + teiElementNickname + "_text_" + index + "_1").text());
/*                      var elementInput = $(element).siblings().children().find('.elementWithValue');*/
                        var elementGroup = $(element).parents().closest('.teiElementGroup');
                        var elementGroupId = $(elementGroup).attr('id');
                        console.log("elementGroup: " + $(elementGroup).attr('id'));
                        console.log("Input: " + $("#" + elementGroupId).find('.elementWithValue').text());
                       var elementInput = $(elementGroup).find('.elementWithValue');
                       var tagName = elementInput.prop("tagName");
                        break;
      }
      
      
      
      console.log("Tagname: " + tagName);
      console.log("contentType: " + contentType);
               switch(tagName){
                   case "BUTTON":
                      var newValue = elementInput.attr('value');
                      
                        var newValueTxt =  elementInput.text().trim();
                        console.log("NewValueTxt in button: " +newValueTxt );
                      console.log("newValue:" + newValue);
                      break;
                      
                   case "INPUT":
                            switch(contentType){
                               case "text": 
                                 newValue = elementInput.val();
                                 newValueTxt = elementInput.val();
                                 break;
                               
                               case "textNodeAndAttribute":
                                 newValue = $("#" + teiElementNickname + "_add_attrib_" + index + "_1").val();
                                 newValueTxt = $("#" + teiElementNickname + "_add_text_" + index + "_1").val();
                                 console.log("text= " + newValueTxt + " | attrib= " + newValue);
                                 break;
                               default: 
                                 newValue = elementInput.val();
                                 break;
                            }
                        break;
                       
                   case "SELECT":
                      newValue = elementInput.val();
                      break;
                   default:
                      newValue = elementInput.attr('value') ;
                      break;
               }
      //console.log("Value:: " + newValue);
                if (newValueTxt != "") {var valueText = newValueTxt}
                else {var valueText = elementInput.text()}
                console.log("newValueTxt: " + newValueTxt);
                console.log("valueText: " + valueText);
                console.log("elementInput.text(): " + elementInput.text().trim);
                console.log("CP: test for add thesaurus concept");
                // CP does not work:
                
                // <ref type="context" target="context:fercan.arch.baum">Baum</ref>
                //newValue = "&lt;ref type='context' target='context:fercan.arch." + newValue + "'&gt;" + newValue + "&lt;/ref&gt;";

   // console.log("value textual value= " + input.text());
        $("body").css("cursor", "wait");
        $("body").css("opacity", "0.5");
        $("button").attr("disabled", true);
        var xmlData = "<xml>"
                        + "<docId>" + docId + "</docId>"
                        + "<inputName>" + input + "</inputName>"

                        + "<value>" + newValue + "</value>"
                        + "<valueTxt>" + valueText + "</valueTxt>"
                        + "<teiElementNickname>" + teiElementNickname + "</teiElementNickname>"
                        + "<xpath>" + xpath + "</xpath>"
                        + "<contentType>" + contentType + "</contentType>"
                        + "<topConceptId>" + topConceptId + "</topConceptId>"
                        + "<lang>" + lang + "</lang>"
                        +"</xml>";
         console.log("xmlData = " + xmlData);

         //var input = inputName;
         //var inputId = "#" + inputName.name.toString();

         var request = new XMLHttpRequest();
         request.open("POST", "$ausohnum-lib/modules/teiEditor/getFunctions.xql?type=addData" , true);
         /*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                    //+ "&project=" + "patrimonium" + "&xpath=" + xpath
         /*                , true);*/
         var xmlDoc;

         request.onreadystatechange = function() {


           //TODOAPPEND TO GROUP
            if (request.readyState == 4 && request.status == 200) {
                var select = elementInput;
                 xmlDoc = request.responseText;
                 $(elementGroup).replaceWith(xmlDoc);
                  console.log("xmlDoc: " + xmlDoc);
                  
                  $("body").css("cursor", "default");
                  $("body").css("opacity", "1");
                  $("button").attr("disabled", false);
                  
/*                 $(elementGroup).replaceWith(xmlDoc.substring(5, xmlDoc.lastIndexOf('<')));
                 console.log("xmlDoc: " + xmlDoc);
                 var tagName = elementInput.prop("tagName");
                 switch(tagName){
                     case "BUTTON":
                        newValue2Display = elementInput.text();
                        break;
                     case "INPUT":
                        newValue2Display = elementInput.val();
                        console.log("NEW VAlUE: " + newValue2Display);
                        break;
                     case "SELECT":
                        //var el = document.getElementById(inputName.name.toString());
                        newValue2Display = elementInput.find(":selected").text();
                        break;
                     default:
                        newValue2Display = elementInput.attr('value') ;
                        break;
                 }
*/


                 //$(idElementValue).html(el.options[el.selectedIndex].innerHTML + " (" + $(inputName).val().substring(1) + ")");

/*                 elementDisplay.toggleClass("teiElementHidden");*/
                 //console.log("Response : Value of " + inputName.name.toString() + ": " + $(inputName).val());
                 //console.log("Response : Value of xmlDoc" + xmlDoc);
                 //console.log("Id of element" + idElementValue);

                 //$(idElementValue).text(xmlDoc.xml.value)
/*                 elementEdit.toggleClass("teiElementHidden");*/
/*                 if(inputName == "docTitle"){$("#docMainTitle").html(newValue2Display)};*/
                }

                };

         request.setRequestHeader('Content-Type', 'text/xml');

            request.send(xmlData);




};

function addGroupData(  element,
                        docId,
                        teiElementNickname,
                        index)
{
    
    $("body").css("cursor", "awit");
    $("body").css("opacity", "0.5");            
    console.log("element (normally this): " + element);
    var xmlDataItems = "";
    var elementGroup = $(element).parents().closest('.teiElementAddGroup ');
    var wholeGroup = $(element).parents().closest('.teiElementGroup');
    console.log(JSON.stringify(elementGroup));
    elementGroup.children().find('.elementWithValue').each(function(i, el){
                
    var elementInput = $(el);
    console.log("elementWithValue: " + elementInput);
    var teiElementNickname = elementInput.attr("name");
    if(elementInput.prop("tagName") === null)
        {var tagName = "INPUT"}
     else
        {var tagName = elementInput.prop("tagName");};
        console.log("tagname = " + tagName);
        switch(tagName)
        {
        case "BUTTON":
            newValue = elementInput.attr('value');
            newValueTxt = elementInput.text()
            xmlItem = '\r\n<groupItem teiElement="' + teiElementNickname + '">' + newValue + '</groupItem>';
            console.log(xmlItem);
            xmlDataItems = xmlDataItems  + xmlItem;
            break;
        case "INPUT":
            value = elementInput.val();
            xmlItem = '\r\n<groupItem teiElement="' + teiElementNickname + '">' + value + '</groupItem>';
            console.log(xmlItem);
            xmlDataItems = xmlDataItems  + xmlItem;
            break;
        case "TEXTAREA":
            value = elementInput.val();
            xmlItem = '\r\n<groupItem teiElement="' + teiElementNickname + '">' + value + '</groupItem>';
            console.log(xmlItem);
            xmlDataItems = xmlDataItems  + xmlItem;
            break;
        case "SELECT":
            newValue = elementInput.val();
            newValueTxt = elementInput.val();
            break;
        default:
            newValue = elementInput.val() ;
            newValueTxt = elementInput.val();
            
        break;
        }
                
    }
            
            );
            console.log(xmlDataItems);
            var xmlData = "<xml>"
                        + xmlDataItems
                        + "<docId>" + docId + "</docId>"
                        + "<index>" + index + "</index>"
                        + "<teiElementNickname>" + teiElementNickname + "</teiElementNickname>"
                        +"</xml>"
           var request = new XMLHttpRequest();
    console.log("xmlData: " + xmlData);
    console.log("CP was here addGroupData");
    request.open("POST", "$ausohnum-lib/modules/teiEditor/getFunctions.xql?type=addGroupData", true);
     var xmlDoc;
     request.onreadystatechange = function() {

            if (request.readyState == 4 && request.status == 200) {
                xmlDoc = request.responseXML;
                newElement2Display = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('updatedElement')[0]);
                console.log("XML doc: " + newElement2Display);
                wholeGroup.replaceWith(newElement2Display);
                $("body").css("cursor", "default");
                $("body").css("opacity", "1");
                   }

                };

            request.setRequestHeader('Content-Type', 'text/xml');
            request.send(xmlData);
        };

function addDataComboAndInput(element,
                            docId,
                            input,
                            teiElementNickname,
                            xpath,
                            contentType,
                            index,
                            topConceptId){
              console.log("element (normally this): " + element);
          /*  console.log("UsRI= " + $(element).siblings().children().find('.elementWithValue').prop("tagName"));*/
          /*  console.log("Textual value= " );*/
          
            // if(index == null) { ind =""} else {var ind = index}
            //         var elementDisplay= $("#" +inputName +"_display_" + ind.toString()+ "_" + cardinality);
            //         var elementValue= $("#" + inputName +"_value_"+ ind.toString()+ "_" + cardinality);
            //         var elementEdit= $("#" +inputName +"_edit_" + ind.toString()+ "_" + cardinality);
            //         var elementInput= $("#" +inputName + "_" + ind.toString() + "_" + cardinality);

      switch(contentType){
                      case "textNodeAndAttribute":
                            var elementGroup = $(element).parents().closest('.teiElementGroup');
                            var elementInput =$("#" + input).find(".elementWithValue");
                            var lookupResultLabel = $("#" + topConceptId + "conceptLookupResultLabeladd" + index).val();
                            var lookupResultUri = $("#" + topConceptId + "conceptLookupResultUriadd" + index).val();
                            var comboBoxUri = elementInput.attr('value');
                            var comboBoxLabel =  elementInput.text().trim();
                            
                            console.log("elementGroup: " + $(elementGroup).attr('id'));
                            console.log("input varaible: " + input);
                            
                            var tagName = elementInput.prop("tagName");
                          break;
                      default:
                      
                        if($("#lang_" + teiElementNickname + "_add"))
                            {var lang =$("#lang_" + teiElementNickname + "_add option:selected").text().trim();}
                            
                         console.log("test select: " + lang);
                        
                        
                        console.log($('#' + teiElementNickname + "_text_" + index + "_1").text());
/*                      var elementInput = $(element).siblings().children().find('.elementWithValue');*/
                        var elementGroup = $(element).parents().closest('.teiElementGroup');
                        var elementGroupId = $(elementGroup).attr('id');
                        console.log("elementGroup: " + $(elementGroup).attr('id'));
                        console.log("Input: " + $("#" + elementGroupId).find('.elementWithValue').text());
                       var elementInput = $(elementGroup).find('.elementWithValue');
                       var tagName = elementInput.prop("tagName");
                        break;
      }
      
      
      
      console.log("Tagname: " + tagName);
      console.log("contentType: " + contentType);
               switch(tagName){
                   case "BUTTON":
                      var newValue = elementInput.attr('value');
                      
                        var newValueTxt =  elementInput.text().trim();
                        console.log("NewValueTxt in button: " +newValueTxt );
                      console.log("newValue:" + newValue);
                      break;
                      
                   case "INPUT":
                            switch(contentType){
                               case "text": 
                                 newValue = elementInput.val();
                                 newValueTxt = elementInput.val();
                                 break;
                               
                               case "textNodeAndAttribute":
                                 newValue = $("#" + teiElementNickname + "_add_attrib_" + index + "_1").val();
                                 newValueTxt = $("#" + teiElementNickname + "_add_text_" + index + "_1").val();
                                 console.log("text= " + newValueTxt + " | attrib= " + newValue);
                                 break;
                               default: 
                                 newValue = elementInput.val();
                                 break;
                            }
                        break;
                       
                   case "SELECT":
                      newValue = elementInput.val();
                      break;
                   default:
                      newValue = elementInput.attr('value') ;
                      break;
               }
      //console.log("Value:: " + newValue);
                
          if(lookupResultLabel =="" && comboBoxUri == "" ) {alert("Please select an item or search for a term");}
            else {
                if (lookupResultLabel != "")
                {var newValueLabel = lookupResultLabel}
                else {var newValueLabel = comboBoxLabel}
                if (lookupResultUri != "")
                {var newValueUri = lookupResultUri}
                else {var newValueUri = comboBoxUri}
                console.log("newValue Label: " + newValueLabel);
                console.log("value URI: " + newValueUri);
                //console.log("elementInput.text(): " + elementInput.text().trim);
   // console.log("value textual value= " + input.text());
        $("body").css("cursor", "wait");
        $("body").css("opacity", "0.5");
        $("button").attr("disabled", true);
        var xmlData = "<xml>"
                        + "<docId>" + docId + "</docId>"
                        + "<inputName>" + input + "</inputName>"
                       + "<value>" + newValueUri + "</value>"
                        + "<valueTxt>" + newValueLabel + "</valueTxt>"
                        + "<teiElementNickname>" + teiElementNickname + "</teiElementNickname>"
                        + "<xpath>" + xpath + "</xpath>"
                        + "<contentType>" + contentType + "</contentType>"
                        + "<topConceptId>" + topConceptId + "</topConceptId>"
                        + "<lang>" + lang + "</lang>"
                        +"</xml>";
         console.log("xmlData = " + xmlData);

         //var input = inputName;
         //var inputId = "#" + inputName.name.toString();

         var request = new XMLHttpRequest();
         request.open("POST", "$ausohnum-lib/modules/teiEditor/getFunctions.xql?type=addData" , true);
         /*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                    //+ "&project=" + "patrimonium" + "&xpath=" + xpath
         /*                , true);*/
         var xmlDoc;

         request.onreadystatechange = function() {


           //TODOAPPEND TO GROUP
            if (request.readyState == 4 && request.status == 200) {
                var select = elementInput;
                 xmlDoc = request.responseText;
                 $(elementGroup).replaceWith(xmlDoc);
                  console.log("xmlDoc: " + xmlDoc);
                  
                  $("body").css("cursor", "default");
                  $("body").css("opacity", "1");
                  $("button").attr("disabled", false);
                  
/*                 $(elementGroup).replaceWith(xmlDoc.substring(5, xmlDoc.lastIndexOf('<')));
                 console.log("xmlDoc: " + xmlDoc);
                 var tagName = elementInput.prop("tagName");
                 switch(tagName){
                     case "BUTTON":
                        newValue2Display = elementInput.text();
                        break;
                     case "INPUT":
                        newValue2Display = elementInput.val();
                        console.log("NEW VAlUE: " + newValue2Display);
                        break;
                     case "SELECT":
                        //var el = document.getElementById(inputName.name.toString());
                        newValue2Display = elementInput.find(":selected").text();
                        break;
                     default:
                        newValue2Display = elementInput.attr('value') ;
                        break;
                 }
*/


                 //$(idElementValue).html(el.options[el.selectedIndex].innerHTML + " (" + $(inputName).val().substring(1) + ")");

/*                 elementDisplay.toggleClass("teiElementHidden");*/
                 //console.log("Response : Value of " + inputName.name.toString() + ": " + $(inputName).val());
                 //console.log("Response : Value of xmlDoc" + xmlDoc);
                 //console.log("Id of element" + idElementValue);

                 //$(idElementValue).text(xmlDoc.xml.value)
/*                 elementEdit.toggleClass("teiElementHidden");*/
/*                 if(inputName == "docTitle"){$("#docMainTitle").html(newValue2Display)};*/
                }

                };

         request.setRequestHeader('Content-Type', 'text/xml');

            request.send(xmlData);


        };

};


function addItem(element, item, index){
/*          teiElementNickname --> used as prefix of input name
 *          index -->   index no of corresponding TEI div/@type='textpart'; default = 1
 *
 * */
    $(element).parents().closest(".teiElementGroup").find('.teiElementAddItem').toggleClass("teiElementHidden");
};

function addGroupItem(element, item, index){
/*          teiElementNickname --> used as prefix of input name
 *          index -->   index no of corresponding TEI div/@type='textpart'; default = 1
 *
 * */

        $(element).parents().closest(".teiElementGroup").find('.teiElementAddGroupItem').toggleClass("teiElementHidden");

};

function saveData(docId, inputName, xpath, contentType, index, cardinality){
/*    console.log("Value of " + inputName.name.toString()  + ": " + $(inputName).val());*/
if(index == null) { ind =""} else {var ind = index}
        var elementDisplay= $("#" +inputName +"_display_" + ind.toString()+ "_" + cardinality);
        var elementValue= $("#" + inputName +"_value_"+ ind.toString()+ "_" + cardinality);
        var elementEdit= $("#" +inputName +"_edit_" + ind.toString()+ "_" + cardinality);
        var elementInput= $("#" +inputName + "_" + ind.toString() + "_" + cardinality);
        var elementGroup = $(inputName).parents().closest('.teiElementGroup');
        switch(contentType){
                      case "textNodeAndAttribute":
                        //var elementGroup = $(inputName).parents().closest('.teiElementGroup');
                        console.log("elementGroup: " + $(elementGroup).attr('id'));
                        if(elementInput.prop("tagName") === null)
                            {var tagName = "INPUT"}
                            else{
                                var tagName = elementInput.prop("tagName");
                                
                            };
                            console.log("tagname loop" + tagName);
                      break;
                      default:
                        var tagName = elementInput.prop("tagName");
                        console.log("Tganame: " + tagName);              
                        }              
        
             switch(tagName){
                 case "BUTTON":
                    newValue = elementInput.attr('value');
                    newValueTxt = elementInput.text()
                    break;
                 case "INPUT":
                    switch(contentType){
                      case "text": 
                        newValue = elementInput.val();
                        newValueTxt = elementInput.val();  
                      break;
                      case "textNodeAndAttribute":
                        newValue = $("#" + inputName + "_attrib_" + index + "_" + cardinality).val();
                        newValueTxt = $("#" + inputName + "_text_" + index + "_" + cardinality).val();
                        console.log("text= " + newValueTxt + " | attrib= " + newValue);
                        break;
                      default: 
                        newValue = elementInput.val();
                        break;
                        }  
                    break;
                 case "SELECT":
                    newValue = elementInput.val();
                    newValueTxt = elementInput.val();
                    break;
                 default:
                    newValue = elementInput.val() ;
                    newValueTxt = elementInput.val();
                    break;
             }
             
    console.log("Value:: " + newValue);
    console.log("Input Id:: " + inputName + "_" + index + "_" + cardinality );
    var xmlData = "<xml>"
                    + "<elementNickname>" + inputName + "</elementNickname>"
                    + "<inputName>" + inputName + "_" + index + "_" + cardinality + "</inputName>"
                    + "<docId>" + docId + "</docId>"
                    + "<value>" + newValue + "</value>"
                    + "<valueTxt>" + newValueTxt + "</valueTxt>"
                    + "<xpath>" + xpath + "</xpath>"
                    + "<contentType>" + contentType + "</contentType>"
                    + "<index>" + cardinality + "</index>"
                    +"</xml>";
     console.log("xmlData = " + xmlData);

     //var input = inputName;
     //var inputId = "#" + inputName.name.toString();

     var request = new XMLHttpRequest();
     console.log("docId = " + docId);
     request.open("POST", "$ausohnum-lib/modules/teiEditor/getFunctions.xql?type=saveData", true);
/*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                //+ "&project=" + "patrimonium" + "&xpath=" + xpath
/*                , true);*/
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
            var select = elementInput;
             xmlDoc = request.responseXML;
             xmlString = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('newContent')[0]);
             newElement2Display = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('updatedElement')[0]);
/*             console.log("newElement2Display: " + newElement2Display);*/
             oldValueTxt = xmlDoc.getElementsByTagName('oldContent')[0].textContent;
             console.log("oldValueTxt:" + oldValueTxt);
             console.log("TEST element name: " + elementInput.prop("tagName"));
             var tagName = elementInput.prop("tagName");
             switch(tagName){
                 case "BUTTON":
                    newValue2Display = elementInput.text();
                    break;
                 case "INPUT":
                    switch(contentType){
                      case "text":
                        newValue2Display = elementInput.val();
                        console.log("NEW VAlUE: " + newValue2Display);
                        
                        console.log("new content" + xmlString) ; 
                        
                        
                        break;
                      case "textNodeAndAttribute":
                          newValue = $("#" + inputName + "_attrib_" + index + "_" + cardinality).val();
                          newValueTxt = $("#" + inputName + "_text_" + index + "_" + cardinality).val();
                          newValue2Display = nexValueTxt + " " + newValue;
                      break;}
                    case "TEXTAREA":
                    newValue2Display = elementInput.val();
                    console.log("NEW VAlUE: " + newValue2Display);
                    break;
                   case "SELECT":
                    //var el = document.getElementById(inputName.name.toString());
                    newValue2Display = elementInput.find(":selected").text();
                    break;
                 default:
                    newValue2Display = elementInput.attr('value') ;
                    break;
             }
            var xmlFile =  


             //$(idElementValue).html(el.options[el.selectedIndex].innerHTML + " (" + $(inputName).val().substring(1) + ")");
             
             elementValue.html(function(i,t){
                            return t.replace(oldValueTxt, newValue2Display)});
/*             elementGroup.html(newElement2Display);*/
             
             console.log("newValue2Display: " + newValue2Display);
             elementDisplay.toggleClass("teiElementHidden");
             //console.log("Response : Value of " + inputName.name.toString() + ": " + $(inputName).val());
             //console.log("Response : Value of xmlDoc" + xmlDoc);
             //console.log("Id of element" + idElementValue);

             //$(idElementValue).text(xmlDoc.xml.value)
             elementEdit.toggleClass("teiElementHidden");
             if(inputName == "docTitle"){$("#docMainTitle").html(newValue2Display)};
             
             refreshXmlFile(xmlString);
            }

            };

     request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);


};

function saveData2( element, 
                    docId, 
                    inputName_text, 
                    input_name_attrib,
                    elementNickName,
                    xpath,
                    contentType,
                    index, 
                    cardinality)
{
 

    /*    console.log("Value of " + inputName.name.toString()  + ": " + $(inputName).val());*/
    var inputElementForText = $("#" + inputName_text);
    var inputElementForAttrib = $("#" + input_name_attrib);
    if(index == null) { ind =""} else {var ind = index}
    if(inputElementForText.prop("tagName") === null)
    {
        var tagName = "INPUT"
    }
    else
    {
        var tagName = inputElementForText.prop("tagName");
        var elementGroup = $(inputElementForText).parents().closest('.teiElementGroup');
    };
    
    var elementDisplay= $("#" +elementNickName +"_display_" + ind.toString()+ "_" + cardinality);
    var elementValue= $("#" + elementNickName +"_value_"+ ind.toString()+ "_" + cardinality);
    var elementEdit= $("#" +elementNickName +"_edit_" + ind.toString()+ "_" + cardinality);
    var elementInput= $("#" +elementNickName + "_" + ind.toString() + "_" + cardinality);
        
    switch(contentType)
    {
        case "textNodeAndAttribute":
        break;
        default:
        break;
    }              
        
    switch(tagName)
    {
        case "BUTTON":
        newValue = inputElementForText.attr('value');
        newValueTxt = inputElementForText.text().trim();
        break;
                 case "INPUT", "TEXTAREA":
                    switch(contentType){
                      case "text", "enrichedText": 
                        newValue = elementInput.val();
                        newValueTxt = elementInput.val();  
                      break;
                    case "textNodeAndAttribute":
                        newValue = inputElementForAttrib.val();
                        newValueTxt = inputElementForText.val();
/*                        console.log("text= " + newValueTxt + " | attrib= " + newValue);*/
                        break;
                      case "nodes":
                        newValue = inputElementForText.val();
                        newValueTxt = inputElementForText.val();
/*                        console.log("text= " + newValueTxt + " | attrib= " + newValue);*/
                        break;
                      default: 
                        newValue = elementInput.val();
                        newValueTxt = inputElementForText.val();
                        break;
                        }  
                    break;
                 case "SELECT":
                        switch(contentType){
                        case("textNodeAndAttribute"):
                            newValue = $("#" +elementNickName + "_" + ind.toString() + "_" + cardinality + ' option:selected').val();
                            newValueTxt = $("#" +elementNickName + "_" + ind.toString() + "_" + cardinality + ' option:selected').attr("textValue");
/*                            console.log("newValue: " + newValue );*/
/*                            console.log("newValueTxt: " + newValueTxt );*/
                          break;}
                    break; //for case select
                 default:
                    newValue = elementInput.val() ;
                    newValueTxt = elementInput.val();
                    break;
             }

    // CP: a bit hacky (lot of if) but works ;)
    // input validation 
    // input is not valid at first
    let isInputValid = false;
    let pattern_dimensions = /^[0-9, ]*$/g;
    let pattern_iso_date = /\b0\d{3}$/g;
    let pattern_abbildung = /\w+\.(jpg|png)*$/g;
    let pattern_abbildung_type = /image\/jpeg|image\/png|text\/csv$/g;
    let pattern_digit_only = /^\d+$/g;
    let pattern_buchstabenhoehe_text = /\d+(,\d+)?–\d+(,\d+)? cm$/g;
    let pattern_buchstabenhoehe_att = /\d+\.\d+$/g;
    let pattern_pid = /o:fercan.\d+$/g;
    let pattern_weihestein = /Weihestein$/g;
    let pattern_fundjahr = /\b\d{4}(\/\d{4})?$/g;
    let pattern_EDH_id = /\bHD\d+$/g;
    let pattern_ClaussSlaby_id = /\bEDCS-\d+$/g;

    if((elementNickName == 'Hoehe' || 
        elementNickName == 'Breite' || 
        elementNickName == 'Tiefe') && 
        !pattern_dimensions.test(newValue))
    {
        alert("'" + newValue + "'" + " is not valid. valid is something like '10,5'");
    }
    else if ((  elementNickName == 'DatISO_notAfter' || 
                elementNickName == 'DatISO_notBefore') &&
                !pattern_iso_date.test(newValue))
    {
        alert("'" + newValue + "'" + " is not a valid ISO date. valid is something like '0100'");
    }
    else if (   elementNickName == 'Abb_filename' &&
                !pattern_abbildung.test(newValue))
    {
        alert("'" + newValue + "'" + " is not a valid file name. valid is something like '0001_Front.jpg'");
    }
    else if (   elementNickName == 'Abb_type' &&
                !pattern_abbildung_type.test(newValue))
    {
        alert("'" + newValue + "'" + " is not a valid MIME-Type. valid is something like 'image/jpeg'");
    }
    // digit only for "Zeile" and Editionen und Lesungen/ID
    else if (   (elementNickName  == 'Appcrit_loc' || elementNickName == 'Editionen_id') &&
                !pattern_digit_only.test(newValue))
    {
        alert("'" + newValue + "'" + " is not valid. valid is something like '1'");
    }
    else if (   elementNickName == 'Buchsthoehe_text' &&
                !pattern_buchstabenhoehe_text.test(newValue))
    {
        alert("'" + newValue + "'" + " is not valid. valid is something like '2,3–5,1 cm'");
    }
    else if (   (elementNickName == 'Buchsthoehe_atLeast' || elementNickName == 'Buchsthoehe_atMost') &&
                !pattern_buchstabenhoehe_att.test(newValue))
    {
        alert("'" + newValue + "'" + " is not valid. valid is something like '0.4'");
    }
    else if (   elementNickName == 'PID' &&
                !pattern_pid.test(newValue))
    {
        alert("'" + newValue + "'" + " is not valid. valid is something like 'o:fercan.468'");
    }    
    else if (   elementNickName == 'Inschrifttraeger' &&
                !pattern_weihestein.test(newValue))
    {
        alert("'" + newValue + "'" + " is not valid. valid is only 'Weihestein'");
    } 
    else if (   elementNickName == 'Fundjahr' &&
                !pattern_fundjahr.test(newValue))
    {
        alert("'" + newValue + "'" + " is not valid. valid is something like '1929'");
    } 
    else if (   elementNickName == 'EDH_id' &&
                !pattern_EDH_id.test(newValue))
    {
        alert("'" + newValue + "'" + " is not valid. valid is something like 'HD025629'");
    }
    else if (   elementNickName == 'ClaussSlaby_id' &&
                !pattern_ClaussSlaby_id.test(newValue))
    {
        alert("'" + newValue + "'" + " is not valid. valid is something like 'EDCS-11202312'");
    }    
    else
    {
        isInputValid = true;
        // CP:
        // input adaption
    }

       
    if(isInputValid)
    {         
    var xmlData = "<xml>"
                    + "<elementNickname>" + elementNickName + "</elementNickname>"
                    + "<inputName>" + inputName_text + "</inputName>"
                    + "<docId>" + docId + "</docId>"
                    + "<value>" + newValue + "</value>"
                    + "<valueTxt>" + newValueTxt + "</valueTxt>"
                    + "<xpath>" + xpath + "</xpath>"
                    + "<contentType>" + contentType + "</contentType>"
                    + "<index>" + index + "</index>"
                    +"</xml>";
     console.log("xmlData = " + xmlData);

     var request = new XMLHttpRequest();
     request.open("POST", "$ausohnum-lib/modules/teiEditor/getFunctions.xql?type=saveData", true);
     
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
            var select = elementInput;
             xmlDoc = request.responseXML;
             xmlString = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('TEI')[0]);
             newElement2Display = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('updatedElement')[0]);
             newContent = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('newContent')[0]);
             oldValueTxt = xmlDoc.getElementsByTagName('oldContent')[0].textContent;
             var tagName = elementInput.prop("tagName");
             switch(tagName){
                 case "BUTTON":
                    newValue2Display = elementInput.text();
                    break;
                 case "INPUT":
                    switch(contentType){
                            case "text":
                               newValue2Display = elementInput.val();
/*                               console.log("NEW VAlUE in case Input: " + newValue2Display);*/
/*                               console.log("new content" + xmlString) ; */
                            break;
                            case "attribute":
                               newValue2Display = elementInput.val();
                               break;
                            case "textNodeAndAttribute":
                                newValue = $("#" + elementNickName + "_attrib_" + index + "_" + cardinality).val();
                                newValueTxt = $("#" + elementNickName + "_text_" + index + "_" + cardinality).val();
                                newValue2Display = newValueTxt + " " + newValue;
                            break;};
                       break;
                    case "TEXTAREA":
                        newValue2Display = elementInput.val();
/*                        console.log("NEW VALUE: " + newValue2Display);*/
                        break;
                   case "SELECT":
                    //var el = document.getElementById(inputName.name.toString());
                    newValue2Display = elementInput.find(":selected").text();
                    break;
                 default:
                    newValue2Display = elementInput.attr('value') ;
                    break;
             }
/*            var xmlFile =  */


             //$(idElementValue).html(el.options[el.selectedIndex].innerHTML + " (" + $(inputName).val().substring(1) + ")");
             
             
             /*elementValue.html(function(i,t){
                            return t.replace(oldValueTxt, newValue2Display)});*/
/*             console.log("NEW VAlUE end of saveData2: " + newValue2Display);*/
/*             console.log("NEW element to diplay: " + newElement2Display);*/
             console.log("newValue2Display: " + newValue2Display);
             console.log("Elementgroup: " + elementGroup);
            elementGroup.replaceWith(newElement2Display);
             
            
/*             elementDisplay.toggleClass("teiElementHidden");*/
             //console.log("Response : Value of " + inputName.name.toString() + ": " + $(inputName).val());
             //console.log("Response : Value of xmlDoc" + xmlDoc);
             //console.log("Id of element" + idElementValue);

             //$(idElementValue).text(xmlDoc.xml.value)
/*             elementEdit.toggleClass("teiElementHidden");*/
             if(elementNickName == "docTitle"){$("#docMainTitle").html(newValue2Display)};
             
             refreshXmlFile(xmlString);
             $("#body").toggleClass('overlap');
     $("#fileModifiedAlert" ).fadeOut(1);
     $("#saveFileButton" ).fadeOut(1);
             //$("#content").replaceWith(newConcent);
            }

            };

     request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);
    }
    else
    {
        alert("input is not valid");
    }

};

function saveDataForGroup(element, docId, elementNickname, contentType, index, cardinality){
    var elementGroup = $(element).parents().closest('.teiElementGroup');
    var elementWithValue = $(element).parents().closest('.elementWithValue');
    var elementType = elementWithValue.prop("tagName");
            console.log("elementType: " + elementType);
            
     switch(tagName){
                 case "BUTTON":
                    newValue = elementWithValue.attr('value');
                    console.log("new value: " + newValue);
                    newValueTxt = elementWithValue.text().trim();
                    break;
                 case "INPUT", "TEXTAREA":
                    switch(contentType){
                      case "text": 
                        newValue = elementWithValue.val();
                        newValueTxt = elementWithValue.val();  
                        console.log("New value in 470" + newValueTxt);
                      break;
                    case "textNodeAndAttribute":
                        newValue = elementWithValue.val();
                        newValueTxt = elementWithValue.val();
                        console.log("text= " + newValueTxt + " | attrib= " + newValue);
                        break;
                      
                      default: 
                        newValue = elementWithValue.val();
                        break;
                        }  
                    break;
                 case "SELECT":
                        switch(contentType){
                        case("textNodeAndAttribute"):
                            /*newValue = $("#" +elementNickName + "_" + ind.toString() + "_" + cardinality + ' option:selected').val();
                            newValueTxt = $("#" +elementNickName + "_" + ind.toString() + "_" + cardinality + ' option:selected').attr("textValue");
                            console.log("newValue: " + newValue );
                            console.log("newValueTxt: " + newValueTxt );*/
                          break;}
                    break; //for case select
                 default:
                    newValue = elementWithValue.val() ;
                    newValueTxt = elementWithValue.val();
                    break;
                    };
               console.log("New value: " + newValue + " | New Value Text: " + newValueTxt);
    
};
function refreshXmlFile(newContent){
    var xmlFileEditor = ace.edit("xml-editor-file");
    xmlFileEditor.setValue(newContent);
            $("#messageZone").fadeOut(1);
            $("#fileModifiedAlert" ).fadeOut(1);
            $("#saveFileButton" ).fadeOut(1);
             $("#body").toggleClass('overlap');
                $("#messageZone").css('background-color', '#8c0000');
            $("#messageZone").css('color', 'white');
    
};

function saveFile(docId){
    var xmlFileEditor = ace.edit("xml-editor-file");
   
    var newContent = xmlFileEditor.getValue();
    var oParser = new DOMParser();
    var oDOM = oParser.parseFromString(newContent, "text/xml");
    
    if(isParseError(oDOM)) {
            alert(getXMLError(oDOM.documentElement));
    }
    else{
     
        $("body").css("cursor", "wait");
        $("body").css("opacity", "0.5");
        $("button").attr("disabled", true);
   
    var xmlData = "<xml>"
                    + "<inputName>" + "docTextSingle" + "</inputName>"
                    + "<docId>" + docId + "</docId>"
                    
                    + "<newContent>" + newContent + "</newContent>"
                    +"</xml>";
/*        console.log(xmlData);*/
            var request = new XMLHttpRequest();
            request.open("POST", "$ausohnum-lib/modules/teiEditor/getFunctions.xql?type=saveFile" , true);

    var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
/*            var el = document.getElementById(inputName.name.toString());*/
             xmlDoc = request.responseText;
            $("#body").toggleClass('overlap');

            //$("#messageZone").css("display", "block");
            //$("#messageZone").html("Text saved!");
            //$("#messageZone").css('background-color', '#8c0000');
            //$("#messageZone").css('color', 'white');
/*            $("#messageZone").css('top', '0');*/
/*            $("#messageZone").fadeOut(200);*/
/*            $("#fileModifiedAlert" ).fadeOut(100);*/
/*            $("#saveFileButton" ).fadeOut(100);*/
/*            $("#messageZone").css("display", "none");*/


             //$(idElementValue).html(el.options[el.selectedIndex].innerHTML + " (" + $(inputName).val().substring(1) + ")");

/*             $(idElementValue).html(newValue2Display);*/


             //console.log("Response : Value of xmlDoc" + xmlDoc);
             // CP
             url4reload = "/exist/apps/estudium/edit-documents/" + docId;
/*             url4reload2 = "http://ausohnum.localhost/admin/reload/document/" + docId ;*/
             $('body').load(url4reload, function() {
                  console.log(url4reload);
                  console.log("DOCID: " + docId);
               ace.require("ace/ext/language_tools");
        
                $.ajax({ type: "GET",   
                             url: "/getdoctext/"+docId,   
                             //async: false,
                             dataType: "xml",
                             success : function(xml)
                             {
/*                             console.log("RESSOURCE: " +resource);*/
                                var xmlEditorArray = [];
                                var pseudoLeidenEditorArray = [];
                                var textPreviewHTMLArray =  $('.textPreviewHTML');
                                var xmlText = new XMLSerializer().serializeToString(xml);
                                        /*console.log("IN AJAX *Loading text************************"
                                         + "\n" +  xmlText);*/
                                $(xml).find('ab').each(function(index){
                                        var no = parseInt(index) + 1;
                                        
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
                                     
                                        
                                        var textPreviewHTMLName = "textPreviewHTML-" + no ;
                                       
                                         xmlText = xmlEditorArray[index].getValue();
                                         $(textPreviewHTMLArray[index]).html(tei2Html4Preview(xmlText));
                                        
                                    window.scrollTo(0,0);
                                     
                                     
  
                                     
                                     
                                    });
                             
                                 
                             }
                    });
               
               
               
               
               
               
               
                        tabToActive = "nav-xmlfile";
                  console.log(tabToActive);
                  $("body").css("cursor", "default");
                  $("body").css("opacity", "1");
                  $("button").attr("disabled", false);
                  $('#pills-tab a[href="#' + tabToActive + '"]').tab('show');
                  if($("body").hasClass('overlap')){$("body").toggleClass('overlap');}
                
                });
             
             
/*             console.log("Id of element" + idElementValue);*/


            } // END of (request.readyState == 4 && request.status == 200) {

        if (request.status == 400) {
            alert("Text could not be saved.\n"
            +"Response: " + request.response);
        }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);
}
};


function saveText(docId, index){
    
    var no = index;
/*    console.log("Index= " + index + " *** no= " + no);*/
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + no ;
    var comment = $("#changeComment" + no).val();
    
    
    xmlEditorArray[no] = ace.edit(xmlEditorName);
    var newText = xmlEditorArray[no].getValue();
    
     var oParser = new DOMParser();
    var oDOM = oParser.parseFromString("<text>" + newText + "</text>", "text/xml");
    
    if(isParseError(oDOM)) {
            alert(getXMLError(oDOM.documentElement));
    }
    else{
    $("body").css("cursor", "wait");
console.log("newText: " + newText);
    var xmlData = "<xml>"
                    + "<inputName>" + "docTextSingle" + "</inputName>"
                    + "<docId>" + docId + "</docId>"
                    + "<index>" + no + "</index>"
                    + "<comment>" + comment + "</comment>"
                    + "<newText>" + newText + "</newText>"
                    +"</xml>";

    var request = new XMLHttpRequest();
    request.open("POST", "$ausohnum-lib/modules/teiEditor/getFunctions.xql?type=saveText" , true);

var xmlDoc;
var xmlDocXML;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
/*            var el = document.getElementById(inputName.name.toString());*/
             xmlDoc = request.responseText;
             xmlDocXML = request.responseXML;
             xmlString = (new XMLSerializer()).serializeToString(xmlDocXML.getElementsByTagName('TEI')[0]);
             refreshXmlFile(xmlString);
            $("#body").removeClass('overlap');

            $("#messageZone").css("display", "block");
            $("#messageZone").html("Text saved!");
            $("#messageZone").css('background-color', '#8c0000');
            $("#messageZone").css('color', 'white');
/*            $("#messageZone").css('top', '0');*/
            $("#messageZone").fadeOut(2000);
            $("#editionAlert" + no).fadeOut(500);
            
/*            $("#saveTextButton" + no).fadeOut(1000);*/
/*            $("#messageZone").css("display", "none");*/


             //$(idElementValue).html(el.options[el.selectedIndex].innerHTML + " (" + $(inputName).val().substring(1) + ")");

/*             $(idElementValue).html(newValue2Display);*/


/*             console.log("Response : Value of xmlDoc" + xmlDoc);*/
/*             console.log("Id of element" + idElementValue);*/
            $("body").css("cursor", "default");

            } // END of (request.readyState == 4 && request.status == 200) {

        if (request.status == 400) {
            alert("Text could not be saved. Please check XML.");
        }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);
};
};


function saveTextarea(docId, textareaId, elementNickName, xpath, index){
    
    var no = index;
/*    console.log("Index= " + index + " *** no= " + no);*/
  var elementInput= $("#" +textareaId);  
  var newText = newValueTxt = elementInput.val().replace('<br>', '<br/>').replace('&nbsp;', ''); 
  var oParser = new DOMParser();
  var oDOM = oParser.parseFromString("<text>" + newText + "</text>", "text/xml");
    
    if(isParseError(oDOM)) {
            alert(getXMLError(oDOM.documentElement));
    }
    else{
    $("body").css("cursor", "wait");
    // CP: hacky replace <i> with <rs type="divine"> 
    newText = newText.replace('<i>', '<rs type="divine">');
    newText = newText.replace('</i>', '</rs>');
    console.log("newText: " + newText);
    var xmlData = "<xml>"
                    + "<inputName>" + textareaId + "</inputName>"
                    + "<docId>" + docId + "</docId>"
                    + "<elementNickName>" + elementNickName  + "</elementNickName>"
                    + "<index>" + no + "</index>"
                    + "<xpath>" + xpath + "</xpath>"
                    + "<newText>" + newText + "</newText>"
                    +"</xml>";

    var request = new XMLHttpRequest();
    request.open("POST", "$ausohnum-lib/modules/teiEditor/getFunctions.xql?type=saveTextarea" , true);

var xmlDoc;
var xmlDocXML;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
/*            var el = document.getElementById(inputName.name.toString());*/
             xmlDoc = request.responseText;
             xmlDocXML = request.responseXML;
             xmlString = (new XMLSerializer()).serializeToString(xmlDocXML.getElementsByTagName('TEI')[0]);
            refreshXmlFile(xmlString);
            $("#body").removeClass('overlap');

            $("#" + textareaId + "_message").css("display", "block");
            $("#" + textareaId + "_message").html("Text has been saved...");
            $("#" + textareaId + "_message").css('background-color', '#a8fa78');
/*            $("#" + textareaId + "_message").css('color', 'white');*/
/*            $("#messageZone").css('top', '0');*/
            $("#" + textareaId + "_message").fadeOut(3000);
/*            $("#editionAlert" + no).fadeOut(500);*/
            
/*            $("#saveTextButton" + no).fadeOut(1000);*/
/*            $("#messageZone").css("display", "none");*/


             //$(idElementValue).html(el.options[el.selectedIndex].innerHTML + " (" + $(inputName).val().substring(1) + ")");

/*             $(idElementValue).html(newValue2Display);*/


/*             console.log("Response : Value of xmlDoc" + xmlDoc);*/
/*             console.log("Id of element" + idElementValue);*/
            $("body").css("cursor", "default");

            } // END of (request.readyState == 4 && request.status == 200) {

        if (request.status == 400) {
            alert("Text could not be saved. \n" + "Error " + request.status + ".\n" + request.responseText);
        }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);
};
};

function isParseError(parsedDocument) {
    // parser and parsererrorNS could be cached on startup for efficiency
    var parser = new DOMParser(),
        errorneousParse = parser.parseFromString('<', 'text/xml'),
        parsererrorNS = errorneousParse.getElementsByTagName("parsererror")[0].namespaceURI;

    if (parsererrorNS === 'http://www.w3.org/1999/xhtml') {
        // In PhantomJS the parseerror element doesn't seem to have a special namespace, so we are just guessing here :(
        return parsedDocument.getElementsByTagName("parsererror").length > 0;
    }

    return parsedDocument.getElementsByTagNameNS(parsererrorNS, 'parsererror').length > 0;
};
function getXMLError(x) {
  var i, y, xLen, txt;
  txt = "";
  x = x.childNodes;
  xLen = x.length;
  for (i = 0; i < xLen ;i++) {
    if (i === 2) { 
    break; }
    y = x[i];
    if (y.nodeType != 3) {
      if (y.childNodes[0] != undefined) {
        txt += getXMLError(y) ;
      }
    } else {
    txt += y.nodeValue + "";
    }
  }
  return txt;
};



/*
******************************
*         BIBLIOGRAPHY       *
******************************
*/

function openBiblioDialog(){
    $('#dialogInsertBiblio').modal('show');
};



function addBiblioRef(docId, zoteroGroup, type){
    
    if($('#add' +type + 'BiblioForm' ).valid() == true) { 
      $("body").css("cursor", "wait");
      $("body").css("opacity", "0.5");
      $("button").attr("disabled", true);
    var biblioId = $('#selectedBiblioId' + type).html();
    var citedRange = $('#citedRange'+ type).val();
    var request = new XMLHttpRequest();


    var xmlData="<xml>"
                    + "<docId>" + getCurrentDocId() + "</docId>"
                    + "<zoteroGroup>" + zoteroGroup + "</zoteroGroup>"
                    + "<type>" + type + "</type>"
                    + "<biblioId>" + biblioId + "</biblioId>"
                    + "<citedRange>" + citedRange + "</citedRange>"
                +"</xml>";

     console.log("xmldata: " + xmlData);

/*     request.open("POST", "http://patrimonium.huma-num.fr/admin/save/document/addBiblio", true);*/
     request.open("POST", "$ausohnum-lib/modules/teiEditor/getFunctions.xql?type=addBiblio" , true);
/*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                //+ "&project=" + "patrimonium" + "&xpath=" + xpath
/*                , true);*/
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
/*            var el = document.getElementById(inputName.name.toString());*/
             xmlDoc = request.responseText;
             xmlDocXML = request.responseXML;
             xmlString = (new XMLSerializer()).serializeToString(xmlDocXML.getElementsByTagName('newContent')[0]);
             newBiblList= (new XMLSerializer()).serializeToString(xmlDocXML.getElementsByTagName('newBiblList')[0]);
             $('#dialogInsert' + type + 'Biblio').find("input[type=text], textarea").val("");
             $(".lookupSelectionPreview").html("");
            $('#dialogInsert' + type + 'Biblio').modal('hide');
/*            $('#mainBiblioList').html(xmlDoc.substring(5, xmlDoc.lastIndexOf('<')))*/
/*            $('#mainBiblioList').html(newBiblList);*/
            console.log("New biblio list: " + newBiblList);
            console.log("type: " + type);
            $('#' + type + 'BiblioList').html(newBiblList);
             //$(idElementValue).html(el.options[el.selectedIndex].innerHTML + " (" + $(inputName).val().substring(1) + ")");

/*             $(idElementValue).html(newValue2Display);*/


/*             console.log("Response : Value of xmlDoc" + xmlDoc);*/
             refreshXmlFile(xmlString);
             $("#body").toggleClass('overlap');
/*             console.log("Id of element" + idElementValue);*/


            }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);
          $("body").css("cursor", "default");
          $("body").css("opacity", "1");
          $("button").attr("disabled", false);
}//End of valid form
else {console.log("Not OK")};
};


function removeItemFromList(docId, list, item, index, topConceptId){
    if (confirm('Are you sure you want to delete this term?')) {
    $("body").css("cursor", "wait");
      $("body").css("opacity", "0.5");
      $("button").attr("disabled", true);
    var xmlData = "<xml>"
                    + "<docId>" + docId + "</docId>"
                    + "<index>" + index + "</index>"
                    + "<list>" + list + "</list>"
                    + "<item>" + item + "</item>"
                    + "<topConceptId>" + topConceptId + "</topConceptId>"
                    +"</xml>";
                    
    var listDivId = "#" + list + "List"
    var request = new XMLHttpRequest();
    console.log("xmldata in remove: " + xmlData);
    request.open("POST", "$ausohnum-lib/modules/teiEditor/getFunctions.xql?type=removeItemFromList" , true);
    console.log("xmldata: " + xmlData);
    var xmlDoc;
    request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
        
/*            var el = document.getElementById(inputName.name.toString());*/
             xmlDoc = request.responseText;
             xmlDocXML = request.responseXML;
             console.log("data in response: " + xmlDoc);
              newList= (new XMLSerializer()).serializeToString(xmlDocXML.getElementsByTagName('newList')[0]);
                if(xmlDocXML.getElementsByTagName('newListForAnnotation')[0]){
                newListForAnnotation= (new XMLSerializer()).serializeToString(xmlDocXML.getElementsByTagName('newListForAnnotation')[0]);
                }
             
             console.log("listDivId: " + listDivId);
             if (list =="editionBiblio" || list =="secondaryBiblio") {
                    console.log("Here in biblio");
                    $(listDivId).html(xmlDoc.substring(5, xmlDoc.lastIndexOf('<')))}
             else if (list == "place" ) {
               
                    console.log("Here in place: " + newList);
/*                    $(".listOfPlaces").html(xmlDoc.substring(5, xmlDoc.lastIndexOf('<')))}*/
                    $(".listOfPlaces").html(newList);
                    $("#listOfPlaces").html(newListForAnnotation);
                    }
              else if (list == "people" ) {
/*                   console.log("Here in place: " + newList);*/
/*                    $(".listOfPlaces").html(xmlDoc.substring(5, xmlDoc.lastIndexOf('<')))}*/
                    $(".listOfPeople").html(newList);
                    $("#peopleList").html(newListForAnnotation);
                             if ( $( "#listOfMentionedNames" ).length ) {
                                    
                                    $("#listOfMentionedNames").html(
                                    (new XMLSerializer()).serializeToString(xmlDocXML.getElementsByTagName('newListForMentionedNames')[0])
                                    );
                                    
                                }
                    }
             else if (list =="editionBblio"){$('#editionBiblioList').html(newList);}
             else  {$("#" + list + "_group_" + "1").replaceWith(xmlDoc);
                        console.log("There in biblio");
                        };
             $("body").css("cursor", "default");
             $("body").css("opacity", "1");
             $("button").attr("disabled", false);
            }
        };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);
        // CP refresh after delete
        setTimeout(function(){
            window.location.reload(1);
         }, 500);
        
        } else{}
};

function addRepository(){
 event.preventDefault();
 if(($("#repositoryUri").val() !="")){
    $("body").css("cursor", "wait");
    $("body").css("opacity", "0.5");
    
    var request = new XMLHttpRequest();
    var xmlData="<xml>"
                                + "<docId>" + getCurrentdocId() + "</docId>"
                                + "<repositoryUri>" + $('#repositoryUri').val() + "</repositoryUri>"
                                + "<repositoryLabel>" + $('#repositoryLabel').val() + "</repositoryLabel>"
                                + "<townUri>" + $('#townUri').val() + "</townUri>"
                                + "<townLabel>" + $('#townLabel').val() + "</townLabel>"
                            +"</xml>";
        console.log("xmldata: " + xmlData);
        request.open("POST", "$ausohnum-lib/modules/teiEditor/getFunctions.xql?type=addRepository" , true);
        var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
        xmlDoc = request.responseText;
             xmlDocXml = request.responseXML;
             console.log(xmlDocXml);
        
        newFunctionList= (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('newFunctionList')[0]);
        
        $("#repositoryLookup").val("");
        $("#repositoryUri").val("")
        $("#repositoryLabel").val("");
        $("#townUri").val("");
        $("#townLabel").val("");
        $("#repositoryDetailsPreview").html("");
        $("#dialogAddRepository").modal('hide');
        xmlString = (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('newContent')[0]);
        //console.log("newContent: " + xmlString);
        refreshXmlFile(xmlString.substring(109).substring(0, xmlString.indexOf("</newContent>")-109));
        $("body").css("cursor", "default");
        $("body").css("opacity", "1");
}
            };

        request.setRequestHeader('Content-Type', 'text/xml');
        request.setRequestHeader('Cache-Control', 'no-cache');
        request.send(xmlData);
            } else {alert("Please a reverse bond type");}

};

function updateRepository(index){
 event.preventDefault();
    
 if(($("#repositoryUri").val() !="")){
    $("body").css("cursor", "wait");
    $("body").css("opacity", "0.5");
    
    var request = new XMLHttpRequest();
    var xmlData="<xml>"
                                + "<docId>" + getCurrentDocId() + "</docId>"
                                + "<repositoryUri>" + $('#repositoryUri').val() + "</repositoryUri>"
                                + "<repositoryLabel>" + $('#repositoryLabel').val() + "</repositoryLabel>"
                                + "<townUri>" + $('#townRepositoryUri').val() + "</townUri>"
                                + "<townLabel>" + $('#townRepositoryLabel').val() + "</townLabel>"
                                + "<index>" + index + "</index>"
                                
                            +"</xml>";
        console.log("xmldata: " + xmlData);
        request.open("POST", "$ausohnum-lib/modules/teiEditor/getFunctions.xql?type=updateRepository" , true);
        var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
        xmlDoc = request.responseText;
             xmlDocXml = request.responseXML;
             console.log(xmlDocXml);
        
        
        
        $("#repositoryLookup").val("");
        $("#repositoryUri").val("")
        $("#repositoryLabel").val("");
        $("#townRepositoryUri").val("");
        $("#townRepositoryLabel").val("");
        $("#repositoryDetailsPreview").html("");
        $("body").css("cursor", "default");
        $("body").css("opacity", "1");
        
        
        xmlString = (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('newContent')[0]);
        console.log("newContent: " + xmlString.substring(12).substring(0, xmlString.indexOf("</newContent>")-12));
        
        refreshXmlFile(xmlString.substring(12).substring(0, xmlString.indexOf("</newContent>")-12));
        newRepositoryDetails= (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('updatedElement')[0]);
        $("#repositoryDetails"+ index).replaceWith(newRepositoryDetails);
        
        closeDialog("dialogEditRepository" + index);
}
            };

        request.setRequestHeader('Content-Type', 'text/xml');
        request.setRequestHeader('Cache-Control', 'no-cache');
        request.send(xmlData);
            } else {alert("Please a reverse bond type");}

};

$( ".zoteroLookup" ).attr('autocomplete','off');
$( ".zoteroLookup" ).autocomplete({
        source: function( request, response ) {
                    var zoteroGroup = $("#zoteroGroupNo").text();
                    var elementId = $(this.element).prop("id");
                    var type = elementId.substr(elementId.lastIndexOf('Modal')+ 5);
                    
                    $.ajax({
                        url : 'https://api.zotero.org/groups/' + zoteroGroup + '/items?',
                        dataType : 'json',
                        data : {
                                    q: $('#zoteroLookupInputModal' + type).val(),
                                    qmode: "everything",
                                    sort: "date"
                                    //types: "place"
                                    },
                        
                        success : function(data){
                    
                    console.log("group: " +zoteroGroup);
                            console.log("sucess: " + JSON.stringify(data));
                            response(
                            $.map(
                                data, function(object){
                                    console.log(JSON.stringify(object.data));
                                       
                                       var creators = 'creators' in data && data.creators[0] || "nocreators"

                                       console.log("Creator: " + creators);
                                       
                                       if(creators !== "nocreators")
                                        {if(object.data.creators[0].lastName)
                                            {var author = object.data.creators[0].lastName}
                                            else if (object.data.creators[0].surname){var author = object.data.creators[0].surname}
                                        }
                                        else{var author =""}
                                       
                                       
                                       /*if(object.data['creators'])
                                        {if(object.data.creators[0].lastName)
                                            {var author = object.data.creators[0].lastName}
                                            else if (object.data.creators[0].surname){var author = object.data.creators[0].surname}
                                        }
                                        else{var author =""}
                                       */
                                       
                                       if(object.data.title!='') {var title = object.data.title}
            
            /*                           console.log("title: " + title);*/
            /*                           console.log("Author: " + author);*/
            /*                           console.log("ID: " + object.key);*/
                                            console.log("Fulldata de Zotero: " + JSON.stringify(object.data));
                                            console.log("OWLSAMEAS: " + JSON.stringify(object.data.relations["owl:sameAs"]));
                                              
                                       return {
                                                    label: author + "  " + object.data.date + ", " + title + ' (Zotero key: ' + object.key + ')',
                                                    author: author,
                                                    //author: object.data.creators[0].lastName,
                                                    date: object.data.date,
                                                    title: title,
                                                    //title: object.data.title,
                                                    value: object.key,
                                                    key: object.data.key,
                                                    fullData: object.data,
                                                    refType : type
                                                    };
                                        }));
            
                            },
                                error:function(){ 
                                console.log("Erreur");
                                }
                        });
        }, //End of Source
      minLength: 3,
      select: function( event, ui ) {
                                            console.log("refType: " + ui.item.refType); 
            var type = ui.item.refType;
            event.preventDefault();
            $('#zoteroLookupInputModal' + type).val(ui.item.label);


/*              $("#selectedBiblioAuthor").html("Author: " + ui.item.fullData.creator[0].firstName + " " + ui.item.fullData.creator[0].lastName);*/
              $("#selectedBiblioAuthor" + type).html("Author: " + ui.item.author);
              $("#selectedBiblioDate"+ type).html("Date: " + ui.item.fullData.date);
              $("#selectedBiblioTitle"+ type).append('Title: <em>' + ui.item.title + '</em>')
              $("#selectedBiblioUri"+ type).html("URI: " + ui.item.uri);
              $("#selectedBiblioId"+ type).html(ui.item.value);
              ;

            }
    } );





function lemmatizeWord(index){
    var no = index ;

    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + no ;
    xmlEditorArray[index] = ace.edit(xmlEditorName);
    var xmlEditorSession = xmlEditorArray[index].getSession();
    var selectedText= xmlEditorArray[index].getSelectedText();
    var standardizedForm = $("#lemmataForm").val();
    if(standardizedForm){var lemmata = ' lemmata="' + standardizedForm + '"'} else {var lemmata = ""}
    
        if (selectedText ){
            if(lemmata){
               
                xmlEditorSession.replace(xmlEditorArray[index].selection.getRange(),
                '<w' + lemmata + '>' + selectedText + '</w>');    
                }else {alert("Please enter a lemmata first");}
                
                
            } else {alert("Please select a portion of text to be annotated");}
};


/*
*******************
*      PEOPLE     *
*******************
*/
function createAndAddPerson(docId, index){
    var sex = $( "#personSex option:selected" ).val();
    var personalStatus = $("#selectDropDownc19291").attr('value');
    var personalRank = $("#selectDropDownc19297").attr('value');
    var personalCitizenship = $("#selectDropDownc19303").attr('value');
    var praenomen = $("#newPersonPraenomen").val();
    var nomen = $("#newPersonNomen").val();
    var cognomen = $("#newPersonCognomen").val();
    /*console.log("Sex: " + sex);
    console.log("praenomen: " + praenomen);
    */

    var request = new XMLHttpRequest();


     var xmlData = "<xml>"

                    + "<docId>" + docId + "</docId>"
                    + "<index>" + index + "</index>"
                    + "<sex>" + sex + "</sex>"
                    + "<personalStatus>" + personalStatus + "</personalStatus>"
                    + "<personalRank>" + personalRank + "</personalRank>"
                    + "<personalCitizenship>" + personalCitizenship + "</personalCitizenship>"
                    + '<persName xml:lang="lat" type="praenomen">' + praenomen + '</persName>'
                    + '<persName xml:lang="lat" type="nomen">' + nomen + "</persName>"
                    + '<persName xml:lang="lat" type="cognomen">' + cognomen + "</persName>"
                    +"</xml>";

/*     console.log("xmldata: " + xmlData);*/
/*     console.log("persName praenomen: " + '<persName xml:lang="lat" type="praenomen">' + praenomen + '</persName>');*/

/*     request.open("POST", "http://patrimonium.huma-num.fr/admin/save/document/addBiblio", true);*/
     request.open("POST", "/modules/teiEditor/getFunctions.xql?type=addPerson" , true);
/*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                //+ "&project=" + "patrimonium" + "&xpath=" + xpath
/*                , true);*/
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
/*            var el = document.getElementById(inputName.name.toString());*/
             xmlDoc = request.responseText;
            $('#dialogNewPerson').modal('hide');
            $('#peopleList').html(xmlDoc.substring(5, xmlDoc.lastIndexOf('<')))

             //$(idElementValue).html(el.options[el.selectedIndex].innerHTML + " (" + $(inputName).val().substring(1) + ")");

/*             $(idElementValue).html(newValue2Display);*/


             console.log("Response : Value of xmlDoc" + xmlDoc);
/*             console.log("Id of element" + idElementValue);*/


            }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);


};

function createAndAddPersonToDoc(docId){
    event.preventDefault();
    var sex = $("#sex_1_").text().trim();
    var sexUri = $("#sex_1_").val();
    
    var personalStatus = $("#selectDropDownc19291").attr('value');
    var personalRank = $("#selectDropDownc19297").attr('value');
    var personalCitizenship = $("#selectDropDownc19303").attr('value');
    var praenomen = $("#newPersonPraenomen").val();
    var nomen = $("#newPersonNomen").val();
    var cognomen = $("#newPersonCognomen").val();
    var standardizedNameEn =$("#newPersonStandardizedNameEn").val();
    var standardizedNameFr =$("#newPersonStandardizedNameFr").val();
    var translitteredName =$("#newPersonTranslitteredName").val();
    var role = $('#person2AddType').val();
    var owner = $('#person2AddOwner').val();
    var bondType = $('#person2AddBondType').val();
    
    /*console.log("Sex: " + sex);
    console.log("praenomen: " + praenomen);
    */

    var request = new XMLHttpRequest();


     var xmlData = "<xml>"

                    + "<docId>" + docId + "</docId>"
                    + "<sex>" + sex + "</sex>"
                    + "<personalStatus>" + personalStatus + "</personalStatus>"
                    + "<personalRank>" + personalRank + "</personalRank>"
                    + "<personalCitizenship>" + personalCitizenship + "</personalCitizenship>"
                    + '<persName xml:lang="lat" type="praenomen">' + praenomen + '</persName>'
                    + '<persName xml:lang="lat" type="nomen">' + nomen + "</persName>"
                    + '<persName xml:lang="lat" type="cognomen">' + cognomen + "</persName>"
                    + '<persName xml:lang="en">' + standardizedNameEn+ "</persName>"
                    + '<persName xml:lang="fr">' + standardizedNameFr+ "</persName>"
                    + '<persName xml:lang="egy-latn-x-st">' + translitteredName+ "</persName>"
                    + '<role>' + role + "</role>"
                    + '<bondType>' + bondType + '</bondType>'
                    + '<owner>' + owner + '</owner>'
                    +"</xml>";

     console.log("xmldata: " + xmlData);
/*     console.log("persName praenomen: " + '<persName xml:lang="lat" type="praenomen">' + praenomen + '</persName>');*/

/*     request.open("POST", "http://patrimonium.huma-num.fr/admin/save/document/addBiblio", true);*/
     request.open("POST", "$ausohnum-lib/modules/prosopoManager/getFunctions.xql?type=createPersonAndAddRefToDoc" , true);
/*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                //+ "&project=" + "patrimonium" + "&xpath=" + xpath
/*                , true);*/
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
        closeDialog("dialogAddPersonToDocument");
/*            var el = document.getElementById(inputName.name.toString());*/
             xmlDocXml = request.responseXML;
             newPeoplePanel= (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('updatedElement')[0]);
            
            $('#peoplePanel').replaceWith(newPeoplePanel)

             //$(idElementValue).html(el.options[el.selectedIndex].innerHTML + " (" + $(inputName).val().substring(1) + ")");

/*             $(idElementValue).html(newValue2Display);*/


             //console.log("Response : Value of xmlDoc" + xmlDoc);
/*             console.log("Id of element" + idElementValue);*/


            }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);


};

function addProjectPersonToDoc(){
    event.preventDefault();
    var peopleUri = $('#selectedPeopleUri').val();
    var docId = getCurrentDocId();
    var request = new XMLHttpRequest();

        if(peopleUri != ""){
$("body").css("cursor", "wait");
$("body").css("opacity", "0.5");

var xmlData="<xml>"
                    + "<docId>" + docId + "</docId>"
                    + "<peopleUri>" + peopleUri + "</peopleUri>"
                         
                +"</xml>";

/*     console.log("xmldata: " + xmlData);*/

/*     request.open("POST", "http://patrimonium.huma-num.fr/admin/save/document/addBiblio", true);*/
     request.open("POST", "$ausohnum-lib/modules/teiEditor/getFunctions.xql?type=addProjectPerson" , true);
/*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                //+ "&project=" + "patrimonium" + "&xpath=" + xpath
/*                , true);*/
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
/*            var el = document.getElementById(inputName.name.toString());*/
             xmlDoc = request.responseText;
             xmlDocXml = request.responseXML;
             console.log("xmlDoc: " + xmlDocXml);
            console.log(xmlDocXml.getElementsByTagName('newList')[0].getElementsByTagName( 'div' )[0].childNodes);
            newPeopleList= (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('newList')[0]);
            newPeopleListForAnnotation= (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('newListForAnnotation')[0]);
            $(".listOfPeople").html(newPeopleList);
            $("#peopleList").html(newPeopleListForAnnotation);
             /*$("#listOfPlacesOverview").html(xmlDocXml.getElementsByTagName('newList')[0].getElementsByTagName( 'div' )[0].childNodes);*/
                $("#projectPeopleDetailsPreview").html("");
              $("#dialogAddPeopleToDoc").modal("hide");
              $("#projectPeopleLookup").val("");
        $("body").css("cursor", "default");
        $("body").css("opacity", "1");
/*             console.log("Response : Value of xmlDoc" + xmlDoc);*/
/*             console.log("Id of element" + idElementValue);*/


            }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);
} else {alert("Please select a person first");}

};

function closeAddPersonToDocModal(){
    $("#projectPeopleLookup").val("");
    $("#selectedPeopleUri").val("");
    $("#dialogAddPeopleToDoc").modal('hide');
};


function openAddPersonToDocDialog(type, owner, bondType){
    $("#person2AddOwner").val(owner);
    $("#person2AddBondType").val(bondType);
    $("#person2AddType").val(type);
    openDialog("dialogAddPersonToDocument");

};


/*
******************************
*         PLACES             *
******************************
*/
function addPlaceToDoc(docId){
$("body").css("cursor", "wait");
$("body").css("opacity", "0.5");

    var placeUri = $('#newPlaceUri').val();
    
    var request = new XMLHttpRequest();


    var xmlData="<xml>"
                    + "<docId>" + docId + "</docId>"
                    + "<placeUri>" + placeUri + "</placeUri>"
                    
                +"</xml>";

/*     console.log("xmldata: " + xmlData);*/

/*     request.open("POST", "http://patrimonium.huma-num.fr/admin/save/document/addBiblio", true);*/
     request.open("POST", "$ausohnum-lib/modules/teiEditor/getFunctions.xql?type=addPlace" , true);
/*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                //+ "&project=" + "patrimonium" + "&xpath=" + xpath
/*                , true);*/
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
/*            var el = document.getElementById(inputName.name.toString());*/
             xmlDoc = request.responseText;
             xmlDocXml = request.responseXML;
             console.log("xmlDoc: " + xmlDocXml);
            console.log(xmlDocXml.getElementsByTagName('newList')[0].getElementsByTagName( 'div' )[0].childNodes);
            newPlacesList= (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('newList')[0]);
            newPlacesListForAnnotation= (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('newListForAnnotation')[0]);
            newPlaceId= xmlDocXml.getElementsByTagName('newUri')[0].childNodes[0].nodeValue;
            
            $(".listOfPlaces").html(newPlacesList);
            $("#listOfPlaces").html(newPlacesListForAnnotation);
             /*$("#listOfPlacesOverview").html(xmlDocXml.getElementsByTagName('newList')[0].getElementsByTagName( 'div' )[0].childNodes);*/
            $("#addPlaceButtonDocPlaces").toggleClass("hidden");
            $("#newPlaceTypeContainer").toggleClass("hidden");
        $("body").css("cursor", "default");
        $("body").css("opacity", "1");
        
/*             console.log("Response : Value of xmlDoc" + xmlDoc);*/
/*             console.log("Id of element" + idElementValue);*/
                var win = window.open(newPlaceUri , '_blank' );
                                    if (win) {
                                        //Browser has allowed it to be opened
                                        win.focus();
                                    } else {
                                        //Browser has blocked it
                                        alert('Please allow popups for this website');
                                    }

            }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);


};

function addProjectPlaceToDoc(docId){
    var placeUri = $('#newPlaceUri').val();
    var placeType =$("#newProjectPlaceTypeContainer").find("BUTTON").val();
    var request = new XMLHttpRequest();

        if(placeType != ""){
$("body").css("cursor", "wait");
$("body").css("opacity", "0.5");

var xmlData="<xml>"
                    + "<docId>" + docId + "</docId>"
                    + "<placeUri>" + placeUri + "</placeUri>"
                    + "<placeType>" + placeType + "</placeType>"        
                +"</xml>";

/*     console.log("xmldata: " + xmlData);

/*     request.open("POST", "http://patrimonium.huma-num.fr/admin/save/document/addBiblio", true);*/
     request.open("POST", "$ausohnum-lib/modules/teiEditor/getFunctions.xql?type=addProjectPlace" , true);
/*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                //+ "&project=" + "patrimonium" + "&xpath=" + xpath
/*                , true);*/
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
/*            var el = document.getElementById(inputName.name.toString());*/
             xmlDoc = request.responseText;
             xmlDocXml = request.responseXML;
             console.log("xmlDoc: " + xmlDocXml);
            console.log(xmlDocXml.getElementsByTagName('newList')[0].getElementsByTagName( 'div' )[0].childNodes);
            newPlacesList= (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('newList')[0]);
            newPlacesListForAnnotation= (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('newListForAnnotation')[0]);
            $(".listOfPlaces").html(newPlacesList);
            $("#listOfPlaces").html(newPlacesListForAnnotation);
             /*$("#listOfPlacesOverview").html(xmlDocXml.getElementsByTagName('newList')[0].getElementsByTagName( 'div' )[0].childNodes);*/
                $("#projectPlaceDetailsPreview").html("");
              $("#addProjectPlaceButtonDocPlaces").toggleClass("hidden");
              $("#newProjectPlaceTypeContainer").toggleClass("hidden");
              $("#projectPlacesLookUp").val("");
        $("body").css("cursor", "default");
        $("body").css("opacity", "1");
/*             console.log("Response : Value of xmlDoc" + xmlDoc);*/
/*             console.log("Id of element" + idElementValue);*/


            }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);
} else {alert("Please select a type of relation with the document");}

};

/*
******************************
*    TEXT EDITOR FUNCTIONS   *
******************************
*/

function activeEditorSession(){
    var index = $("#currentEditorIndexVariable").text();
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + index ;
    xmlEditorArray[index] = ace.edit(xmlEditorName);
    var xmlEditorSession = xmlEditorArray[index].getSession();
    return xmlEditorSession;
};
function currentEditorIndex(){
    var index = parseInt($("#currentEditorIndexVariable").text());
    
    return index;
};

/*Resizable pane*/
/*$( function() {
    $( "#editorPanel" ).resizable({
      maxHeight: 250,
      maxWidth: 350,
      minHeight: 150,
      minWidth: 200
    });
    });
*/
/*
*****************
*   Epigraphy   *
*****************
*/

function checkXml(editor, cursorPosition){
            var cursorPosition =ace.edit(editor).selection.getCursor();
             var selectedText = ace.edit(editor).getSelectedText();
            var Range = require('ace/range').Range,
            frontRange = new Range(0,0, ace.edit(editor).selection.getRange().start.row,ace.edit(editor).selection.getRange().start.column);
            frontText = ace.edit(editor).getSession().doc.getTextRange(frontRange);
            backRange = new Range(ace.edit(editor).selection.getRange().end.row, 
                                                     ace.edit(editor).selection.getRange().end.column,
                                                     ace.edit(editor).getSession().doc.getLength(),
                                                     ace.edit(editor).getSession().doc.getLine(ace.edit(editor).getSession().doc.getLength()).length
                                                     );
            backText = ace.edit(editor).getSession().doc.getTextRange(backRange);
            
            openingPointedBracketinLeft = frontText.lastIndexOf("<");
            closingPointedBracketinLeft = frontText.lastIndexOf(">");
            openingPointedBracketinRight = frontText.indexOf("<");
            closingPointedBracketinRight = frontText.lastIndexOf(">");
            
            console.log("frontText: " + frontText);
            console.log("backText: " + backText);
            console.log("openingPointedBracketinLeft: " + openingPointedBracketinLeft + "; closingPointedBracketinLeft: " + closingPointedBracketinLeft);
            console.log("openingPointedBracketinRight: " + openingPointedBracketinRight + "; closingPointedBracketinRight: " + closingPointedBracketinRight);
            if(openingPointedBracketinLeft > closingPointedBracketinLeft){
                alert("Error: you cannot insert an XML element inside another XML element");
                exit;
            };
            /*if(closingPointedBracketinRight < openingPointedBracketinRight){
                alert("Position of the cursor is not suitable for XML marking up");
                exit;
            };*/

    try { xmlDoc = $.parseXML("<root>" + selectedText + "</root>"); //is valid XML
            
            return true;
            
            
        } catch (err) {
                  // was not XML
                  alert("Selection is not XML compliant:\n" 
                  + selectedText);
                  exit;
                  }    
}

function insertLb(index, lineNo, inWord){
    var no = index ;
    console.log("indexNo: " + index);
        console.log("no: " + no);
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + no ;
    checkXml(xmlEditorName);
    xmlEditorArray[index] = ace.edit(xmlEditorName);
    var breakNo = "";
   if(inWord ==="no"){breakNo =' break="no"'}
   /*var xmlEditorSession = xmlEditorArray[index].getSession();
     activeEditorSession().replace(xmlEditorArray[index].selection.getRange(), '<lb n="' + no + '"/>'); 
   */ 
    var xmlEditorSession = xmlEditorArray[index].getSession();
    xmlEditorSession.replace(xmlEditorArray[index].selection.getRange(), '<lb n="' + lineNo + '"' + breakNo + '/>');
     };
function insertCb(index, colNo, inWord){
    var breakNo = "";
    if(inWord ==="no"){breakNo =' break="no"'}
    var no = index ;
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + index ;
    xmlEditorArray[index] = ace.edit(xmlEditorName);
    var xmlEditorSession = xmlEditorArray[index].getSession();
    xmlEditorSession.replace(xmlEditorArray[index].selection.getRange(), '<cb n="' + colNo + '"' + breakNo +'/>');
     };


function insertGap(index, reason, extent, unit, option){

    var no = index ;
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + no ;
    console.log("No: " + no + "Index= " + index);
    if( unit != "") {var unitAttrib= ' unit="' + unit + '"'} else {var unitAttrib = ""}
    if(extent=="unknown") {var extentAttrib= ' extent="' + extent + '"'} 
                else if(extent=="range"){extentAttrib = ' atLeast="5" atMost="7"'} 
                else {extentAttrib = ' quantity="' + extent + '"'};
    var certAttrib = "";
    var quantity= "";
    if(option === "low") {certAttrib = ' precision="low"'};
    
    xmlEditorArray[index] = ace.edit(xmlEditorName);

    var xmlEditorSession = xmlEditorArray[index].getSession();

      xmlEditorSession.replace(xmlEditorArray[index].selection.getRange(), 
      '<gap reason="' + reason + '"' + extentAttrib + unitAttrib + certAttrib + '/>');

        };

function supplied(index, reason, certainty){
    console.log("SUPPLIED");
    var no = index ;
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + no ;
    checkXml(xmlEditorName);
    xmlEditorArray[index] = ace.edit(xmlEditorName);
    console.log("Range: " + xmlEditorArray[index].selection.getRange());
    
    var xmlEditorSession = xmlEditorArray[index].getSession();
    var selectedText = xmlEditorArray[index].getSelectedText();
    
    try { xmlDoc = $.parseXML("<root>" + selectedText + "</root>"); //is valid XML
            var certAttrib ="";
                if(certainty==="low"){ certAttrib = ' cert="low"'};
                xmlEditorSession.replace(xmlEditorArray[index].selection.getRange(), '<supplied reason="'+ reason + '"' + certAttrib + '>' + selectedText + "</supplied>");
        } catch (err) {
                  // was not XML
                  alert("Selection is not XML compliant:\n" 
                  + selectedText);
                  }    
        };


function surplus(index){

var no = index ;
//console.log("Surplus no = " + index);
    
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + no ;
    
    xmlEditorArray[index] = ace.edit(xmlEditorName);
    var selectedText = xmlEditorArray[index].getSelectedText();
    
    checkXml(xmlEditorName);

    var xmlEditorSession = xmlEditorArray[index].getSession();

           

      xmlEditorSession.replace(xmlEditorArray[index].selection.getRange(), '<surplus>' + selectedText + "</surplus>");

        };

function corr(index){
var no = index ;
//console.log("Surplus no = " + index);
    
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + no ;
    checkXml(xmlEditorName);
    xmlEditorArray[index] = ace.edit(xmlEditorName);
    var selectedText = xmlEditorArray[index].getSelectedText();
   
   var sic = prompt("Enter letters as on the stone");
   if(sic === null) {exit;}
   var corr = prompt("Enter correction", selectedText);
    if(corr === null) {exit;}
    var xmlEditorSession = xmlEditorArray[index].getSession();


      xmlEditorSession.replace(xmlEditorArray[index].selection.getRange(), '<choice><corr>' + corr 
                                        + "</corr><sic>" + sic + "</sic></choice>");

        };

function abbrev(index, certainty){
var no = index ;
//console.log("Surplus no = " + index);
    
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + no ;
    checkXml(xmlEditorName);
    xmlEditorArray[index] = ace.edit(xmlEditorName);
    var selectedText = xmlEditorArray[index].getSelectedText();
   var certAttrib = "";
   if(certainty==="low"){ certAttrib = ' cert="low"'};
   var abbr = prompt("Enter abbreviation");
     if(abbr === null) {exit;}
   var ex = prompt("Enter development");
     if(ex=== null) {exit;}
    var xmlEditorSession = xmlEditorArray[index].getSession();


      xmlEditorSession.replace(xmlEditorArray[index].selection.getRange(), '<expan><abbr>' + abbr 
                                        + "</abbr><ex" + certAttrib +">" + ex + "</ex></expan>");

        };

function insertComplexAbbrev(index, abbrev){
var no = index ;
//console.log("Surplus no = " + index);
    
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + no ;
    checkXml(xmlEditorName);
    
    xmlEditorArray[index] = ace.edit(xmlEditorName);
    var selectedText = xmlEditorArray[index].getSelectedText();
    var xmlEditorSession = xmlEditorArray[index].getSession();
    var xml;
   switch (abbrev) {
         case 'consul':
             xml = '<expan><abbr>co</abbr><ex>n</ex><abbr>s</abbr><ex>ul</ex></expan>';
           break;
         case 'proconsul':
            xml = '<expan><abbr>proco</abbr><ex>n</ex><abbr>s</abbr><ex>ul</ex></expan>';
           break;
         case 'cohors':
            xml = '<expan><abbr>c</abbr><ex>o</ex><abbr>ho</abbr><ex>rs</ex></expan>';
         default:
           xml = '<expan><abbr></abbr><ex></ex><abbr></abbr><ex></ex></expan>'
       }
   
   
   
      xmlEditorSession.replace(xmlEditorArray[index].selection.getRange(), xml);

        };
        
function abbrevShort(index){
var no = index ;
//console.log("Surplus no = " + index);
    
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + no ;
    checkXml(xmlEditorName);
    
    xmlEditorArray[index] = ace.edit(xmlEditorName);
    var selectedText = xmlEditorArray[index].getSelectedText();
   
    var xmlEditorSession = xmlEditorArray[index].getSession();


      xmlEditorSession.replace(xmlEditorArray[index].selection.getRange(), '<abbr>' + selectedText
                                        + "</abbr>");

        };
function abbrevIncomplete(index){
var no = index ;
//console.log("Surplus no = " + index);
    
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + no ;
    checkXml(xmlEditorName);
    xmlEditorArray[index] = ace.edit(xmlEditorName);
    var selectedText = xmlEditorArray[index].getSelectedText();
   
   var expan = prompt("Enter abbreviation");
   if(axpan === null) {exit;}
   var ex = prompt("Enter development");
    if(ex === null) {exit;}
    var xmlEditorSession = xmlEditorArray[index].getSession();


      xmlEditorSession.replace(xmlEditorArray[index].selection.getRange(), '<w par="I"><expan>' + expan 
                                        + "<ex>" + ex + "</ex></expan></w>");

        };

function abbrevSymbol(index){
var no = index ;
//console.log("Surplus no = " + index);
    
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + no ;
    checkXml(xmlEditorName);
    xmlEditorArray[index] = ace.edit(xmlEditorName);
    var selectedText = xmlEditorArray[index].getSelectedText();
   /*var abbr = prompt("Enter symbol");
     if(abbr === null) {exit;}
   */
    var xmlEditorSession = xmlEditorArray[index].getSession();


      xmlEditorSession.replace(xmlEditorArray[index].selection.getRange(), '<expan><ex>' + selectedText + "</ex></expan>");

        };
        
function unclear(index){

    var no = index ;
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + no ;
    checkXml(xmlEditorName);
    xmlEditorArray[index] = ace.edit(xmlEditorName);

    var xmlEditorSession = xmlEditorArray[index].getSession();

      xmlEditorSession.replace(xmlEditorArray[index].selection.getRange(), '<unclear>' + xmlEditorArray[index].getSelectedText() + "</unclear>");

        };


function apex(index){

    var no = index ;
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + no ;
    checkXml(xmlEditorName);
    xmlEditorArray[index] = ace.edit(xmlEditorName);

    var xmlEditorSession = xmlEditorArray[index].getSession();

      xmlEditorSession.replace(xmlEditorArray[index].selection.getRange(), '<hi rend="apex">' + xmlEditorArray[index].getSelectedText() + "</hi>");

        };

function supraline(index){

    var no = index ;
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + no ;
    checkXml(xmlEditorName);
    xmlEditorArray[index] = ace.edit(xmlEditorName);

    var xmlEditorSession = xmlEditorArray[index].getSession();

      xmlEditorSession.replace(xmlEditorArray[index].selection.getRange(), '<hi rend="supraline">' + xmlEditorArray[index].getSelectedText() + "</hi>");

        };

function intraline(index){

    var no = index ;
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + no ;
    checkXml(xmlEditorName);
    xmlEditorArray[index] = ace.edit(xmlEditorName);

    var xmlEditorSession = xmlEditorArray[index].getSession();

      xmlEditorSession.replace(xmlEditorArray[index].selection.getRange(), '<hi rend="intraline">' + xmlEditorArray[index].getSelectedText() + "</hi>");

        };

function ligature(index){

    var no = index ;
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + no ;
    checkXml(xmlEditorName);
    xmlEditorArray[index] = ace.edit(xmlEditorName);

    var xmlEditorSession = xmlEditorArray[index].getSession();

      xmlEditorSession.replace(xmlEditorArray[index].selection.getRange(), '<hi rend="ligature">' + xmlEditorArray[index].getSelectedText() + "</hi>");

        };


function erasure(index){

    var no = index ;
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + no ;
    checkXml(xmlEditorName);
    xmlEditorArray[index] = ace.edit(xmlEditorName);

    var xmlEditorSession = xmlEditorArray[index].getSession();

      xmlEditorSession.replace(xmlEditorArray[index].selection.getRange(), '<del rend="erasure">' + xmlEditorArray[index].getSelectedText() + "</del>");

        };

function add_above(index){

    var no = index ;
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + no ;
    checkXml(xmlEditorName);
    xmlEditorArray[index] = ace.edit(xmlEditorName);

    var xmlEditorSession = xmlEditorArray[index].getSession();

      xmlEditorSession.replace(xmlEditorArray[index].selection.getRange(), '<add place="above">' + xmlEditorArray[index].getSelectedText() + "</add>");

        };
function vacat(index, unit, no){

    var noEditor = index ;
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + noEditor;
    checkXml(xmlEditorName);
    xmlEditorArray[index] = ace.edit(xmlEditorName);

    var xmlEditorSession = xmlEditorArray[index].getSession();

    if(no==0) {var extentAttrib= ' extent="unknown"'} 
                   else {extentAttrib = ' quantity="' + no + '"'};
    

    xmlEditorSession.replace(xmlEditorArray[index].selection.getRange(), '<space' + extentAttrib + ' unit="' + unit +'"/>');
    };


function add_below(index){

    var no = index ;
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + no;
    checkXml(xmlEditorName);
    xmlEditorArray[index] = ace.edit(xmlEditorName);

    var xmlEditorSession = xmlEditorArray[index].getSession();

    xmlEditorSession.replace(xmlEditorArray[index].selection.getRange(), '<add place="below">' + xmlEditorArray[index].getSelectedText() + "</add>");
    };

function insertChiRho(index){

    var no = index ;
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + no;
    checkXml(xmlEditorName);
    xmlEditorArray[index] = ace.edit(xmlEditorName);

    var xmlEditorSession = xmlEditorArray[index].getSession();

    xmlEditorSession.replace(xmlEditorArray[index].selection.getRange(), '<g type="chi-rho">☧</g>');
    };

function illegible(index, unit, extent){

    var no = index ;
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + no;
    checkXml(xmlEditorName);
    xmlEditorArray[index] = ace.edit(xmlEditorName);
    if(extent === "unknown"){quantity = ' extent="unknown" '} 
    else {quantity = ' quantity="' + extent + '" '}
    var xmlEditorSession = xmlEditorArray[index].getSession();

      xmlEditorSession.replace(xmlEditorArray[index].selection.getRange(),
        '<gap reason="illegible"' + quantity + 'unit="' + unit +'"/>');

        };

function romanNumber(index, no){

    var noEditor = index ;
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + noEditor;
    checkXml(xmlEditorName);
    xmlEditorArray[index] = ace.edit(xmlEditorName);
    var selectedText = xmlEditorArray[index].getSelectedText();
    if(no === "convert" && selectedText ===""){
        alert("Please select a roman number in the text.");
        return false;
    };
    if(selectedText !==""){ 
        var arabicNum = romanToArabic(selectedText);
        var romanNum = selectedText;}
            else {arabicNum = no;
                    romanNum = convertToRoman(no);};
            
    var xmlEditorSession = xmlEditorArray[index].getSession();

    xmlEditorSession.replace(xmlEditorArray[index].selection.getRange(), '<num value="' + arabicNum + '">' + romanNum + "</num>");
    };

function vacat_line(index, no){
    var no = index ;
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + no;
    checkXml(xmlEditorName);
    xmlEditorArray[index] = ace.edit(xmlEditorName);

    var xmlEditorSession = xmlEditorArray[index].getSession();

    xmlEditorSession.replace(xmlEditorArray[index].selection.getRange(), '<space extent="' + no + '" unit="line"/>');
    };
    
    
function insertHedera(index){
    var no = index ;
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + no;
    checkXml(xmlEditorName);
    xmlEditorArray[index] = ace.edit(xmlEditorName);

    var xmlEditorSession = xmlEditorArray[index].getSession();

    xmlEditorSession.replace(xmlEditorArray[index].selection.getRange(), '<g type="hedera">❦</g>');
    };
function insertInterpunct(index){
    var no = index ;
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + no;
    checkXml(xmlEditorName);
    xmlEditorArray[index] = ace.edit(xmlEditorName);

    var xmlEditorSession = xmlEditorArray[index].getSession();

    xmlEditorSession.replace(xmlEditorArray[index].selection.getRange(), '<g type="interpunct">▴</g>');
    };    
function insertDenarius(index){
    var no = index ;
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + no;
    checkXml(xmlEditorName);
    xmlEditorArray[index] = ace.edit(xmlEditorName);

    var xmlEditorSession = xmlEditorArray[index].getSession();

    xmlEditorSession.replace(xmlEditorArray[index].selection.getRange(), '<g type="denarius">Ӿ</g>');
    };    

function insertAbbrev(index){
    var no = index ;
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + no;
    checkXml(xmlEditorName);
    xmlEditorArray[index] = ace.edit(xmlEditorName);

    var xmlEditorSession = xmlEditorArray[index].getSession();

    xmlEditorSession.replace(xmlEditorArray[index].selection.getRange(), '<expan><abbr></abbr><ex></e<></expan>');
    };    


function insertNote(index, noteContent){

    var no = index ;
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + no;
    checkXml(xmlEditorName);
    xmlEditorArray[index] = ace.edit(xmlEditorName);

    var xmlEditorSession = xmlEditorArray[index].getSession();
    
   /* var position = xmlEditorArray[index].selection.getRange()
    alert(position);
    
    var selectedText= xmlEditorArray[index].getSelectedText();

    if (selectedText ){
        try {*/
            xmlEditorSession.replace(xmlEditorArray[index].selection.getRange(), '<note>' + noteContent +'</note>');
    /*         } catch (err) {
                  // was not XML
                  alert("Selection is not XML compliant:\n" 
                  + XMLTextSelection);
                  }
            } else {alert("Please select a portion of text to be annotated");}     
    */
    };


/*
*****************
*    Semantic   *
*****************
*/
function pasteSelectedText(index, target){
     var no = currentEditorIndex() +1 ;
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + no ;
    xmlEditorArray[no] = ace.edit(xmlEditorName);

    var xmlEditorSession = xmlEditorArray[no].getSession();
    var selectedText= xmlEditorArray[no].getSelectedText();
    if (selectedText ){
    $("#" + target).val(selectedText);
    } else {alert("Please select a portion of text");}
};


function addPlace(index, key, ref){
    var no = currentEditorIndex() + 1 ;
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + no ;
    xmlEditorArray[index] = ace.edit(xmlEditorName);

    var xmlEditorSession = xmlEditorArray[index].getSession();
    var selectedText= xmlEditorArray[index].getSelectedText();

    if (selectedText ){

            checkXml(xmlEditorName);
                    xmlEditorSession.replace(xmlEditorArray[index].selection.getRange(),
            '<placeName ref="' + ref + '"' 
            //+'key="' + key + '"'
            + '>' +xmlEditorArray[index].getSelectedText() + '</placeName>');
                  
            } else {alert("Please select a portion of text to be annotated");}
    };

function addPeople(index, ref){
    var no = currentEditorIndex() + 1 ;
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + no ;
    xmlEditorArray[index] = ace.edit(xmlEditorName);
    $("#" + xmlEditorName).focus;
    var xmlEditorSession = xmlEditorArray[index].getSession();
    var selectedText= xmlEditorArray[index].getSelectedText();

    if (selectedText ){

            checkXml(xmlEditorName);
            xmlEditorSession.replace(xmlEditorArray[index].selection.getRange($("#rangeVariable").val()),
            '<rs type="person" ref="' + ref + '">' + xmlEditorArray[index].getSelectedText() + '</rs>');
            
            } else {alert("Please select a portion of text to be annotated");}

    };

function addReferenceString(index, type, input, pos){
    var no = currentEditorIndex() + 1 ;
    var refId = "#" + input + "_" + index + "_" + pos ;
    var refValue = $(refId).attr('value');
    var keyValue = $(refId).text().trim().toLowerCase();
    
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + no ;
    xmlEditorArray[index] = ace.edit(xmlEditorName);

    var xmlEditorSession = xmlEditorArray[index].getSession();
    var selectedText= xmlEditorArray[index].getSelectedText();

    if (refValue ){

        if (selectedText ){
                checkXml(xmlEditorName);
                xmlEditorSession.replace(xmlEditorArray[index].selection.getRange(),
                        '<rs type="'+ type + '" key="' + keyValue + '" ref="' + refValue + '">' + selectedText + '</rs>');
            } else {alert("Please select a portion of text to be annotated");}
        }
            else{alert("Please select a " + type + " first");}
    };
    
    
function addPlaceRefToText(){
    
    var no = currentEditorIndex()+1;

    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + no ;
    xmlEditorArray[no] = ace.edit(xmlEditorName);
    var xmlEditorSession = xmlEditorArray[no].getSession();
    var selectedText= xmlEditorArray[no].getSelectedText();
    var placeNameRef = $( "#placeList option:selected" ).val();
    var placeNameKey =$( "#placeList option:selected" ).text().trim();
    if (selectedText ){
            checkXml(xmlEditorName);
                xmlEditorSession.replace(xmlEditorArray[no].selection.getRange(),
                '<placeName ref="'+ placeNameRef + '" key="' + placeNameKey + '">' + selectedText + '</placeName>');
            } else {alert("Please select a portion of text to be annotated");}
    };

function addPersName(index, type){
    var no = currentEditorIndex() + 1 ;
        console.log("I'm here!" + no);
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + (no) ;
    xmlEditorArray[no] = ace.edit(xmlEditorName);
    var xmlEditorSession = xmlEditorArray[no].getSession();
    var selectedText= xmlEditorArray[no].getSelectedText();
    var persNameType = $('#persNameType').find("button").text().trim().toLowerCase();
    if(persNameType != "select an item"){ var persNameTypeAttrib = ' type="' + persNameType + '"' }
                else {var persNameTypeAttrib = ""}
    
    if(type){var typeAttrib = 'type="' + type + '"'}
            else {var typeAttrib = ""}
        if (selectedText ){
         checkXml(xmlEditorName);
         xmlEditorSession.replace(xmlEditorArray[no].selection.getRange(),
                '<persName'+ persNameTypeAttrib + '>' + selectedText + '</persName>');
         
            } else {alert("Please select a portion of text to be annotated");}
    };

function addName(index, type){
    var no = currentEditorIndex() + 1 ;
    console.log("currentEditorIndex: " + currentEditorIndex())
    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + no ;
    xmlEditorArray[no] = ace.edit(xmlEditorName);
    var xmlEditorSession = xmlEditorArray[no].getSession();
    var selectedText= xmlEditorArray[no].getSelectedText();
    var standardizedForm = $("#standardizedForm").val();
    if(standardizedForm){var nymRef = ' nymRef="' + standardizedForm + '"'} else {var nymRef= ""}
    switch(type){
                      case "name":
                        var nameType = "";
                     break;
                     case "praenomen":
                     case "nomen":
                     case "cognomen":
                        var nameType = ' type="' + type + '"';
                     break;
                     default:
                        var nameType = "";
                     break;
      }
    
        if (selectedText ){
                
                checkXml(xmlEditorName);                       
                xmlEditorSession.replace(xmlEditorArray[no].selection.getRange(),
                '<name' + nymRef + nameType + '>' + selectedText + '</name>');    
                        
                
            } else {alert("Please select a portion of text to be annotated");}
}


function lemmatizeWord(index){
    var no = index ;

    var xmlEditorArray = [];
    var xmlEditorName = "xml-editor-" + no ;
    xmlEditorArray[index] = ace.edit(xmlEditorName);
    var xmlEditorSession = xmlEditorArray[index].getSession();
    var selectedText= xmlEditorArray[index].getSelectedText();
    var standardizedForm = $("#lemmataForm").val();
    if(standardizedForm){var lemmata = ' lemmata="' + standardizedForm + '"'} else {var lemmata = ""}
    
        if (selectedText ){
            if(lemmata){
              checkXml(xmlEditorName);
              xmlEditorSession.replace(xmlEditorArray[index].selection.getRange(),
                '<w' + lemmata + '>' + selectedText + '</w>');
                }else {alert("Please enter a lemmata first");}
                
                
            } else {alert("Please select a portion of text to be annotated");}
};



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






function getTextFromEditor() {
              var text =  editor.getValue();
                   console.log("Le texte est: " + text.toString());
/*                   text.toString();*/

/*            return text;*/

};



/*function insertSupplied(){
/\* document.getElementById("suppliedForm").submit(
            function(){*\/

            var selectedText = editor.getSelectedText();
            var reason = $('input[name="optreason"]:checked').val();
            var evidence = $('input[name="optevidence"]:checked').val();
            var certainty= $('input[name="optcertainty"]:checked').val();
            var text = $('input[name="text"]').val();
            var responsable = $('input[name="responsable"]').val();

            $('#dialogSupplied').modal('hide');

            if(evidence != ""){evidenceAtt = ' evidence="' + evidence +'"'} else {""};
            if(certainty != ""){certaintyAtt = ' cert="' + certainty +'"'} else {""};
           // if(certainty != null){certaintyAtt = 'cert="' + certainty +'"'} else{""}
            var text2BeInserted = "<supplied" + reason + evidenceAtt + certaintyAtt +">"
                            + editor.getSelectedText() + "</supplied>"

            console.log("text inséré = " + text2BeInserted);
            editor.session.replace(editor.selection.getRange(), text2BeInserted);
           //});
          };*/

/*function addProvenance(){
    var uri = $('#nameLookupInputModal').val();
    $('#dialogProvenance').modal('hide');
    $('#provenanceInput-value').val(uri);

}*/



function getObjects(obj, key, val) {
        var objects = [];
        for (var i in obj) {
            if (!obj.hasOwnProperty(i)) continue;
            if (typeof obj[i] == 'object') {
                objects = objects.concat(getObjects(obj[i], key, val));
            } else
            //if key matches and value matches or if key matches and value is not passed (eliminating the case where key matches but passed value does not)
            if (i == key && obj[i] == val || i == key && val == '') { //
                objects.push(obj);
            } else if (obj[i] == val && key == ''){
                //only add if the object is not already in the array
                if (objects.lastIndexOf(obj) == -1){
                    objects.push(obj);
                }
            }
        }
        return objects;
    };

function getData() {
                    if (xmlRequest.readyState == 4 && xmlRequest.status == 200) {
                    try {
                    var result = document.getElementsByTagName("result");

                    console.log("result de la request: " + result);
                        //resultAsTrg = new WText(result.toString, Wt::PlainText);
                          //  console.log("result as text: " + WText);



                    var response = '';
                    $.ajax({ type: "GET",
                             url: "/$ausohnum-lib/modules/get-text-from-document.xql",
                             async: false,
                             success : function(data)
                             {
                                 response = data;
                             }
                    });

                    var editor = ace.edit("editor");
                   // editor.getSession().setValue(response);


                    } catch (e) {
                    console.log(e.message);
                    }
                    }
                    };

function toggleFullScreen(elemId) {
    elem = document.getElementById(elemId);
    // ## The below if statement seems to work better ## if ((document.fullScreenElement && document.fullScreenElement !== null) || (document.msfullscreenElement && document.msfullscreenElement !== null) || (!document.mozFullScreen && !document.webkitIsFullScreen)) {
    if ((document.fullScreenElement !== undefined && document.fullScreenElement === null) || (document.msFullscreenElement !== undefined && document.msFullscreenElement === null) || (document.mozFullScreen !== undefined && !document.mozFullScreen) || (document.webkitIsFullScreen !== undefined && !document.webkitIsFullScreen)) {
        if (elem.requestFullScreen) {
            elem.requestFullScreen();
        } else if (elem.mozRequestFullScreen) {
            elem.mozRequestFullScreen();
        } else if (elem.webkitRequestFullScreen) {
            elem.webkitRequestFullScreen(Element.ALLOW_KEYBOARD_INPUT);
        } else if (elem.msRequestFullscreen) {
            elem.msRequestFullscreen();
        }
    } else {
        if (document.cancelFullScreen) {
            document.cancelFullScreen();
        } else if (document.mozCancelFullScreen) {
            document.mozCancelFullScreen();
        } else if (document.webkitCancelFullScreen) {
            document.webkitCancelFullScreen();
        } else if (document.msExitFullscreen) {
            document.msExitFullscreen();
        }
    }
};

$(document).ready(function() {

/*        console.log("check doc number: " + getCurrentDocId());*/
        document.title = getCurrentDocId() + " - " + $("#docMainTitle").text();
var importEditor = ace.edit("text2importInputEditor");
       $('.titleProjectHeader').hide();//hide the first part of header to get more space

       //var editor = ace.edit("editor");
            
        /*$('#pills-places-tab').click(function(){
        
        
/\*        var map = L.map('mapid');*\/
            console.log("click");
/\*            map.invalidateSize();*\/
        });
*/

        $('#importSource').change(function(){
                    
                var editorPreview = ace.edit("text2importXMLPreview");
                var importSource = $( "#importSource option:selected" ).val();

                editorPreview.getSession().setValue(
                convertAncientText(importEditor.getValue(), importSource));
          });

        $(".dropdown-menu li a").click(function(){
/*                console.log("menu: " + $(this).attr('menu'));*/
/*                console.log("v: " + $(this).attr('value'));*/
        /*        var menu = "#" + $(this).attr('id');*/
                var menu = $(this).attr('menu');
                 $(menu).html($(this).text()  + '<span class="caret"></span>');
                 $(menu).attr('value', $(this).attr('value'));
        
           });



        $("#callInsertBiblio").click(function(){
                $('#dialogInsertBiblio').modal('show');
             });

        $("#callPlaceName").click(function(){
                $('#dialogPlaceName').modal('show');
        });

$('#addBiblioForm').validate({
     rules: {
       zoteroLookupInputModal: {
         required: true,
         minlength: 1
       },
       
       highlight: function(element) {
         $(element).closest('.control-group').removeClass('success').addClass('error');
       },
       success: function(element) {
         element
           .text('OK!').addClass('valid')
           .closest('.control-group').removeClass('error').addClass('success');
           
           
       }
     }
   });
   
   $( "button[data-dismiss='modal']" ).click(function() {
  //Code to be executed when close is clicked
  $(this).closest('form').find("input[type=text], textarea").val("");
  $(".lookupSelectionPreview").html("");
});

/*$('#addBiblioForm').bootstrapValidator({
        // To use feedback icons, ensure that you use Bootstrap v3.1.0 or later
        feedbackIcons: {
            valid: 'glyphicon glyphicon-ok',
            invalid: 'glyphicon glyphicon-remove',
            validating: 'glyphicon glyphicon-refresh'
        },
        fields: {
            citedRange: {
                validators: {
                        stringLength: {
                        min: 2
                    },
                        notEmpty: {
                        message: 'Please supply a cited range'
                    }
                }
            }
             
            }
        })
        .on('success.form.bv', function(e) {
            $('#success_message').slideDown({ opacity: "show" }, "slow") // Do something ...
                $('#addBiblioForm').data('bootstrapValidator').resetForm();

            // Prevent form submission
            e.preventDefault();

            // Get the form instance
            var $form = $(e.target);

            // Get the BootstrapValidator instance
            var bv = $form.data('bootstrapValidator');

            // Use Ajax to submit form data
            $.post($form.attr('action'), $form.serialize(), function(result) {
                console.log(result);
            }, 'json');
        });
*/


 /*       var suplliedSubmission = $('#suppliedForm').validate(        { // initialize the plugin
            rules: {
                reason: "required"
                ,
                textInputModal: {
                    required: true
    
                }
            },
            messages: {
    					reason: "Please enter a reason"
    					},
    		submitHandler:
    		function() {
    		    var selectedText = editor.getSelectedText();
                var reason = $('input[name="optreason"]:checked').val();
                var evidence = $('input[name="optevidence"]:checked').val();
                var certainty= $('input[name="optcertainty"]:checked').val();
                var text = $('input[name="text"]').val();
                var responsable = $('input[name="responsable"]').val();
                console.log("ffrfrfrfrfrfrfrfrf");
                $('#dialogSupplied').modal('hide');
    
    
                if(evidence != ""){evidenceAtt = ' evidence="' + evidence +'"'} else {""};
                if(certainty != ""){certaintyAtt = ' cert="' + certainty +'"'} else {""};
                if(reason != ""){reason= ' reason="' + reason +'"'} else {""};
               // if(certainty != null){certaintyAtt = 'cert="' + certainty +'"'} else{""}
                var text2BeInserted = "<supplied" + reason + evidenceAtt + certaintyAtt +">"
                                + editor.getSelectedText() + "</supplied>"
    
                console.log("text qui va être inséré = " + text2BeInserted);
                editor.session.replace(editor.selection.getRange(), text2BeInserted);
    
    			}
    });*/

            /*var $formProvenance4validation = $('#provenanceForm').submit(function(e) {
                e.preventDefault();
            }).validate(
                    { // initialize the plugin
                    rules: {
            
                        nameLookupInputModal: {
                            required: true
            
                        }
                    },
                    messages: {
            					nameLookupInputModal: "No URI"
            					},
            		submitHandler:
            		function(form) {
            
            
                        var $URI = $('#nameLookupInputModal').val();
                        var $certainty= $('input[name="provCertainty"]:checked').val();
            
                        xmlData = "<data>"
                                    + "<uri>" + $('#nameLookupInputModal').val() + "</uri>"
                                    + "<certainty>" + $('input[name="provCertainty"]:checked').val() + "</certainty>"
                                  +"</data>"
            
                        $('#dialogProvenance').modal('hide');
            
                          var response = '';
            
                            $.ajax({
                                type: "POST",
                                url: "/modules/create-apc-place.xql",
                                dataType: "xml",
                                //contentType: "multipart/form-data",
                                 contentType: "text/xml",
                                 data: xmlData,
                                //data: "<data><uri>lala</uri></data>",
                                /\*data: {
                                    azerty: "deed",
                                    lelooe: "rfrf"
                                    },*\/
                                processData: true,
                                cache: false,
                                success : function(data)
                                {
                                    response = data;
                                    console.log("Données envoyées: " + data);
                                    console.log("Données traitées: " + response);
                                }
                            });
            
                        console.log("Formulaire Provenance alidé");
                        console.log($URI);
                        $('#provenanceInput-value').val($URI);
                        $('#provenancePlaceName').val(response.data);
                        return false;
            
            			}
                });*/


/*
            var textImportSubmission = $('#textImportForm').validate(        { // initialize the plugin
                    rules: {
                        //text2import: "required"
            
                    },
                    messages: {
                          //  text2import: "Please enter a text"
                            },
                   submitHandler:
            	function() {
            	console.log("Index: " + $('input[name="editorIndex"]').val());
            	                   var xmlEditorArray = [];
                                   var xmlEditorName = "xml-editor-" + $('input[name="editorIndex"]').val();
                                   xmlEditorArray[index] = ace.edit(xmlEditorName);
                    	           xmlPreviewEditor = ace.edit("text2importXMLPreview");
                    	           var text2import = xmlPreviewEditor.getValue();
                                   //console.log("Text import");
                                  $('#dialogTextTmport').modal('hide');
                                  //console.log("text qui va être inséré = " + text2import);
                                  xmlEditorArray[index].session.setValue(text2import);
            
                    	         }
                });*/
            
            
            /*    Disabling enter key in forms*/
                $("#provenaceForm").keypress(
                function(event){
                 if (event.which == '13') {
                    event.preventDefault();
                  }
            });




 $( ".pleiadesLookup" ).each(function(i, el) {
                el = $(el);
                lookUpId = el.attr("id");
                
            el.autocomplete({
                  source: 
                    function( request, response ) {
                    $.ajax({
                        url : 'https://peripleo.pelagios.org/peripleo/search?object_type=place',
                        dataType : 'json',
                        data : {
/*                            query: $('#placesLookupInputSemantic').val() + "*"*/
                            query: el.val() + "*"
                            
            
                        },
            
                        success : function(data){
                            response(
                            
                            $.map(
                                       
                                data.items, function(object){
                                       return {
                            
                                            label: object.title + ' (' + object.identifier + ')',
                                            prefLabel: object.title,
                                            value: object.identifier,
                                            fullObject: object
                                            };
                                            console.log("Object keys: " + Object.keys(object));
                                   }
                                )
                              );
                        },
                        error: console.log("Erreur")
                    });
            
                  },
                  minLength: 3,
                  select: function( event, ui ) {
                        event.preventDefault();
                        el.val(ui.item.label);
                        

                        var src = "https://peripleo.pelagios.org/embed/" + ui.item.value.replace(/\//g, '%2F');
                        console.log( "Pleaides - url: " + "https://peripleo.pelagios.org/embed/" + ui.item.value.replace(/\//g, '%2F'));
                         $("#" + lookUpId + "_peripleoWidget").show();
                        $("#" + lookUpId + "_peripleoWidget").attr("src", "https://peripleo.pelagios.org/embed/" + ui.item.value.replace(/\//g, '%2F'));
                         
                         try {
                            var geojsonFeature = {
                                    "type": "Feature",
                                    "properties": {
                                        "name": ui.item.prefLabel,
                                        "amenity": "",
                                        "popupContent": "This is where the Rockies play!"
                                    },
                                    "geometry": {
                                        "type": "Point",
                                        "coordinates": [ui.item.fullObject.geo_bounds.min_lon, ui.item.fullObject.geo_bounds.min_lat]
                                    }
                                };
                                document.getElementById('editorMap').innerHTML = "<div id='editorMap2' style='width: 100%; height: 100%;'></div>";
/*                                mymap.remove();*/
                                var mymap2 = L.map('editorMap2').setView([ui.item.fullObject.geo_bounds.min_lon, ui.item.fullObject.geo_bounds.min_lat], 4);
                                        L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoiaXNhd255dSIsImEiOiJBWEh1dUZZIn0.SiiexWxHHESIegSmW8wedQ', {
                                         attribution: 'Map data © <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>',
                                         maxZoom: 10,
                                        id: 'isawnyu.map-knmctlkh',
                                        accessToken: 'pk.eyJ1IjoiaXNhd255dSIsImEiOiJBWEh1dUZZIn0.SiiexWxHHESIegSmW8wedQ'
                                   }).addTo(mymap2); 
 
                                  console.log("Test places: " +getProjectPlacesGeoJSon());
                                
                                
                                L.geoJSON(geojsonFeature, {
                                onEachFeature: onEachFeature
                                    }).addTo(mymap2);
                                L.geoJSON(getProjectPlacesGeoJSon(), {
                                onEachFeature: onEachFeature
                                    }).addTo(mymap2);
                            console.log(ui.item.fullObject.geo_bounds.min_lon);
                          }
                          catch(error) {
                            console.error(error);
                            // expected output: ReferenceError: nonExistentFunction is not defined
                            // Note - error messages will vary depending on browser
                          };
                         
                          if ($('#addNewPlaceButton').hasClass('hidden') === true) {
                                $("#addNewPlaceButton").toggleClass("hidden");
                                $("#addProjectPlaceButtonDocPlaces").toggleClass("hidden");
                         
                            } else {
                                
                         };
                         
                         
                         
                         
                         
                         
                         
                         /*}else{
                             console.log("else");
                             
                         }*/
                           $("#prefLabelPlace").html( ui.item.prefLabel);
                         }
                         });
                } );



            $( "#placesLookupInputSemantic" ).autocomplete({
                  source: 
                    function( request, response ) {
                    $.ajax({
                        url : 'https://peripleo.pelagios.org/peripleo/search?object_type=place',
                        dataType : 'json',
                        data : {
/*                            query: $('#placesLookupInputSemantic').val() + "*"*/
                            query: $('#placesLookupInputSemantic').val() + "*"
                            
            
                        },
            
                        success : function(data){
                            response(
                            $.map(
                                data.items, function(object){
                                       return {
                                            label: object.title + ' (' + object.identifier + ')',
                                            prefLabel: object.title,
                                            value: object.identifier
                                            };
                                   }
                                )
                              );
                        },
                        error: console.log("Erreur")
                    });
            
                  },
                  minLength: 3,
                  select: function( event, ui ) {
                        event.preventDefault();
                        $('#placesLookupInputSemantic').val(ui.item.value);
            
/*                         Following IF commented as Peripleo can display data from any gazetteer*/
                         /*if (ui.item.value.indexOf('gazetteer.dainst.org') >= 0){
                               var src = ui.item.value;
                               var placeID = src.substring(src.lastIndexOf("/") + 1);
                               console.log("Place ID: " + placeID);
                               //var src = "http://patrimonium.huma-num.fr";
            /\*                        AJAX call for gazetteer.dai*\/
                                    $.ajax({
                                      url :  'https://gazetteer.dainst.org/doc/' + placeID +".json",
                                      dataType : 'json',
                                      contentType: "text/plain",
                                      success : function(data){
                                                     var labelFr = getObjects(data.names, "language", "eng");
                                                     var geocoordinates = JSON.stringify(data.prefLocation.coordinates);
                                                     var lat = geocoordinates.substring(geocoordinates.indexOf(',')+1, geocoordinates.length-1);
                                                     var long = geocoordinates.substring(1, geocoordinates.indexOf(','));
                                                     console.log("Geo: " + geocoordinates + "Lat: " + lat + "; long: " + long);
                                          $('#previewMap').removeClass("hide");
            
                                          var pMap = L.map('previewMap').setView([lat, long], 5);
            
                                          L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={accessToken}', {
                                            attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>',
                                            maxZoom: 18,
                                            id: 'mapbox.streets',
                                            accessToken: 'pk.eyJ1IjoidnJhemFuYWphbyIsImEiOiJjamI1MmxjNTQwYXM4MnJxZm1wYmhudTdhIn0.RekdrSgwL48OQflUOUxvfQ'
                                              }).addTo(pMap);
                                        var marker = L.marker([lat, long]).addTo(pMap);
                                      },
                                      error: console.log("Erreur")
                                  });
                              $("#peripleoWidget").hide();
/\*                               $("#placePreviewPanel").load(src);*\/
                               console.log( "Autre que Pleaiades - url: " +  ui.item.value);
                               
                         }else if(ui.item.value.indexOf('pleiades') >= 0)
                         {*/
                                var src = "https://peripleo.pelagios.org/embed/" + ui.item.value.replace(/\//g, '%2F');
                                console.log( "Pleaides - url: " + "https://peripleo.pelagios.org/embed/" + ui.item.value.replace(/\//g, '%2F'));
                                 $("#peripleoWidget").show();
                                $("#peripleoWidget").attr("src", "https://peripleo.pelagios.org/embed/" + ui.item.value.replace(/\//g, '%2F'));
                         
                          if ($('#addNewPlaceButton').hasClass('hidden') === true) {
                                $("#addNewPlaceButton").toggleClass("hidden");
                            } else {
                                
                         };
                         
                         
                         
                         
                         
                         
                         
                         
                         /*}else{
                             console.log("else");
                             
                         }*/
                           $("#prefLabelPlace").html( ui.item.prefLabel);
                         }
                } );



            $( "#placeNameLookupInputModal" ).autocomplete({
                  source: function( request, response ) {
                    $.ajax({
                        url : 'https://peripleo.pelagios.org/peripleo/search?object_type=place',
                        dataType : 'json',
                        data : {
                            query: $('#placeNameLookupInputModal').val(),
                            types: "place"
            
                        },
            
                        success : function(data){
                            response(
                            $.map(
                                data.items, function(object){
            
            
            
                                       return {
                                            label: object.title + ' (' + object.identifier + ')',
                                            prefLabel: object.title,
                                            value: object.identifier
                                            };
                                   }
                                )
                              );
                        },
                        error: console.log("Erreur")
                    });
            
                  },
                  minLength: 3,
                  select: function( event, ui ) {
                        event.preventDefault();
                        $('#nameLookupInputModal').val(ui.item.value);
            
                         if (ui.item.value.indexOf('gazetteer.dainst.org') >= 0){
                               var src = ui.item.value;
                               var placeID = src.substring(src.lastIndexOf("/") + 1);
                               console.log("Place ID: " + placeID);
                               //var src = "http://patrimonium.huma-num.fr";
            /*                        AJAX call for gazetteer.dai*/
                                    $.ajax({
                                      url :  'https://gazetteer.dainst.org/doc/' + placeID +".json",
                                      dataType : 'json',
                                      contentType: "text/plain",
                                      success : function(data){
            
                                                     var labelFr = getObjects(data.names, "language", "eng");
                                                     var geocoordinates = JSON.stringify(data.prefLocation.coordinates);
                                                     var lat = geocoordinates.substring(geocoordinates.indexOf(',')+1, geocoordinates.length-1);
                                                     var longitude = geocoordinates.substring(1, geocoordinates.indexOf(','));
                                                     console.log("Geo: " + geocoordinates + "Lat: " + lat + "; long: " + long);
                                          $('#previewMap').removeClass("hide");
            
                                          var pMap = L.map('previewMap').setView([lat, longitude], 5);
            
                                          L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={accessToken}', {
                                            attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>',
                                            maxZoom: 18,
                                            id: 'mapbox.streets',
                                            accessToken: 'pk.eyJ1IjoidnJhemFuYWphbyIsImEiOiJjamI1MmxjNTQwYXM4MnJxZm1wYmhudTdhIn0.RekdrSgwL48OQflUOUxvfQ'
                                        }).addTo(pMap);
                                        var marker = L.marker([lat, longitude]).addTo(pMap);
                                      },
                                      error: console.log("Erreur")
                                  });
                              $("#peripleoWidget").hide();
                               //$("#placePreviewPanel").load(src);
                               console.log( "Autre que Pleaiades - url: " +  ui.item.value);
                         }else if(ui.item.value.indexOf('pleiades') >= 0)
                         {
                                var src = "https://peripleo.pelagios.org/embed/" + ui.item.value.replace(/\//g, '%2F');
                                console.log( "Pleaides - url: " + "https://peripleo.pelagios.org/embed/" + ui.item.value.replace(/\//g, '%2F'));
                                $("#peripleoWidget").attr("src", "https://peripleo.pelagios.org/embed/" + ui.item.value.replace(/\//g, '%2F'));
                         }else{}
            
            
            
            
            
            
                          $("#prefLabelPlace").html( ui.item.prefLabel);
            
                        }
                } );


$( ".projectPeopleLookup" ).attr('autocomplete','on');
$( ".projectPeopleLookup" ).autocomplete({
        source: function( request, response ) {
                    console.log("Dans lookup");
                    var elementId = $(this.element).prop("id");
                    var type = elementId.substr(elementId.lastIndexOf('Modal')+ 5);
                    
                    $.ajax({
                        //url : 'geo/search-place/' 
                        url: '/people/search/'
                                //+$('#projectPlacesLookUp').val()
                                ,
                        dataType : 'json',
                        data : {
                                    'query': $('#projectPeopleLookup').val()
                                    //types: "place"
                                    },
                        success : function(data){
                            /*console.log("sucess: " + JSON.stringify(data));*/
                            response(
                                $.map(
                                    data.list.items, function(object){
                                    
                                       return {
                                                    
                                                    label: object.title + " " + object.identifier,
                                                    uri: object.identifier,
                                                    persname: object.title,
                                                    
                                                    //author: object.data.creators[0].lastName,
                                                    //date: object.data.date,
                                                    //title: title,
                                                    //title: object.data.title,
                                                    //value: object.key,
                                                   // key: object.data.key,
                                                    fullData: object
                                                    //refType : type
                                                    };
                                                   
                                        }));
            
                            },
                                error:function(){ 
                                console.log("Erreur");
                                }
                        });
        }, //End of Source
      minLength: 3,
      select: function( event, ui ) {
            event.preventDefault();
              $("#selectedPeopleUri").val(ui.item.uri);
              $("#projectPeopleDetailsPreview").html("<strong>"+ ui.item.persname + "</strong> <em>" + ui.item.uri +"</uri>");
                if ($('#addProjectPeopleButtonDocPlaces').hasClass('hidden') === true) {
                                $("#addProjectPeopleButtonDocPlaces").toggleClass("hidden");
                                
                         
                            } else {
                                
                         };
           
             
            

            }
    } );






    var text2importTextArea = $('#text2importInputEditor');

    text2importTextArea.bind("keydown click focus", function(){
                //var editor = ace.edit("editor");
                // console.log("text: " );
                //console.log("HERE!!");
                $("#conversionInProcess").removeClass("hidden");
                 var text2convert = $(this).val();

//                console.log(text2convert);

                var editorPreview = ace.edit("text2importXMLPreview");
                $("#conversionInProcess").addClass("hidden");
/*                editorPreview.getSession().setValue(convertEDR2TEI(text2convert));*/
                //editorPreview.getSession().setValue(pointedCharacters2Epidoc(text2convert));
                    });

   var xmlFileEditor = ace.edit("xml-editor-file");
   
   var xmlFileEditorSession = xmlFileEditor.getSession();
   xmlFileEditorSession.on('change', function(){
   console.log("ICI!");
     $("#body").toggleClass('overlap');
     $("#fileModifiedAlert" ).fadeIn(1000);
     $("#saveFileButton" ).fadeIn(1000);
            xmlText = xmlFileEditor.getValue();
     });
/*
////for dashboard tables
var table = $('#documentList').DataTable( {
        "scrollY": "200px"
    } );
 
 
    $('a.toggle-vis').on( 'click', function (e) {
        e.preventDefault();
 
        // Get the column API object
        var column = table.column( $(this).attr('data-column') );
 
        // Toggle the visibility
        column.visible( ! column.visible() );
    } );
*/



});//Ready function


                                  /*
                                      $( window, "#content" ).on( "load", function() {
                                  
                                  
                                      //var model = window.document.getElementById("m_document");
                                      //var instanceElement = window.document.getElementById("i_teidoc");
                                      //var ins = model.getInstanceDocument("i_teidoc");
                                      //console.log(instanceElement.documentElement.textContent);
                                  
                                  
                                  });*/

   $("#text2importInputEditor").keydown(function(){
   
   
   var importEditor = ace.edit("text2importInputEditor");
       var importEditorPreview = ace.edit("text2importXMLPreview");
       
    importEditor.getSession().on('change', function(){

         //var text2convert = $(this).val();

                var editorPreview = ace.edit("text2importXMLPreview");
                var importSource = $( "#importSource option:selected" ).val();
                //console.log("Update preview with source: " + importSource);
                editorPreview.getSession().setValue(
                    convertAncientText(importEditor.getValue(), importSource));
            /*                editorPreview.getSession().setValue(convertEDR2TEI(importEditor.getValue()));*/
});
       
        });

  $(".xmlEditor").each(function( index ) {
     var no = index + 1;
     /*console.log( "Index: " + index + ": " + $( this ).text() );*/
     var xmlEditorArray = [];
     var textPreviewHTMLArray =  $('.textPreviewHTML');
     var xmlEditorName = "xml-editor-" + no ;
     xmlEditorArray[index] = ace.edit(xmlEditorName);
     var xmlEditorSession = xmlEditorArray[index].getSession();
     var toolbarId = "#edition-toolbar-" + no;
     var currentXmlElementDivId = "#current-xml-element-" + no;
     xmlEditorArray[index].focus();


     /*xmlEditorArray[index].on('focus', function(){
        $(toolbarId).removeClass( "disabledToolBar" )});*/
     /*xmlEditorArray[index].on('blur', function(){
        $(toolbarId).addClass( "disabledToolBar" )});*/

    xmlEditorArray[index].on('focus', function(){
/*    console.log("current editor: " + index);*/
    $("#currentEditorIndexVariable").text(index);
    
});


    // CP: here to chagne event for text preview
     xmlEditorSession.on('change', function(){
     //$("#body").toggleClass('overlap');
     $("#editionAlert" + no).fadeIn(500);
     $("#changeComment" + no).val("");
     
     
/*     $("#saveTextButton" + no).fadeIn(1000);*/
            xmlText = xmlEditorArray[index].getValue();
            //console.log("index = " + index);

         //updating Betterform textare
    
                        cursorPosition =  xmlEditorArray[index].getCursorPosition();

                        //xftextarea.val("<newText>"+ xmlText.substring(4, xmlText.length-5) + "</newText>");
                       // xftextarea.val(xmlText);
                       // xftextarea.focus();

                       // xftextarea.blur();
                         $(textPreviewHTMLArray[index]).html(tei2Html4Preview(xmlText));


                         $("#textEditionRepeat > .xfRepeatItem:eq( " + index + " ) > div > div > textarea").val(xmlText);
                         $("#textEditionRepeat > .xfRepeatItem:eq( " + index + " ) > div > div > textarea").focus();
                         $("#textEditionRepeat > .xfRepeatItem:eq( " + index + " ) > div > div > textarea").blur();
                         //$(".xfRepeatItem:eq( " + index + " ) > div > div > textarea").focus();
                         //$(".xfRepeatItem:eq( " + index + " ) > div > div > textarea").blur();
                         //$(".xfRepeatItem:eq( 0 ) > div > div > textarea").css( "font-style", "italic" );
                         xmlEditorArray[index].focus();
                         //xmlEditorArray[index].moveCursorToPosition(cursorPosition);

                    //console.log("Change bis: " + $(".xfRepeatItem:eq( " + index + " ) > div > div > textarea").val());
                    
                    
                         var allTexts = $(".xmlEditor").map(function(index, val){
                            var editor = ace.edit(this);  
                            indexNo = index +1;
                            
                            var textPartLabel =""; 
                            if($("#textPartLabel" + indexNo)){$("#textPartLabel" + indexNo).html()};
                            var text2pass = textPartLabel 
                                + '<div class="textPartDiv">'
                                +  editor.getValue(); 
                                + '</div>'
                            return text2pass 
                            }).get().join("</div>");
                            allTexts = allTexts + "</div>"
/*                            console.log("All texts: " + allTexts);*/
                        $("#textPreviewHTML-9999").html(tei2Html4Preview("<div>" + allTexts + "</div>"));

     });

     xmlEditorSession.selection.on('changeSelection', function(){
     
  /*
/\*  COMMENT FROM HERE*\/
  
  
  //get beginning and end of selection

        /\*console.log("START OF SDELECTION EVENTS");
        //anchor = editor.getSelection();
        console.log("%%%%%%%%%%%%%%%%%%%%%%%%%%%%. Selection Object" + JSON.stringify(xmlEditorArray[index].getSession().selection));
        console.log("%%%%%%%%%%%%%%%%%%%%%%%%%%%%. Selection Anchor" + JSON.stringify(xmlEditorArray[index].getSession().selection.getSelectionAnchor()));
        console.log("%%%%%%%%%%%%%%%%%%%%%%%%%%%%. Selection Lead" + JSON.stringify(xmlEditorArray[index].getSession().selection.getSelectionLead()));
        console.log("%%%%%%%%%%%%%%%%%%%%%%%%%%%%. Selection Range" + JSON.stringify(xmlEditorArray[index].getSession().getSelection()));
        *\/
       XMLText = xmlEditorArray[index].getValue();
            //XMLTextLeftPart = XMLText.substr(0, startOfSelectionAbsPos);
            //XMLTextSelection = editor.getSelectedText();
            //XMLTextRightPart = XMLText.substr(endOfSelectionAbsPos);



        if(xmlEditorArray[index].getSession().selection.isBackwards()) {
            console.log("Selection bacwards");
            startOfSelectionAbsPos = xmlEditorArray[index].session.doc.positionToIndex(xmlEditorArray[index].getSession().selection.getSelectionLead());
        endOfSelectionAbsPos = xmlEditorArray[index].session.doc.positionToIndex(xmlEditorArray[index].getSession().selection.getSelectionAnchor());
        /\*console.log(
                    "Selection anchor: " + JSON.stringify(xmlEditorArray[index].getSelection())
                    + "startOfSelectionAbsPos: " + startOfSelectionAbsPos
                    + "enOfSelectionAbsPos" +endOfSelectionAbsPos
                    );*\/
            XMLTextLeftPart = XMLText.substr(0, startOfSelectionAbsPos);
            XMLTextSelection = xmlEditorArray[index].getSelectedText();
            XMLTextRightPart = XMLText.substr(endOfSelectionAbsPos);
            pointedBrackgtPosSelectionStart = XMLTextLeftPart.lastIndexOf('>');
            pointedBrackltPosSelectionStart = XMLTextLeftPart.lastIndexOf('<');
            pointedBrackgtPosSelectionEnd = XMLTextRightPart.indexOf('>');
            pointedBrackltPosSelectionEnd = XMLTextRightPart.indexOf('<');


             if(pointedBrackgtPosSelectionStart > pointedBrackltPosSelectionStart) startInWord = true
                 else startInWord = false;
                     if(pointedBrackgtPosSelectionEnd < pointedBrackltPosSelectionEnd) endInWord = true
                 else endInWord = false;


            }
        else if(xmlEditorArray[index].getSession().selection.isBackwards()===false)  {
             startOfSelectionAbsPos = xmlEditorArray[index].session.doc.positionToIndex(xmlEditorArray[index].getSession().selection.getSelectionAnchor());
             endOfSelectionAbsPos = xmlEditorArray[index].session.doc.positionToIndex(xmlEditorArray[index].getSession().selection.getSelectionLead());
        /\*console.log(
                    "^^^^^^Selection anchor: " + JSON.stringify(xmlEditorArray[index].getSelection())
                    + "^^^^^^startOfSelectionAbsPos: " + startOfSelectionAbsPos
                    + "^^^^^^enOfSelectionAbsPos" +endOfSelectionAbsPos
                    );
            console.log("ùùùùùùùùùùùùùùùùùùùùùùùùùùùùùù    Dans FALSE");*\/
            XMLTextLeftPart = XMLText.substr(0, startOfSelectionAbsPos);
            XMLTextSelection = xmlEditorArray[index].getSelectedText();
            XMLTextRightPart = XMLText.substr(endOfSelectionAbsPos);

            pointedBrackgtPosSelectionStart = XMLTextLeftPart.lastIndexOf('>');
            pointedBrackltPosSelectionStart = XMLTextLeftPart.lastIndexOf('<');
            pointedBrackCloseltPosSelectionStart = XMLTextLeftPart.lastIndexOf('</');
            pointedBrackgtPosSelectionEnd = XMLTextRightPart.indexOf('>');
            pointedBrackltPosSelectionEnd = XMLTextRightPart.indexOf('<');

            if(pointedBrackgtPosSelectionStart > pointedBrackltPosSelectionStart) startInWord = true
            else startInWord = false;
            if(pointedBrackgtPosSelectionEnd > pointedBrackltPosSelectionEnd) endInWord = true
            else endInWord = false;
            }
            if(startInWord = true)
                    XMLTextLeftPartLeft = XMLTextLeftPart.substr(0, pointedBrackltPosSelectionStart)
                    XMLTextLeftPartRight = XMLTextLeftPart.substr(pointedBrackltPosSelectionStart)

   /\*
        console.log("*********************Selection going backwards " + xmlEditorArray[index].getSession().selection.isBackwards());
        console.log("*********************Start Pointed bracket <: " + pointedBrackltPosSelectionStart);
        console.log("*********************Start Pointed bracket >: " + pointedBrackgtPosSelectionStart);
        console.log("*********************End Pointed bracket <: " + pointedBrackltPosSelectionEnd);
       console.log("*********************End Pointed bracket </: " + pointedBrackCloseltPosSelectionStart);
        console.log("*********************End Pointed bracket >: " + pointedBrackgtPosSelectionEnd);
   *\/

       if(pointedBrackgtPosSelectionStart > pointedBrackltPosSelectionStart) startInWord = true
            else startInWord = false;
         if(pointedBrackgtPosSelectionEnd > pointedBrackltPosSelectionEnd) endInWord = true
            else endInWord = false;
         /\*console.log("/////Start InWord: " + startInWord);
         console.log("/////End InWord: " + endInWord);
    *\/

      /\*if(pointedBrackPos > pointedBrackAutoPos) pointedBrackPosition = pointedBrackPos
                 else pointedBrackPosition = pointedBrackAutoPos ;
      *\/
        XMLLeftLeft = XMLTextLeftPart.substr(0, pointedBrackltPosSelectionStart);
        XMLLeftRight = XMLTextLeftPart.substr(pointedBrackltPosSelectionStart);
        XMLRightLeft = XMLTextRightPart.substr(0, pointedBrackgtPosSelectionEnd+1);
        XMLRightRight = XMLTextRightPart.substr(pointedBrackgtPosSelectionEnd+1);
        XMLSelectionLeft = XMLTextSelection.substr(0, XMLTextSelection.indexOf('<'));
        XMLSelectionLeftTogt = XMLTextSelection.substr(0, XMLTextSelection.indexOf('>')+1);
        XMLSelectionLeftToltClosing = XMLTextSelection.substr(0, XMLTextSelection.lastIndexOf('</'));
        XMLSelectionRightFromltClosing = XMLTextSelection.substr(XMLTextSelection.lastIndexOf('</'));
        XMLSelectionRight = XMLTextSelection.substr(XMLTextSelection.indexOf('<'))
        XMLSelectionRightFromgt = XMLTextSelection.substr(XMLTextSelection.indexOf('>')+1)
        //typeOfElement =
        /\*console.log(
            ">>>>>>> XMLLeftLeft = " + XMLLeftLeft
            + "\n>>>>>>> XMLLeftRight = " + XMLLeftRight
            + "\n>>>>>>> XMLRightLeft = " + XMLRightLeft
            + "\n>>>>>>> XMLRightRight = " + XMLRightRight
            + "\n>>>>>>> XMLSelectionLeft = "  + XMLSelectionLeft
            + "\n>>>>>>> XMLSelectionRight = " + XMLSelectionRight
            + "\n>>>>>>> XMLSelectionLeftTogt" + XMLSelectionLeftTogt
            + "\n>>>>>>> XMLSelectionRightFromgt" + XMLSelectionRightFromgt
        )
        console.log("*** Left text: " + XMLTextLeftPart
                +"\n*** Selected text: " + XMLTextSelection
                +"\n*** Right text: " + XMLTextRightPart);
    *\/

      if(pointedBrackltPosSelectionStart >=0 && startInWord==false){
/\*           console.log("SELECTION - START - Pointed bracket and not in word");*\/


              if(pointedBrackCloseltPosSelectionStart == pointedBrackltPosSelectionStart){
/\*                    console.log("closing element");       *\/
                           if(pointedBrackltPosSelectionEnd >=0 && endInWord==false){
/\*                              console.log("Selection - end NOT in word");*\/
                              if(XMLTextSelection.lastIndexOf('<') == XMLTextSelection.lastIndexOf('</')){
                                  text = XMLTextLeftPart + XMLSelectionLeftTogt + '<span class="selectionPreview">'
                             + XMLSelectionRightFromgt + '</span>'
                             + XMLSelectionLeftToltClosing + XMLSelectionLeftFromltClosing
                             + XMLTextRightPart;
                              /\*console.log("SELECTION - Start not in word -  End in Pointed bracket and not in word"
                              + "\nFull text with selection: " + text);*\/
                               $(textPreviewHTMLArray[index]).html(tei2Html4Preview(text));
                               console.log("Dans pointedBrackCloseltPosSelectionStart == pointedBrackltPosSelectionStart");

                              }

                              else if(XMLTextSelection.lastIndexOf('<') > XMLTextSelection.lastIndexOf('</')){
                              /\*console.log("Selection - end IN word");
                                  text = XMLTextLeftPart + XMLSelectionLeftTogt + '<span class="selectionPreview">'*\/
                             + XMLSelectionRightFromgt + '</span>'
                             + XMLSelectionRight + XMLRightRight;
                              /\*console.log("SELECTION - Start not in word -  End in Pointed bracket and not in word"
                              + "\nFull text with selection: " + text);*\/
                               $(textPreviewHTMLArray[index]).html(tei2Html4Preview(text));
                               console.log("Dans XMLTextSelection.lastIndexOf('<') > XMLTextSelection.lastIndexOf('</'");
                              }


                          }

                         else if(pointedBrackltPosSelectionEnd =-1 || endInWord==true){
/\*                             console.log("Selection - end in word");*\/
                             text = XMLTextLeftPart + XMLSelectionLeftTogt + '<span class="selectionPreview">' + XMLSelectionRightFromgt + '</span>' + XMLTextRightPart;
                             /\*console.log("SELECTION - Start not in word - end in no pointed bracket or in word"
                             + "\nFull text with selection: " + text);*\/
                              $(textPreviewHTMLArray[index]).html(tei2Html4Preview(text));
                              console.log("dans if(pointedBrackltPosSelectionEnd =-1 || endInWord==true)");
                          }
                }




                else if(pointedBrackCloseltPosSelectionStart < pointedBrackltPosSelectionStart){
/\*                    console.log("Opening element");*\/

                }







          //  text = XMLTextLeftPartLeft + '<span class="selectionPreview">' + XMLTextLeftPartRight + XMLTextSelection + '</span>' + XMLLeftRight + XMLTextRightPart;
            $(textPreviewHTMLArray[index]).html(tei2Html4Preview(text));
            $(currentXmlElementDivId).html('<span class="selectionNotXml">Selection is not XML compliant</span>')
            console.log("Dans pointedBrackCloseltPosSelectionStart < pointedBrackltPosSelectionStart");
        }
        else if(pointedBrackgtPosSelectionStart =-1 || startInWord==true){


/\*                console.log("SELECTION - no Pointed bracket or in word");*\/
                if(pointedBrackltPosSelectionEnd >=0 && endInWord==false){

                   text = XMLTextLeftPart + '<span class="selectionPreview">' + XMLSelectionLeft + '</span>' + XMLSelectionRight + XMLRightRight;
                    /\*console.log("SELECTION - Start in word - End in Pointed bracket and not in word"
                    + "\nFull text with selection: " + text);*\/
                    $(textPreviewHTMLArray[index]).html(tei2Html4Preview(text));
                      $(currentXmlElementDivId).html('<span class="selectionNotXml">Selection is not XML compliant</span>')
                    console.log("Dans pointedBrackltPosSelectionEnd >=0 && endInWord==false; SELECTION: " + XMLSelectionLeft);
                }
                else if(pointedBrackltPosSelectionEnd =-1 || endInWord==true){

                   text = XMLTextLeftPart+ '<span class="selectionPreview">' + XMLTextSelection + '</span>' + XMLTextRightPart;
  /\*                 console.log("SELECTION - Start in word - End in No pointed bracket or in word"
                   + "\nFull text with selection: " + text);
  *\/                 $(textPreviewHTMLArray[index]).html(tei2Html4Preview(text));
                            try {
                                xmlDoc = $.parseXML("<root>" + XMLTextSelection + "</root>"); //is valid XML
                                $(currentXmlElementDivId).html("Selection is XML compliant" );
                                    console.log($(xmlDoc).find("*").last().prop("tagName"));
                                } catch (err) {
                                            // was not XML
                                    $(currentXmlElementDivId).html('<span class="selectionNotXml">Selection is not XML compliant</span>')
                                };
/\*                        console.log("Dans pointedBrackltPosSelectionEnd =-1 || endInWord==true. SELECTION: " + XMLTextSelection);*\/
                }
        }


        //text = XMLTextLeftPart+ '<span class="selectionPreview">' + XMLTextSelection + '|</span>' + XMLTextRightPart;


/\*COMMENTS TO HERE*\/
*/
});

/******/
/*Desactivated because looping - 06/12/2018*/ 
/*xmlEditorSession.selection.on('changeCursor', function(){


    /\*console.log("???????????????????????????");
    console.log("$$$$$$$CURSOR CHANGE$$$$$$$$$$$$$$");
    console.log("?????????????????????????????");*\/
    PlainSelectedText =  xmlEditorArray[index].getSelectedText();
    //posEndOfElement = PlainSelectedText.lastIndexOf('/>');

    caretRelPos = xmlEditorArray[index].getCursorPosition();
    caretAbsPos = xmlEditorArray[index].session.doc.positionToIndex(caretRelPos);
    //console.log("caret Rel pos" + JSON.stringify(caretRelPos) + "\ncaret abs pos" + caretAbsPos);

    XMLText = xmlEditorArray[index].getValue();
    //console.log("Full text: " + XMLText);
    XMLTextLeftPart = XMLText.substr(0, caretAbsPos);
    XMLTextRightPart = XMLText.substr(caretAbsPos);


/\*    Get positions of some pointed brackets*\/
    pointedBrackgtPos = XMLTextLeftPart.lastIndexOf('>');   // last > in left part
    pointedBrackltPos = XMLTextLeftPart.lastIndexOf('<');   // last < in left part


    pointedBrackPos = XMLTextLeftPart.lastIndexOf('</');    //  last </ (closing) in left part
    pointedBrackAutoPos = XMLTextLeftPart.lastIndexOf('/>');//  last /> (autoclosing) in left part

    pointedBrackgtPosInRight = XMLTextRightPart.indexOf(">")// First > in right part
    pointedBrackltPosInRight = XMLTextRightPart.indexOf("<")// First < in right part




    if(pointedBrackgtPos > pointedBrackltPos) inWord = true
            else inWord = false;

    if(pointedBrackPos > pointedBrackAutoPos) pointedBrackPosition = pointedBrackPos
                 else pointedBrackPosition = pointedBrackAutoPos ;




        XMLLeftLeft = XMLTextLeftPart.substr(0, pointedBrackltPos);
        XMLLeftRight = XMLTextLeftPart.substr(pointedBrackltPos);
        XMLRightLeft = XMLTextRightPart.substr(0, XMLTextRightPart.indexOf('>')+1);

        if(XMLLeftRight.substring(0, 2) =="</" ) inEndingTag = true
            else inEndingTag = false;

            /\*console.log("*** Left text: " + XMLTextLeftPart
                +"\n*** Right text: " + XMLTextRightPart);
    *\/
    /\*        console.log("***InWord: " + inWord);
            console.log("***InEndingTag: " + inEndingTag + "(value: " + XMLLeftRight.substring(0, 1) + ")");
            console.log("***********Pointed bracket pos (left part): " + pointedBrackPos);
            console.log("***********Pointed bracket AUto pos (left part): " + pointedBrackAutoPos);
        console.log("***Pointed bracket < in left part: " + pointedBrackltPos);
        console.log("***Pointed bracket > in left part: " + pointedBrackgtPos);
        console.log("***First Pointed bracket < in right part: " + pointedBrackltPosInRight);
        console.log("***First Pointed bracket > in right part: " + pointedBrackgtPosInRight);

        console.log("***Text to the left of pointed bracket >: " + XMLLeftLeft);
        console.log("***Text to the right of pointed bracket <: " + XMLLeftRight);

        console.log("XMLLeftRight: " + XMLLeftRight);
        console.log("XMLRightLeft: " + XMLRightLeft);
    *\/
        if(pointedBrackltPos >=0 && inWord==false){
                //Case cursor is in opening tag
                if(XMLLeftRight.substring(0, 2) !="</" )
                        {
                        console.log("In opening tag");
                        openingXMLElement = XMLLeftRight + XMLRightLeft;
                        posOfElementNameEndSpace = openingXMLElement.indexOf(" ");
                        posOfElementNameEndPointedBracket = openingXMLElement.indexOf(">");

                        if(posOfElementNameEndSpace <= 0) posOfElementNameEnd = posOfElementNameEndPointedBracket
                            else posOfElementNameEnd = posOfElementNameEndSpace;
                        endCurrentXMLElement = openingXMLElement.substr(0, 1) + "/" + openingXMLElement.substring(1, posOfElementNameEnd ) + ">";

                        XMLElementWithContent = openingXMLElement
                                + XMLTextRightPart.substring(pointedBrackgtPosInRight+ 1, XMLTextRightPart.indexOf(endCurrentXMLElement))  + endCurrentXMLElement;
                               /\* console.log("Pointed bracket and not in word");
                                console.log("Position of element name end: " + posOfElementNameEnd);
                                console.log("Opening element: " + openingXMLElement);
                                console.log("Ending element: " + endCurrentXMLElement);
                                console.log("Elements + content: "
                                + XMLElementWithContent);*\/
                    text = XMLLeftLeft + '<span class="cursorPreview">|</span>' + XMLLeftRight + XMLTextRightPart;
                    $(textPreviewHTMLArray[index]).html(tei2Html4Preview(text));

                    $(currentXmlElementDivId).text(XMLElementWithContent);
                   }
                   if(XMLLeftRight.substring(0, 2) =="</" )
                    {
/\*                    console.log("////////////////////////////In closing tag");*\/
                            closingXMLElement = XMLLeftRight + XMLRightLeft;
                            openingCurrentXMLElement = "<" + closingXMLElement.substr(2);

                      /\*          console.log("Opening element: " + openingCurrentXMLElement);
                                console.log("Closing element: " + closingXMLElement);*\/
                        XMLElementWithContent = openingCurrentXMLElement
                                + XMLTextLeftPart.substring(XMLTextLeftPart.lastIndexOf(openingCurrentXMLElement) + openingCurrentXMLElement.length +1)
                                 + closingXMLElement;

                                /\*console.log("Elements + content: "
                                + XMLElementWithContent);*\/
                                        text = XMLLeftLeft + '<span class="cursorPreview">|</span>' + XMLLeftRight + XMLTextRightPart;
                    $(textPreviewHTMLArray[index]).html(tei2Html4Preview(text));

                    $(currentXmlElementDivId).text(XMLElementWithContent);
                    }
                }


        else if(pointedBrackltPos =-1 || inWord==true){
/\*                    console.log("no Pointed bracket or in word");*\/
                    text = XMLTextLeftPart+ '<span class="cursorPreview">|</span>' + XMLTextRightPart;
                    $(textPreviewHTMLArray[index]).html(tei2Html4Preview(text));

                    if(PlainSelectedText.length <=0) $(currentXmlElementDivId).html("<em>Cursor is currently not in any XML element")
                    else $(currentXmlElementDivId).html("<em>See selected text in preview pane</em>");
                    }

        else if(XMLLeftRight.substring(0, 2) =="</" ) {
/\*            console.log("in Ending Tag");*\/
        }


});
*End of function cursor 
*/

/*
***********************************
*  Selection from preview pane    *
***********************************
*/
        $(textPreviewHTMLArray[index]).bind("mouseup", function() {
         var xmlEditorArray = [];
         var xmlEditorName = "xml-editor-" + (index + 1)  ;
         xmlEditorArray[index] = ace.edit(xmlEditorName);
         var mytext = convertAncientText(window.getSelection().getRangeAt(0), 'edcs').substring(11);
/*        console.log("mytext" + convertAncientText(mytext, 'edcs').substring(11));*/
         console.log("Text to find: %" + mytext + "%");
         console.log("Other: " + window.getSelection());
         var range = xmlEditorArray[index].find(mytext,{
                wrap: true,
                caseSensitive: false,
                wholeWord: false,
                regExp: false,
                preventScroll: false // do not change selection
         });
         $("#currentEditorIndexVariable").text(index.toString());

    });


});

/*
****************************
*     Dropdown menus       *
****************************
*/
 $(function(){
$( "#content" ).on( "click", ".dropdown-menu li a", function( event ) {
    //console.log("menu: " + $(this).attr('menu'));
    //              console.log("v: " + $(this).attr('value'));
        /*        var menu = "#" + $(this).attr('id');*/
                var menu = $(this).attr('menu');
                 $(menu).html($(this).text()  + '<span class="caret"></span>');
                 $(menu).attr('value', $(this).attr('value'));
        
});
});


function convertToRoman(num) {
  //TABLE OF EQUIVALENCES
  var arrConv=[{0:' '},{1:'I'},{2:'II'},{3:'III'},{4:'IV'},{5:'V'},{6:'VI'},{7:'VII'},{8:'VIII'},{9:'IX'},{10:'X'},{20:'XX'},{30:'XXX'},{40:'XL'},{50:'L'},{60:'LX'},{70:'LXX'},{80:'LXXX'},{90:'XC'},{100:'C'},{200:'CC'},{300:'CCC'},{400:'CD'},{500:'D'},{600:'DC'},{700:'DCC'},{800:'DCCC'},{900:'CM'},{1000:'M'},{2000:'MM'},{3000:'MMM'},{4000:'MMMM'},{5000:'MMMMM'},{6000:'MMMMMM'},{7000:'MMMMMMM'},{8000:'MMMMMMMM'},{9000:'MMMMMMMMM'}];

  //First we break down the number into its units
  //and create an array ex: 652 ==> [600, 50, 2]
  var arr=[num.length];
  arr=num.toString().split("").reverse();
  var i=1;
  for (var k=0;k<arr.length;k++){
    arr.splice(k,1,arr[k]*i);
    i*=10;
  }
 
  //We make an array of objects with the number and the roman number equivalence
 var romansArray=[];
  for (i=0;i<arr.length;i++){
    var val=arrConv.filter(function(obj){
       return obj[arr[i]];
     })[0];
    romansArray.push(val);
  }

  //I get rid of all the null values
  var result=romansArray.filter(function(val){
    return (val!=null);
  });

  //It returns the string with the roman number
  return result.map(function(value,key){
    return result[key][arr[key]];
  }).reverse().join("").trim();

};
function romanToArabic(romanNumber){
  romanNumber = romanNumber.toUpperCase();
  const romanNumList = ["CM","M","CD","D","XC","C","XL","L","IX","X","IV","V","I"];
  const corresp = [900,1000,400,500,90,100,40,50,9,10,4,5,1];
  var index =  0, num = 0;
  for(var rn in romanNumList){
        index = romanNumber.indexOf(romanNumList[rn]);
        while(index != -1){
      num += parseInt(corresp[rn]);
      romanNumber = romanNumber.replace(romanNumList[rn],"-");
      index = romanNumber.indexOf(romanNumList[rn]);
    }
  }
  return num;
};


$( ".repositoryLookup" ).attr('autocomplete','off');
$( ".repositoryLookup" ).autocomplete({
              
               source: function( request, response ) {
                    console.log("Dans lookup");
                    var elementId = $(this.element).prop("id");
                    var type = elementId.substr(elementId.lastIndexOf('Modal')+ 5);      
                    $.ajax({
                        //url : 'geo/search-place/' 
                        url: '/objectRepositories/search/'
                                //+$('#projectPlacesLookUp').val()
                                ,
                        dataType : 'json',
                        data : {
                                    'query': $('#repositoryLookup').val()
                                    //types: "place"
                                    },
                        success : function(data){
                            /*console.log("sucess: " + JSON.stringify(data));*/
                            response(
                                $.map(
                                    data.list.items, function(object){
                                       return {
                                                    label: object.searchResult,
                                                    title: object.title,
                                                    uri: object.identifier,
                                                    fullData: object,
                                                    parentLabel: object.parentLabel,
                                                    parentUri: object.parentUri
                                                    };
                                                   
                                        }));
            
                            },
                                error:function(){ 
                                console.log("Erreur");
                                }
                        });
        }, //End of Source
      minLength: 3,
      select: function( event, ui ) {
            event.preventDefault();
                    $(this).val(ui.item.label);
              $("#repositoryUri").val(ui.item.uri);
              $("#repositoryLabel").val(ui.item.title);
              $("#townRepositoryUri").val(ui.item.parentUri);
              $("#townRepositoryLabel").val(ui.item.parentLabel);
              $("#repositoryDetailsPreview").html("<span><strong>You have selected the following repository:</strong> "
                    + ui.item.title + " ("+ ui.item.parentLabel + ")"
                    + "<br/>"
                    + "<em>"  + ui.item.uri 
                    + "</em> (" + ui.item.parentUri + ")");
              
             
            

            }
    } );