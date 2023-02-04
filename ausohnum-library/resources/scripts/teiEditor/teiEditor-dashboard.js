function openDialog(dialogId, project){
    dialogId = "#" + dialogId;
    $(dialogId).modal('show');
    $(dialogId).find("input,textarea,select").val('').end();
    $(".templateSelect option[value='" + project +"']").attr("selected","selected");
/*    $(".templateSelect").selected = true;*/
  };


    $( window ).on( "load", function() {
            $('#newCollectionTitleFull').keyup(function() {
                $('#newCollectionTitleShort').val($("#newCollectionTitleFull").val().replace(/\W/g, "-").toLowerCase());
                $('#newCollectionPrefix').val($("#newCollectionTitleFull").val().match(/\b(\w)/g).join("").toLowerCase());
      


      
      
      
      });
    });
  
 $(document).on('ready', function() {
 
 $('#newDocumentSection').accordion();
 
  $(".dropdown-menu li a").click(function(){
                console.log("menu: " + $(this).attr('menu'));
                console.log("v test: " + $(this).attr('value'));
                var menu = $(this).attr('menu');
                 $(menu).html($(this).text()  + '<span class="caret"></span>');
                 $(menu).attr('value', $(this).attr('value'));
        
           });

 
 $('#newUserPassword, #confirm_password').on('keyup', function () {
  if ($('#newUserPassword').val() == $('#confirm_password').val()) {
    $('#message').html('Passwords are matching').css('color', 'green');
  } else 
    $('#message').html('Passwords are not Matching').css('color', 'red');
});
 
 
 
 
 
$( "#zoteroLookupCreateNewDoc" ).autocomplete({
      source: function( request, response ) {
        $.ajax({
            url : 'https://api.zotero.org/groups/2094917/items?',
            dataType : 'json',
            data : {
                q: $('#zoteroLookupCreateNewDoc').val()
                //types: "place"

            },

            success : function(data){
                console.log("sucess: " + data);
                response(
                $.map(
                    data, function(object){
                           if(object.data.creators[0]!=undefined) {var author = object.data.creators[0].lastName}else{var author =""}
                           if(object.data.title!='') {var title = object.data.title}

/*                           console.log("title: " + title);*/
/*                           console.log("Author: " + author);*/
/*                           console.log("ID: " + object.key);*/
                           return {
                                label: author + "  " + object.data.date + ", " + title + ' (Zotero key: ' + object.key + ')',
                                author: author,
                                //author: object.data.creators[0].lastName,
                                date: object.data.date,
                                title: title,
                                //title: object.data.title,
                                value: object.key,
                                fullData: object.data
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
            $('#zoteroLookupCreateNewDoc').val(ui.item.label);


/*              $("#selectedBiblioAuthor").html("Author: " + ui.item.fullData.creator[0].firstName + " " + ui.item.fullData.creator[0].lastName);*/
              $("#selectedBiblioAuthor").html("Author: " + ui.item.author);
              $("#selectedBiblioDate").html("Date: " + ui.item.fullData.date);
              $("#selectedBiblioTitle").append('Title: <em>' + ui.item.title + '</em>')
              $("#selectedBiblioId").html(ui.item.value);
              ;

            }
    } );

});

function createNewCollection(){
    
    var titleFull = $("#newCollectionTitleFull").val();
    var titleShort = $("#newCollectionTitleShort").val();
    var collectionPrefix = $("#newCollectionPrefix").val();
    
    if (titleShort ){

            try { 
                     var xmlData = "<xml>"
                                               + "<titleFull>" + titleFull + "</titleFull>"
                                               + "<titleShort>" + titleShort + "</titleShort>"
                                               + "<collectionPrefix>" + collectionPrefix + "</collectionPrefix>"
                                            +"</xml>"
                    console.log(xmlData);
                    var request = new XMLHttpRequest();
                    request.open("POST", "$ausohnum-lib/modules/teiEditor/getFunctions.xql?type=newCollection" , true);
                    var xmlDoc;
                
                         request.onreadystatechange = function() {
                             if (request.readyState == 4 && request.status == 200) {
                             console.log("New document created");
                             response = request.responseText;
                             
                             console.log("Response" + response);
                             $('#dialogNewCollection' ).modal('hide');
                             //console.log("New doc ID: " + $(response).find("newDocId").text());
                             //console.log($(response).find("newList").get(0));
/*                             var newDocId = $(response).find("newDocId").text();*/
                             
                             $("#collectionList").replaceWith($(response).find("newList"));
                              
                                    
                             
                             }
                             
                             };
                             
                             request.setRequestHeader('Content-Type', 'text/xml');
                
                            request.send(xmlData);
                            
            } catch (err) {
                  // was not XML
                  alert("Selection is not XML compliant!");
                  }
            } else {alert("Please enter a title");}
    

    
    
}; /*End of createNewCollection*/

function createNewDocument($collection){
    var template = $("#newDocTemplate" + $collection).val();
    var title = $("#newDocTitle" + $collection).val();
    var externalResource = $("#externalResourceUri" + $collection).val();
    var externalResourceType = $("#c23504_1_1").val();
    var externalResourceSubtype = $("#c23500_1_1").val();
        if( externalResource !== undefined && externalResource.match(/\&/g)){
        alert("Please check the URI: character '&' cannot be imported in a XML file" );
        return false;
        };
        
    if (template ==null ){
    alert("Please select a template")}
    else{
    if (title )
            {
            if(
            externalResource !== "" && (externalResourceType =="" || externalResourceSubtype =="")
                ){
                alert("Please enter a type and a subtype for the external resource");
                return false;
            }
           
            try { 
            $("body").css("cursor", "wait");
            $("body").css("opacity", "0.5");
            $("button").attr("disabled", true);
            $("input").attr("disabled", true);
                     var xmlData = "<xml>"
                                            + "<template>" + template + "</template>"
                                            + "<title>" + title + "</title>"
                                            + "<collection>" + $collection + "</collection>"
                                            + "<typeTextValue>" + $("#c21851_1_1").text().trim() + "</typeTextValue>"
                                            + "<typeAttributeValue>" + $("#c21851_1_1").val() + "</typeAttributeValue>"
                                            + "<langTextValue>" +  $("#c39_1_1").text().trim() + "</langTextValue>"
                                            + "<langAttributeValue>" +  $("#c39_1_1").val() + "</langAttributeValue>"
                                            + "<scriptTextValue>" +  $("#c109_1_1").text().trim() + "</scriptTextValue>"
                                            + "<scriptAttributeValue>" +  $("#c109_1_1").val() + "</scriptAttributeValue>"
                                            + "<externalResource>" +  externalResource + "</externalResource>"
                                            + "<externalResourceType>" +  externalResourceType + "</externalResourceType>"
                                            + "<externalResourceSubtype>" +  externalResourceSubtype + "</externalResourceSubtype>"
                                            +"</xml>"
                  
                   console.log(xmlData);
                    var request = new XMLHttpRequest();
                    /*request.open("POST", "$ausohnum-lib/modules/teiEditor/getFunctions.xql?type=newDocument" , true);*/
                    request.open("POST", "$ausohnum-lib/modules/teiEditor/createNewDocument.xql?type=template" , true);
                    var xmlDoc;
                
                         request.onreadystatechange = function() {
                             if (request.readyState == 4 && request.status == 200) {
                             console.log("New document created");
                             response = request.responseText;
                             
                             console.log("Response" + response);
                             $('#dialogNewDocument' + $collection).modal('hide');
                             console.log("New doc ID: " + $(response).find("newDocId").text());
                             console.log($(response).find("newList").get(0));
                             var newDocId = $(response).find("newDocId").text();
                             
                             $("#documentListDiv").replaceWith($(response).find("newList"));
                              $("body").css("cursor", "default");
                               
                                $("body").css("opacity", "1");
                                $("button").attr("disabled", false);
                                $("input").attr("disabled", false);
                                    // CP path fix
                                    var win = window.open('/exist/apps/estudium/edit-documents/' + newDocId , '_blank' );
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
                            
            } catch (err) {
                  // was not XML
                  alert("Selection is not XML compliant!");
                  }
            } else {alert("Please enter a title");}
    }

    
    
}; /*End of createNewDocument*/

function createNewDocumentFromTemplateWithEditionFromExternalResource($collection){
    var template = $("#newDocTemplateWithEditionFromExtResource" + $collection).val();
    var title = $("#newDocTitleWithEditionFromExtResource" + $collection).val();
    var externalResource = $("#externalResourceUriWithEditionFromExtResource" + $collection).val();
    var externalResourceType = $("#c23504_1_1").val();
    var externalResourceSubtype = $("#c23500_1_1").val();
        if( externalResource !== undefined && externalResource.match(/\&/g)){
        alert("Please check the URI: character '&' cannot be imported in a XML file" );
        return false;
        };
        
    if (template ==null ){
    alert("Please select a template")}
    else{
    if (title )
            {
            if(
            externalResource !== "" && (externalResourceType =="" || externalResourceSubtype =="")
                ){
                alert("Please enter a type and a subtype for the external resource");
                return false;
            }
           
            try { 
            $("body").css("cursor", "wait");
            $("body").css("opacity", "0.5");
            $("button").attr("disabled", true);
            $("input").attr("disabled", true);
                     var xmlData = "<xml>"
                                            + "<template>" + template + "</template>"
                                            + "<title>" + title + "</title>"
                                            + "<collection>" + $collection + "</collection>"
                                            + "<typeTextValue>" + $("#c21851_1_1").text().trim() + "</typeTextValue>"
                                            + "<typeAttributeValue>" + $("#c21851_1_1").val() + "</typeAttributeValue>"
                                            + "<langTextValue>" +  $("#c39_1_1").text().trim() + "</langTextValue>"
                                            + "<langAttributeValue>" +  $("#c39_1_1").val() + "</langAttributeValue>"
                                            + "<scriptTextValue>" +  $("#c109_1_1").text().trim() + "</scriptTextValue>"
                                            + "<scriptAttributeValue>" +  $("#c109_1_1").val() + "</scriptAttributeValue>"
                                            + "<externalResource>" +  externalResource + "</externalResource>"
                                            + "<externalResourceType>" +  externalResourceType + "</externalResourceType>"
                                            + "<externalResourceSubtype>" +  externalResourceSubtype + "</externalResourceSubtype>"
                                            +"</xml>"
                  
                   console.log(xmlData);
                    var request = new XMLHttpRequest();
                    /*request.open("POST", "$ausohnum-lib/modules/teiEditor/getFunctions.xql?type=newDocument" , true);*/
                    request.open("POST", "$ausohnum-lib/modules/teiEditor/createNewDocument.xql?type=templateWithEditionFromExternalResource" , true);
                    var xmlDoc;
                
                         request.onreadystatechange = function() {
                             if (request.readyState == 4 && request.status == 200) {
                             console.log("New document created");
                             response = request.responseText;
                             
                             console.log("Response" + response);
                             $('#dialogNewDocumentWithEditionFromExtResource' + $collection).modal('hide');
                             console.log("New doc ID: " + $(response).find("newDocId").text());
                             console.log($(response).find("newList").get(0));
                             var newDocId = $(response).find("newDocId").text();
                             
                             $("#documentListDiv").replaceWith($(response).find("newList"));
                              $("body").css("cursor", "default");
                               
                                $("body").css("opacity", "1");
                                $("button").attr("disabled", false);
                                $("input").attr("disabled", false);
                                    // CP
                                    var win = window.open('/exist/apps/estudium/edit-documents/' + newDocId , '_blank' );
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
                            
            } catch (err) {
                  // was not XML
                  alert("Selection is not XML compliant!");
                  }
            } else {alert("Please enter a title");}
    }

    
    
}; /*End of createNewDocumentDivEditionfromext res*/ 
function createNewDocumentFromExternalResource($collection){
    var template = $("#newDocTemplate" + $collection).val();
    var title = $("#newDocTitle" + $collection).val();
    
    
$("body").css("cursor", "wait");
     
                     var xmlData = "<xml>"
                                            + "<collection>" + $collection + "</collection>"
                                            + "<externalResource>" +  $("#externalResource" + $collection).val() + "</externalResource>" 
                                            + "<docId>" + $("#docId" + $collection).val()  + "</docId>"
                                            + "<docUri>" + $("#docUri" + $collection).val() + "</docUri>"
                                            +"</xml>"
                    console.log(xmlData);
                    var request = new XMLHttpRequest();
/*                    request.open("POST", "$ausohnum-lib/modules/teiEditor/getFunctions.xql?type=newDocumentFromExternalResource" , true);*/
                             request.open("POST", "$ausohnum-lib/modules/teiEditor/createNewDocument.xql?type=external", true);
                    var xmlDoc;
                
                         request.onreadystatechange = function() {
                             if (request.readyState == 4 && request.status == 200) {
                             console.log("New document created");
                             response = request.responseText;
                             
                             console.log("Response" + response);
                             $('#dialogNewDocument' + $collection).modal('hide');
                             console.log("New doc ID: " + $(response).find("newDocId").text());
                             console.log($(response).find("newList").get(0));
                             var newDocId = $(response).find("newDocId").text();
                             
                             $("#documentList").replaceWith($(response).find("newList"));
                             $("body").css("cursor", "default"); 
                                    //CP
                                    var win = window.open('/exist/apps/estudium/edit-documents/' + newDocId , '_blank' );
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
                            
            
    

    
    
}; /*End of createNewDocument*/




function createUser(){


    
    
    
    if  ($('#newUserPassword').val() == $('#confirm_password').val()) {

            try { 
            $("body").css("cursor", "wait");
                     var newUserFirstName = $("#newUserFirstName").val();
                     var newUserLastName = $("#newUserLastName").val();
                     var newUserUsername = $("#newUserUsername").val();
                     var newUserPassword = $("#newUserPassword").val();
                     var xmlData = "<xml>"
                                            + "<newUserFirstName>" + newUserFirstName + "</newUserFirstName>"
                                            + "<newUserLastName>" + newUserLastName + "</newUserLastName>"
                                            + "<newUserUsername>" + newUserUsername + "</newUserUsername>"
                                            + "<newUserPassword>" + newUserPassword + "</newUserPassword>"
                                            +"</xml>"
                    console.log(xmlData);
                    var request = new XMLHttpRequest();
                    request.open("POST", "$ausohnum-lib/modules/create-user.xql" , true);
                    var xmlDoc;
                
                         request.onreadystatechange = function() {
                             if (request.readyState == 4 && request.status == 200) {
                             console.log("New user created");
                             response = request.responseText;
                             
                             console.log("Response" + response);
                             
                             console.log("New doc ID: " + $(response).find("newDocId").text());
                             console.log($(response).find("newList").get(0));
                             
                             
                             
                              
                                    window.location = "/" 
                                    
                             $("body").css("cursor", "default");
                             }
                             };
                             
                             request.setRequestHeader('Content-Type', 'text/xml');
                
                            request.send(xmlData);
                            
            } catch (err) {
                  // was not XML
                  alert("Selection is not XML compliant!");
                  }
            } else {alert("Please enter a title");}
    

    
    
}; /*End of createNewUser*/

function retrieveEditionFromExternalResource($collection){
    var docUri = "";
    if ($("#externalResourceUriWithEditionFromExtResource" + $collection).length > 0) { docUri = $("#externalResourceUriWithEditionFromExtResource" + $collection).val()}
    else { docUri = $("#externalResourceUri" + $collection).val() }
     var request = new XMLHttpRequest();
     var xmlData="<xml>"
                        + "<docUri>" + docUri + "</docUri>"
                        + "</xml>"
    console.log(xmlData);
    request.open("POST", "$ausohnum-lib/modules/teiEditor/importAndConvert.xql" , true);
        var xmlDoc;    
        request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
                        xmlDoc = request.responseText;
                        $("#externalResourceEditionPreview").html(xmlDoc);
                        }
                };
                 request.setRequestHeader('Content-Type', 'text/xml');
                 request.send(xmlData);
        
};
 