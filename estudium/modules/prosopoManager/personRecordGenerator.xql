xquery version "3.1";

module namespace personRecordGenerator = "http://ausonius.huma-num.fr/personRecordGenerator";

import module namespace config="https://ausohnum.huma-num.fr/apps/eStudium/config" at "../config.xqm";
import module namespace console="http://exist-db.org/xquery/console";
import module namespace functx="http://www.functx.com";
import module namespace http="http://expath.org/ns/http-client";

import module namespace ausohnumCommons="http://ausonius.huma-num.fr/commons"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/commons/commonsApp.xql";
import module namespace prosopoManager="http://ausonius.huma-num.fr/prosopoManager"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/prosopoManager/prosopoManager.xql";

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
(:declare namespace spatial="http://geovocab.org/spatial#";:)

declare variable $personRecordGenerator:lang := request:get-parameter("lang", ());

declare function personRecordGenerator:recordForDisplay($personUriShort as xs:string){
(:    let $personUriShort := $prosopoManager:uriBasePeople  || $personRecordGenerator:resourceUri:)
    let $currentUser := sm:id()//sm:real/sm:username/string()
    let $groups := string-join(sm:get-user-groups($currentUser), ' ')
    let $userRights :=
            if (matches($groups, ('sandbox'))) then "sandbox"
            else if(matches($groups, ('patrimonium'))) then "editor"
            else ("guest")
    let $personUriLong := $personUriShort || "#this"
    let $personId := functx:substring-after-last($personUriShort, "/")

return
if($prosopoManager:peopleCollection//lawd:person[@rdf:about= $personUriLong]) then (
          let $personRecord :=  $prosopoManager:peopleCollection//lawd:person[@rdf:about= $personUriLong]
          let $updateTitleWindow :=
                        if ($personId != "") then '$(document).ready( function () {{
                document.title = "Person ' || $personId || ' - ' || normalize-space(ausohnumCommons:displayElement('standardizedName', (), 'inLinePlainText', (), ())) || '";
                    }});' 
                    else '$(document).ready( function () {{
                document.title = "' || "APC Person" || '";
                    }});'

          return

    <div>
    <h3 id="resourceTitle"><span>{ $personId }.</span>{ ausohnumCommons:displayElement('standardizedName', (), 'inLinePlainText', (), ()) }</h3>
                    <span id="currentPlaceUri" class="hidden">{ $personUriShort }</span>
                    <h4>URI { $personUriShort } {ausohnumCommons:copyValueToClipboardButton("uri", 1, $personUriShort)}</h4>
                    <ul class="nav nav-pills" id="pills-tab" role="tablist">
                                         <li class="nav-item active">
                                           <a class="nav-link" id="pills-home-tab" data-toggle="pill" href="#nav-metadata" role="tab" aria-controls="pills-home" aria-selected="false">Person details</a>
                                         </li>
                                         
                                         <li class="nav-item">
                                           <a class="nav-link" id="pills-profile-tab" data-toggle="pill" href="#nav-xmlfile" role="tab" aria-controls="pills-profile" aria-selected="false">XML</a>
                                         </li>
                 </ul>
                 <div class="tab-content" id="nav-tabContent">
                       <div class="tab-pane fade in active" id="nav-metadata" role="tabpanel" aria-labelledby="nav-metadata-tab">
                                  { ausohnumCommons:displayElement('sex', (), 'simple', (), ()) }
                                  { ausohnumCommons:displayElement('personalStatus', (), 'simple', (), ()) }
                                  { ausohnumCommons:displayElement('socialStatus', (), 'simple', (), ()) }
                                  { ausohnumCommons:displayElement('juridicalStatus', (), 'simple', (), ()) }
                                  { ausohnumCommons:displayElement('exactMatches', 'External resource(s)', 'simple', (), ()) }
                                  { ausohnumCommons:temporalRangeAttestations($personUriShort) }
                                  { ausohnumCommons:relatedDocuments($personUriShort, "people") }
                                  { ausohnumCommons:relatedPeopleToPerson($personUriLong)}
                                  { ausohnumCommons:personFuntions($personUriLong)}
                                  { ausohnumCommons:biblioAndResourcesList($personRecord, "seeFurther") }
                                  { ausohnumCommons:displayElement('generalCommentary', (), 'simple', (), ()) }
                       </div>
                       <div class="tab-pane fade in" id="nav-xmlfile" role="tabpanel" aria-labelledby="nav-text-tab">
                                          { 
                                          ausohnumCommons:displayXMLFile($personUriShort) }
                                          
                       </div>
                </div>         
        <link rel="stylesheet" href="https://unpkg.com/leaflet@1.0.3/dist/leaflet.css" integrity="sha512-07I2e+7D8p6he1SIM+1twR5TIrhUQn9+I6yjqD53JQjFiMf8EtC93ty0/5vJTZGF8aAocvHYNEDJajGdNx1IsQ==" crossorigin="" />
        <script src="https://unpkg.com/leaflet@1.0.3/dist/leaflet-src.js" integrity="sha512-WXoSHqw/t26DszhdMhOXOkI7qCiv5QWXhH9R7CgvgZMHz1ImlkVQ3uNsiQKu5wwbbxtPzFXd1hK4tzno2VqhpA==" crossorigin=""></script>
        <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet-providers.js"></script>
        <link rel="stylesheet" href="$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet-search/src/leaflet-search.css"/>
         <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet-search/src/leaflet-search.js"></script>
        <link href='$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.fullscreen/leaflet.fullscreen.css' rel='stylesheet' />
        <script src='$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.fullscreen/Leaflet.fullscreen.min.js'></script>
       <!--Markercluster -->
       <link rel="stylesheet" href="https://leaflet.github.io/Leaflet.markercluster/dist/MarkerCluster.css" />
       <link rel="stylesheet" href="https://leaflet.github.io/Leaflet.markercluster/dist/MarkerCluster.Default.css" />
       <script src="https://leaflet.github.io/Leaflet.markercluster/dist/leaflet.markercluster-src.js"></script>
        <script type="text/javascript" src="$ausohnum-lib/resources/scripts/spatiumStructor/L.Control.Geonames.min.js"/>

        <!--<link href="$ausohnum-lib/resources/css/spatiumStructor.css" rel="stylesheet" type="text/css"/>-->
        
       <!-- <script type="text/javascript" src="$ausohnum-lib/resources/scripts/spatiumStructor/spatiumStructor.js"/>
        -->
  
        <script type="text/javascript">{ $updateTitleWindow }
           var editor4File = ace.edit("xmlFile");
                   editor4File.session.setMode("ace/mode/xml");
                   editor4File.setOptions({{
                        readOnly: true,
                         minLines: 40,
                         maxLines: Infinity}});
        </script>

    
</div>                
            )
            else(
            <div class="jumbotron jumbotron-fluid">
                        <div class="container">
                          <h3 class="display-4">Error!</h3>
                          <p class="lead">There is no Person with URI { $personUriShort }</p>
                        </div>
                      </div>
            )

};