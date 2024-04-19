xquery version "3.1";

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

let $tmPlaces := collection('xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/cleaning-ousia/places')
let $ousiaTableRaw := util:binary-to-string(util:binary-doc('xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/cleaning-ousia/ousiaiPlots_to_ousiaID.csv'))
let $ousiaTable := tokenize(replace($ousiaTableRaw, '"', ''), '\r\n')
let $ousiaList := doc('xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/cleaning-ousia/ousiaList.xml')

return 
    <plots>
        {
    for $plot in $ousiaTable[position() > 1]
        let $plotId := tokenize($plot, ',')[1]
        let $ousiaId := tokenize($plot, ',')[2]
        let $tmOusiaID := "https://www.trismegistos.org/ousiaTM/" || $ousiaId 
        let $apcOusiaUri := if($ousiaList//ousia[ousiaNo/text() = $ousiaId][1]//apcNo/text() != "")then $ousiaList//ousia[ousiaNo/text() = $ousiaId][1]//apcNo/text()
        else  substring-before($tmPlaces//spatial:Feature[skos:exactMatch[@rdf:resource = $tmOusiaID]]/@rdf:about, "#this")
        let $apcOuasiaUriLong := $apcOusiaUri|| "#this"
        let $ousiaPlace := $tmPlaces//spatial:Feature[@rdf:about = $apcOuasiaUriLong]
    return
        
        <plot ousiaIdRef="{ tokenize($plot, ',')[1]}" ousiaId="{ $ousiaId }"
        apcPlace="{ $apcOusiaUri }">
            <name>{ $ousiaPlace//dcterms:title/text()}</name>
            <ousiaTmNo>{ if(count($ousiaPlace//skos:exactMatch) > 1) then 
                    string-join($ousiaPlace//skos:exactMatch/@rdf:resource, " ")
                    else $ousiaPlace//skos:exactMatch/@rdf:resource}</ousiaTmNo>
        </plot>
        
        }
    </plots>