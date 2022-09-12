(:~
: AusoHNum Library - spatial data manager module
: @author Vincent Razanajao
:)

xquery version "3.1";
import module namespace functx="http://www.functx.com";

declare namespace dcterms="http://purl.org/dc/terms/";
declare namespace geo = "http://www.w3.org/2003/01/geo/wgs84_pos#";
declare namespace json="http://www.json.org";
declare namespace lawd="http://lawd.info/ontology/";
declare namespace local="local";
declare namespace osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/";
declare namespace owl="http://www.w3.org/2002/07/owl#";
declare namespace pleiades="https://pleiades.stoa.org/places/vocab#";
declare namespace prism="http://prismstandard.org/namespaces/basic/2.0/";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace spatial="http://geovocab.org/spatial#";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare boundary-space preserve;

declare option output:method "xml";
declare option output:indent "yes";

declare variable $local:project external;
declare variable $project := $local:project;
(:declare variable $project := request:get-parameter('project', ());:)

declare variable $appVariables := doc("/db/apps/" || $project || "/data/app-general-parameters.xml");

declare variable $placeCollection := collection("/db/apps/" || $project || "Data/places/" || $project );
declare variable $placesGazetteer := doc("/db/apps/" || $project || "Data/places/project-places-gazetteer.xml");
declare variable $provinceTypeUris := "https://ausohnum.huma-num.fr/concept/c22264", "https://ausohnum.huma-num.fr/concept/c23737";
declare variable $adminDistrict := "https://ausohnum.huma-num.fr/concept/c23621";
declare variable $romanProvinces := ($placeCollection//pleiades:Place[pleiades:hasFeatureType[@rdf:resource="https://ausohnum.huma-num.fr/concept/c22264"]]
   ,
     $placeCollection//pleiades:Place[pleiades:hasFeatureType[@rdf:resource="https://ausohnum.huma-num.fr/concept/c23737"]]
   );
declare variable $romanProvincesUriList := string-join($romanProvinces//@rdf:about, " ");
declare variable $thesaurus-app  := doc('/db/apps/' || $project || '/data/app-general-parameters.xml')//thesaurus-app/text();
declare variable $conceptCollection := collection('/db/apps/'|| $thesaurus-app || "Data/concepts");
declare variable $newLine := '&#xa;';
declare variable $provinceTypeUri := "https://ausohnum.huma-num.fr/concept/c22264";
declare variable $nomosTypeUri := "https://ausohnum.huma-num.fr/concept/c26346";
declare variable $ousiaTypeUri := "https://ausohnum.huma-num.fr/concept/c23587";


declare function local:getRelatedPlacesCoordinates($placeUri as xs:string, $level as xs:int){

    let $placeUriLong := $placeUri || '#this'
    let $place := $placeCollection//spatial:Feature[@rdf:about= $placeUriLong ]
    
    return
    if($place//pleiades:Place/geo:long/text() != "")
            then      (
                         <coordinates json:array="true" json:literal="false"
                         type="{ $place//pleiades:hasFeatureType/@rdf:resource/string() }">{ $place//pleiades:Place/geo:long/text()}, {$place//pleiades:Place/geo:lat/text()}</coordinates>
                       )
        else if( $level = 2) then ()
        else if( $place//pleiades:hasFeatureType[@type="main"][@rdf:resource=$ousiaTypeUri]) then ()
        else (
             
             let $isPartOf := ($place//spatial:P)
             let $isMadeOf := ($place//spatial:Pi)
             let $isInVicinityOf := ($place//spatial:C[@type='isInVicinityOf'])
            
           let $coordinatesFromIsMadeOf :=
             if($isMadeOf) then (
                        for $relatedPlace in $isMadeOf
                                   let $relatedPlaceUri := data($relatedPlace/@rdf:resource)
                                   let $relatedPlaceNode := $placeCollection//spatial:Feature[@rdf:about= $relatedPlaceUri || "#this" ]
                                   let $relatedPlaceGeoCoordinates :=
                                  <geoCoord>{
                                                try { local:getRelatedPlacesCoordinates($relatedPlaceUri, $level +1) }
                                                catch * {"error in isMadeOf" } 
                                                }</geoCoord>
                                  
                                return $relatedPlaceGeoCoordinates
                                )
             else ()
          
          
          let $coordinatesFromIsInVicinityOf :=<geoCoord>{
                if($isInVicinityOf) then (
                    for $relatedPlace at $pos in $isInVicinityOf
                          let $relatedPlaceUri := data($relatedPlace/@rdf:resource)
                          let $relatedPlaceNode := $placeCollection//spatial:Feature[@rdf:about= $relatedPlaceUri || "#this" ]
                          let $relatedPlaceGeoCoordinates :=
                          (:Check if place is Province then discard     :)
                                if ($relatedPlaceNode//pleiades:hasFeatureType[@rdf:resource="https://ausohnum.huma-num.fr/concept/c22264"]) then ()
                                else if($relatedPlaceNode//geo:long/text() != "") then (
                          <coordinates json:array="true" json:literal="false" type="{ $relatedPlaceNode//pleiades:hasFeatureType/@rdf:resource/string() }">{ $relatedPlaceNode//pleiades:Place/geo:long/text()}, { $relatedPlaceNode//pleiades:Place/geo:lat/text() }</coordinates>
                          ) 
                    else (try { local:getRelatedPlacesCoordinates($relatedPlaceUri, $level + 1) }
                             catch * {"error in isMadeOf" } 
                            )
                   return $relatedPlaceGeoCoordinates
             )
             else ()}</geoCoord>
        
        let $coordinatesFromIsPartOf :=
                if($isPartOf) then (
                    for $relatedPlace in $isPartOf
                          let $relatedPlaceUri := data($relatedPlace/@rdf:resource)
                          let $relatedPlaceNode := $placeCollection//spatial:Feature[@rdf:about= $relatedPlaceUri || "#this" ]
                          let $relatedPlaceGeoCoordinates :=
                                (:Check if place is Province then discard     :)
                                (:Check number of related places; if more than 2 and place type is Province, then the place is discarded     :)
                                if (
                                (count($isPartOf) > 1) and
                                (
                                ($relatedPlaceNode//pleiades:hasFeatureType[@type="main"][@rdf:resource="https://ausohnum.huma-num.fr/concept/c22264"])
                                or ($relatedPlaceNode//pleiades:hasFeatureType[@type="main"][@rdf:resource="https://ausohnum.huma-num.fr/concept/c23587"])
                                )) then ()
                                else 
                                    if($relatedPlaceNode//geo:long/text() != "") then (<geoCoord type="{ $relatedPlaceNode//pleiades:hasFeatureType/@rdf:resource/string() }"><coordinates json:array="true" json:literal="false">{ $relatedPlaceNode//pleiades:Place/geo:long/text()}, { $relatedPlaceNode//pleiades:Place/geo:lat/text() }</coordinates></geoCoord>) 
                                                                                  else (
                                                                                  <geoCoord type="{ $relatedPlaceNode//pleiades:hasFeatureType/@rdf:resource/string() }">{
                                                                                                try { local:getRelatedPlacesCoordinates($relatedPlaceUri, $level + 1) }
                                                                                                catch * {"error in isPartOf" } 
                                                                                                }</geoCoord>
                                                                                  )
                   return $relatedPlaceGeoCoordinates
             )
             else ()
        
      return (
      if($coordinatesFromIsMadeOf//coordinates) then $coordinatesFromIsMadeOf else (), 
      if($coordinatesFromIsInVicinityOf//coordinates) then $coordinatesFromIsInVicinityOf else (),
      if((count($coordinatesFromIsMadeOf//coordinates) >0 ) or (count($coordinatesFromIsInVicinityOf//coordinates) >0) )
                then () else ($coordinatesFromIsPartOf) 
      )
(:             else( <coordinates json:array="true" json:literal="false">15, 15</coordinates>):)
             )
             
         
};

declare function local:getLastUpdatePlace($project){
let $collection := ("/db/apps/" || $project || "Data/places/" || $project)
let $childCollections := xmldb:get-child-collections($collection)
let $placesInChildCollections :=
    for $subCollection in $childCollections
        let $resources := for $resource in xmldb:get-child-resources($collection || "/" || $subCollection)
                        return <place path="{ $collection || "/" || $subCollection || $resource }" lastModified="{ xmldb:last-modified($collection || "/" || $subCollection, $resource) }"/>
    return $resources   
let $placesInParentCollection :=
   for $child in  xmldb:get-child-resources($collection)
(:   order by xs:dateTime(xmldb:last-modified($collection|| "/imports", $child)) descending:)
   return <place path="{ $collection || $child }" lastModified="{ xmldb:last-modified($collection, $child) }"/>
 let $places := ($placesInChildCollections, $placesInParentCollection) 
  
   
   return 
       for $place in $places
        order by xs:dateTime($place/@lastModified) descending
        return
       $place[1]
};


let $library-path := "/db/apps/ausohnum-library/"

let $appVariables := doc("/db/apps/" || $project || "/data/app-general-parameters.xml")

let $now := fn:current-dateTime()
let $currentUser := data(sm:id()//sm:username)

let $lastUpdate := xs:dateTime(data(local:getLastUpdatePlace($project)[1]/@lastModified))
let $gazetteerDate := xs:dateTime( $placesGazetteer//last-update/text())

return 
         if ($lastUpdate > $gazetteerDate ) then 
                    
                    
                    let $startTime := util:system-time()
                    
                    let $currentUser := data(sm:id()//sm:username)
                    
                    
                    let $productionUnitTypes := $conceptCollection//skos:Concept[skos:broader[@rdf:resource = $appVariables//productionUnitsUri/text()]]
                    
                    let $features :=
                                for $placeSpatialFeature at $pos in $placeCollection//spatial:Feature
                                        let $uriLong := data($placeSpatialFeature/@rdf:about)
                                        let $uri := substring-before($uriLong, "#this")
                                        let $id := functx:substring-after-last($uri, "/")
                                        let $place := $placeSpatialFeature//pleiades:Place
                                        let $exactMatch := string-join($placeSpatialFeature//skos:exactMatch/@rdf:resource, " ")
                                        let $placeName := $place/dcterms:title/text()
                                        let $altNames := string-join($place//skos:altLabel/text(), " ")
                                        let $provinceUri := $placeSpatialFeature//spatial:P[functx:contains-any-of($romanProvincesUriList, ./@rdf:resource/string()) ]/@rdf:resource/string()
                                        let $provinceName := $romanProvinces//.[@rdf:about = $provinceUri]//dcterms:title/text()      
                                         (:let $mainPlaceType := if($place/pleiades:hasFeatureType[@type = "main"]/@rdf:resource) 
                                            then  $projectThesaurus//skos:Concept[@rdf:about = $place/pleiades:hasFeatureType[matches(./@type, "main")]/@rdf:resource]//skos:prefLabel[@xml:lang ="en"]/text()
                                                                                else("untyped place"):)
                                         let $mainPlaceTypeUri := functx:if-absent($place//pleiades:hasFeatureType[@type = "main"]/@rdf:resource, "no-type")
                                         let $mainPlaceType :=
                                               functx:if-absent(
                                                    $conceptCollection//skos:Concept[@rdf:about = $mainPlaceTypeUri]//skos:prefLabel[@xml:lang ="en"]/text(),
                                                    "untyped place")
                                                
                                         let $productionTypeUris := $place/pleiades:hasFeatureType[@type = "productionType"]/@rdf:resource
                                          let $productionType := if($productionTypeUris) then
                                                        for $productionTypeUri at $pos in $productionTypeUris
                                                            let $label := functx:if-empty($conceptCollection//skos:Concept[@rdf:about = $productionTypeUri]//skos:prefLabel[@xml:lang ="en"]/text(), $conceptCollection//skos:Concept[@rdf:about = $productionTypeUri]//skos:prefLabel[1]/text())
                                                            where $productionTypeUri != ""
                                                            return 
                                                                <prodTypes>
                                                                    <productionType>{ $label }</productionType>
                                                                    <productionTypeLink><a href="{ $productionTypeUri }" target="_blank" class="label label-primary labelInTable">{ functx:capitalize-first($label) }</a></productionTypeLink>
                                                                 </prodTypes>
                                                                    
                                                             else
                                                                 ()
                                           let $marker := concat("marker-",
                                                                switch(lower-case($mainPlaceType))
                                                                            case "landed estate" return
                                                                                    (
                                                                                        if($productionType[1]) then 
                                                                                            switch(lower-case($productionType[1]/productionType))
                                                                                                    case "balsam" return "workshops-balsam"
                                                                                                    case "dates" return "farming-dates"
                                                                                                    case "horses" return "farming-horses"
                                                                                                    case "sheep" 
                                                                                                    case "goats" return "farming-sheeps"
                                                                                                    case "cereals"
                                                                                                        return "farming-wheat-and-others"
                                                                                                    case "olive" return "farming-olives"    
                                                                                                    case "olives" return "farming-olives"
                                                                                                    case "vineyard" 
                                                                                                    case "wine" 
                                                                                                    case "vines" return "farming-vineyard"
                                                                                                    case "wheat" return "farming-wheat"
                                                                                            default return "farming-wheat"
                                    (:                                                    || "Icon":)
                                                                                        else("farming-wheat")
                                                                                    )
                                                                           case "fishery" return "farming-fishery"         
                                                                           case "forest"
                                                                           case "forest or pastureland" return "forest-pasture"
                                                                           case "processing unit" return 
                                                                                            ( if($productionType[1]) then
                                                                                            switch(lower-case($productionType[1]/productionType))
                                                                                            case "olive oil" return "workshops-oliveoil"
                                                                                            case "iron"
                                                                                            case "gold"
                                                                                            case "lead"
                                                                                            case "silver" return "smelteries"
                                                                                            default return concat("workshops-",
                                                                                                "" || normalize-space(lower-case($productionType[1]/productionType)), "")
                                                                                    else()
                                                                                    )
                                                                           case "workshop" return 
                                                                           ( if($productionType[1]) then 
                                                                                    switch(lower-case($productionType[1]/productionType))
                                                                                        case "balsam" return "workshops-balsam"
                                                                                        case "bricks" return "workshops-bricks"
                                                                                        case "tiles" return "workshops-bricks"
                                                                                        case "iron" return "extraction-iron"
                                                                                        case "gold" return "extraction-gold"
                                                                                        case "lead" return "extraction-lead"
                                                                                        case "silver" return "extraction-silver"
                                                                                        case "olive oil" return "workshops-oliveoil"
                                                                                        default return concat("workshops-",
                                                                                        "" || normalize-space(lower-case($productionType[1]/productionType)), "")
                                                                                    
                                                                                    else ("color-violet")
                                                                                )
                                                                           case "military camp/outpost" return "default"
                                                                           case "modern place" case "city" case "settlement" case "village/settlement" return "default"
                                                                           case "mine" 
                                                                           case "mines" return "mines"
                                                                           case "quarry" return "extraction-marble"
                                                                           case "area" case "geographic region" return "color-green"
                                                                           case "production units" return "default"
                                                                           case "administrative district" return "default"
                                                                           case "station" return "default"
                                                                           case "roman provinces" case "province" return "color-black"
                                                                           case "ethnic region" return "color-black"
                                                                           case "villa" return "villa"
                                                                           case "domus" return "villa"
                                                                           case "flock" return "farming-sheeps"
                                                                           case "untyped place" return "color-red"
                                                                           default return 
                                                                                 "default"
                                                                           , ".png")
                    
                            
                             
                                     let $isPartOf := ($placeSpatialFeature//spatial:P)
                                     let $isMadeOf := ($placeSpatialFeature//spatial:Pi)
                                     let $isInVicinityOf := ($placeSpatialFeature//spatial:C[@type='isInVicinityOf'])
                                     let $coordinates :=(
                                        if($place//geo:long != "")
                                            then      (<geoCoord>
                                                                        <coordinates json:array="true" json:literal="false" type="assigned">{ $place/geo:long/text()}, {$place/geo:lat/text()}</coordinates>
                                                          </geoCoord>)
                                           else 
                                                    (
                    (:                                if isMadeOf take coordinates:)
                                                    (if($isMadeOf or $isInVicinityOf) 
                                                                then
                                                                     <geoCoord>{
                                                                         for $parent in ($isMadeOf, $isInVicinityOf)
                                                                                  return
                                                                                         
                                                                                                     try { local:getRelatedPlacesCoordinates(data($parent/@rdf:resource), 0) } 
                                                                                                     catch * {"error in in isMadeOf"}
                                                                                                   
                                                                          }</geoCoord>
                                                         else if ($isPartOf) then (
                                                                   <geoCoord>{
                                                                        for $parent in $isPartOf
                                                                            return 
                                                                               
                                                                                    try { local:getRelatedPlacesCoordinates(data($parent/@rdf:resource), 0) } 
                                                                                    catch * {"error in is InVicinityOf" || " - Error ", $err:code, ": ", $err:description}    
                                                                                   
                                                               }</geoCoord>
                                                                   )
                                                             else (<geoCoord><coordinates type="lastChance">0, 0</coordinates></geoCoord>
                                                             )
                                                      )
                    (:                                if isInVicinityOf take coordinates:)
                                                    (:(
                                                        if($isInVicinityOf//node())
                                                            then (
                                                                <geoCoord>{
                                                                        for $parent in $isInVicinityOf
                                                                            return 
                                                                                <coordinates>{ 
                                                                                              try { spatiumStructor:getRelatedPlacesCoordinates($project, $placeCollection, data($parent/@rdf:resource), 0) } 
                                                                                             catch * {"error in is InVicinityOf" || " - Error ", $err:code, ": ", $err:description}    }
                                                                                </coordinates>
                                                                  }</geoCoord>
                                                        ) else()
                                                        ):)
                    (:                                    if no isMadeOf and no IsInVicinity of take coordinates:)
                                                    (:(
                                                    if($isPartOf//node())
                                                            then (
                                                            <geoCoord>{
                                                                        for $parent in $isPartOf
                                                                            return 
                                                                                <coordinates>
                                                                                    {
                                                                                    try { spatiumStructor:getRelatedPlacesCoordinates($project, $placeCollection, data($parent/@rdf:resource), 0) } 
                                                                                    catch * {"error in is InVicinityOf" || " - Error ", $err:code, ": ", $err:description}    
                                                                                    }
                                                                                    </coordinates>
                                                               }</geoCoord>
                                                                    )
                                                        else(<coordinates>[0, 0]</coordinates>)
                                                    ):)
                                )                  )
                                          
          (:                                             
                    let $listOfCoordinates := if (normalize-space($coordinates) = "")
                                                            then <coordinates json:array="true" json:literal="false">[0, 0]</coordinates>
                                                            
                                                            else if($coordinates//coordinates[(normalize-space(.) !="") or (not(contains(./text(), "0, 0")))])
                                                                then 
                                                                    let $numberOfCoordinates := count($coordinates//coordinates)
                                                                    let $numberOfCoordinatesWith00 := count($coordinates//coordinates[./text() ="0, 0"])
                                                                    
                                                                    return
                                                                        if ($numberOfCoordinates >1) then
                                                                        (
                                                                                for $coord in $coordinates//coordinates[normalize-space(.) !=""][not(contains(./text(), "0, 0"))]
                                                                                
                                                                                return (
                                                                                    if (
                                                                                    (($coord/@type=$provinceTypeUri) or ($coord/@type=$ousiaTypeUri))
                                                                                    and (count($coordinates//coordinates[@type=$adminDistrict]) >1)
                                                                                    (\:and (exists($coordinates//coordinates[@type=$nomosTypeUri])
                                                                                            or
                                                                                            exists($coordinates//coordinates[@type=$adminDistrict])):\)
                                                                                    ) then () 
                                                                                    else
                                                                                <coordinates json:array="true" json:literal="false">[{ normalize-space($coord)}]</coordinates>, $newLine )
                                                                       )
                                                                       else (<coordinates json:array="true" json:literal="false">[{ normalize-space($coordinates//coordinates/text())}]</coordinates>)
                                                               else (<coordinates json:array="true" json:literal="false">[2, 2]</coordinates>)
                          :)                                                        
                           let $listOfCoordinates:= 
                                                        if (normalize-space($coordinates) = "")
                                                            then <coordinates json:array="true" json:literal="false">[0, 0]</coordinates>
                                                            else if($coordinates//coordinates[(normalize-space(.) !="") or (not(contains(./text(), "0, 0")))])
                                                                then 
                                                                    let $numberOfCoordinates := count($coordinates//coordinates)
                                                                    let $numberOfCoordinatesWith00 := count($coordinates//coordinates[./text() ="0, 0"])
                                                                    
                                                                    return
                                                                        if ($numberOfCoordinates >1) then
                                                                        (
                                                                                for $coord in $coordinates//coordinates[normalize-space(.) !=""][not(contains(./text(), "0, 0"))]
                                                                                
                                                                                return (
                                                                                    if (
                                                                                    (($coord/@type=$provinceTypeUris[1]) or ($coord/@type=$provinceTypeUris[2]) or ($coord/@type=$ousiaTypeUri))
                                                                                    and ($mainPlaceTypeUri != $adminDistrict)
                                                                                    (:and (exists($coordinates//coordinates[@type=$nomosTypeUri])
                                                                                            or
                                                                                            exists($coordinates//coordinates[@type=$adminDistrict])):)
                                                                                    ) then () 
                                                                                    else
                                                                                <coordinates json:array="true" json:literal="false">[{ normalize-space($coord)}]</coordinates>, $newLine )
                                                                       )
                                                                       else (<coordinates json:array="true" json:literal="false">[{ normalize-space($coordinates//coordinates/text())}]</coordinates>)
                                                               else (<coordinates json:array="true" json:literal="false">[2, 2]</coordinates>)
                                                                       
                          return
                            (
                            <features type="Feature">
                                                    <properties>
                                                        <name>{ $placeName }</name>
                                                        <altNames>{ $altNames }</altNames>
                                                        <uri>{ $uri }</uri>
                                                        <id>{ $id }</id>
                                                        <placeType>{ if ( $mainPlaceType = "MAN MADE MATERIAL") then "Please check type of place"
                                                            else $mainPlaceType }</placeType>
                                                        <placeTypeUri>{ if ( $mainPlaceType = "MAN MADE MATERIAL") then "Please check type of place"
                                                            else if ($mainPlaceTypeUri = "") then "no-uri" else 
                                                            data($mainPlaceTypeUri) }</placeTypeUri>
                                                        <provinceUri>{ $provinceUri }</provinceUri>
                                                        <provinceName>{ $provinceName }</provinceName>
                                                        <productionType>{ if($productionType//productionType) then string-join($productionType//productionType, ", ") else ()
                                                                                            }</productionType>
                                                        <productionTypeLink>{ if($productionType//productionTypeLink) then $productionType//productionTypeLink/node() else ()
                                                                                            }</productionTypeLink>
                                                        <exactMatch>{ $exactMatch }</exactMatch>
                                                        <isMadeOf>{ string-join($isMadeOf/@rdf:resource, " ") }</isMadeOf>
                                                        <coordinatesType>{ if($place//geo:long != "") then "assigned" else "calculated" }</coordinatesType>
                                                        <coordList number="{count($coordinates//coordinates)}">{ $listOfCoordinates }</coordList>
                                                        <icon>{ $marker }</icon>
                                                        <amenity></amenity>
                                                        <popupContent>
                                                        {""
                                                        (:"'<h5>'"  || $placeName || "'</h5>'"}
                                                       {if($mainPlaceType) then "<div>" || $mainPlaceType || "</div>" else ("no main type")} 
                                                       {'<span class="uri">' || $uri || '</span>'}
                                                       {if($productionType//productionType) then '<div class="margin-top: 5em;"><span>Types of production: </span>' || string-join($productionType, ', ') || '</div>'
                                                       else("")}
                                                       { if($isMadeOf) then
                                                       (
                                                            for $place in $isMadeOf/@rdf:resource
                                                                let $placeName :=$placeCollection//pleiades:Place[@rdf:about =$place][1]//dcterms:title[1]/text()
                                                                
                                                             return
                                                             "<li>*" || $placeName   || "</li>" 
                                                              
                                                        
                                                       )
                                                       else():)
                                                       }</popupContent>
                                                     </properties>
                                                     <style>
                                                         <fill>red</fill>
                                                         <fill-opacity>1</fill-opacity>
                                                      </style>
                                                      <geometry>
                                                        <type>MultiPoint</type>
                                                        { $listOfCoordinates }
                                                         {""
                                                         (:if (normalize-space($coordinates) = "")
                                                            then <coordinates json:array="true" json:literal="false">[0, 0]</coordinates>
                                                            
                                                            else if($coordinates//coordinates[(normalize-space(.) !="") or (not(contains(./text(), "0, 0")))])
                                                                then 
                                                                    let $numberOfCoordinates := count($coordinates//coordinates)
                                                                    let $numberOfCoordinatesWith00 := count($coordinates//coordinates[./text() ="0, 0"])
                                                                    
                                                                    return
                                                                        if ($numberOfCoordinates >1) then
                                                                            if($coordinates//coordinates[./@type != $provinceTypeUri])
                                                                                    then (
                                                                                            for $coord at $pos in distinct-values(
                                                                                                $coordinates//coordinates[normalize-space(.) !=""]
                                                                                                                                              [not(contains(./text(), "0, 0"))]
(\:                                                                                                                                              [not((./@type=$provinceTypeUri) or(./@type=$ousiaTypeUri))]:\)
                                                                                                )
                                                                                            where $pos <2
                                                                                            return (
                                                                                                if ($coordinates//coordinates[$pos][@type=$nomosTypeUri]) then () 
                                                                                                else
                                                                                            <coordinates json:array="true" json:literal="false">[{ normalize-space($coord)}]</coordinates>, $newLine )
                                                                                        )
                                                                                   else(
                                                                                   for $coord at $pos in $coordinates//coordinates
                                                                                    where $pos = 1
                                                                                        return <coordinates json:array="true" json:literal="false">[{ normalize-space($coord)}]</coordinates>, $newLine 
                                                                                   )
                                                                       else (<coordinates json:array="true" json:literal="false">[{ normalize-space($coordinates//coordinates/text())}]</coordinates>)
                                                               else (<coordinates json:array="true" json:literal="false">[2, 2]</coordinates>)
                                                         :)   }
                                                    </geometry>
                                               </features>,
                                                                                    $newLine)
                                               
                          let $endTime := util:system-time()      
                          let $duration := $endTime - $startTime
                          let $seconds := $duration div xs:dayTimeDuration("PT1S")
                    
                    let $placesGazetteer :=
                    <places xmlns:json="http://www.json.org" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
                        <last-update>{  $now }</last-update>
                        <generated-in>{ $seconds }</generated-in>
                        <count>{ count($placeCollection//spatial:Feature) }</count>
                        <user>{ $currentUser }</user>
                            <root json:array="true" type="FeatureCollection">
                            { $features }
                                       </root>
                                 </places>
                    
                    
                    
                    
                    
                    
                    
                    let $updateGazetteer := ( 
                    update replace doc("/db/apps/" || $project || "Data/places/project-places-gazetteer.xml")//places with $placesGazetteer,
                    util:log("INFO", "Places gazetteer of project " || $project || " updated after a place record had been updated.")
                    )
                    return
                    $placesGazetteer
else ()