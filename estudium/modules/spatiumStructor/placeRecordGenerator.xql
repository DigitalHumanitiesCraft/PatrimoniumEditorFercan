xquery version "3.1";

module namespace placeRecordGenerator = "http://ausonius.huma-num.fr/placeRecordGenerator";

import module namespace config="https://ausohnum.huma-num.fr/apps/eStudium/config" at "../config.xqm";
import module namespace console="http://exist-db.org/xquery/console";
import module namespace functx="http://www.functx.com";
import module namespace http="http://expath.org/ns/http-client";

import module namespace ausohnumCommons="http://ausonius.huma-num.fr/commons"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/commons/commonsApp.xql";
import module namespace spatiumStructor="http://ausonius.huma-num.fr/spatiumStructor"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/spatiumStructor/spatiumStructor.xql";


declare namespace apc = "https://ausohnum.huma-num.fr/apps/eStudium/onto#";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace dcterms="http://purl.org/dc/terms/";
declare namespace ev = "http://www.w3.org/2001/xml-events";
declare namespace local = "local";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace foaf = "http://xmlns.com/foaf/0.1/";
declare namespace geo = "http://www.w3.org/2003/01/geo/wgs84_pos#";
declare namespace lawd="http://lawd.info/ontology/";
declare namespace pleiades="https://pleiades.stoa.org/places/vocab#";
declare namespace spatial="http://geovocab.org/spatial#";

declare function placeRecordGenerator:recordForDisplay($placeUriShort as xs:string){
let $placeNumber := count($spatiumStructor:project-place-collection//pleiades:Place)
let $placeId := functx:substring-after-last($placeUriShort , "/")

let $placeUriLong := $placeUriShort || "#this"

let $log := console:log("uri: " )
let $currentUser := sm:id()//sm:real/sm:username/string()
let $groups := string-join(sm:get-user-groups($currentUser), ' ')
let $userRights :=
        if (matches($groups, ('sandbox'))) then "sandbox"
        else if(matches($groups, ('patrimonium'))) then "editor"
        else ("guest")
let $gazetteerRecord := $spatiumStructor:placeGazetteer//features[.//uri = normalize-space($placeUriShort)]
let $coordinates := $gazetteerRecord//coordList/coordinates[1]/text()

(:     let $placeRdf := util:eval('collection("' || $spatiumStructor:project-place-collection-path || '")//spatial:Feature[@rdf:about="' || $placeUriLong || '"][1]'):)
   return
   ((<http:response status="200"> 
                    <http:header name="Cache-Control" value="no-cache"/> 
                 </http:response> 
     ),
            if($spatiumStructor:place-collection//spatial:Feature[@rdf:about= $placeUriLong]) then (
               
               let $placeRdf :=  $spatiumStructor:project-place-collection//spatial:Feature[@rdf:about= $placeUriLong]
                  
                  let $isMadeOfUris := if($placeRdf//spatial:Pi) then <uris>{ $placeRdf//spatial:Pi }</uris> else <none/>
                  let $isPartOfUris := if($placeRdf//spatial:P) then <uris> { $placeRdf//spatial:P }</uris> else <none/>
                  let $isInVicinityOfUris := if($placeRdf//spatial:C[@type='isInVicinityOf']) then <uris> { $placeRdf//spatial:C[@type='isInVicinityOf'] }</uris> else <none/>
                  let $hasInItsVicinityUris:= if($placeRdf//spatial:C[@type='hasInItsVicinity']) then <uris> { $placeRdf//spatial:C[@type='hasInItsVicinity'] }</uris> else <none/>
                  let $isAdjacentToUris:= if($placeRdf//spatial:C[@type='isAdjacentTo']) then <uris> { $placeRdf//spatial:C[@type='isAdjacentTo'] }</uris> else <none/>
                  let $placeName := $placeRdf//dcterms:title/text()
                  
                 
                let $hasSize :=if($placeRdf//apc:hasSize) then 
                 <div class="xmlElementGroup">
                                      <div>
                                        {ausohnumCommons:elementLabel("Size", "simple", ())}{ausohnumCommons:displayElement('hasSizeValue', (), 'inLinePlainText', (), ())/string()}
                                        {ausohnumCommons:displayElement('hasSizeType', (), 'inLinePlainText', (), ())}
                                        {if($placeRdf//apc:hasSize/text() != "") then " (" || 
                                        $placeRdf//apc:hasSize/text()
                                        || ")"
                                        else ()
                                        }
                                        </div>
                                        </div>
                        
                    else()
                let $hasYield :=if($placeRdf//apc:hasYield) then 
                 <div class="xmlElementGroup">
                                      {ausohnumCommons:elementLabel("Yield", "simple", ())}{ausohnumCommons:displayElement('hasYieldValue', (), 'inLinePlainText', (), ())/string()}{ausohnumCommons:displayElement('hasYieldType', (), 'inLinePlainText', (), ())/string()}
                                      { if($placeRdf//apc:hasYield/text() != "") then " (" || $placeRdf//apc:hasYield/text() || ")"
                                      else ()
                                      }
                                      <div>
                                     
                                        
                                        
                                        </div>
                                        </div>
                        
                    else()
                
                return
                
                <div id="placeDetails">
                
                <div class="">
                { spatiumStructor:variables($placeUriShort, $spatiumStructor:project) }
                <div id="currentPlaceCoordinates" class="hidden">{ $coordinates }</div>
            <!--    <script type="text/javascript" src="$ausohnum-lib/resources/scripts/spatiumStructor/spatiumStructor.js"/>
                
                  
                  <link href="$ausohnum-lib/resources/css/spatiumStructor.css" rel="stylesheet" type="text/css"/>
                  -->
             <!--
             <link rel="stylesheet" href="$ausohnum-lib/resources/css/teiEditor.css"/>
             -->
             
                <h3 id="resourceTitle"><span>{ $placeId }.</span>{ ausohnumCommons:displayElement('title', (), 'inLinePlainText', (), ()) }</h3>
                <span id="currentPlaceUri" class="hidden">{ $placeUriShort }</span>
                <h4>URI { $placeUriShort } {ausohnumCommons:copyValueToClipboardButton("uri", 1, $placeUriShort)}</h4>
                    <ul class="nav nav-pills" id="pills-tab" role="tablist">
                                         <li class="nav-item active">
                                           <a class="nav-link" id="pills-home-tab" data-toggle="pill" href="#nav-metadata" role="tab" aria-controls="pills-home" aria-selected="false">Place details</a>
                                         </li>
                                         
                                         <li class="nav-item">
                                           <a class="nav-link" id="pills-profile-tab" data-toggle="pill" href="#nav-xmlfile" role="tab" aria-controls="pills-profile" aria-selected="false">XML</a>
                                         </li>
                                     </ul>
                                     <div class="tab-content" id="nav-tabContent">
                                         <div class="tab-pane fade in active" id="nav-metadata" role="tabpanel" aria-labelledby="nav-metadata-tab">
                                                {ausohnumCommons:displayElement('hasFeatureTypeMain', (), 'simple', (), ())                                                 } 
                                                
                                                
                                                { ausohnumCommons:displayElement('altLabel', (), 'simple', (), ()) }
                                                { ausohnumCommons:displayElement('exactMatch', 'External resource(s)', 'simple', (), ()) }
                                                
                                                { ausohnumCommons:displayElement('productionType', (), 'simple', (), ()) }
                                                { $hasSize }
                                                { $hasYield }
                                                { ""
                                                (:ausohnumCommons:temporalRangeAttestations($placeUriShort) :)}
                                                
                                                { spatiumStructor:representativeCoordinates($placeUriShort) }
                                                <div id="temporalScaleListHolder" style="margin-bottom: 1em">
                                                <img id="f-load-indicator" class="" src="$ausohnum-lib/resources/images/ajax-loader.gif" style="margin-right: 1em;"/>... retrieving temporal range of attestations in documents...
                                                </div>
                                                { ausohnumCommons:biblioAndResourcesList($placeRdf, "seeFurther") }
                                                <div id="relatedPlacesListHolder" style="margin-bottom: 1em">
                                                <img id="f-load-indicator" class="" src="$ausohnum-lib/resources/images/ajax-loader.gif" style="margin-right: 1em;"/>... retrieving related places...
                                                </div>
                                                
                                                {""
                                                (:ausohnumCommons:relatedPlacesToPlace($placeUriLong, "isPartOf")
                                                { ausohnumCommons:relatedPlacesToPlace($placeUriLong, "isMadeOf")
                                                { ausohnumCommons:relatedPlacesToPlace($placeUriLong, "isInVicinityOf")
                                                { ausohnumCommons:relatedPlacesToPlace($placeUriLong, "hasInItsVicinity")
                                                { ausohnumCommons:relatedPlacesToPlace($placeUriLong, "isAdjacentTo")
                                                { ausohnumCommons:relatedDocuments($placeUriShort, "place") :)}                                                
                                                <div id="relatedDocumentsListHolder" style="margin-bottom: 1em">
                                                <img id="f-load-indicator" class="" src="$ausohnum-lib/resources/images/ajax-loader.gif" style="margin-right: 1em;"/>... retrieving related documents...
                                                </div>
                                                
                                                <div id="relatedPeopleListHolder" style="margin-bottom: 1em">
                                                <img id="f-load-indicator" class="" src="$ausohnum-lib/resources/images/ajax-loader.gif" style="margin-right: 1em;"/>... retrieving related people...
                                                </div>
                                                {""
(:                                                ausohnumCommons:relatedPeople($placeUriShort, "place") :)
                                                }
                                                
                                                { ausohnumCommons:displayElement('generalCommentary', (), 'simple', (), ()) }
                                                { ausohnumCommons:displayElement('keywords', (), 'simple', (), ()) }
                                           
                                        </div>
                                     <div class="tab-pane fade in" id="nav-xmlfile" role="tabpanel" aria-labelledby="nav-text-tab">
                                          
                                          {
                                          
                                          ausohnumCommons:displayXMLFile($placeUriShort) }
                                            
                                                              
                                      </div>
                                      </div>
                                      </div>
                                      <script>//console.log("Editor required");
                                      
             var editor4File = ace.edit("xmlFile");
                   editor4File.session.setMode("ace/mode/xml");
                   editor4File.setOptions({{
                        readOnly: true,
                         minLines: 40,
                         maxLines: Infinity}});
                         
              function getXmlEditorContent(){{
                     var xmlFileEditor = ace.edit("xmlFile");
                     return xmlFileEditor.getValue();
                      
              }};           
              $(document).ready(function() {{
                $("#temporalScaleListHolder").load("/places/get-temporal-scale/" + {$placeId});
              $("#relatedPlacesListHolder").load("/places/get-related-places/" + {$placeId});
              $("#relatedDocumentsListHolder").load("/places/get-related-documents/" + {$placeId});
              $("#relatedPeopleListHolder").load("/places/get-related-people/" + { $placeId });
              
              }});                                        
             </script>
                </div>
                )
                else (
                <div class="jumbotron jumbotron-fluid">
                        <div class="container">
                          <h1 class="display-4">Error!</h1>
                          <p class="lead">There is no place with URI { $placeUriLong }</p>
                        </div>
                      </div>
                )
 )
 };
 
 declare function placeRecordGenerator:recordForEditing($placeUriShort as xs:string){
let $placeNumber := count($spatiumStructor:project-place-collection//pleiades:Place)
let $placeId := functx:substring-before-last($placeUriShort , "/")

let $placeUriLong := $placeUriShort || "#this"

let $log := console:log("uri: " )
let $currentUser := sm:id()//sm:real/sm:username/string()
let $groups := string-join(sm:get-user-groups($currentUser), ' ')
let $userRights :=
        if (matches($groups, ('sandbox'))) then "sandbox"
        else if(matches($groups, ('patrimonium'))) then "editor"
        else ("guest")

let $placeUriLong := xmldb:decode-uri($placeUriLong)
(:     let $placeRdf := util:eval('collection("' || $spatiumStructor:project-place-collection-path || '")//spatial:Feature[@rdf:about="' || $placeUriLong || '"][1]'):)
   return
   ((<http:response status="200"> 
                    <http:header name="Cache-Control" value="no-cache"/> 
                    <http:header name="TESTUM" value="no-cache"/>
                </http:response> 
     ),
            if($spatiumStructor:place-collection//spatial:Feature[@rdf:about= $placeUriLong]) then (
               
               let $placeRdf :=  $spatiumStructor:project-place-collection//spatial:Feature[@rdf:about= $placeUriLong]
                  
                  let $isMadeOfUris := if($placeRdf//spatial:Pi) then <uris>{ $placeRdf//spatial:Pi }</uris> else <none/>
                  let $isPartOfUris := if($placeRdf//spatial:P) then <uris> { $placeRdf//spatial:P }</uris> else <none/>
                  let $isInVicinityOfUris := if($placeRdf//spatial:C[@type='isInVicinityOf']) then <uris> { $placeRdf//spatial:C[@type='isInVicinityOf'] }</uris> else <none/>
                  let $hasInItsVicinityUris:= if($placeRdf//spatial:C[@type='hasInItsVicinity']) then <uris> { $placeRdf//spatial:C[@type='hasInItsVicinity'] }</uris> else <none/>
                  let $isAdjacentToUris:= if($placeRdf//spatial:C[@type='isAdjacentTo']) then <uris> { $placeRdf//spatial:C[@type='isAdjacentTo'] }</uris> else <none/>
                  let $placeName := $placeRdf//dcterms:title/text()
                  
                 let $relatedDocs := spatiumStructor:relatedDocuments($placeUriShort)
                 
                let $hasSize :=if($placeRdf//apc:hasSize) then 
                 <div class="xmlElementGroup">
                                      <span class="subSectionTitle">Size</span>
                                      <div>
                                        {spatiumStructor:displayElement('hasSizeType', $placeUriLong, (), ())}
                                        {spatiumStructor:displayElement('hasSizeValue', $placeUriLong, (), ())}
                                        {spatiumStructor:displayElement('hasSizeComment', $placeUriLong, (), ())}
                                        </div>
                                        </div>
                        
                    else()
                let $hasYield :=if($placeRdf//apc:hasYield) then 
                 <div class="xmlElementGroup">
                                      <span class="subSectionTitle">Yield</span>
                                      <div>
                                        {spatiumStructor:displayElement('hasYieldType', $placeUriLong, (), ())}
                                        {spatiumStructor:displayElement('hasYieldValue', $placeUriLong, (), ())}
                                        {spatiumStructor:displayElement('hasYieldComment', $placeUriLong, (), ())}
                                        </div>
                                        </div>
                        
                    else()
                
                return
                
                <div id="placeDetails">
            <!--    <script type="text/javascript" src="$ausohnum-lib/resources/scripts/spatiumStructor/spatiumStructor.js"/>
                
                  
                  <link href="$ausohnum-lib/resources/css/spatiumStructor.css" rel="stylesheet" type="text/css"/>
                  -->
             <!--
             <link rel="stylesheet" href="$ausohnum-lib/resources/css/teiEditor.css"/>
             -->
             
                <h3 id="resourceTitle">{ $placeName }</h3>
                <span id="currentPlaceUri" class="hidden">{ $placeUriShort }</span>
                <h4>URI { $placeUriShort }</h4>
                    <ul class="nav nav-pills" id="pills-tab" role="tablist">
                                         <li class="nav-item active">
                                           <a class="nav-link" id="pills-home-tab" data-toggle="pill" href="#nav-metadata" role="tab" aria-controls="pills-home" aria-selected="false">Place details</a>
                                         </li>
                                         
                                         <li class="nav-item">
                                           <a class="nav-link" id="pills-profile-tab" data-toggle="pill" href="#nav-xmlfile" role="tab" aria-controls="pills-profile" aria-selected="false">XML</a>
                                         </li>
                                     </ul>
                                     <div class="tab-content" id="nav-tabContent">
                                         <div class="tab-pane fade in active" id="nav-metadata" role="tabpanel" aria-labelledby="nav-metadata-tab">
                                     
                                                { spatiumStructor:displayElement('title', $placeUriLong, (), ()) }
                                                 { spatiumStructor:displayElement('altLabel', $placeUriLong, (), ()) }
                                                {spatiumStructor:displayElement('exactMatch', $placeUriLong, (), ())}
                                                { spatiumStructor:displayElement('hasFeatureTypeMain', $placeUriLong, (), ()) }
                                                { spatiumStructor:displayElement('productionType', $placeUriLong, (), ()) }
                                                { $hasSize }
                                                { $hasYield }
                                                {spatiumStructor:placeLocation($placeUriLong)}
                                                 { spatiumStructor:isPartOf($placeUriLong, $isPartOfUris)}
                                                { spatiumStructor:placeConnectedWith($placeUriLong, "isInVicinityOf", $isInVicinityOfUris)}
                                                { spatiumStructor:placeConnectedWith($placeUriLong, "hasInItsVicinity", $hasInItsVicinityUris)}
                                                { spatiumStructor:placeConnectedWith($placeUriLong, "isAdjacentTo", $isAdjacentToUris)}
                                                { spatiumStructor:isMadeOf($placeUriLong, $isMadeOfUris)}
                                                
                                                  
                                           { $docs }
                                           {spatiumStructor:relatedPeople($placeUriShort)}
                                           {
                                   spatiumStructor:resourcesManager('seeFurther', $placeUriShort)
                                   }
                                   { spatiumStructor:displayElement('keywords', $placeUriLong, (), ()) }
                                           { spatiumStructor:displayElement('generalCommentary', $placeUriLong, (), ()) }
                                           { spatiumStructor:displayElement('privateCommentary', $placeUriLong, (), ()) }
                                           
                                        </div>
                                     <div class="tab-pane fade in" id="nav-xmlfile" role="tabpanel" aria-labelledby="nav-text-tab">
                                          { spatiumStructor:xmlFileEditorWithUri($placeUriLong) }
                                                              
                                      </div>
                                      </div>
                                      <script>console.log("Editor required");
             var editor4File = ace.edit("xml-editor-file");
                   editor4File.session.setMode("ace/mode/xml");
                   editor4File.setOptions({{
                         minLines: 40,
                         maxLines: Infinity}});
                         
              function getXmlEditorContent(){{
                     var xmlFileEditor = ace.edit("xml-editor-file");
                     return xmlFileEditor.getValue();
                      
              }};           
             </script>
                </div>
                )
                else (
                <div class="jumbotron jumbotron-fluid">
                        <div class="container">
                          <h3 class="display-4">Error!</h3>
                          <p class="lead">There is no Place with URI { $placeUriShort }</p>
                        </div>
                      </div>
                )
 )
 };