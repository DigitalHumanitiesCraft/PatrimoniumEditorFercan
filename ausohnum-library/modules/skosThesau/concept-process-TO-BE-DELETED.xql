xquery version "3.1";

(:import module namespace config="http://patrimonium.huma-num.fr/config" at "../config.xqm";:)
import module namespace login="http://exist-db.org/xquery/login" at "resource:org/exist/xquery/modules/persistentlogin/login.xql";
import module namespace request="http://exist-db.org/xquery/request";

import module namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/" at "skosThesauApp.xql";

declare namespace processConcept="https://ausohnum.huma-num.fr/skosThesau/processConcept";

declare namespace dc="http://purl.org/dc/elements/1.1/";
declare namespace dct = "http://purl.org/dc/terms/";
declare namespace functx = "http://www.functx.com";
declare namespace periodo="http://perio.do/#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
(:declare namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/";:)

declare namespace time="http://www.w3.org/2006/time#";

declare variable $processConcept:project :=request:get-parameter('project', ());
declare variable $processConcept:input := collection('/db/apps/' || $processConcept:project || '-data/concepts');
declare variable $processConcept:appVariables := doc('/db/apps/' || $processConcept:project || '-data/thot-config.xml');
declare variable $processConcept:schemes := doc('/db/apps/' || $processConcept:project || '-data/schemes/external-schemes.rdf');
declare variable $processConcept:requests := collection('/db/apps/' || $processConcept:project || '-data//requests');

(: declare variable $processConcept:conceptId := request:get-parameter("conceptId", ""); :)
(: declare variable $processConcept:concept := $processConcept:input//id($processConcept:conceptId);
declare variable $processConcept:title :=
  <div class="page-header concept-header">
    <h1>{$processConcept:concept//skos:prefLabel[@xml:lang='en']}<span class="conceptTag"> Concept <em>{$processConcept:conceptId}</em></span></h1>
  </div>
    ; :)

(: declare variable $processConcept:currentUser := xmldb:get-current-user(); :)
(: let $userPrimaryGroup := sm:get-user-primary-group($currentUser) :)

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



declare function processConcept:fullConcept($node as node(), $model as map(*), $conceptId as xs:string, $language as xs:string) {

  let $concept := $processConcept:input//id($conceptId)
  let $conceptUri := data($concept/@rdf:about)
  let $schemeURI := data($concept//skos:inScheme/@rdf:resource)
  let $schemeNode := $processConcept:input//skos:ConceptScheme[@rdf:about=$schemeURI]
  let $nodeType := name($concept)
  let $schemeName := $schemeNode//dc:title[@type='short']

  let $title :=
    <div class="page-header concept-header">
      <h1>
        {if($nodeType = "skos:Collection") then concat("<", " ") else ()}
        {upper-case(substring($concept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang=$language]/text(), 1, 1))}{substring($concept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang=$language]/text(), 2)}
          {if($nodeType = "skos:Collection") then concat(" ", ">") else ()}

<span class="conceptTag"> Concept <em>{$conceptId}</em></span></h1>
    </div>
  let $uri :=
      <div class="URI"><span class="pastilleLabelBlue pastilleURI">URI </span>{data($concept/@rdf:about)}
         </div>
  let $prefLabels :=
    <div class="panel panel-default panel-terms">
           <div class="panel-heading">
              <h2 class="panel-title">Preferred Terms{if(sm:has-access(xs:anyURI('/db/apps/' || $processConcept:project || '/modules/4access.xql') , 'r-x' )) then
                                (
                            skosThesau:addPrefLabelButton($conceptId)
                            )
                                else()
               }
               <span class="skosLabel"> (skos:prefLabel)
              <a title="" data-html="true" data-toggle="popover" data-content="For more details about skos:prefLabel, see the Skos &lt;a
            ">
                                <i class="glyphicon glyphicon-question-sign
                skosQuestion"></i></a>
                </span></h2>
           </div>
           <div class="panel-body">
              <ul id="prefLabel-list" class="term-list">
                {
                  for $prefLabel in $concept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)]
                    let $value := if ($prefLabel/@xml:lang = "xml") then ($prefLabel) else upper-case(substring($prefLabel, 1, 1)) || substring($prefLabel, 2) 
                    let $lang := data($prefLabel/@xml:lang)
                    
                  return
                    
                   if (sm:has-access(xs:anyURI('/db/apps/' || $processConcept:project || '/modules/4access.xql') , 'r-x' )) then (
                   
                     <li class="term-list-item">
                         {skosThesau:displayAndEditLabel($conceptId, $value, 'prefLabel', $lang, 0)}
                     </li>
                    
                    )
              else (
                    <li class="term-list-item">
                    {$value || " (" || $lang || ")"}
                    </li>
                    )
                    
                }
              </ul>
           </div>
        </div>
let $altLabels :=
    <div class="panel panel-default panel-terms">
           <div class="panel-heading">
              <h2 class="panel-title">Alternative Terms
              {if(sm:has-access(xs:anyURI('/db/apps/' || $processConcept:project || '/modules/4access.xql') , 'r-x' )) then
                                (
                            skosThesau:addAltLabelButton($conceptId)
                            )
                                else()
               }
              <span class="skosLabel"> (skos:altLabel)
              <a title="" data-html="true" data-toggle="popover" data-content="For more details about skos:prefLabel, see the Skos &lt;a">
                                <i class="glyphicon glyphicon-question-sign
                skosQuestion"></i></a>
                </span>
                </h2>
                
           </div>
           <div class="panel-body">
              <ul id="altLabel-list" class="term-list">
                {
                  for $altLabel at $pos in $concept//skos:altLabel[not(ancestor-or-self::skos:exactMatch)]
                    let $value := upper-case(substring($altLabel, 1, 1)) || substring($altLabel, 2)
                    let $lang := data($altLabel/@xml:lang)
                    order by $value
                  return
                    if (sm:has-access(xs:anyURI('/db/apps/' || $processConcept:project || '/modules/4access.xql') , 'r-x' )) then (
                   
                     <li class="term-list-item">
                         {skosThesau:displayAndEditLabel($conceptId, $value, 'altLabel', $lang, $pos)} 
                     </li>
                    
                    )
              else (
                    <li class="term-list-item">
                    {$value || " (" || $lang || ")"}
                    </li>
                    )
                }
              </ul>
           </div>
        </div>

let $dcTitles :=
    <div class="panel panel-default panel-terms">
           <div class="panel-heading">
              <h2 class="panel-title">Title<span class="skosLabel"> (dc:title)
              <a title="" data-html="true" data-toggle="popover" data-content="For more details about dc:title, see the Skos &lt;a
            ">
                                <i class="glyphicon glyphicon-question-sign
                skosQuestion"></i></a>
                </span></h2>
           </div>
           <div class="panel-body">
              <ul class="term-list">
                {
                  for $dcTitle in $concept//dc:title[not(ancestor-or-self::skos:exactMatch)]

                  return
                    <li class="term-list-item">{$dcTitle} ({data($dcTitle/@xml:lang)})

                    </li>
                }
              </ul>
           </div>
        </div>


let $broaderTerms:=
  <div class="panel panel-default panel-terms">
               <div class="panel-heading">
                  <h2 class="panel-title">Broader Terms<span class="skosLabel"> (skos:broader)<a title="" data-html="true" data-toggle="popover" data-content="" data-original-title="skos:
                                    Narrower"><i class="glyphicon glyphicon-question-sign
                    skosQuestion"></i></a></span></h2>
               </div>
               <div class="panel-body">
                  <ul class="term-list">
                        {
                                           for $bt in $concept//skos:broader
                                           let $btId := substring-after($bt/@rdf:resource, '/concept/')
                                           return
                                             <li  class="term-list-item">
                                               <a class="conceptLink"  onclick="loadOnClickConcept('{$btId}', '{$language}')">
                                                 {$processConcept:input/id($btId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang=$language]}</a></li>
}
  </ul>
  <ul id="broader-list" class="term-list"> 
    {
        for $bt at $pos in $concept//skos:broader
        let $btId := substring-after($bt/@rdf:resource, '/concept/')
        let $btUri := substring-after($bt/@rdf:resource, '/concept/')
        let $labelValue := $processConcept:input/id($btId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang=$language]
        return
         if (sm:has-access(xs:anyURI('/db/apps/' || $processConcept:project || '/modules/4access.xql') , 'r-x' )) then (
         skosThesau:displayAndEditRelatedTerm($conceptId, $btId, $btUri, $labelValue, 'broader', $pos, $language)
         
         )
         else(
        <li  class="term-list-item">
        <a class="conceptLink"  onclick="loadOnClickConcept('{$btId}', '{$language}')">
        {$processConcept:input/id($btId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang=$language]}</a></li>
        )
}
  </ul>
               </div>
            </div>

 let $narrowerTerms:=
                <div class="panel panel-default panel-terms">
                             <div class="panel-heading">
                                <h2 class="panel-title"> Narrower Terms
                                {if(sm:has-access(xs:anyURI('/db/apps/' || $processConcept:project || '/modules/4access.xql') , 'r-x' )) then
                                (
                            skosThesau:addNTButton($conceptId)
                            )
                                else()
                                }
                                <span class="skosLabel"> (skos:narrower)<a title="" data-html="true" data-toggle="popover" data-content="" data-original-title="skos:
                                                  Narrower"><i class="glyphicon glyphicon-question-sign
                                  skosQuestion"></i></a></span>

                                  </h2>
                             </div>
                             <div class="panel-body">


                                <ul id="narrower-list" class="term-list">
                                      {

                                         for $nt in $concept//skos:narrower
                                         let $ntId := substring-after($nt/@rdf:resource, '/concept/')

                                         let $prefLabelNTinCurrentLang :=
                                         concat(upper-case(substring($processConcept:input/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang=$language], 1, 1)), substring($processConcept:input/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang=$language], 2))

                                         let $prefLabelNTinEn :=
                                         concat(upper-case(substring($processConcept:input/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang='en'], 1, 1)), substring($processConcept:input/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang='en'], 2))

                                         let $prefLabelNTin1stAvailableLang :=
                                         concat(upper-case(substring($processConcept:input/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][1], 1, 1)), substring($processConcept:input/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][1], 2)
                                         , ' (', $processConcept:input/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][1]/@xml:lang/string(), ')')

                                         let $prefLabelNT2 :=

                                         $processConcept:input/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang=$language]


                                         let $titleNT := $processConcept:input/id($ntId)//dc:title[not(ancestor-or-self::skos:exactMatch)][@xml:lang=$language]|$processConcept:input/id($ntId)//dc:title[not(ancestor-or-self::skos:exactMatch)][1]

                                        order by $prefLabelNTinCurrentLang


                                         return
                                           <li  class="term-list-item">
                                             <a class="conceptLink"
                                               onclick="loadOnClickConcept('{$ntId}', '{$language}')">

                                               {if($processConcept:input/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)]) then
                                                  (
                                                  if($prefLabelNTinCurrentLang != '') then $prefLabelNTinCurrentLang
                                                        else if ($prefLabelNTinEn != '') then $prefLabelNTinEn
                                                        else ($prefLabelNTin1stAvailableLang)
                                                  )
                                                  else $titleNT
                                               }
                                               </a></li>
              }
                </ul>
                             </div>
                          </div>
let $schemeNote :=
<div class="panel panel-default panel-genNote">
          <div class="panel-heading">
                  <h2 class="panel-title">Scheme note <span class="skosLabel"> (skos:ConceptScheme)<a title="" data-html="true" data-toggle="popover" data-content="For more "
                  data-original-title="Skos: Concept Scheme"><i class="glyphicon glyphicon-question-sign skosQuestion"></i></a></span></h2>
               </div>
               <div class="panel-body">
                 <span class="h5">Publisher:</span> {$schemeNode/dc:publisher}
                 <br/>
                 <span class="h5">Editor &amp; contributors:</span>
                  <ul>
                    {for $people in  $schemeNode//dc:creator[@role='editor']
                    order by $people ascending
                    return
                      <li>
                      {$people/text()} ({$people/@role/string()})
                    </li>
                    }
                    {for $people in  $schemeNode//dc:creator[@role='contributor']
                    order by functx:substring-after-last($people, ' ') ascending
                    return
                      <li>
                      {$people/text()} ({$people/@role/string()})
                    </li>
                    }
                  </ul>
               </div>
            </div>

let $temporalExtent :=
  <div class="panel panel-default panel-date panel-terms">
                 <div class="panel-heading">
                    <h2 class="panel-title">Temporal Extent
                       <span class="skosLabel"> (time:TemporalEntity)<a title="" data-html="true" data-toggle="popover" data-content="For more details about " data-original-title="Time:Temporal
                                      Entity"><i class="glyphicon glyphicon-question-sign
                      skosQuestion"></i></a></span></h2>
                 </div>
                 <div class="panel-body">
                 
                   {for $temp in $concept//time:TemporalEntity
                      return

                          <span class="dateEntry">
                            {if(starts-with($temp/periodo:earliestYear, '-'))
                              then
                              (
                                if($temp/periodo:latestYear <0)
                                then
                                  (
                                    concat(substring($temp/periodo:earliestYear, 2), " - ", substring($temp/periodo:latestYear, 2), " ", $processConcept:appVariables//item[@type='bc'][@xml:lang=$language])
                                  )
                                  else if($temp/periodo:latestYear >0)
                                  then
                                    (
                                      concat(substring($temp/periodo:earliestYear, 2), " ", $processConcept:appVariables//item[@type='bc'][@xml:lang=$language], " - ", $temp/periodo:latestYear, " ", $processConcept:appVariables//item[@type='ad'][@xml:lang=$language])
                                    )
                                    else()
                              )
                            else(
                              concat($temp/periodo:earliestYear, " - ", $temp/periodo:latestYear, " ", $processConcept:appVariables//item[@type='ad'][@xml:lang=$language])
                            )

                            }
                          </span>
                 }
                 </div>
              </div>

let $exactMatches :=
  <div class="panel panel-default panel-terms">
               <div class="panel-heading">
                  <h2 class="panel-title"> Exact match<span class="skosLabel"> (skos:exactMatch)<a title="" data-html="true" data-toggle="popover"
                  data-content="For more " data-original-title="skos: Exact
                                    Match"><i class="glyphicon glyphicon-question-sign
                    skosQuestion"></i></a></span></h2>
               </div>
               <div class="panel-body">
                  <ul class="term-list">
                      {
                        for $em in $concept//skos:exactMatch

                        let $schemeURI:= $em/skos:Concept/skos:inScheme/@rdf:resource/string()
                        let $schemeShortname := $processConcept:schemes//skos:ConceptScheme[@rdf:about=$schemeURI]/dc:title/dct:alternative
                        let $schemeLongname := $processConcept:schemes//skos:ConceptScheme[@rdf:about=$schemeURI]/dc:title[not(child::dct:alternative)]
                        let $emUrl := $em/skos:Concept/@rdf:about/string()
                        return
                        <li class="term-list-item">
                          <span class="pastilleLbelBlue">
                          <a class="pastilleLabelBlue" href="{$em/skos:Concept/skos:inScheme/@rdf:resource/string()}" title="{$schemeLongname}">
                          {$schemeShortname}
                          </a>
                          </span>
                          <span class="exactMatchValue">{$em/skos:Concept/skos:notation}
                            {if ($em/skos:Concept/skos:prefLabel/text() != "")
                            then(
                            concat(" ('" , $em/skos:Concept/skos:prefLabel[1], "')")
                            )
                            else()

                            }
                            &#160;
                          <a href="{$emUrl}" target="_blank" title="Open in a new window">
                          <i class="glyphicon glyphicon-new-window" ></i>
                          </a>
                          </span>

                        </li>
                      }



                  </ul>
               </div>
            </div>

let $adminButtons :=
<div class="editbutton row">
<!--
<button id="pullRequest" class="btn btn-primary editbutton pull-right" onclick="javascript:createRequestOnConcept('{$conceptId}')" appearance="minimal" type="button"><i class="glyphicon glyphicon-plus
                            editConceptIcon"></i>&#160;Request</button>
    -->
<button id="newConcept" class="btn btn-primary editbutton
                        pull-right" appearance="minimal" type="button" onclick="window.open('/admin/new-concept/{$schemeName}')"><i class="glyphicon glyphicon-plus
                            editConceptIcon"> </i>&#160;Concept</button>
 <button id="editTree" class="btn btn-warning editbutton  pull-right" onclick="javascript:window.location.href='/admin/scheme/{$schemeName}'"
  appearance="minimal" type="button"><i class="glyphicon glyphicon-edit
                              editConceptIcon"></i>&#160;Scheme</button>
 <button id="editConcept" class="btn btn-primary editbutton pull-right" onclick="javascript:window.location.href='/admin/concept/{$conceptId}'" appearance="minimal" type="button"><i class="glyphicon glyphicon-edit
                            editConceptIcon"></i>&#160;Concept</button>

    </div>

let $revisionSuggestions :=
    if(not(exists($processConcept:requests//.[@object=$conceptId]))) then () else
    <div>
    <h3>Revision suggestions</h3>
    <table class="table table-striped">

             <tr>
                  <th>Request id</th>
                  <th>Suggested by</th>
                  <th>Description</th>
                  <th>Overview</th>

            </tr>


    {
  for $revision in $processConcept:requests//.[@object=$conceptId]


  order by $revision/@created

  return
  <tr>
  <td>{data($revision/@xml:id)}</td>
        <td>{data($revision/@creator)}</td>
        <td>{$revision/description/text()}</td>
        <td>
        <ul>
        {

        for $nodes at $pos in $revision/skos:Concept//.[position()>1]
          let $nodeName := node-name($nodes)

        return

                if(compare($nodes, $concept//.[$pos+1]) = -1) then (
                    if (string($nodeName) eq "") then () else(
                <li>
                {$nodes}  [original: {$concept//.[$pos+1]}] [{$nodeName} ({data($nodes/@xml:lang)})]</li>
                )) else ()

           }
            </ul>
        </td>

      </tr>
  }
    </table>
 </div>

let $copyright :=
<div class="panel-body">
                <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">
                    <img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png"/>
                </a>
                <br/>This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons
                    Attribution-ShareAlike 4.0 International License</a>.
        </div>

(:*******************
*   MAIN RETURN   *
*******************:)
return
(
<div>
<!--
{if (sm:has-access (xs:anyURI('/db/apps/' || $processConcept:project || '/modules/4access.xql'), 'r-x' ))
            then (<div>{$adminButtons}

            <div class="h4 pull-right"><span class="pastilleLabelBlue pastilleURI">Status </span>{data($concept//skosThesau:admin/@status)}</div>
            </div>
            )else()}
-->
{
(: ****************
    Displays different details according to concept status (1/ deleted; 2/published; /3 Not published
    ****************:)

(:Case Concept is deleted:)

if($conceptId="intro" or $conceptId="undefined" or $conceptId='' ) then
    (
      <div>
      <h3>Welcome to APC thesaurus - {$conceptId}</h3>
      <p>TBD</p>
      <div>
      <h3>Search in existing concepts</h3>
            <label for="conceptLookupInputModal">
            </label>
            <input type="text" class="form-control" id="concepts4NTLookupInputModal" name="concepts4NTLookupInputModal"/>
            </div>
                            <div id="selectedConceptURI" class="hidden">URI of selected concept: <span id="newNTconceptURI"/></div>
                            <button id="addSelectedConceptasNT" class="btn btn-primary" onclick="addSelectedNT2Concept('{$conceptId}')">Add as NT</button>
           
      
      
      </div>
    )
    else if(not($concept))
    then (<h3>
      There is no concept with an ID <em>{$conceptId}</em> in project {$processConcept:project}
  </h3>)

else if($concept//skosThesau:admin/@status="deleted") then
    (
      <p>deleted</p>
    )
    else if(not($concept))
    then (<h3>
      There is no concept with an ID <em>{$conceptId}</em>
  </h3>)

(:Case Scheme is 'published':)

else if($schemeNode/skosThesau:admin/@status = "published")
    then (
(:    Case Concept is published:)
    if($concept/skosThesau:admin/@status = "published") then
        (
         <div>
          <div class="row">aaa
             {$title}
             {$uri}
          </div>
          <div class="row">
             {
             if ($concept//dc:title) then ($dcTitles)
             else
             $prefLabels}
             {if( $concept//skos:altLabel) then
                     $altLabels
                       else(
                       if(sm:has-access(xs:anyURI('/db/apps/' || $processConcept:project || '/modules/4access.xql') , 'r-x' )) then (
                        $altLabels )
                       else()
                       )
                   }
     
               {if( $concept//skos:broader) then
                     (skosThesau:displayRelatedConceptList($conceptId, "broader", $language))
                       else if (not($concept//skos:broader) and (sm:has-access(xs:anyURI('/db/apps/' || $processConcept:project || '/modules/4access.xql'), 'r-x' ))) then
                       (skosThesau:displayRelatedConceptList($conceptId, "broader", $language))
                       else ()
                 
               }
               
               {if( $concept//skos:narrower) then
                     (skosThesau:displayRelatedConceptList($conceptId, "narrower", $language))
                       else if (not($concept//skos:narrower) and (sm:has-access(xs:anyURI('/db/apps/' || $processConcept:project || '/modules/4access.xql'), 'r-x' ))) then
                       (skosThesau:displayRelatedConceptList($conceptId, "narrower", $language))
                       else ()
                   }
     
     
                   {if( $concept//time:TemporalEntity) then
                     $temporalExtent
                     else if (not($concept//skos:TemporalEntity) and (sm:has-access(xs:anyURI('/db/apps/' || $processConcept:project || '/modules/4access.xql'), 'r-x' ))) then 
                     $temporalExtent
                     else()
                   }
                   {if($concept//skos:exactMatch) then
                     (
                     $exactMatches)
                     else if (not($concept//skos:exactMatch) and (sm:has-access(xs:anyURI('/db/apps/' || $processConcept:project || '/modules/4access.xql'), 'r-x' ))) then (
                     $exactMatches)
                     else()
                     
                   }
     
     
                   </div>
                       <div class="row">
                            {$schemeNote}
                          </div>
     
     
     
                 </div>
                 )
                 else (
(:                 Case of a unpublished concept in a published scheme:)
                 if (sm:has-access(xs:anyURI('/db/apps/' || $processConcept:project || '/modules/4access.xql'), 'r-x' )) then (
                 skosThesau:processConcept($conceptId, $language)
                  )
                 
                 else skosThesau:loggedInRequired()
                 
                 
                 )
        )
(:Case Concept is Not published:)

   else if($schemeNode/skosThesau:admin/@status != "published")
   then(if (sm:has-access (xs:anyURI('/db/apps/' || $processConcept:project || '/modules/4access.xql'), 'r-x' )) then (
       <div>
         <div class="row">
           {$title}
           {$uri}
           {$prefLabels}
           {$altLabels}
           {skosThesau:displayRelatedConceptList($conceptId, "broader", $language)}
           {skosThesau:displayRelatedConceptList($conceptId, "narrower", $language)}
           
           {$exactMatches}
           {$temporalExtent}
        </div>
        <div class="row">
           {$schemeNote}
        </div>
    </div>


         )
       else(
     <div>
     <p>You have to be loggued in to access this resource</p>
      <a href="#loginDialog" class="" data-toggle="modal" title="Login"><button type="button" class="btn btn-primary">Login</button></a>

      </div>
     )
   )
     else(

     )}
<div class="row">
{$copyright}
                       {
                       $revisionSuggestions}
            </div>

</div>
)
};

  return

(: processConcept:fullConcept(request:get-parameter("concept", ""), request:get-parameter("lang", "")) :)
