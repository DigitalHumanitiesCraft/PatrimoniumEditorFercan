(:~
: AusoHNum Library - commons module
: This module contains functions to build XHTML
: @author Vincent Razanajao
:)


xquery version "3.1";

module namespace ausohnumCommons="http://ausonius.huma-num.fr/commons";
import module namespace spatiumStructor="http://ausonius.huma-num.fr/spatiumStructor"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/spatiumStructor/spatiumStructor.xql";
import module namespace prosopoManager="http://ausonius.huma-num.fr/prosopoManager"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/prosopoManager/prosopoManager.xql";
import module namespace teiEditor="http://ausonius.huma-num.fr/teiEditor"
      at "../teiEditor/teiEditorApp.xql";
import module namespace functx="http://www.functx.com";
(:import module namespace httpclient="http://exist-db.org/xquery/httpclient" at "java:org.exist.xquery.modules.httpclient.HTTPClientModule";:)
import module namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/" at "../skosThesau/skosThesauApp.xql";
(:import module namespace tan="http://alpheios.net/namespaces/text-analysis" at "./cts-3/textanalysis_utils.xquery";:)
import module namespace templates="http://exist-db.org/xquery/templates" ;
(:import module namespace config="http://patrimonium.huma-num.fr/config" at "../config.xqm";:)
import module namespace kwic="http://exist-db.org/xquery/kwic";

declare boundary-space preserve;

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";

declare namespace apc="http://patrimonium.huma-num.fr/onto#";
declare namespace ausohnum= "http://ausonius.huma-num.fr/onto";
declare namespace bibo="http://purl.org/ontology/bibo/";
declare namespace cito="http://purl.org/spar/cito/";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace dct = "http://purl.org/dc/terms/";
declare namespace dcterms="http://purl.org/dc/terms/";
declare namespace err = "http://www.w3.org/2005/xqt-errors";
declare namespace ev = "http://www.w3.org/2001/xml-events";
declare namespace foaf = "http://xmlns.com/foaf/0.1/";
declare namespace geo = "http://www.w3.org/2003/01/geo/wgs84_pos#";
declare namespace lawd="http://lawd.info/ontology/";
declare namespace owl="http://www.w3.org/2002/07/owl#";
declare namespace pleiades="https://pleiades.stoa.org/places/vocab#";
declare namespace prism="http://prismstandard.org/namespaces/basic/2.0/";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfs = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace spatial="http://geovocab.org/spatial#";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace thot = "http://thot.philo.ulg.ac.be/";
declare namespace xf = "http://www.w3.org/2002/xforms";
declare namespace local = "local";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
(:declare option output:item-separator "&#xa;";:)

declare variable $ausohnumCommons:library-path := "/db/apps/ausohnum-library/";
declare variable $ausohnumCommons:project :=request:get-parameter('project', ());
declare variable $ausohnumCommons:appVariables := doc("/db/apps/" || $ausohnumCommons:project || "/data/app-general-parameters.xml");
declare variable $ausohnumCommons:data := request:get-data();
declare variable $ausohnumCommons:docId :=  request:get-parameter("docid", ());
declare variable $ausohnumCommons:resourceType :=  request:get-parameter("resourceType", ());
declare variable $ausohnumCommons:lang :=request:get-parameter("lang", "en");
declare variable $ausohnumCommons:languages := $ausohnumCommons:appVariables//languages;


(:declare variable $ausohnumCommons:project := "patrimonium";:)
declare variable $ausohnumCommons:data-repository := collection("/db/apps/" || $ausohnumCommons:project || "Data");
declare variable $ausohnumCommons:data-repository-path := "/db/apps/" || $ausohnumCommons:project || "Data";

declare variable $ausohnumCommons:docCollection-path := $ausohnumCommons:data-repository-path || "/documents";
declare variable $ausohnumCommons:docCollection := collection($ausohnumCommons:docCollection-path);
declare variable $ausohnumCommons:conceptCollection-path := "/db/apps/" || $ausohnumCommons:appVariables//thesaurus-app/text() || "Data/concepts";
declare variable $ausohnumCommons:conceptCollection := collection( $ausohnumCommons:conceptCollection-path);
declare variable $ausohnumCommons:biblioRepo := doc($ausohnumCommons:data-repository-path || "/biblio/biblio.xml");
declare variable $ausohnumCommons:resourceRepo := collection($ausohnumCommons:data-repository-path || "/resources");
declare variable $ausohnumCommons:peopleRepo := doc($ausohnumCommons:data-repository-path || "/people/people.xml");
declare variable $ausohnumCommons:peopleCollection-path := $ausohnumCommons:data-repository-path || "/people";
declare variable $ausohnumCommons:peopleCollection := collection($ausohnumCommons:peopleCollection-path);
declare variable $ausohnumCommons:placeCollection-path := collection($ausohnumCommons:data-repository-path || "/places");
declare variable $ausohnumCommons:allPlaceCollection := collection($ausohnumCommons:placeCollection-path);
declare variable $ausohnumCommons:projectPlaceCollection := collection($ausohnumCommons:data-repository-path || "/places/" || $ausohnumCommons:project);
declare variable $ausohnumCommons:placeRepo := doc($ausohnumCommons:data-repository-path || "/places/listOfPlaces.xml");

declare variable $ausohnumCommons:baseUri := $ausohnumCommons:appVariables//uriBase[@type='app']/text();


declare variable $ausohnumCommons:teiElements := doc($ausohnumCommons:library-path || 'data/teiEditor/teiElements.xml');
declare variable $ausohnumCommons:teiElementsCustom := doc("/db/apps/" || $ausohnumCommons:project || '/data/teiEditor/teiElements.xml');
declare variable $ausohnumCommons:placeElements := doc($ausohnumCommons:library-path || 'data/spatiumStructor/placeElements.xml');
declare variable $ausohnumCommons:placeElementsCustom := doc("/db/apps/" || $ausohnumCommons:project || '/data/spatiumStructor/placeElements.xml');
declare variable $ausohnumCommons:peopleElements := doc($ausohnumCommons:library-path || 'data/prosopoManager/peopleElements.xml');
declare variable $ausohnumCommons:peopleElementsCustom := doc("/db/apps/" || $ausohnumCommons:project || '/data/prosopoManager/peopleElements.xml');

declare variable $ausohnumCommons:docTemplates := collection($ausohnumCommons:library-path || 'data/teiEditor/docTemplates');

declare variable $ausohnumCommons:teiTemplate := doc($ausohnumCommons:library-path || 'data/teiEditor/teiTemplate.xml');
declare variable $ausohnumCommons:externalResources := doc($ausohnumCommons:library-path || 'data/teiEditor/externalResources.xml');
declare variable $ausohnumCommons:teiDoc := $ausohnumCommons:docCollection/id($ausohnumCommons:docId) ;
declare variable $ausohnumCommons:docTitle :=  $ausohnumCommons:teiDoc//tei:fileDesc/tei:titleStmt/tei:title/text() ;

declare variable $ausohnumCommons:logs := collection($ausohnumCommons:data-repository-path || '/logs');
declare variable $ausohnumCommons:now := fn:current-dateTime();
declare variable $ausohnumCommons:currentUser := data(sm:id()//sm:username);
declare variable $ausohnumCommons:userStatus :=request:get-parameter('userStatus', ());
declare variable $ausohnumCommons:currentUserUri := concat($ausohnumCommons:baseUri, '/people/' , data(sm:id()//sm:username));
declare variable $ausohnumCommons:zoteroGroup :=request:get-parameter('zoteroGroup', ());
declare variable $ausohnumCommons:nl := "&#10;"; (:New Line:)

declare
    %templates:wrap
function ausohnumCommons:variables($docId as xs:string, $project as xs:string, $docType as xs:string?){
    <div class="hidden">
        <div id="currentDocId">{ $docId }</div>
        <div id="currentProject">{ $project }</div>
        <div id="docType">{ $docType }</div>
    </div>
};

declare %templates:wrap
    function ausohnumCommons:navBar($node as node(), $model as map(*)){ausohnumCommons:navBar()
    };
declare %templates:wrap
    function ausohnumCommons:navBar(){
    <div class="collapse navbar-collapse navbarCollapse col-xs-12 col-sm-12 col-md-12" id="datanavbar">
            <ul class="nav navbar-nav">
                <li id="datanavbar-documents" class="col-xs-2 col-sm-2 col-md-2"><a href="/documents/list/">Documents</a></li>
                <li id="datanavbar-people" class="col-xs-2 col-sm-2 col-md-2"><a href="/people/list/">People</a></li>
                <li id="datanavbar-places" class="col-xs-2 col-sm-2 col-md-2"><a href="/places/list/">Places</a></li>
                <li id="datanavbar-atlas" class="col-xs-2 col-sm-2 col-md-2"><a href="/atlas/map/">Map</a></li>
                <li id="datanavbar-thesaurus" class="col-xs-2 col-sm-2 col-md-2"><a href="#">Thesaurus</a></li>
                <li id="datanavbar-biblio" class="col-xs-2 col-sm-2 col-md-2"><a href="https://www.zotero.org/groups/2094917">Bibliography</a></li>
                { if($ausohnumCommons:userStatus = "editor") then
                      let $url := (
                                (
                                switch( $ausohnumCommons:resourceType)
                                case "document" return "/edit-documents/"
                                case "place" return "/edit-places/"
                                case "people" return "/edit-people/"
                                default return "/documents/")
                                ||  $ausohnumCommons:docId)
                          return
                        <li><a class="btn-primary" href="{ $url }">Edit</a></li>
                        else()
                }
            </ul>
        </div>
    
    };
declare function ausohnumCommons:displayElement(
                                          $elementNickname as xs:string,
                                          $overwriteTitle as xs:string?,
                                          $labelType as xs:string?,
                                          $index as xs:int?,
                                          $xpath_root as xs:string?){
        let $elementNode :=
            switch($ausohnumCommons:resourceType)
                case("document") return 
                                if (not(exists($ausohnumCommons:teiElementsCustom//teiElement[nm=$elementNickname]))) 
                                        then $ausohnumCommons:teiElements//teiElement[nm=$elementNickname] 
                                        else $ausohnumCommons:teiElementsCustom//teiElement[nm=$elementNickname]
                case ("place") return
                                if (not(exists($ausohnumCommons:placeElementsCustom//xmlElement[nm=$elementNickname]))) 
                                        then $ausohnumCommons:placeElements//xmlElement[nm=$elementNickname] 
                                        else $ausohnumCommons:placeElementsCustom//xmlElement[nm=$elementNickname]
                 case ("people") return
                                if (not(exists($ausohnumCommons:peopleElementsCustom//xmlElement[nm=$elementNickname]))) 
                                        then $ausohnumCommons:peopleElements//xmlElement[nm=$elementNickname] 
                                        else $ausohnumCommons:peopleElementsCustom//xmlElement[nm=$elementNickname]
                default return  if (not(exists($ausohnumCommons:teiElementsCustom//xmlElement[nm=$elementNickname]))) 
                                        then $ausohnumCommons:teiElements//xmlElement[nm=$elementNickname] 
                                        else $ausohnumCommons:teiElementsCustom//xmlElement[nm=$elementNickname]
                                        
         let $elementIndex := if ($index ) then ("[" || string($index) || "]" ) else ("")
         let $fieldType := $elementNode/fieldType/text()
         let $attributeValueType := $elementNode/attributeValueType/text()
         let $elementDataType :=$elementNode/contentType/text()
         let $elementCardinality := $elementNode/cardinality/text()
         let $conceptTopId := if($elementNode/thesauDb/text()) then
                        substring-after($elementNode/thesauTopConceptURI, '/concept/')
                        else()
             
         let $xpathRaw := $elementNode/xpath/text()    
         let $xpathEnd := if(contains($xpathRaw, "/@"))
                    then( functx:substring-before-last($xpathRaw[1], '/') || $elementIndex || "/" || functx:substring-after-last($xpathRaw[1], '/'))
                    else($xpathRaw)
         let $elementAncestors := if($ausohnumCommons:resourceType ="document")
                                                        then $elementNode/ancestor::teiElement
                                                        else $elementNode/ancestor::xmlElement
                            
         let $XPath := if($xpath_root)
                    then
                        $xpath_root || $xpathRaw
                    else
                            if($elementNode/ancestor::teiElement or $elementNode/ancestor::xmlElement )
                                then
                                    string-join(
                                    for $ancestor at $pos in $elementAncestors
                                    let $ancestorIndex := if($pos = 1 ) then
                                        if($index) then "[" || string($index) || "]" else ("")
                                        else ("")
                                    return
                                    if (contains($ancestor/xpath/text(), '/@'))
                                    then
                                        substring-before($ancestor/xpath/text(), '/@')
                                        || $ancestorIndex
                                        else $ancestor/xpath/text() ||
                                        $ancestorIndex
                                    )
                                 || $xpathEnd
                            else
                        $xpathEnd
                        
                 let $xpathBaseForCardinalityX :=
                        if (contains($XPath, "/@")) then
            (:            (functx:substring-before-last(functx:substring-before-last($XPath, "/@"), '/')):)
            
                        (functx:substring-before-last($XPath, "/@"))
            
                        else
                            (""||functx:substring-before-last($XPath, '/')||"")

             let $selectorForCardinalityX :=
                    if (contains($XPath, "/@")) then
                    (functx:substring-after-last($XPath, "/"))
                    else
                        (functx:substring-after-last($XPath, "/"))
               (:let $selectorForCardinalityX :=
                    if (contains($XPath, "/@")) then
                    (functx:substring-after-last(functx:substring-before-last($XPath, "/@"), "/"))
                    else
                        (functx:substring-after-last($XPath, "/")):)
                        
                let $resource-path := 
                    switch($ausohnumCommons:resourceType)
                        case "document" return $ausohnumCommons:docCollection-path
                        case "place" return $ausohnumCommons:placeCollection-path
                        case "people" return $ausohnumCommons:peopleCollection-path
                        default return $ausohnumCommons:docCollection-path
                let $resource := 
                    switch($ausohnumCommons:resourceType)
                        case "document" return $ausohnumCommons:docCollection/id($ausohnumCommons:docId )
                        case "place" return 
                                    let $resourceUri := $spatiumStructor:uriBase || "/places/" || $ausohnumCommons:docId || "#this"
                                    return $ausohnumCommons:projectPlaceCollection//spatial:Feature[@rdf:about = $resourceUri ]
                        case "people" return
                            let       $resourceUri := $spatiumStructor:uriBase || "/people/" || $ausohnumCommons:docId || "#this"
                            return $ausohnumCommons:peopleCollection//lawd:person[@rdf:about= $resourceUri ]
                        default return ""
              
              let $elementRoot := 
                    switch($ausohnumCommons:resourceType)
                        case "document" return "/id("
                        case "place" return ""
                        case "people" return "'lawd:person[@rdf:about='" ||$ausohnumCommons:docId ||"']"
                        default return ""
                let $elementValue :=
                        if($elementCardinality = "1" ) then (
                         util:eval( "$resource" || $XPath ))
                        
                        else if($elementCardinality = "x" ) then (
                            if( ($xpathBaseForCardinalityX != $selectorForCardinalityX)
                                and ($selectorForCardinalityX != ""))
                                then  util:eval( "$resource/" || $xpathBaseForCardinalityX 
                                        || "//" || $selectorForCardinalityX)
                                else util:eval( "$resource/" || $xpathBaseForCardinalityX)
                           )          
                         else(util:eval(  "$resource" || $XPath ))
                let $valuesTotal := count($elementValue)
                    
         let $label :=
                    if(starts-with($labelType, "groupParent")) then ausohnumCommons:elementLabel($elementAncestors/formLabel[@xml:lang=$ausohnumCommons:lang]/text(),
                                                                            substring-after($labelType, "-"),
                                                                            $xpathRaw)
                else if($overwriteTitle != "") then 
                            ausohnumCommons:elementLabel($overwriteTitle,
                                                                            $labelType,
                                                                            $xpathRaw)
                 
                else
                            ausohnumCommons:elementLabel($elementNode/formLabel[@xml:lang=$ausohnumCommons:lang]/text(),
                                                                            $labelType,
                                                                            $xpathRaw)
         let $inlineClassElement := if ($labelType = "inLinePlainText") then " inLinePlainText" else ()
         return
            if
            (:(not(data($elementValue))):)
            (normalize-space($elementValue[1]) = "" ) 
            then ()
            else
         <div class="xmlElementGroup{ $inlineClassElement }" >{ $label }
         {(:         if($valuesTotal > 1) then  :)
            for $value at $pos in $elementValue
                let $value2Bedisplayed:=
                    switch($elementDataType)
                            case "text" return 
                                    if(starts-with(data($value), "http")) then <a href="{ data($value) }" target="blank">{ data($value) }</a>
                                    else 
                                        let $valueLang := if((data($value/@xml:lang) != "") and (count($elementValue) > 1)) then " (" || data($value/@xml:lang) || ")" else ()
                                        return
                                        (data($value) || $valueLang)
                            case "attribute" return
                                    if(starts-with($value, "http") and (exists($attributeValueType)) and ($attributeValueType != "")) then 
                                        <a href="{ $value }" target="blank">{ skosThesau:getLabel($value, $attributeValueType) }</a>
                                    else if(starts-with($value, "http") and (not(exists($attributeValueType)))) then 
                                        <a href="{ data($value) }" target="blank">{ data($value) }</a>
                                    else  data($value) 
                            case "textNodeAndAttribute" return
                                  if(starts-with($value, "http")) then 
                                    <a href="{ $value }" target="blank">{ skosThesau:getLabel($value, $attributeValueType) }</a>
                                    
                                    else  if($value != "") then skosThesau:getLabel($value, $attributeValueType) || " [" || $value || "]" else "Error: No value" 
                            case "enrichedText" return 
                                    $value
                            default return $value/text()
               let $valueSeparator := 
                        switch($elementDataType)
                            case "text" 
                                return
                                    if(contains(lower-case($elementNickname), "date")) then <i> or </i> else ", " 
                            case "attribute" return " "
                            default return " "
               return
                    if(data($value2Bedisplayed) = "") then ("No value: " || data($value) || " attributeValueType" || ($attributeValueType = "")) else     
                    (
                    <span id="elementValue_{$elementNickname }_{ $index }" class="elementValue">
                    { $value2Bedisplayed }</span>
                    , if($pos < count($elementValue)) then $valueSeparator else ()
                    
                    
                    )
                    }
           </div>
           
         (:else
         let $value2Bedisplayed:=
                switch($elementDataType)
                    case "text" case "attribute" return $elementValue
                    case "textNodeAndAttribute" return 
                            skosThesau:getLabel($elementValue, $attributeValueType)
                    default return $elementValue
                return
                    ausohnumCommons:elementLabel($elementNode/formLabel[@xml:lang=$ausohnumCommons:lang]/text(), $labelType, $xpathRaw) || $value2Bedisplayed:)
};

declare function ausohnumCommons:biblioAndResourcesList($resource as node()?, $biblioType as xs:string){
let $resourceType   := 
        switch(lower-case(string(node-name($resource))))
         case "tei" return "biblio"
         case "lawd:person" return "seeFurther"
        default return "seeFurther"
let $refs := 
                switch($resourceType)
                case "biblio" return
                    $resource//tei:text/tei:body/tei:div[@type='bibliography'][@subtype=$biblioType]/tei:listBibl//tei:bibl
                case "seeFurther" return ($resource//cito:citesForInformation)
                    
                default return $resource//tei:text/tei:body/tei:div[@type='bibliography'][@subtype=$biblioType]/tei:listBibl//tei:bibl 

   return
   if($refs) then
<div id="resourcesManager{ $resourceType }" class="xmlElementGroup" >
   <div class="xmlElementGroupHeaderInline">{ausohnumCommons:elementLabel(
        (switch($biblioType)
                                                        case 'edition' return "Main edition(s)"
                                                        case 'seeFurther' case "secondary" return 'Bibliography'
                                                        default return $biblioType), "simple", ())}
   
</div>
      <div id="{ $resourceType }List" class="resourceList">
   {if($biblioType = "edition") then ( 
            for $resource at $pos in $refs
                  let $ref := ausohnumCommons:displayResource($resource, $resourceType, $pos)
            return $ref)
        else(
            for $resource at $pos in $refs
              let $ref := ausohnumCommons:displayResource($resource, $resourceType, $pos)
              order by $ref
            return $ref)    
               }
   </div>
   </div>
   else()
   };

declare function ausohnumCommons:displayBibRef($bibRef as node(),
                            $refType as xs:string,
                            $index as xs:int){
    let $targetType := if(starts-with($bibRef/tei:ptr/@target, "#")) then "ref" else "uri"
    let $bibId := if( $targetType ="ref") then substring(data($bibRef[1]/tei:ptr/@target), 2)
                                    else data($bibRef/tei:ptr/@target)
    let $teiBibRef := if( $targetType ="ref") then $ausohnumCommons:biblioRepo/id($bibId)
                                else $ausohnumCommons:biblioRepo//tei:biblStruct[matches(./@corresp, $bibId)]
    let $authorLastName := <span class="lastname">{ 
                if($teiBibRef[1]//tei:author[1]/tei:surname) then 
                        if(count($teiBibRef[1]//tei:author) = 1) then data($teiBibRef[1]//tei:author[1]/tei:surname)
                        else if(count($teiBibRef[1]//tei:author) = 2) then data($teiBibRef[1]//tei:author[1]/tei:surname) || " &amp; " || data($teiBibRef[1]//tei:author[2]/tei:surname)
                        else if(count($teiBibRef[1]//tei:author) > 2) then  <span>{ data($teiBibRef[1]//tei:author[1]/tei:surname)} <em> et al.</em></span>
                        else ()
                        
                
                
                else if ($teiBibRef[1]//tei:editor[1]/tei:surname) then
                            if(count($teiBibRef[1]//tei:editor) = 1) then data($teiBibRef[1]//tei:editor[1]/tei:surname)
                        else if(count($teiBibRef[1]//tei:editor) = 2) then data($teiBibRef[1]//tei:editor[1]/tei:surname) || " &amp; " || data($teiBibRef[1]//tei:editor[2]/tei:surname)
                        else if(count($teiBibRef[1]//tei:editor) > 2) then  <span>{ data($teiBibRef[1]//tei:editor[1]/tei:surname)} <em> et al.</em></span>
                        else ()
                        
                else ("[no name]")
                }</span>
    let $date := data($teiBibRef[1]//tei:imprint/tei:date)
    let $citedRange :=if($bibRef//tei:citedRange != "") then
                                   
                                     if (starts-with(data($bibRef[1]//tei:citedRange), ',')) 
                                     then data($bibRef[1]//tei:citedRange)
                                     else (', ' || data($bibRef[1]//tei:citedRange))
                                  else ()
    let $suffixLetter := 
    if (matches(
    substring(data($teiBibRef[1]/@xml:id), string-length(data($teiBibRef[1]/@xml:id))),
    '[a-z]'))
    then substring(data($teiBibRef[1]/@xml:id), string-length(data($teiBibRef[1]/@xml:id)))
    else ''
(:    if (matches(functx:substring-after-last-match($teiBibRef/@xml:id, [0-9]), [a-z])) then functx:substring-after-last-match($teiBibRef/@xml:id, [0-9]) else ""    :)
    let $ref2display :=    if($teiBibRef[1]//tei:title[@type="short"]) then
            (
               data($teiBibRef[1]//tei:title[@type="short"]) || substring-after($citedRange, ',')
            )
            else (
                $authorLastName  || " " || $date || $suffixLetter || $citedRange 

            )

    return

    <span class="bibRef elementValue"><a href="{data($teiBibRef[1]/@corresp)}" target="_blank" class="btn btn-primary">{$ref2display}</a>
    {if($targetType ="ref") then ("️ Please change to URI") else ()}
    
    </span>

};

declare function ausohnumCommons:displayResource($resource as node(),
                                                                                             $type as xs:string,
                                                                                             $index as xs:int){
        let $resourceUri := if($type = "biblio")
                                                    then data($resource/tei:ptr/@target)
                                                    else data($resource/@rdf:resource)
        
        let $resourceRecord := 
                switch($type)
                case "biblio" return $ausohnumCommons:biblioRepo//tei:biblStruct[@corresp = $resourceUri]
                case "illustration" return $ausohnumCommons:resourceRepo//ausohnum:resource[@rdf:about=$resourceUri]
                case "seeFurther" return $ausohnumCommons:biblioRepo//tei:biblStruct[@corresp = $resourceUri]
                default return $ausohnumCommons:biblioRepo//tei:biblStruct[@corresp = $resourceUri]
        let $imageUrl := $resourceRecord//bibo:Image/bibo:uri/text()
        let $zoteroUrl := $resourceRecord//owl:sameAs[1]/@rdf:resource/text()
        let $title := 
               if($resourceRecord//bibo:Image/dcterms:title) then $resource//bibo:Image/dcterms:title[1]
                          else ("No title found")
 (:       let $authorLastName := <span class="lastname">{ 
                if($resourceRecord[1]//tei:author[1]/tei:surname) then data($resourceRecord[1]//tei:author[1]/tei:surname)
                else if ($resourceRecord[1]//tei:editor[1]/tei:surname) then $resourceRecord[1]//tei:editor[1]/tei:surname
                else ("[no name]")
                }</span>:)
                
         let $authorLastName := <span class="lastname">{ 
                if($resourceRecord[1]//tei:author[1]/tei:surname) then 
                        if(count($resourceRecord[1]//tei:author) = 1) then data($resourceRecord[1]//tei:author[1]/tei:surname)
                        else if(count($resourceRecord[1]//tei:author) = 2) then data($resourceRecord[1]//tei:author[1]/tei:surname) || " &amp; " || data($resourceRecord[1]//tei:author[2]/tei:surname)
                        else if(count($resourceRecord[1]//tei:author) > 2) then  <span>{ data($resourceRecord[1]//tei:author[1]/tei:surname)} <em> et al.</em></span>
                        else ()
                        
                
                
                else if ($resourceRecord[1]//tei:editor[1]/tei:surname) then
                            if(count($resourceRecord[1]//tei:editor) = 1) then data($resourceRecord[1]//tei:editor[1]/tei:surname)
                        else if(count($resourceRecord[1]//tei:editor) = 2) then data($resourceRecord[1]//tei:editor[1]/tei:surname) || " &amp; " || data($resourceRecord[1]//tei:editor[2]/tei:surname)
                        else if(count($resourceRecord[1]//tei:editor) > 2) then  <span>{ data($resourceRecord[1]//tei:editor[1]/tei:surname)} <em> et al.</em></span>
                        else ()
                        
                else ("[no name]")
                }</span>       
                
        let $date := data($resourceRecord[1]//tei:imprint/tei:date)
        let $citedRange :=if($resource//tei:citedRange and $resource//tei:citedRange != "") then
                                                    if (starts-with(data($resource[1]//tei:citedRange), ',')) 
                                                    then data($resource[1]//tei:citedRange)
                                                    else (', ' || data($resource[1]//tei:citedRange))
                                    else if($resource//prism:pageRange) then 
                                    
                                            if (starts-with(data($resource//prism:pageRange), ',')) 
                                                    then data($resource//prism:pageRange)
                                                    else (', ' || data($resource//prism:pageRange))
                             else ()
          let $suffixLetter := 
                 if (matches(
                 substring(data($resourceRecord[1]/@xml:id), string-length(data($resourceRecord[1]/@xml:id))),
                 '[a-z]'))
                 then substring(data($resourceRecord[1]/@xml:id), string-length(data($resourceRecord[1]/@xml:id)))
                 else ''                               
        let $ref2display :=
                switch($type)
                    case "illustration" return if($resourceRecord//bibo:Image/dcterms:title) then $resourceRecord//bibo:Image/dcterms:title[1] else ()
                    case "seeFurther" case "biblio" return
                            (
                             if($resourceRecord[1]//tei:title[@type="short"]) then
                                     (data($resourceRecord[1]//tei:title[@type="short"]) || substring-after($citedRange, ','))
                             else ($authorLastName  || " " || $date || $suffixLetter || $citedRange)
                         )
                         
                    default return "Cannot get resource details"
                    
        return
        <span class="resourceRef">{switch ($type)
            case "illustration" return 
                     <div class="resourcePanel col-xs-4 col-sm-4 col-md-4">
                    <h5>{$title}</h5>
                            <ul>
                            <li><a href="{ $imageUrl }" target="_about">Flickr</a><br/></li>
                            <li><a href="{ $zoteroUrl }" target="_about">Zotero</a></li>
                            </ul>
                    </div>
             case "seeFurther" case "biblio" return <span class="elementValue">
             <a href="{data($resourceRecord[1]/@corresp)}" target="_blank" class="">{$ref2display}</a>
         </span>
             default return null
        }</span>
};

declare function ausohnumCommons:elementLabel($label as xs:string?, $type as xs:string, $xpath as xs:string?){
switch($type)
    case "simple" return <span class="elementLabel labelSimple">{ $label }: </span>
    case "badge" return  <span class="elementLabel badge badge-secondary">{ $label }</span>
    case "badgeWithXpath" return
                <span class="elementLabel labelForm">{ $label }<span class="xmlInfo">
                     <a title="XML element: { $xpath }"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                     </span>
                </span>
     default return ""
};

declare function ausohnumCommons:copyToClipboardButton($elementNickname as xs:string,
                                                                    $index as xs:int?){
        let $javascript :='
                                    function copToCliboard(element) {{
                              /* Get the text field */
                              var copyText = document.getElementById("element");
                            
                              /* Select the text field */
                              copyText.select();
                              copyText.setSelectionRange(0, 99999); /*For mobile devices*/
                            
                              /* Copy the text inside the text field */
                              document.execCommand("copy");
                            
                              /* Alert the copied text */
                              alert("Copied the text: " + copyText.value);
                                }}'
        return
<span><button class="btn btn-small" onclick="copyToClipboard('elementValue_{$elementNickname }_{ $index }')"><i class="glyphicon glyphicon-copy"/></button>
    
</span>
};
declare function ausohnumCommons:copyValueToClipboardButton($elementNickname as xs:string, $index as xs:int, $value as xs:string){
        let $javascript :='
                                    function copyValueToClipboard(element) {{
                              /* Get the text field */
                              console.log(element)
                              var copyText = document.getElementById(element);
                            
                              /* Select the text field */
                              copyText.select();
                              copyText.setSelectionRange(0, 99999); /*For mobile devices*/
                            
                              /* Copy the text inside the text field */
                              document.execCommand("copy");
                            
                              /* Alert the copied text */
                              alert("Copied the text: " + copyText.value);
                                }}'
        return
<span>
<input id="elementValue_{$elementNickname }_{ $index }" style="position: absolute; left:     -1000px; top:-1000px" value="{ $value}"></input> 
<button class="btn btn-small btn-primary" onclick="copyValueToClipboard('elementValue_{$elementNickname }_{ $index }')"><i class="glyphicon glyphicon-copy"/></button>
 <script>{ $javascript }</script>   
</span>
};

declare function ausohnumCommons:documentProvenance(){
      let $placesList := ($ausohnumCommons:teiDoc//tei:placeName[@ana="provenance"])
      
      for $place in $placesList
            let $placeUriInternal :=
                        for $uri in tokenize($place/@ref, " ")
                        return 
                            if (contains($uri, $ausohnumCommons:project)) then $uri else ()
            let $placeUriLong := $placeUriInternal || "#this"
            let $placeRecord := $ausohnumCommons:projectPlaceCollection//spatial:Feature[@rdf:about = $placeUriLong ]
            let $placeName := if($placeRecord//dcterms:title[@xml:lang=$ausohnumCommons:lang]/text() != "") then $placeRecord//dcterms:title[@xml:lang=$ausohnumCommons:lang]/text()
            else $placeRecord//dcterms:title[1]/text()
            
            return 
                <div>{ ausohnumCommons:elementLabel("Provenance", "simple", ()) }
                <a href="{ $placeUriInternal}" >{ $placeName }</a>
                </div>
            
    };
    
 declare function ausohnumCommons:textPreview(){
    let $paramMap :=
        map {"method": "xml", "indent": false(), "item-separator": ""}
    
    return
        if(normalize-space(string-join($ausohnumCommons:teiDoc//tei:div[@type="edition"]//tei:div[@type="textpart"][1]/tei:ab//./text(), "")) != "")
            then
                <div class="textPreviewPane">
                    <span style="margin-top: 1em;">{ ausohnumCommons:elementLabel("Text", "simple", "")}
                        { teiEditor:previewToolBar(9999) }</span>
                        <div class="textpartPane" id="editionPane-9999">
                           <div class="previewPane">
                                <div id="textPreviewHTML-9999" class="textPreviewHTMLOverview"/>
                            </div>    
                        </div>
                        <div id="editionDivForLoading" class="hidden">{
                                    for $textPart in $ausohnumCommons:teiDoc//tei:div[@type="edition"]//tei:div[@type="textpart"]
                                            return 
                                        <textarea class="editionTextPart" subtype="{ $textPart/@subtype }" n="{ $textPart/@n }">{
                                            replace(functx:trim(serialize(functx:change-element-ns-deep(
                                        $textPart/tei:ab/node(), '', ''), $paramMap)), '&#9;', '')}</textarea>
                                        }
                         </div>
                 </div>
              else 
                <div class="textPreviewPane">
                    <span style="margin-top: 1em;">
                        { ausohnumCommons:elementLabel("Text", "simple", "")}
                        <p class="h5" style="margin-left: 3em;">The text of this document is not yet available</p>
                        </span>
                </div>
 };
 
 
 declare function ausohnumCommons:textPreviewWithEpidocStylesheet($docType as xs:string){
    let $paramMap :=
        map {"method": "xml", "indent": false(), "item-separator": ""}
    let $leidenStyle:= switch($docType)
                case "epigraphic" return "panciera"
                case "papyrological" return "ddbdp"
                default return "panciera"
    let $xslt := doc($ausohnumCommons:library-path || "/xslt/epidocEdition2html.xsl")
    let $params := <parameters>
                    <param name="css-loc" value="$epidocLib/resources/xsl/epidoc-stylesheets/global.css"/>
                    <param name="leiden-style" value="{ $leidenStyle }"/>
                    <param name="edition-type" value="interpretive"/>
                    <param name="internal-app-style" value="ddbdp"/>  
                </parameters>
    let $paramsContinuousEdition := <parameters>
                    <param name="css-loc" value="$epidocLib/resources/xsl/epidoc-stylesheets/global.css"/>
                    <param name="leiden-style" value="ddbdp"/>
                    <param name="edition-type" value="interpretive"/>
                    <param name="internal-app-style" value="ddbdp"/>  
                    <param name="line-inc" value="0"/> 
                </parameters>            
    let $epidocTransform := transform:transform($ausohnumCommons:teiDoc//tei:div[@type="edition"], $xslt, $params)
    (:~ let $fixSuppliedInAbb := 
        replace($epidocTransform, "\]\((urator)\)", "($1)]") ~:)
    return
        if(normalize-space(string-join($ausohnumCommons:teiDoc//tei:div[@type="edition"]//tei:div[@type="textpart"][1]/tei:ab//./text(), "")) != "")
            then
                <div class="textPreviewPane epidoc">
                    <span style="margin-top: 1em;">{ ausohnumCommons:elementLabel("Text", "simple", "")}
                        { teiEditor:previewToolBar(9999) }</span>
                        { if($docType = "epigraphic") then 
                            <button id="toggleTranscriptionButton" class="btn btn-xs btn-primary" style="margin-left: 3em;">Toggle transcription view</button>
                           else ()}
                        <div class="textpartPane" id="editionPane-9999">
                           <div class="previewPane">
                                <div id="textPreviewHTML-9999" class="textPreviewHTMLOverview">
                                    <div class="transcriptionPanel">
                                    { if($docType = "epigraphic" or $docType="literary") then "" else $epidocTransform }
                                    </div>
                                    <div class="transcriptionPanel hidden">
                                    {
                                    transform:transform($ausohnumCommons:teiDoc//tei:div[@type="edition"], $xslt, $paramsContinuousEdition)
                                            }
                                    </div>

                                </div>
                            </div>    
                        </div>
                        <div id="editionDivForLoading" class="hidden">{
                                    for $textPart in $ausohnumCommons:teiDoc//tei:div[@type="edition"]//tei:div[@type="textpart"]
                                            return 
                                        <textarea class="editionTextPart" subtype="{ $textPart/@subtype }" n="{ $textPart/@n }">{
                                            replace(functx:trim(serialize(functx:change-element-ns-deep(
                                        $textPart/tei:ab/node(), '', ''), $paramMap)), '&#9;', '')}</textarea>
                                        }
                         </div>
                <script type="text/javascript">
                $("#toggleTranscriptionButton").click(function() {{
                            $(".transcriptionPanel").toggleClass("hidden");
                                }});
        
                </script>

                 </div>
              else 
                <div class="textPreviewPane">
                    <span style="margin-top: 1em;">
                        { ausohnumCommons:elementLabel("Text", "simple", "")}
                        <p class="h5" style="margin-left: 3em;">The text of this document is not yet available</p>
                        </span>
                </div>
 };
 
declare function ausohnumCommons:placesInDoc(){
        let $placeOfOrigin := $ausohnumCommons:teiDoc//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origPlace
      
      return
        <div>
        <div id="editorMap"></div>
        </div>
};

declare function ausohnumCommons:generalMap(){
        let $placeOfOrigin := $ausohnumCommons:teiDoc//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origPlace
      
      return
        <div>
        <div id="generalMap"></div>
        <div id="positionInfo" style="font-size: smaller;"/>
        <div id="savedPositionInfo" style="font-size: smaller;">Click to store current position: </div>
        </div>
};

declare function ausohnumCommons:atlasMap($node as node(), $model as map(*)){

        <div>
        <link rel="stylesheet" href="$ausohnum-lib/resources/scripts/jquery/summernote/summernote.min.css" />
        <script src="$ausohnum-lib/resources/scripts/jquery/summernote/summernote.min.js"></script>
        <div id="atlasMap" >
                <div id="atlasSearchPanel" class="panel panel-default hidden">
                    <button id="closeSearchPaneButton" type="button" class="close" onclick="closeAtlasSearchPanel()" style="margin:3px;"><i class="glyphicon glyphicon-remove-circle" /></button>
                    <div class="panel-body">
                        { ausohnumCommons:placesListSimple() }
                    </div>
                </div>
        
                <div id="placeRecordContainer" class="panel panel-default hidden">
                    <button id="closePlaceRecordButton" type="button" class="close" onclick="closePlaceRecord()"><i class="glyphicon glyphicon-remove-circle" /></button>
                    <div class="panel-body">
                        <!--<div id="loaderBig" class="center-block"></div>-->
                        <div id="mapPlaceRecord">
                        Loading...
                        <ul id="placeholder">
                        </ul>
                    </div>
                 </div>
            </div>
       </div>
       
       <link rel="stylesheet" href="https://unpkg.com/leaflet@1.0.3/dist/leaflet.css" integrity="sha512-07I2e+7D8p6he1SIM+1twR5TIrhUQn9+I6yjqD53JQjFiMf8EtC93ty0/5vJTZGF8aAocvHYNEDJajGdNx1IsQ==" crossorigin="" />
       <script src="https://unpkg.com/leaflet@1.0.3/dist/leaflet-src.js" integrity="sha512-WXoSHqw/t26DszhdMhOXOkI7qCiv5QWXhH9R7CgvgZMHz1ImlkVQ3uNsiQKu5wwbbxtPzFXd1hK4tzno2VqhpA==" crossorigin=""></script>
         <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet-providers.js"></script>
       <link href='$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.fullscreen/leaflet.fullscreen.css' rel='stylesheet' />
        <script src='$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.fullscreen/Leaflet.fullscreen.min.js'></script>
        <script src="https://unpkg.com/shpjs@3.6.3/dist/shp.js"/>
        <!-- <script src="$ausohnum-lib/resources/scripts/spatiumStructor/shp.js"/> -->
        <!--Markercluster -->
        <link rel="stylesheet" href="$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet.markerCluster1.4.1/MarkerCluster.css" />
        <link rel="stylesheet" href="$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet.markerCluster1.4.1/MarkerCluster.Default.css" />
        <script src="$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet.markerCluster1.4.1/leaflet.markercluster.js"></script>
         <script src="$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet.featuregroup.subgroup.js"></script>
        <link rel="stylesheet" href="$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet-search/src/leaflet-search.css"/>
        <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet-search/src/leaflet-search.js"></script>
        <script type="text/javascript" src="$ausohnum-lib/resources/scripts/spatiumStructor/L.Control.Geonames.min.js"/>
        <link href="$ausohnum-lib/resources/css/spatiumStructor.css" rel="stylesheet" type="text/css"/>
        <script type="text/javascript" src="$ausohnum-lib/resources/scripts/spatiumStructor/spatiumStructor.js"/>
        <script type="text/javascript" src="$ausohnum-lib/resources/scripts/spatiumStructor/spatiumStructorFunctions.js"/>
        <link href="$ausohnum-lib/resources/css/ausohnumCommons.css" rel="stylesheet" type="text/css"/>
        <link rel="stylesheet" href="https://ppete2.github.io/Leaflet.PolylineMeasure/Leaflet.PolylineMeasure.css" />
        <script src="https://ppete2.github.io/Leaflet.PolylineMeasure/Leaflet.PolylineMeasure.js"></script>
        <script>
            document.title = "APC - Map";</script>
  </div>
};

declare function ausohnumCommons:placesList(){
            
            let $teiDoc := $ausohnumCommons:teiDoc
            let $places := $teiDoc//tei:sourceDesc/tei:listPlace//tei:place
            
            return
            <div class="xmlElementGroup">
                                     <span class="subSectionTitle">Places linked to this document ({count($places)})</span>
                                     <div id="listOfPlacesOverview" class="listOfPlaces">
                            <ul>{
                              let $places := $teiDoc//tei:sourceDesc/tei:listPlace//tei:place
                                            for $place at $pos in $places
                                                        
                                                        let $placeName := $place/tei:placeName/string()
                                                        let $placeUris := data($place/tei:placeName/@ref)
                                                        let $placeUriInternal :=
                                                            for $uri in tokenize($placeUris, " ")
                                                            return 
                                                                if (contains($uri, $teiEditor:project)) then $uri else ()
                                                        let $placeStatus := data($place/tei:placeName/@ana)
                                                       (:let $placeStatus2 := teiEditor:displayElement("placeStatus", $docId, $pos, '/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:listPlace/tei:place/tei:placeName['|| $pos ||']')       
                                                                order by $place/tei:placeName:)
                                                        let $placeRecord:= $ausohnumCommons:projectPlaceCollection//pleiades:Place[@rdf:about = $placeUriInternal][1]
                                                        return
                                                                <li class="placeInList"><a href="{ $placeUriInternal }" title="Open details of { $placeUriInternal }" target="_self">
                                                                {$placeRecord[1]//dcterms:title[1]/text()}</a>
                                                                <span class="geoLat hidden">{$placeRecord[1]//geo:lat/text()}</span>
                                                                <span class="geoLong hidden">{$placeRecord[1]//geo:long/text()}</span>
                                                                <!--
                                                                { teiEditor:displayElement("placeStatus", $docId, $pos, '/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:listPlace/tei:place/tei:placeName['|| $pos ||']')}
                                                                -->
                                                                
                                                                [{$placeStatus}]
                                                                <a href="{ $placeUriInternal }" title="Open details of { $placeUriInternal } in a new window" target="_blank">
                                                       <i class="glyphicon glyphicon-new-window"/></a></li>
                            }</ul>
                            </div>
                            </div>
};


declare function ausohnumCommons:peopleList(){
let $teiDoc := $ausohnumCommons:teiDoc
let $peopleInDoc := $teiDoc//tei:listPerson[@type="peopleInDocument"]//tei:person


return
<div class="xmlElementGroup listOfPeople">
                         <span class="subSectionTitle">People linked to this document ({count($teiDoc//tei:listPerson[@type="peopleInDocument"]//tei:person)})</span>
                         <div id="listOfPeople">
<ul>{""
(:if(count($peopleInDoc) > 50) then ("Only 50 persons are listed here"):)
(:else ():)
}
{
    for $person at $pos in $peopleInDoc
(:            where $pos < 50:)
           
            let $personUris := data($person/@corresp)
            let $personUriInternal :=
                for $uri in tokenize($personUris, " ")
                return 
                    if (contains($uri, $teiEditor:project)) then $uri else ()
             let $personUriInternalLong := $personUriInternal || "#this"       
            let $personDetails := $teiEditor:peopleCollection//lawd:person[@rdf:about=$personUriInternalLong]
            let $persName := if($personDetails//lawd:personalName[@xml:lang="en"]) then $personDetails//lawd:personalName[@xml:lang="en"]/text() else $personDetails//lawd:personalName[1]/text()
            let $juridicalStatus := skosThesau:getLabel($personDetails//apc:juridicalStatus/@rdf:resource, $ausohnumCommons:lang)
            let $personStatus := skosThesau:getLabel($personDetails//apc:personalStatus/@rdf:resource, $ausohnumCommons:lang)
            let $personRank := skosThesau:getLabel($personDetails//apc:socialStatus/@rdf:resource, $ausohnumCommons:lang)
            
            		(: CP :) 
                    order by $person/tei:persName[1]
                    return
                    <li><a href="{ $personUriInternal }" title="Open details of { $personUriInternal }" target="_self">
                    {$persName} [{substring-after($personUriInternal, '/people/')}]</a>
                     <span>{ if($juridicalStatus != "") then "[" || $juridicalStatus || "]" else ()}</span>
                    <span>{ if($personStatus !="") then "[" || $personStatus || "]" else ()}</span>
                       <span>{ if($personRank != "") then "[" || $personRank || "]" else ()}</span>
                    {"" 
                    (:if($personDetails//skos:exactMatch) then 
                        (
                        let $uri := data($personDetails//skos:exactMatch[1]/@rdf:resource)
                        return
                            <span style="font-size: smaller;">[<a href="{ $uri }" title="Open details of { $uri } in a new window" target="_blank">
                                    { if(contains($uri, "trism")) then "TM " || substring-after($uri, "person/") else $uri }
                                </a> ] 
                    </span>)
                        else ():)}
                   <a href="{ $personUriInternal }" title="Open details of { $personUriInternal } in a new window" target="_blank">
           <i class="glyphicon glyphicon-new-window"/></a></li>
}</ul>
</div></div>
                                };
declare function ausohnumCommons:displayXMLFile($resourceUri as xs:string?){
  let $resourceType := request:get-parameter("resourceType", ())
  let $paramMap :=
        map {"method": "xml", "indent": false(), "item-separator": ""}
  
  let $data :=
        switch($resourceType)
            case "document" return replace(functx:trim(serialize(functx:change-element-ns-deep($ausohnumCommons:teiDoc, '', ''), $paramMap)), '&#9;', '')
            case "place" return replace(functx:trim(serialize($ausohnumCommons:projectPlaceCollection//spatial:Feature[@rdf:about = $resourceUri || "#this"]/ancestor::rdf:RDF, $paramMap)), '&#9;', '')
            case "people" return replace(functx:trim(serialize($ausohnumCommons:peopleCollection//lawd:person[@rdf:about = $resourceUri || "#this"]/ancestor::rdf:RDF, $paramMap)), '&#9;', '')
            default return <error>Error</error>
    
    return
    <div>
        <div id="xmlFile">
        
        {"XML will be made available soon." 
        (:$data :)}</div>
     <script>
     
     </script>
     </div>
             


};


declare function ausohnumCommons:getDocumentKeywords(){
    let $teiDoc := $ausohnumCommons:teiDoc
    let $elementNicknameKeyword := "docKeywords"
    let $docKeywordXPath :=
                if (not(exists($ausohnumCommons:teiElementsCustom//teiElement[nm=$elementNicknameKeyword]))) 
                                        then $ausohnumCommons:teiElements//teiElement[nm=$elementNicknameKeyword]/xpath/text() 
                                        else $ausohnumCommons:teiElementsCustom//teiElement[nm=$elementNicknameKeyword]/xpath/text()
    let $docKeywordXPathElementNode:= substring-before($docKeywordXPath, '/@')
    let $docKeywordAttributeName := substring-after($docKeywordXPath, '/@')
    let $keywordsInDoc := util:eval("$teiDoc/" || $docKeywordXPathElementNode)  
    let $peopleInDoc := $teiDoc//tei:listPerson[@type="peopleInDocument"]//tei:person
    let $peopleRecords :=
        for $person at $pos in $peopleInDoc
(:            where $pos < 50:)
           
            let $personUris := data($person/@corresp)
            let $personUriInternal :=
                for $uri in tokenize($personUris, " ")
                return 
                    if (contains($uri, $teiEditor:project)) then $uri else ()
             let $personUriInternalLong := $personUriInternal || "#this"       
            let $personDetails := $teiEditor:peopleCollection//lawd:person[@rdf:about=$personUriInternalLong][not(.//apc:socialStatus[@rdf:resource="https://ausohnum.huma-num.fr/concept/c22259"])]
        return $personDetails
        
        (:let $persName := if($personDetails//lawd:personalName[@xml:lang="en"]) then $personDetails//lawd:personalName[@xml:lang="en"]/text() else $personDetails//lawd:personalName[1]/text()
            let $personStatus := $personDetails//apc:personalStatus/text()
            let $personRank := $personDetails//apc:socialStatus/text()
    :)
    
    let $relatedPlaces := $teiDoc//tei:sourceDesc/tei:listPlace//tei:place
    
    let $productionUnitTypesURIs :=
        for $item in $spatiumStructor:productionUnitTypes//skos:Concept return data($item/@rdf:about)
    
    let $placeTypesToBeTakenUris := ($productionUnitTypesURIs, "https://ausohnum.huma-num.fr/concept/c26367")
    
    let $keywordsFromPlaces :=
        for $place at $pos in $relatedPlaces
            let $placeName := $place/tei:placeName/string()
            let $placeUris := data($place/tei:placeName/@ref)
            let $placeUriInternal :=
                for $uri in tokenize($placeUris, " ")
                return 
                    if (contains($uri, $ausohnumCommons:project)) then $uri else ()
            let $placeRecord:= $ausohnumCommons:projectPlaceCollection//pleiades:Place[@rdf:about = $placeUriInternal][1]
            return
                (
                if(contains($placeTypesToBeTakenUris,
                        data($placeRecord//pleiades:hasFeatureType[@type="main"]/@rdf:resource)))
                    then data($placeRecord//pleiades:hasFeatureType[@type="main"]/@rdf:resource)
                    else (),
                    $placeRecord//pleiades:hasFeatureType[@type="productionType"]/@rdf:resource
                 )

    
    
    
    
    
    let $keywordUriList :=
    distinct-values(
        for $keyword in $keywordsInDoc
            return util:eval("$keyword/@" ||  $docKeywordAttributeName || "")
            )
            
    let $personalStatusesUriList :=distinct-values( 
        for $personStatus in $peopleRecords//apc:personalStatus[@rdf:resource !=""]
            return util:eval("$personStatus/@rdf:resource"))
(:    let $socialStatusesUriList :=distinct-values( :)
(:        for $socialStatus in $peopleRecords//apc:socialStatus[@rdf:resource !=""]:)
(:            return util:eval("data($socialStatus/@rdf:resource)"))        :)
    let $peopleFfunctionsUriList :=distinct-values( 
        for $function in $peopleRecords//apc:hasFunction[@rdf:resource !=""]
            return util:eval("$function/@rdf:resource"))        
            
    let $keywordsFromPlacesUriList :=distinct-values($keywordsFromPlaces)
    
    let $keywordList :=
        for $uri at $pos in ($keywordUriList, $personalStatusesUriList, $peopleFfunctionsUriList, $keywordsFromPlacesUriList)
        let $label := skosThesau:getLabel(data($uri), "uri")
        order by $label
            return
            <keyword>{ $uri }</keyword>
(:    let $keywordsFromPlacesUriList :=distinct-values( :)
(:        for $place in $keywordsFromPlaces:)
(:            return util:eval("data($personStatus/@rdf:resource)")):)
    
    return 
    <div class="xmlElementGroup" >{  ausohnumCommons:elementLabel("Related thesaurus terms", "simple", $docKeywordXPath) }
        {for $uri at $pos in $keywordList
        let $label := skosThesau:getLabel(data($uri), "uri")
        return 
        (    <a href="{ data($uri) }" target="blank">{$label }</a>
        , if($pos  = count($keywordList))
                then "" else ", "
        )
        }
            
        </div>
     

};

declare function ausohnumCommons:temporalRangePlaceAttestations($resourceUri as xs:string){
    let $dateRange := ausohnumCommons:dateRangeFromRelatedDoc($resourceUri)
    return if($dateRange[1]) then 
            <div class="xmlElementGroup">
            <span class="subSectionTitle">{ ausohnumCommons:elementLabel('Temporal range of attestations in documents', 'simple',  ()) }
            { $dateRange[1] || " - " || $dateRange[2] }
            </span>
            <div>  
                    
                    { spatiumStructor:dateRangeScale($dateRange[1],$dateRange[2], 50, 300)
            }</div>
        </div>
        else ()
};

declare function ausohnumCommons:relatedPlacesToPlace($resourceUri as xs:string, $relationType as xs:string){
        let $relatedPlacesList := spatiumStructor:relatedPlacesList($resourceUri, $relationType)
        let $title :=
            switch ($relationType)
                    case "isPartOf" return
                            "This place is part of " || count($relatedPlacesList//place) || " place" || (if(count($relatedPlacesList//place) > 1) then "s" else())
                    case "isMadeOf" return
                            "This place is made of " || count($relatedPlacesList//place) || " place" || (if(count($relatedPlacesList//place) > 1) then "s" else())
                    case "isInVicinityOf" return
                        "This place is in the vicinity of " || count($relatedPlacesList//place) || " place" || (if(count($relatedPlacesList//place) > 1) then "s" else())
                   case "hasInItsVicinity" return
                        "This place has " || count($relatedPlacesList//place) || " place" || (if(count($relatedPlacesList//place) > 1) then "s" else())  
                      ||  " in its vicinity"
                      case "isAdjacentTo" return
                        "This place is adjacent to " || count($relatedPlacesList//place) || " place" || (if(count($relatedPlacesList//place) > 1) then "s" else())
                    default return null
    return if($relatedPlacesList//place) then 
            <div class="xmlElementGroup">
            <span class="subSectionTitle">{ ausohnumCommons:elementLabel($title, 'simple',  ()) }</span>
            <div><ul>
                    {for $place in $relatedPlacesList//place
                    order by $place/text()
                    return <li><a onclick="showPlaceOnMapAndDisplayRecord('{ data(substring-before($place/@uri, "#this")) }')" title="Open Place { data(substring-before($place/@uri, "#this")) } in a new tab" class="spanLink">{ $place/text()  } [{ substring-after(substring-before($place/@uri, "#this"), "/places/") }]</a></li>
                }
                </ul>
            </div>
        </div>
        else ()
};

declare function ausohnumCommons:relatedPlacesToPeople($resourceUri as xs:string){
        let $relatedPlacesList := prosopoManager:relatedPlacesList($resourceUri)
        let $placeNumber := count($relatedPlacesList//place)
        
        let $title :=
            if($placeNumber >1) then "There are " || $placeNumber || " places linked to this person"
                                            else "There is 1 place linked to this person"
                    
        return if($placeNumber > 0) then 
            <div class="xmlElementGroup">
            <span class="subSectionTitle">{ ausohnumCommons:elementLabel($title, 'simple',  ()) }</span>
            <div><ul>
                    {for $place in $relatedPlacesList//place
                    order by $place/text()
                    return <li><a href="{ data(substring-before($place/@uri, "#this")) }" title="Open Place { data(substring-before($place/@uri, "#this")) } in a new tab" target="about">{ $place/text()  }</a></li>
                }
                </ul>
            </div>
        </div>
        else ()
};

declare function ausohnumCommons:temporalRangeAttestations($resourceUri as xs:string){
    let $type := request:get-parameter("resourceType", ())
    let $dateRange := ausohnumCommons:dateRangeFromRelatedDoc($resourceUri, $type)
                                
                
    return if($dateRange[1]) then 
            <div class="xmlElementGroup">
            <span class="subSectionTitle">{ ausohnumCommons:elementLabel('Temporal range of attestations in documents', 'simple',  ()) }
            { $dateRange[1] || " - " || $dateRange[2] }
            </span>
            <div>  
                    
                    { ausohnumCommons:dateRangeScale($dateRange[1],$dateRange[2], 50, 300)
            }</div>
        </div>
        else ()
};

declare function ausohnumCommons:dateRangeScale($earlierNotBeforeDate as xs:integer,
                                $latestNotAfterDate as xs:integer,
                                $scaleStartingYearBC as xs:integer,
                                $scaleEndingYearAD as xs:integer){
  let $startPositionRaw := sum(($earlierNotBeforeDate, $scaleStartingYearBC)) 
  let $endPositionRaw := sum(($latestNotAfterDate, $scaleStartingYearBC))
  let $sum := abs(sum(($endPositionRaw, -$startPositionRaw)))
  let $startPosition := if($sum < 10) then sum(($startPositionRaw, -3)) else $startPositionRaw 
  let $endPosition := if($sum < 10) then sum(($endPositionRaw, 3)) else $endPositionRaw
  return
         
       <div>
       <svg height="50" width="400">
                <line x1="0" y1="10" x2="{ $startPosition }" y2="10" style="stroke:rgb(192, 231, 237);stroke-width:10" />
                <line x1="{ $startPosition }" y1="10" x2="{ $endPosition }" y2="10" style="stroke:rgb(125, 29, 32);stroke-width:10" />
                <line x1="{ $endPosition }" y1="10" x2="{sum(($scaleEndingYearAD, $scaleStartingYearBC)) }" y2="10" style="stroke:rgb(192, 231, 237);stroke-width:10" />
                <text x="0" y="35" fill="black">- {$scaleStartingYearBC}</text>
                <text x="{ $scaleStartingYearBC }" y="35" fill="black">1</text>
                <text x="{ sum(($scaleStartingYearBC, 50)) }" y="35" fill="black">50</text>
                <text x="{ sum(($scaleStartingYearBC, 95)) }" y="35" fill="black">100</text>
                <text x="{ sum(($scaleStartingYearBC, 145)) }" y="35" fill="black">150</text>
                <text x="{ sum(($scaleStartingYearBC, 195))}" y="35" fill="black">200</text>
                <text x="{ sum(($scaleStartingYearBC, 245)) }" y="35" fill="black">250</text>
                <text x="{ sum(($scaleStartingYearBC, 295)) }" y="35" fill="black">{ $scaleEndingYearAD }</text>
                
        </svg>
        </div>
            };            


declare function ausohnumCommons:relatedDocuments($resourceUri as xs:string, $resourceType as xs:string){
    let $relatedDocs:=
        switch ($resourceType)
        case "place" return
            spatiumStructor:relatedDocuments($resourceUri)
        case "people" return
            prosopoManager:relatedDocuments($resourceUri)
       default return null
    let $docs:=
        for $doc in $relatedDocs
                      let $docId := data($doc/@xml:id)
                      let $title := $doc//tei:titleStmt[not(ancestor::tei:bibFull)]/tei:title/text()
                      let $provenanceUri := 
                                      let $splitRef := tokenize(data($doc//tei:sourceDesc/tei:msDesc/tei:history/tei:provenance/tei:location/tei:placeName/@ref), " ")
                                           return 
                                              for $uri in $splitRef
                                                  return
                                                  if(contains($uri, $teiEditor:baseUri)) then normalize-space($uri[1]) else ()
                     let $provenance := if($provenanceUri != "") then 
                                                      $teiEditor:placeCollection//pleiades:Place[@rdf:about=$provenanceUri[1]]//dcterms:title[@xml:lang='en'][1]/text()
                                                      else ""
                     let $placeRelationType := $doc//tei:listPlace//tei:placeName[contains(./@ref, $resourceUri)][1]/@ana/string()                                 
                     let $dating :=
                              if($doc//tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate)
                                     then 
                                     for $date in $doc//tei:sourceDesc[not(ancestor::tei:bibFull)]/tei:msDesc/tei:history/tei:origin//tei:origDate
                                                let $dateBefore := 
                                                    if($date/@notBefore-custom)
                                                            then data($date/@notBefore-custom)
                                                            else if($date/@notBefore) then data($date/@notBefore)
                                                            else ()
                                                let $dateAfter := 
                                                    if($date/@notAfter-custom)
                                                            then data($date/@notAfter-custom)
                                                            else if($date/@notAfter) then data($date/@notAfter)
                                                            else ()
                                                return 
                                                "[" || $dateBefore || (if(($dateBefore) and ($dateAfter != "")) then
                                                        ("-" || $dateAfter ) else())
                                                        || "]"
                                        
                              else ()
                   
                      
                  let $docUri := if($doc//tei:fileDesc/tei:publicationStmt/tei:idno[@type="uri"]) then $doc//tei:fileDesc/tei:publicationStmt/tei:idno[@type="uri"]
                                                                                         else $spatiumStructor:uriBase || "/documents/" || $docId
          return <li>{ $title } {if($placeRelationType != "") then " [" || $placeRelationType || "]" else ("")}{
                            if(($provenance != "") and $resourceType ="people")
                                then " [" || $provenance || "]" 
                                else ()} { $dating }<a href="{ $docUri }" target="about"><i class="glyphicon glyphicon-new-window"/></a></li>
          
        let $label := "There " || (if(count($relatedDocs) >1) then " are " else " is ") || count($relatedDocs) || " document" || (if(count($relatedDocs) >1) then "s" else "")
                                        || " related to this " ||( switch ($resourceType)
                                                                                    case "place" return "place"
                                                                                    case "people" return "person"
                                                                                    default return "element")
        
    return
            <div class="xmlElementGroup">
            <span class="subSectionTitle">{ ausohnumCommons:elementLabel($label, 'simple',  ()) }</span>
               <div>
                    <ul>{ $docs[position() < 6] }
                        {if(count($relatedDocs) > 5) then
                        <li style="list-style: none;">
                            <a class="" type="button" data-toggle="collapse" data-target="#collapseDocList" aria-expanded="false" aria-controls="collapseDocList">See more...</a>
                        </li>
                       else () }
                        </ul>
                        
                        {if(count($relatedDocs) > 5)
                            then 
                                    (
                                        <div class="collapse" id="collapseDocList">
                                             <div class="card card-body">
                                                        <ul>{ $docs[position() > 5] }</ul>
                                             </div>
                                     
                                      </div>)
                           else ()
                         }
               </div>
            </div>
};
declare function ausohnumCommons:relatedPeople($resourceUri as xs:string, $resourceType as xs:string){

let $relatedPeopleList := spatiumStructor:relatedPeopleList($resourceUri)

let $peopleLinkedByDoc :=
        <people>{ $relatedPeopleList//people[@type="linkedByDocuments"]//person }</people>
        
let $peopleSpecificRelation:=
        <people>{ $relatedPeopleList//people[@type="specificRelation"]//person }</people>

return
    (
        (if($peopleLinkedByDoc//person)
            then
                (  
(:                let $peopleNumber := data($relatedPeopleList//people[@type="linkedByDocuments"]/@number):)
                let $peopleNumber := count($peopleLinkedByDoc//person)
                let $listLabel := "There " 
                                       || (if($peopleNumber = 1) then " is " else " are ")
                                       || $peopleNumber || " person" || 
                                       (if($peopleNumber = 1) then "" else "s") || " mentioned in documents linked to this place" 
                let $peopleList := for $person in $peopleLinkedByDoc//person
                                            let $docUri := $ausohnumCommons:baseUri || "/documents/" || $person//docId/text()
                                            return
                                                <li>{ $person/personalName/text()}
                                                        {if( $person//personalStatus/text() != "") then " [" || $person//personalStatus/text() || "]" else ()}
                                                        {if( $person//juridicalStatus/text() != "") then " [" || $person//juridicalStatus/text() || "]" else ()}
                                                        {if( $person//rank/text() != "") then " [" || $person//rank/text() || "]" else ()}<a href="{ data($person/@uri) }" target="blank"><i class="glyphicon glyphicon-new-window"/></a>
                                                        
                                                        <span class="pull-right"><span class="glyphicon glyphicon-hand-right"/><a href="{ $docUri }" title="Document { $docUri }" target="_blank"><span class="glyphicon glyphicon-file"/></a></span>
                                                  </li>
                
                return
                <div class="xmlElementGroup">
                        <span class="subSectionTitle">{ ausohnumCommons:elementLabel($listLabel, 'simple',  ()) }</span>
                        <div>
                            <ul>{ $peopleList[position() < 6] }
                                   {if($peopleNumber > 5)
                                        then
                                                <li style="list-style: none;">
                                                    <a class="" type="button" data-toggle="collapse" data-target="#collapseMentionedPeopleList" aria-expanded="false" aria-controls="collapseMentionedPeopleList">See more...</a>
                                                </li>
                                        else () }
                              </ul>
                              {if($peopleNumber > 5)
                                        then 
                                        (
                                            <div class="collapse" id="collapseMentionedPeopleList">
                                                 <div class="card card-body">
                                                     <ul>{ $peopleList[position() > 5] }</ul>
                                                </div>
                                            </div>
                                        )
                                        else()
                                }
                    </div>
                    
                    </div>
           )
           else()   
         )
         ,
         (if($peopleSpecificRelation//person)
            then
                (
(:                let $peopleNumber := data($relatedPeopleList//people[@type="specificRelation"]/@number):)
                let $peopleNumber := count($peopleSpecificRelation//person)
                let $listLabel := "There " 
                            || (if($peopleNumber = 1) then " is " else " are ")
                            || $peopleNumber || " person" || 
                            (if($peopleNumber = 1) then "" else "s") || " with a specific relation to this place"
                let $peopleList :=
                            for $person in $relatedPeopleList//people[@type="specificRelation"]//person
                            order by $person//function/text()
                                return
                                    <li>{ $person/personalName/text()}
                                            {if( $person//function/text() != "") then 
                                            for $function in $person//function
                                            return " [" || $function/text() || "]" else ()}
                                            
                                   <a href="{ data($person/@uri) }" target="blank"><i class="glyphicon glyphicon-new-window"/></a></li>
                return
                <div class="xmlElementGroup">
                        <span class="subSectionTitle">{ ausohnumCommons:elementLabel($listLabel, 'simple',  ()) }</span>
                        <div>
                         <ul>{ $peopleList[position() < 6] }
                                   {if($peopleNumber > 5)
                                        then
                                                <li style="list-style: none;">
                                                    <a class="" type="button" data-toggle="collapse" data-target="#collapseSpecificRelationPeopleList" aria-expanded="false" aria-controls="collapseSpecificRelationPeopleList">See more...</a>
                                                </li>
                                        else () }
                              </ul>
                              {if($peopleNumber > 5)
                                        then 
                                        (
                                            <div class="collapse" id="collapseSpecificRelationPeopleList">
                                                 <div class="card card-body">
                                                     <ul>{ $peopleList[position() > 5] }</ul>
                                                </div>
                                            </div>
                                        )
                                        else()
                                }
                        </div>
                    </div>)
            else()
         )
         
        )
};

declare function ausohnumCommons:dateRangeFromRelatedDoc($resourceUri as xs:string){
        let $type := request:get-parameter("resourceType", ())
        let $relatedDocs := 
            switch($type)
                case "place" return spatiumStructor:relatedDocuments($resourceUri)
                case "people" return prosopoManager:relatedDocuments($resourceUri)
                default return null
        let $dateBefore :=
                for $date in $relatedDocs//tei:origin//tei:origDate
                        return
                            if($date/@notBefore-custom)
                                then replace($date/@notBefore-custom, "\?", "")
                                else if($date/@notBefore) then replace($date/@notBefore, "\?", "")
                                else ()
         let $dateAfter := 
               for $date in $relatedDocs//tei:origin//tei:origDate
                        return
                            if($date/@notAfter-custom)
                                    then replace($date/@notAfter-custom, "\?", "")
                                    else if($date/@notAfter) then replace($date/@notAfter, "\?", "")
                                    else ()
       return
        (min($dateBefore), max($dateAfter))
};

declare function ausohnumCommons:dateRangeFromRelatedDoc($resourceUri as xs:string, $type as xs:string){
        let $relatedDocs := 
            switch($type)
                case "place" return spatiumStructor:relatedDocuments($resourceUri)
                case "people" return prosopoManager:relatedDocuments($resourceUri)
                default return spatiumStructor:relatedDocuments($resourceUri)
        let $dateBefore :=
                for $date in $relatedDocs//tei:origin[not(ancestor::tei:bibFull)]//tei:origDate
                        return number(
                            if($date/@notBefore-custom)
                                then replace($date/@notBefore-custom, "\?", "")
                                else if($date/@notBefore) then replace($date/@notBefore, "\?", "")
                                else ())
         let $dateAfter := 
               for $date in $relatedDocs//tei:origin[not(ancestor::tei:bibFull)]//tei:origDate
                        return number(
                            if($date/@notAfter-custom)
                                    then replace($date/@notAfter-custom, "\?", "")
                                    else if($date/@notAfter) then replace($date/@notAfter, "\?", "")
                                    else ())
       return
        
        (min($dateBefore), max($dateAfter))
};
declare function ausohnumCommons:relatedPeopleToPerson($resourceUri as xs:string){
        let $relatedPeopleList := prosopoManager:relatedPeopleList($resourceUri)
        let $bondNumber := count($relatedPeopleList//bond)
        let $title := if($bondNumber > 1) then "There are " || $bondNumber || " people linked to thi person"
                                else "There is 1 person linked to this person"
    return if($relatedPeopleList//bond) then 
            <div class="xmlElementGroup">
            <span class="subSectionTitle">{ ausohnumCommons:elementLabel($title, 'simple',  ()) }</span>
            <div><ul>
                    {for $bond in $relatedPeopleList//bond
                    return <li><a href="{ data($bond/@uri) }" title="Open Person { data($bond/@uri) } in a new tab" target="about">{ $bond/text()  } [{data($bond/@bondType)}]</a></li>
                }
                </ul>
            </div>
        </div>
        else ()
};
   declare function ausohnumCommons:personFuntions($resourceUri as xs:string){
        let $functionList := prosopoManager:hasFunctionList($resourceUri)
        let $functionNumber := count($functionList//function)
        let $title := if($functionNumber > 1) then "This person has " || $functionNumber || " functions attested in the APC corpus"
                                else "This person has 1 function attested in the APC corpus"
    return if($functionNumber >0) then 
            <div class="xmlElementGroup">
            <span class="subSectionTitle">{ ausohnumCommons:elementLabel($title, 'simple',  ()) }</span>
            <div>
                <ul>
                    {for $function in $functionList//function
                    return
                    <li><a href="{ data($function/@uri) }"
                        title="Open Function { data($function/@uri) } in a new tab" target="about">{ $function/text()  }
                        </a>
                        { if(data($function/@targetUri) != "") then (
                            "[", <a href="{ data($function/@targetUri) }" title="Open target {data($function/@targetLabel)} in a new tab" target="about">{ data($function/@targetLabel)}</a>, "]"
                            )
                        else ()}
                        </li>
                     }
                
                </ul>
            </div>
        </div>
      else ()
};

declare 
%templates:wrap
function ausohnumCommons:documentsList($node as node(), $model as map(*), $filteredColumn as xs:int, $filterValues as xs:string){
    
    let $documents := $teiEditor:doc-collection//tei:TEI except $teiEditor:doc-collection//documents-test 
    let $placeToDisplay := $teiEditor:appVariables//dashboardPlaceToDisplay/text()
    let $lang := request:get-parameter("lang", ())
    let $docPrefix := $teiEditor:appVariables//idPrefix[@type="document"]/text()
    let $romanProvinces := ($ausohnumCommons:projectPlaceCollection//pleiades:Place[pleiades:hasFeatureType[@rdf:resource="https://ausohnum.huma-num.fr/concept/c22264"]])
    let $romanProvincesUriList := string-join($romanProvinces//@rdf:about, " ")
    
    (:    Provisional list of areas. TODO: proper places in Gazetteer or in thesaurus?:)
    let $areas := map{
                 "Alpine provinces": "Alpes Maritimae, Alpes Graiae, Alpes Cottiae, Alpes Poeninae, Raetia, Noricum",
	    "Sicily, Sardinia, Corsica": "Sicilia, Sardinia, Corsica",
	    "Gaul and Germany": "Narbonensis, Aquitania, Lugdunensis, Belgica, Germania Inferior, Germania superior",
	    "Iberian peninsula": "Baetica, Hispania citerior tarraconensis, Lusitania",
	    "Britain": "Britannia",
	    "Balkan provinces":"Dalmatia, Pannonia inferior, Pannonia superior, Moesia inferior, Moesia Superior, Thracia, Dacia",
	    "Greece": "Macedonia, Epirus, Achaia",
	    "Asia Minor":"Asia, Galatia, Lycia et Pamphylia, Pontus et Bithynia, Cappadocia, Cilicia",
	    "Africa": "Africa proconsularis, Mauretania tingitana, Mauretania Caesarensis",
	    "Crete–Cyrene, Cyprus": "Creta et Cyrene, Cyprus",
	    "Egypt": "Aegyptus",
	    "The East": "Syria, Palaestina, Arabia, Mesopotamia, Osroene"
	}
    let $buildFilteringNode := function($k, $v){
    <button id="filterButtonFor{$filteredColumn}" class="btn btn-default filter {$filteredColumn}Filter" value="{ replace($v, ", ", "|") }" title="This area encompasses the following Roman provinces: { $v }">{ $k }</button>
}        
    let $filteringButtons := sort(map:for-each($areas, $buildFilteringNode))
   (: let $filteringButtons :=
        for $value in tokenize($romanProvincesUriList, ' ')
        let $provinceName := $romanProvinces//.[@rdf:about = $value]//dcterms:title/text() 
        order by $provinceName
        return
            <button id="filterButtonFor{$filteredColumn}" class="btn btn-default filter {$filteredColumn}Filter" value="{ $provinceName }">{ $provinceName }</button>
            :)        
    return
       <div data-template="templates:surround" data-template-with="templates/page.html" data-template-at="content">
              <div class="container-fluid">
                   <div class="row">
                        <div class="col-xs-12 col-sm-12 col-md-12">
                                <h2>Browse documents</h2>
                          </div>
                          <div class="row">
                          <div class="panel col-xs-8 col-sm-8 col-md-8">
                                    <div class="">
                                        <label>Filter by area</label>
                                        <div class="panel-body">{ $filteringButtons }</div>
                                   </div>
                                </div>
                                <div class="col-xs-4 col-sm-4 col-md-4">
                                        <label>Filter by date range</label>
                                 <div style="width: 100%;">   
                                    <div id="slider-range"></div>
                                    <input type="text" id="min" name="min" class="pull-left" readonly="readonly" size="4" style="border-width:0px; border:none;" value="-50"></input>
                                    <input type="text" id="max" name="max" class="pull-right" readonly="readonly" size="4" style="border-width:0px; border:none; text-align:right;" value="500"></input>
                                 </div>   
                       </div>
                   </div>
                   <div class="row">
                        <div class="col-xs-12 col-sm-12 col-md-12">
                        <div id="documentListDiv">
                        <table id="documentsList" class="stripe">
                                    <thead>
                                       <tr>
                                       <th class="sortingActive">ID</th>
                                       <th>Document title</th>
                                       <th>Provenance</th>
                                       <th>Province</th>
                                       <th>Dating</th>
                                       <th></th>
                                       <th>TM no.</th><!--Header for TM -->
                                      <th>Edition</th>
                                       <th>Other identifiers</th><!--Header for other identifiers-->
                                       </tr>
                                       </thead>
                        </table>
                </div>     
                    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.20/css/jquery.dataTables.css"/>
                    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.20/js/jquery.dataTables.js"></script>
                    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/plug-ins/1.10.21/sorting/any-number.js"/>
                    <script type="text/javascript" src="$ausohnum-lib/resources/scripts/ausohnumCommons/ausohnumCommons.js"/>
                    <script type="text/javascript" src="$ausohnum-lib/resources/scripts/ausohnumCommons/documentsList.js"/>
                    <link rel="stylesheet" type="text/css" href="$ausohnum-lib/resources/css/ausohnumCommons.css"/>
                    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.24/css/jquery.dataTables.min.css"/>
    
    
    
    
    
                        </div>
                
                        </div>
                    </div>
               </div>
       </div>
};

declare function ausohnumCommons:getYearFromAncientDate($data as xs:string*, $type as xs:string){
       (:let $values :=if( contains($data, " " )) then replace($data, " ", ",")
                  else($data):)
        let $values := 
                for $value in $data
(:                for $value in tokenize($values, ", "):)
                    let $value :=
                      if( contains($value, "/" )) then functx:substring-after-last($value, "/")
                      else($value)
                    let $value := replace($value, "\D", "")
                    return
                $value 
        
return switch($type)
    case "max" return max(($values))
    case "min" return min(($values))
    default return $values || "default"
};

declare 
%templates:wrap
function ausohnumCommons:peopleList($node as node(), $model as map(*)){
    let $lang := request:get-parameter("lang", ())
    
                    
    return
       <div data-template="templates:surround" data-template-with="templates/page.html" data-template-at="content">
              <div class="container-fluid">
                   <div class="row">
                        
                         <div class="col-xs-12 col-sm-12 col-md-12">
                         <h2>Browse People</h2>
                                <div class="col-xs-6 col-sm-6 col-md-6 col-xs-offset-6 col-sm-offset-6 col-md-offset-6">
                                        <label>Filter by date range</label>
                                 <div style="width: 100%;">   
                                    <div id="slider-range"></div>
                                    <input type="text" id="min" name="min" class="pull-left" readonly="readonly" size="4" style="border-width:0px; border:none;" value="-50"></input>
                                    <input type="text" id="max" name="max" class="pull-right" readonly="readonly" size="4" style="border-width:0px; border:none; text-align:right;" value="500"></input>
                                 </div>   
                               </div>
                         </div>
                   
                   </div>
                   <div class="row" style="height: 300px">
                        <div class="col-xs-12 col-sm-12 col-md-12">
                        <div id="peopleListDiv">
                            <table id="peopleList" class="stripe">
                                    <!--<span class="pull-right">Sorting language: {$lang}</span>-->
                                    <thead>
                                       <tr>
                                       <th>ID</th>
                                       <th class="sortingActive">Name</th>
                                       <th>Sex</th>
                                       <th>Personal status</th>
                                       <th>Citizenship</th>
                                       <th>Rank</th>
                                       <th>Functions</th>
                                       <th>Dates</th>
                                       <th></th>
                                       <th></th>
                                       </tr>
                                       </thead>
                        </table>
                      </div>
                    </div>
                    <!--<div class="col-xs-4 col-sm-4 col-md-4">
                        <div id="loaderBig" class="hidden"></div>
                        <div id="personRecord"/>
                    </div>-->
                    
                            <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.20/css/jquery.dataTables.css"/>
                            <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.20/js/jquery.dataTables.js"></script>
                            <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/plug-ins/1.10.21/sorting/any-number.js"/>
                
                            <script type="text/javascript" src="$ausohnum-lib/resources/scripts/ausohnumCommons/ausohnumCommons.js"/>
                            <script type="text/javascript" src="$ausohnum-lib/resources/scripts/ausohnumCommons/peopleList.js"/>
                             <link rel="stylesheet" type="text/css" href="$ausohnum-lib/resources/css/ausohnumCommons.css"/>
                             <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.24/css/jquery.dataTables.min.css"/>
            </div>
       </div>
</div>
       
};

declare 
%templates:wrap
function ausohnumCommons:placesList($node as node(), $model as map(*)){
    
    let $lang := request:get-parameter("lang", ())
    
                    
    return
       <div data-template="templates:surround" data-template-with="templates/page.html" data-template-at="content">
              <div class="container-fluid">
                   
                   <div class="row" style="height: 300px">
                        <div class="col-xs-12 col-sm-12 col-md-12">
                       <h2>Browse Places</h2>
                        <div id="placesListDiv">
                            <table id="placesList" class="stripe">
                                    <!--<span class="pull-right">Sorting language: {$lang}</span>-->
                                    <thead>
                                      <tr>
                                        <th>ID</th>
                                        <th class="sortingActive">Name</th>
                                        <th>URI</th>
                                        <th>Geocoord</th>
                                        <th>Type</th>
                                        <th>Production</th>
                                        <th>Province</th>
                                        <th>ProvinceUri</th>
                                        <th>External resource(s)</th>
                                        <th>Alternative names</th>
                                     </tr>
                                       </thead>
                        </table>
                      </div>
                    </div>
                    <!--<div class="col-xs-4 col-sm-4 col-md-4">
                    <div id="loaderBig" class="hidden"></div>
                     <div id="placeRecord"/>
                    </div>-->
                    
                            <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.20/css/jquery.dataTables.css"/>
                            <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.20/js/jquery.dataTables.js"></script>
                            <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/plug-ins/1.10.21/sorting/any-number.js"/>
                            <script type="text/javascript">

                                                           
                        
                                                            
                </script>
                <script type="text/javascript">
                    
                </script>
                <script type="text/javascript" src="$ausohnum-lib/resources/scripts/ausohnumCommons/ausohnumCommons.js"/>
                <script type="text/javascript" src="$ausohnum-lib/resources/scripts/ausohnumCommons/placesList.js"/>
                <link rel="stylesheet" type="text/css" href="$ausohnum-lib/resources/css/ausohnumCommons.css"/>
                <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.24/css/jquery.dataTables.min.css"/>
            </div>
       </div>
</div>
       
};

declare 
%templates:wrap
function ausohnumCommons:placesListSimple(

){
    
    let $lang := request:get-parameter("lang", ())
    
                    
    return
       <div>
            <div id="placesListDiv">
                            <table id="placesListSimple" class="table">
                                    <thead>
                                      <tr>
                                        <th>ID</th>
                                        <th class="sortingActive">Name</th>
                                        <th>URI</th>
                                        <th>Geocoord</th>
                                        <th>Type</th>
                                        <th>Production type</th>
                                        <th>Exact Match</th>
                                     </tr>
                                       </thead>
                        </table>
                      </div>
                            <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.20/css/jquery.dataTables.css"/>
                            <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.20/js/jquery.dataTables.js"></script>
                            <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/plug-ins/1.10.21/sorting/any-number.js"/>
                            <script type="text/javascript">     
                        
                                                            
                </script>
                <script type="text/javascript">
                    
                </script>
                <script type="text/javascript" src="$ausohnum-lib/resources/scripts/ausohnumCommons/ausohnumCommons.js"/>
            </div>


       
};

declare function ausohnumCommons:getLabelFromConcept($conceptUri as xs:string?, $lang as xs:string){
    try {
        let $concept := $ausohnumCommons:conceptCollection//skos:Concept[@rdf:about = $conceptUri]
        let $prefLabelCurrentLang := $concept//skos:prefLabel[@xml:lang=$lang]/text()
        let $label := if( $prefLabelCurrentLang != "") then $prefLabelCurrentLang
            else functx:if-empty($concept//skos:prefLabel[1]/text(),"No preferred label")
            
        return normalize-space($label)
    
    }
    catch * { " "}
};

declare function ausohnumCommons:getRelatedPlacesList($resourceId as xs:string){
    let $placeUriLong :=$ausohnumCommons:baseUri  || "/places/" || $resourceId || "#this"
    return
    <div>
        { ausohnumCommons:relatedPlacesToPlace($placeUriLong, "isPartOf")}
        { ausohnumCommons:relatedPlacesToPlace($placeUriLong, "isMadeOf")}
        { ausohnumCommons:relatedPlacesToPlace($placeUriLong, "isInVicinityOf")}
        { ausohnumCommons:relatedPlacesToPlace($placeUriLong, "hasInItsVicinity")}
        { ausohnumCommons:relatedPlacesToPlace($placeUriLong, "isAdjacentTo")}
    </div>
};

declare function ausohnumCommons:getRelatedPeopleList($resourceId as xs:string){
    let $placeUriShort :=$ausohnumCommons:baseUri  || "/places/" || $resourceId 
    return
    <div>
        { ausohnumCommons:relatedPeople($placeUriShort, "place") }
    </div>
};

declare function ausohnumCommons:getRelatedDocumentsList($resourceId as xs:string){
    let $placeUriShort :=$ausohnumCommons:baseUri  || "/places/" || $resourceId 
    return
    <div>
        { ausohnumCommons:relatedDocuments($placeUriShort, "place") }
    </div>
};

declare function ausohnumCommons:getTemporalScale($resourceId as xs:string){
    let $placeUriShort :=$ausohnumCommons:baseUri  || "/places/" || $resourceId 
    return
    <div>
        { ausohnumCommons:temporalRangeAttestations($placeUriShort) }
    </div>
};

declare function ausohnumCommons:searchBuilder($node as node(), $model as map(*)){

    let $lang := "en"
    let $type := ""
    return
    <div>
        <div id="searchTools" class="panel">
         <button class="btn btn-primary">+ word</button>
         
         
         
         <button class="btn btn-primary">+ person</button>
         <button class="btn btn-primary">+ place</button>
         <button class="btn btn-primary">+ function</button>

        </div>
        <div id="searchPanel" class="panel">
        </div>

    </div>
};

declare  %templates:wrap
function ausohnumCommons:indices($node as node(), $model as map(*), $project as xs:string){
    let $documents := collection("/db/apps/" || $project || "Data/documents")//tei:TEI  
    let $lemmataList:= <lemmata>{
        for $w in $documents//tei:w 
            let $lemmata := data($w/@lemmata)
            let $doc:= root($w)
            let $docId := $doc//ancestor-or-self::tei:TEI/@xml:id
            let $docTitle:= $doc//tei:title[1]/text()
            return  
            <lemma lem="{ $lemmata }" docId="{ $docId }" docTitle="{ $docTitle }"/>
            }
            </lemmata>
    return
    <div>
    <div>
        <table id="indices" class="table table-striped ">
            <thead>
                <tr>
                    <td class="sortingActive">Lemma</td>
                    <td>Documents</td>
                </tr>
            </thead>
            <tbody>
            {
            for $lemma in distinct-values($lemmataList//lemma/@lem)
            let $lemInList := $lemmataList//lemma[./@lem = $lemma]
            order by normalize-unicode(ausohnumCommons:normalizeGreek($lemma),'NFC')
            return 
            <tr>
                <td>{$lemma}</td>
                <td>{for $lem at $pos in $lemInList
                    return
                    <span lass="lemmaLoc" style=""><a href="/documents/{ data($lem/@docId)}" title="{ data($lem/@docTitle) }">{ data($lem/@docId)}</a>
                    {if($pos < count($lemInList)) then " " else ()}</span>}
                </td>
            </tr>
            }
            </tbody>
        </table>
    </div>
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.20/css/jquery.dataTables.css"/>
    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.20/js/jquery.dataTables.js"></script>
    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/plug-ins/1.10.21/sorting/any-number.js"/>
    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/buttons/1.7.0/js/dataTables.buttons.min.js"/>
    <script type="text/javascript" charset="utf8" src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.1.3/jszip.min.js"/>
    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/buttons/1.7.0/js/buttons.html5.min.js"/>
    <script type="text/javascript" src="$ausohnum-lib/resources/scripts/teiEditor/teiEditor-dashboard.js"/>
    <link href="$ausohnum-lib/resources/css/skosThesau.css" rel="stylesheet" type="text/css"/>
    <script type="text/javascript">$(document).ready( function () {{
                      $('#indices').DataTable({{
                        //scrollY:        "600px",
                        scrollX:        false,
                        scrollCollapse: true,
                        paging: false,
                        dom: <![CDATA[
                            "<'row'<'col-sm-2'f><'col-sm-4'><'col-sm-6'>>" +
                            "<'row'<'col-sm-12'tr>>" +
                            "<'row'<'col-sm-5'i><'col-sm-7'p>>"
                            ]]>
                        ,
                        
                          fixedColumns: true,
                        language: {{search: "Filter"}}
                            
                            }});

                            $( '#indices' ).searchable();
                        }} );
        </script>
        <style>.dataTables_filter {{
        float: left !important;
        text-align: left!important;
        }}</style>
    </div>
};

(:~ Function to make ancient Greek ordering possibile.
 : Inspired from https://wiki.digitalclassicist.org/Collations_for_Ancient_Languages_in_XSLT_and_XQuery :)
declare function ausohnumCommons:normalizeGreek($string as xs:string){
translate($string,'ἀἁἂἃἄἅἆἇἈἉἊἋἌἍἎἏὰάᾀᾁᾂᾃᾄᾅᾆᾇᾈᾉᾊᾋᾌᾍᾎᾏᾰᾱᾲᾳᾴᾶᾷᾸᾹᾺΆᾼΆΑάαΒβϐΓγΔδἐἑἒἓἔἕἘἙἚἛἜἝὲέῈΈΈΕέεϵ϶ΖζἠἡἢἣἤἥἦἧἨἩἪἫἬἭἮἯὴήᾐᾑᾒᾓᾔᾕᾖᾗᾘᾙᾚᾛᾜᾝᾞᾟῂῃῄῆῇῊΉῌͰͱΉΗήηΘθϑϴἰἱἲἳἴἵἶἷἸἹἺἻἼἽἾἿὶίῐῑῒΐῖῗῘῙῚΊΊΐΙΪίιϊϳΚκϏϗϰΛλΜμΝνΞξὀὁὂὃὄὅὈὉὊὋὌὍὸόῸΌΌΟοόΠπϺϻῤῥῬΡρϱϼΣςσϲϹϽϾϿΤτὐὑὒὓὔὕὖὗὙὛὝὟὺύῠῡῢΰῦῧῨῩῪΎΎΥΫΰυϋύϒϓϔΦφϕΧχΨψὠὡὢὣὤὥὦὧὨὩὪὫὬὭὮὯὼώᾠᾡᾢᾣᾤᾥᾦᾧᾨᾩᾪᾫᾬᾭᾮᾯῲῳῴῶῷῺΏῼΏΩωώϖϚϛϜϝϞϟϘϙͲͳϠϡϷϸϢϣϤϥϦϧϨϩϪϫϬϭϮϯ᾽ι᾿῀῁῍῎῏῝῞῟῭΅`´῾ʹ͵Ͷͷͺͻͼͽ;΄΅·',
'ααααααααααααααααααααααααααααααααααααααααααααααααααβββγγδδεεεεεεεεεεεεεεεεεεεεεεζζηηηηηηηηηηηηηηηηηηηηηηηηηηηηηηηηηηηηηηηηηηηηηηηηθθθθιιιιιιιιιιιιιιιιιιιιιιιιιιιιιιιιιιιικκκκκλλμμννξξοοοοοοοοοοοοοοοοοοοοππϻϻρρρρρρρσσσσσσσσττυυυυυυυυυυυυυυυυυυυυυυυυυυυυυυυυυυφφφχχψψωωωωωωωωωωωωωωωωωωωωωωωωωωωωωωωωωωωωωωωωωωωωωωω ϛϛϝϝϟϟϙϙϠϠϡϡϸϸϣϣϥϥϧϧϩϩϫϫϭϭϯϯ')
};

(: declare function ausohnumCommons:executeBuiltQuery($project as xs:string, $data as node()){
    
    let $keywords := $data//keywords
    let $documentCollection := collection("/db/apps/" || $project || "Data/documents")
    let $keywordsOr := for $keyword in $keywords//keyword[operator = "or"]
                            return ($keyword/keywordUri)
    let $query := ($documentCollection//tei:keywords[functx:contains-any-of(./tei:term/@ref, ($keywordsOr))],
            $documentCollection//tei:rs[functx:contains-any-of(./@ref, ($keywordsOr))])
    let $hitNumber := count($query)
    let $distinctHitNumber := count(functx:distinct-deep($query))
    let $hits := <hits>{
        for $hit in $query
            let $doc := root($hit)
            let $docId := $doc/tei:TEI/@xml:id/string()
            return 
                <item>
                    <hit>{ $hit }</hit>
                    <docId>{ $docId }</docId>
                    <doc>{ $doc }</doc>
                    <text>{ $hit/ancestor::tei:ab }</text>
                </item>
            }
            </hits>
    return 
    
    if($hitNumber > 0) then 
        <ol type="1">
            {
            for $doc in functx:distinct-deep($hits//doc)
                let $docId := $doc//tei:TEI/@xml:id/string()
                let $hitsInDoc := 
                    (for $hitInDoc in $hits//item[equals(./docId/text(), $docId)]//hit
                        return 
                                <li>{
                                    switch(name($hitInDoc/node()))
                                    case "rs" return
                                        let $text :=
                                            (local:applyKeywordMatch($hitInDoc/parent::node()/text/node(), $hitInDoc/node()/@ref, $hitInDoc/node()/@key)
                                        )
                                        return
                                            $text
                                    case "keywords" return "Search term Keyword to document"
                                    default return "error with qname " || name($hitInDoc)
                                    }
                                </li>)
                return
                    <li><a href="/documents/{ $docId }">{ $doc//tei:title[1]/text() } [{ $docId }]</a>
                        <ol type="1">{ $hitsInDoc }
                        </ol>
                    </li>
                    
            }
        </ol>
        else ("No result") 
}; :)

(: declare function local:applyKeywordMatch($text as node()?, $keywordUri as xs:string?, $keywordLabel as xs:string?){
    <div class="searchresultsPreview"><span>Words indexed with "{ $keywordLabel }" [{ $keywordUri }]:</span>
    <br/>
    {
    for $node in $text//child::node()[functx:node-kind(.) = "text"]
        (: return        
        typeswitch ($node)
        case text() return $node
        default  :)
        return 
            if(data($node/ancestor::node()/@ref) = $keywordUri) then <mark>{$node}</mark>
            (: if(data($node/@ref) = $keywordUri) then <mark>A{$node/following-sibling::node()[1]/text()}B</mark> :)
            (: functx:add-attributes($node, (xs:QName("style")), "color: red;") :)
            (: else if(functx:node-kind($node) = "text") then :)
             else $node
            
    }</div>
}; :)