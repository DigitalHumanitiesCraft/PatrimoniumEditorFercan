xquery version "3.1";

import module namespace config="https://ausohnum.huma-num.fr/apps/eStudium/config" at "../config.xqm";
import module namespace teiEditor="http://ausonius.huma-num.fr/teiEditor"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/teiEditor/teiEditorApp.xql";
import module namespace ausohnumCommons="http://ausonius.huma-num.fr/commons"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/commons/commonsApp.xql";

import module namespace functx="http://www.functx.com" at "/db/system/repo/functx-1.0/functx/functx.xql";

import module namespace spatiumStructor="http://ausonius.huma-num.fr/spatiumStructor"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/spatiumStructor/spatiumStructor.xql";


declare namespace apc = "https://ausohnum.huma-num.fr/apps/eStudium/onto#";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace dct = "http://purl.org/dc/terms/";
declare namespace ev = "http://www.w3.org/2001/xml-events";
declare namespace local = "local";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace foaf = "http://xmlns.com/foaf/0.1/";
declare namespace geo = "http://www.w3.org/2003/01/geo/wgs84_pos#";
declare namespace lawd="http://lawd.info/ontology/";

declare option exist:serialize "method=xhtml media-type=text/html
omit-xml-declaration=yes indent=yes";



declare function local:saveData($input as xs:string, $data as xs:string?) as xs:string{
  <a>{$data}</a>
};

let $now := fn:current-dateTime()
let $currentUser := sm:id()
let $docTitle := normalize-space(data(ausohnumCommons:displayElement("docTitle", (), "noLabel", (), ())))
let $updateTitleWindow :=
                        if ($teiEditor:docId != "") then '$(document).ready( function () {{
                document.title = "' || $teiEditor:docId || '" + " - " + "' || $docTitle || '";
                $("#datanavbar-documents").addClass("active");
                }});' 
                    else '$(document).ready( function () {{
                document.title = "' || "APC Documents" || '";
                $("#datanavbar-documents").addClass("active");
                    }});'
let $docType := lower-case(normalize-space(ausohnumCommons:displayElement("docType", (), "nolabel", (), ())))

(:************************:)
(:*     MAIN RETURN      *:)
(:************************:)

return
    if(exists($teiEditor:teiDoc)) then 
    <div data-template="templates:surround" data-template-with="templates/page-apc.html" data-template-at="content">

      <link rel="stylesheet" href="$ausohnum-lib/resources/scripts/jquery/summernote/summernote.min.css" />
      <script src="$ausohnum-lib/resources/scripts/jquery/summernote/summernote.min.js"></script>

       <div class="container">
            <div class="row" data-template="app:navBar"/>
        </div>
    <div class="row">
        <div class="container-fluid" style="padding: 0 3em 0 3em">
        {ausohnumCommons:variables($ausohnumCommons:docId, $ausohnumCommons:project, $docType) }
            <h2 id="docMainTitle">{$docTitle}</h2>
            <h4><span class="labelBlue labelURI">URI</span>{ teiEditor:buildDocumentUri($teiEditor:docId) }
            {ausohnumCommons:copyValueToClipboardButton("uri", 1, teiEditor:buildDocumentUri($teiEditor:docId) )}</h4>
         <ul class="nav nav-pills mb-3" id="pills-tab" role="tablist">
                <li class="nav-item active">
                  <a class="nav-link" id="pills-home-tab" data-toggle="pill" href="#nav-metadata" role="tab" aria-controls="pills-home" aria-selected="false">Document overview</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link" id="pills-profile-tab" data-toggle="pill" href="#nav-xmlfile" role="tab" aria-controls="pills-profile" aria-selected="false">XML file</a>
                </li>
           </ul>
         <div class="tab-content" id="nav-tabContent">
            <div class="tab-pane fade in active" id="nav-metadata" role="tabpanel" aria-labelledby="nav-metadata-tab">
                <div class="row">
                    <div class="col-sm-9 col-md-9 col-lg-9">
                    { ausohnumCommons:displayElement("docType", (), "simple", (), ())}
                    { ausohnumCommons:biblioAndResourcesList($teiEditor:teiDoc, "edition")}
                    
                    { ausohnumCommons:displayElement("altIdentifierValue", "See also", "simple", (), ())}
                    
                    { ausohnumCommons:displayElement("origDateGroupNote", (), "groupParent-simple", (), ())}
                    
                    { ausohnumCommons:documentProvenance()}
                    <!-- CP: -->
                    <!-- { ausohnumCommons:textPreviewWithEpidocStylesheet($docType) } -->
                    { ($docType) }
                    <br/>
                    { ausohnumCommons:biblioAndResourcesList($teiEditor:teiDoc, "secondary")}
                    { ausohnumCommons:displayElement("docCommentary", (), "simple", (), ())}
                    { ausohnumCommons:getDocumentKeywords()}
                    </div>
                    <div class="col-sm-3 col-md-3 col-lg-3 rightSideBorder">
                    { ausohnumCommons:placesInDoc() }
                    { ausohnumCommons:placesList() }
                    { ausohnumCommons:peopleList() }
                    </div>
                </div>
            </div>
            
            <div class="tab-pane fade in" id="nav-xmlfile" role="tabpanel" aria-labelledby="nav-text-tab">
                { ausohnumCommons:displayXMLFile(()) }
                
            </div>
            <script>  $("#logoForMenu").removeClass("hidden");
            if($("#apcMenu").hasClass("active")){{}} else{{$("#apcMenu").addClass("active");}}
        </script>
         </div>
         
         
         
         
         
         
         </div>
         
        </div>
                <script></script>
        <script type="text/javascript">{ $updateTitleWindow }</script>
        <link rel="stylesheet" href="https://unpkg.com/leaflet@1.4.0/dist/leaflet.css"
            integrity="sha512-puBpdR0798OZvTTbP4A8Ix/l+A4dHDD0DGqYW6RQ+9jxkRFclaxxQb/SJAWZfWAkuyeQUytO7+7N4QKrDh+drA=="
            crossorigin=""/>
            
        <!-- Make sure you put this AFTER Leaflet's CSS -->
        <script src="https://unpkg.com/leaflet@1.4.0/dist/leaflet.js"
   integrity="sha512-QVftwZFqvtRNi0ZyCtsznlKSWOStnDORoefr1enyq5mVL4tmKB3S/EnC3rRJcxCPavG10IcrVGSmPh6Qw5lwrg=="
   crossorigin=""></script>
        <script src="https://unpkg.com/leaflet@1.0.3/dist/leaflet-src.js" integrity="sha512-WXoSHqw/t26DszhdMhOXOkI7qCiv5QWXhH9R7CgvgZMHz1ImlkVQ3uNsiQKu5wwbbxtPzFXd1hK4tzno2VqhpA==" crossorigin=""></script>
        
          <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet-providers.js"></script>
           <link rel="stylesheet" href="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet-search.css"/>
           
          <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet-search.js"></script>
          
          
         <!--Markercluster -->
        <!--<link rel="stylesheet" href="https://leaflet.github.io/Leaflet.markercluster/dist/MarkerCluster.css" />
        <link rel="stylesheet" href="https://leaflet.github.io/Leaflet.markercluster/dist/MarkerCluster.Default.css" />
        <script src="https://leaflet.github.io/Leaflet.markercluster/dist/leaflet.markercluster-src.js"></script>
        -->
        <link rel="stylesheet" href="$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet.markerCluster1.4.1/MarkerCluster.css" />
        <link rel="stylesheet" href="$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet.markerCluster1.4.1/MarkerCluster.Default.css" />
        <script src="$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet.markerCluster1.4.1/leaflet.markercluster.js"></script>
         <script src="$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet.featuregroup.subgroup.js"></script>
        
        <script type="text/javascript" src="$ausohnum-lib/resources/scripts/spatiumStructor/L.Control.Geonames.min.js"/> 
        <script type="text/javascript" src="$ausohnum-lib/resources/scripts/spatiumStructor/spatiumStructor.js"/>
        
        <link href='$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.fullscreen/leaflet.fullscreen.css' rel='stylesheet' />
        <script src='$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.fullscreen/Leaflet.fullscreen.min.js'></script>
  
        <link href="$ausohnum-lib/resources/css/L.Control.Geonames.css" rel="stylesheet" type="text/css"/>
        <link rel="stylesheet" href="$ausohnum-lib/resources/css/teiEditor.css"/>
        <link href="$ausohnum-lib/resources/css/skosThesau.css" rel="stylesheet" type="text/css"/>
        <link href="/resources/css/document-publisher.css" rel="stylesheet" type="text/css"/>
        <script type="text/javascript" src="$ausohnum-lib/resources/scripts/teiEditor/ancientTextImportRules.js"/>
         <script type="text/javascript" src="$ausohnum-lib/resources/scripts/teiEditor/tei2Html4Preview.js"/>
        <script type="text/javascript" src="$ausohnum-lib/resources/scripts/teiEditor/tei2leiden.js"/>
        <link href="$ausohnum-lib/resources/css/ausohnumCommons.css" rel="stylesheet" type="text/css"/>
        <script type="text/javascript" src="$ausohnum-lib/resources/scripts/ausohnumCommons/ausohnumCommons.js"/>
       <!-- <script type="text/javascript" src="$ausohnum-lib/resources/scripts/teiEditor/teiEditorConfig.js"/>
        <script type="text/javascript" src="$ausohnum-lib/resources/scripts/teiEditor/teiEditorEvents.js"/>
-->
 
</div>

else
 <div data-template="templates:surround" data-template-with="templates/page-apc.html" data-template-at="content">
     <div class="container">
        <div class="row" data-template="app:navBar"/>
             <div class="jumbotron jumbotron-fluid">
                <div class="container">
                  <h3 class="display-4">Error!</h3>
                  <p class="lead">There is no document with ID { $teiEditor:docId }</p>
                </div>
              </div>
    </div>
 </div>