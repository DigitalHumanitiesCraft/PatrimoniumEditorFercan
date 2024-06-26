xquery version "3.1";

import module namespace config="https://ausohnum.huma-num.fr/apps/eStudium/config" at "../config.xqm";
import module namespace teiEditor="http://ausonius.huma-num.fr/teiEditor"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/teiEditor/teiEditorApp.xql";
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

declare option exist:serialize "method=xhtml media-type=text/html
omit-xml-declaration=yes indent=yes";



declare function local:saveData($input as xs:string, $data as xs:string?) as xs:string{
  <a>{$data}</a>
};
declare variable $teiEditor:docId := request:get-parameter('docid', '');

declare variable $teiEditor:project :=request:get-parameter('project', ());
(:declare variable $teiEditor:doc-collection := collection("/db/apps/" || $teiEditor:project || "Data/documents");:)
declare variable $teiEditor:teiDoc := $teiEditor:doc-collection/id($teiEditor:docId);

let $now := fn:current-dateTime()
let $currentUser := sm:id()




(: let $teiElements := doc('/db/apps/ausohnum-library/data/templates/teiElements.xml') :)
(: let $logs := collection("/db/apps/patrimonium/data/logs") :)

(: let $savePanel :=
<div class="sectionPanel">
<button id="saveDocument" class="btn btn-primary editbutton" onclick="javascript:saveData(titleStmt)"
appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-floppy-save"></i></button>
  </div> :)

(: let $title :=
 <div class="">
 <div id="docTitle" class="">{$teiEditor:teiDoc//tei:fileDesc/tei:titleStmt/tei:title/text()}</div>
 <button id="editTitle" class="btn btn-xs btn-primary editbutton" onclick=""
  appearance="minimal" type="button"><i class="glyphicon glyphicon-edit
                              editConceptIcon"></i></button>
 </div> :)

 (: let $titlePanel :=
    <div>
    <input id="titleStmt" class="fullWidth" name="titleStmt" value="{$teiEditor:teiDoc//tei:fileDesc/tei:titleStmt/tei:title/text()}"></input>
    <button id="saveTitleStmt" class="btn btn-primary" onclick="javascript:saveData('{$teiEditor:docId}', titleStmt, 'tei:fileDesc/tei:titleStmt/tei:title')"
            appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-floppy-save"></i></button>
    </div> :)

(:************************:)
(:*     MAIN RETURN      *:)
(:************************:)

return
<div data-template="templates:surround" data-template-with="templates/page.html" data-template-at="content">
    <!-- For Bootstrap 3 -->
  <link rel="stylesheet" href="$ausohnum-lib/resources/scripts/jquery/summernote/summernote.min.css" />
<script src="$ausohnum-lib/resources/scripts/jquery/summernote/summernote.min.js"></script>

  


<div
            class="container-fluid">

            <div class="container-fluid">
            <h2 id="docMainTitle">{$teiEditor:teiDoc/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/text()}
            <!--<span class="pull-right">{teiEditor:displayEditorLabel("editing_document")} {$teiEditor:docId}</span>
            -->
            </h2>
            <h4><span class="pastilleLabelBlue pastilleURI">URI</span>{ teiEditor:buildDocumentUri($teiEditor:docId) }</h4>
            <ul class="nav nav-pills mb-3" id="pills-tab" role="tablist">
                <li class="nav-item active">
                  <a class="nav-link" id="pills-home-tab" data-toggle="pill" href="#nav-metadata" role="tab" aria-controls="pills-home" aria-selected="false">Document overview</a>
                </li>
                <!--
                <li class="nav-item">
                  <a class="nav-link" id="pills-textbearer-tab" data-toggle="pill" href="#nav-textbearer" role="tab" aria-controls="pills-textbearer" aria-selected="false">Support</a>
                </li>
                -->
                <!--
                <li class="nav-item">
                  <a class="nav-link" id="pills-fragments-tab" data-toggle="pill" href="#nav-fragments" role="tab" aria-controls="pills-fragments" aria-selected="false">Object &amp; Fragments</a>
                </li>
                -->
                <!--
                <li class="nav-item">
                  <a class="nav-link" id="pills-text-metadata-tab" data-toggle="pill" href="#nav-text-metadata" role="tab" aria-controls="pills-profile" aria-selected="true">Document overview</a>
                </li>
                -->
                <li class="nav-item">
                  <a class="nav-link" id="pills-text-tab" data-toggle="pill" href="#nav-text" role="tab" aria-controls="pills-profile" aria-selected="true">Text annotation</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link" id="pills-places-tab" data-toggle="pill" href="#nav-places" role="tab" aria-controls="pills-profile" aria-selected="true">Atlas</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link" id="pills-profile-tab" data-toggle="pill" href="#nav-xmlfile" role="tab" aria-controls="pills-profile" aria-selected="false">XML file</a>
                </li>
            </ul>

<div class="tab-content" id="nav-tabContent">
    <div class="tab-pane fade in active" id="nav-metadata" role="tabpanel" aria-labelledby="nav-metadata-tab">
    <div class="row">
        <div class="col-sm-6 col-md-6 col-lg-6">
                        {teiEditor:variables($teiEditor:docId, $teiEditor:project)}
                        {teiEditor:displayElement('docTitle', (), (), ())}
                        {teiEditor:displayElement('docType', (), (), ())}
                        {teiEditor:displayElement('textMainLang', (), (), ())}
                        
                        {teiEditor:bibliographyPanel($teiEditor:docId, "edition")}
                        <h4>Datation</h4>
                       {teiEditor:displayElement('origDateGroup', (), (), ())}
                       {"" 
(:                       teiEditor:displayElement('origDateNote', (), (), ()):)
                       }
                        {"" 
(:                        teiEditor:displayElement('origDateNotBefore', (), (), ()):)
                        }
                        {""
(:                        teiEditor:displayElement('origDateNotAfter', (), (), ()):)
                        }
                        { teiEditor:peopleMentionsInDoc($teiEditor:docId)}
                        {
                        teiEditor:peopleListLight($teiEditor:docId)
                        }
                        
                        {teiEditor:placesList($teiEditor:docId)}
                        
                       <h4>External resources</h4>
                       {teiEditor:displayElement('altIdentifierGroup', (), (), ())} 
                        {""
(:                        teiEditor:displayElement('altIdentifierGroup', (), (), ()):)
                        }
                        
                        {teiEditor:displayElement("tmNumber", (), (), ())}
                        <br/>
                          
                        {teiEditor:bibliographyPanel($teiEditor:docId, "secondary")}
                        
                        <br/>
                        <textarea id="zz_1" class="form-control summernote" name="zz_1"></textarea>
                        
                        {"" 
(:                        teiEditor:displayElement('docKeywords2', (), (), ()) :)
                        }
                        {teiEditor:displayElement("docCommentary", (), (), ())}
                          <br/>
                          {teiEditor:displayElement("privateCommentary", (), (), ())}
                          <br/>
             </div>
        <div class="col-sm-5 col-md-5 col-lg-5">
        
        {teiEditor:textPreview($teiEditor:docId, count($teiEditor:teiDoc//tei:div[@type="edition"]))}
        {teiEditor:displayElement('textPartGroup', (), (), ())}
        </div>
        </div>
    </div><!-- End of tab -->     
<div class="tab-pane fade in" id="nav-textbearer" role="tabpanel" aria-labelledby="nav-textbearer-tab">


                    

   </div>    <!--End of tab-->
            <!--
            <div class="tab-pane fade in" id="nav-fragments" role="tabpanel" aria-labelledby="nav-fragments-tab">
            </div>
            -->
    <div class="tab-pane fade" id="nav-text-metadata" role="tabpanel" aria-labelledby="nav-text-metadata-tab">
                


    </div>

    <div class="tab-pane fade in" id="nav-text" role="tabpanel" aria-labelledby="nav-text-tab">
        <div class="row">
        <div class="sideToolPane col-sm-2 col-md-2 col-lg-2">
                { teiEditor:semanticAnnotation("Subject Indexing", "subject", "rs", "c21849") }
                {teiEditor:annotationPlacePeopleTime()}
                
             </div>
                            <!-- col-sm-8 col-md-8 col-lg-8  -->
             <div id="editorPanel" class="col-sm-10 col-md-10 col-lg-10">

                {teiEditor:textEditor($teiEditor:docId)}
             </div>
             
        </div>
    </div>
    <div class="tab-pane fade in" id="nav-places" role="tabpanel" aria-labelledby="nav-text-tab">
            { teiEditor:placesManager($teiEditor:docId)}
            
    </div>
    <div class="tab-pane fade in" id="nav-xmlfile" role="tabpanel" aria-labelledby="nav-text-tab">
    { teiEditor:xmlFileEditor() }


<!--<div id="xml-editor-file" class="">
           {serialize($teiEditor:teiDoc, ())}

           </div>
           -->
    </div>
    <div id="messageZone"/>


    </div>
    </div>
    </div>
{ teiEditor:searchProjectPeopleModal() }

        


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
<link rel="stylesheet" href="https://leaflet.github.io/Leaflet.markercluster/dist/MarkerCluster.css" />
<link rel="stylesheet" href="https://leaflet.github.io/Leaflet.markercluster/dist/MarkerCluster.Default.css" />
<script src="https://leaflet.github.io/Leaflet.markercluster/dist/leaflet.markercluster-src.js"></script>
<!--  Leaflet Draw  -->
 <!--  <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/Leaflet.draw.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/Leaflet.Draw.Event.js"></script>
    <link rel="stylesheet" href="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/leaflet.draw.css"/>

    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/Toolbar.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/Tooltip.js"></script>

    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/ext/GeometryUtil.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/ext/LatLngUtil.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/ext/LineUtil.Intersect.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/ext/Polygon.Intersect.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/ext/Polyline.Intersect.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/ext/TouchEvents.js"></script>

    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/draw/DrawToolbar.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/draw/handler/Draw.Feature.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/draw/handler/Draw.SimpleShape.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/draw/handler/Draw.Polyline.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/draw/handler/Draw.Marker.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/draw/handler/Draw.Circle.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/draw/handler/Draw.CircleMarker.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/draw/handler/Draw.Polygon.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/draw/handler/Draw.Rectangle.js"></script>


    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/edit/EditToolbar.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/edit/handler/EditToolbar.Edit.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/edit/handler/EditToolbar.Delete.js"></script>

    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/Control.Draw.js"></script>

    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/edit/handler/Edit.Poly.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/edit/handler/Edit.SimpleShape.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/edit/handler/Edit.Rectangle.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/edit/handler/Edit.Marker.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/edit/handler/Edit.CircleMarker.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/edit/handler/Edit.Circle.js"></script>
    -->
    
<script type="text/javascript" src="$ausohnum-lib/resources/scripts/spatiumStructor/L.Control.Geonames.min.js"/> 
<script type="text/javascript" src="$ausohnum-lib/resources/scripts/spatiumStructor/spatiumStructor.js"/>
<link href="$ausohnum-lib/resources/css/spatiumStructor.css" rel="stylesheet" type="text/css"/>
<link href="$ausohnum-lib/resources/css/L.Control.Geonames.css" rel="stylesheet" type="text/css"/>



        <link rel="stylesheet" href="$ausohnum-lib/resources/css/teiEditor.css"/>
        <link href="$ausohnum-lib/resources/css/skosThesau.css" rel="stylesheet" type="text/css"/>
        <link href="$ausohnum-lib/resources/css/editor.css" rel="stylesheet" type="text/css"/>
        
        
        
     

  

        
        <script type="text/javascript" src="$ausohnum-lib/resources/scripts/teiEditor/ancientTextImportRules.js"/>
         <script type="text/javascript" src="$ausohnum-lib/resources/scripts/teiEditor/tei2Html4Preview.js"/>
        <script type="text/javascript" src="$ausohnum-lib/resources/scripts/teiEditor/tei2leiden.js"/>
        <script type="text/javascript" src="$ausohnum-lib/resources/scripts/teiEditor/teiEditorConfig.js"/>
        <script type="text/javascript" src="$ausohnum-lib/resources/scripts/teiEditor/teiEditorEvents.js"/>


  
<script type="text/javascript" >
            window.onbeforeunload = function() {{
                    return "Are you sure you want to navigate away?";}};
        </script>
       
    </div>
