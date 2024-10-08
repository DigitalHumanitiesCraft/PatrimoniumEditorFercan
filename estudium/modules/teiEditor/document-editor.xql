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
declare namespace foaf = "http://xmlns.com/foaf/0.1/";
declare namespace geo = "http://www.w3.org/2003/01/geo/wgs84_pos#";
declare namespace lawd="http://lawd.info/ontology/";

declare option exist:serialize "method=xhtml media-type=text/html
omit-xml-declaration=yes indent=yes";



declare function local:saveData($input as xs:string, $data as xs:string?) as xs:string{
  <a>{$data}</a>
};
(:declare variable $teiEditor:docId := request:get-parameter('docid', '');:)

(:declare variable $teiEditor:project :=request:get-parameter('project', ());:)
(:declare variable $teiEditor:doc-collection := collection("/db/apps/" || $teiEditor:project || "Data/documents");:)
(:declare variable $teiEditor:teiDoc := $teiEditor:doc-collection/id($teiEditor:docId);:)

let $now := fn:current-dateTime()
let $currentUser := sm:id()


(:************************:)
(:*     MAIN RETURN      *:)
(:************************:)

return
<div data-template="templates:surround" data-template-with="templates/page.html" data-template-at="content">

  <link rel="stylesheet" href="$ausohnum-lib/resources/scripts/jquery/summernote/summernote.min.css" />
<script src="https://cdn.jsdelivr.net/npm/summernote@0.8.18/dist/summernote.min.js"></script>

  


<div
            class="container-fluid">

            <div class="container-fluid">
            <h2 id="docMainTitle">{$teiEditor:teiDoc/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/text()}
            <!--<span class="pull-right">{teiEditor:displayEditorLabel("editing_document")} {$teiEditor:docId}</span>
            -->
            </h2>
            <h4><span class="pastilleLabelBlue pastilleURI">URI</span><span id="uri_pid">{ teiEditor:buildDocumentUri($teiEditor:docId)}</span></h4>


            <ul class="nav nav-pills mb-3" id="pills-tab" role="tablist">
                <li class="nav-item active">
                  <a class="nav-link" id="pills-home-tab" data-toggle="pill" href="#nav-metadata" role="tab" aria-controls="pills-home" aria-selected="false">Document overview</a>
                </li>

                <li class="nav-item">
                  <a class="nav-link" id="pills-text-tab" data-toggle="pill" href="#nav-text" role="tab" aria-controls="pills-profile" aria-selected="true">Text annotation</a>
                </li>
                <!--
                <li class="nav-item">
                  <a class="nav-link" id="pills-places-tab" data-toggle="pill" href="#nav-places" role="tab" aria-controls="pills-profile" aria-selected="true">Atlas</a>
                </li>
                -->
                <li class="nav-item">
                  <a class="nav-link" id="pills-profile-tab" data-toggle="pill" href="#nav-xmlfile" role="tab" aria-controls="pills-profile" aria-selected="false">XML file</a>
                </li>
            </ul>

<div class="tab-content" id="nav-tabContent">
    <div class="tab-pane fade in active" id="nav-metadata" role="tabpanel" aria-labelledby="nav-metadata-tab">
    <div class="row">
      <div class="col-sm-6 col-md-6 col-lg-6">
        {teiEditor:variables($teiEditor:docId, $teiEditor:project)}
        <h3>Titel</h3>
        {teiEditor:displayElement('docTitle', (), (), ())}
        {teiEditor:displayElement('subTitle', (), (), ())}
        {teiEditor:displayElement('civitas', (), (), ())}
        <div class="bg-info" style="margin: 10px; padding-left: 50px;" id="civitas_note_collapse">
          {teiEditor:displayElement('civitas_note', (), (), ())}
        </div>
        <p class="bg-info" style="margin: 10px; padding-left: 50px;"><![CDATA[&lt;]]> = &lt; | <![CDATA[&gt;]]> = &gt;</p>
        {teiEditor:displayElement('Appcrit', (), (), ())}
        <div class="bg-info" style="margin: 10px; padding-left: 50px;" id="Appcrit_note_collapse">
              {teiEditor:displayElement('Appcrit_note', (), (), ())}
        </div>
        <h3>Autopsie und Editionen</h3>
        {teiEditor:displayElement('Autopsie', (), (), ())}
        <div class="bg-info" style="margin: 10px; padding-left: 50px;" id="Autopsie_note_collapse">
           {teiEditor:displayElement('Autopsie_note', (), (), ())}
        </div>
        {teiEditor:displayElement('Editionen', (), (), ())}
        <div class="bg-info" style="margin: 10px; padding-left: 50px;" id="Editionen_note_collapse">
           {teiEditor:displayElement('Editionen_note', (), (), ())}
        </div>
        <h3>Elektronische Ressourcen</h3>
        {teiEditor:displayElement('EDH', (), (), ())} 
        {teiEditor:displayElement('Lupa', (), (), ())}
        {teiEditor:displayElement('ClaussSlaby', (), (), ())}
        {teiEditor:displayElement('trismegistos', (), (), ())}
        {teiEditor:displayElement('other', (), (), ())}
        <div class="bg-info" style="margin: 10px; padding-left: 50px;" id="Editionen_note_collapse">
           {teiEditor:displayElement('ElektronischeRessourcen_note', (), (), ())}
        </div>
        <h3>Übersetzungen</h3>
        {teiEditor:displayElement('dtUEbers', (), (), ())}
        <div class="bg-info" style="margin: 10px; padding-left: 50px;" id="dtUEbers_note_collapse">
         {teiEditor:displayElement('dtUEbers_note', (), (), ())}
        </div>
        {teiEditor:displayElement('englUEbers', (), (), ())}
        <div class="bg-info" style="margin: 10px; padding-left: 50px;" id="englUEbers_note_collapse">
          {teiEditor:displayElement('englUEbers_note', (), (), ())}
        </div>
        <h3>Abbildungen</h3>
        <p class="bg-info" style="margin: 10px; padding-left: 50px;">Eingabe für 'MIME-Type': image/jpeg , image/png .</p>
        {teiEditor:displayElement('Abb', (), (), ())}
        <div class="bg-info" style="margin: 10px; padding-left: 50px;" id="Abb_note_collapse">
           {teiEditor:displayElement('Abb_note', (), (), ())}
        </div>
        <h3>Fund</h3>
        {teiEditor:displayElement('FOantik', (), (), ())}
        <div class="bg-info" style="margin: 10px; padding-left: 50px;" id="FOantik_note_collapse">
          {teiEditor:displayElement('FOantik_note', (), (), ())}
        </div>
        {teiEditor:displayElement('FOmodern', (), (), ())}
        <div class="bg-info" style="margin: 10px; padding-left: 50px;" id="FOmodern_note_collapse">
           {teiEditor:displayElement('FOmodern_note', (), (), ())}
        </div>
        {teiEditor:displayElement('Fundstelle', (), (), ())}
        <div class="bg-info" style="margin: 10px; padding-left: 50px;" id="Fundstelle_not_collapse">
          {teiEditor:displayElement('Fundstelle_note', (), (), ())}
        </div>
        {teiEditor:displayElement('Fundumst', (), (), ())}
        <div class="bg-info" style="margin: 10px; padding-left: 50px;" id="Fundumst_note_collapse">
           {teiEditor:displayElement('Fundumst_note', (), (), ())}
        </div>
        {teiEditor:displayElement('Fundjahr', (), (), ())}
        <div class="bg-info" style="margin: 10px; padding-left: 50px;" id="Fundjahr_note_collapse">
          {teiEditor:displayElement('Fundjahr_note', (), (), ())}
        </div>
        <h3>Verwahrung</h3>
        {teiEditor:displayElement('VerwahrortOrt', (), (), ())}
        <div class="bg-info" style="margin: 10px; padding-left: 50px;" id="VerwahrortOrt_note_collapse">
            {teiEditor:displayElement('VerwahrortOrt_note', (), (), ())}
        </div>
        {teiEditor:displayElement('VerwahrortInstitution', (), (), ())}
        {teiEditor:displayElement('InvNr', (), (), ())}
        <div class="bg-info" style="margin: 10px; padding-left: 50px;" id="InvNr_note_collapse">
          {teiEditor:displayElement('InvNr_note', (), (), ())}
        </div>
        <h3>Objektbeschreibung</h3>
        {teiEditor:displayElement('Inschrifttraeger', (), (), ())}
        <div class="bg-info" style="margin: 10px; padding-left: 50px;" id="Inschrifttraeger_note_collapse">
            {teiEditor:displayElement('Inschrifttraeger_note', (), (), ())}
        </div>
        {teiEditor:displayElement('Material', (), (), ())}
        <div class="bg-info" style="margin: 10px; padding-left: 50px;" id="Material_note_collapse">
            {teiEditor:displayElement('Material_note', (), (), ())}
        </div>
        {teiEditor:displayElement('ArchKlass', (), (), ())}
        <div class="bg-info" style="margin: 10px; padding-left: 50px;" id="ArchKlass_note_collapse">
           {teiEditor:displayElement('ArchKlass_note', (), (), ())}
        </div>
        {teiEditor:displayElement('Objbeschr', (), (), ())}
        <div class="bg-info" style="margin: 10px; padding-left: 50px;" id="Objbeschr_note_collapse">
           {teiEditor:displayElement('Objbeschr_note', (), (), ())}
        </div>
        <p class="bg-info" style="margin: 10px; padding-left: 50px;">Auswahl aus: vollständig, weitgehend vollständig, größere Fehlstelle/n, größeres Fragment, kleineres Fragment, unklar, unzusammenhängende Fragmente</p>
        {teiEditor:displayElement('ErhzustObj', (), (), ())}
        <div class="bg-info" style="margin: 10px; padding-left: 50px;" id="ErhzustObj_note_collapse">
           {teiEditor:displayElement('ErhzustObj_note', (), (), ())}
        </div>
        <h4>Maße Objekt</h4>
        {teiEditor:displayElement('Hoehe', (), (), ())}
        {teiEditor:displayElement('Breite', (), (), ())}
        {teiEditor:displayElement('Tiefe', (), (), ())}
        {teiEditor:displayElement('MasseKommentar', (), (), ())}
        <div class="bg-info" style="margin: 10px; padding-left: 50px;" id="Masse_note_collapse">
                {teiEditor:displayElement('Masse_note', (), (), ())}
        </div>
        <p class="bg-info" style="margin: 10px; padding-left: 50px;"> </p>
        {teiEditor:displayElement('Ikonogr', (), (), ())}
        <div class="bg-info" style="margin: 10px; padding-left: 50px;" id="Ikonogr_note_collapse">
           {teiEditor:displayElement('Ikonogr_note', (), (), ())}
        </div>
        {teiEditor:displayElement('Inschrtext', (), (), ())}
        <div class="bg-info" style="margin: 10px; padding-left: 50px;" id="Inschrtext_note_collapse">
           {teiEditor:displayElement('Inschrtext_note', (), (), ())}
        </div>
        <p class="bg-info" style="margin: 10px; padding-left: 50px;">
        Auswahl aus: 
        <br/>vollständig = https://gams.uni-graz.at/o:fercan.arch#C.130400
        <br/>weitgehend vollständig = C.130500 
        <br/>größere Fehlstelle/n = C.130600
        <br/>größeres Fragment = C.130310
        <br/>kleineres Fragment = C.130320 
        <br/>unklar = C.130700
        <br/>unzusammenhängende Fragmente = C.130330</p>
        {teiEditor:displayElement('ErhzustInschr', (), (), ())}
        <div class="bg-info" style="margin: 10px; padding-left: 50px;" id="ErhzustInschr_note_collapse">
           {teiEditor:displayElement('ErhzustInschr_note', (), (), ())}
        </div>
        {teiEditor:displayElement('Schrifttechnik', (), (), ())}
        <div class="bg-info" style="margin: 10px; padding-left: 50px;" id="Schrifttechnik_note_collapse">
          {teiEditor:displayElement('Schrifttechnik_note', (), (), ())}
        </div>
        <p class="bg-info" style="margin: 10px; padding-left: 50px;">Eingabe: 2,3–5,1 cm</p>
        {teiEditor:displayElement('Buchsthoehe', (), (), ())}
        <div class="bg-info" style="margin: 10px; padding-left: 50px;" id="Buchsthoehe_note_collapse">
               {teiEditor:displayElement('Buchsthoehe_note', (), (), ())}
        </div>
        <h3>Kommentare</h3>
        {teiEditor:displayElement('Notvar', (), (), ())}
        <div class="bg-info" style="margin: 10px; padding-left: 50px;" id="Notvar_note_collapse">
           {teiEditor:displayElement('Notvar_note', (), (), ())}
        </div>
        {teiEditor:displayElement('KommGoettern', (), (), ())}
        <div class="bg-info" style="margin: 10px; padding-left: 50px;" id="KommGoettern_note_collapse">
          {teiEditor:displayElement('KommGoettern_note', (), (), ())}
        </div>
        {teiEditor:displayElement('SonstKomm', (), (), ())}
        <div class="bg-info" style="margin: 10px; padding-left: 50px;" id="SonstKomm_note_collapse">
          {teiEditor:displayElement('SonstKomm_note', (), (), ())}
        </div>
        <h3>Datierung</h3>
        {teiEditor:displayElement('Datierung', (), (), ())}
        <div class="bg-info" style="margin: 10px; padding-left: 50px;" id="Datierung_note_collapse">
          {teiEditor:displayElement('Datierung_note', (), (), ())}
        </div>
        <h4>Datierung ISO</h4>
        {teiEditor:displayElement('DatISO_notAfter', (), (), ())}
        {teiEditor:displayElement('DatISO_notBefore', (), (), ())}
        <h3>Index Liste</h3>
        <p class="bg-info" style="margin: 10px; padding-left: 50px;">Mehrfache Zuordnung durch Trennung mittels ";": "Borvoboendoa; Cobba"</p>
        {teiEditor:displayElement('keltischesGoetternamenelement', (), (), ())}
        {teiEditor:displayElement('GeographischeBezeichnungantik', (), (), ())}
        {teiEditor:displayElement('Bevoelkerungsgruppe', (), (), ())}
        {teiEditor:displayElement('Verwaltungseinheit', (), (), ())}
        {teiEditor:displayElement('MilitaerischeEinheit', (), (), ())}
        {teiEditor:displayElement('MilitaerischeDienstgrade', (), (), ())}
        {teiEditor:displayElement('Gentilnomen', (), (), ())}
        {teiEditor:displayElement('Cognomen', (), (), ())}
        {teiEditor:displayElement('Kultfuktionaere', (), (), ())}
        {teiEditor:displayElement('Kultbauten', (), (), ())}
        {teiEditor:displayElement('Inschriftenformel', (), (), ())}
        {teiEditor:displayElement('ReligionSonstiges', (), (), ())}
        {teiEditor:displayElement('Herrscher', (), (), ())}
        {teiEditor:displayElement('Amtstraeger', (), (), ())}
        {teiEditor:displayElement('StatusSonstiges', (), (), ())}
        {teiEditor:displayElement('DatierungsangabenimISText', (), (), ())}
        {teiEditor:displayElement('BesondereZeichen', (), (), ())}
        {teiEditor:displayElement('SonstigeBesonderheiten', (), (), ())}
        {teiEditor:displayElement('Belegformgesamt', (), (), ())}
        {teiEditor:displayElement('TheonymischesFormular', (), (), ())}
        {teiEditor:displayElement('SonstigeTheonymischesFormular', (), (), ())}
        <div class="bg-info" style="margin: 10px; padding-left: 50px;" id="Datierung_note_collapse">
          {teiEditor:displayElement('Index_note', (), (), ())}
        </div>


        <!--
        <h3>Listen</h3>
        {teiEditor:placesList($teiEditor:docId)}
        {teiEditor:peopleList($teiEditor:docId)}
        -->
      </div>
        <div class="col-sm-5 col-md-5 col-lg-5" style="position: -webkit-sticky; position: sticky; top: 0;">
          <h3>Preview</h3>
          <p>Um eine Vorschau des Textes zu erhalten, muss im Feld "XML Editor 1" unter "Text annotation" eine Bearbeitung durchführen, um die Vorschau zu aktivieren. </p>
          
          <!--
          <div id="PID_display_1_1" class="teiElementGroup">
          
          <div class="TeiElementGroupHeaderInline">
            <span class="labelForm">GAMS PID 
              <span class="teiInfo">
                <a title="TEI element: /tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type=&#34;PID&#34;]">
                  <i class="glyphicon glyphicon glyphicon-info-sign"></i>
                </a>
              </span>
            </span>
          </div>

          <div id="PID_value_1_1" class="teiElementValue" style="">
            <span>{$teiEditor:teiDoc//tei:fileDesc/tei:publicationStmt/tei:idno[@type="PID"]}</span>
          </div>
          
        </div>
        -->
        <!--
        <div id="text_preview" class="row">
          <p></p>
        </div>
        -->
        {teiEditor:textPreview($teiEditor:docId, count($teiEditor:teiDoc//tei:div[@type="edition"]))}
        </div>
        </div>
    </div><!-- End of tab -->     
    <div class="tab-pane fade in" id="nav-textbearer" role="tabpanel" aria-labelledby="nav-textbearer-tab">

   </div>    <!--End of tab-->

    <div class="tab-pane fade" id="nav-text-metadata" role="tabpanel" aria-labelledby="nav-text-metadata-tab">

    </div>

    <div class="tab-pane fade in" id="nav-text" role="tabpanel" aria-labelledby="nav-text-tab">
        <div class="row">
          <!-- CP: removed -->
          <!--
          <div class="sideToolPane col-sm-2 col-md-2 col-lg-2">
          {teiEditor:semanticAnnotation("Subject Indexing", "subject", "rs", "c21849") }
          {teiEditor:annotationPlacePeopleTime()}
          </div>
          -->
          <!-- col-sm-8 col-md-8 col-lg-8 -->
          <div id="editorPanel" class="col-sm-12 col-md-12 col-lg-12">
            {teiEditor:textEditor($teiEditor:docId, ())}
          </div> 
        </div>
    </div>
    <div class="tab-pane fade in" id="nav-places" role="tabpanel" aria-labelledby="nav-text-tab">
      {teiEditor:placesManager($teiEditor:docId)}
    </div>
    <div class="tab-pane fade in" id="nav-xmlfile" role="tabpanel" aria-labelledby="nav-text-tab">
      {teiEditor:xmlFileEditor()}
      <!--<div id="xml-editor-file" class="">
            {serialize($teiEditor:teiDoc, ())}
           </div>
           -->
    </div>
    <div id="messageZone"/>


    </div>
    </div>
    </div>
<!-- CP: removed -->
<!-- { teiEditor:searchProjectPeopleModal() }-->

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
