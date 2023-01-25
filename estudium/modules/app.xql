xquery version "3.1";

module namespace app="https://ausohnum.huma-num.fr/apps/eStudium/templates";
import module namespace i18n='http://exist-db.org/xquery/i18n' at "lib/i18n.xql";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="https://ausohnum.huma-num.fr/apps/eStudium/config" at "config.xqm";
import module namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/" at "/db/apps/ausohnum-library/modules/skosThesau/skosThesauApp.xql";
import module namespace http="http://expath.org/ns/http-client" at "java:org.expath.exist.HttpClientModule";

declare namespace lawd="http://lawd.info/ontology/";
declare namespace pleiades="https://pleiades.stoa.org/places/vocab#";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace ev = "http://www.w3.org/2001/xml-events";
(:declare namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/";:)
declare namespace thot = "http://thot.philo.ulg.ac.be/";
declare namespace xf = "http://www.w3.org/2002/xforms";
declare namespace dct = "http://purl.org/dc/terms/";
declare namespace local = "local";

declare variable $app:docId :=  request:get-parameter("docid", ());

declare variable $app:resourceType :=  request:get-parameter("resourceType", ());

declare variable $app:config-parameters := doc("/db/apps/" || $config:project || "/data/app-general-parameters.xml");
declare variable $app:currentUser := data(sm:id()//sm:username);
declare variable $app:user :=request:get-attribute($config:login-domain||".user");
declare variable $app:userGroups := request:get-parameter("userGroups", ());

(:~
 : This is a sample templating function. It will be called by the templating module if
 : it encounters an HTML element with an attribute data-template="app:test"
 : or class="app:test" (deprecated). The function has to take at least 2 default
 : parameters. Additional parameters will be mapped to matching request or session parameters.
 :
 : @param $node the HTML node with the attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)



declare
    %templates:wrap
function app:current-user($node as node(), $model as map(*)) {
    sm:id()//sm:username
};

declare function app:show-if-logged-in($node as node(), $model as map(*)) {
    let $user := request:get-attribute($config:login-domain || ".user")
    return
        if ($user) then
            element { node-name($node) } {
                $node/@*,
                templates:process($node/node(), $model)
            }
        else
            ()
};


declare
    %templates:wrap
function app:admin-menu($node as node(), $model as map(*)) {
    let $user := request:get-attribute($config:login-domain || ".user")
    return
        if ($user) then
            templates:process($node/*[2], $model)
        else
            templates:process($node/*[1], $model)
};

declare
    %templates:wrap
function app:current-user-name($node as node(), $model as map(*)) {
    request:get-attribute($config:login-domain || ".user")
};

declare %templates:wrap
    function app:navBar($node as node(), $model as map(*)){app:navBar()};
    
declare %templates:wrap
    function app:navBar(){
    
        <div class="col-xs-12 col-md-12 col-lg-12 collapse navbar-collapse navbarCollapse" id="datanavbar">
        
            <ul class="nav navbar-nav">
            <li>
            
            <a href="/exist/apps/estudium/atlas/"><!--<img src="$nav-base/resources/images/logo-patrimonium-square.png" alt="Patrimonium logo" height="25px"/>
            -->
            <strong>APC<em><sup><span class="hidden-xs">beta</span></sup></em><i class="glyphicon glyphicon-chevron-right" style="margin-left: 0.5m;"/></strong></a>
            
            </li>
                <li id="datanavbar-documents"><a href="/exist/apps/estudium/documents/list/">
                        <span class="col-xs-1 visible-xs"><i class="glyphicon glyphicon-file visible-xs"/></span><span class="hidden-xs">Documents</span></a></li>
                <li id="datanavbar-people"><a href="/exist/apps/estudium/people/list/"><span class="col-xs-1 visible-xs"><i class="glyphicon glyphicon-user visible-xs"/></span><span class="hidden-xs">People</span></a></li>
                <li id="datanavbar-places"><a href="/exist/apps/estudium/places/list/"><span class="col-xs-1 visible-xs"><i class="glyphicon glyphicon-pushpin visible-xs"/></span><span class="hidden-xs">Places</span></a></li>
                <li id="datanavbar-atlas"><a href="/exist/apps/estudium/atlas/map/"><span class="col-xs-1 visible-xs"><i class="glyphicon glyphicon-globe visible-xs"/></span><span class="hidden-xs">Map</span></a></li>
                <li id="datanavbar-keywords"><a href="/exist/apps/estudium/atlas/keywords/"><span class="col-xs-1 visible-xs"><i class="glyphicon glyphicon-tags visible-xs"/></span><span class="hidden-xs">Keywords</span></a></li>
                <!--<li id="datanavbar-thesaurus"><a href="#">Thesaurus</a></li>-->
                
                <li id="datanavbar-biblio"><a href="https://www.zotero.org/groups/2094917"><span class="col-xs-1 visible-xs" style="height: 10px;"><i class="glyphicon glyphicon-book visible-xs-*"/></span><span class="hidden-xs">Bibliography</span></a></li>
                <li id="datanavbar-editor"><a href="/exist/apps/estudium/atlas/editor/"><span class="col-xs-1 visible-xs"><i class="glyphicon glyphicon-pencil visible-xs"/></span><span class="hidden-xs">P<span style="font-size: smaller">ATRIMONIVM</span></span> editor</a></li>
                
             </ul>
                    
                { if(contains($app:userGroups, $config:project || "-editor")) then
                      let $url := (
                                (
                                switch( $app:resourceType)
                                case "document" return "/edit-documents/"
                                case "place" case "placeList" return "/edit-places/"
                                case "people" case "peopleList" return "/edit-people/"
                                case "documentsList" return "/admin/"
                                
                                default return "/")
                                ||  $app:docId)
                      let $label := (
                                (
                                switch( $app:resourceType)
                                case "document" case "place" case "people" return "Edit "
                                case "documentsList" case "placeList" case "peopleList" return "Admin"
                                default return "/")
                                ||  $app:docId)
                                
                          return
                        <ul class="nav navbar-nav pull-right"><li><a class="" href="{ $url }"><span class="col-xs-1 visible-xs"><i class="glyphicon glyphicon-edit visible-xs"/></span><span class="hidden-xs">{ $label }</span></a></li></ul>
                        else(
                        
                        )
                }
                {
                let $emailDetails := (
                                (
                                switch( $app:resourceType)
                                case "document" return "Document "
                                case "place" return "Place "
                                case "people" return "Person "
                                case "documentsList" case "peopleList" case "placeList"  return ""
                                default return "")
                                ||  $app:docId)
                                
                          return
                         switch( $app:resourceType)
                            case "landingpage" case "documentsList" case "peopleList" case "placeList" case "atlas" case "atlasEditor" return ""
                            default return <ul class="nav navbar-nav btn-warning pull-right"><li><a href="mailto:alberto.dallarosa@u-bordeaux-montaigne.fr?subject=[Patrimonium] Feedback on { $emailDetails }&amp;body=Please write your feedback about { $emailDetails } below. We shall get back to you in due course."><span class="col-xs-1 visible-xs"><i class="glyphicon glyphicon-edit visible-xs"/></span><span class="hidden-xs">Send feedback</span></a></li></ul>}
            
        
    </div>
    };

declare
    %templates:wrap
function app:action($node as node(), $model as map(*), $source as xs:string?, $action as xs:string?, $new-odd as xs:string?) {
    switch ($action)
        case "create-odd" return
            <div class="panel panel-primary" role="alert">
                <div class="panel-heading"><h3 class="panel-title">Generated Files</h3></div>
                <div class="panel-body">
                    <ul class="list-group">
                    {
                        let $template := doc($config:odd-root || "/template.odd.xml")
                        return
                            xmldb:store($config:odd-root, $new-odd || ".odd", document { app:parse-template($template, $new-odd) }, "text/xml")
                  }
                    </ul>
                </div>
            </div>
        default return
            ()
};
declare %private function app:parse-template($nodes as node()*, $odd as xs:string) {
    for $node in $nodes
    return
        typeswitch ($node)
        case document-node() return
            app:parse-template($node/node(), $odd)
        case element(tei:schemaSpec) return
            element { node-name($node) } {
                $node/@*,
                attribute ident { $odd },
                app:parse-template($node/node(), $odd)
            }
        case element() return
            element { node-name($node) } {
                $node/@*,
                app:parse-template($node/node(), $odd)
            }
        default return
            $node
};









declare function app:menu($node as node(), $model as map(*)){
    let $config-parameters := doc($config:data-root || '/app-general-parameters.xml')
    let $lang := request:get-parameter('lang', ())
    let $selectedLang := request:get-parameter('selectedLang', ())
    let $labels := $config-parameters//menuLabels
    let $currentUser := data(sm:id()//sm:username) 
        let $currentUrl := request:get-uri()



return

<div class="navbar-collapse collapse" id="navbar-collapse-1" xml:lang="en"
data-template="i18n:translate" data-selectedLang="fr"
data-lang="en"
data-catalogues="http://ausonius.huma-num.fr/exist/apps/patrimonium/data/i18n/">
                <ul class="nav navbar-nav">
                    <li class="btn-group" id="home">
                         <a class="btn" href="/index.html">
                        <i18n:translate>a<i18n:text key="home"/>b</i18n:translate>
                         {$labels//.[@id="home"]/value[@xml:lang=$lang]}</a>


                    </li>
                    <li class="btn-group" >
                    <a class="btn" href="/exist/apps/estudium/index.html">{$labels//.[@id="goals"]/value[@xml:lang=$lang]}</a></li>
                    <li class="btn-group" ><a class="btn" href="/exist/apps/estudium/index.html">{$labels//.[@id="atlas"]/value[@xml:lang=$lang]}</a></li>

                    <li class="btn-group" ><a class="btn" href="/exist/apps/estudium/index.html">{$labels//.[@id="team"]/value[@xml:lang=$lang]}</a></li>
                    <li class="btn-group" ><a class="btn" href="/exist/apps/estudium/index.html">{$labels//.[@id="news"]/value[@xml:lang=$lang]}</a></li>
                    <li class="btn-group" ><a class="btn" href="/exist/apps/estudium/index.html">{$labels//.[@id="jobs"]/value[@xml:lang=$lang]}</a></li>


                {if ($currentUser = 'guest') then

      <li class="pull-right">
                        <a href="/login/" class="dropdown-toggle btn thotGenCss"
                        data-toggle="dropdown">

                        {$labels//.[@id="collaborating"]/value[@xml:lang=$lang]}<span class="caret"></span></a>
                        <ul class="dropdown-menu thotGenCss" role="menu">
                            <div class="col-lg-12">
                                <form
                                action="https://ausohnum.huma-num.fr/apps/eStudium/exist/apps/patrimonium/modules/login.xql" method="post">

            <div class="form-group">
                <label for="username">AAA{$labels//.[@id="username"]/value[@xml:lang=$lang]}</label>
                <input class="form-control" type="text" id="username" name="username" value=""/>
            </div>
            <div class="form-group">
                <label for="password">{$labels//.[@id="password"]/value[@xml:lang=$lang]}</label>
                <input type="password" id="password" name="password" class="form-control"/>

                <input name="url" id="url" value="{$currentUrl}" hidden="hidden"/>
            </div>
    <div class="form-actions">
            <button type="submit" class="btn btn-default">{$labels//.[@id="login"]/value[@xml:lang=$lang]}</button>
        </div>
        </form>
      </div>
      </ul>
      </li>

      else(
      <li class="btn-group login pull-right">
      <a href="#" class="dropdown-toggle btn thotGenCss"
                                        data-toggle="dropdown" role="button" aria-haspopup="true"
                                        aria-expanded="false">
                                        <i class="glyphicon glyphicon-user" style="padding-right: 2em;"/>
      {$currentUser} <span class="caret"></span></a>
      <ul class="dropdown-menu" role="presentation" aria-labelledby="drop4">
                                        <li class="thotGenCssResp">
                                            <a role="menuitem" tabindex="-2" href="/exist/apps/estudium/admin/"
                                                >Dashboard</a>
                                        </li>
                                        <li class="thotGenCssResp">
                                            <a role="menuitem" tabindex="-2" href="/exist/apps/estudium/modules/logout.xql"
                                                >Log out</a>
                                        </li>
                                        </ul>


      </li>

      )


                }
                </ul>


            </div>

};
declare function app:get-patri-parameter($node as node(), $model as map(*), $param as xs:string){
        let $config-parameters := doc($config:data-root || '/app-general-parameters.xml')
        return
        $config-parameters/$param


};

declare %templates:wrap function app:app-shortname($node as node(), $model as map(*)) as text() {
       let $config-parameters := doc($config:data-root || '/app-general-parameters.xml')
        let $lang := request:get-parameter('lang', 'fr')
    return
    $app:config-parameters//projectTitle/value[@type="shortname"][@xml:lang=$lang]/text()
};
declare %templates:wrap function app:app-shortname-latin($node as node(), $model as map(*)) as text() {

        let $lang := request:get-parameter('lang', 'fr')
    return
    $app:config-parameters//projectTitle/value[@type="shortname-latin"][@xml:lang='en']/text()
};

declare %templates:wrap function app:app-subtitle($node as node(), $model as map(*)) as text() {
        let $config-parameters := doc($config:data-root || '/app-general-parameters.xml')
        let $lang := request:get-parameter('lang', 'fr')
    return
    $config-parameters//projectTitle/value[@type="subtitle"][@xml:lang='en']/text()
};

declare %templates:wrap function app:new-document($node as node(), $model as map(*)){
let $now := fn:current-dateTime()
let $currentUser := data(sm:id()//sm:username)
let $userPrimaryGroup := sm:get-user-primary-group($currentUser)
let $template := doc('/db/apps/patrimonium/data/templates/doc-simple.xml')

let $model :=
<div
    id="xform_model" class=""
>
    <xf:model
        id="m_document"
        xmlns:skos="http://www.w3.org/2004/02/skos/core#"
        xmlns:thot="http://thot.philo.ulg.ac.be/"
    >
        <xf:instance xmlns="" id="i_document">
            {$template}


</xf:instance>
<xf:bind
            id="doc_title"
            ref="instance('i_document')/item"/>
</xf:model>
</div>

return
<div xmlns:ev="http://www.w3.org/2001/xml-events" xmlns:xf="http://www.w3.org/2002/xforms">
{$model}test
<xf:input bind="doc_title"/>
</div>
};


declare function app:open-sourceFile($node as node(), $model as map(*)) {
    let $user := request:get-attribute($config:login-domain || ".user")
    let $url := request:get-parameter('currentFilePath', '')
    return
        if ($user) then(
            <a href="https://ausohnum.huma-num.fr/apps/eStudium/exist/apps/eXide/index.html?open=/apps/patrimonium{$url}"
            target="about"
            class="btn btn-warning openSourceButton">Edit HTML</a>

            )
        else
            ()
};

declare 
%templates:wrap
function app:documentsList($node as node(), $model as map(*)){
    let $appVariables := doc("/db/apps/" || $config:project || "/data/app-general-parameters.xml")
(:    let $documents := collection("/db/apps/" || $config:project || "Data/documents")//tei:TEI:)
(:    let $projectPlaceCollection := collection("/db/apps/" || $config:project || "Data/places/" || $config:project) :)
(:    let $placeToDisplay := $appVariables//dashboardPlaceToDisplay/text():)
    let $lang := request:get-parameter("lang", ())
    let $docPrefix := $appVariables//idPrefix[@type="document"]/text()
    (:let $romanProvinces := ($projectPlaceCollection//pleiades:Place[pleiades:hasFeatureType[@rdf:resource="https://ausohnum.huma-num.fr/concept/c22264"]])
    let $romanProvincesUriList := string-join($romanProvinces//@rdf:about, " "):)
    
    (:    Provisional list of areas. TODO: proper places in Gazetteer or in thesaurus?:)
    let $areas := map{
               "Alpine provinces": "Alpes Maritimae, Alpes Graiae, Alpes Cottiae, Alpes Poeninae, Raetia, Noricum",
	    "Sicily, Sardinia, Corsica": "Sicilia, Sardinia, Corsica",
	    "Gaul and Germany": "Narbonensis, Aquitania, Lugdunensis, Belgica, Germania Inferior, Germania superior",
	    "Iberian peninsula": "Baetica, Hispania citerior tarraconensis, Lusitania",
	    "Britain": "Britannia",
	    "Balkan provinces":"Dalmatia, Pannonia inferior, Pannonia superior, Moesia inferior, Moesia Superior, Thracia, Dacia",
	    "Greece": "Macedonia, Epirus, Achaia",
	    "Asia Minor":"Asia, Galatia, Lycia et Pamphylia, Pontus et Bithynia, Cappadocia, Cilicia",
	    "Africa": "Africa proconsularis, Mauretania tingitana, Mauretania Caesariensis",
	    "Crete–Cyrene, Cyprus": "Creta et Cyrene, Cyprus",
	    "Egypt": "Aegyptus",
	    "The East": "Syria, Palaestina, Arabia, Mesopotamia, Osroene",
	    "Italy": "Aemilia (Regio VIII), Apulia et Calabria (Regio II), Etruria (Regio VII), Latium et Campania (Regio I), Liguria (Regio IX), Lucania et Bruttii (Regio III), Picenum (Regio V), Samnium (Regio IV), Transpadana (Regio XI), Umbria (Regio VI), Venetia et Histria (Regio X)"
	}
    let $buildFilteringNode := function($k, $v){
    <button id="filterButtonForProvinces" class="btn btn-default filter provincesFilter" value="{ replace(replace(replace($v, ", ", "|"), "\(", "\\("), "\)", "\\)") }" title="This area encompasses the following Roman provinces: { $v }">{ $k }</button>
}        
    let $filteringButtons := sort(map:for-each($areas, $buildFilteringNode))
           
    return
       <div data-template="templates:surround" data-template-with="templates/page.html" data-template-at="content">
              <div class="container-fluid">
                   <div class="row">
                        
                          <div class="row">
                          { app:regenerateListMenu() }
                          <div class="panel panel-noBorder-noMargin col-xs-8 col-sm-8 col-md-8">
                                    <div style="width: 100%;">
                                        <label>Filter by area </label><button id="resetFilters" class="btn btn-default btn-xs" style="margin-left: 1em;"><i class="glyphicon glyphicon-remove-sign"/> reset</button>
                                        <div class="" style="width: 100%;">{ $filteringButtons }</div>
                                   </div>
                            </div>
                                <div class="col-xs-4 col-sm-4 col-md-4">
                                        <label>Filter by date range</label>
                                 <div style="width: 100%;">   
                                    <div id="slider-range"></div>
                                    <input type="text" id="min" name="min" class="pull-left" readonly="readonly" size="4" style="border-width:0px; border:none;" value="-50"></input>
                                    <input type="text" id="max" name="max" class="pull-right" readonly="readonly" size="4" style="border-width:0px; border:none; text-align:right;" value="650"></input>
                                 </div>   
                       </div>
                   </div>
                   <div class="row">
                        <div class="col-xs-12 col-sm-12 col-md-12">
                        <div id="documentListDiv">
                        <table id="documentsList" class="stripe">
                                    <thead>
                                       <tr>
                                       <th class="sortingActive">ID</th>
                                       <th>Document title</th>
                                       <th>Document Uri</th>
                                       <th>Provenance</th>
                                       <th>ProvenanceURI</th>
                                       <th>ProvenanceCoordinates</th>
                                       <th>Province</th>
                                       <th>ProvinceURI</th>
                                       <th>Dating</th>
                                       <th></th>
                                       <th>TM no.</th><!--Header for TM -->
                                      <th>Edition</th>
                                       <th>Other identifiers</th><!--Header for other identifiers-->
                                       <th>Keywords</th>
                                       <th>provenanceAltNames</th>
                                       </tr>
                                       </thead>
                        </table>
                </div>     
                    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.20/css/jquery.dataTables.css"/>
                    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.20/js/jquery.dataTables.js"></script>
                    
                    <script type="text/javascript" src="$ausohnum-lib/resources/scripts/ausohnumCommons/ausohnumCommons.js"/>
                    <!-- CP: fix path -->
                    <script type="text/javascript" src="/exist/apps/estudium/resources/scripts/documentsList.js"/>
                    <link rel="stylesheet" type="text/css" href="$ausohnum-lib/resources/css/ausohnumCommons.css"/>
                    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.24/css/jquery.dataTables.min.css"/>
    
    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/buttons/1.7.0/js/dataTables.buttons.min.js"/>
    <script type="text/javascript" charset="utf8" src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.1.3/jszip.min.js"/>
    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/buttons/1.7.0/js/buttons.html5.min.js"/>
    <script type="text/javascript" src="https://cdn.datatables.net/fixedheader/3.1.9/js/dataTables.fixedHeader.min.js"/>
    <script type="text/javascript" src="https://cdn.datatables.net/fixedcolumns/3.3.3/js/dataTables.fixedColumns.min.js"/>
    <script type="text/javascript" src="https://cdn.datatables.net/responsive/2.2.8/js/dataTables.responsive.min.js"/>
    <script type="text/javascript" src="https://cdn.datatables.net/plug-ins/1.10.25/sorting/any-number.js"/>
    <script type="text/javascript" src="$ausohnum-lib/resources/scripts/dataTables/accent-and-diacritics-neutralise.js"/>

<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/fixedheader/3.1.9/css/fixedHeader.dataTables.min.css"/>
<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/responsive/2.2.8/css/responsive.dataTables.min.css"/>
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/buttons/1.7.0/css/buttons.dataTables.min.css"/>
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/fixedcolumns/3.3.3/css/fixedColumns.dataTables.min.css"/>
                        </div>
                
                        </div>
                    </div>
               </div>
       </div>
};

declare function app:atlasMap($node as node(), $model as map(*)){

        <div>
        <link rel="stylesheet" href="$ausohnum-lib/resources/scripts/jquery/summernote/summernote.min.css" />
        <script src="$ausohnum-lib/resources/scripts/jquery/summernote/summernote.min.js"></script>
        <div id="atlasMap" >
                <div id="atlasSearchPanel" class="panel panel-default hidden">
                    <button id="closeSearchPaneButton" type="button" class="close" onclick="closeAtlasSearchPanel()" style="margin:3px;"><i class="glyphicon glyphicon-remove-circle" /></button>
                    <div class="panel-body">
                        { app:placesListSimple() }
                    </div>
                </div>
        
                <div id="placeRecordContainer" class="panel panel-default hidden">
                    <button id="closePlaceRecordButton" type="button" class="close" onclick="closePlaceRecord()"><i class="glyphicon glyphicon-remove-circle" /></button>
                    <div class="panel-body">
                        <!--<div id="loaderBig" class="center-block"></div>-->
                        <div id="mapPlaceRecord">
                        Loading...
                        <ul id="placeholder">
                        </ul>
                    </div>
                 </div>
            </div>
       </div>
       
        <link rel="stylesheet" href="https://unpkg.com/leaflet@1.0.3/dist/leaflet.css" integrity="sha512-07I2e+7D8p6he1SIM+1twR5TIrhUQn9+I6yjqD53JQjFiMf8EtC93ty0/5vJTZGF8aAocvHYNEDJajGdNx1IsQ==" crossorigin="" />
        <script src="https://unpkg.com/leaflet@1.0.3/dist/leaflet-src.js" integrity="sha512-WXoSHqw/t26DszhdMhOXOkI7qCiv5QWXhH9R7CgvgZMHz1ImlkVQ3uNsiQKu5wwbbxtPzFXd1hK4tzno2VqhpA==" crossorigin=""></script>
        <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet-providers.js"></script>
        <link href='$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.fullscreen/leaflet.fullscreen.css' rel='stylesheet' />
        <script src='$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.fullscreen/Leaflet.fullscreen.min.js'></script>
        <script src="https://unpkg.com/shpjs@3.6.3/dist/shp.js"/>
        <!--Markercluster -->
        <link rel="stylesheet" href="$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet.markerCluster1.4.1/MarkerCluster.css" />
        <link rel="stylesheet" href="$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet.markerCluster1.4.1/MarkerCluster.Default.css" />
        <script src="$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet.markerCluster1.4.1/leaflet.markercluster.js"></script>
         <script src="$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet.featuregroup.subgroup.js"></script>
        <link rel="stylesheet" href="$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet-search/src/leaflet-search.css"/>
        <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet-search/src/leaflet-search.js"></script>
        <script type="text/javascript" src="$ausohnum-lib/resources/scripts/spatiumStructor/L.Control.Geonames.min.js"/>
        <link href="$ausohnum-lib/resources/css/spatiumStructor.css" rel="stylesheet" type="text/css"/>
        <!-- CP: fix path -->
        <script type="text/javascript" src="/exist/apps/estudium/resources/scripts/spatiumStructor.js"/>
        <script type="text/javascript" src="$ausohnum-lib/resources/scripts/spatiumStructor/spatiumStructorFunctions.js"/>
        <link href="$ausohnum-lib/resources/css/ausohnumCommons.css" rel="stylesheet" type="text/css"/>
        <link rel="stylesheet" href="https://ppete2.github.io/Leaflet.PolylineMeasure/Leaflet.PolylineMeasure.css" />
        <script src="https://ppete2.github.io/Leaflet.PolylineMeasure/Leaflet.PolylineMeasure.js"></script>
        <script src="$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet-heat.js"></script>
        <script>
            document.title = "APC - Map";</script>
  </div>
};

declare 
%templates:wrap
function app:placesListSimple(

){
    
    let $lang := request:get-parameter("lang", ())
    
                    
    return
       <div>
            <div id="placesListDiv">
                            <table id="placesListSimple" class="table">
                                    <thead>
                                      <tr>
                                        <th>ID</th>
                                        <th class="sortingActive">Name</th>
                                        <th>URI</th>
                                        <th>Geocoord</th>
                                        <th>Type</th>
                                        <th>Production type</th>
                                        <th>Exact Match</th>
                                     </tr>
                                       </thead>
                        </table>
                      </div>
                            <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.20/css/jquery.dataTables.css"/>
                            <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.20/js/jquery.dataTables.js"></script>
                            <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/plug-ins/1.10.21/sorting/any-number.js"/>
                            <script type="text/javascript" src="https://cdn.datatables.net/responsive/2.2.8/js/dataTables.responsive.min.js"/>
                            <script type="text/javascript" src="$ausohnum-lib/resources/scripts/dataTables/accent-and-diacritics-neutralise.js"/>

                <script type="text/javascript" src="$ausohnum-lib/resources/scripts/ausohnumCommons/ausohnumCommons.js"/>
            </div>


       
};
declare 
%templates:wrap
function app:placesList($node as node(), $model as map(*)){
    
    let $lang := request:get-parameter("lang", ())
    let $areas := map{
               "Alpine provinces": "Alpes Maritimae, Alpes Graiae, Alpes Cottiae, Alpes Poeninae, Raetia, Noricum",
	    "Sicily, Sardinia, Corsica": "Sicilia, Sardinia, Corsica",
	    "Gaul and Germany": "Narbonensis, Aquitania, Lugdunensis, Belgica, Germania Inferior, Germania superior",
	    "Iberian peninsula": "Baetica, Hispania citerior tarraconensis, Lusitania",
	    "Britain": "Britannia",
	    "Balkan provinces":"Dalmatia, Pannonia inferior, Pannonia superior, Moesia inferior, Moesia Superior, Thracia, Dacia",
	    "Greece": "Macedonia, Epirus, Achaia",
	    "Asia Minor":"Asia, Galatia, Lycia et Pamphylia, Pontus et Bithynia, Cappadocia, Cilicia",
	    "Africa": "Africa proconsularis, Mauretania tingitana, Mauretania Caesarensis",
	    "Crete–Cyrene, Cyprus": "Creta et Cyrene, Cyprus",
	    "Egypt": "Aegyptus",
	    "The East": "Syria, Palaestina, Arabia, Mesopotamia, Osroene",
	    "Italy": "Aemilia (Regio VIII), Apulia et Calabria (Regio II), Etruria (Regio VII), Latium et Campania (Regio I), Liguria (Regio IX), Lucania et Bruttii (Regio III), Picenum (Regio V), Samnium (Regio IV), Transpadana (Regio XI), Umbria (Regio VI), Venetia et Histria (Regio X)"
	}
    let $buildFilteringNode := function($k, $v){
    <button id="filterButtonForProvinces" class="btn btn-default filter provincesFilter" value="{ replace(replace(replace($v, ", ", "|"), "\(", "\\("), "\)", "\\)") }" title="This area encompasses the following Roman provinces: { $v }">{ $k }</button>
}        
    let $filteringButtons := sort(map:for-each($areas, $buildFilteringNode))
    
    let $productionUnitTypes := 
(:    collection("/db/apps/" || $app:config-parameters//thesaurus-app/text() || "/concepts" )//:)
    skosThesau:getChildren($app:config-parameters//productionUnitsUri/text(), $config:project)                
    let $productionUnitsTypesFullList := string-join($productionUnitTypes//skos:prefLabel[@xml:lang="en"]/text(), '\b|')
    return
       <div data-template="templates:surround" data-template-with="templates/page.html" data-template-at="content">
                                
                   <div class="row" style="height: 300px">
                        <div class="col-xs-12 col-sm-12 col-md-12">
                        <div id="placesListDiv">
                        <div class="panel panel-noBorder-noMargin col-xs-8 col-sm-8 col-md-8" style="padding-left:0!important;">
                                    <div style="">
                                        <label>Filter by area </label><button id="resetFilters" class="btn btn-default btn-xs" style="margin-left: 1em;"><i class="glyphicon glyphicon-remove-sign"/> reset</button>
                                        <div class="" style="width: 100%;">{ $filteringButtons }</div>
                                   </div>
                            </div>
                            <div class="panel panel-noBorder-noMargin col-xs-4 col-sm-4 col-md-4">
                            <br/>
                            <input id="filterProductionUnits" class="" type="checkbox" name="filterProductionUnits"
                                   value="{ $productionUnitsTypesFullList }"/>
                                   <label for="filterProductionUnits">Show production units only</label>
                                   </div>
                            <table id="placesList" class="stripe">
                                    <!--<span class="pull-right">Sorting language: {$lang}</span>-->
                                    <thead>
                                      <tr>
                                        <th>ID</th>
                                        <th class="sortingActive">Name</th>
                                        <th>URI</th>
                                        <th>Geocoord</th>
                                        <th>Type</th>
                                        <th>Production</th>
                                        <th>Province</th>
                                        <th>ProvinceUri</th>
                                        <th>External resource(s)</th>
                                        <th>Alternative names</th>
                                     </tr>
                                       </thead>
                        </table>
                      </div>
                    </div>
                    <!--<div class="col-xs-4 col-sm-4 col-md-4">
                    <div id="loaderBig" class="hidden"></div>
                     <div id="placeRecord"/>
                    </div>-->
            
                    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.20/css/jquery.dataTables.css"/>
                    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.20/js/jquery.dataTables.js"></script>
                    <script type="text/javascript" src="https://cdn.datatables.net/responsive/2.2.8/js/dataTables.responsive.min.js"/>
                    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/plug-ins/1.10.21/sorting/any-number.js"/>
                    
                    <script type="text/javascript" src="$ausohnum-lib/resources/scripts/dataTables/accent-and-diacritics-neutralise.js"/>

                   

                <script type="text/javascript" src="$ausohnum-lib/resources/scripts/ausohnumCommons/ausohnumCommons.js"/>
                <link rel="stylesheet" type="text/css" href="$ausohnum-lib/resources/css/ausohnumCommons.css"/>
                <!-- CP: fix path -->
                <script type="text/javascript" src="/exist/apps/estudium/resources/scripts/placesList.js"/>
        
                <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.24/css/jquery.dataTables.min.css"/>


                <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/buttons/1.7.0/js/dataTables.buttons.min.js"/>
                <script type="text/javascript" charset="utf8" src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.1.3/jszip.min.js"/>
                <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/buttons/1.7.0/js/buttons.html5.min.js"/>
                <script type="text/javascript" src="https://cdn.datatables.net/fixedheader/3.1.9/js/dataTables.fixedHeader.min.js"/>
                
                <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/fixedheader/3.1.9/css/fixedHeader.dataTables.min.css"/>
                <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/responsive/2.2.8/css/responsive.dataTables.min.css"/>
                <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/buttons/1.7.0/css/buttons.dataTables.min.css"/>

                
            </div>
       </div>

       
};

declare function app:peopleList($node as node(), $model as map(*)){
    let $lang := "en"(:request:get-parameter("lang", ()):)
    
                    
    return
       <div>
                   <div class="row">
                        
                         <div class="col-xs-12 col-sm-12 col-md-12">
                          { app:regenerateListMenu() }
                                <div class="col-xs-6 col-sm-6 col-md-6 col-xs-offset-6 col-sm-offset-6 col-md-offset-6">
                               
                                        <label>Filter by date range</label>
                                 <div style="width: 100%;">   
                                    <div id="slider-range"></div>
                                    <input type="text" id="min" name="min" class="pull-left" readonly="readonly" size="4" style="border-width:0px; border:none;" value="-50"></input>
                                    <input type="text" id="max" name="max" class="pull-right" readonly="readonly" size="4" style="border-width:0px; border:none; text-align:right;" value="650"></input>
                                 </div>   
                               </div>
                         </div>
                   
                   </div>
                   <div class="row" style="height: 300px">
                        <div class="col-xs-12 col-sm-12 col-md-12">
                        <div id="peopleListDiv">
                            <table id="peopleList" class="stripe">
                                    <!--<span class="pull-right">Sorting language: {$lang}</span>-->
                                    <thead>
                                       <tr>
                                       <th>ID</th>
                                       <th class="sortingActive">Name</th>
                                       <th>Sex</th>
                                       <th>Personal status</th>
                                       <th>Personal status URI</th>
                                       <th>Citizenship</th>
                                       <th>Citizenship URI</th>
                                       <th>Rank</th>
                                       <th>RankURI</th>
                                       <th>Functions</th>
                                       <th>Dates</th>
                                       <th></th>
                                       <th></th>
                                       <th>Ref.</th>
                                       </tr>
                                    </thead>
                        </table>
                      </div>
                    </div>
                    <!--<div class="col-xs-4 col-sm-4 col-md-4">
                        <div id="loaderBig" class="hidden"></div>
                        <div id="personRecord"/>
                    </div>-->
                    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.24/css/jquery.dataTables.min.css"/>
                            <!--<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.20/css/jquery.dataTables.css"/>-->
                            <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.20/js/jquery.dataTables.js"></script>
                            <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/plug-ins/1.11.2/filtering/type-based/diacritics-neutralise.js"/>
                                   <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/plug-ins/1.11.2/filtering/type-based/accent-neutralise.js"/>
                            <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/plug-ins/1.10.21/sorting/any-number.js"/>
                              <script type="text/javascript" src="https://cdn.datatables.net/fixedheader/3.1.9/js/dataTables.fixedHeader.min.js"/>
                            <script type="text/javascript" src="https://cdn.datatables.net/responsive/2.2.8/js/dataTables.responsive.min.js"/>
                            <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/fixedheader/3.1.9/css/fixedHeader.dataTables.min.css"/>
                            <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/responsive/2.2.8/css/responsive.dataTables.min.css"/>
                            <script type="text/javascript" src="$ausohnum-lib/resources/scripts/ausohnumCommons/ausohnumCommons.js"/>
                            <!-- CP: fix path -->
                            <script type="text/javascript" src="/exist/apps/estudium/resources/scripts/peopleList.js"/>
                            <link rel="stylesheet" type="text/css" href="$ausohnum-lib/resources/css/ausohnumCommons.css"/>
                             
            </div>
       </div>

       
};

declare function app:regenerateListMenu(){

        if(contains($app:userGroups, $config:project || "-editors")) then
             <div class="form-group">
                <div class="pull-right">
                  {if(request:get-parameter("resourceType", ()) = "documentsList") then <span class="">[# of docs in corpus: { app:documentCount() }]</span>else ""}<br/>
                        <button id="btn-regenerate" class="btn btn-warning">Re-generate list</button><br/>
                        <img id="f-load-indicator" class="hidden" src="$ausohnum-lib/resources/images/ajax-loader.gif"/>
                        <div id="messages"></div>
                   </div>
             </div>
         else ()
};
declare %templates:wrap function app:documentCount($node as node(), $model as map(*)) {
    count(collection("/db/apps/" || $config:project[1] || "Data/documents")//tei:TEI)
};
declare function app:documentCount() {
    count(collection("/db/apps/" || $config:project[1] || "Data/documents")//tei:TEI)
};
declare %templates:wrap function app:documentsInListCount($node as node(), $model as map(*)) {
    count(doc("/db/apps/" || $config:project[1] || "Data/lists/list-documents.xml")//data)
};
declare %templates:wrap function app:peopleCount($node as node(), $model as map(*)) {
    count(collection("/db/apps/" || $config:project[1] || "Data/people")//lawd:person)
};
declare %templates:wrap function app:placesCount($node as node(), $model as map(*)) {
    count(collection("/db/apps/" || $config:project[1] || "Data/places/" || $config:project[1])//pleiades:Place)
};

declare function app:contactForm(){
<div class="container">
  <form action="">

    <label for="lname">Name</label>
    <input type="text" id="lname" name="lastname" placeholder="Your name"/>
<label for="email">Name</label>
    <input type="text" id="email" name="email" placeholder="Your e-mail address"/>
    <label for="subject">Your message</label>
    <textarea id="message" name="message" placeholder="Write your message here" style="height:200px"></textarea>

    <input type="submit" value="Submit"/>

  </form>
</div>
};

declare function app:cleanXmlForPublic($nodes as node()*) as node()*{
    
    <div>
        {
            for $node in $nodes
            return
            typeswitch($node)
            case element(skos:note) return ""
            default return $node
            
        }
    </div>
};

declare
    %templates:wrap
function app:lang ($node as node(), $model as map(*)) {
    let $lang :=
        if (request:get-parameter("selectedLang", ()) != "") then (request:get-parameter("selectedLang", ()))
    else if(
        (request:get-parameter("lang", ()) = "") 
        or not((request:get-parameter("lang", ()) = "en")
        or (request:get-parameter("lang", ()) = "fr"))
        )
        then ("en")
        else (request:get-parameter("lang", ())) 
    return
    templates:process($node/*[@lang=$lang], $model)
};

declare function app:getUserCountry($node as node(), $model as map(*)){
 let $ip := request:get-remote-addr()
 let $http-request-data := <request xmlns="http://expath.org/ns/http-client"
    method="GET" href="https://www.iplocate.io/api/lookup/{ $ip }"/>

 let $responses :=
    http:send-request($http-request-data)
 let $response :=util:base64-decode(
      if ($responses[1]/@status ne '200')
         then
      $responses[1]
         else
           $responses[2]
        )
 let $country :=$response 
(: tokenize($response, ",")[3]:)
 
 return
 if($app:user = "vrazanajao") then
 (
 (
  
 for $header in request:get-header-names()
    return $header || " = " || request:get-header($header)
  ),
  "1st Accepted : " || substring-before(request:get-header("Accept-Language"), ","))
    else ()
 
};

declare function app:getUserClientLang($node as node(), $model as map(*)){
        "Lang=" || request:get-parameter("lang", ()) || " - langSelected: " || request:get-parameter("selectedLang", ()) 
};

declare function app:keywordsBrowser($node as node(), $model as map(*)){
    let $lang := request:get-parameter("lang", ())
    let $conceptUrisForTree := "c22031 c21869 c21862 c22148 c22055 c21987 c22017 c22070"
    let $labelForTree := "Thesaurus APC"
                    
    return
       
<div class="row" style="">
    <div class="col-xs-4 col-sm-4 col-md-4">
        <div id="conceptUrisForTree" class="hidden">{ $conceptUrisForTree }</div>
        <div id="labelForTree" class="hidden">{ $labelForTree }</div>
        <div id="lang" class="hidden">{ $lang }</div>

        <form id="searchBar" class="navbar-form" role="search" >
            <div class="input-group">
                <i class="glyphicon glyphicon-search"/>
                <input name="searchTree" id="searchTree" placeholder="Filter terms" title="Filter terms" autocomplete="off"/>
                <div class="input-group-btn">
                    <button id="btnResetSearch" class="btn btn-default" title="Clear filter">
                        <i class="glyphicon glyphicon-remove-sign" style="line-height: 1!important;"/>
                    </button>
                </div>
            </div>
        </form>
        <span id="matches"/>
        <div id="thesaurus" style="height: 100%; max-height: 100%"/>
    </div>
    <div class="col-xs-8 col-sm-8 col-md-8">
        <div id="conceptDetails">
        { skosThesau:generalIndex("patrimonium", $lang, 30) }
        </div>
    </div>
    <script type="text/javascript" src="/resources/scripts/keywordsBrowser.js"/>
    <link rel="stylesheet" type="text/css" href="$ausohnum-lib/resources/css/ausohnumCommons.css"/>        
</div>
};