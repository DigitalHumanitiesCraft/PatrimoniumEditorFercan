xquery version "3.1";

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

let $apcPlaces := (doc('xmldb:exist:///db/apps/patrimoniumData/places/patrimonium/imports/egyptianMaterialPlaces.xml')
(:,:)
(:doc('xmldb:exist:///db/apps/patrimoniumData/places/patrimonium/imports/missingOusiai.xml')):)
)
let $tmDump := doc('xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/geo/tmEgyptianPlaces.xml')
let $nomeCodes := <nomeCodes>
    <nomeCode code="0" tm="332" apc="54001" />
<nomeCode code="00?" tm="332" apc="54001" cert="low" />
<nomeCode code="00a" tm="1008" apc="54003" />
<nomeCode code="00a?" tm="1008" apc="54003" cert="low" />
<nomeCode code="00b" tm="2366" apc="54030" />
<nomeCode code="00c" tm="1882" apc="54031" />
<nomeCode code="00d" tm="327" apc="54054" />
<nomeCode code="Arabia" tm="282" apc="54473" />
<nomeCode code="L" tm="4819" apc="54184" />
<nomeCode code="L00" tm="100" apc="16" />
<nomeCode code="L00?" tm="100" apc="16" cert="low" />
<nomeCode code="L01" tm="2714" apc="55389" />
<nomeCode code="L01?" tm="2714" apc="55389" cert="low" />
<nomeCode code="L02" tm="3079" apc="54479" />
<nomeCode code="L03" tm="817" apc="54448" />
<nomeCode code="L03?" tm="3108" apc="54477" />
<nomeCode code="L05" tm="11566" apc="54475" />
<nomeCode code="L06?" tm="7865" apc="54480" cert="low" />
<nomeCode code="L07" tm="3085" apc="54445" />
<nomeCode code="L07?" tm="3085" apc="54445" />
<nomeCode code="L08" tm="11907" apc="56485" />
<nomeCode code="L08?" tm="11907" apc="56485" cert="low" />
<nomeCode code="L11" tm="3087" apc="54877" />
<nomeCode code="L12" tm="8569" apc="54508" />
<nomeCode code="L13" tm="3088" apc="54478" />
<nomeCode code="L16" tm="3090" apc="54674" />
<nomeCode code="L16?" tm="3090" apc="54674" cert="low" />
<nomeCode code="L18" tm="11742" apc="54474" />
<nomeCode code="L18?" tm="11742" apc="54474" cert="low" />
<nomeCode code="L19" tm="2957" apc="54502" />
<nomeCode code="L20" tm="282" apc="54473" />
<nomeCode code="L21" tm="11814" apc="54187" />
<nomeCode code="U" tm="2982" apc="54183" />
<nomeCode code="U01" tm="13441" apc="56486" />
<nomeCode code="U04a" tm="2849" apc="56487" />
<nomeCode code="U07" tm="2998" apc="54253" />
<nomeCode code="U08" tm="2999" apc="56488" />
<nomeCode code="U09" tm="2719" apc="54575" />
<nomeCode code="U10a" tm="3020" apc="54382" />
<nomeCode code="U10b" tm="3017" apc="54436" />
<nomeCode code="U13" tm="3027" apc="54854" />
<nomeCode code="U15" tm="2720" apc="54362" />
<nomeCode code="U15?" tm="2720" apc="54362" cert="low" />
<nomeCode code="U17" tm="3032" apc="54036" />
<nomeCode code="U19" tm="2722" apc="54106" />
<nomeCode code="U19?" tm="2722" apc="54106" cert="low" />
<nomeCode code="U20" tm="2713" apc="54035" />
<nomeCode code="U20?" tm="2713" apc="54035" cert="low" />
<nomeCode code="Western desert, Oasis Magna" tm="619" apc="54262" />
</nomeCodes>
return
    <results totalPlaces="{ count($apcPlaces//spatial:Feature)}">
        {
    for $place at $pos in $apcPlaces//spatial:Feature
(:        where $pos < 10:)
        let $apcUriLong := data($place/@rdf:about)
        let $tmId := substring-after(data($place//skos:exactMatch[contains(./@rdf:resource, "trismeg")][1]/@rdf:resource), "place/")
        let $nomeCode := data($tmDump//place[@tm = $tmId]/@nomeCode)
        let $node2Insert := <data>
            <spatial:P rdf:resource="https://patrimonium.huma-num.fr/places/{data($nomeCodes//nomeCode[@code=$nomeCode]/@apc)}"/></data>
        let $insertNode := if( ($nomeCodes//nomeCode[@tm = $tmId]) or not($nomeCodes//nomeCode[@code = $nomeCode])) then ()
            else update insert $node2Insert/node() following $place//spatial:P[last()]
        let $reverseNode := <data>
            <spatial:Pi rdf:resource="{ substring-before($apcUriLong, '#this')}"/></data>
        let $nomeUriLong := "https://patrimonium.huma-num.fr/places/" || data($nomeCodes//nomeCode[@code=$nomeCode]/@apc) || "#this"
        let $insertReverse :=if( ($nomeCodes//nomeCode[@tm = $tmId]) or not($nomeCodes//nomeCode[@code = $nomeCode])) then () else
                if($apcPlaces//spatial:Feature[@rdf:about = $nomeUriLong]//spatial:Pi) then
                update insert $reverseNode/node() following $apcPlaces//spatial:Feature[@rdf:about = $nomeUriLong]//spatial:Pi[last()]
                else update  insert $reverseNode/node() following $apcPlaces//spatial:Feature[@rdf:about = $nomeUriLong]//spatial:P[last()]
        return
(:            $nomeCode || "     " || $apcUriLong || '&#xa;':)
        <data>{if( ($nomeCodes//nomeCode[@tm = $tmId]) or not($nomeCodes//nomeCode[@code = $nomeCode])) then "Not processed" else "Processed"  }
            <place apc="{$apcUriLong}" tm="{ $tmId }" nomeCode="{ $nomeCode }"/>
            <inPlace>{ $node2Insert/node() }</inPlace>
            <reverse>{$nomeUriLong}{ $reverseNode/node() }</reverse>
        </data>
        }
        
    </results>