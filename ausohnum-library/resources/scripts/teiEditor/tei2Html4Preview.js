function tei2Html4Preview(text){
    var project = getCurrentProject();
    var countLb = (text.match(/<lb/g) || []).length;
    
    var xmlCompliant;
    text = text.replace(/<br>/g, "<br/>");
/*    console.log("Text to be parsed: " + text);*/
try { xmlDoc = $.parseXML("<root>" + text + "</root>");
        xmlCompliant = "";
        } catch (err) {
                  // was not XML
                  xmlCompliant = '<strong class="alert alert-danger">XML is not compliant! </strong>'
                  };

    var langSource = $('#selectDropDownc39_1_1').val();
    if (langSource == "grc") {var characterRange = "[α-ωΑ-Ω\s]"};
    if (langSource == "la") {var characterRange = "[a-zA-Z\s]"};    
    
    //1st line: indent for align with following lines
    if(text.startsWith("<lb")) {
      //  console.log("Statrt with");
    } else{
    text = "<br/>" + text;
    //text= "<span class='lineNo no1'>1</span>" + text;
    };
    
    
/*        parser = new DOMParser();
        xmlDoc = parser.parseFromString(text,"text/xml");
*/
/*        document.getElementById("test").innerHTML =
                  xmlDoc.getElementsByTagName("ab")[0];
*/    
    
    
    //lb into br
    regexLBGeneral = /<lb n=\"([0-9]*)\"\/>/g
   // substLB = "\n<br /><span class='lineNo no$1'>$1</span>";
    text = text.replace(regexLBGeneral,  function(match, selection){
/*                console.log("selection" + selection);*/
                var no = selection.toString();
                var lineNo;
                var length = no.length;
                //console.log("no " + no);
                //console.log("length " + length);
                if (length  ==1 ){lineNo = "<span class='hiddenExtraNo'>00</span>" + no;}
                        else if (length  == 2){ lineNo ="<span class='hiddenExtraNo'>0</span>" + no}
                        else {  lineNo = no;};
/*                        console.log("lineNo" + lineNo);*/
                var html =  "\n<br /><span class='lineNo no" + no +"'>" + lineNo + "</span>"; 
/*                console.log("return here: " + html );*/
                return html;               });
     
    //lb with break no into br >>>> n before break
    regexLBBreakOn = /<lb n=\"([0-9]*)\"( break=\"no\")\/>/g
/*    substLB = "-\n<br /><span class='lineNo no$1'>$1</span>";*/
    text = text.replace(regexLBBreakOn,  function(selection, match){
                var match0 =match[0]
                var match1 =match[1];
                var match2 =match[2]
                var no;
                var lineNo;
                console.log(match0 + match1 + match2 + "    " + match2 !== undefined);
                if (match2 !== undefined)
                            {no = match0 + match1 + match2;
                            lineNo = no;}
                  else if (match1 !== undefined)
                        {  
                        no = match0  + match1; 
                        lineNo ="<span class='hiddenExtraNo'>0</span>" + no}
                        else 
                        {no = match0;
                  lineNo = "<span class='hiddenExtraNo'>00</span>" + no;}
                        
                        
                         
                       // console.log("lineNo" + lineNo);
                var html =  "-\n<br /><span class='lineNo no" + no +"'>" + lineNo + "</span>"; 
                
                return html;               });

//lb with break no into br  >>>> break before n
    regexLBBreakOn = /<lb (break=\"no\") n=\"([0-9]*)\"\/>/g
/*    substLB = "-\n<br /><span class='lineNo no$1'>$1</span>";*/
    text = text.replace(regexLBBreakOn,  function(selection, match){

                var no = selection.toString();
                var lineNo;
                var length = no.length;
                if (length  ==1 ){lineNo = "<span class='hiddenExtraNo'>00</span>" + no;}
                        else if (length  == 2){ lineNo ="<span class='hiddenExtraNo'>0</span>" + no}
                        else {  lineNo = no;};
                       // console.log("lineNo" + lineNo);
                var html =  "-\n<br /><span class='lineNo no" + no +"'>" + lineNo + "</span>"; 
                
                return html;               });     
                
                
 //cb into br
    regexCBGeneral = /<cb n=\"([0-9]*)\"\/>/g
   // substLB = "\n<br /><span class='lineNo no$1'>$1</span>";
    text = text.replace(regexCBGeneral,  function(match, selection){
/*                console.log("selection" + selection);*/
                var no = selection.toString();
                var colNo;
                var length = no.length;
                //console.log("no " + no);
                //console.log("length " + length);
                if (length  ==1 ){colNo = "<span class='hidden'>00</span>" + no;}
                        else if (length  == 2){ colNo ="<span class='hidden'>0</span>" + no}
                        else {  colNo = no;};
/*                        console.log("lineNo" + lineNo);*/
             var lineBreak ="";
             if(no > "1"){lineBreak= "\n<br />"};
                var html =  lineBreak + "<span class='colNo no" + no +"'>Col. " + no + "</span>"; 
/*                console.log("return here: " + html );*/
                return html;               });
     



    //lb with xml:idinto br
    regexLB = /<lb xml:id=\".*\" n=\"([0-9]*)\"\/>/g
    substLB = "\n<br /><span class='lineNo no$1'>$1</span>";
    text = text.replace(regexLB, substLB);
    /*text = text.replace(regexLB,  function(a, match){
                lineNo = "234";
                
                    return "AAAAAAA" + lineNo + "]";
                    
               //console.log("match = " + match);
               
               });*/
               
    //Cleaning extra BR when lb following a cb
    text= text.replace(/<\/span>\n*<br\s?\/><span class=\'lineNo/g, "</span><span class='lineNo");
    
    
    //glyph with hedera
    regex = /<g type=\"hedera\"\/>/g
    if(project="petrae") {subst=" "}
    else {subst = "❦";}
    text = text.replace(regex, subst);
    
    //glyph with hedera
    regex = /<g type=\"leaf\"\/>/g
    if(project="petrae") {subst=" "}
    else{subst = "❦";}
    text = text.replace(regex, subst);
    
    //glyph with interpunct
    regex = /<g type=\"interpunct\"\/>/g
    if(project="petrae") {subst=" "}
    else{subst = "▴";}
    text = text.replace(regex, subst);
    
    //sic
    regex = /\s*<sic>([^"'\<]*)<\/sic>\s*/g
    subst = "";
    text = text.replace(regex, subst);

    //corr
    regex = /<corr>([^"'\<]*)<\/corr>\s*/g
    subst = "⸢$1⸣";
    text = text.replace(regex, subst);
    //corr
    regex = /<orig>([^"'\<]*)<\/orig>\s*/g
    subst = "$1";
    text = text.replace(regex, subst);
/*    regex = /<reg>([^"'\<]*)<\/reg>\s*\/g*/
    regex = /<reg>(.*)<\/reg>\s*/g
    subst = "";
    text = text.replace(regex, subst);
    
    
    //Notes
    regex = /<note>([!]|(sic))<\/note>/g
    subst = "($1)";
    text = text.replace(regex, subst);
/*console.log("TEST");*/
/*    //supplied 
    regexSupplied = /<supplied(\s.[^\/]*)?>(^\x00-\x7F]*[aA-zZ]*)<\/supplied>/g
    substSupplied = "[$2]"
    text = text.replace(regexSupplied, substSupplied);
*/
   
/*   console.log("test @ 144");*/
   //supplied reason lost within an expansion
                //WRONG with letter after supplied but before expan: <expan><abbr>([^\x00-\x7F]*[aA-zZ]*)?<supplied reason=\"lost\">(((\s?)[^\x00-\x7F]*[aA-zZ]*(\s?))*)<\/supplied>(([^\x00-\x7F]*[aA-zZ]*)?)<\/abbr><ex>([^\x00-\x7F]*[aA-zZ]*)\<\/ex>\<\/expan>
    regex= /<expan><abbr>([^\x00-\x7F]*[aA-zZ]*)?<supplied reason=\"lost\">(((\s?)[^\x00-\x7F]*[aA-zZ]*(\s?))*)<\/supplied><\/abbr><ex>([^\x00-\x7F]*[aA-zZ]*)\<\/ex>\<\/expan>/g

    subst= "$1[$2($6)]"
    text = text.replace(regex, subst);
   
   //supplied reason lost cert low within an expansion
    regex= /<expan><abbr>([^\x00-\x7F]*[aA-zZ]*)?<supplied reason=\"lost\" cert=\"low\">(((\s?)[^\x00-\x7F]*[aA-zZ]*(\s?))*)<\/supplied><\/abbr><ex>([^\x00-\x7F]*[aA-zZ]*)\<\/ex>\<\/expan>/g

    subst= "$1[$2($6)?]"
    text = text.replace(regex, subst);
   
   
   //erasure  within an expansion
                //WRONG with letter after supplied but before expan: <expan><abbr>([^\x00-\x7F]*[aA-zZ]*)?<supplied reason=\"lost\">(((\s?)[^\x00-\x7F]*[aA-zZ]*(\s?))*)<\/supplied>(([^\x00-\x7F]*[aA-zZ]*)?)<\/abbr><ex>([^\x00-\x7F]*[aA-zZ]*)\<\/ex>\<\/expan>
    regex= /<expan><abbr>([^\x00-\x7F]*[aA-zZ]*)?<del rend=\"erasure\">(((\s?)[^\x00-\x7F]*[aA-zZ]*(\s?))*)<\/del><\/abbr><ex>([^\x00-\x7F]*[aA-zZ]*)\<\/ex>\<\/expan>/g
    subst= "$1⟦$2($6)⟧"
    text = text.replace(regex, subst);
   
   //erasurereason lost cert low within an expansion
    regex= /<expan><abbr>([^\x00-\x7F]*[aA-zZ]*)?<del rend=\"erasure\" cert=\"low\">(((\s?)[^\x00-\x7F]*[aA-zZ]*(\s?))*)<\/del><\/abbr><ex>([^\x00-\x7F]*[aA-zZ]*)\<\/ex>\<\/expan>/g

    subst= "$1⟦$2($6)?⟧"
    text = text.replace(regex, subst);
   
/*   console.log("test @ 171");*/
   
/*//supplied reason illegible
    regexSuppliedReasonLost = /<supplied reason=\"illegible\">((<?^\x00-\x7F]*[aA-zZ]*?>?)*(<\/?\S*>?)*)<\/supplied>/g
    substSuppliedReasonLost = "[$2]"
    text = text.replace(regexSuppliedReasonLost, substSuppliedReasonLost);

//supplied reason omitted
    regexSuppliedReasonLost = /<supplied reason=\"omitted\">((<?^\x00-\x7F]*[aA-zZ]*?>?)*(<\/?\S*>?)*)<\/supplied>/g
    substSuppliedReasonLost = "⟨[$2]⟩"
    text = text.replace(regexSuppliedReasonLost, substSuppliedReasonLost);

*/
//gap

//gap reason lost extent unknown PRECEDED by a supplied
    regexGap = /<\/supplied>\s?<gap reason=\"lost\" extent=\"unknown\"\/>/g
    substGap= "– – –]"
    text = text.replace(regexGap, substGap);


//gap reason lost extent unknown
    regexGap = /<gap reason=\"lost\" extent=\"unknown\"\/>/g
    substGap= "[– – –]"
    text = text.replace(regexGap, substGap);

//gap reason lost extent unknown with
    regexGap = /<gap reason=\"lost\" extent=\"unknown\" unit=\"character\"\/>/g
    substGap= "[– – –]"
    text = text.replace(regexGap, substGap);

//gap reason lost extent unknown with
    regexGap = /<gap extent=\"unknown\" reason=\"lost\" unit=\"character\"\/>/g
    substGap= "[– – –]"
    text = text.replace(regexGap, substGap);

//gap reason lost extent unknown with line
    regexGap = /<gap reason=\"lost\" extent=\"unknown\" unit=\"line\"\/>/g
    substGap= "– – – – – –"
    text = text.replace(regexGap, substGap);
//gap reason lost extent unknown with line
    regexGap = /<gap reason=\"lost\" quantity=\"1\" unit=\"line\"\/>/g
    substGap= "[– – – – – –]"
    text = text.replace(regexGap, substGap);

/*console.log("test @ 211");*/


//gap reason omitted extent unknown
    regexGap = /<gap reason=\"omitted\" extent=\"unknown\"\/>/g
    substGap= "⟨...⟩"
    text = text.replace(regexGap, substGap);

//gap reason omitted extent unknown
    regexGap = /<gap reason=\"omitted\" extent=\"unknown\" unit=\"character\"\s?\/>/g
    substGap= "(– – –)"
    text = text.replace(regexGap, substGap);


//gap reason lost extent character
    regexGapLost = /<gap reason=\"lost\" quantity=\"([0-9]*)\" unit=\"character\"\/>/g
    substGap= "[·· ? ··]"
    text = text.replace(regexGapLost, function(a, match){
                number = match;
/*                console.log("number: " + number);*/
                
                var dots="";
                        for (var i = 0; i < number; i++) {
                            /*dots = dots.concat("·");*/
                            dots = dots.concat(".");
                        }
                    return "[" + dots + "]";
                    
               //console.log("match = " + match);
               
               });
//gap reason lost extent character    First reason and quantity
    regexGapLost = /<gap reason=\"illegible\" quantity=\"([0-9]*)\" unit=\"character\"\/>/g
    substGap= "[·· ? ··]"
    text = text.replace(regexGapLost, function(a, match){
                number = match;
/*                console.log("number: " + number);*/
                
                var dots="";
                        for (var i = 0; i < number; i++) {
                            /*dots = dots.concat("·");*/
                            dots = dots.concat("+");
                        }
                    return "" + dots + "";
                    
               //console.log("match = " + match);
               
               });
//gap reason lost extent character    First reason and quantity
    regexGapLost = /<gap quantity=\"([0-9]*)\" reason=\"illegible\" unit=\"character\"\/>/g
    substGap= "[·· ? ··]"
    text = text.replace(regexGapLost, function(a, match){
                number = match;
/*                console.log("number: " + number);*/
                
                var dots="";
                        for (var i = 0; i < number; i++) {
                            /*dots = dots.concat("·");*/
                            dots = dots.concat("+");
                        }
                    return "" + dots + "";
                    
               //console.log("match = " + match);
               
               });

 //CP: in fercan we have: @reason @unit @quantity           
 //gap reason lost extent character    First reason and quantity
 regexGapLost = /<gap reason=\"illegible\" unit=\"character\" quantity=\"([0-9]*)\"\/>/g
 substGap= "[·· ? ··]"
 text = text.replace(regexGapLost, function(a, match){
             number = match;
/*                console.log("number: " + number);*/
             
             var dots="";
                     for (var i = 0; i < number; i++) {
                         /*dots = dots.concat("·");*/
                         dots = dots.concat("+");
                     }
                 return "" + dots + "";
                 
            //console.log("match = " + match);
            
            });              


               
//gap reason lost extent character with precision low
    regexGapLost = /<gap reason=\"lost\" quantity=\"([0-9]*)\" unit=\"character\" precision=\"low\"\/>/g
    substGap= "[·· ? ··]"
    text = text.replace(regexGapLost, "[– ca. $1 –]");

//gap reason lost extent character with precision low
    regexGapLost = /<gap reason=\"lost\" atLeast=\"([0-9]*)\" atMost=\"([0-9]*)\" unit=\"character\"\/>/g
    substGap= "[·· ? ··]"
    text = text.replace(regexGapLost, "[– $1-$2 –]");


//abbrebvation only (a(---)
 regex= /(\<abbr>)(\S*)(\<\/abbr\>)(?!(\<ex))/g
    subst = "$2(– – –)"
    text = text.replace(regex, subst);


    //expan
    regexExInExpan = /\s*(\<ex\>)([^"'\<]*)(\<\/ex\>)\s*/g
    substExInExpan = "($2)"
    text = text.replace(regexExInExpan, substExInExpan);

    //expan with uncertain resolution
    regexExInExpan = /(\<ex cert=\"low\">)(\S*)(\<\/ex\>)/g
    substExInExpan = "($2?)"
    text = text.replace(regexExInExpan, substExInExpan);


  //character with apex
    regex= /<hi rend=\"apex\">([^\x00-\x7F]*[aA-zZ]*)<\/hi>/g
    subst= "$1" + '\u0301'
    text = text.replace(regex, subst);
    
    
    //character with ligature
    regex= /<hi rend=\"ligature\">([^\x00-\x7F]*[aA-zZ])([^\x00-\x7F]*[aA-zZ]*)<\/hi>/g
    subst= "$1" + '\u0361' + "$2"
    text = text.replace(regex, subst);
    
    
    //space
    regex = /\<space extent=\"unknown\" unit=\"[aA-zZ]*\"\/>/g
    subst = "<em>vac.</em>"
    text = text.replace(regex, subst);
    
    regex = /\<space quantity=\"([0-9]*)\" unit=\"[aA-zZ]*\"\/>/g
    subst = "<em>vac.</em>$1"
    text = text.replace(regex, subst);
    
    //surplus
   /* regex = /\s*\<surplus\>(\S*)\<\/surplus\>*\/g
    subst= "{$1" +"&#125;"
    text = text.replace(regex, subst);
*/
    regex = /\<surplus\>*/g
    subst= "{"
    text = text.replace(regex, subst);
    regex = /\<\/surplus\>/g
    subst= "&#125;"
    text = text.replace(regex, subst);

    //unclear into dotted character
    regexUnclear = /<unclear>([^\x00-\x7F]*[aA-zZ]*)<\/unclear>/g
    substUnclear = "$1" + '\u0323'
    text = text.replace(regexUnclear, function(match, selection){
/*                text = selection.substring(match.indexOf('>') +1, selection.indexOf('</'));*/
/*                console.log("text: " + text);*/
                text= selection;
                var is = text.length;
                var unclearText="";
                        for (var i = 0; i < text.length; i++) {
                             unclearText += text.charAt(i) + '\u0323';
                        }
                    return unclearText;
                    
             
               
               });
    
 //character with supraline
//THROUGH CSS is better!
/*    regex= /<hi rend=\"supraline\">([^\x00-\x7F]*[aA-zZ]*)<\/hi>/g     
    text = text.replace(regex, function(match, selection){
            /\*                text = selection.substring(match.indexOf('>') +1, selection.indexOf('</'));*\/
            /\*                console.log("text: " + text);*\/
                text= selection;
                var is = text.length;
                var supralineText="";
                        for (var i = 0; i < text.length; i++) {
                             supralineText += text.charAt(i) + '\u0305';
                        }
                    return supralineText;
               });
*/        
    //Remoe br first line
    /*regex= "<br /><span class='lineNo no1'>"
    subst= "<span class='lineNo no1'>"
    text = text.replace(regex, subst);
    */
/*
 * ***************************
 *   Semantic annotations    *
 * ***************************
 */
 
 //placenames
    regexPlaceName= /<placeName( type=\"([^"']*)\")?( ref=\"([^"']*)\")?( key=\"([^"']*)\")?>/g

    substPlaceName= '<span class="place teiPreviewplace placeName $2"><a title="Open this place in a new window [$4]" target="_about" href="$4"><span class="teiPreviewIconplace">⌘</span></a>'
            //+ '<a titles="$3" href="$3" target="_blank">'
/*            +'$1</span>'*/
    
    text = text.replace(regexPlaceName, substPlaceName);
 //placeName - closing
    regexPlaceName= /<\/placeName>/g
    substPlaceName= '</span>'
    text = text.replace(regexPlaceName, substPlaceName);
 
  //persnames
    regexPersName= /<rs\s?(type=\"([^\x00-\x7F]*[aA-zZ]*)\")?(\sref=\"([^"']*)\")?>/g

    substPersName= '<span class="person teiPreviewperson persName $2"><a title="Open this person in a new window [$4]" target="_about" href="$4""><span class="teiPreviewIconperson">👤</span></a>'
            //+ '<a titles="$3" href="$3" target="_blank">'
/*            +'$1</span>'*/
    
    text = text.replace(regexPersName, substPersName);
    
 //persName - closing
    regexPersNameClosing= /<\/rs>/g
    substPersNameClosing= '</span>'
    text = text.replace(regexPersNameClosing, substPersNameClosing);
 
 //persnames
    regexPersName= /<persName\s?(type=\"([^\x00-\x7F]*[aA-zZ]*)\")?(\sref=\"(.*)\")?>/g

    substPersName= '<span class="person teiPreviewperson persName $2">'
            //+ '<a titles="$3" href="$3" target="_blank">'
/*            +'$1</span>'*/
    
    text = text.replace(regexPersName, substPersName);
    
 //persName - closing
    regexPersNameClosing= /<\/persName>/g
    substPersNameClosing= '</span>'
    text = text.replace(regexPersNameClosing, substPersNameClosing);
 
 
 //Names
    regexName= /<name(\snymRef=\"([^\x00-\x7F]*[aA-zZ]*)\")?(\stype=\"([^\x00-\x7F]*[aA-zZ]*)\")?(\sref=\"([^\x00-\x7F]*[aA-zZ]*)\")?>/g

    substName= '<span class="person teiPreviewperson name $4">'
            //+ '<a titles="$3" href="$3" target="_blank">'
/*            +'$1</span>'*/
    
    text = text.replace(regexName, substName);
    
 //persName - closing
    regexPersName= /<\/name>/g
    substPersName= '</span>'
    text = text.replace(regexPersName, substPersName);
 
    //rs - opening
    regex= /<rs type=\"([^\x00-\x7F]*[aA-zZ]*)\"(\sref=\"(http:\/\/([aA-zZ][0-9]*\.*\-*\/*)*)\")?>/g

    subst= '<div class=\"semanticAnnotation $1 teiPreview$1\">'
            +'<span class="annotationTag annotationTag$1">'
            + '<a title="$4" href="$4" target="_blank">'
            +'$1</a></span>'

    text = text.replace(regex, subst);
    
    //rs Keywords- opening
    regex=  /<rs type=\"subject\" key=\"([^"']*)\" ref=\"([^"']*)\"\s?>/g

    subst= '<span class=\"subject semanticAnnotation teiPreviewsubject\"'
            + ' data-toggle=\"tooltip\" data-placement=\"top\" title=\"$1 --> $2\" href="$2" target="_blank">'
            +'<span class="annotationTag annotationTagsubject">'
/*            + '<a title="$3AA" href="$2" target="_blank">'*/
            +'$1</span>'
            

//denarius

    text = text.replace(regex, subst);
    
    
    //rs - closing
    regexRs= /<\/rs>/g
    substRs= '</span>'
    text = text.replace(regexRs, substRs);
    
    //Words
    regexRs= /<w/g
    substRs= '<span class="word"'
    text = text.replace(regexRs, substRs);
    regexRs= /<\/w>/g
    substRs= '</span>'
    text = text.replace(regexRs, substRs);
    
    
    //Clean hyphens
    text = text.replace(/\s\-/g, "-");
   
   //supplied reason omitted
    regex= /<supplied reason=\"omitted\">(((\s?)[^\x00-\x7F]*[aA-zZ]*(\s?))*)<\/supplied>/g
    subst= "⟨$1⟩"
    text = text.replace(regex, subst);
    //supplied reason subaudible
    regex= /<supplied reason=\"subaudible\">(((\s?)[^\x00-\x7F]*[aA-zZ]*(\s?))*)<\/supplied>/g
    subst= "\($1\)"
    text = text.replace(regex, subst);  
   //del erasure
   text = text.replace(/<del rend=\"erasure\">/g, "⟦");
   text = text.replace(/<\/del>/g, "⟧");

/*console.log("test @ 471");*/

/*Cleaning erasure ]][[  */
text = text.replace(/⟧ ⟦/g, " ");
text = text.replace(/⟧⟦/g, " ");
text = text.replace(/⟧<expan><abbr>⟦/g, " ");
text = text.replace(/⟧<expan><abbr>\s⟦/g, " ");
text = text.replace(/⟧\s<expan><abbr>⟦/g, " ");
text = text.replace(/⟧\n?<\/span>\n?⟦/g, "</span>");
   
   /*
   //supplied reason lost
/\*    regexSuppliedReasonLost = /<supplied reason=\"lost\">((<?\S*?>?)*(<\/?\S*>?)*)<\/supplied>/g*\/
    regexSuppliedReasonLost = /<supplied reason=\"lost\">((?:(?:\s?)[^\x00-\x7F]*[aA-zZ]*(?:\s?))*)<\/supplied>/g

    substSuppliedReasonLost = "[$1]"
    text = text.replace(regexSuppliedReasonLost, substSuppliedReasonLost);
    */
    //supplied reason lost with certainty low
    regexSuppliedReasonLostCertaintyLow = /<supplied reason=\"lost\" cert=\"low\">(((?:\s?)[^\x00-\x7F]*[aA-zZ]*(?:\s?))*)<\/supplied>/g
    substSuppliedReasonLostCertaintyLow = "[$1?]"
    text = text.replace(regexSuppliedReasonLostCertaintyLow, substSuppliedReasonLostCertaintyLow);
    
    
/*console.log("test @ 492");*/

//supplied reason lost brutal
    text = text.replace(/<\/supplied>/g, ']');
    text = text.replace(/<supplied reason=\"lost\">/g, '[');
    


/*console.log("TESTFIN");*/
   
   
  /*  //Clean ][
    text = text.replace(/(<\/supplied>\[)/g, " ");*/

/*Cleaning converted ][]  */
text = text.replace(/\] \[/g, " ");
text = text.replace(/\]\[/g, " ");
text = text.replace(/\]<expan><abbr>\[/g, " ");
text = text.replace(/\]<expan><abbr>\s\[/g, " ");
text = text.replace(/\]\s<expan><abbr>\[/g, " ");
text = text.replace(/\]\n?<\/span>\n?\[/g, "</span>");

text = text.replace(/\]\s?<\/span>\s?\[/g, "</span>");
 
/*Cleaning [– – –]⟦ ERASURE*/
text = text.replace(/\[\– \– \–\]⟦/g, '⟦– – –');
    
//Cleaning expan and ex elements
text = text.replace(/<expan>/g, '');
text = text.replace(/<\/expan>/g, '');
text = text.replace(/<ex>/g, '');
text = text.replace(/<\/ex>/g, '');


/*/\*Cleaning \]👤\[*\/   ==>Not working*/
/*   text = text.replace(/\]\👤\[/g, ' ');*/

/*console.log("HTML conversion:" + text);*/
//Cleaning First br
//    console.log(countLb);
    if(countLb ==1 && text.substring(1, 7) == "<br />") {
     // console.log("yes " + text.substring(0, 6))
  //    text = text.substring(7)
    } else{
    //console.log("no " + text.substring(0, 7))
    //text= "<span class='lineNo no1'>1</span>" + text;
    };
    
//Masking rdg
text = text.replace(/<rdg>(.*)<\/rdg>/g, "");

return xmlCompliant + text; 
/*    '<div style="style: text-indent: -2em">' + text + "</div>";*/
};



