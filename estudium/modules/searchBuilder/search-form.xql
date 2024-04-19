xquery version "3.1";

import module namespace config="https://ausohnum.huma-num.fr/apps/eStudium/config" at "../config.xqm";
import module namespace ausohnumSearch="http://ausonius.huma-num.fr/search"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/commons/search.xql";

import module namespace ausohnumCommons="http://ausonius.huma-num.fr/commons"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/commons/commonsApp.xql";
import module namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/" at "xmldb:exist:///db/apps/ausohnum-library/modules/skosThesau/skosThesauApp.xql";
import module namespace functx="http://www.functx.com" at "/db/system/repo/functx-1.0/functx/functx.xql";

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

let $lang := request:get-parameter("lang", "en")


return

<div data-template="templates:surround" data-template-with="templates/page.html" data-template-at="content">
    <script src="$ausohnum-lib/resources/scripts/skosThesau/skosThesauActions.js"></script>
    
    <link rel="stylesheet" type="text/css" href="$ausohnum-lib/resources/css/teiEditor.css"/>
    <link rel="stylesheet" type="text/css" href="$ausohnum-lib/resources/css/ausohnumCommons.css"/>
    <link rel="stylesheet" type="text/css" href="$epidocLib/resources/xsl/epidoc-stylesheets/global.css"/>
    <div class="container-fluid">
    <div class="row">
        <h1>Fulltext search</h1>
        <div class="row">
            <div class="col-md-6">
                            <div class="form form-horizontal">
                                <div class="form-group">
                                    <label for="mode" class="col-md-1 hidden-xs control-label">Query:</label>
                                    <div class="col-md-8 col-xs-12">
                                        <span class="input-group">
                                            <input id="query" name="query" type="search" class="form-control" placeholder="Search string"/>
                                            <span class="input-group-btn" style="height: 100%;">
                                                <button id="f-btn-search" class="btn btn-primary" onclick="executeftSearch()">
                                                    <span class="glyphicon glyphicon-search"/>
                                                </button>
                                            </span>    
                                        </span>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label for="mode" class="col-md-1 hidden-xs control-label" title="">Mode:</label>
                                    <div class="col-md-4 col-xs-12">
                                        <select id="mode" name="mode" class="form-control">
                                            <option value="all">All</option>
                                            <option value="any">Any</option>
                                            <option value="phrase">Phrase</option>
                                            <option value="near">Near</option>
                                        </select>
                                    </div>
                                   <div style="margin-top: 3px">
                                        <button type="button" class="btn btn-xs btn-primary" data-toggle="popover" title="Modes" data-content="" data-html="true">?
                                            <div id="popover-title" class="hidden">Modes</div>
                                            <div id="popover-body" class="hidden"><ul style='list-style: none; padding: 0!important;'>
                                                <li><strong>All</strong> &amp; <strong>Any</strong> Search for texts containing all or any of the search terms</li>
                                                <li><strong>Phrase</strong> Searches for a group of terms occurring in the correct order</li>
                                                <li><strong>Near</strong> Alternative to Phrase mode, this makes it possible to search for two sequences of terms which are within a specific distance</li>
                                                </ul>
                                            </div>
                                        </button>
                                    Use <strong>* as a wildcard</strong></div>
                                </div>
                                
                                <img id="load-indicator" class="hidden" style="padding: 10px 0 10px 6em;" src="$ausohnum-lib/resources/images/ajax-loader.gif"/>
                                <span id="searchResultsNo" style="font-weight: bold;     display: block; padding: 10px 0 10px 0;"/>
                            </div>
            
            
            </div>


        </div>
        
        
        <div class="row">
            <div id="searchResultsMap" class="panel"  style="height:250px; margin: 0 50px 0 50px"></div>

                <!--<div class="ausohnumSearch:display-map"/>-->
        </div>
        <div class="row hidden searchResultsPaneElement">
                    <div class="col-xs-3 col-sm-3 col-md-3">
                                        <label>Filter by date range</label>
                                 <div style="width: 100%;">   
                                    <div id="slider-range"></div>
                                    <input type="text" id="min" name="min" class="pull-left" readonly="readonly" size="4" style="border-width:0px; border:none;" value="-50"></input>
                                    <input type="text" id="max" name="max" class="pull-right" readonly="readonly" size="4" style="border-width:0px; border:none; text-align:right;" value="650"></input>
                                 </div>
                    </div>
        </div>
        <div class="row hidden searchResultsPaneElement">
                <div id="results" class="">
                    <!-- <div class="col-md-8 hitsList">
                        <p><span id="hit-count" class="ausohnumSearch:hit-countAsLabel"/>.</p>
                            <div class="ausohnumSearch:show-hits"/>
                        </div>
                    <button class="btn btn-xs btn-primary" onclick="executeftSearch()">Search</button>-->
                    <div class="col-md-12 hitsList">
                        <table id="hitsTable">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>docId</th>
                                <th>Match summary</th>
                                <th>Document text</th>
                                <th>Provenance</th>
                                <th>ProvenanceURI</th>
                                <th>Province</th>
                                <th>ProvinceURI</th>
                                <th>Dating</th>
                                <th></th>
                                <th>Keywords</th>
                            </tr>
                        </thead>
                        </table>
                </div>
        
        </div>
        
    </div>
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.20/css/jquery.dataTables.css"/>
    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.20/js/jquery.dataTables.js"></script>
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.24/css/jquery.dataTables.min.css"/>
    
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.0.3/dist/leaflet.css" integrity="sha512-07I2e+7D8p6he1SIM+1twR5TIrhUQn9+I6yjqD53JQjFiMf8EtC93ty0/5vJTZGF8aAocvHYNEDJajGdNx1IsQ==" crossorigin="" />

    <script src="https://unpkg.com/leaflet@1.0.3/dist/leaflet-src.js" integrity="sha512-WXoSHqw/t26DszhdMhOXOkI7qCiv5QWXhH9R7CgvgZMHz1ImlkVQ3uNsiQKu5wwbbxtPzFXd1hK4tzno2VqhpA==" crossorigin=""></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet-providers.js"></script>
    <!--Markercluster -->
<link rel="stylesheet" href="https://leaflet.github.io/Leaflet.markercluster/dist/MarkerCluster.css" />
<link rel="stylesheet" href="https://leaflet.github.io/Leaflet.markercluster/dist/MarkerCluster.Default.css" />
<script src="https://leaflet.github.io/Leaflet.markercluster/dist/leaflet.markercluster-src.js"></script>
<script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet-search/src/leaflet-search.js"></script>
<script type="text/javascript" src="$ausohnum-lib/resources/scripts/spatiumStructor/L.Control.Geonames.min.js"/>
    <!--<script src="$ausohnum-lib/resources/scripts/spatiumStructor/spatiumStructorFunctions.js"></script>    -->
 
  <script src="$shared/resources/scripts/jquery/jquery.scrollExtend.min.js" type="text/javascript"></script>


  <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/buttons/1.7.0/js/dataTables.buttons.min.js"/>
    <script type="text/javascript" charset="utf8" src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.1.3/jszip.min.js"/>
    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/buttons/1.7.0/js/buttons.html5.min.js"/>
    <script type="text/javascript" src="https://cdn.datatables.net/fixedheader/3.1.9/js/dataTables.fixedHeader.min.js"/>
    <script type="text/javascript" src="https://cdn.datatables.net/fixedcolumns/3.3.3/js/dataTables.fixedColumns.min.js"/>
<script type="text/javascript" src="https://cdn.datatables.net/responsive/2.2.8/js/dataTables.responsive.min.js"/>


<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/fixedheader/3.1.9/css/fixedHeader.dataTables.min.css"/>
<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/responsive/2.2.8/css/responsive.dataTables.min.css"/>
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/buttons/1.7.0/css/buttons.dataTables.min.css"/>
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/fixedcolumns/3.3.3/css/fixedColumns.dataTables.min.css"/>

    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/spatiumStructorFunctions.js"></script>
    <script src="/resources/scripts/spatiumStructorMarkersOptions.js"></script>
    <script src="/resources/scripts/searchBuilder.js"></script>
    
       </div>
       
    

    </div>        
    
</div>
