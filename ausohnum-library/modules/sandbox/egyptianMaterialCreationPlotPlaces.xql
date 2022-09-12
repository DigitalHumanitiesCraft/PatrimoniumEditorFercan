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
let $apcNoStart := 55013
let $plotsRaw := util:binary-to-string(util:binary-doc('xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/cleaning-ousia/ousia-plots.csv'))
let $plots := tokenize(replace($plotsRaw, '"', ''), "\r\n")
let $ousiaForPlots := doc('xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/cleaning-ousia/ousiaForPlots.xml')
let $tmPlaces := collection('xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/cleaning-ousia/places')
let $ousiaTableRaw := util:binary-to-string(util:binary-doc('xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/cleaning-ousia/ousiaiPlots_to_ousiaID.csv'))
let $ousiaTable := tokenize(replace($ousiaTableRaw, '"', ''), '\r\n')
let $ousiaPlots :=
<ousiaPlots>
    {
    for $place at $pos in $plots[position()>1]
(:        where $pos <110:)
        let $placeRecord := tokenize($place, ";")
        let $ousiaRefId := $placeRecord[1]
        let $locationTmNo := $placeRecord[7]
        let $nomeTMUri := "https://www.trismegistos.org/place/" || $placeRecord[12]
        let $apcNomeUriLong := $tmPlaces//spatial:Feature[skos:exactMatch[@rdf:resource = $nomeTMUri]]/@rdf:about
        let $apcNomeUriShort := substring-before($apcNomeUriLong, "#this")
        let $locationTmUri := "https://www.trismegistos.org/place/" || $locationTmNo
        let $apcPlaceLocationUriLong := $tmPlaces//spatial:Feature[skos:exactMatch[@rdf:resource = $locationTmUri]]/@rdf:about
        let $apcPlaceLocationUriShort := substring-before($apcPlaceLocationUriLong, "#this")
        
        let $ousiaApcUri := data($ousiaForPlots//plot[@ousiaIdRef = $ousiaRefId]/@apcPlace) 
        let $ousiaName := $ousiaForPlots//plot[@ousiaIdRef = $ousiaRefId]//name/text() 
        let $placeUri := "https://patrimonium.huma-num.fr/places/" || $apcNoStart + $pos
(:        let $tmPlace :=$tmPlaces/id("geo" || substring-after($place/@uris, "/place/"))[1]:)
        let $mainType:= "https://ausohnum.huma-num.fr/concept/c21871"
        
        let $spatialPiForOusia := <spatialPi><spatial:Pi rdf:resource="{ $placeUri }"/>
        </spatialPi>
        let $insertSpatialPiInOusia := 
            for $ousia in $ousiaApcUri 
            return update insert $spatialPiForOusia/node()
            preceding $tmPlaces//spatial:Feature[@rdf:about = $ousia ||"#this"]//foaf:primaryTopicOf
            
        let $spacialCForLocation :=<spatialC><spatial:C type="hasInItsVincinity" rdf:resource="{ $placeUri}"/>
        </spatialC>
        let $updatLocationPlaceWithSpatialC :=
        if ($apcPlaceLocationUriShort = $apcNomeUriShort ) then ()
                 else 
                    for $location in $apcPlaceLocationUriLong
                    return
                    update insert $spacialCForLocation/node() preceding $tmPlaces//spatial:Feature[@rdf:about = $apcPlaceLocationUriLong]//foaf:primaryTopicOf
        
        let $spatialPiForNome := <spatialPi><spatial:Pi rdf:resource="{ $placeUri }"/>
        </spatialPi>
        let $insertSpatialPiInNome := 
        if ($apcPlaceLocationUriShort = $apcNomeUriShort ) then ()
                 else 
                    for $ousia in $ousiaApcUri 
                    return update insert $spatialPiForNome/node()
                    preceding $tmPlaces//spatial:Feature[@rdf:about = $apcNomeUriLong]//foaf:primaryTopicOf
        return
            if ($ousiaApcUri = "") then
                (<error ousiaIdRef="{$ousiaRefId}" ousiaId="{ string-join($ousiaForPlots//plot[@ousiaIdRef = $ousiaRefId]/@ousiaId, ' ') }" type="noCorrespondingApc"/>, $nl)
                else (
   <rdf:RDF xmlns:pleiades="https://pleiades.stoa.org/places/vocab#" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:spatial="http://geovocab.org/spatial#" xmlns:prov="http://www.w3.org/TR/prov-o/#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:spatium="http://ausonius.huma-num.fr/spatium-ontoology" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:lawdi="http://lawd.info/ontology/" xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/">
        <spatial:Feature rdf:about="{ $placeUri }#this">
             <skos:exactMatch rdf:resource="https://www.trismegistos.org/ousiaRefId/{$ousiaRefId}"/>
             <spatial:P rdf:resource="{ $apcNomeUriShort }"/>
             <spatial:P rdf:resource="{ $ousiaApcUri }"/>{
                 if ($apcPlaceLocationUriShort = $apcNomeUriShort ) then ()
                 else 
             (<spatial:C type="isInVincinityOf" rdf:resource="{ $apcPlaceLocationUriShort }"/>)}
            <foaf:primaryTopicOf>
                <pleiades:Place rdf:about="{ $placeUri }">
                    <dcterms:title xml:lang="en">Land plot of {$ousiaName} ({ $placeRecord[8] })</dcterms:title>
                    <skos:altLabel xml:lang="en">Land plot of {$ousiaName} at { $placeRecord[8] }</skos:altLabel>
                    <skos:altLabel xml:lang="en">Land plot of {$ousiaName}</skos:altLabel>
                    <skos:altLabel xml:lang="en">Land plot (no. { $ousiaRefId}) of {$ousiaName} near village { $placeRecord[8] }</skos:altLabel>
                    <pleiades:hasFeatureType type="main" rdf:resource="{ $mainType }"/>
                    <geo:long rdf:datatype="http://www.w3.org/2001/XMLSchema#float"/>
                    <geo:lat rdf:datatype="http://www.w3.org/2001/XMLSchema#float"/>
                    <skos:note>This place is the land plot TM ousiaRefId { $ousiaRefId } associated with ousia {$ousiaName} [{ $ousiaApcUri } = TMGeo {$locationTmNo}]</skos:note>
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
   }
</ousiaPlots>


let $createPlotFile := xmldb:store("xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/cleaning-ousia/files",
            "ousiaPlots" 
            || substring(replace($now, ":", "-"), 1, 16) || ".xml",
<places number="{ count($ousiaPlots//rdf:RDF)}">
    { for $place in $ousiaPlots//rdf:RDF 
    return
        ($place, $nl) }
</places>)
let $createErrorFile := xmldb:store("xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/cleaning-ousia/files",
            "errorsInousiaPlots" 
            || substring(replace($now, ":", "-"), 1, 16) || ".xml",
<errors number="{ count($ousiaPlots//error) }">
    { for $error in $ousiaPlots//error
    return
        ($error, $nl) }
</errors>)
return
    "Places created: " || count($ousiaPlots//spatial:Feature) || $nl
    || "Errors: " || count($ousiaPlots//error)