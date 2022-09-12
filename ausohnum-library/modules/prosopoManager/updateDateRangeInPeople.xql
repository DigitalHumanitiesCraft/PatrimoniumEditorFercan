xquery version "3.1";

import module namespace functx="http://www.functx.com";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";
declare namespace apc="http://patrimonium.huma-num.fr/onto#";
declare namespace lawd="http://lawd.info/ontology/";
declare namespace local = "local";
declare namespace prism="http://prismstandard.org/namespaces/basic/2.0/";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace snap="http://onto.snapdrgn.net/snap#";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "xml";
(:declare option output:media-type "text/javascript";:)

declare variable $project :=request:get-parameter('project', ());
declare variable $appVariables := doc("/db/apps/" || $project || "/data/app-general-parameters.xml");
declare variable $baseUri := $appVariables//uriBase[@type='app']/text();

declare variable $biblioRepo := doc("/db/apps/" || $project || "Data/biblio/biblio.xml");
declare variable $people := collection("/db/apps/" || $project || "Data/people");
declare variable $docs := collection("/db/apps/" || $project || "Data/documents");

declare variable $start :=request:get-parameter('start', ());
declare variable $end:=request:get-parameter('end', ());

declare function local:formatDate($date){
    let $number := abs(number($date))
    let $BC := contains($date, "-")
    let $requiredDigits :=
        let $digitNumber := sum((4 - string-length($number)))
                return switch($digitNumber)
                    case 1 return "0"
                    case 2 return "00"
                    case 3 return "000"
                    default return ""
            return
                if($BC = true()) then "-" || $requiredDigits || $number else $requiredDigits || $number
};

declare function local:displayBibRef($resource as node()){
    let $resourceUri := data($resource/tei:ptr/@target)
    let $resourceRecord := $biblioRepo//tei:biblStruct[@corresp = $resourceUri]
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
        if($resourceRecord[1]//tei:title[@type="short"]) then
                                     $resourceRecord[1]//tei:title[@type="short"]/text() || substring-after($citedRange, ',')
                                     else $authorLastName  || " " || $date || $suffixLetter || $citedRange 
                             (:if($resourceRecord[1]//tei:title[@type="short"]) then
                                     (serialize(<span class="labelInTable label label-primary">
                                     <em>{$resourceRecord[1]//tei:title[@type="short"]/text() } </em> { substring-after($citedRange, ',')}
                                     </span>))
                             else (serialize(<span class="labelInTable label label-primary">{ $authorLastName  || " " || $date || $suffixLetter || $citedRange } </span>)):)
               
                    
        return
        $ref2display
};

let $data := for $person at $pos in $people//apc:people
(:[@rdf:about= "https://patrimonium.huma-num.fr/people/612"]:)
    where $pos >= number($start) and $pos < number($end)
    let $uriShort := $person/@rdf:about/string()
    let $logStart := console:log($uriShort)
    let $relatedDocs := $docs//tei:TEI[descendant-or-self::tei:listPerson//tei:person[@corresp=$uriShort]]
    let $dateBefore :=
                for $date in $relatedDocs//tei:origin[not(ancestor::tei:bibFull)]//tei:origDate
                        return
                            if($date/@notBefore-custom)
                                then replace($date/@notBefore-custom, "\?", "")
                                else if($date/@notBefore) then replace($date/@notBefore, "\?", "")
                                else ()
         let $dateAfter := 
               for $date in $relatedDocs//tei:origin[not(ancestor::tei:bibFull)]//tei:origDate
                        return
                            if($date/@notAfter-custom)
                                    then replace($date/@notAfter-custom, "\?", "")
                                    else if($date/@notAfter) then replace($date/@notAfter, "\?", "")
                                    else ()
            let $dateNode :=<node>              <snap:associatedDate type="apcDocuments" notBefore="{ min($dateBefore) }" notAfter="{ max($dateAfter) }">{ local:formatDate(min($dateBefore)) }/{ local:formatDate(max($dateAfter)) }</snap:associatedDate>
</node>
         let $citations :=  <citations>{ for $doc in $relatedDocs
            return 
<lawd:Citation type="apcDocument" rdf:resource="{ $baseUri|| "/documents/" || $doc/@xml:id/string() }">{ $doc//tei:titleStmt//tei:title[1]/text() }</lawd:Citation>
         }
         {
                    for $ref in $relatedDocs//tei:div[@type="bibliography"][@subtype="edition"]//tei:bibl
            return 
<lawd:Citation type="edition" rdf:resource="{ $ref/tei:ptr/@target/string() }">{ local:displayBibRef( $ref )}</lawd:Citation>
         }</citations>
         
         let $updateCitations := if($citations/node()) then
                    (update delete $person//lawd:Citation,
                    update insert $citations/node() into $person) else()
     
     let $updatePersonRecord :=
            ((if($person//snap:associatedDate) then 
                update replace $person//snap:associatedDate with $dateNode/node()
                else 
                update insert ($dateNode/node(), "    ", "&#xa;") into $person),
                console:log("INFO", $uriShort))
    return
        <record uri="{ $uriShort }">{ $dateNode/node() }</record>
 return
 (
 console:log("test"),
 <results>From { $start } to { $end }{ $data }</results>
 )