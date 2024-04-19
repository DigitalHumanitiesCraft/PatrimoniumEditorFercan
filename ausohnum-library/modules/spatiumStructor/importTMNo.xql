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
    
let $logs := doc('xmldb:exist:///db/apps/patrimoniumData/logs/logs-import-egyptianMaterial.xml')
let $apcNoStart := 54000
let $places2beprocessed := doc('xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/meta/tmPlaces2BeAdded.xml')
let $tmPlaces := collection('xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/meta/geo')


return 
<places>
    {
    for $place at $pos in $places2beprocessed//place
(:        where $pos <110:)
        let $tmPlace :=$tmPlaces/id("geo" || substring-after($place/@uris, "/place/"))[1]
        let $statusRaw :=$tmPlace/status/text()
        let $status :=
                    if(contains($statusRaw, ":"))
                    then substring-before($statusRaw, ":")
                    else if(contains($statusRaw, ",")) then substring-before($statusRaw, ",")
                    else if(contains($statusRaw, ";")) then substring-before($statusRaw, ";")
                    else if(contains($statusRaw, "?")) then substring-before($statusRaw, "?")
                    else $statusRaw
        let $mainType :=
            switch($status)
                case "area" return "https://ausohnum.huma-num.fr/concept/c21867"
                case "building" return "https://ausohnum.huma-num.fr/concept/c23585"
                case "canal" return "no-uri-for-canal"
                case "city" return "https://ausohnum.huma-num.fr/concept/c21865"
                case "district" return "https://ausohnum.huma-num.fr/concept/c21998"
                case "ethnicon" return "https://ausohnum.huma-num.fr/concept/c21864"
                case "kleros" return "https://ausohnum.huma-num.fr/concept/c23586"
                case "ousia" return "https://ausohnum.huma-num.fr/concept/c23587"
                case "people" return "no-uri-for-people"
                case "phyle" return "no-uri-for-phyle"
                case "quarter" return "no-uri-for-quater"
                case "region" return "https://ausohnum.huma-num.fr/concept/c21863"
                case "river" return "no-uri-for-river"
                case "sanctuary" return "no-uri-for-sanctuary"
                case "sea" return "no-uri-for-sea"
                case "topos" return "no-uri-for-topos"
                case "village" return "https://ausohnum.huma-num.fr/concept/c21866"
                case "well" return "no-uri-for-well"
                default return "no-uri-for" || encode-for-uri($status)
                
        return
   <rdf:RDF xmlns:pleiades="https://pleiades.stoa.org/places/vocab#" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:spatial="http://geovocab.org/spatial#" xmlns:prov="http://www.w3.org/TR/prov-o/#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:spatium="http://ausonius.huma-num.fr/spatium-ontoology" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:lawdi="http://lawd.info/ontology/" xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/">
        <spatial:Feature rdf:about="https://patrimonium.huma-num.fr/places/{$apcNoStart + $pos }#this">
             <skos:exactMatch rdf:resource="{$tmPlace/@rdf:about}"/>
             <spatial:P rdf:resource="https://patrimonium.huma-num.fr/places/1031"/>
            <foaf:primaryTopicOf>
                <pleiades:Place rdf:about="https://patrimonium.huma-num.fr/places/{$apcNoStart + $pos }">
                    <dcterms:title xml:lang="en">{ $tmPlace/name_standard/text()}</dcterms:title>
                    <skos:altLabel xml:lang="grc">{ $tmPlace//unicode_greek/text()}</skos:altLabel>
                    <skos:altLabel xml:lang="egyx">{ $tmPlace//unicode_egyptian/text()}</skos:altLabel>
                    <pleiades:hasFeatureType type="main" rdf:resource="{ $mainType }"/>
                    {if($tmPlace/coordinates/text()) then (
                    <geo:long rdf:datatype="http://www.w3.org/2001/XMLSchema#float">{substring-after($tmPlace/coordinates[1], ",")}</geo:long>
                    )
                    else (
                    <geo:long rdf:datatype="http://www.w3.org/2001/XMLSchema#float"/>
                    )}
                    {if($tmPlace/coordinates/text()) then (
                    <geo:lat rdf:datatype="http://www.w3.org/2001/XMLSchema#float">{substring-before($tmPlace/coordinates, ",")}</geo:lat>
                    )
                    else (
                    <geo:lat rdf:datatype="http://www.w3.org/2001/XMLSchema#float"/>
                    )}
                    <skos:note>Status in TM: { $tmPlace/status/text() }</skos:note>
                </pleiades:Place>
            </foaf:primaryTopicOf>
            <pleiades:Location rdf:about="https://patrimonium.huma-num.fr/places/{ $apcNoStart + $pos }/position">
                <prov:wasDerivedFrom>
                    <rdf:Description>
                        <rdfs:label>Trismegistos</rdfs:label>
                    </rdf:Description>
                </prov:wasDerivedFrom>
                {if($tmPlace/coordinates/text()) then (
                <osgeo:asGeoJSON>{{"type": "Point", "coordinates": [{substring-after($tmPlace/coordinates, ",")}, {substring-before($tmPlace/coordinates, ",")}]}}</osgeo:asGeoJSON>
                    )
                    else (
                <osgeo:asGeoJSON/>
                    )}
                {if($tmPlace/coordinates/text()) then (
                <osgeo:asWKT>POINT ({substring-after($tmPlace/coordinates, ",")} {substring-before($tmPlace/coordinates, ",")})</osgeo:asWKT>
                    )
                    else (
                <osgeo:asWKT/>
                    )}
                <pleiades:start_date rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">{ $tmPlace/begin_date/text() }</pleiades:start_date>
                <pleiades:end_date rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">{ $tmPlace/end_date/text() }</pleiades:end_date>
            </pleiades:Location>
        </spatial:Feature>
 </rdf:RDF>
   }
</places>