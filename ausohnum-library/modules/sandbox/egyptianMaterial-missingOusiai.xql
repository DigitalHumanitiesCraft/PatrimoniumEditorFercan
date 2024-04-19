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
    
let $logs := doc('xmldb:exist:///db/apps/patrimoniumData/logs/logs-import-egyptianMaterial.xml')
let $apcNoStart := 55000
let $plotsRaw := util:binary-to-string(util:binary-doc('xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/cleaning-ousia/ousia-plots.csv'))
let $plots := tokenize(replace($plotsRaw, '"', ''), "\r\n")
let $ousiaForPlots := doc('xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/cleaning-ousia/ousiaForPlots.xml')
let $tmPlaces := doc('xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/cleaning-ousia/egyptianMaterialPlaces.xml')
let $ousiaTableRaw := util:binary-to-string(util:binary-doc('xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/cleaning-ousia/ousiaiPlots_to_ousiaID.csv'))
let $ousiaTable := tokenize(replace($ousiaTableRaw, '"', ''), '\r\n')
let $ousiaiDetails := doc('xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/cleaning-ousia/ousiai.xml')
let $geoToOusiaXml := doc('xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/cleaning-ousia/geoToOusia.xml')

let $problematicOusia := 
    (5, 15, 22, 39, 47, 81, 137, 138, 139, 140, 144, 154, 158, 159)
let $geoToOusiaRaw := util:binary-to-string(util:binary-doc("xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/cleaning-ousia/geoToOusia.csv"))
let $geoToOusia := tokenize(replace($geoToOusiaRaw, '"', ''), "\r\n")
let $ousiaList := doc('xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/cleaning-ousia/ousiaList.xml')    
let $mainType:= "https://ausohnum.huma-num.fr/concept/c23587"
let $ousiai :=
(for $place at $pos in $problematicOusia
    let $apcUri := data($ousiaList//ousia[ousiaNo = $place ][1]//apcNo)
    
    return 
        if($apcUri != "") then ()
        else(
            let $placeUri := "https://patrimonium.huma-num.fr/places/" || $apcNoStart + $pos
            let $ousiaDetails := $ousiaiDetails//item[ousia_id = $place]
             
            return
                (
                <rdf:RDF xmlns:pleiades="https://pleiades.stoa.org/places/vocab#" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:spatial="http://geovocab.org/spatial#" xmlns:prov="http://www.w3.org/TR/prov-o/#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:spatium="http://ausonius.huma-num.fr/spatium-ontoology" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:lawdi="http://lawd.info/ontology/" xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/">
        <spatial:Feature rdf:about="{ $placeUri }#this">{ if($geoToOusiaXml//item[ousia_id = $place]) then
            for $tm in $geoToOusiaXml//item[ousia_id = $place] return 
                <skos:exactMatch rdf:resource="https://www.trismegistos.org/place/{$tm/geo_id/text()}"/>
                else()
            }
            <skos:exactMatch rdf:resource="https://www.trismegistos.org/ousiaTM/{$place}"/>
            <spatial:P rdf:resource="https://patrimonium.huma-num.fr/places/1031"/>
            <foaf:primaryTopicOf>
                <pleiades:Place rdf:about="{ $placeUri }">
                    <dcterms:title xml:lang="en">{ $ousiaDetails//name/text()}</dcterms:title>
                    <pleiades:hasFeatureType type="main" rdf:resource="{ $mainType }"/>
                    <geo:long rdf:datatype="http://www.w3.org/2001/XMLSchema#float"/>
                    <geo:lat rdf:datatype="http://www.w3.org/2001/XMLSchema#float"/>
                    <skos:note>Ousia owner: { $ousiaDetails//owner/text()}{
                        if ($ousiaDetails//PIR_id != "") then " (" || $ousiaDetails//PIR_id/text() || ")"
                                                    else()}{
                        if ($ousiaDetails//TM_Per_id != "") then " (" || $ousiaDetails//TM_Per_id/text() || ")"
                                                    else()}{
                        if ($ousiaDetails//comments_owner != "") then ". " || $ousiaDetails//comments_owner/text() || ")"
                                                    else()}
                   </skos:note>
                </pleiades:Place>
            </foaf:primaryTopicOf>
            <pleiades:Location rdf:about="https://patrimonium.huma-num.fr/places/{ $apcNoStart + $pos }/position">
                <prov:wasDerivedFrom>
                    <rdf:Description>
                        <rdfs:label>Trismegistos</rdfs:label>
                    </rdf:Description>
                </prov:wasDerivedFrom>
                <osgeo:asGeoJSON/>
                <osgeo:asWKT/>
                <pleiades:start_date rdf:datatype="http://www.w3.org/2001/XMLSchema#integer"></pleiades:start_date>
                <pleiades:end_date rdf:datatype="http://www.w3.org/2001/XMLSchema#integer"></pleiades:end_date>
            </pleiades:Location>
        </spatial:Feature>
 </rdf:RDF>, $nl)
        ))
        return
<ousia number="{count($ousiai)}">
{ $ousiai }
</ousia>       
