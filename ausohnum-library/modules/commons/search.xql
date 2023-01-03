(:~
: AusoHNum Library - commons module
: This module contains functions to build XHTML
: @author Vincent Razanajao
:)


xquery version "3.1";

module namespace ausohnumSearch="http://ausonius.huma-num.fr/search";
(:~ import module namespace jsonWrapper="http://ausonius.huma-num.fr/jsonWrapper" at "./json-wrapper.xqm"; ~:)

import module namespace http="http://expath.org/ns/http-client";

import module namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/" at "../skosThesau/skosThesauApp.xql";
import module namespace spatiumStructor="http://ausonius.huma-num.fr/spatiumStructor" at "../spatiumStructor/spatiumStructor.xql";
import module namespace functx="http://www.functx.com";
import module namespace templates="http://exist-db.org/xquery/templates" at "../../modules/templates.xql";
import module namespace maps="http://ausohnum.huma-num.fr/maps" at "../spatiumStructor/maps.xql";

import module namespace kwic="http://exist-db.org/xquery/kwic"
    at "resource:org/exist/xquery/lib/kwic.xql";

(: import module namespace sf="http://srophe.org/srophe/facets" at "../srophe/lib/facets.xql"; :)

(: declare boundary-space preserve; :)

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
declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare namespace foaf = "http://xmlns.com/foaf/0.1/";
declare namespace geo = "http://www.w3.org/2003/01/geo/wgs84_pos#";
declare namespace json="http://www.json.org";
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

declare option output:indent "yes";
declare option output:method "json";
declare option output:media-type "text/javascript";

declare variable $ausohnumSearch:project := request:get-parameter("project", ());
declare variable $ausohnumSearch:SESSION := "ausohnumSearch:results"||$ausohnumSearch:project;

declare function ausohnumSearch:executeBuiltQuery($project as xs:string, $data as node()){
    let $keywords := $data//keywords
    let $documentCollection := collection("/db/apps/" || $project || "Data/documents")
    let $placesCollection := collection("/db/apps/" || $project || "Data/places/" || $project)
    let $keywordsOr := for $keyword in $keywords//keyword[operator = "or"]
                            return ($keyword/keywordUri)
    let $keywordsAnd := for $keyword in $keywords//keyword[operator = "and"]
                            return ($keyword/keywordUri)
    let $queryOr := (
                $documentCollection//tei:keywords[functx:contains-any-of(./tei:term/@ref, ($keywordsOr))],
                $documentCollection//tei:rs[functx:contains-any-of(./@ref, ($keywordsOr))]
                ,
                $placesCollection//pleiades:hasFeatureType[functx:contains-any-of(./@*[local-name()='resource'], ($keywordsOr))]

                )
    let $queryAnd := (
                $documentCollection//tei:keywords[functx:contains-any-of(./tei:term/@ref, ($keywordsAnd))],
                $documentCollection//tei:rs[functx:contains-any-of(./@ref, ($keywordsAnd))]
                ,
                $placesCollection//pleiades:hasFeatureType[functx:contains-any-of(./@*[local-name()='resource'], ($keywordsAnd))]

                )
    let $requiredHits :=<hits>{
        for $hit in $queryAnd
            let $doc := root($hit)
            let $docId := $doc/tei:TEI/@xml:id/string()
            return 
                <item>
                    <hit>{ $hit }</hit>
                    <docId>{ $docId }</docId>
                    <doc>{ $doc }</doc>
                    <text>{ $hit/ancestor::tei:ab }</text>
                    <docOrigPlace>{ if(exists($doc//tei:origPlace/@ref)) then 
                                        tokenize($doc//tei:origPlace/@ref, " ")[1] 
                                    else 
                                        substring-before($doc//spatial:Feature/@rdf:about, "#this")}</docOrigPlace>
                </item>
            }
            </hits>
    let $optionalHits := <hits>{
        for $hit in $queryOr
            let $doc := root($hit)
            let $docId := $doc/tei:TEI/@xml:id/string()
            return 
                if(functx:contains-any-of($docId, ($requiredHits//docId))) then
                <item>
                    <hit>{ $hit }</hit>
                    <docId>{ $docId }</docId>
                    <doc>{ $doc }</doc>
                    <text>{ $hit/ancestor::tei:ab }</text>
                    <docOrigPlace>{ if(exists($doc//tei:origPlace/@ref)) then 
                                        tokenize($doc//tei:origPlace/@ref, " ")[1] 
                                    else 
                                        substring-before($doc//spatial:Feature/@rdf:about, "#this")}</docOrigPlace>
                </item>
                else()
            }
            </hits>
    
    let $hitNumber:= count(($requiredHits, $optionalHits))
    let $docNumber:=count(functx:distinct-deep($requiredHits//tei:TEI))
    let $placesNumber:=count($requiredHits//spatial:Feature)
    return 
    <response>
        <html>  
            <div class="row">
            Total of hits: { $hitNumber }
            </div>
            <div class="row">
            {
            if($docNumber > 0) then 
                (
                let $results:=
                if(exists($requiredHits//tei:TEI)) then
                                for $doc in functx:distinct-deep($requiredHits//tei:TEI)
                                    let $docId := $doc/@xml:id/string()
                                    let $keywords :=
                                    string-join($requiredHits//item[equals(./docId/text(), $docId)]//hit/node()/@ref, ", ")
                                    let $params := <parameters>
                                                                <param name="keywordUri" value="{ $keywords }"/>
                                                                <param name="css-loc" value="/$ausohnum-lib/xslt/epidoc-stylesheets/global.css"/>
                                                                <param name="leiden-style" value="panciera"/>
                                                                <param name="edition-type" value="interpretive"/>
                                                                    
                                                                </parameters>
                                    let $xslt := doc("/db/apps/epidocLib" || "resources/xsl/epidoc-stylesheets/start-edition.xsl")
                                    
                                    let $textWithMatch:=transform:transform($doc//tei:div[@type="edition"]/tei:ab, $xslt, $params)

                                    (: let $hitsInDoc := 
                                        (for $hitInDoc in $hits//item[equals(./docId/text(), $docId)]//hit
                                            return 
                                                <li>{
                                                    if($hitInDoc/node())then
                                                    switch(name($hitInDoc/node()))
                                                    case "rs" return
                                                        let $params := <parameters>
                                                                <param name="keywordUri" value="{ $hitInDoc/node()/@ref }"/>
                                                                <param name="$css-loc" value="/$ausohnum-lib/xslt/epidoc-stylesheets/global.css"/>
                                                                <param name="leiden-style" value="panciera"/>
                                                                <param name="edition-type" value="interpretive"/>
                                                                    
                                                                </parameters>
                                                        let $xslt := doc("/db/apps/ausohnum-library-dev" || "/xslt/epidoc-stylesheets/start-edition.xsl")
                                                        let $text := transform:transform($hitInDoc/parent::node()/text/node(), $xslt, $params)
                                                            (: (local:applyKeywordMatch($hitInDoc/parent::node()/text/node(), $hitInDoc/node()/@ref, $hitInDoc/node()/@key)
                                                        ) :)
                                                        
                                                        return
                                                            $text
                                                    case "keywords" return "Search term Keyword to document"
                                                    default return "error with qname " || name($hitInDoc)
                                                    else()
                                                    }
                                                </li>
                                        ) :)
                                    return
                                        <li><i class="glyphicon glyphicon-file"/><a href="/documents/{ $docId }">{ $doc//tei:title[1]/text() } [{ $docId }]</a>
                                            <ol type="1">{ $keywords }{ $textWithMatch }
                                            </ol>
                                        </li>
                               
                                    else()

                return    
                <div class="panel panel-default col-md-8">
                    <div class="panel-heading">Document{if($docNumber > 1) then "s" else()}: {count(functx:distinct-deep($requiredHits//tei:TEI))}</div>
                        <div class="panel-body">
                            <ol type="1">
                            {
                                $results[position()<6]
                            }
                            { if($docNumber > 4)
                                then
                                        <a class="" type="button" data-toggle="collapse" data-target="#collapseDocList" aria-expanded="false" aria-controls="collapseDocList">See more...</a>
                                     
                                else()
                            }
                            { if($docNumber > 4)
                                then
                                (
                                <div class="collapse" id="collapseDocList">
                                        <div class="card card-body">
                                            { $results[position() > 5] }
                                    </div>
                                </div>
                                )
                                else()
                                }


                            </ol>
                        </div>
                    </div>)
                else ()
            }            
                
            {
            if($placesNumber > 0) then 
                (
                <div class="panel panel-default col-md-4">
                    <div class="panel-heading">Place{if($placesNumber>1) then "s" else()}: { count($requiredHits//spatial:Feature) }</div>
                    <div class="panel-body">
                        <ol type="1">
                            {
                        for $place in $requiredHits//spatial:Feature
                            let $placeUri:= substring-before($place/@rdf:about, "#this")
                            let $placeName:=$place//dcterms:title/text()
                            let $placeType :=
                                if($place//pleiades:hasFeatureType) then
                                for $type in $place//pleiades:hasFeatureType[./@rdf:resource !=""]
                                    let $label:=functx:trim(skosThesau:getLabel($type/@rdf:resource, "en"))
                                        return
                                        $label
                                else()
                            let $isPartOfPlaces := spatiumStructor:getPlaceHierarchy($placeUri, ())
                            let $placeInHierarchy :=
                                    for $isPartOfPlace at $pos in reverse($isPartOfPlaces//spatial:Feature)
                                        return 
                                        if($pos < count($isPartOfPlaces//spatial:Feature)) then 
                                            $isPartOfPlace//dcterms:title/text() || " > " else
                                            <strong>{ $isPartOfPlace//dcterms:title/text() }</strong>
                        return 
                        <li><i class="glyphicon glyphicon-pushpin"/>{ $placeName } [{ $placeType }]{ $placeUri }<br/>{$placeInHierarchy}</li>
                               
                        }
                    </ol>
                    </div>
                    </div>
                )
                else ("No result") }

                 </div>               
        </html>
    <hits>{ $requiredHits }</hits>
    <geojson>{serialize(<root json:array="false" type="FeatureCollection">{ 
            let $places := functx:distinct-deep(
                for $item in $requiredHits//docOrigPlace
                return $item)
            let $placesFromGazetteer := for $place in $places
                let $placeObject := doc("/db/apps/" ||$ausohnumSearch:project || "Data/places/project-places-gazetteer.xml" )//features[properties/uri = $place]
                return 
                <features type="Feature">
                    <properties>
                        { $placeObject//properties/node() }
                        <hits>
                        { for $hitInPlace in $requiredHits//item[equals(./docOrigPlace/text(), $place)]//docId
                            return <docId>{ $hitInPlace/text()}</docId>
                            }
                        </hits>
                    </properties>
                    { $placeObject/style }
                    { $placeObject/geometry }
                </features>

            return $placesFromGazetteer}</root>,
        <output:serialization-parameters>
                <output:method>json</output:method>
                <output:json-ignore-whitespace-text-nodes>yes</output:json-ignore-whitespace-text-nodes>
                <output:media-type>text/javascript</output:media-type>
            </output:serialization-parameters>)}
                </geojson>
        </response>
};

declare function local:applyKeywordMatch($text as node()?, $keywordUri as xs:string?, $keywordLabel as xs:string?){
    <div class="searchresultsPreview"><span class="em">Words indexed with "{ $keywordLabel }" [{ $keywordUri }]:</span>
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
};

declare function ausohnumSearch:executeftSearch(){
    let $queryStr:= request:get-parameter("query", ())
    let $mode := request:get-parameter("mode", ())
    let $lemmataMode:= request:get-parameter("lemmataMode", ())
    let $hits:= ausohnumSearch:do-query($queryStr, $mode, $lemmataMode)
    let $hitsForDatatables := ausohnumSearch:show-hitsForDatatableLight($hits)
    let $matchTotal := sum((data($hitsForDatatables//@matchCount)))
            
    
    let $geojson :=<geojson><root json:array="false" type="FeatureCollection">{ 
                            let $places := functx:distinct-deep(
                                for $item in $hitsForDatatables//provenanceUri[./text() != ""]
                                return $item)
                            let $placesFromGazetteer := for $place in $places
                let $placeObject := doc("/db/apps/" ||$ausohnumSearch:project || "Data/places/project-places-gazetteer.xml" )//features[properties/uri = $place]
                return 
                if($placeObject//coordinates[contains(., "0, 0")]) then () else
                <features type="Feature">{$place//coordinates/text()}
                    <properties>
                        { $placeObject//properties/node() }
                        <hits>
                        { for $hitInPlace in $hitsForDatatables//data[./provenanceUri/text()= $place]//docId
                            return <docId>{ $hitInPlace/text()}</docId>
                            }
                        </hits>
                    </properties>
                    { $placeObject/style }
                    { $placeObject/geometry }
                </features>
                return $placesFromGazetteer
                            }</root>
                </geojson>


    return
        serialize(
        (:~ jsonWrapper:json( ~:)
            <response>
            <summary match="{ $matchTotal }" docsTotal="{ count($hitsForDatatables//data)}" lemmata="{ $lemmataMode }"></summary>
            { $hitsForDatatables}
            { $geojson }
            </response>
            (:~ ) ~:)
        ,
            <output:serialization-parameters>
                <output:method>json</output:method>
                <output:media-type>text/javascript</output:media-type>
            </output:serialization-parameters>
        )
};


declare
    %templates:wrap
function ausohnumSearch:query($node as node()*, $model as map(*), $query as xs:string?, $mode as xs:string?) {
    session:create(),
    let $hits := ausohnumSearch:do-query($query, $mode)
    let $store := session:set-attribute($ausohnumSearch:SESSION, $hits)
    return
        map:entry("hits", $hits)
};

declare function ausohnumSearch:do-query($queryStr as xs:string?, $mode as xs:string?) {
    let $query := ausohnumSearch:create-query($queryStr, $mode)
    let $options :=
    <options>
        <default-operator>and</default-operator>
        <phrase-slop>1</phrase-slop>
        <leading-wildcard>yes</leading-wildcard>
        <filter-rewrite>yes</filter-rewrite>
    </options>
    for $hit in 
        (collection("/db/apps/" || $ausohnumSearch:project || "Data/documents")//tei:div[@type='edition']//tei:ab[ft:query(., $query)]
        ,
        collection("/db/apps/" || $ausohnumSearch:project || "Data/documents")//tei:w[ft:query(./@lemmata, $query)]
        ) 
    order by ft:score($hit) descending
    return $hit
};
declare function ausohnumSearch:do-query($queryStr as xs:string?, $ftMode as xs:string?, $lemmataMode as xs:string?) {
    let $queryStrgNormalized := normalize-unicode($queryStr, 'NFD')
    let $queryStrgStrippedDiacritics := replace($queryStrgNormalized, '\p{IsCombiningDiacriticalMarks}', '')
    let $query := ausohnumSearch:create-query($queryStrgStrippedDiacritics, $ftMode)
    let $options :=
                    <options>
                        <default-operator>and</default-operator>
                        <phrase-slop>1</phrase-slop>
                        <leading-wildcard>yes</leading-wildcard>
                        <filter-rewrite>yes</filter-rewrite>
                    </options>
    let $lemmaQuery:=
        if($lemmataMode="yes") then
        collection("/db/apps/" || $ausohnumSearch:project || "Data/documents")//tei:ab[ft:query(.//@lemmata, $query)]
        else()
        
    for $hit in
        (
        collection("/db/apps/" || $ausohnumSearch:project || "Data/documents")//tei:div[@type='edition']//tei:ab[ft:query(., $query)]
        , 
        $lemmaQuery
        )
        
    order by ft:score($hit) descending
    return $hit
};
(:~
    Read the last query result from the HTTP session and pass it to nested templates
    in the $model parameter.
:)
declare
    %templates:wrap
function ausohnumSearch:from-session($node as node()*, $model as map(*)) {
    map:entry("hits", session:get-attribute($ausohnumSearch:SESSION))
};

(:~
 : Create a span with the number of items in the current search result.
 : The annotation %templates:output("wrap") tells the templating module
 : to create a new element with the same name and attributes as $node,
 : using the return value of the function as its content.
 :)
declare
    %templates:wrap
function ausohnumSearch:hit-count($node as node()*, $model as map(*)) {
    count($model("hits"))
};
declare
    %templates:wrap
function ausohnumSearch:hit-countAsLabel($node as node()*, $model as map(*)) {
    let $lang := request:get-parameter("lg", ())
    return
    switch($lang)
        case "en" return "Found " || (count($model("hits")) || " match" || (if(count($model("hits")) >1 ) then "es" else ()))
        case "fr" return (count($model("hits")) || " occurrence" 
            || (if(count($model("hits")) >1 ) then "s trouvées" else (" trouvée")))
        case "de" return (count($model("hits")) || "  Übereinstimmung" || (if(count($model("hits")) >1 ) then "en" else ()) || " gefunden")
        default return "Found " || (count($model("hits")) || " match" || (if(count($model("hits")) >1 ) then "es" else ()))


};

(:~
 : Output the actual search result as a div, using the kwic module to summarize full text matches.
:)
declare
    %templates:default("start", 1)
function ausohnumSearch:show-hits($node as node()*, $model as map(*), $start as xs:int) {
<div>
    <div>
    {
    for $hit at $p in subsequence($model("hits"), $start, 10)
        let $doc := $hit/ancestor::tei:TEI
        let $docId := data($doc/@xml:id)
        
        let $docTitle := $doc//tei:titleStmt/tei:title/text()
        let $matchLineNumbers := kwic:get-matches($hit)/preceding::tei:lb[1]/@n/string()
        let $matchLine := for $no at $pos in $matchLineNumbers
            return $no
                ||(if(count($matchLineNumbers) >1)
                    then (
                        if($pos = sum((count($matchLineNumbers), -1)))
                        then " and "
                        else if(($pos >= 1) and ($pos< count($matchLineNumbers))) then ", "
                        else()
                    )
                    else()
                )

        let $kwic := kwic:summarize($hit, <config width="40" table="yes"/>, ausohnumSearch:filter#2)
       
    return
        <div class="item" xmlns="http://www.w3.org/1999/xhtml">
            <h4><span class="badge" style="margin-right:1em;">{$start + $p - 1}</span> {$docTitle}
            [{$docId} <a href="/documents/{$docId}" target="_blank"><i class="glyphicon glyphicon-new-window"/></a>]</h4>
            <div class="hitSummary">
                <h6>Line{if(count($matchLineNumbers) >1) then "s" else ()} { $matchLine }</h6>
                <table>{ $kwic }</table>
            </div>
        </div>
    }
    </div>

    
</div>

};
declare
function ausohnumSearch:show-hitsForDatatable($hits) {
    let $documentsList := doc("/db/apps/" || $ausohnumSearch:project || "Data/lists/list-documents.xml")
    
    return
    (: let $hits := session:get-attribute($ausohnumSearch:SESSION) :)
    (
    
                (:~ serialize( ~:)
                    <results>
                    
                     {
                    for $hit at $p in $hits
                        let $matches:=kwic:get-matches($hit)
                        let $doc := $hit/ancestor::tei:TEI
                        let $docId := data($doc/@xml:id)
                        let $docTitle := $doc//tei:titleStmt/tei:title/text()
                        (:~ let $matchLineNumbers := kwic:get-matches($hit)//preceding::tei:lb[1]/@n/string() ~:)
                        let $matchLineNumbers := for $match in $matches return data($match/preceding::tei:lb[1]/@n)

                        let $matchLines := for $no at $pos in $matchLineNumbers
                            return $no
                                ||(if(count($matchLineNumbers) >1)
                                    then (
                                        if($pos = sum((count($matchLineNumbers), -1)))
                                        then " and "
                                        else if(($pos >= 1) and ($pos< count($matchLineNumbers))) then ", "
                                        else()
                                    )
                                    else()
                                )

                        let $docMetadata:=$documentsList//data[id=$docId]
                   
                   let $provenancePlaceUri := 
                                                let $splitRef := tokenize(data($docMetadata/provenanceUri/text()), " ")
                                                return 
                                                    for $uri in $splitRef
                                                    return
(:                                                          string-join($uri, "-->"):)
                                                    if(contains($uri, $ausohnumSearch:project)) then 
                                                    normalize-space($uri[1]) else ()
                        
                        let $params := <parameters>
                                                                <param name="keywordUri" value=""/>
                                                                <param name="css-loc" value="/$epidocLib/resources/xsl/epidoc-stylesheets/"/>
                                                                <param name="leiden-style" value="panciera"/>
                                                                <param name="edition-type" value="interpretive"/>
                                                                <param name="edn-structure" value="london"/>  
                                                                <param name="line-inc" value="5"/> 
                                                                </parameters>
                                    let $xslt := doc("/db/apps/ausohnum-library-dev" || "/xslt/highlightMatches.xsl")
                                    (:~ let $xslt := doc("/db/apps/ausohnum-library-dev" || "/xslt/epidoc-stylesheets/start-edition.xsl") ~:)
                                    
                                    (:let $textWithMatch:=transform:transform(kwic:expand($hit), $xslt, $params):)
                                    (:let $textWithMatch:=substring(transform:transform($hit, $xslt, $params), 4):)
                                    let $textWithMatch:=transform:transform($hit, $xslt, $params)

                        
                        
                        let $summary := 
                            <span>
                            <a href="/documents/{ $docId }" target="_about" style="font-weight: bold; margin-right: 1em;">{ $docId }</a> { $docTitle }
                            <br/>Found { count($matches)} match{if(count($matches)>1) then "es" else() } {if(count($matchLines)>1) then " at lines "
                                                                                                           else if (count($matchLines)=0) then ""
                                                                                                           else " at line " }{ $matchLines }
                            { ""
                            (:~ if($docMetadata/provenance/text()!="")
                                then
                                <a href="{ $provenancePlaceUri }" target="_about">{ $docMetadata/provenance/text() }</a>
                                else() ~:) }
                             <div>
                             <div style="padding: 1em 0 0.5em 1em">
                             { kwic:summarize($hit, <config width="40"/>)}
                             </div>
                              <a class="" type="button" data-toggle="collapse" data-target="#collapseFullText-{ $p }" aria-expanded="false" aria-controls="collapseDocList" style="padding-left: 2em">[Show/hide full text]</a>
                              <div class="collapse" id="collapseFullText-{ $p }">
                                    <div class="card card-body" style="padding: 1em 0 0 0.5em">
                                      { $textWithMatch }      
                                    </div>
                                </div>
                             </div>
                          
                            </span>
                        
                        return
                            
                            <data matchCount="{count($matches)}" json:array="true">
                                <no>{ $p }</no>
                                <docId>{ $docId }</docId>
                                <summary>{ serialize($summary) }</summary>
                                <text>{$textWithMatch }</text>
                                <provenance>{ $docMetadata/provenance/text() }</provenance>
                                <provenanceUri>{ $provenancePlaceUri }</provenanceUri>
                                <province>{ $docMetadata/provinceName/text() }</province>
                                <provinceUri>{ $docMetadata/provinceUri/text() }</provinceUri>
                                <datingNotBefore>{ $docMetadata/datingNotBefore/text() }</datingNotBefore>
                                <datingNotAfter>{ $docMetadata/datingNotAfter/text() }</datingNotAfter>
                                <keywords>{ $docMetadata/keywords/text() }</keywords>
                            </data>
                        }
                    </results>
                    
                    (:~ ,
                        <output:serialization-parameters>
                            <output:method>json</output:method>
                            <output:json-ignore-whitespace-text-nodes>yes</output:json-ignore-whitespace-text-nodes>
                            <output:indent>yes</output:indent>
                            <output:media-type>text/javascript</output:media-type>

                        </output:serialization-parameters>
                    ) ~:)
    )  
};

declare
function ausohnumSearch:show-hitsForDatatableLight($hits) {
    let $documentsList := doc("/db/apps/" || $ausohnumSearch:project || "Data/lists/list-documents.xml")
    
    return
    (: let $hits := session:get-attribute($ausohnumSearch:SESSION) :)
    (
    
                (:~ serialize( ~:)
                    <results>
                    
                     {
                    for $hit at $p in $hits
                        let $matches:=kwic:get-matches($hit)
                        let $doc := $hit/ancestor::tei:TEI
                        let $docId := data($doc/@xml:id)
                        let $docTitle := $doc//tei:titleStmt/tei:title/text()
                        (:~ let $matchLineNumbers := kwic:get-matches($hit)//preceding::tei:lb[1]/@n/string() ~:)
                        let $matchLineNumbers := for $match in $matches return data($match/preceding::tei:lb[1]/@n)

                        let $matchLines := for $no at $pos in $matchLineNumbers
                            return $no
                                ||(if(count($matchLineNumbers) >1)
                                    then (
                                        if($pos = sum((count($matchLineNumbers), -1)))
                                        then " and "
                                        else if(($pos >= 1) and ($pos< count($matchLineNumbers))) then ", "
                                        else()
                                    )
                                    else()
                                )

                        let $docMetadata:=$documentsList//data[id=$docId]
                   
                   let $provenancePlaceUri := 
                                                let $splitRef := tokenize(data($docMetadata/provenanceUri/text()), " ")
                                                return 
                                                    for $uri in $splitRef
                                                    return
(:                                                          string-join($uri, "-->"):)
                                                    if(contains($uri, $ausohnumSearch:project)) then 
                                                    normalize-space($uri[1]) else ()
                        
                       
                        
                        let $summary := 
                            <span>
                            <a href="/documents/{ $docId }" target="_about" style="font-weight: bold; margin-right: 1em;">{ $docId }</a> { $docTitle }
                            <br/>Found { count($matches)} match{if(count($matches)>1) then "es" else() } {if(count($matchLines)>1) then " at lines "
                                                                                                           else if (count($matchLines)=0) then ""
                                                                                                           else " at line " }{ $matchLines }
                            { ""
                            (:~ if($docMetadata/provenance/text()!="")
                                then
                                <a href="{ $provenancePlaceUri }" target="_about">{ $docMetadata/provenance/text() }</a>
                                else() ~:) }
                             <div>
                             <div style="padding: 1em 0 0.5em 1em">
                             { kwic:summarize($hit, <config width="40"/>)}
                             </div>
                              <a class="" type="button" data-toggle="collapse" data-target="#collapseFullText-{ $p }" aria-expanded="false" aria-controls="collapseDocList" style="padding-left: 2em" onclick="displayTextPreview('{ $p }', '{ $docId }')">[Show/hide full text]</a>
                              
                              <div class="collapse" id="collapseFullText-{ $p }">
                                    <div class="card card-body" style="padding: 1em 0 0 0.5em">
                                   <div id="textPreview-{ $p }"/>     
                                    </div>
                                </div>
                                <div id="hitNodes{ $p }" class="hidden">{ $hit }</div>
                             </div>
                          
                            </span>
                        
                        return
                            
                            <data matchCount="{count($matches)}" json:array="true">
                                <no>{ $p }</no>
                                <docId>{ $docId }</docId>
                                <summary>{ serialize($summary) }</summary>
                                <text></text>
                                <provenance>{ $docMetadata/provenance/text() }</provenance>
                                <provenanceUri>{ $provenancePlaceUri }</provenanceUri>
                                <province>{ $docMetadata/provinceName/text() }</province>
                                <provinceUri>{ $docMetadata/provinceUri/text() }</provinceUri>
                                <datingNotBefore>{ $docMetadata/datingNotBefore/text() }</datingNotBefore>
                                <datingNotAfter>{ $docMetadata/datingNotAfter/text() }</datingNotAfter>
                                <keywords>{ $docMetadata/keywords/text() }</keywords>
                            </data>
                        }
                    </results>
                    
                    (:~ ,
                        <output:serialization-parameters>
                            <output:method>json</output:method>
                            <output:json-ignore-whitespace-text-nodes>yes</output:json-ignore-whitespace-text-nodes>
                            <output:indent>yes</output:indent>
                            <output:media-type>text/javascript</output:media-type>

                        </output:serialization-parameters>
                    ) ~:)
    )  
};

declare 
function ausohnumSearch:show-hitsAsTable($hits) {
    (: let $hits := session:get-attribute($ausohnumSearch:SESSION) :)

  
    for $hit at $p in $hits
    let $doc := $hit/ancestor::tei:TEI
    let $docId := data($doc/@xml:id)
    let $docTitle := $doc//tei:titleStmt/tei:title/text()
    let $matchLine := kwic:get-matches($hit)/preceding::tei:lb[1]/@n/string()
    let $kwic := kwic:summarize($hit, <config width="40" table="no"/>, ausohnumSearch:filter#2)
    return
        <tr>
            <id>{ $docId }</id>
            <docTitle>{ $docTitle }</docTitle>
            <kwic>{ $kwic }</kwic>
            <provenanceUri></provenanceUri>
        </tr>
        
};
(:~
    Callback function called from the kwic module.
:)
declare %private function ausohnumSearch:filter($node as node(), $mode as xs:string?) as text()? {
  if ($node/parent::SPEAKER or $node/parent::STAGEDIR) then
      ()
  else if ($mode eq 'before') then
      text { concat($node, ' ') }
  else
      text { concat(' ', $node) }
};

(:~
    Helper function: create a lucene query from the user input
:)
declare function ausohnumSearch:create-query($queryStr as xs:string?, $mode as xs:string?) {
        <query>
        {
            if ($mode eq 'any') then
                for $term in tokenize($queryStr, '\s')
                return
                    if (contains($term, "*"))
                        then <wildcard occur="should">{$term}</wildcard>
                        else <term occur="should">{$term}</term>
            else if ($mode eq 'all') then
                for $term in tokenize($queryStr, '\s')
                return
                  if (contains($term, "*"))
                        then <wildcard occur="must">{$term}</wildcard>
                        else <term occur="must">{$term}</term>
            else if ($mode eq 'phrase') then
                <phrase>{$queryStr}</phrase>
            else
                <near>{$queryStr}</near>
        }
        </query>
};

declare function ausohnumSearch:displayResults($data){

    <div class="ausohnumSearch:from-session">{$data}
        <div class="ausohnumSearch:show-hits"/>
    </div>
};


(:~
 : @from Srophé
 : Passes any tei:geo coordinates in results set to map function. 
 : Suppress map if no coords are found. 
:)                   
declare function ausohnumSearch:display-map($node as node(), $model as map(*)){
    
    if($model("hits")) then 
        let $requiredHits :=<hits>{
        for $hit in $model("hits")
            let $doc := $hit/ancestor::tei:TEI
            let $docId := data($doc/@xml:id)
            return 
                <item>
                    <docId>{ $docId }</docId>
                    <docOrigPlace>{
                            if(exists($doc//tei:origPlace/@ref)) then 
                                tokenize($doc//tei:origPlace/@ref, " ")[1] 
                            else if(exists($doc//tei:provenance/tei:location/tei:placeName)) then
                                tokenize($doc//tei:provenance/tei:location/tei:placeName/@ref, " ")[1]
                            else 
                                        substring-before($doc//spatial:Feature/@rdf:about, "#this")}</docOrigPlace>
                </item>
        }</hits>
        let $geoJson:=
        <geojson>{serialize(<root json:array="false" type="FeatureCollection">{ 
            let $places := functx:distinct-deep(
                for $item in $requiredHits//docOrigPlace
                return $item)
            let $placesFromGazetteer := for $place in $places
                let $placeObject := doc("/db/apps/" ||$ausohnumSearch:project || "Data/places/project-places-gazetteer.xml" )//features[properties/uri = $place]
                return 
                if($placeObject//coordinates[contains(., "0, 0")]) then () else
                <features type="Feature">{$place//coordinates/text()}
                    <properties>
                        { $placeObject//properties/node() }
                        <hits>
                        { for $hitInPlace in $requiredHits//item[./docOrigPlace/text()= $place]//docId
                            return <docId>{ $hitInPlace/text()}</docId>
                            }
                        </hits>
                    </properties>
                    { $placeObject/style }
                    { $placeObject/geometry }
                </features>
                return $placesFromGazetteer}</root>,
        <output:serialization-parameters>
                <output:method>json</output:method>
                <output:json-ignore-whitespace-text-nodes>yes</output:json-ignore-whitespace-text-nodes>
                <output:media-type>text/javascript</output:media-type>
            </output:serialization-parameters>)}
                </geojson>
        return
        ((: $geoJson, :)
        maps:build-leaflet-map-withGeoJson($geoJson,
        count($model("hits")/descendant::tei:origPlace//descendant::tei:geo))
        )
    else ()
};

declare function ausohnumSearch:displayTextPreviewWithHighlight($project as xs:string, $id as xs:string){
    let $doc := collection("/db/apps/" || $project || "Data/documents")/id($id)
    let $params := <parameters>
                        <param name="keywordUri" value=""/>
                        <param name="css-loc" value="/$epidocLib/resources/xsl/epidoc-stylesheets/"/>
                        <param name="leiden-style" value="panciera"/>
                        <param name="edition-type" value="interpretive"/>
                        <param name="edn-structure" value="london"/>  
                        <param name="line-inc" value="5"/>
                    </parameters>
    let $xslt := doc("/db/apps/ausohnum-library-dev" || "/xslt/highlightMatches.xsl")
    (: let $text := functx:change-element-ns-deep($hit, "http://www.tei-c.org/ns/1.0", "") :)
    return 
    (: $doc//tei:div[@type="edition"] :)
    transform:transform($doc//tei:div[@type="edition"], $xslt, $params)
    
};