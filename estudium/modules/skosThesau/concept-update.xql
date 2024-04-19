xquery version "3.1";

import module namespace config="https://ausohnum.huma-num.fr/apps/eStudium/config" at "../config.xqm";

declare namespace skos="http://www.w3.org/2004/02/skos/core#";
declare namespace dc="http://purl.org/dc/elements/1.1/";
declare namespace dct="http://purl.org/dc/terms/";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/";
declare namespace json="http://www.json.org"; 
declare namespace functx = "http://www.functx.com"; 

declare variable $baseUri := doc($config:data-root || '/app-general-parameters.xml')//uriBase/text();

declare option exist:serialize "method=xhtml media-type=text/html indent=yes";
(:declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=yes indent=yes";:)


declare function functx:escape-for-regex
  ( $arg as xs:string? )  as xs:string {

   replace($arg,
           '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')
 } ;

declare function functx:substring-after-last
  ( $arg as xs:string? ,
    $delim as xs:string )  as xs:string {

   replace ($arg,concat('^.*',functx:escape-for-regex($delim)),'')
 } ;


declare function functx:replace-element-values
  ( $elements as element()* ,
    $values as xs:anyAtomicType* )  as element()* {

   for $element at $seq in $elements
   return element { node-name($element)}
             { $element/@*,
               $values[$seq] }
 } ;
declare function functx:remove-elements
  ( $elements as element()* ,
    $names as xs:string* )  as element()* {

   for $element in $elements
   return element
     {node-name($element)}
     {$element/@*,
      $element/node()[not(functx:name-test(name(),$names))] }
 } ;
declare function functx:name-test
  ( $testname as xs:string? ,
    $names as xs:string* )  as xs:boolean {

$testname = $names
or
$names = '*'
or
functx:substring-after-if-contains($testname,':') =
   (for $name in $names
   return substring-after($name,'*:'))
or
substring-before($testname,':') =
   (for $name in $names[contains(.,':*')]
   return substring-before($name,':*'))
 } ;
 
 
declare function functx:substring-after-if-contains
  ( $arg as xs:string? ,
    $delim as xs:string )  as xs:string? {

   if (contains($arg,$delim))
   then substring-after($arg,$delim)
   else $arg
 } ;
 
 
(: get the form data that has been "POSTed" to this XQuery :)
let $data := request:get-data()
let $submissiontype := request:get-parameter('submissiontype', '')

(:General variables:)
let $currentUser := data(sm:id()//sm:username)
let $userGroup := sm:get-user-primary-group($currentUser)
let $now := fn:current-dateTime()

let $data-collection := collection($config:data-collection || '/concepts') 
(:let $commentCollection := collection("/db/apps/skosThesau/data/comments"):)
(:let $updateCollection := collection($config:data-collection || '/updates'):)
let $logs := collection($config:data-collection || '/logs')
(:let $scheme-tree := collection('/db/apps/skosThesau/data/coll/xml'):)



let $originalConcept:= $data//skosThesau:xfinstance[@type='original']/*[self::skos:Concept or self::skos:Collection]
let $updatedConcept:= $data//skosThesau:xfinstance[@type='update']/*[self::skos:Concept or self::skos:Collection]
let $newScopeNote := $data//skosThesau:xfinstance[@type='update']/skos:scopeNote
let $canonicalConcept:= $data//skosThesau:xfinstance[@type='canonical']/skos:Concept
let $conceptId := data($originalConcept/@xml:id)
let $concept := $data-collection/id($conceptId)
let $schemeURI := data($concept/skos:inScheme/@rdf:resource)
let $updateComment := $data//skosThesau:xfinstance[@type="admin"]/skosThesau:adminComment


(:let $scheme-currentConcept := $scheme-tree//children[inScheme = $originalConcept/skos:inScheme/@rdf:resource]:)
(:let $treeSchemeNodeCurrentConcept := $scheme-tree//children[id=$conceptId]:)

let $currentStatus := $concept//skosThesau:validation/skosThesau:validationGroup[@name=$userGroup]/skosThesau:conceptStatus/node()
let $validationNode := $concept//skosThesau:validation




(:let $updatedConceptPrefLabelEn:= $updatedConcept/skos:prefLabel[@xml:lang='en']/text():)


(:Keep only updated fields:)
(:All removed since not used anymore:)
(:let $updatedprefLabelEn := if ($canonicalConcept/skos:prefLabel[@xml:lang='en']/text() !='')
                then $canonicalConcept/skos:prefLabel[@xml:lang='en']
                else if ($originalConcept/skos:prefLabel[@xml:lang='en']/text() != $updatedConcept/skos:prefLabel[@xml:lang='en']/text())
            then $updatedConcept/skos:prefLabel[@xml:lang='en']
            else()
let $updatedprefLabelDe := if ($canonicalConcept/skos:prefLabel[@xml:lang='de']/text() !='')
                then $canonicalConcept/skos:prefLabel[@xml:lang='de']
                else if ($originalConcept/skos:prefLabel[@xml:lang='de']/text() != $updatedConcept/skos:prefLabel[@xml:lang='de']/text())
            then $updatedConcept/skos:prefLabel[@xml:lang='de']
            else()
let $updatedprefLabelFr := if ($canonicalConcept/skos:prefLabel[@xml:lang='fr']/text() !='')
                then $canonicalConcept/skos:prefLabel[@xml:lang='fr']
                else if ($originalConcept/skos:prefLabel[@xml:lang='fr']/text() != $updatedConcept/skos:prefLabel[@xml:lang='fr']/text())
            then $updatedConcept/skos:prefLabel[@xml:lang='fr']
            else() 
let $updatedprefLabelXml := if ($canonicalConcept/skos:prefLabel[@xml:lang='xml']/text() !='')
                then $canonicalConcept/skos:prefLabel[@xml:lang='xml']
                else if ($originalConcept/skos:prefLabel[@xml:lang='xml']/text() != $updatedConcept/skos:prefLabel[@xml:lang='xml']/text())
            then $updatedConcept/skos:prefLabel[@xml:lang='xml']
            else()
let $updatedprefLabelAr := if ($canonicalConcept/skos:prefLabel[@xml:lang='ar']/text() !='')
                then $canonicalConcept/skos:prefLabel[@xml:lang='ar']
                else if($originalConcept/skos:prefLabel[@xml:lang='ar']/text() != $updatedConcept/skos:prefLabel[@xml:lang='ar']/text())
                    then $updatedConcept/skos:prefLabel[@xml:lang='ar']
            else()
:)

(:let $updatedscopeNote := if ($canonicalConcept/skos:scopeNote/text() !='')
                then $canonicalConcept/skos:scopeNote
                else if ($originalConcept/skos:scopeNote/text() != $updatedConcept/skos:scopeNote/text())
            then $updatedConcept/skos:scopeNote
            else()
:)






(: log into the collection :)
(:let $login := xmldb:login($data-collection, 'vincent', 'fromExist2'):)


(:let $comment := request:get-parameter('comment', ""):)

let $langAltLabel:=request:get-parameter('langAltLabel', '')

(:let $validationNode := $concept//skosThesau:adminComments:)

(:let $submission:=  <skosThesau:adminComment group='{$userGroup}' user='{$currentUser}' type='{$submissiontype}'>{$comment}<dct:created>{$now}</dct:created></skosThesau:adminComment>:)


(:COMMENTS:)
(:let $adminComment := if ($canonicalConcept/skosThesau:adminComment/text() !='')
                then <skosThesau:adminComment ref='{$conceptId}' group='{$userGroup}' user='{$currentUser}' type='{$submissiontype}'
                    xml:lang='{$langAltLabel}' >{$canonicalConcept/skosThesau:adminComment/text()}
                        <dct:created>{$now}</dct:created>
                    </skosThesau:adminComment>
                else()
let $simpleComment := if ($canonicalConcept/skosThesau:adminComment/text() !='')
                then <skosThesau:adminComment>{$conceptId}{$canonicalConcept/skosThesau:adminComment/text()}</skosThesau:adminComment>
                        else()

:)


(:let $newStatus :=  <skosThesau:validationGroup name='{$userGroup}' status='{$status}'>{$comment}<dct:created>{$now}</dct:created></skosThesau:validationGroup>:)

(:let $nodeToBeAdded := <a>b</a>:)
(: save the new file, overwriting the old one :)
(:let $store := xmldb:store($data-collection, $data-collection, $item):)
(:let $log:= update replace $concept//skosThesau:validation/skosThesau:validationGroup[@name=$userGroup]/skosThesau:conceptStatus with $status :)
(:let $insert := update insert $newStatus into $validationNode:)



(:let $includeNewScopeNote :=  update insert <dct:modified when="{$now}" who="{$currentUser}" /> into $data-collection//*[@xml:id=$conceptId]:)
 
 
 
  
 (:SAVE concept:)
(:
let $updatedConceptCleanedFromnNwNT :=  
                                        
                         functx:remove-elements($updatedConcept//skos:narrower, 'skos:prefLabel'):)

let $saveAndupdateConcept := update replace $data-collection/id($conceptId) with $updatedConcept
(:Possible new scopeNote to be added after concept is updated:)
let $includeNewScopeNote := if ($newScopeNote/text() !='')
                then update insert $newScopeNote into $data-collection/id($conceptId)
                else()   
 
 
 
(: Update of Narrower and Broader terms:)
(: NARROWER TERMS:)
 
 let $updateNTRemovedFromConcept:=
         for $ntToDelete in $originalConcept//skos:narrower
             let $IDNTToDelete:= functx:substring-after-last($ntToDelete/@rdf:resource, '/')
            return
              if($ntToDelete[@rdf:resource = $updatedConcept//skos:narrower/@rdf:resource])  (:Check if NT already preent in Concept:)
              then () (:YES: nothing to do:)
              else (
(:                1) Current concept removed as BT in NT:)
             update delete $data-collection/id($IDNTToDelete)//skos:broader[@rdf:resource=$updatedConcept/@rdf:about],
             
             
(:                 2) NT removed from Tree :)
(:             update delete $scheme-tree//children/id[contains(., $conceptId)]/parent::node()/children/id[contains(., $IDNTToDelete)]/parent::node(),:)
(:                 3) Log entry :)
             update insert <skosThesau:log type='nt-deletion' when='{$now}' who='{$currentUser}' scheme='{$schemeURI}' what='{$conceptId}'>Concept {$IDNTToDelete} removed from list of NTs of concept {$conceptId};</skosThesau:log> into $logs/rdf:RDF/id('all-logs')            
                )
                

let $updateNTAddFromUpdate:=
         for $ntToAdd in $updatedConcept//skos:narrower
             let $IDNTToAdd:= functx:substring-after-last($ntToAdd/@rdf:resource, '/')
             let $ntConcept := $data-collection/id($IDNTToAdd)
             let $nodeType := fn:node-name($ntConcept)
            return
                    
              if($ntToAdd[@rdf:resource = $originalConcept//skos:narrower/@rdf:resource])    (:Check whether NT is already in original Concept:)
              
              then (  (:NT already in original concept: nothing to do:)
              (:update insert <test when="{$now}">Nothing to do for {$IDNTToAdd}; conceptid = {$conceptId}"
                    </test> into $logs/rdf:RDF[@xml:id='all-logs']:)
                    ) 
                    (:Nothing :)
              else (
              (:Include current Concept as BT to added NT:)
                 if ($ntToAdd/@rdf:resource='newNT')
                 then(
                     let $idList := for $id in $data-collection//.[contains(./@xml:id, 'thot-')]
                                    return
                                    <item>{substring-after($id/@xml:id, 'thot-')}</item>
                     let $last-id:= fn:max($idList)
                     let $newId := concat('thot-', fn:sum(($last-id, 1)))
                     let $newConcept :=
                          <skos:Concept type="non-ordered" rdf:about="{$baseUri}/concept/{$newId}" xml:id="{$newId}">
                          <skos:prefLabel xml:lang="{$ntToAdd/skos:prefLabel/@xml:lang/string()}">{$ntToAdd/skos:prefLabel/text()}</skos:prefLabel>
                          <skos:inScheme rdf:resource="{$schemeURI}"/>
                          <skos:broader rdf:resource="{$baseUri}/concept/{$conceptId}"/>
                          <skosThesau:admin status="{$concept//skosThesau:admin/@status/string()}"/>
                          <dct:created>{$now}</dct:created>
                          </skos:Concept>
                    return
                    (                      
                         update insert $newConcept into $data-collection//rdf:RDF[node()/@xml:id=$conceptId],
                        
                        
                        if( $data-collection//id($conceptId)/skos:narrower) then
                        
               update insert <skos:narrower rdf:resource="{$baseUri}/concept/{$newId}"/> following $data-collection//id($conceptId)/skos:narrower[last()]
               else(
               update insert <skos:narrower rdf:resource="{$baseUri}/concept/{$newId}"/> following $data-collection//id($conceptId)/skos:prefLabel[last()]
               ),
                        
                        
                     
                     update insert <skosThesau:log type='concept-creation-in-nt-addition' when='{$now}' who='{$currentUser}' what='{$conceptId}' scheme='{$schemeURI}'>
                     Concept {$newId} created and added as NT to concept {$conceptId};
                     Updated concept: {$updatedConcept}
                     
                     
                     </skosThesau:log>
                              into $logs/rdf:RDF/id('all-logs')
                    )
                 )
                 else(
                     update insert <skos:broader rdf:resource="{data($updatedConcept/@rdf:about)}"/> into $data-collection//id($IDNTToAdd),
                     update insert <skosThesau:log type='nt-addition' when='{$now}' who='{$currentUser}' what='{$conceptId}' scheme='{$schemeURI}'>Concept {$IDNTToAdd} added as NT of concept {$conceptId}</skosThesau:log>
                              into $logs/rdf:RDF/id('all-logs')
                )   
                )
                
                
(: BROADER TERMS               :)
let $updateBTRemovedFromConcept:=
         for $btToProcess in $originalConcept//skos:broader
             let $IDBTToProcess:= functx:substring-after-last($btToProcess/@rdf:resource, '/')
            return
              if($btToProcess[@rdf:resource = $updatedConcept//skos:broader/@rdf:resource])  (:Check if BT is in Updated Concept:)
              then () (:YES: nothing to do:)
              else (   (:NO: then Current Concept has to be removed as NT in BT:)
(:                1) Current concept removed as BT in NT:)
             update delete $data-collection/id($IDBTToProcess)//skos:narrower[@rdf:resource=$updatedConcept/@rdf:about],
             
             
(:                 2) NT removed from Tree :)
(:             update delete $scheme-tree//children/id[contains(., $conceptId)]/parent::node()/children/id[contains(., $IDNTToDelete)]/parent::node(),:)
(:                 3) Log entry :)
             update insert <skosThesau:log type='nt-deletion' when='{$now}' who='{$currentUser}' what='{$conceptId}' scheme='{$schemeURI}'>Concept {$IDBTToProcess} removed from list of NTs of concept {$conceptId}; Concept {$conceptId} removed fromlist of BT of {$IDBTToProcess} .
             </skosThesau:log> into $logs/rdf:RDF/id('all-logs')            
                )
        
let $updateBTAddFromUpdate:=
         for $btToProcess in $updatedConcept//skos:broader
             let $IDBTToProcess:= functx:substring-after-last($btToProcess/@rdf:resource, '/')
             let $btConcept := $data-collection/id($IDBTToProcess)
             let $nodeType := fn:node-name($btConcept)
            return
                    
              if($btToProcess[@rdf:resource = $originalConcept//skos:broader/@rdf:resource])    (:Check whether NT is already in original Concept:)
              
              then (  (:NT already in original concept: nothing to do:)
              (:update insert <test when="{$now}">Nothing to do for {$IDBTToProcess}; conceptid = {$conceptId}"
                    </test> into $logs/rdf:RDF[@xml:id='all-logs']:)
                    ) 
                    (:Nothing :)
              else (
              (:Include current Concept as BT to added NT:)
               if( $data-collection/id($IDBTToProcess)/skos:broader) then
               update insert <skos:narrower rdf:resource="{data($updatedConcept/@rdf:about)}"/> following $data-collection/id($IDBTToProcess)/skos:narrower[last()]
               else(
               update insert <skos:narrower rdf:resource="{data($updatedConcept/@rdf:about)}"/> following $data-collection/id($IDBTToProcess)/skos:prefLabel[last()]
               )
               ,    update insert <skosThesau:log type='nt-addition' when='{$now}' who='{$currentUser}' what='{$conceptId}' scheme='{$schemeURI}'>Concept {$IDBTToProcess} added as NT of concept {$conceptId}</skosThesau:log>
                        into $logs/rdf:RDF/id('all-logs')
                )              
                
                
                
                                        
  
(:Gestion des LOGS:)


(:let $insertIntoComments := if ($canonicalConcept/skosThesau:adminComment/text() !='')
                then update insert $adminComment into $commentCollection/rdf:RDF
                else()
    :)            

let $cleanNewNT :=
        for $newNt in $data-collection/id($conceptId)//skos:narrower[@rdf:resource='newNT']
        return update delete $newNt
 
let $lognode := <skosThesau:log type="concept-update" when="{$now}" who='{$currentUser}' what='{$conceptId}' scheme='{$schemeURI}'>
{$data}
    <skos:Concept type="original">{$originalConcept}</skos:Concept>
    
    {$updateComment}
    </skosThesau:log>
let $loginjection := update insert $lognode into $logs/rdf:RDF/id('all-logs')
return 
<response>
<code>200</code>
<message>OK, data saved</message></response>