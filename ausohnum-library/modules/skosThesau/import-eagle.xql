xquery version "3.1";

import module namespace config="http://ausonius.huma-num.fr/ausohnum-library/config" at "../config.xqm";
import module namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/" at "skosThesauApp.xql";
import module namespace functx="http://www.functx.com";

declare namespace dc="http://purl.org/dc/elements/1.1/";
declare namespace dct = "http://purl.org/dc/terms/";

declare namespace periodo="http://perio.do/#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
(:declare namespace skosThesau = "https://ausohnum.huma-num.fr/skosThesau/";:)
declare variable $thesaurus := "ausohnum";
declare variable $project :=request:get-parameter('project', 'ausohnum');
declare variable $dbName := doc('xmldb:exist:///db/apps/' || $project || '/data/app-general-parameters.xml')//idPrefix[@type='db']/text();
declare variable $baseUri := doc('xmldb:exist:///db/apps/' || $project || '/data/app-general-parameters.xml')//uriBase[@type="thesaurus"]/text();
declare variable $thesaurusPrefix := doc('xmldb:exist:///db/apps/' || $project || '/data/app-general-parameters.xml')//idPrefix[@type='thesaurus']/text();
declare variable $conceptPrefix := doc('xmldb:exist:///db/apps/' || $project || '/data/app-general-parameters.xml')//idPrefix[@type='concept']/text();
declare variable $conceptBaseUri := $baseUri || "/concept/";

declare variable $peopleRepo := collection("xmldb:exist:///db/data/" || $project || "/accounts");

let $mode := "existing"
let $rdfFilename := "objtyp.rdf"
let $thesaurusLabel := substring-before($rdfFilename, ".")

let $logs := collection("/db/apps/" || $thesaurus || "/logs")
let $now := fn:current-dateTime()
let $currentUser := sm:id()
let $personRecord := $peopleRepo/id($currentUser)
let $userName := $personRecord//firstname || ' ' || $personRecord//lastname

let  $conceptCollection := collection('xmldb:exist:///db/apps/' || $thesaurus || "Data/concepts")
let $conceptScheme := $conceptCollection//.[skos:ConceptScheme[@rdf:about="https://ausohnum.huma-num.fr/thesaurus/petrae/"]]

let $rdfInput := doc("/db/apps/" || $thesaurus || "Data/imports/" || $rdfFilename)

let $idList := for $id in $conceptCollection//.[contains(./@xml:id, $conceptPrefix)]
                return
                <item>
                { substring-after($id/@xml:id, $conceptPrefix) }
                </item>
        
            let $last-id:= fn:max($idList) 
            
            (:let $newId := $conceptPrefix || fn:sum(($last-id, 1)):)
            let $newId := $conceptPrefix || fn:sum(($last-id, 1))
             
             let $idTopConcept := $newId
             
return
    (
        
<rdf:RDF xmlns:dct="http://purl.org/dc/terms/" xmlns:periodo="http://perio.do/#"
    xmlns:skosThesau="https://ausohnum.huma-num.fr/skosThesau/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:time="http://www.w3.org/2006/time#"
    xmlns:map="http://www.w3c.rl.ac.uk/2003/11/21-skos-mapping#"
    xmlns:dc="http://purl.org/dc/elements/1.1/">


{ element {"skos:ConceptScheme"}
            {attribute {"rdf:about"} {$baseUri || '/' || $thesaurusPrefix 
            || '/' || "eagle-" || $thesaurusLabel || '/'},
            element {"dc:title"}
                    {attribute {"type"} {"full"},
                    $thesaurusLabel},
            element {"dc:title"}
                    {attribute {"type"} {"short"},
                    $thesaurusLabel},
            element {"skos:hasTopConcept"}
                    {attribute {"rdf:resource"} {$conceptBaseUri || $idTopConcept}},
            
        element {"dc:creator"} {$userName},
        element {"dc:publisher"} {"Ausonius Institute"},
        element {"dct:created"} {$now},
        element {"skosThesau:admin"}
                {attribute{"status"}{"draft"}} }
                
}
<skos:Concept xml:id="{ $conceptPrefix}{($last-id + 1)}" rdf:about="{ $conceptBaseUri || "/" ||$conceptPrefix}{($last-id + 1)}">
<skos:prefLabel xml:lang="en">Type of inscriptions</skos:prefLabel>
<skos:prefLabel xml:lang="fr">Nature de l'inscription</skos:prefLabel>
<skos:prefLabel xml:lang="de"></skos:prefLabel>
{
    
for $concept at $pos in $rdfInput//skos:Concept
            let $prefLabel1 := $concept//skos:prefLabel[1]
            let $prefLabel1Value := $prefLabel1/text()
            let $prefLabel1Lang := $prefLabel1/@xml:lang
            let $eagleUri := $concept/@rdf:about
            return
        <skos:narrower rdf:resource="{  $conceptBaseUri || "" ||$conceptPrefix}{($last-id + 1 + $pos)}"/>
}
<skos:inScheme rdf:resource="https://www.eagle-network.eu/voc/typeins/"/>
</skos:Concept>

{
    
for $concept at $pos in $rdfInput//skos:Concept
            let $prefLabel1 := $concept//skos:prefLabel[1]
            let $prefLabel1Value := $prefLabel1/text()
            let $prefLabel1Lang := $prefLabel1/@xml:lang
            let $eagleUri := $concept/@rdf:about
    

            
return
 (       <skos:Concept xml:id="{$conceptPrefix}{($last-id + 1 + $pos)}" 
    rdf:about="{ $conceptBaseUri || "" ||$conceptPrefix}{($last-id + 1 + $pos)}">
            {$concept//skos:prefLabel}
            {$concept//skos:altLabel}
        <skos:broader rdf:resource="{ $baseUri  || "" ||$conceptPrefix}{($last-id + 1)}"/>
        <skos:exactMatch>
        <skos:Concept rdf:resource="{data($concept/@rdf:about)}">
                <skos:prefLabel xml:lang="{ $prefLabel1Lang }">{ $prefLabel1Value}</skos:prefLabel>
                <skos:notation>{ data($concept/@rdf:about)}</skos:notation>
                <skos:inScheme rdf:resource="{data($concept//skos:inScheme/@rdf:resource)}"/>
            </skos:Concept>
        </skos:exactMatch>
         <skos:inScheme rdf:resource="{$baseUri || '/' || $thesaurusPrefix || '/eagle-' || $thesaurusLabel || '/'}"/>    
        <dct:created>{ $now }</dct:created>
        <dct:modified>{ $now }</dct:modified>
        </skos:Concept>

)
  
} 
</rdf:RDF>
)   