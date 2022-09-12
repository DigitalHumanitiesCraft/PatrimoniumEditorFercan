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
let $documents := collection("/db/apps/patrimoniumData/documents/")
let $places := collection("/db/apps/patrimoniumData/places/patrimonium/")
let $docsYanne := collection("/db/apps/patrimoniumData/egyptianMaterial/docs/")


let $missingDocs :=  
    <docs>
        {for $item at $pos in tokenize(replace($docList, '"', ''), "\r")
        where $pos >600
            and $pos <= 700
        let $tmNo := normalize-space($item)
        let $tmUri := "https://www.trismegistos.org/text/" || $tmNo
        let $apcId := $documents//tei:TEI[.//tei:idno[@subtype="tm"]/text() = $tmUri]/@xml:id
        let $docYanne := $docsYanne//file[@text=$tmUri]
        let $provenanceTMUri := $docYanne/@provenance/string()
        let $apcPlace := $places//spatial:Feature[.//skos:exactMatch[@rdf:resource=$provenanceTMUri]]
        let $ousiaPlot := normalize-space($ousiaPlotsXml//ousiaPlot[@tmText=$tmNo][1]/@ousiaPlot)
        let $ousiaTMId := $ousiaRef2ousiaXml//ousia[@refId = $ousiaPlot]/@ousiaId/string()
        let $apcOusia := $places//spatial:Feature[.//skos:exactMatch[@rdf:resource = "https://www.trismegistos.org/ousia/"|| $ousiaTMId[1]]]/@rdf:about/string()

        order by $docYanne
        return 
            <doc tmUri="{ $tmUri }" apcId="{ $apcId }" fileYanne="{ if(exists($docYanne//text)) then "YES" else "NO"}">
            {if(exists($docYanne//text)) then
                <data>
                    <title>{ $docYanne/@description/string() }</title>
                    <origDate notBefore-custom="{ $docYanne/@notBefore/string() }" notAfter-custom="{ $docYanne/@notAfter/string() }"/>
                    <provenance tm="{ $provenanceTMUri}" apcPlace="{ $apcPlace//pleiades:Place/@rdf:about }">{ $apcPlace//dcterms:title/string()}</provenance>
                    <ousia apc="{$apcOusia}" tmId="{ $ousiaTMId }" tm="https://www.trismegistos.org/ousia/{ $ousiaTMId }" />
                </data>
                else()
            }
            </doc>
        }</docs>
    return 
        
        <missingDocs allNo="{count($missingDocs//doc[@apcId = ""])}"
        existingYanneDoc="{count($missingDocs//doc[@apcId = ""][@fileYanne = "YES"])}" noYanneDoc="{count($missingDocs//doc[@apcId = ""][@fileYanne = "NO"])}">
            { $missingDocs//doc[@apcId = ""]}
        </missingDocs>