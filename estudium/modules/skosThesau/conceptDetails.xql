xquery version "3.1";

import module namespace functx="http://www.functx.com";
import module namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/" 
            at "xmldb:exist:///db/apps/ausohnum-library/modules/skosThesau/skosThesauApp.xql";


declare namespace apc="https://ausohnum.huma-num.fr/apps/eStudium/onto#";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace dct = "http://purl.org/dc/terms/";
declare namespace ev = "http://www.w3.org/2001/xml-events";
declare namespace json="http://www.json.org";
declare namespace lawd="http://lawd.info/ontology/";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace periodo="http://perio.do/#";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace thot = "http://thot.philo.ulg.ac.be/";
declare namespace time="http://www.w3.org/2006/time#";
declare namespace xf = "http://www.w3.org/2002/xforms";

declare boundary-space preserve;

declare variable $project :=request:get-parameter('project', ());
declare variable $lang :=request:get-parameter('lang', ());
declare variable $conceptId :=request:get-parameter('conceptId', ());

if($conceptId ="root") then 
    <div>{ skosThesau:generalIndex($project, $lang, 50) }</div>

else

let $lang := if (not($lang)) then "en" else $lang
let $appParam := doc('/db/apps/' || $project || '/data/app-general-parameters.xml')
let $thesaurus-app := $appParam//thesaurus-app/text()
let $concept-collection := collection('/db/apps/' || $thesaurus-app || 'Data/concepts')
let $doc-collection := collection("/db/apps/" || $project || "Data/documents")
let $people-collection := collection("/db/apps/" || $project || "Data/people")
let $concept := $concept-collection/id($conceptId)
let $conceptUri := data($concept/@rdf:about)
let $schemeURI := data($concept//skos:inScheme/@rdf:resource)

let $schemeNode := $concept-collection//skos:ConceptScheme[@rdf:about=$schemeURI]


let $nodeType := name($concept)
let $schemeName := $schemeNode//dc:title[@type='short']
let $conceptStatus := data($concept//skosThesau:admin/@status)
let $schemeStatus := data($schemeNode//skosThesau:admin/@status)
let $schemeCreators := data($schemeNode//dc:creator/@ref)



let $prefLabels :=
    <div class="">
         <h4>Preferred term(s):</h4>
              <ul id="prefLabel-list" class="term-list">
                {
                  for $prefLabel at $pos in $concept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)]
                    let $value := if ($prefLabel/@xml:lang = "xml") then ($prefLabel) else functx:capitalize-first($prefLabel)
                    let $lang := data($prefLabel/@xml:lang)

                  return
                    
                    <li class="term-list-item">
                    {$value || " (" || $lang || ")"}
                    </li>
                    

                }
              </ul>
           </div>
       
let $altLabels :=
    <div class="">
            <h4>Alternative term(s):</h4>
              <ul id="altLabel-list" class="term-list">
                {
                  for $altLabel at $pos in $concept//skos:altLabel[not(ancestor-or-self::skos:exactMatch)]
                    let $value := functx:capitalize-first($altLabel)
                    let $lang := data($altLabel/@xml:lang)
                    order by $value
                  return

                    <li class="term-list-item">
                    {$value || " (" || $lang || ")"}
                    </li>
                 
                }
              </ul>
      </div>
let $exactMatches :=
    if(not($concept//skos:exactMatch)) then () else
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
                        let $schemeShortname := $skosThesau:schemes//skos:ConceptScheme[@rdf:about=$schemeURI]/dc:title/dct:alternative
                        let $schemeLongname := $skosThesau:schemes//skos:ConceptScheme[@rdf:about=$schemeURI]/dc:title[not(child::dct:alternative)]
                        let $emUrl := $em/skos:Concept/@rdf:about/string()
                        return
                        <li class="term-list-item">
                          <span class="pastilleLabelBlue">
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

let $copyright :=
<div class="row">
<div class="panel-body">
                <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">
                    <img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png"/>
                </a>
                <br/>This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons
                    Attribution-ShareAlike 4.0 International License</a>.
</div></div> 
let $relatedDocumentsData :=skosThesau:retrieveDocuments("patrimonium", $conceptUri, ())//li      
let $relatedDocuments:=
        if(count($relatedDocumentsData) >0) then
        <div class="panel panel-default panel-terms">
           <div class="panel-heading">
              <h2 class="panel-title">{if(count($relatedDocumentsData) >1)
              then "There are " || count($relatedDocumentsData) || " documents related to this keyword"
              else "There is 1 document related to this keyword" }</h2>
            </div>
            <div class="panel-body">
              <ol>
              {
        for $match in $relatedDocumentsData
            let $matchType:=switch($match/matchNode)
                        case "rs" return "text annotation"
                        case "term" return "doc. keyword"
                        default return $match/matchNode
            
            order by (functx:substring-after-last-match($match/id, "[aA-zZ]"))
        return 
            <li>{ data($match/id) } - { $match/docTitle/text() }<a href="{ $match/docUri/text() }" target="about"><i class="glyphicon glyphicon-new-window" /></a> [{ $matchType }]</li>
              }
          </ol>
          </div>
          
        </div>
        else()
(: let $relatedDocuments:=
        if(count($relatedDocumentsData) >0) then
        <div class="panel panel-default panel-terms">
           <div class="panel-heading">
              <h2 class="panel-title">{if(count($relatedDocumentsData) >1)
              then "There are " || count($relatedDocumentsData) || " documents related to this keyword"
              else "There is 1 document related to this keyword" }</h2>
            </div>
            <div class="panel-body">
              <ol>
              {
        for $match in $doc-collection//tei:TEI[.//tei:term[@ana = $conceptUri ]]
        return 
            <li>
                { data($match/@xml:id) } - { $match//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/text() }<a href="{ $match//tei:publicationStmt/tei:idno[@type="uri"]/text() }" target="about"><i class="glyphicon glyphicon-new-window" /></a></li>
              }
          </ol>
          </div>
          
        </div>
        else() :)
let $relatedPeopleData :=skosThesau:retrievePeople("patrimonium", $conceptUri)//data
let $relatedPeople :=
if(count( $relatedPeopleData)> 0)
then
    <div class="panel panel-default panel-terms">
          
   
             
           <div class="panel-heading">
              <h2 class="panel-title">{if(count( $relatedPeopleData)>1) then 
                "There are " || count( $relatedPeopleData) || " people related to this keyword"
                else "There is 1 person related to this keyword" }</h2>
            </div>
            <div class="panel-body">
            <div>
                  
                        <div class="row" style="height: 300px">
                            
                                <div class="col-xs-12 col-sm-12 col-md-12">
                                <div id="peopleListDiv">
                                    <table id="peopleList" class="stripe" style="width:100%">
                                            <!--<span class="pull-right">Sorting language: {$lang}</span>-->
                                            <thead>
                                            <tr>
                                            <th>ID</th>
                                            <th class="sortingActive">Name</th>
                                            <th>Personal status</th>
                                            <th>Personal status URI</th>
                                            <th>Rank</th>
                                            <th>RankURI</th>
                                            <th>Dates</th>
                                            <th></th>
                                            <th>Ref.</th>
                                            </tr>
                                            </thead>
                                <tbody>
                                {for $row in $relatedPeopleData
                                return 
                                    <tr>
                                        <td>{ $row//id/text() }</td>
                                        <td>{ normalize-space($row//name) }</td>
                                        <td>{ $row//personalStatus/text() }</td>
                                        <td>{ $row//personalStatusUri/text() }</td>
                                        <td>{ $row//socialStatus/text() }</td>
                                        <td>{ $row//socialStatusUri/text() }</td>
                                        <td>{ $row//temporalRangeStart/text() }</td>
                                        <td>{ $row//temporalRangeEnd/text() }</td>
                                        <td>{ parse-xml-fragment($row//biblio) }</td>
                                    </tr>

                                }</tbody>
                                </table>
                            </div>
                            
                            </div>
                            <!--<div class="col-xs-4 col-sm-4 col-md-4">
                                <div id="loaderBig" class="hidden"></div>
                                <div id="personRecord"/>
                            </div>-->
                            
                    </div>
            </div>
        </div>
 
        <script>
        

            console.log($('#peopleList') +"e");
            var dataTable = $('#peopleList').DataTable({{
    order: [[ 1, "asc" ]],
    //scrollY:        "600px",
    scrollX:        false,
    scrollCollapse: true,
    responsive: true,
    paging: true,
    pageLength: 200,
    lengthMenu: [[50, 100, 200, -1], [50, 100, 200, "All"]],
    
   columns: [
                    {{ data: 'id' }}, //0
                    {{ data: 'name'}}, //1
                   
                    {{ data: 'personalStatus' }}, //2
                    {{ data: 'personalStatusUri' }},//3
                    
                    {{ data: 'socialStatus' }},// 4 
                    {{ data: 'socialStatusUri' }}, //5
                   
                    {{ data: 'temporalRangeStart' }}, //6
                    {{ data: 'temporalRangeEnd' }}, // 7
                    
                    {{ data: 'ref.'}}//8

                  ],   
    columnDefs: [{{
                                   "type": "any-number", targets: [0],
                                   "width": "5em",
                                   "render": function ( data, type, full, meta ) {{
                                return '<span class="spanLink" onclick="displayPersonRecord('+ full.id +')">' + data + '</span>';    }}
                                   
                               }},
                             {{
                                   "width": "100em", 
                                   targets: [1],
                                   "render": function ( data, type, full, meta ) {{
                                return '<span class="spanLink" onclick="displayPersonRecord('+ full.id +')">' + data + '</span>';    }}
                                   
                               }},
                               {{
                               "width": "3em",
                                   targets: [ 2 ]
                               }},
                               
                               {{
                                   targets: [ 3 ],
                                   visible: false
                               }},
                             
                               {{
                                   targets: [ 5 ],
                                   visible: false,
                                   
                               }},
                               
                               {{"width": "4em",
                                   targets: [6],
                                   "type": "num-fmt",
                                   visible: true
                               }},
                               {{
                                   targets: [7],
                                   "type": "num-fmt",
                                   visible: true,
                                   "width": "10em"
                               }}
                            ],
    fixedColumns: true,
    //autoWidth: false,
      language: {{
                        search: "",
                        searchPlaceholder: "Filter by name, status, function, TM no."
                            }},
        
                    }});
                    
     dataTable.on( 'select', function ( e, dt, type, indexes ) {{
                    console.log(type);
                    if ( type === 'row' ) {{
                        var uri = table.rows( indexes ).data().pluck( 'uri' );
                        var id = table.rows( indexes ).data().pluck( 'id' );
                          console.log(id);
                         $("#personRecord").load("/people/get-person-record/" + id);
                        history.pushState(null, null,  "/people/" + id);
                        document.title = "People " + " - " + id;  
                        
                    }}
                }} );
    function displayPersonRecord(id){{
            var url = "/people/" + id;
            window.open(url, "_blank");
            }};
                                                                    

        </script>




    </div>
else()

let $dataTablesScript:=
"

"
        
return 
<div>
<div class="panel panel-default panel-terms">
               <div class="panel-body">
<h2 style="color: #7d1d20; font-weight: bold;">{ skosThesau:getLabel($conceptUri, $lang) }</h2>
<div class="URI"><span class="pastilleLabelBlue pastilleURI">URI </span>{data($concept/@rdf:about)}
    </div>
        <div class="row">
            
                <div class="col-xs-6 col-md-6 col-lg-6">
                {$prefLabels}
                {if( $concept//skos:altLabel) then
                     $altLabels
                       else(
                       )
                }
                </div>
                    <div class="col-xs-6 col-md-6 col-lg-6">
                    {if( $concept//skos:broader) then
                        <div class=""><h4>Broader term(s)</h4>
                        <ul>{
                                for $bt in $concept//skos:broader
                                return
                                <li>{ skosThesau:getLabel($bt/@rdf:resource, $lang) }</li>
                                }
                            </ul>
                        </div>
                        else ()

                    }

                    {if( $concept//skos:narrower) then
                    <div class="termsPanel"><h4>Narrower term(s)</h4>
                            <ul>{for $nt in $concept//skos:narrower[position() < 6]
                                    return
                                    <li>{ skosThesau:getLabel($nt/@rdf:resource, $lang) }</li>}
                                {if(count($concept//skos:narrower) > 5 ) 
                                then 
                                    <li style="list-style: none;">
                                        <a class="" type="button" data-toggle="collapse" data-target="#collapseDocList" aria-expanded="false" aria-controls="collapseDocList">See more...</a>
                                    </li>
                                    else()}
                                </ul>
                                {if(count($concept//skos:narrower) > 5)
                                    then 
                                    (
                                        <div class="collapse" id="collapseDocList">
                                            <div class="card card-body">
                                                <ul>{
                                                    for $nt in $concept//skos:narrower[position() > 5]
                                                    return
                                                    <li>{ skosThesau:getLabel($nt/@rdf:resource, $lang) }</li>
                                                }
                                                </ul>
                                                    </div>
                                            
                                            </div>)
                                else ()
                                }
                                    

                        
                        
                        </div>
                            else ()
                        }

                        </div>
                        
                        {if($concept//skos:exactMatch) then
                            (
                            $exactMatches)
                            
                            else()

                        }


                        </div>
                        </div></div>
                 
                   { $relatedDocuments }
                   
                   { $relatedPeople }
                
                   {$copyright}
   

        <script type="text/javascript" src="/$ausohnum-lib/resources/scripts/skosThesau/skosThesauActions.js"/>
   
                 </div>
