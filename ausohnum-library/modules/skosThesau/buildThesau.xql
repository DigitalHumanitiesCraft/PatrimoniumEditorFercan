(:~
: AusoHNum Library - thesaurus module
: This function builds the hierachical tree of concepts as JSon, by processing the concepts and their relations). 
: @author Vincent Razanajao
: @param name of the project
: @return This function updates the thesaurus XML tree stored in the Thesaurus App > /thesaurus/thesaurus-as-tree.xml, and return a simple phrase stipulating this.
:)

xquery version "3.1";

import module namespace functx="http://www.functx.com";
import module namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/" at "./skosThesauApp.xql";

declare boundary-space preserve;

declare namespace apc="http://patrimonium.huma-num.fr/onto#";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace dct = "http://purl.org/dc/terms/";
declare namespace ev = "http://www.w3.org/2001/xml-events";
declare namespace json="http://www.json.org";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace periodo="http://perio.do/#";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace thot = "http://thot.philo.ulg.ac.be/";
declare namespace time="http://www.w3.org/2006/time#";
declare namespace xf = "http://www.w3.org/2002/xforms";

declare option output:indent "yes";
(: Switch to JSON serialization :)


declare variable $project :=request:get-parameter('project', ());
declare variable $authorized-groups :=request:get-parameter('authorized-groups', ());
declare variable $appParam := doc('/db/apps/' || $skosThesau:project || '/data/app-general-parameters.xml');
declare variable $thesaurus-app := $skosThesau:appParam//thesaurus-app/text();
declare variable $concept-collection := collection('/db/apps/' || $thesaurus-app || 'Data/concepts');
declare variable $concepts-tree := doc('/db/apps/' || $thesaurus-app || 'Data/thesaurus/thesaurus-as-tree.xml');
declare variable $lang := request:get-parameter('lang', ());
declare variable $dataFormat := request:get-parameter('dataFormat', ());
declare variable $langList := string-join($appParam//languages//lang/text(), " "); 

declare option output:method "xml";
declare option output:media-type "text/xml";

declare function local:buildTree($topConcepts as node()*, $lang as xs:string){
(:            let $children :=xmldb:get-child-collections($rootNodes):)
let $rootNodes :=
    for $uri in $topConcepts
        return
            $concept-collection/id(substring-after($uri, "/concept/"))



                let $collation :=  '?lang=' || lower-case($lang) || "-" || $lang
       for $child in $topConcepts
                let $concept := $concept-collection/id(substring-after($child/@rdf:resource, "/concept/"))

                let $nts := $concept//skos:narrower
                let $nonDescriptorStart := 
                        if ($concept/name() ='skos:Collection') then (concat('&#65308;', ' ')) else('')
                let $nonDescriptorEnd := 
                        if ($concept/name() ='skos:Collection') then (concat(' ', '&#65310;')) else('')
                 
                 let $title := $nonDescriptorStart || 
                            (if($concept/skos:prefLabel[@xml:lang=$lang][1]/text()) then
                            functx:capitalize-first($concept/skos:prefLabel[@xml:lang=$lang][1]/text()) 
                            else ( functx:capitalize-first($concept/skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][1]/text()) 
                                      || " ("  || data($concept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][1]/@xml:lang) || ")"
                            ))
                            || $nonDescriptorEnd
                            
   let $xmlValue := $concept/skos:prefLabel[@xml:lang='xml'][1]/text()
   
                (:let $title :=
                    for $prefLabel in $concept//skos:prefLabel
                        return
                        if (count( tokenize($prefLabel/@xml:lang, " ")) = 1 ) then 
                            element{ $prefLabel/@xml:lang }{ $nonDescriptorStart || functx:capitalize-first($prefLabel/text()) || $nonDescriptorEnd}
                        else (
                            for $lang in tokenize($prefLabel/@xml:lang, " ") return 
                            element{ $lang }{ $nonDescriptorStart || functx:capitalize-first($prefLabel/text()) || $nonDescriptorEnd}
                        ):)

(:                let $title :=if($concept/skos:prefLabel[@xml:lang=$lang][1]/text()) then
                            functx:capitalize-first($concept/skos:prefLabel[@xml:lang=$lang][1]/text())
                        else if ($concept/skos:prefLabel[@xml:lang="en"]/text()) then
                            (functx:capitalize-first($concept/skos:prefLabel[@xml:lang='en'][1]/text()))
                        else if ($concept/skos:prefLabel[@xml:lang='fr']/text())
                        then (functx:capitalize-first($concept/skos:prefLabel[@xml:lang='fr'][1]/text()))
                        else("no label"):)
                let $id := data($concept/@xml:id)
                let $uri := data($concept/@rdf:about)
                let $type := $concept/@type
                let $order :=$type
                (:order by
                      lower-case($child/skos:prefLabel[@xml:lang=$lang]/text()) collation "?lang=fr-FR"
:)
              return
              (
                
              <children json:array="true" status="{ $child/@status }" type="collectionItem"
                groups="{ data($child/@groups) }">
                 <title>{ $title}</title>
                 <id>{ $id }</id>
                 <uri>{ $uri }</uri>
                 <key>{ $id }</key>
                 <xmlValue>{ $xmlValue }</xmlValue>
                 <lang>{$lang}</lang>
                 <isFolder>true</isFolder>{ 
                 local:nodes($nts, (), $type, $lang)
                 }</children>
                )
};


declare function local:nodes($nodes, $visited as node()*, $renderingOrder as xs:string?, $lang as xs:string?){
  
  (:let $draftConcepts := for $concepts in $nodes//skos:Concept[skosThesau:admin[@status='draft']],
                              $collections in $nodes//skos:Collection[skosThesau:admin[@status='draft']]
                              return  ($concepts)
:)
(:            return:)

            for $childnode in $nodes except ($visited)
                let $id := substring-after($childnode/@rdf:resource, "/concept/")
                let $ntSkosConcept :=
                    $concept-collection/id($id)
                let $nonDescriptorStart := 
                        if ($ntSkosConcept/name() ='skos:Collection') then (concat('&#65308;', ' ')) else('')
                let $nonDescriptorEnd := 
                        if ($ntSkosConcept/name() ='skos:Collection') then (concat(' ', '&#65310;')) else('')
                let $title := $nonDescriptorStart || 
                            (if($ntSkosConcept/skos:prefLabel[@xml:lang=$lang][1]/text()) then
                            functx:capitalize-first($ntSkosConcept/skos:prefLabel[@xml:lang=$lang][1]/text())
                            else ( functx:capitalize-first($ntSkosConcept/skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][1]/text()) 
                                        || " (" || data($ntSkosConcept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][1]/@xml:lang) || ")"
                            ))
                            || $nonDescriptorEnd        
               let $xmlValue := $ntSkosConcept/skos:prefLabel[@xml:lang='xml'][1]/text()
                (:let $title :=
                    for $prefLabel in $ntSkosConcept//skos:prefLabel
                        return
                        if (count( tokenize($prefLabel/@xml:lang, " ")) = 1 ) then 
                            element{ $prefLabel/@xml:lang }{ $nonDescriptorStart || functx:capitalize-first($prefLabel/text()) || $nonDescriptorEnd}
                        else (
                            for $lang in tokenize($prefLabel/@xml:lang, " ") return 
                            element{ $lang }{ $nonDescriptorStart || functx:capitalize-first($prefLabel/text()) || $nonDescriptorEnd}
                        ):)
                 (:try {
                    if(exists($ntSkosConcept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang=$lang])) then
                                ( functx:capitalize-first($ntSkosConcept/skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang=$lang][1]/text())
                                )


                                else if (exists($ntSkosConcept/skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang='en']/text())) then
                                (
                                    functx:capitalize-first($ntSkosConcept/skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang='en'][1]/text()) || ' (en)'
                                )
                                else if  (exists($ntSkosConcept/skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang='fr']/text())) then
                                    (functx:capitalize-first($ntSkosConcept/skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang='fr'][1]/text()) || ' (fr)')
                                else if  (exists($ntSkosConcept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)]/text())) then
                                    ($ntSkosConcept[1]//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][1]/text() || ' (' || data($ntSkosConcept/skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][1]/@xml:lang), ')' )
                          



                                else ("No label -")
                }
                catch * {"error in retrieving label"}:)
                
                let $uri := data($ntSkosConcept/@rdf:about)
                let $status := if(data($ntSkosConcept//@status) != "") then data($ntSkosConcept//@status) else "draft"
               let $order := $ntSkosConcept/@type

                order by
                    if ($renderingOrder = "ordered") then reverse($childnode)
                    else $title[1]
                   (:else (lower-case(if(exists($ntSkosConcept//skos:prefLabel[@xml:lang=$lang][not(ancestor-or-self::skos:exactMatch)]/text())) then
                           translate($ntSkosConcept//skos:prefLabel[@xml:lang=$lang][1][not(ancestor-or-self::skos:exactMatch)]/text(),'Â, Ê, É','A, E, E')
                            else if(exists($ntSkosConcept//skos:prefLabel[@xml:lang="en"][not(ancestor-or-self::skos:exactMatch)]/text())) then
                            translate($ntSkosConcept//skos:prefLabel[@xml:lang="en"][1][not(ancestor-or-self::skos:exactMatch)]/text(),'Â, Ê, É','A, E, E')
                            else if(exists($ntSkosConcept//skos:prefLabel[@xml:lang="fr"][not(ancestor-or-self::skos:exactMatch)]/text())) then
                            translate($ntSkosConcept//skos:prefLabel[@xml:lang="fr"][1][not(ancestor-or-self::skos:exactMatch)]/text(),'Â, Ê, É','A, E, E')
                            else if(exists($ntSkosConcept//skos:prefLabel[@xml:lang="de"][not(ancestor-or-self::skos:exactMatch)]/text())) then
                            translate($ntSkosConcept//skos:prefLabel[@xml:lang="de"][1][not(ancestor-or-self::skos:exactMatch)]/text(),'Â, Ê, É','A, E, E')
                            else if(exists($ntSkosConcept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)]/text())) then
                            translate($ntSkosConcept//skos:prefLabel[1][not(ancestor-or-self::skos:exactMatch)]/text(),'Â, Ê, É','A, E, E')
                            else if (exists($ntSkosConcept//skos:altLabel/text()))
                            then (translate($ntSkosConcept//skos:altLabel[1]/text(),'Â, Ê, É','A, E, E'))
                            else ("Error")
                    )):)
                    
                    
                     (:
                     if($renderingOrder ="ordered") then order by reverse($childnodes)
                     else order by $ntSkosConcept/skos:prefLabel[@xml:lang=$lang]:)
            return

                if ($ntSkosConcept//skos:narrower)
                  then(
                       <children json:array="true" status="{ $status }" type="collectionItem">
                                <title>{ $title }</title>
                                <id>{ $id }</id>
                                <uri>{ $uri }</uri>
                                <key>{ $id }</key>
                                <xmlValue>{ $xmlValue }</xmlValue>
                                <lang>{$lang}</lang>
                                <isFolder>true</isFolder>
                                { local:nodes($ntSkosConcept//skos:narrower, ($visited, $childnode), $ntSkosConcept/@type, $lang)
                                        }
                        </children>
                    )
                    else
                    (
                    <children json:array="false" status="{ $status }" type="collectionItem">
                        <title>{ $title }</title>
                        <id>{ $id }</id>
                        <uri>{ $uri }</uri>
                        <key>{ $id }</key>
                        <xmlValue>{ $xmlValue }</xmlValue>
                        <lang>{$lang}</lang>
                    </children>
                    )

(:, $collation):)

};

        let $startTime := util:system-time()

    let $lang := if(equals($lang, "")) then "en" else $lang
    
    let $currentUser := sm:id()//sm:real/sm:username/string()
    let $groups := string-join(sm:get-user-groups($currentUser), ' ')
    let $topConcepts := (
            for $tcs in $concept-collection//skos:ConceptScheme[@rdf:about[starts-with(., $skosThesau:thesBaseUri)]]
                            except $concept-collection//skos:ConceptScheme[@type = "root"]
                    
                return
                    if($tcs//skos:hasTopConcept/@rdf:resource = "") then () else
                    <topConcept rdf:resource="{ $tcs//skos:hasTopConcept/@rdf:resource }"
                        status="{ $tcs/skosThesau:admin/@status }"
                        groups="{ $tcs/skosThesau:admin/@groups }"/>
          )

    let $thesauri :=for $lang in tokenize($langList, " ")
        let $collation :=  '?lang=' || lower-case($lang) || "-" || $lang
        return
        <thesaurus xml:lang="{ $lang }">
<children xmlns:json="http://www.json.org" json:array="true">
         <title>Thesaurus {$skosThesau:thesaurus-app}</title>
         <id>{$skosThesau:appParam//idPrefix[@type="concept"]/text()}1</id>
         <key>{$skosThesau:appParam//idPrefix[@type="concept"]/text()}1</key>
          <isFolder>true</isFolder>
         <orderedCollection json:literal="true">true</orderedCollection>
         <lang>{$lang}</lang>{
            sort(local:buildTree($topConcepts, $lang), $collation)
            }</children>
    </thesaurus>
    
    
     let $endTime := util:system-time()      
      let $duration := $endTime - $startTime
      let $seconds := $duration div xs:dayTimeDuration("PT1S")
    let $thesaurus := 

    <thesauri>
    <!--This file is updated automatically when a change occurs in the project collection-->
    <last-update>{ fn:current-dateTime() }</last-update>
    <generated-in>{ $seconds } seconds</generated-in>
    <count/>
    <topConceptsUris>{for $topConcept in $topConcepts
        return <topConceptUri status="{ data($topConcept/@status) }">{ data($topConcept/@rdf:resource) }</topConceptUri>}</topConceptsUris>
    <user>{ $currentUser }</user>
        { $thesauri
        }
</thesauri>
let $update := update replace $concepts-tree//thesauri with $thesaurus
return 
<data>Thesaurus updated in { $seconds } seconds; top Concepts: {$topConcepts}</data>






