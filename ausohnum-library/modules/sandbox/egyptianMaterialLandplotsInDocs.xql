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
let $docs := collection('xmldb:exist:///db/apps/patrimoniumData/documents/documents-ybroux')
let $places := collection('xmldb:exist:///db/apps/patrimoniumData/places/patrimonium')

return 
    for $landplot at $pos in $plots where $pos > 1 and $pos < 5
    let $landplotDetails := tokenize($landplot, ";")
    let $ousiaRefId := "https://www.trismegistos.org/ousiaRefId/" || $landplotDetails[1]
    let $apcPlaceUriLong := data($places//spatial:Feature[skos:exactMatch[@rdf:resource= $ousiaRefId]]/@rdf:about)
    let $apcPlaceUriShort := substring-before($apcPlaceUriLong, '#this') 
    let $docTM := "https://www.trismegistos.org/text/" || $landplotDetails[2]
    let $apcDoc := $docs//tei:TEI[tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:altIdentifier/tei:idno/text()= $docTM]
    let $placeNode := <data>
<place>
        <placeName ref="{ $apcPlaceUriShort }" ana=""/>
</place></data>
    let $insertPlaceInDoc :=
        if(not($apcDoc//tei:listPlace//tei:placeName[@ref=$apcPlaceUriShort])) then
            update insert $placeNode/node() into $apcDoc//tei:listPlace
            else ()
return $insertPlaceInDoc



