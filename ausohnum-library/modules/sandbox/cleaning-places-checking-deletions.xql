xquery version "3.1";

import module namespace http="http://expath.org/ns/http-client" at "java:org.expath.exist.HttpClientModule";
import module namespace teiEditor="http://ausonius.huma-num.fr/teiEditor"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/teiEditor/teiEditorApp.xql";
import module namespace prosopoManager="http://ausonius.huma-num.fr/prosopoManager"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/prosopoManager/prosopoManager.xql";

import module namespace functx="http://www.functx.com";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare namespace lawd="http://lawd.info/ontology/";
declare namespace apc="http://patrimonium.huma-num.fr/onto#";
declare namespace foaf="http://xmlns.com/foaf/0.1/"; 
declare namespace pleiades="https://pleiades.stoa.org/places/vocab#";
declare namespace owl="http://www.w3.org/2002/07/owl#";
declare namespace skos="http://www.w3.org/2004/02/skos/core#"; 
declare namespace geo="http://www.w3.org/2003/01/geo/wgs84_pos#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace dcterms="http://purl.org/dc/terms/";
declare namespace ausohnum="http://ausonius.huma-num.fr/onto";
declare namespace spatial="http://geovocab.org/spatial#";
declare boundary-space preserve;

let $now := fn:current-dateTime()
let $currentUser := data(sm:id()//sm:username)
let $nl := '&#xa;'
    

let $plotsRaw := util:binary-to-string(util:binary-doc('xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/landplots/ousia-plots.csv'))
let $plots := tokenize(replace($plotsRaw, '"', ''), "\r\n")
let $docs := collection('xmldb:exist:///db/apps/patrimoniumData/documents')
let $places := collection('xmldb:exist:///db/apps/patrimoniumData/places/patrimonium')
let $people := collection('xmldb:exist:///db/apps/patrimoniumData/people')
let $placesToBeChecked := "52269
52701
52700
53310
52735
7141"

return
    for $placeToBecChecked in tokenize($placesToBeChecked, "\n")
    return
let $placeId := "places/" || $placeToBecChecked
return
    <results placeId="{ $placeId }">
    {for $doc in $docs//tei:TEI[.//tei:listPlace/tei:place/tei:placeName[contains(./@ref, $placeId)]]
    return <docs>{data($doc/@xml:id)} [{util:collection-name($doc)}]</docs>}
    {
    for $place in $places//.[contains(./@rdf:resource, $placeId)]
    return <places>{data($place/ancestor-or-self::spatial:Feature/@rdf:about)}</places>
    }
    {
    for $person in $people//.[contains(./@rdf:resource, $placeId)]
    return <person>{data($person/ancestor-or-self::lawd:person/@rdf:about)}</person>
    }
    {
    for $target in $people//.[contains(./@target, $placeId)]
    return <target>{data($target/ancestor-or-self::lawd:person/@rdf:about)}</target>
    }
    </results>