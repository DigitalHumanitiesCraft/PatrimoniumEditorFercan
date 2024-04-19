xquery version "3.1";

import module namespace config="http://ausonius.huma-num.fr/ausohnum-library/config" at "../config.xqm";
import module namespace teiEditor="http://ausonius.huma-num.fr/teiEditor"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/teiEditor/teiEditorApp.xql";
import module namespace functx="http://www.functx.com" at "/db/system/repo/functx-1.0/functx/functx.xql";

declare namespace apc = "http://patrimonium.huma-num.fr/onto#";
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

declare variable $teiEditor:project :=request:get-parameter('project', ());

let $now := fn:current-dateTime()
let $currentUser := xmldb:get-current-user()

let $docId := request:get-parameter('docid', '')
let $doc-collection := collection("/db/data/" || $teiEditor:project || "/documents")
let $teiDoc := $doc-collection/id($docId)

(: let $teiElements := doc('/db/apps/ausohnum-library/data/templates/teiElements.xml') :)
(: let $logs := collection("/db/apps/patrimonium/data/logs") :)

(: let $savePanel :=
<div class="sectionPanel">
<button id="saveDocument" class="btn btn-primary editbutton" onclick="javascript:saveData(titleStmt)"
appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-floppy-save"></i></button>
  </div> :)

(: let $title :=
 <div class="">
 <div id="docTitle" class="">{$teiDoc//tei:fileDesc/tei:titleStmt/tei:title/text()}</div>
 <button id="editTitle" class="btn btn-xs btn-primary editbutton" onclick=""
  appearance="minimal" type="button"><i class="glyphicon glyphicon-edit
                              editConceptIcon"></i></button>
 </div> :)

 (: let $titlePanel :=
    <div>
    <input id="titleStmt" class="fullWidth" name="titleStmt" value="{$teiDoc//tei:fileDesc/tei:titleStmt/tei:title/text()}"></input>
    <button id="saveTitleStmt" class="btn btn-primary" onclick="javascript:saveData('{$docId}', titleStmt, 'tei:fileDesc/tei:titleStmt/tei:title')"
            appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-floppy-save"></i></button>
    </div> :)

(:************************:)
(:*     MAIN RETURN      *:)
(:************************:)

return
<div data-template="templates:surround" data-template-with="templates/page-admin.html" data-template-at="content">
        <div
            class="container-fluid">

            <div class="container-fluid">
            <h2 id="docMainTitle">{$teiDoc//tei:titleStmt/tei:title/string()}</h2><h3>Editing Document {$docId}</h3>
            <ul class="nav nav-pills mb-3" id="pills-tab" role="tablist">
                <li class="nav-item active">
                  <a class="nav-link" id="pills-home-tab" data-toggle="pill" href="#nav-metadata" role="tab" aria-controls="pills-home" aria-selected="false">Metadata</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link" id="pills-text-tab" data-toggle="pill" href="#nav-text" role="tab" aria-controls="pills-profile" aria-selected="true">Text</a>
                </li>

                <li class="nav-item">
                  <a class="nav-link" id="pills-profile-tab" data-toggle="pill" href="#nav-xmlfile" role="tab" aria-controls="pills-profile" aria-selected="false">XML file</a>
                </li>
            </ul>

<div class="tab-content" id="nav-tabContent">
    <div class="tab-pane fade in active" id="nav-metadata" role="tabpanel" aria-labelledby="nav-metadata-tab">

        <div class="panel panel-default">
             <div class="panel-heading"  data-toggle="collapse"  href="#titlepanel">Title &amp; Edition</div>
                 <div id="titlepanel" class="panel-collapse collapse in">
                     <div class="panel-body">
                        {teiEditor:displayTeiElement('docTitle', ())}
                        {teiEditor:displayTeiElement('docEditor', ())}
                        {teiEditor:displayTeiElementWithTaxo('docType', ())}
                        {teiEditor:principalBibliography()}
                     </div>
                  </div>
        </div>

        <div class="panel panel-default">
           <div class="panel-heading"  data-toggle="collapse"  href="#placespanel">Object</div>
               <div id="placespanel" class="panel-collapse collapse in">
                  <div class="panel-body">
                    {teiEditor:displayTeiElementWithThesauCardi('docObjectType', 'apcc19310', (), ())}
                    {teiEditor:displayTeiElementWithThesau('docObjectMaterial', 'apcc6200', ())}
                    {teiEditor:docProvenance()}
                  </div>
               </div>
        </div>

        <div class="panel panel-default">
           <div class="panel-heading"  data-toggle="collapse"  href="#metatextpanel">Texts - Placement &amp; layout</div>
               <div id="metatextpanel" class="panel-collapse collapse in">
                  <div class="panel-body">
                        {teiEditor:surfaceManager()}
                        {teiEditor:layoutManager()}
                        {teiEditor:msItemManager()}

                  </div>
               </div>
        </div>


   </div>    <!--End of metadata tab-->




    <div class="tab-pane fade in" id="nav-text" role="tabpanel" aria-labelledby="nav-text-tab">
        <div class="row">
             <div class="col-sm-8 col-md-8 col-lg-8">

                {teiEditor:textEditor()}
             </div>
             <div class="rightToolPane col-sm-4 col-md-4 col-lg-4">
                {teiEditor:annotationMenuSemantic()}
             </div>
        </div>
    </div>
    <div class="tab-pane fade" id="nav-xmlfile" role="tabpanel" aria-labelledby="nav-text-tab">
    <div id="xml-editor-file" class="">
           {serialize($teiDoc, ())}

           </div>
    </div>
    <div id="messageZone"/>


    </div>
    </div>
    </div>
    </div>
