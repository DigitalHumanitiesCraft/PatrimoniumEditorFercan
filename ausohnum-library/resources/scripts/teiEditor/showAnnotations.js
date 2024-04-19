function showAnnotations(docid){
                    
        $.ajax({
                    //method: "GET",
                          url: "http://patrimonium.huma-num.fr/json/get-annotations/" + docid,
                          //url: "http://thot.philo.ulg.ac.be/api/txt/get-dateRange/thot-374",
                          dataType : 'json', 
                          //contentType: "text/plain",
                          success : function(data){
                            var editor = ace.edit("editor");
                            
                            console.log("Raw data: " +
                            JSON.stringify(data)+
                            "\n##############################START"
                            + "OF LOOP####################"
                            //+ "test post start: " + data
                            )
             
                            /*data.annotation.forEach(function(annotation) {
                                var posStart = annotation.posStart;
                                var posEnd = annotation.posEnd;
                                var originalText = editor.getValue();
                                seqBefore = originalText.substring(0, posStart);
                                seqMiddle = originalText.substring(posStart, posEnd);
                                seqAfter = originalText.substring(posEnd);
                                console.log("Before: " + seqBefore
                                + "\nMiddle: " + seqMiddle
                                + "\nAfter: " + seqAfter);
                            });
             */
             
             
             
    /*                      //for (var a in data)
                          data.annotations.forEach(function(annotation)){  
                            console.log("Data loop" + data[a].posStart);
                          
                          
                          var posStart = JSON.stringify(a);
                          var posEnd = a.posEnd;
                          var text2process =editor.getValue(); 
                          
                          //console.log("posStart: " + a[].posStart);
                          
                          text2processBefore = text2process.substring(0,
                          posStart);
                          text2processAfter = text2process.substring(posEnd);
                          text2processMiddle = text2process.substring(posStart, posEnd);
                           console.log(
                             "Before: " + text2processBefore
                             + "\nAfter: " + text2processAfter
                             + "\nMiddle: " + text2processMiddle
                            
                           )
                           }
             */              
                           
                           
                           //newText = text2processBefore + '<span id="ddd" class="annotationPeople">' +
                           //text2processMiddle + "</span>" + text2processAfter
                           // $("#textPreviewHTML").html(newText);
                          },
                          error: function(){console.log("Erreur dans Ajax")}
                          
                      });
};


$(document).ready(function() {
    var url = window.location.href;
    var docid= url.substr(url.lastIndexOf('/') + 1);
    console.log("json/get-annotations/" + docid);
   showAnnotations(docid) 
});