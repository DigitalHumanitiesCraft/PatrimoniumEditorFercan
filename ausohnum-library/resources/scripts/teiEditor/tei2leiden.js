function tei2leiden(text){
    //1st line: indent for align with following lines
    if(text.startsWith("<lb")) {
      //  console.log("Statrt with");
    } else{
    //console.log("NO Statrt with");
    text= "<span class='lineNo no3'>1</span>" + text;
    }
    //lb into br
    regexLB = /<lb n=\"([0-9]*)\"\/>/g
    substLB = "\n<br /><span class='lineNo no$1'>$1</span>";
    text = text.replace(regexLB, substLB);
    
    //lb with break no into br
    regexLB = /<lb n=\"([0-9]*)\"( break=\"no\")\/>/g
    substLB = "-\n<br /><span class='lineNo no$1'>$1</span>";
    text = text.replace(regexLB, substLB);
    
    //lb with xml:idinto br
    regexLB = /<lb xml:id=\".*\" n=\"([0-9]*)\"\/>/g
    substLB = "\n<br /><span class='lineNo no$1'>$1</span>";
    text = text.replace(regexLB, substLB);
    
    //glyph with hedera
    regex = /<g type=\"hedera\"\/>/g
    subst = "❦";
    text = text.replace(regex, subst);
    
    //glyph with hedera
    regex = /<g type=\"interpunct\"\/>/g
    subst = "▴";
    text = text.replace(regex, subst);
    
    //sic
    regex = /\s*<sic>(.*)<\/sic>\s*/g
    subst = "";
    text = text.replace(regex, subst);

    //corr
    regex = /<corr>(.*)<\/corr>\s*/g
    subst = "($1)";
    text = text.replace(regex, subst);
    //corr
    regex = /<orig>(.*)<\/orig>\s*/g
    subst = "$1";
    text = text.replace(regex, subst);
    
    //supplied 
    regexSupplied = /<supplied(\s.[^\/]*)?>(\S*)<\/supplied>/g
    substSupplied = "[$2]"
    text = text.replace(regexSupplied, substSupplied);

   //supplied reason lost
    regexSuppliedReasonLost = /<supplied reason=\"lost\">((<?\S*?>?)*(<\/?\S*>?)*)<\/supplied>/g
    substSuppliedReasonLost = "[$2]"
    text = text.replace(regexSuppliedReasonLost, substSuppliedReasonLost);
    
    //supplied reason lost with certainty low
    regexSuppliedReasonLostCertaintyLow = /<supplied reason=\"lost\" certainty=\"low\">((<?\S*>?)*(<\/?\S*>?)*)<\/supplied>/g
    substSuppliedReasonLostCertaintyLow = "[$2 ?]"
    text = text.replace(regexSuppliedReasonLostCertaintyLow, substSuppliedReasonLostCertaintyLow);


    //expan
    regexExInExpan = /\s*(\<ex\>)(\S*)(\<\/ex\>)\s*/g
    substExInExpan = "($2)"
    text = text.replace(regexExInExpan, substExInExpan);

    //expan with uncertain resolution
    regexExInExpan = /(\<ex cert=\"low\">)(\S*)(\<\/ex\>)/g
    substExInExpan = "($2 ?)"
    text = text.replace(regexExInExpan, substExInExpan);

    //unclear into dotted character
    regexUnclear = /<unclear>(\S*)<\/unclear>/g
    substUnclear = "$1" + '\u0323'
  
    
    
    text = text.replace(regexUnclear, function(match){
                text = match.substring(match.indexOf('>') +1, match.indexOf('</'));
                console.log("text: " + text);
                var is = text.length;
                var unclearText="";
                        for (var i = 0; i < text.length; i++) {
                            console.log("Character at index " +i + ": " + text.charAt(i));
                            console.log("letter with dot: " + text.charAt(i) + '\u0323');
                             unclearText += text.charAt(i) + '\u0323';
                            console.log(unclearText);
                        }
                    return unclearText;
                    
               //console.log("match = " + match);
               
               });
    
    
    //Remoe br first line
    regexUnclear = "<br /><span class='lineNo no1'>"
    substUnclear = "<span class='lineNo no1'>"
    text = text.replace(regexUnclear, substUnclear);
   // console.log("Converted text for preview: " + text);
    
    
/*
 * ***************************
 *   Semantic annotations    *
 * ***************************
 */
    //rs - opening
    regex= /<rs type=\"(\w*)\"(\sref=\"(.*)\")?>/g

    subst= '<div class=\"semanticAnnotation $1 teiPreview$1\">'
            +'<span class="annotationTag annotationTag$1">'
            + '<a title="$3" href="$3" target="_blank">'
            +'$1</a></span>'

    text = text.replace(regex, subst);
    
    //rs - closing
    regexRs= /<\/rs>/g
    substRs= '</div>'
    text = text.replace(regexRs, substRs);
    
    
    return text;
};



