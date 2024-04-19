xquery version "3.1";

(:import module namespace processConcept="https://ausohnum.huma-num.fr/skosThesau/processConcept" at "concept-process.xql";:)

declare namespace skos = "http://www.w3.org/2004/02/skos/core#";

declare variable $conceptId :=  request:get-parameter("conceptId", "apcc0");
declare variable $lang :=  request:get-parameter("lang", ());
declare variable $project :=  request:get-parameter("project", ());


(: let $input := collection("/db/apps/thot/data/concepts") :)

(: let $concept := $input/id($conceptId) :)
(: let $currentUser := xmldb:get-current-user() :)
(: let $userPrimaryGroup := sm:get-user-primary-group($currentUser) :)

(: let $title :=
  <div class="page-header concept-header">
    <h1>{$concept//skos:prefLabel[@xml:lang='en']/text()}<span class="conceptTag"> Concept <em>thot-6197</em></span></h1>
  </div> :)



  <div  data-template="templates:surround" data-template-with="./templates/page.html" data-template-at="content">
  <!--Script for fancytree-->
        <!-- Include Fancytree skin and library -->
        <link href="$ausohnum-lib/resources/scripts/jquery/fancytree/skin-bootstrap/ui.fancytree.css" rel="stylesheet" type="text/css" />
        <script src="$ausohnum-lib/resources/scripts/jquery/fancytree/jquery.fancytree-all.min.js" type="text/javascript"></script>
        <script src="$ausohnum-lib/resources/scripts/jquery/fancytree/jquery.fancytree.filter.js" type="text/javascript"></script>
        <script src="$ausohnum-lib/resources/scripts/jquery/fancytree/jquery.fancytree.glyph.js" type="text/javascript"></script>
        <script src="$ausohnum-lib/resources/scripts/jquery/fancytree/jquery.fancytree.wide.js" type="text/javascript"></script>
        
        
             <script type="text/javascript" src="$ausohnum-lib/resources/scripts/skosThesau/skosThesauTree.js"></script>
        <!--<script type="text/javascript" src="$ausohnum-lib/resources/scripts/skosThesau/skosThesauActions.js"></script>-->
         <link href="$ausohnum-lib/resources/css/skosThesau.css" rel="stylesheet" type="text/css"/>
      <!--    <script src="/resources/scripts/accordion4concepts.js" type="text/javascript"/>-->
      <div class="container">
          <div class="row row-centered">
              <div class="col-xs4 col-sm-4 col-md-4" id="leftMenu">

                      <!--                    <label>Q:</label>-->
                    <form id="searchBar" class="navbar-form" role="search" >
                      <div class="input-group">
                      <i class="glyphicon glyphicon-search"/>
                      <input name="searchTree" id="searchTree" placeholder="Filter concepts in current language" title="Filter concepts in current language" autocomplete="off"/>
                      <div class="input-group-btn">
                      <button id="btnResetSearch" class="btn btn-default" title="Clear filter">
                          <i class="glyphicon glyphicon-remove-sign"/>
                      </button>
                      </div>
                      </div>
                      </form>

                      <span id="matches"/>
                  <div id="langflags">
                      <img id="lang-en" class="langflag" src="/$ausohnum-lib/resources/images/flags/gb.png"/>
                      <img id="lang-de" class="langflag" src="/$ausohnum-lib/resources/images/flags/de.png"/>
                      <img id="lang-fr" class="langflag" src="/$ausohnum-lib/resources/images/flags/fr.png"/>
                      <img id="lang-ar" class="langflag" src="/$ausohnum-lib/resources/images/flags/ar.png"/>
                      <!--            <span class="lang-en lang-lbl" lang="en"></span>-->
                  </div>
                  <div id="collection-tree" data-type="json"/>
              </div>
              <div id="rightSide" class="col-xs-8 col-sm-8 col-md-8">

                  <div id="conceptContent">
                          <div data-template="skosThesau:templatingProcessConcept" data-template-conceptId="{$conceptId}" 
                          data-template-language="{$lang}" data-template-project="{$project}" />
                          
                  </div>


              </div>
              
              <!--
              <script type="text/javascript"> function getURLParameter(name) {{ return unescape(
                  (RegExp(name + '=' + '(.+?)($)').exec(location.search)||[,null])[1] ); }} </script>
              -->
          </div>
      </div>
  </div>
