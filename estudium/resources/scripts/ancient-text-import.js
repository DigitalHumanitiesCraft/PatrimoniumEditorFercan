function pointedCharacters2Epidoc(text){
        text = text.replace(/([aA-zZ])\x{323}/g, '<unclear>$1</unclear>');    //a
        //text = text.replace(/\u1E5B\/u/g, '<unclear>r</unclear>');    //r
        console.log("Texte dot ---:" + text);
        return text;
        
    };



function convertEDR2TEI(text){
    
    //console.log("test dotted: " + pointedCharacters2Epidoc(text));
    
    
    
    
    var htmlTagRegex = '/^(.*)|s+/>)$/';
    //Numbered lines to be removed
        regexNumberedLines =/\n([1-9]{1,3} )/g;
        const regexSubstNumberedLines = "\n";
   
   //text = pointedCharacters2Epidoc(text).replace(regexNumberedLines, regexSubstNumberedLines);
    //First Line
    text= "<lb n='1'/>" + text;
    
    
    //New lines
    var regexLine = /\n/g;
        index =0;
        text = text.replace(regexLine, function(match){
               
               return "\n<lb n='" + (index++ +2) + "'/>" ;
               });
               
    
    //Lines 5, 10, 15, etc.
    var regexLines5 = /\n<lb n=\'([0-9])\'\/>\1\s/g;
    var substLines5 = "\n<lb n='$1'/>";
    text = text.replace(regexLines5, substLines5);
               
    //New line breaking a word
    var regexLineInWord = /=\n<lb n=\'([0-9]*)\'\/>/g;
    var substLineInWord = "\n<lb n='$1' break='no'/>";
    text = text.replace(regexLineInWord, substLineInWord);
    
    //Abbreviations.
    var regexAbbrev = /([aA-zZ]*)\(([aA-zZ]*)\)/g;
    var substAbbrev = "<expan><abbr>$1</abbr><ex>$2</ex></expan>";
    text = text.replace(regexAbbrev, substAbbrev);


    //Line in lacuna [------]
    text = text.replace('\n\[------\]', '<gap unit="line" />');   
    //Line in lacuna ------
    text = text.replace(/(-){6}/g, '<gap unit="line" />');   
     
    //gap of 3?
    text = text.replace(/\[---\]/g, '<gap reason="lost" unit="caracter" extent="unknown"/>');
    
    
    //Line lost of unknown extent ; ------? 
    text = text.replace(/\------\?/g, '<gap reason="lost" extent="unknown" ' 
    + 'unit="line"><certainty match=".." locus="name"/></gap>');
    //Line lost of unknown extent ; [------?] 
    text = text.replace(/\[\------\?\]/g, '<gap reason="lost" extent="unknown" ' 
    + 'unit="line"><certainty match=".." locus="name"/></gap>');
    //Line lost of unknown extent ; [------?] 
    text = text.replace(/\[\---\?\]/g, '<gap reason="lost" extent="unknown" ' 
    + 'unit="line"><certainty match=".." locus="name"/></gap>');
    
    //illegible charactes +++
     var regexIllegibleCharacter = /([+])+/g;
        index =0;
        text = text.replace(regexIllegibleCharacter, function(match){
               console.log('Ici match:' + match.length);
               return "<gap reason='illegible' quantity='" + match.length +"' unit='character'/>" ;
               });
    
    
    
    //restituted text
    var regexTextInLacuna = /(\[)(\w*\s?\w*)(])/g;
    var substTextInLacuna = "<supplied reason='lost'>$2</supplied>";
    var text = text.replace(regexTextInLacuna, substTextInLacuna);
    
    //text + ---- in lacuna
    var regexTextandUnkInLacuna = /(\[)(\w*\s?\w*)(---)?(])/g;
    var substTextandUnkInLacuna = "<supplied reason='lost'>$2</supplied><gap reason='lost' />";
    var text = text.replace(regexTextandUnkInLacuna, substTextandUnkInLacuna);
    
    
    //text = text.replace('extent=\"8\" unit=\"letter\"', 'class="gap8letters"');
   
   //Dotted characters
    var regexDotted = /([aA-zZ])̣/g;
    var substDotted = '<unclear>$1</unclear>';
    text = text.replace(regexDotted, substDotted);    
    
    console.log("Converted text for preview: " + text);
    return text;
};
