xquery version "3.1";

import module namespace teiEditor="http://ausonius.huma-num.fr/teiEditor"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/teiEditor/teiEditorApp.xql";

import module namespace functx="http://www.functx.com";

import module namespace http="http://expath.org/ns/http-client" at "java:org.expath.exist.HttpClientModule";

declare boundary-space preserve;

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace local = "local";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:indent "yes";

declare variable $type := request:get-parameter('type', ());
declare variable $project:= request:get-parameter('project', ());
declare variable $data2 := request:get-data();
declare variable $tab := '&#9;';
declare variable $newLine := "&#10;";

declare function local:convert2Epidoc($text as xs:string){
   
 (:let $text := replace($text, "\n", "NEWLINE"):)

  (:Line in lacuna – – – – at end of text:)
let $text :=
    replace($text, "<lb/>(\s?–\s–){1,}</ab>", '<gap reason="lost" extent="unknown" unit="line"/></ab>')

  (:Line in lacuna – – – – at beginning of text:)
let $text :=
    replace($text, "<lb/>(–\s–\s?){1,}", '<gap reason="lost" extent="unknown" unit="line"/>')

(: Vacat. <hi rend="smallit"> vac.</hi>:)
let $text :=
    replace($text, '<hi rend="smallit"> vac.</hi>',
     '<space extent="unknown" unit="character"/>')

(:cleaning full line in lacuna:)
let $text := replace($text, "(/>.?<gap)", "/><gap")
(:cleaning full line in lacuna at end of text:)
let $text := replace($text, "/>–</ab>", "/></ab>")

  
  (:Correcting linebreak, ending with character:)
let $text :=
    replace($text, '([\w])–<lb\sn="([0-9]*)"\s?/>', '$1<lb n="$2" break="no"/>')
  
(:Correcting linebreak, ending with ]:)
let $text :=
    replace($text, '(\])–<lb\sn="([0-9]*)"\s?/>', '$1<lb n="$2" break="no"/>')

(:Start of line in lacuna no closing square bracket and no reconstructed text:)
(:
 – – – – – – – – – – – – – – – – – – – – – – – – –ν·
 : ]:)

let $text :=
    replace($text, "(>(–\s–\s?){1,}\s–)", '><gap reason="lost" extent="unknown" unit="character"/>')


(:End of line in lacuna with some reconstructions:)
(:σιλ̣[εῖ – – – –]:)

let $text :=
    replace($text, "(\w*)\[(\w*)(\s–){1,20}\]", '$1<supplied reason="lost">$2</supplied><gap reason="lost" extent="unknown" unit="character" />')

(:End of line in lacuna with some reconstructions, and no closing square bracket:)
(:σιλ̣[εῖ – – –]:)

(:let $text :=:)
(:    replace($text, "(\w*)\[(\w*)(\s–){1,20}", '$1<supplied reason="lost">$2</supplied><gap reason="lost" extent="unknown" unit="characterXXX" />'):)

(: [.]:)
let $text :=
    replace($text, "\[\.\]", '<gap reason="lost" quantity="1" unit="character"/>')


(: [ . οἱ παῖ]δ̣ες:)
let $text :=
    replace($text, "\[\s\.\s(.*)\]", '<gap reason="lost" quantity="1" unit="character"/><supplied reason="lostu">$1</supplied>')

(:[ .. ] βουλή:)
let $text :=
    replace($text, "\[\s\.\.\s\]", '<gap reason="lost" extent="unknown" unit="character"/>')

(: [ .. ἐπ]ὶ Δάλιον καὶ:)
let $text :=
    replace($text, "\[\s\.\.\s(\w*)\]", '<gap reason="lost" extent="unknown" unit="character"/><supplied reason="lost">$1</supplied>')

(:[οις – – – – – – – – – – – – – – – – – – – βασιλέως] Ἀττάλου οὐκ ἐλάσσω τα̣:)
let $text :=
    replace($text, "\[([α-ωΑ-Ω\s][^\s]*)((\s?–\s){1,20})([α-ωΑ-Ω\s][^\s]*)\]",
           '<supplied reason="lost">$1</supplied><gap reason="lost" extent="unknown" unit="character"/><supplied reason="lost">$4</supplied>') 

(:Simple [τοῖς π]αισὶ:)
let $text :=
    replace($text, "\[((\w*[^\]])*)\]", '<supplied reason="lost">$1</supplied>')

(:Patch to correct start of line in lacuna with opening square bracket and reconstructed text:)
(:
 [– – – – – – – – – – – – – – – – – – – – – εὔνους ὑ]πάρχων
 : ]:)

let $text :=
    replace($text, '(<supplied reason="lost">)(–\s?–\s?){1,}', '<gap reason="lost" extent="unknown" unit="character"/>$1')

(:Correcting hyphen after opening supplied when preceded by a gap:)
let $text :=
    replace($text, '(<supplied reason="lost">)–\s?', '$1')



let $text :=
    replace(replace($text, "\[", '<supplied reason="lost">'), "\]", "</supplied>")




(:End of line in lacuna without ending bracket at the end – – – – :)
let $text :=
    replace($text, "(\w)(\s–){1,}", '$1<gap reason="lost" extent="unknown" unit="character"/>')

(:Correcting end of lacuna:)
let $text :=
    replace($text, '<gap reason="lost" extent="unknown" unit="character"/> (–\s–\s?){1,}–</supplied>', '</supplied><gap reason="lost" extent="unknown" unit="character"/>')
(:Correcting gap inside supplied:)
 let $text :=
    replace($text, '<gap reason="lost" extent="unknown" unit="character"/></supplied>', '</supplied><gap reason="lost" extent="unknown" unit="character"/>')

(:Unclear characters with dot:)
let $text :=
    replace($text, "(\w?)̣",
     '<unclear>$1</unclear>')

(:supralinear lines:)
let $text :=
    replace($text, "(\w?)̅",
     '<hi rend="supraline">$1</hi>')

(:lb preceded by new lines:)
let $text :=
    replace($text, "<lb",
     $newLine ||'<lb')

(:Omitted letters]:)
let $text :=
    replace($text, '<(\w{1,2})>', '<supplied reason="omitted">$1</supplied>')

return
parse-xml("&lt;ab&gt;" 
(:        || $newLine :)
        || $text 
(:        || $newLine :)
        || "&lt;/ab&gt;") 
(:$text:)
    
};


let $externalDocUri := 
data($data2//docUri)
(:"http://telota.bbaw.de/ig/api/xml/IG%20XII%204,%201,%20281":)


let $url4httpRequest := 
                    if($externalDocUri !='' ) then 
                               (if(contains($externalDocUri, 'edh-www.adw.uni-heidelberg.de/edh/inschrift/')) then
                                            $externalDocUri || ".xml"
                               else if(contains($externalDocUri, 'http://papyri.info/ddbdp')) then
                                            $externalDocUri || "/source"
                               else if(contains($externalDocUri, 'http://mama.csad.ox.ac.uk/monuments/MAMA-XI')) then
                                            (
                                            let $externalDocId := substring-before(substring-after($externalDocUri, "http://mama.csad.ox.ac.uk/monuments/"), ".html")
                                            return 
                                            "http://mama.csad.ox.ac.uk/xml/" || $externalDocId || ".xml"
                                            )
                                            else $externalDocUri)
                            else ()





let $http-request-data := <request xmlns="http://expath.org/ns/http-client"
    method="get" href="{$url4httpRequest}">
        <header name="Content-Type" value="text/xml; charset=utf-8/"/>
    </request>

let $responses :=
    http:send-request($http-request-data)

let $response :=
    <results>
      {if ($responses[1]/@status ne '200')
         then
             <failurea>{$responses[1]}</failurea>
         else
           <success>
             {$responses[2]}
             {'' (: todo - use string to JSON serializer lib here :) }
           </success>
      }
    </results>
let $params :=
        <output:serialization-parameters
        xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
            <output:omit-xml-declaration value="yes"/>
            <output:method value="xml"/>
            <output:indent value="yes"/>
            <output:item-separator value="\n"/>
            <output:undeclare-prefixes value="yes"/>
        </output:serialization-parameters>
let $paramMap :=
        map {
            "method": "xml",
            "indent": true(),
            "item-separator": ""

   }
        
let $textDiv := $response//tei:div[@type='edition']
let $apparatusDiv := $response//tei:div[@type='apparatus']
let $noOfTextpart := count($textDiv//tei:div[@type="edition"])
let $checkIfAbIsChildOfTextPart := exists($textDiv//tei:div[@type="edition"]/tei:ab)
let $reconstructedDivEdition :=
        if($checkIfAbIsChildOfTextPart =true()) then $textDiv
            else
                <tei:div type="edition" xmlns="http://www.tei-c.org/ns/1.0">
                {for $textPart in $textDiv//tei:div[@type="edition"]
                    return 
                        element {"tei:div"}
                        {
                        attribute {"type"} {"textpart"},
                        if(exists($textPart/@subtype)) then 
                            attribute {"subtype"} { $textPart/@subtype}
                            else()
                        ,
                        if(exists($textPart/@n)) then 
                            attribute {"n"} { $textPart/@n}
                            else(),
                        
                         local:convert2Epidoc(serialize($textPart, $params))
(:                         local:convert2Epidoc($textPart):)
                }}{ $newLine}
                </tei:div>
                
return
    ($reconstructedDivEdition,
    $externalDocUri,
    $response)