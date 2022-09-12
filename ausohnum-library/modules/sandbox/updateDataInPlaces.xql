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

let $ousiaPlotsCsv := util:binary-to-string(util:binary-doc("/db/apps/patrimoniumData/egyptianMaterial/places/ousia-plots.csv"))
let $ousiaPlotsXml :=  
    <ousiaPlots>
        {for $item in tokenize(replace($ousiaPlotsCsv, '"', ''), "\r")
        return <ousiaPlot ousiaPlot="{tokenize($item, ";")[1]}" tmText="{tokenize($item, ";")[2]}"/>
}</ousiaPlots>
let $ousiaRef2ousiaCsv := util:binary-to-string(util:binary-doc("/db/apps/patrimoniumData/egyptianMaterial/places/ousiaRef_to_ousia.csv"))
let $ousiaRef2ousiaXml :=  
    <ousia>
        {for $item in tokenize(replace($ousiaRef2ousiaCsv, '"', ''), "\r")
        return <ousia refId="{tokenize($item, ",")[1]}" ousiaId="{tokenize($item, ",")[2]}"/>
}</ousia>


let $docList := util:binary-to-string(util:binary-doc("/db/apps/patrimoniumData/egyptianMaterial/BordeauxCorpus.csv"))
let $documents := collection("/db/apps/patrimoniumData/documents/documents-ybroux/newDocs")
let $places := collection("/db/apps/patrimoniumData/places/patrimonium/")
let $docsYanne := collection("/db/apps/patrimoniumData/egyptianMaterial/docs/")

return
    <result>{
for $doc in $documents//tei:TEI
    let $tmUri := $doc//tei:idno[@subtype="tm"]/text()
    let $tmNo := substring-after($tmUri, "/text/")
    
    let $ousiaPlot := normalize-space($ousiaPlotsXml//ousiaPlot[@tmText = $tmNo][1]/@ousiaPlot/string())
    let $tmRefId := "https://www.trismegistos.org/ousiaRefId/" || $ousiaPlot[1]
    let $place := $places//spatial:Feature[.//skos:exactMatch
    [./@rdf:resource = $tmRefId]]
    
    let $UPDATE-listPlace := 
            if($place/@rdf:about != "") then
                let $node := <node>
                <place>
                    <placeName ref="{ $place//pleiades:Place/@rdf:about }" ana="mentionned-in-text">{
                        $place//dcterms:title/text()}</placeName>
                </place>
                </node>
                return
                    ($node
(:                    ,:)
(:                    update insert functx:change-element-ns-deep($node/node(), "http://www.tei-c.org/ns/1.0", "") into $doc//tei:listPlace:)
                    )
                else()
    return 
        
            <doc>{"" || $doc/@xml:id/string() || " [TM " || $tmNo ||"] == Place " ||$place/@rdf:about || " [ousiaRefId "||  $tmRefId ||"]"}
                { $UPDATE-listPlace }
            </doc>
 }   </result>    
    
    