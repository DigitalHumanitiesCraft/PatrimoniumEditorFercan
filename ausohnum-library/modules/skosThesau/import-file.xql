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

declare variable $peopleRepo := collection("xmldb:exist:///db/data/" || $project || "Data/accounts");
(:let $logs := collection("db/apps/" || $thesaurus || "Data/logs"):)
let $now := fn:current-dateTime()
let $currentUser := "vrazanajao"
let $personRecord := $peopleRepo/id($currentUser)
let $userName := $personRecord//firstname || ' ' || $personRecord//lastname
let $importCollectionPath := "xmldb:exist:///db/apps/ausohnumData/imports/"
let $importFilename := "fiscus.txt"
let $fileContent := unparsed-text($importCollectionPath || $importFilename)

let $destinationSchemeUri := "https://ausohnum.huma-num.fr/thesaurus/fiscus/"
let $topConceptInDestSchemeUri := "https://ausohnum.huma-num.fr/concept/c25658"
let  $conceptCollection := collection('xmldb:exist:///db/apps/' || $thesaurus || "Data/concepts")


let $csv-input-sample :=
""
let $lines := tokenize($fileContent, '\n')
let $header := $lines[1]
let $entryHeaders := tokenize($header, '\|')
let $nl := "&#10;"
let $space := "&#032;"
let $tab   := "&#009;"
let $tab2 :="\t"
let $tab3 := "    "
(:let $tab := $tab2:)
let $pipe := "|"



let $separator := $pipe

let $idList := for $id in $conceptCollection//.[contains(./@xml:id, $conceptPrefix)]
        let $int := data(substring-after($id/@xml:id, $conceptPrefix))
        order by number($int) ascending
        return
        <item>
        { $int }
        </item>

        
let $last-id:= 
(:fn:max($idList) :)
  data($idList[last()])

(:let $newId := $conceptPrefix || fn:sum(($last-id, 1)):)
let $newId := $conceptPrefix || fn:sum(($last-id, 1))
let $thesaurusLabel:= 
    lower-case(tokenize(tokenize($lines[2]), '\|')[2])
let $thesaurusTile := "Thesaurus " || functx:capitalize-first($thesaurusLabel)
 let $idTopConcept := $newId

let $newContent :=
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
            {attribute {"rdf:about"} {$baseUri || '/' || $thesaurusPrefix || '/' || $thesaurusLabel || '/'},
            element {"dc:title"}
                    {attribute {"type"} {"full"},
                    $thesaurusTile},
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
{

  for $line at $pos in $lines
            where $pos > 1
    let $indent := string-length(functx:substring-before-last($line, "    "))
    let $entries := tokenize($line, "\|")
    let $level := string-length($entries[1])
    let $text := functx:substring-after-last($line, $tab)
    let $id := $conceptPrefix ||sum(($last-id, number($pos), -1))
    let $fields := tokenize($text, "\|")
  
    let $previousNodesReverse := reverse(subsequence($lines, 1, $pos))
    let $previousLines := 
        <list>
            {for $previousLine at $revPos in $previousNodesReverse
                where $revPos > 1
(:            let $previousIndent := string-length(functx:substring-before-last($previousLine, $tab)):)
            let $prevEntries := tokenize($previousLine, '\|')
            let $prevLevel :=  string-length($prevEntries[1])
            let $idParent := $conceptPrefix || ($last-id + $pos - $revPos)
            return
                <node><level>{ if ($prevLevel < $level) then $prevLevel else ($level) }</level><reversePos>{ $revPos }</reversePos><parent ref="{$idParent}">{ $prevEntries[2]}</parent></node>
                }
            </list>
    
    let $parent := $previousLines//node[level < $level][1]
        let $parents := for $broader in $parent
                where $pos >2
            return
                element {"skos:broader"}
                {attribute{"rdf:resource"}{data($conceptBaseUri || $broader//parent/@ref)}}
    
    
    
    let $followingSeq := subsequence($lines, $pos+1)
    let $followingLines :=
            <list>
                {for $followingLine at $followingPos in $followingSeq
                
                let $followingEntries := tokenize($followingLine, '\|')   
                let $followingLevel :=  string-length($followingEntries[1])   
                let $idChild := $conceptPrefix || ($pos + $followingPos)
                
                return 
                  <child level="{ if($followingLevel) then  $followingLevel else 4 }" ref="{$idChild}" label="{$followingEntries[2]}"/>
            }
                </list>
    let $previousLevel := number($level - 4)
    let $firstSameLevelNode :=if($followingLines//child[@level = number($level)]) then
            (

                functx:index-of-node($followingLines/child, $followingLines/child[@level = number($level)][1])
                )
            else (count($lines))
     let $followingSeq4Children := subsequence($lines, $pos+1, $firstSameLevelNode )

    
    let $childrenNodes :=
            <list>
                {for $followingLine2 at $followingPos2 in $followingSeq4Children
                
                let $followingEntries2 := tokenize($followingLine2, '\|')   
                let $followingLevel2 :=  string-length($followingEntries2[1])   
                let $idChild2 := $conceptBaseUri  || $conceptPrefix || ($last-id + $pos + $followingPos2 -1)
                
                return 
                    
                    <child level="{ if($followingLevel2) then  $followingLevel2 else 0}">
                    <level>{ data(if($followingLevel2) then  $followingLevel2 else "Same")}</level>
                    <skos:narrower rdf:resource="{$idChild2}"/></child>
            }
                </list>
    
    
    
    let $children := $childrenNodes//.[@level = data($level+1)]//skos:narrower
    
    (:let $parent := 
            for $nodes in $previousNodesReverse
            where 
      :)      
  
  return
        
  element {"skos:Concept"}
  {attribute {"xml:id"} {$id},
   attribute {"rdf:about"} {$conceptBaseUri || $id},
(:   attribute {"indent"} {$level},:)
        for $field at $posInFields in $fields
        where $posInFields > 1 and  $posInFields < 5
        return
            if($field) then
            <skos:prefLabel xml:lang="{normalize-space(data($entryHeaders[$posInFields]))}">{normalize-space($field)}</skos:prefLabel>
            else (),
            $parents,
            $children,
            
        element {"skos:inScheme"} 
            {attribute {"rdf:resource"} {$baseUri || '/' || $thesaurusPrefix || '/' || $thesaurusLabel || '/'}},
        element {"dct:created"} {$now},
        element {"skosThesau:admin"}
                {attribute{"status"}{"draft"}}
(:                ,:)
(:                "level: ", $level,:)
(:                "previouslevel: ", $previousLevel,:)
(:                "$firstSameLevelNode: ", $firstSameLevelNode,:)
(:                $followingLines,:)
(:                $followingSeq4Children,:)
(:                $childrenNodes:)
  }
}
   
</rdf:RDF>

return 
(:    $last-id:)
    $newContent