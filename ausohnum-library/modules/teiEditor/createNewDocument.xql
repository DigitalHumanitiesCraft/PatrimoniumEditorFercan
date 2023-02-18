(:~
: AusoHNum Library - teiEditor module
: This function is used to create a new document. Data from the front-end form is in @param data 
: @author Vincent Razanajao
: @return This function creates a new doc in a specific collection, and returns the updated list of documents to be displayed in the dashboard.
:)


xquery version "3.1";

import module namespace teiEditor="http://ausonius.huma-num.fr/teiEditor"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/teiEditor/teiEditorApp.xql";

import module namespace functx="http://www.functx.com";

import module namespace http="http://expath.org/ns/http-client" at "java:org.expath.exist.HttpClientModule";

declare namespace apc="http://patrimonium.huma-num.fr/onto#";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace dct = "http://purl.org/dc/terms/";
declare namespace dcterms="http://purl.org/dc/terms/";
declare namespace ev = "http://www.w3.org/2001/xml-events";
declare namespace geo = "http://www.w3.org/2003/01/geo/wgs84_pos#";
declare namespace lawdi="http://lawd.info/ontology/";
declare namespace owl="http://www.w3.org/2002/07/owl#";
declare namespace pleiades="https://pleiades.stoa.org/places/vocab#";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfs = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace spatial="http://geovocab.org/spatial#";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace thot = "http://thot.philo.ulg.ac.be/";
declare namespace xf = "http://www.w3.org/2002/xforms";
declare namespace local = "local";

declare option exist:timeout "60000";
declare variable $type := request:get-parameter('type', ());
declare variable $project:= request:get-parameter('project', ());
declare variable $data := request:get-data();
declare variable $template := collection( '/db/apps/' || $project || '/data/teiEditor/docTemplates')//.[@xml:id=$data//template/text()];
declare variable $newLine := "&#10;";

declare function local:convert2Epidoc($text as xs:string) as node(){
 (:let $text := replace($text, "\n", "NEWLINE"):)

(: Vacat. <hi rend="smallit"> vac.</hi>:)
let $text :=
    replace($text, '<hi rend="smallit">(\s?)vac\.(\s?)</hi>',
     '<space extent="unknown" unit="character"/>')



(:Line in lacuna – – – – at end of text:)
let $text :=
    replace($text, "<lb/>(\s?–\s–){1,}</ab>", '<gap reason="lost" extent="unknown" unit="line"/></ab>')

  (:Line in lacuna – – – – at beginning of text:)
let $text :=
    replace($text, "<lb/>(–\s–\s?){1,}", '<gap reason="lost" extent="unknown" unit="line"/>')

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


return
parse-xml("&lt;ab&gt;" 
(:        || $newLine :)
        || $text 
(:        || $newLine :)
        || "&lt;/ab&gt;") 
(:$text:)
    
};


switch ($type)
   case "external" return (

    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)
    let $userDetails := collection($teiEditor:data-repository-path || "accounts")/id($currentUser)
    
    let $doc-collection := collection($teiEditor:data-repository-path || "/documents/" || $data//collection/text())
    let $doc-collection-path := $teiEditor:data-repository-path || "/documents/" || $data//collection/text()
    let $collectionPrefix := doc($teiEditor:data-repository-path || "/documents/" || $data//collection/text() || ".xml")//docPrefix/text()
(:    let $docIdPrefix := $teiEditor:appVariables//idPrefix[@type='document']/text():)
    let $docIdList := for $id in $doc-collection//tei:TEI[contains(./@xml:id, $collectionPrefix)]
        return
        <item>
        {substring-after($id/@xml:id, $collectionPrefix)}
        </item>



(:Get document from external resource:)
let $sourceUri := $data//externalResource/text()
let $externalResourceDetails := $teiEditor:externalResources//.[@xml:id=$sourceUri]
let $UriPrefix := $externalResourceDetails/url[@type='teiDocPrefix']/text()
let $UriSuffix := $externalResourceDetails/url[@type='teiDocSuffix']/text()
let $externalDocId := $data//docId/text()
let $externalDocUri := $data//docUri/text()

(:let $logEventTEST := teiEditor:logEvent("document-new-TEST" , 'test-new-doc', (),
                        "$UriPrefix || $externalDocId || $UriSuffix:" || $UriPrefix || $externalDocId || $UriSuffix || " $externalDocId" || $externalDocId || " by " || $currentUser)
:)

let $url4httpRequest := 
                    if($externalDocUri !='' ) then 
                               (if(contains($externalDocUri, 'edh-www.adw.uni-heidelberg.de/edh/inschrift/')) then
                                            $externalDocUri || ".xml"
                                            else if(contains($externalDocUri, 'http://papyri.info/ddbdp')) then
                                            $externalDocUri || "/source"
                                            else())
                            else if ($externalDocId != "") then
                            $UriPrefix || $externalDocId || $UriSuffix
                            else ($UriPrefix || $externalDocId || $UriSuffix)
                            
                    
let $http-request-data := <request xmlns="http://expath.org/ns/http-client"
    method="GET" href="{$url4httpRequest}"/>




    let $responses :=
    http:send-request($http-request-data)

(:let $logEventTEST := teiEditor:logEvent("document-new-from-External-resource" , 'test-new-docdddd', <data>{ $responses }</data>,
                        "$responses:" || "ee" || " created in Collection " || $data//collection/text() || " by " || $currentUser )
:)

let $response :=
    <results>
      {if ($responses[1]/@status ne '200')
         then
             <failure>{$responses[1]}</failure>
         else
           <success>
             {$responses[2]}
             {'' (: todo - use string to JSON serializer lib here :) }
           </success>
      }
    </results>

        
(:let $newDocFromExternalResource := $response//*[local-name()="success"]:)

let $newDocFromExternalResource := $response//*[local-name()='TEI']


let $last-id:= fn:max($docIdList)
let $newDocId := $collectionPrefix || fn:sum(($last-id, 1))
let $newDocUri := $teiEditor:baseUri || "/" || "documents" ||"/" || $newDocId

let $filename := $newDocId || ".xml"


   let $storeNewFile := 
   xmldb:store($doc-collection-path, $filename, $newDocFromExternalResource)

   let $changeMod := sm:chmod(xs:anyURI(concat($doc-collection-path, "/", $filename)), "rw-rw-r--")
   let $changeGroup := sm:chgrp(xs:anyURI(concat($doc-collection-path, "/", $filename)), $data//collection/text())

   let $updateId := if(util:eval( "doc('" || $doc-collection-path ||"/" || $filename||"')")/tei:TEI/@xml:id) then
                            (update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/@xml:id
                            with $newDocId)
                            else 
                            (update insert attribute xml:id {$newDocId} into util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI)
  
(:let $updateTypeAtt := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:teiHeader/tei:profileDesc/tei:textClass/tei:catRef/@ref
                            with $data//typeAttributeValue/text()
:)
(:let $updateTypeText := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:teiHeader/tei:profileDesc/tei:textClass/tei:catRef/text()
                            with $data//scriptTextValue/text()
:)
(:let $updateMainLang := if (string-length($data//langAttributeValue/text()) > 0) then
                                update replace  util:eval( "doc('" || $doc-collection-path || "/" || $filename
                                ||"')")/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msContents/tei:msItem/tei:textLang/@mainLang
                                with $data//langAttributeValue/text()
                            else ():)
(:Update IDs and references to ID with ID of new doc:)

let $updateSurfaceID := 
                                if(util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:sourceDoc/tei:surface/@xml:id) then
                                update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:sourceDoc/tei:surface/@xml:id
                            with $newDocId || "-surface1"
                            else
                            if (util:eval( "doc('" || $doc-collection-path ||"/" || $filename ||"')")/tei:TEI/tei:sourceDoc/tei:surface)
                            then (
                            update insert attribute xml:id {$newDocId || "-surface1"} into util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:sourceDoc/tei:surface
                            )(:INSERT @xml:id:)
                            else if (util:eval( "doc('" || $doc-collection-path ||"/" || $filename ||"')")/tei:TEI/tei:sourceDoc)
                            then (
                            update insert 
                            functx:change-element-ns-deep(
<node>
                            <tei:surface xml:id="{$newDocId || '-surface1'}"></tei:surface>
</node>
, "http://www.tei-c.org/ns/1.0", "")/node()
into
                            util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:sourceDoc
                            )(:Insert /surface:)
                            else (
                            update insert 
                            functx:change-element-ns-deep(
<node>
    <tei:sourceDoc>
        <tei:surface xml:id="{$newDocId || '-surface1'}" ana="front-face">
            <desc>Main written surface of the monument</desc>
       </tei:surface>
   </tei:sourceDoc>
</node>
                            , "http://www.tei-c.org/ns/1.0", "")/node()
                            following
                            util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:teiHeader
                            )(:insert sourceDoc/surface/@xml:id='':)

let $updateLayoutID := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:layoutDesc/tei:layout/@xml:id
                            with $newDocId || "-layout1"
                            
                            
let $updateLayoutCorresp := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:layoutDesc/tei:layout/@corresp
                            with "#" || $newDocId || "-surface1"
let $updateMsItemID := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msContents/tei:msItem/@xml:id
                            with $newDocId || "-msItem1"
let $updateDivPartCorresp := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:text/tei:body/tei:div/tei:div[@type="edition"]/@corresp
                            with "#" || $newDocId || "-surface1"


let $creationNode :=
    <change who="{$currentUser}" when="{$now}">Creation of this file</change>

let $updateCreationChange := update replace util:eval( "doc('" || $doc-collection-path || "/" || $filename
                                ||"')")/tei:TEI/tei:teiHeader/tei:revisionDesc/tei:listChange/tei:change
                                with functx:change-element-ns-deep($creationNode, "http://www.tei-c.org/ns/1.0", "")




(:let $logEvent := teiEditor:logEvent("document-new" , $newDocId, (),
                        "New document " || $newDocId || " created in Collection " || $data//collection/text() || " by " || $currentUser)
:)    return
    <result><newDocId>{ $newDocId }</newDocId>
    <sentData>{ $data }</sentData>
    <newList>{ teiEditor:listDocuments() }</newList>
    </result>
)(:End of creation fromExtrenal:)

case "template" return 
(   
let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)
    let $userDetails := collection($teiEditor:data-repository-path || "accounts")/id($currentUser)
    let $doc-full-collection := collection($teiEditor:data-repository-path || "/documents")
(:    let $doc-collection := collection($teiEditor:data-repository-path || "/documents/" || $data//collection/text()):)
    let $doc-collection-path := $teiEditor:data-repository-path || "/documents/" || $data//collection/text()
    let $collectionPrefix := doc($teiEditor:data-repository-path || "/documents/" || $data//collection/text() || ".xml")//docPrefix/text()
(:    let $docIdPrefix := $teiEditor:appVariables//idPrefix[@type='document']/text():)
    let $docIdList := for $id in $doc-full-collection//tei:TEI[contains(./@xml:id, $collectionPrefix)]
        return
        <item>
        {substring-after($id/@xml:id, $collectionPrefix)}
        </item>



let $logEventTEST := teiEditor:logEvent("document-new-TEST" , 'test-new-doc', (),
                        "Test:" || $teiEditor:library-path || " created in Collection " || $data//collection/text() || " by " || $currentUser[1])




let $last-id:= fn:max($docIdList)
let $newDocId := $collectionPrefix || fn:sum(($last-id, 1))
let $newDocUri := $teiEditor:baseUri || "/" || "documents" ||"/" || $newDocId

let $filename := $newDocId || ".xml"


   let $storeNewFile := xmldb:store($doc-collection-path, $filename, $template)

   let $changeMod := sm:chmod(xs:anyURI(concat($doc-collection-path, "/", $filename)), "rw-rw-r--")
   let $changeGroup := sm:chgrp(xs:anyURI(concat($doc-collection-path, "/", $filename)), $data//collection/text())

   let $updateId := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/@xml:id
                            with $newDocId
  let $updateIDNOProject := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type="uri"]/text()
                            
                            with $newDocUri
                            
(:let $updateExternalResource :=  
                                    if($data//externalResource/text() != "") then 
                                    (
                                    let $externalResourceCode := data($teiEditor:externalResources//resource[starts-with(substring-after(./url[@type='teiDocPrefix'], "://"),
                                            substring-before(substring-after($data//externalResource/text(), '://'), "/"))]/@xml:id)
                        
                                    let $externalUriNode := <node>
                                       <idno type="{substring-before(substring-after($data//externalResource/text(), '://'), "/")}
                                       {$externalResourceCode}">{$data//externalResource/text()}</idno>
                                       </node>

                                    return update insert   
                                    functx:change-element-ns-deep($externalUriNode/node(), "http://www.tei-c.org/ns/1.0", "")
                                    following util:eval( "doc('" || $doc-collection-path ||"/" || $filename||"')")/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type="uri"]
                                    ) else()
:)       

let $updateExternalResource :=
    let $externalResourceNode :=
        if(
        ($data//externalResource/text() != "" )
        and
        ($data//externalResourceType/text() != "" )
        and 
        ($data//externalResourceSubtype/text() != "" )
        ) then <node>
        <altIdentifier>
            <idno type="{ $data//externalResourceType/text() }" 
            subtype="{ $data//externalResourceSubtype/text() }">{ $data//externalResource/text() }</idno></altIdentifier>
        </node>
            else()
    
    return
        if($externalResourceNode//idno)
        then update replace  
        util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:altIdentifier
                            with functx:change-element-ns-deep($externalResourceNode/node(), "http://www.tei-c.org/ns/1.0", "")
        else ()

    (:CP:)
    let $updatePID:= update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                    ||"')")/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type="PID"]/text()
                    with concat('o:fercan.', substring-after($newDocId, 'erior')) 

  let $updateTitle := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/tei:title[@type="main"]/text()
                            with $data//title/text()
  let $updateTypeAtt := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:teiHeader/tei:profileDesc/tei:textClass/tei:catRef/@target
                            with $data//typeAttributeValue/text()
let $updateTypeText := if($data//typeTextValue/text() != "") then update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:teiHeader/tei:profileDesc/tei:textClass/tei:catRef/text()
                            with $data//typeTextValue/text()
                            else()

let $updateMainLang := if ((string-length($data//langAttributeValue/text()) > 0) or ($data//langAttributeValue/text() != "undefined")) then
                                update replace  util:eval( "doc('" || $doc-collection-path || "/" || $filename
                                ||"')")/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msContents/tei:msItem/tei:textLang/@mainLang
                                with $data//langAttributeValue/text()
                            else ()
(:Update IDs and references to ID with ID of new doc:)

let $updateSurfaceID := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:sourceDoc/tei:surface/@xml:id
                            with $newDocId || "-surface1"

let $updateLayoutID := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:layoutDesc/tei:layout/@xml:id
                            with $newDocId || "-layout1"
let $updateLayoutCorresp := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:layoutDesc/tei:layout/@corresp
                            with "#" || $newDocId || "-surface1"
let $updateMsItemID := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msContents/tei:msItem/@xml:id
                            with $newDocId || "-msItem1"
let $updateDivPartCorresp := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:text/tei:body/tei:div/tei:div[@type="edition"]/@corresp
                            with "#" || $newDocId || "-surface1"

let $editorPersName := <node>
<persName ref="#{$currentUser}" corresp="{$userDetails//uri}">{$userDetails//firstname} {$userDetails//lastname}</persName>
</node>
let $updateEditor := update replace util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:text/tei:body/tei:div/tei:div[@type="edition"]/@corresp
                            with "#" || $newDocId || "-surface1"

(:
let $externalDocUri := $data//externalResource/text()

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

let $responses :=if($externalDocUri !="" ) then 
    http:send-request($http-request-data) else ()

let $response :=
    <results>
      {if ($responses[1]/@status ne '200')
         then
             <failurea>{$responses[1]}</failurea>
         else
           <success>
             {$responses[2]}
             {'' (\: todo - use string to JSON serializer lib here :\) }
           </success>
      }
    </results>

let $textDiv := $response//tei:div[@type='edition']

let $apparatusDiv := $response//tei:div[@type='apparatus']
let $noOfTextpart := count($textDiv//tei:div[@type="edition"])

let $checkIfAbIsChildOfTextPart := exists($textDiv//tei:div[@type="edition"]/tei:ab)
let $params :=
        <output:serialization-parameters
        xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
            <output:omit-xml-declaration value="yes"/>
            <output:method value="xml"/>
            <output:indent value="yes"/>
            <output:item-separator value="\n"/>
            <output:undeclare-prefixes value="yes"/>
        </output:serialization-parameters>

let $reconstructedDivEdition :=
    if($externalDocUri !="" ) then
        if($checkIfAbIsChildOfTextPart =true()) then $textDiv
            
        else if($textDiv//tei:ab) then 
                <tei:div type="edition" xmlns="http://www.tei-c.org/ns/1.0">
                {for $textPart in $textDiv//tei:ab
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
                        
                         local:convert2Epidoc(serialize($textPart/node(), $params))
                }}
                </tei:div>    
            
            
            
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
                        
                         local:convert2Epidoc(serialize($textPart/node(), $params))
                }}
                </tei:div>
  else()
  
  let $updateDivTextEdition :=
    if(exists($reconstructedDivEdition//tei:ab) ) then
                    update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:text/tei:body/tei:div[@type="edition"]
                            with  functx:change-element-ns-deep($reconstructedDivEdition, "http://www.tei-c.org/ns/1.0", "")
    else():)




let $creationNode :=
    <change who="{$currentUser}" when="{$now}">Creation of this file</change>

let $updateCreationChange := update replace util:eval( "doc('" || $doc-collection-path || "/" || $filename
                                ||"')")/tei:TEI/tei:teiHeader/tei:revisionDesc/tei:listChange/tei:change
                                with functx:change-element-ns-deep($creationNode, "http://www.tei-c.org/ns/1.0", "")




let $logEvent := teiEditor:logEvent("document-new" , $newDocId, (),
                        "New document " || $newDocId || " created in Collection " || $data//collection/text() || " by " || $currentUser[1])
    return
    <result><newDocId>{ $newDocId }</newDocId>
    <sentData>{ $data }</sentData>
    <newList>{ teiEditor:documentList($data//collection/text()) }</newList>
    </result>
)
 case "templateWithEditionFromExternalResource" return 
(   
let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)
    let $userDetails := collection($teiEditor:data-repository-path || "accounts")/id($currentUser)
    let $doc-full-collection := collection($teiEditor:data-repository-path || "/documents")
    let $doc-collection := collection($teiEditor:data-repository-path || "/documents/" || $data//collection/text())
    let $doc-collection-path := $teiEditor:data-repository-path || "/documents/" || $data//collection/text()
    let $collectionPrefix := doc($teiEditor:data-repository-path || "/documents/" || $data//collection/text() || ".xml")//docPrefix/text()
(:    let $docIdPrefix := $teiEditor:appVariables//idPrefix[@type='document']/text():)
    let $docIdList := for $id in $doc-full-collection//tei:TEI[contains(./@xml:id, $collectionPrefix)]
        return
        <item>
        {substring-after($id/@xml:id, $collectionPrefix)}
        </item>



(: let $logEventTEST := teiEditor:logEvent("document-new-TEST" , 'test-new-doc', (),
                        "Test:" || $teiEditor:library-path || " created in Collection " || $data//collection/text() || " by " || $currentUser[1])
 :)



let $last-id:= fn:max($docIdList)
let $newDocId := $collectionPrefix || fn:sum(($last-id, 1))
let $newDocUri := $teiEditor:baseUri || "/" || "documents" ||"/" || $newDocId

let $filename := $newDocId || ".xml"


   let $storeNewFile := xmldb:store($doc-collection-path, $filename, $template)

   let $changeMod := sm:chmod(xs:anyURI(concat($doc-collection-path, "/", $filename)), "rw-rw-r--")
   let $changeGroup := sm:chgrp(xs:anyURI(concat($doc-collection-path, "/", $filename)), $data//collection/text())

   let $updateId := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/@xml:id
                            with $newDocId
  let $updateIDNOProject := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type="uri"]/text()
                            
                            with $newDocUri
                            
(:let $updateExternalResource :=  
                                    if($data//externalResource/text() != "") then 
                                    (
                                    let $externalResourceCode := data($teiEditor:externalResources//resource[starts-with(substring-after(./url[@type='teiDocPrefix'], "://"),
                                            substring-before(substring-after($data//externalResource/text(), '://'), "/"))]/@xml:id)
                        
                                    let $externalUriNode := <node>
                                       <idno type="{substring-before(substring-after($data//externalResource/text(), '://'), "/")}
                                       {$externalResourceCode}">{$data//externalResource/text()}</idno>
                                       </node>

                                    return update insert   
                                    functx:change-element-ns-deep($externalUriNode/node(), "http://www.tei-c.org/ns/1.0", "")
                                    following util:eval( "doc('" || $doc-collection-path ||"/" || $filename||"')")/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type="uri"]
                                    ) else()
:)       

let $updateExternalResource :=
    let $externalResourceNode :=
        if(
        ($data//externalResource/text() != "" )
        and
        ($data//externalResourceType/text() != "" )
        and 
        ($data//externalResourceSubtype/text() != "" )
        ) then <node>
        <altIdentifier>
            <idno type="{ $data//externalResourceType/text() }" 
            subtype="{ $data//externalResourceSubtype/text() }">{ $data//externalResource/text() }</idno></altIdentifier>
        </node>
            else()
    
    return
        if($externalResourceNode//idno)
        then update replace  
        util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:altIdentifier
                            with functx:change-element-ns-deep($externalResourceNode/node(), "http://www.tei-c.org/ns/1.0", "")
        else ()

    
    (:CP:)
    let $updatePID:= update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                    ||"')")/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type="PID"]/text()
                    with concat('o:fercan.', substring-after($newDocId, 'erior')) 


  let $updateTitle := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/tei:title[@type="main"]/text()
                            with $data//title/text() 
  let $updateTypeAtt := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:teiHeader/tei:profileDesc/tei:textClass/tei:catRef/@target
                            with $data//typeAttributeValue/text()
let $updateTypeText := if($data//typeTextValue/text() != "") then update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:teiHeader/tei:profileDesc/tei:textClass/tei:catRef/text()
                            with $data//typeTextValue/text()
                            else()

let $updateMainLang := if (string-length($data//langAttributeValue/text()) > 0) then
                                update replace  util:eval( "doc('" || $doc-collection-path || "/" || $filename
                                ||"')")/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msContents/tei:msItem/tei:textLang/@mainLang
                                with $data//langAttributeValue/text()
                            else ()
(:Update IDs and references to ID with ID of new doc:)

let $updateSurfaceID := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:sourceDoc/tei:surface/@xml:id
                            with $newDocId || "-surface1"

let $updateLayoutID := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:layoutDesc/tei:layout/@xml:id
                            with $newDocId || "-layout1"
let $updateLayoutCorresp := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:layoutDesc/tei:layout/@corresp
                            with "#" || $newDocId || "-surface1"
let $updateMsItemID := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msContents/tei:msItem/@xml:id
                            with $newDocId || "-msItem1"
let $updateDivPartCorresp := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:text/tei:body/tei:div/tei:div[@type="edition"]/@corresp
                            with "#" || $newDocId || "-surface1"

let $editorPersName := <node>
<persName ref="#{$currentUser}" corresp="{$userDetails//uri}">{$userDetails//firstname} {$userDetails//lastname}</persName>
</node>
let $updateEditor := update replace util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:text/tei:body/tei:div/tei:div[@type="edition"]/@corresp
                            with "#" || $newDocId || "-surface1"


let $externalDocUri := $data//externalResource/text()

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

let $responses :=if($externalDocUri !="" ) then 
    http:send-request($http-request-data) else ()

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

let $textDiv := $response//tei:div[@type='edition']

let $apparatusDiv := $response//tei:div[@type='apparatus']
let $noOfTextpart := count($textDiv//tei:div[@type="edition"])

let $checkIfAbIsChildOfTextPart := exists($textDiv//tei:div[@type="edition"]/tei:ab)
let $params :=
        <output:serialization-parameters
        xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
            <output:omit-xml-declaration value="yes"/>
            <output:method value="xml"/>
            <output:indent value="yes"/>
            <output:item-separator value="\n"/>
            <output:undeclare-prefixes value="yes"/>
        </output:serialization-parameters>

let $reconstructedDivEdition :=
    if($externalDocUri !="" ) then
        if($checkIfAbIsChildOfTextPart =true()) then $textDiv
            
        else if($textDiv//tei:ab) then 
                <tei:div type="edition" xmlns="http://www.tei-c.org/ns/1.0">
                {for $textPart in $textDiv//tei:ab
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
                        local:convert2Epidoc(serialize($textPart/node(), $params))
                        }}
                </tei:div>    
            
            
            
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
                        
                         local:convert2Epidoc(serialize($textPart/node(), $params))
                }}
                </tei:div>
  else(<error>ERROR!</error>)
  
  let $updateDivTextEdition :=
    if(exists($reconstructedDivEdition) ) then
                    update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:text/tei:body/tei:div[@type="edition"]
                            with  functx:change-element-ns-deep($reconstructedDivEdition, "http://www.tei-c.org/ns/1.0", "")
    else()


let $creationNode :=
    <change who="{$currentUser}" when="{$now}">Creation of this file</change>

let $updateCreationChange := update replace util:eval( "doc('" || $doc-collection-path || "/" || $filename
                                ||"')")/tei:TEI/tei:teiHeader/tei:revisionDesc/tei:listChange/tei:change
                                with functx:change-element-ns-deep($creationNode, "http://www.tei-c.org/ns/1.0", "")




let $logEvent := teiEditor:logEvent("document-new" , $newDocId, (),
                        "New document " || $newDocId || " created in Collection " || $data//collection/text() || " by " || $currentUser[1])
    return
    <result><newDocId>{ $newDocId }</newDocId>
    <sentData>{ $data }</sentData>
    <newList>{ teiEditor:documentList($data//collection/text()) }</newList>
    </result>
)
   
    default return null
