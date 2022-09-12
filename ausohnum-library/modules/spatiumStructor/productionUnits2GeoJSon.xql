xquery version "3.1";

(:import module namespace spatiumStructor="http://ausonius.huma-num.fr/spatiumStructor" at "./spatiumStructor.xql";:)
import module namespace functx="http://www.functx.com";
import module namespace spatiumStructor="http://ausonius.huma-num.fr/spatiumStructor" at "spatiumStructor.xql";
import module namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/" at "../skosThesau/skosThesauApp.xql";
declare namespace json="http://www.json.org";

declare namespace apc="http://patrimonium.huma-num.fr/onto#";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace dct = "http://purl.org/dc/terms/";
declare namespace dcterms="http://purl.org/dc/terms/";
declare namespace ev = "http://www.w3.org/2001/xml-events";
declare namespace geo = "http://www.w3.org/2003/01/geo/wgs84_pos#";
declare namespace http="http://expath.org/ns/http-client";

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


(:declare option exist:serialize "method=xml media-type=xml";:)

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:indent "yes";
(: Switch to JSON serialization :)

declare option output:method "json";
declare option output:media-type "application/json";


declare variable $project :=request:get-parameter('project', ());
declare variable $library-path := "/db/apps/ausohnum-library/";
declare variable $places := collection("/db/apps/" || $project || "Data/places" || "/" || $project)//rdf:RDF;
declare variable $appVariables := doc("/db/apps/" || $project || "/data/app-general-parameters.xml");
(:declare variable $concept-collection:= collection("/db/apps/" || $appVariables//thesaurus-app/text() || "Data/concepts");:)
declare variable $concept-collection:= doc("/db/apps/" || $appVariables//thesaurus-app/text() || "Data/concepts/" || $project || ".rdf");
declare variable $productionUnitTypes := skosThesau:getChildren($appVariables//productionUnitsUri/text(), $project);


(:let $places :=functx:distinct-deep(collection("/db/apps/" || $project || "Data/places/" || $project )//rdf:RDF):)

        <root json:array="true" type="FeatureCollection" count="{ count($places//pleiades:Place[pleiades:hasFeatureType[@type="main"][not(./@rdf:resource = "") and (contains((string-join($productionUnitTypes//skos:Concept/@rdf:about, ",")), ./@rdf:resource))]]) }">
        {for $place in $places//pleiades:Place[pleiades:hasFeatureType[@type="main"][not(./@rdf:resource = "") and (contains((string-join($productionUnitTypes//skos:Concept/@rdf:about, ",")), ./@rdf:resource))]]
                    let $uri := $place/@rdf:about
                    let $placeName := $place/dcterms:title/text() 
                     (:let $mainPlaceType := if($place/pleiades:hasFeatureType[@type = "main"]/@rdf:resource) 
                        then  $projectThesaurus//skos:Concept[@rdf:about = $place/pleiades:hasFeatureType[matches(./@type, "main")]/@rdf:resource]//skos:prefLabel[@xml:lang ="en"]/text()
                                                            else("untyped place"):)
                     let $mainPlaceTypeUri := functx:if-absent($place//pleiades:hasFeatureType[@type = "main"]/@rdf:resource, "no-type")
                     let $mainPlaceType :=
                           functx:if-absent(
                                $concept-collection//skos:Concept[@rdf:about = $mainPlaceTypeUri]//skos:prefLabel[@xml:lang ="en"]/text(),
                                "untyped place")
                            
                     let $productionTypeUris := $place/pleiades:hasFeatureType[@type = "productionType"]/@rdf:resource
                                         let $productionType := if($productionTypeUris) then
                                    for $productionTypeUri at $pos in $productionTypeUris 
                                        where $productionTypeUri != ""
                                        return 
                                            <productionType>{
                                                $concept-collection//skos:Concept[@rdf:about = $productionTypeUri]//skos:prefLabel[@xml:lang ="en"]/text()
                                                }</productionType>
                                         else
                                             ()
                       let $marker := concat("marker-",
                                            switch(lower-case($mainPlaceType))
                                                        case "landed estate" return
                                                        (
                                                            if($productionType[1]) then 
                                                                switch(lower-case($productionType[1]))
                                                                        case "wheat" return "farming-wheat"
                                                                        case "cereals"
                                                                            return "farming-wheat-and-others"
                                                                        case "vineyard" return "farming-vineyard"
                                                                        
                                                                default return "color-violet"
        (:                                                    || "Icon":)
                                                            else("color-violet")
                                                        )
                                                       case "workshop" return 
                                                       ( if($productionType[1]) then 
                                                                switch(lower-case($productionType[1]))
                                                                    case "bricks" return "workshops-bricks"
                                                                    default return concat("workshps-", lower-case($productionType[1]))
                                                                
                                                                else ("color-violet")
                                                            )
                                                       case "military camp/outpost" return "default"
                                                       case "modern place" case "city" case "settlement" case "village/settlement" return "default"
                                                       case "mine" case "quarry" return "color-green"
                                                       case "area" case "geographic region" return "color-green"
                                                       case "production units" return "default"
                                                       case "administrative district" return "default"
                                                       case "station" return "default"
                                                       case "roman provinces" case "province" return "color-black"
                                                       case "ethnic region" return "color-black"
                                                       case "untyped place" return "color-red"
                                                       default return 
                                                             "default"
                                                       , ".png")

        
        (:let $docs := <div class="xmlElementGroup">
                                      <span class="subSectionTitle">List of documents linked to this place</span>
                                      <div id="listOfDocuments">
                                      {if (spatiumStructor:relatedDocuments($uri)) then
                                      (
                                      <ul class="listNoBullet">{
                                        for $doc in spatiumStructor:relatedDocuments($uri) 
             (\:                           $spatiumStructor:doc-collection//tei:TEI[descendant-or-self::tei:placeName[@ref=$uriShort]]:\)
                                         (\:$spatiumStructor:doc-collection//tei:TEI[tei:listPlace//tei:place//tei:placeName[@ref=$uriShort]]:\)
                                                let $docId := data($doc/@xml:id)
                                                let $title := $doc//tei:titleStmt/tei:title/text()
                                                let $docUri := if($doc//tei:fileDesc/tei:publicationStmt/tei:idno[@type="uri"]) then $doc//tei:fileDesc/tei:publicationStmt/tei:idno[@type="uri"]
                                                                         else $spatiumStructor:uriBase || "/documents/" || $docId
                                                let $placeType := (
                                                                             let $placeNodes := 
                                                                             $doc//tei:listPlace//tei:place//tei:placeName[contains(./@ref, $uri)]
                                                                             for $placeNode in $placeNodes
                                                                                 return
                                                                                     if ($placeNode/@ana)
                                                                                     then data($placeNode/@ana)
                                                                                     else if (not($placeNode/@ana)) then ($placeNode/parent::node()/name())
                                                                                     else ()
                                                                                     )
                                                          return
                                                             <li>
                                                             <span class="glyphicon glyphicon-file"/><a href="{ $docUri }" title="Open document { $docUri }" target="_self">{ $title }</a>
                                                             
                                                                             <span>[{""
(\:                                                                             $placeType :\)
                                                                             }]</span><a href="{ $docUri }" title="Open document { $docUri } in a new window" target="_blank">
                                                                             <i class="glyphicon glyphicon-new-window"/></a>
                                                             </li>
                                         
                                         }</ul>)
                                         
                                         else (<em>None</em>)}
                                         </div>
                                         
                                  </div>
        :)       
        
        let $coordinates :=
        if($place/geo:long/text() != "")
                                            then      (<geoCoord>
                                                          <coordinates json:array="true" json:literal="false">{ $place/geo:long/text()}, {$place/geo:lat/text()}</coordinates>
                                                          
                                                        </geoCoord>)
                                             else (
                                                        let $isPartOf := $place/ancestor::spatial:Feature//spatial:P
                                                        let $isInVicinityOf := $place/ancestor::spatial:Feature//spatial:C[@type='isInVicinityOf']
                                                        let $isPartOfCoordinates := 
                                                           
                                                             for $parent in $isPartOf
                                                               let $parentUri := data($parent/@rdf:resource)
                                                                let $parentNode := $spatiumStructor:place-collection//pleiades:Place[@rdf:about= $parentUri][1]
                                                                let $parentGeoCoordinates := if($parentNode/geo:long/text() != "") then (<geoCoord>
                                                                              <coordinates json:array="true" json:literal="false">{ $parentNode/geo:long/text()}, { $parentNode/geo:lat/text() }</coordinates>
                                                                              
                                                                            </geoCoord>) 
                                                                            else (<geoCoord>
                                                                              <coordinates json:array="true" json:literal="false">1, 1</coordinates>
                                                             
                                                                            </geoCoord>)
                                                                   return $parentGeoCoordinates
                                                         
                                                         
                                                         let $isInVicinityOfCoordinates := 
                                                           
                                                             for $parent in $isInVicinityOf[1]
                                                              let $parentUri := data($parent/@rdf:resource)
                                                                let $parentNode := $spatiumStructor:place-collection//pleiades:Place[@rdf:about= $parentUri]
                                                                let $parentGeoCoordinates := if($parentNode//geo:long/text() != "")
                                                                then (<geoCoord><coordinates json:array="true" json:literal="false">{ $parentNode/geo:long/text()}, { $parentNode/geo:lat/text() }</coordinates>
                                                                            </geoCoord>)
                                                                            else (<geoCoord>
                                                                             <coordinates json:array="true" json:literal="false">1, 1</coordinates>
                                                                              </geoCoord>
                                                                           )
                                                                            
                                                                   return
                                                                   $parentGeoCoordinates      
                                                        
                                                        return  
                                                        if( $isInVicinityOfCoordinates) then 
                                                        
                                                            $isInVicinityOfCoordinates
                                                            else 
                                                            <geoCoord>
                                                                              <coordinates json:array="true" json:literal="false">10, 10</coordinates>
                                                                              
                                                                            </geoCoord>
                                                        ) 
        
        return
        
        <features type="Feature">
                                <properties>
                                    <name>{ $placeName }</name>
                                    <uri>{data($place/@rdf:about)}</uri>
                                    <id>{ $uri }</id>
                                    <placeType>{ if ( $mainPlaceType = "MAN MADE MATERIAL") then "Please check type of place"
                                        else $mainPlaceType }</placeType>
                                    <productionType>{ if($productionType) then string-join($productionType, ", ") else ()
                                                                        }</productionType>
                                    <icon>{ $marker }</icon>
                                    <amenity></amenity>
                                    <popupContent>{"<h5>"  || $placeName || "</h5>"}
                                   {if($mainPlaceType) then "<div>" || $mainPlaceType || "</div>" else ("no main type")} 
                                        {'<span class="uri">' || $uri || '</span>'}
                                        {if($productionType) then '<div class="margin-top: 5em;"><span>Types of production: </span>' || string-join($productionType, ', ') || '</div>'
                                                                                                                    else("")}
                                        </popupContent>
                                 </properties>
                                 <style>
                                     <fill>red</fill>
                                     <fill-opacity>1</fill-opacity>
                                     </style>
                                     <geometry>
                                     <type>MultiPoint</type>
                                     { for $coordinate in $coordinates//coordinates
                                    return 
                                        <coordinates json:array="true" json:literal="false">[{ $coordinate/text()}]</coordinates>
                                        }
                                </geometry>
                                 
                                 </features>
                   }
                  
             </root>