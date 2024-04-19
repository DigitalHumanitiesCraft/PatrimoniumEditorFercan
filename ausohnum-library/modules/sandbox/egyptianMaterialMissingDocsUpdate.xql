xquery version "3.1";
import module namespace functx="http://www.functx.com";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace pleiades="https://pleiades.stoa.org/places/vocab#";
declare namespace owl="http://www.w3.org/2002/07/owl#";
declare namespace skos="http://www.w3.org/2004/02/skos/core#"; 
declare namespace geo="http://www.w3.org/2003/01/geo/wgs84_pos#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace dcterms="http://purl.org/dc/terms/";
declare namespace ausohnum="http://ausonius.huma-num.fr/onto";
declare namespace spatial="http://geovocab.org/spatial#";

declare boundary-space preserve;

let $tab := '&#9;' (: tab :)
let $nl := "&#10;"

let $missingRecordsCsv := util:binary-to-string(util:binary-doc("/db/apps/patrimoniumData/egyptianMaterial/docs/missingRecords.csv"))
let $missingRecordsXml :=  
    <records>
        {for $item at $pos in tokenize($missingRecordsCsv, "\r")
            where $pos > 1
            let $record :=tokenize($item, '","')
        return <record tmUri="{ replace($record[1], '"', '')}" 
        apcd="{ $record[2] }" publication="{ $record[3] }" texrelations="{ $record[4] }" provenance="{ $record[5] }"
        date="{ $record[6] }" type="{ replace($record[7], '"', '')}"/>}</records>


let $docList := util:binary-to-string(util:binary-doc("/db/apps/patrimoniumData/egyptianMaterial/BordeauxCorpus.csv"))
let $documents := collection("/db/apps/patrimoniumData/documents/documents-ybroux/newDocs")
let $places := collection("/db/apps/patrimoniumData/places/patrimonium/")
let $docsYanne := collection("/db/apps/patrimoniumData/egyptianMaterial/docs/")
let $processData :=
    for $record at $pos in $missingRecordsXml//record
(:        where $pos = 1:)
        let $docId := $record/@apcd
        let $apcdDoc := $documents/id($docId)
        let $docTitle := $apcdDoc//tei:titleStmt/tei:title/text()
        let $textRelationSource :=
            if(contains($record/@texrelations, "hgv")) then "papyriHGV"
            else if(contains($record/@texrelations, "ddbdp")) then "papyriDDbDP"
            else if(contains($record/@texrelations, "edcs")) then "edcs"
            else if(contains($record/@texrelations, "packhum")) then "phi"
            else if(contains($record/@texrelations, "berlpap")) then "berlpap"
            else "ERROR: " || $record/@texrelations
        let $provenance :=
            if(matches($record/@provenance, "Karanis"))
                then ("Karanis", "https://patrimonium.huma-num.fr/places/54003")
            else if(matches($record/@provenance, "Psenharpsenesis"))
                then ("Psenharpsenesis", "https://patrimonium.huma-num.fr/places/54057")
            else if(matches($record/@provenance, "Soknopaiou Nesos"))
                then ("Soknopaiou Nesos", "https://patrimonium.huma-num.fr/places/54004")
            else if(matches($record/@provenance, "Arsinoites \(Fayum\) \[found"))
                then ("Arsinoites", "https://patrimonium.huma-num.fr/places/54001")
            else if(matches($record/@provenance, "Philadelpheia \(Gharabet el-Gerza\) \[found"))
                then ("Philadelpheia", "https://patrimonium.huma-num.fr/places/54008")
(:            else if(matches($record/@provenance, "Philadelpheia \(Gharabet el-Gerza\) \(\?\) \[found")):)
(:                then ("Philadelpheia", "https://patrimonium.huma-num.fr/places/54008")    :)
            else if(matches($record/@provenance, "Theadelpheia \(Batn el-Harit\) \[found"))
                then ("Theadelpheia", "https://patrimonium.huma-num.fr/places/54010")
            else if(matches($record/@provenance, "Hermopolis \(El\-Ashmunein\) \[found"))
                then ("Hermopolis", "https://patrimonium.huma-num.fr/places/54422")
            
            else if(matches($record/@provenance, "Boubastos"))
                then ("Boubastos", "https://patrimonium.huma-num.fr/places/54868")
            else if(matches($record/@provenance, "Oxyrynchos \(Bahnasa\) \[found"))
                then ("Oxyrynchos", "https://patrimonium.huma-num.fr/places/58")
            else ("Error: " || $record/@provenance/string(), "error")
        let $tmProv := if($provenance[2] != "error") then
                    string-join($places//spatial:Feature[@rdf:about = ($provenance[2] ||"#this")]//skos:exactMatch/@rdf:resource, " ") else
            ()
        let $node:= 
    <node>
                        <altIdentifier>
                            <idno type="uri" subtype="{ $textRelationSource }">{ $record/@texrelations/string() }</idno>
                        </altIdentifier></node>
        let $nodePlace:= 
    <node>
                        <place>
                            <placeName ref="{ $provenance[2] || " " || $tmProv }" ana="provenance">{ $provenance[1] }</placeName>
                        </place></node>
    return
(:            if($apcdDoc//tei:provenance[@type="findspot"][.//@ref=""]) then:)
            ( 
                $docId || $tab || $textRelationSource || $tab || $record/@texrelations || $nl
(:        update value $apcdDoc//tei:origDate/text() with $record/@date/string(),:)
(:        update insert functx:change-element-ns-deep($node/node(), "http://www.tei-c.org/ns/1.0", "") following $apcdDoc//tei:altIdentifier,:)
(:        $docTitle with functx:capitalize-first($docTitle),:)
(:                if($provenance[1] = "") then $docId || "nothing changed for provenance " || $record/@provenance || $nl:)
(:                else :)
(:                    update value $apcdDoc//tei:location/tei:placeName/@ref with $provenance[2] || " " || $tmProv,:)
(:                    update value $apcdDoc//tei:location/tei:placeName with $provenance[1],:)
(:        update insert functx:change-element-ns-deep($nodePlace/node(), "http://www.tei-c.org/ns/1.0", "") into $apcdDoc//tei:listPlace,:)
(:                    $docId || $tab || $provenance[1]|| $tab || $provenance[2] || " tm:" || $tmProv || $nl:)
 (:        $docId || " - former date: " || $apcdDoc//tei:origDate/text() || " replaced with: " || $record/@date/string()  || $nl:)
(: $docId || " - title changed to " || functx:capitalize-first($docTitle) || $nl :)
            )
(:            else ($docId || $tab || "has already a provenance: " || $apcdDoc//provenance[@type="findspot"]/@ref/string() || $nl):)
        
    return
        <result>
    { $processData }
        </result>
    
    
    