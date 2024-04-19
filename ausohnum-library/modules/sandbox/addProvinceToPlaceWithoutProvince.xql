xquery version "3.1";

import module namespace functx="http://www.functx.com";
declare namespace dcterms="http://purl.org/dc/terms/";
declare namespace foaf="http://xmlns.com/foaf/0.1/";
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
declare variable $places := collection("/db/apps/patrimoniumData/places/patrimonium");
declare variable $provinceTypeUris := "https://ausohnum.huma-num.fr/concept/c22264", "https://ausohnum.huma-num.fr/concept/c23737";
declare variable $romanProvinces := ($places//pleiades:Place[pleiades:hasFeatureType[@rdf:resource="https://ausohnum.huma-num.fr/concept/c22264"]]
   ,
     $places//pleiades:Place[pleiades:hasFeatureType[@rdf:resource="https://ausohnum.huma-num.fr/concept/c23737"]]
   );
let $provincesUri := $romanProvinces//@rdf:about

let $selectedPlaces := $places//spatial:Feature
[not(.//pleiades:hasFeatureType[@type="main"][functx:contains-any-of(./@rdf:resource,$provinceTypeUris)])]
[not(.//spatial:P[functx:contains-any-of(./@rdf:resource, ($provincesUri))])]
(:[.//pleiades:hasFeatureType[@type="main"][@rdf:resource="https://ausohnum.huma-num.fr/concept/c23587"]]:)
(:                        [.//geo:long=""]:)
(:                        [count(.//spatial:Pi) = 0]:)
(:                        [count(.//spatial:P) = 1]:)


let $tab := '&#9;' (: tab :)
let $nl := "&#10;"
return 
    <results xmlns:spatial="http://geovocab.org/spatial#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
    count="{count($selectedPlaces)}">{
        
        for $place at $pos in $selectedPlaces
(:        where $pos <10:)
        let $name := $place//dcterms:title/string()
        let $firstP := $place//spatial:P[1]/@rdf:resource/string()
        let $firstPUriLong := $firstP||"#this"
        let $firstPNode := $places//spatial:Feature[@rdf:about = $firstPUriLong]//spatial:P[functx:contains-any-of(./@rdf:resource, ($provincesUri))]/@rdf:resource/string()
        let $vicinityOf := $place//spatial:C[@type="isInVicinityOf"]
        let $vicinityOfNode := 
            $places//spatial:Feature[@rdf:about = $vicinityOf[1]/@rdf:resource ||"#this"]
            //spatial:P[functx:contains-any-of(./@rdf:resource, ($provincesUri))]/@rdf:resource/string()
        
        let $provinceUri :=
            if($firstPNode[1] != "") then $firstPNode[1]
                        else if($vicinityOfNode[1]!= "") then $vicinityOfNode[1]
                        else "ERROR"
        let $provinceNode := if($provinceUri != "ERROR") then $places//spatial:Feature[@rdf:about = $provinceUri || "#this"] else ()                        
        let $provinceIsProvince := functx:contains-any-of($provinceUri, ($provincesUri))
        let $noSpatialP := if (count($place//spatial:P) = 0) then "This place has no related place" 
            else if ((count($place//spatial:P)>0) and $provinceUri = "") then "None of the spatial:P is a province"
            else ()
(:        let $insertSpaptialP :=:)
(:            let $nodePlace:= :)
(:    <node><spatial:P rdf:resource="{ $provinceUri }"/>:)
(:        </node>:)
(:                return :)
(:                    if(contains($provinceUri, "http")):)
(:                    then :)
(:                        if ($place//spatial:P[@rdf:resource= $provinceUri]) then () else:)
(:                            update insert $nodePlace/node() preceding $place/foaf:primaryTopicOf:)
(:                    else ():)
(:        order by $place/@rdf:about:)
        return
            ( $pos || $tab ||
                (if(contains($provinceUri, "http")) then "OK" else "Error")
                || $tab
                || $name
                || " (" || $place/@rdf:about || ")"
                || $tab || (if($provinceUri = "ERROR") then $noSpatialP
                else if($provinceUri ="") then $noSpatialP
                    else "Province: " || $provinceNode//dcterms:title/text()
                     )
                || $tab || (if($provinceUri != "ERROR") then $provinceUri else " " )
                ||$tab || (if($provinceIsProvince = true()) then "Province OK" else" ")
(:                "FirstPNode: " || $firstPNode[1]:)
(:                || "vicinity: " || $vicinityOfNode[1]:)
(:                || $place//spatial:P[1]:)
(:                || $tab :)
                || "&#10;"
(:                ||:)
(:                substring-before($place/ancestor::spatial:Feature/@rdf:about/string(), "#this") || "&#10;":)
(:               <place id="{ $place/@rdf:about/string()}">{ $place//dcterms:title/string() }</place>:)
           
            
            )
    }</results>
    