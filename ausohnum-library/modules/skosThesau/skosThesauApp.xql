(:~
: AusoHNum Library - thesaurus module - Main Module
: This module contains the main functions of the thesaurus module.
: @author Vincent Razanajao
:)

xquery version "3.1";

(:
 : Module Name: skosThesau App;
 :
 : Module version: 1.0
 :
 : Date: 22/08/2018
 :
 :Module Overview: this modules contains the functions used for displaying thesaurus concepts and build the tree of concepts.
 :
 : @author Vincent Razanajao
 : @version 1.0 
 :)

module namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/";

import module namespace functx="http://www.functx.com";

declare boundary-space preserve;

declare namespace apc="http://patrimonium.huma-num.fr/onto#";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace dcterms = "http://purl.org/dc/terms/";
declare namespace ev = "http://www.w3.org/2001/xml-events";
declare namespace json="http://www.json.org";
declare namespace lawd="http://lawd.info/ontology/";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace periodo="http://perio.do/#";
declare namespace pleiades="https://pleiades.stoa.org/places/vocab#";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace thot = "http://thot.philo.ulg.ac.be/";
declare namespace time="http://www.w3.org/2006/time#";
declare namespace xf = "http://www.w3.org/2002/xforms";

(:declare boundary-space preserve;:)


declare variable $skosThesau:data := request:get-data();
declare variable $skosThesau:project :=request:get-parameter('project', ());
declare variable $skosThesau:authorized-groups :=request:get-parameter('authorized-groups', ());
declare variable $skosThesau:appParam := doc('/db/apps/' || $skosThesau:project || '/data/app-general-parameters.xml');
declare variable $skosThesau:thesaurus-app := $skosThesau:appParam//thesaurus-app/text();
declare variable $skosThesau:concept-collection := collection('/db/apps/' || $skosThesau:thesaurus-app || 'Data/concepts');
declare variable $skosThesau:concept-collection-path := '/db/apps/' || $skosThesau:thesaurus-app || 'Data/concepts';
declare variable $skosThesau:concept-backup-collection := collection('/db/apps/' || $skosThesau:thesaurus-app || 'Data/backups/concepts');
declare variable $skosThesau:thesaurusTree := doc('/db/apps/' || $skosThesau:thesaurus-app || 'Data/thesaurus/thesaurus-as-tree.xml');
declare variable $skosThesau:account-collection := collection('/db/apps/' || $skosThesau:project || 'Data/accounts');
declare variable $skosThesau:logs-collection := collection('/db/apps/' || $skosThesau:thesaurus-app || 'Data/logs');

declare variable $skosThesau:baseUri := $skosThesau:appParam//uriBase[@type="app"]/text();
declare variable $skosThesau:thesBaseUri :=     $skosThesau:appParam//uriBase[@type="thesaurus"]/text();
declare variable $skosThesau:thesImportBaseUri :=     $skosThesau:appParam//uriBase[@type="thesaurusImport"]/text();
declare variable $skosThesau:conceptBaseUri := $skosThesau:thesBaseUri ||'/concept/';
declare variable $skosThesau:peopleBaseUri := $skosThesau:baseUri ||'/people/';
declare variable $skosThesau:schemes := doc('/db/apps/' || $skosThesau:thesaurus-app || 'Data/schemes/external-schemes.rdf');
declare variable $skosThesau:langList := string-join($skosThesau:appParam//languages//lang/text(), " "); 

(:
 :***************************
 :*     BUILDING TREES      *
 :***************************
  : There are 2 types of thesaurus tree that can be built:
  : 1) tree in json, to be used e.g. in fancytree JQuery : function skosThesau:buildThesaurus
  : 2) tree in HTML, to be used as hierarchically ordered dropdown menus : function skosThesau:dropDownThesau
  :
:)
(: testzz :)
declare function skosThesau:processData($type, $data, $lang, $conceptId, $conceptUri, $project, $dataFormat){
switch ($type)
    case "thesaurusDashboard"
        return skosThesau:dashboard($project)
   case "buildTree"
        return skosThesau:buildTreeJSon($lang)
   case "getTreeJSon"
        return skosThesau:getTree($dataFormat, $lang)

case "saveData"
        return skosThesau:saveData($data, $project)
   case "saveNTSortingOrderType"
        return skosThesau:saveNTSortingOrderType($data, $project)
  case "saveConceptType"
        return skosThesau:saveConceptType($data, $project)
   case "addExistingConceptasNT"
        return skosThesau:addExistingConceptasNT($data, $project)
   case "addNewConceptasNT"
        return skosThesau:addNewConceptasNT($data, $project)
   case "addNewAltLabel"
        return skosThesau:addNewAltLabel($data, $project)
   case "addNewPrefLabel"
        return skosThesau:addNewPrefLabel($data)
   case "deletePrefLabel"
        return skosThesau:deleteLabel($data)
   case "deleteRelation"
        return skosThesau:deleteRelation($data)
   case "displayConcept"
        return skosThesau:displayConcept($conceptId, $lang, $project)
   case "processConcept"
        return skosThesau:processConcept($conceptId, $conceptUri, $lang, $project)
   (:case "getData"
        return skosThesau:getData($conceptId, $lang, $project):)

   default return null
};

declare function skosThesau:dashboard($project as xs:string){
let $concepts-collection := collection('/db/apps/' || $project || 'Data/concepts')
let $concept-backup-collection := collection('/db/apps/' || $project || 'Data/backups/concepts')

let $schemes := $skosThesau:concept-collection//rdf:RDF/skos:ConceptScheme

let $allSchemeList :=
    <table class="table table-striped">

   <tr>
  <th>Name</th>
  <th>URL</th>
  <th>Editor(s)</th>
  <th/>
  <th/>
  <th>Status</th>
  <th>No. of <br/>Concepts</th>
  <th>No. of <br/>prefLabels</th>
  <th>No. of <br/>orphan Concepts</th>
  </tr>
   {
  for $scheme in $schemes
            let $schemeShortName := data(functx:substring-after-last(functx:substring-before-last($scheme/@rdf:about, '/'), '/'))
            let $topConceptUri := data($scheme/skos:hasTopConcept/@rdf:resource)
            let $noOfTopConcepts := count($scheme/skos:hasTopConcept)
(:            data(functx:substring-after-last($scheme/skos:hasTopConcept/@rdf:resource, '/')):)

    let $listOfConceptsAndCollections := $scheme/parent::node()//skos:Concept|$scheme/parent::node()//skos:Collection
    let $orphans := $listOfConceptsAndCollections[not(skos:broader)][@xml:id != $topConceptUri]
    let $noOfOrphans := count($orphans) - $noOfTopConcepts

order by $scheme/dc:title[@type='full']/text() ascending
  return

  <tr>
  <td>{data($scheme/dc:title[@type='full']/text())}</td>
  <td>{data($scheme/@rdf:about)}</td>
  <td>{for $editors at $pos in $scheme/dc:creator[@role='editor']
        return (concat(if($pos>1) then ', ' else (), $editors/text()))}</td>
  <td><a href="{$topConceptUri}" ><i class="glyphicon glyphicon-eye-open"/></a></td>
  <td><a href="{concat('/admin/scheme/', $schemeShortName) }" ><i class="glyphicon glyphicon-edit"/></a></td>
  <td>{data($scheme/thot:admin/@status)}</td>
  <td>{count($scheme/ancestor::*/skos:Concept)}</td>
  <td>{count($scheme/ancestor::*//skos:prefLabel)}</td>
  <td>{$noOfOrphans}</td>
  </tr>
}
</table>                    
                    
    return
            <div data-template="templates:surround"
                data-template-with="/templates/page.html" data-template-at="content">
            
             <div class="col-xs-12 col-sm-12 col-md-12">
             <h1>Dashboard</h1>
               <!-- Nav tabs -->
              <ul class="nav nav-tabs" role="tablist">
                <li role="presentation" class="active"><a href="#scheme" aria-controls="scheme" role="tab" data-toggle="tab">Scheme overview</a></li>
                <li role="presentation"><a href="#issues" aria-controls="issues" role="tab" data-toggle="tab">Requests</a></li>
                <li role="presentation"><a href="#logs" aria-controls="logs" role="tab" data-toggle="tab">Logs</a></li>
                <li role="presentation"><a href="#exportAndImport" aria-controls="exportAndImport" role="tab" data-toggle="tab">Export and Import data</a></li>
              </ul>
              
              {$allSchemeList}
              </div>
              </div>
 };
                                            
declare function skosThesau:rdfabout($project as xs:string, $uri as xs:string){

        let $appParam := doc('/db/apps/' || $project || '/data/app-general-parameters.xml')
        let $thesaurus-app := $appParam//thesaurus-app/text()
        let $data :=  collection("/db/apps/" || $thesaurus-app || "Data/concepts")

        return

        $data//.[@rdf:about =$uri]

};



declare function skosThesau:dropDownThesau($topConceptId as xs:string,
                                           $lang as xs:string?,
                                           $label as xs:string,
                                           $type as xs:string?,
                                           $index as xs:int?,
                                           $pos as xs:int?,
                                           $dataType as xs:string?){
             
let $indexNo := if($index) then data($index) else "1"
(:let $topConceptsURI :=
            for $tcs in $skosThesau:concept-collection//skos:ConceptScheme[@rdf:about[starts-with(., $skosThesau:thesBaseUri)]]
                return
                    $tcs//skos:hasTopConcept/@rdf:resource:)
let $rootNodes :=
       (: switch ($topConceptId)
            case "all" return
                       for $uri in $topConceptsURI
                            return
                            $skosThesau:concept-collection/id(substring-after($uri, "/concept/"))
            default return
       :)     $skosThesau:concept-collection/id($topConceptId)



let $formClass :=
         switch ($type)
            case "row" return "form-group row"
            case "inline" return "dropdown-inline"
            case "rowInnerLabel" return "form-group row"
            case "inlineInnerLabel" return "dropdown-inline col-sm-8"
            default return "form"

let $col :=
         switch ($label)
            case "noLabel" return ""

            default return "col-sm-8"

return

        <div class="{$formClass}">
              {
            if($label = "noLabel" or contains($type, "InnerLabel")) then()
            else
                <label for="selectDropDown{$topConceptId}_{$indexNo}_{$pos}" class="pull-left">{$label}</label>}
              <div class="{$col} elementWithValue">
                    <div class="dropdown">
                        <button id="selectDropDown{$topConceptId}_{$indexNo}_{$pos}" 
                        name="selectDropDown{$topConceptId}_{$indexNo}_{$pos}" 
                        value="" class="btn btn-xs btn-default dropdown-toggle elementWithValue" type="button" data-toggle="dropdown"
                        label="{ $label }"><em>{
            if(contains($type, "InnerLabel")) then($label)
            else "Select an item"}</em>
                        <span class="caret"></span></button>
                        <ul class="dropdown-menu">
                                {
                                for $child at $position in $rootNodes

                                    let $nts := $child//skos:narrower
                                    let $order :=data($child/@type)
                                    order by
                                          $child/skos:prefLabel[@xml:lang=$lang]/text()
                                    return
                                    <li>{if($position < 1)
                                        then <a tabindex="-1-{$position}" menu="#selectDropDown{$topConceptId}_{$indexNo}_{$pos}"
                                        value="{
                                                        if($dataType = '' or $dataType="uri") then
                                                        $child/@rdf:about
                                                        else $child//skos:prefLabel[@xml:lang="xml"]
                                                     }">{skosThesau:nodesInHTMLUl($nts, (), $child/@type, $lang, "selectDropDown" || $topConceptId, $indexNo, $pos, $dataType)}</a>
                                        else skosThesau:nodesInHTMLUl($nts, (), $child/@type, $lang, 'selectDropDown' || $topConceptId, $indexNo, $pos, $dataType)
                                        }</li>
                                }
                        </ul>
                </div>
             </div>
          </div>


};

declare function skosThesau:dropDownThesauXML($topConcept as xs:string,
                                           $lang as xs:string?,
                                           $label as xs:string,
                                           $type as xs:string?,
                                           $index as xs:int?,
                                           $pos as xs:int?,
                                           $dataType as xs:string?){
let $topConceptId := if(contains($topConcept, "http"))
      then functx:substring-after-last($topConcept, "/")
      else $topConcept
let $conceptPrefix := functx:substring-before-match($topConceptId, "[0-9]") 
let $uriRoot := data($skosThesau:appParam//thesauri//thesaurus[@idPrefix = $conceptPrefix]/@uriRoot)
let $indexNo := if($index) then data($index) else "1"
(:let $topConceptsURI :=
            for $tcs in $skosThesau:concept-collection//skos:ConceptScheme[@rdf:about[starts-with(., $skosThesau:thesBaseUri)]]
                return
                    $tcs//skos:hasTopConcept/@rdf:resource:)
let $rootNodes :=
       (: switch ($topConceptId)
            case "all" return
                       for $uri in $topConceptsURI
                            return
                            $skosThesau:concept-collection/id(substring-after($uri, "/concept/"))
            default return
       :)     $skosThesau:concept-collection/id($topConceptId)



let $formClass :=
         switch ($type)
            case "row" return "form-group row"
            case "inline" return "dropdown-inline"
            default return "form"

let $col :=
         switch ($label)
            case "noLabel" return ""

            default return "col-sm-8"
let $xslt := doc("/db/apps/ausohnum-library/xslt/jsonTree2html.xsl") 
let $params := <parameters>
    <param name="topConceptUri" value="{ $uriRoot || $topConceptId }"/>
    <param name="xmlElement" value="{ $topConceptId }"/>
    <param name="dataType" value="{ $dataType }"/>
    <param name="index" value="{ $index }"/>
    <param name="pos" value="{ $pos }"/>
    </parameters>
let $json := skosThesau:getTreeFromConcept($skosThesau:project, $uriRoot || $topConceptId, $lang)
let $htmlTree := transform:transform($json, $xslt, $params)

return

        <div class="{$formClass}">
              {
            if($label = "noLabel") then()
            else
                <label for="selectDropDown{ $topConceptId }_{$indexNo}_{$pos}" class="">{$label}</label>}
              <div class="{$col}">
                    { $htmlTree }
             </div>
          </div>


};

declare function skosThesau:dropDownThesauXMLMultiple($topConceptId as xs:string,
                                            $number as xs:int,
                                           $lang as xs:string?,
                                           $label as xs:string,
                                           $type as xs:string?,
                                           $index as xs:int?,
                                           $pos as xs:int?,
                                           $dataType as xs:string?){
let $conceptPrefix := functx:substring-before-match($topConceptId, "[0-9]")
let $uriRoot := data($skosThesau:appParam//thesauri//thesaurus[@idPrefix = $conceptPrefix]/@uriRoot)

let $indexNo := if($index) then data($index) else "1"
(:let $topConceptsURI :=
            for $tcs in $skosThesau:concept-collection//skos:ConceptScheme[@rdf:about[starts-with(., $skosThesau:thesBaseUri)]]
                return
                    $tcs//skos:hasTopConcept/@rdf:resource:)
let $rootNodes :=
       (: switch ($topConceptId)
            case "all" return
                       for $uri in $topConceptsURI
                            return
                            $skosThesau:concept-collection/id(substring-after($uri, "/concept/"))
            default return
       :)     $skosThesau:concept-collection/id($topConceptId)



let $formClass :=
         switch ($type)
            case "row" return "form-group row"
            case "inline" return "dropdown-inline"
            default return "form"

let $col :=
         switch ($label)
            case "noLabel" return ""

            default return "col-sm-8"
let $xslt := doc("/db/apps/ausohnum-library/xslt/jsonTree2html.xsl") 
let $json := skosThesau:getTreeFromConcept($skosThesau:project, $uriRoot || $topConceptId, $lang)
    
return
        
        <div class="{$formClass}">
              {
            if($label = "noLabel") then()
            else
                <label for="{ $topConceptId }_{$indexNo}_{$pos}" class="">{$label}</label>}
              <div id="multipleSelection{ $topConceptId }_{$indexNo}" class="{$col}">{ 
              for $no at $iter in 1 to $number
                    let $params := <parameters>
                      <param name="topConceptUri" value="{ $uriRoot || $topConceptId }"/>
                      <param name="xmlElement" value="{ $topConceptId }"/>
                      <param name="dataType" value="{ $dataType }"/>
                      <param name="index" value="{ $index }"/>
                      <param name="pos" value="{ $no }"/>
                      <param name="activateFollowing" value="{ sum(($no, 1)) }" />
                      </parameters>
        
                    let $htmlTree := transform:transform($json, $xslt, $params)
                    return
                    $htmlTree }
             </div>
          </div>


};

declare function skosThesau:dropDownThesauForElement($teiElementNickname as xs:string,
                                           $topConceptId as xs:string,
                                           $lang as xs:string?,
                                           $label as xs:string,
                                           $type as xs:string?,
                                           $index as xs:int?,
                                           $pos as xs:int?,
                                           $dataType as xs:string?){

let $indexNo := if($index) then $index else "1"
(:let $topConceptsURI :=
            for $tcs in $skosThesau:concept-collection//skos:ConceptScheme[@rdf:about[starts-with(., $skosThesau:thesBaseUri)]]
                return
                    $tcs//skos:hasTopConcept/@rdf:resource
:)
let $rootNodes :=
(:        switch ($topConceptId)
            case "all" return
                       for $uri in $topConceptsURI
                            return
                            $skosThesau:concept-collection/id(substring-after($uri, "/concept/"))
            default return
:)                        $skosThesau:concept-collection/id($topConceptId)



let $formClass :=
         switch ($type)
            case "row" return "form-group row"
            case "inline" return "dropdown-inline"
            default return "form"

let $col :=
         switch ($label)
            case "noLabel" return ""

            default return ""

return

        <div class="{$formClass}">{
            if($label = "noLabel") then()
            else
                <label for="{$teiElementNickname}_{$indexNo}_{$pos}" class="col-form-label">{$label}</label>}
              <div class="{$col} elementWithValue">
                    <div class="dropdown">
                        <button id="{$teiElementNickname}_{$indexNo}_{$pos}" nameOLD="{$topConceptId}_{$indexNo}_{$pos}" name="{$teiElementNickname}" value="" conceptHierarchy="" class="btn btn-xs btn-default dropdown-toggle elementWithValue" type="button" data-toggle="dropdown"><em>Select an item</em>
                        <span class="caret"></span></button>
                        <ul class="dropdown-menu">
                                {
                                for $child at $position in $rootNodes

                                    let $nts := $child//skos:narrower
                                    let $order :=data($child/@type)
                                    order by
                                          $child/skos:prefLabel[@xml:lang=$lang]/text()
                                    return
                                    <li>{if($position < 1)
                                        then <a tabindex="-1-{$position}" menu="#{$teiElementNickname}_{$indexNo}_{$pos}">{
                                        skosThesau:nodesInHTMLUl($nts, (), $child/@type, $lang, $teiElementNickname, $indexNo, $pos, $dataType)}</a>
                                        
                                        else skosThesau:nodesInHTMLUl($nts, (), $child/@type, $lang, $teiElementNickname, $indexNo, $pos, $dataType)}
                                        </li>
                                }
                        </ul>
                </div>
               <!-- <input id="{$teiElementNickname}_{$indexNo}_{$pos}selection" class="hidden" value=""/>-->
             </div>
          </div>


};

declare function skosThesau:dropDownThesauForElementWithConceptHierarchy($teiElementNickname as xs:string,
                                           $topConceptId as xs:string,
                                           $lang as xs:string?,
                                           $label as xs:string,
                                           $type as xs:string?,
                                           $index as xs:int?,
                                           $pos as xs:int?,
                                           $dataType as xs:string?){

let $indexNo := if($index) then $index else "1"
(:let $topConceptsURI :=
            for $tcs in $skosThesau:concept-collection//skos:ConceptScheme[@rdf:about[starts-with(., $skosThesau:thesBaseUri)]]
                return
                    $tcs//skos:hasTopConcept/@rdf:resource
:)
let $rootNodes :=
(:        switch ($topConceptId)
            case "all" return
                       for $uri in $topConceptsURI
                            return
                            $skosThesau:concept-collection/id(substring-after($uri, "/concept/"))
            default return
:)                        $skosThesau:concept-collection/id($topConceptId)



let $formClass :=
         switch ($type)
            case "row" return "form-group row"
            case "inline" return "dropdown-inline"
            default return "form"

let $col :=
         switch ($label)
            case "noLabel" return ""

            default return "col-sm-10"

return

        <div class="{$formClass}">{
            if($label = "noLabel") then()
            else
                <label for="{$teiElementNickname}_{$indexNo}_{$pos}" class="col-sm-2 col-form-label">{$label}</label>}
              <div class="{$col} elementWithValue">
                    <div class="dropdown">
                        <button id="{$teiElementNickname}_{$indexNo}_{$pos}" nameOLD="{$topConceptId}_{$indexNo}_{$pos}" name="{$teiElementNickname}" value="" class="btn btn-xs btn-default dropdown-toggle elementWithValue" type="button" data-toggle="dropdown"><em>Select an item</em>
                        <span class="caret"></span></button>
                        <ul class="dropdown-menu">
                                {
                                for $child at $position in $rootNodes

                                    let $nts := $child//skos:narrower
                                    let $order :=data($child/@type)
                                    order by
                                          $child/skos:prefLabel[@xml:lang=$lang]/text()
                                    return
                                    <li>{if($position < 1)
                                        then <a tabindex="-1-{$position}" menu="#{$teiElementNickname}_{$indexNo}_{$pos}">{
                                        skosThesau:nodesWithConceptHierarchyInHTMLUl($nts, (), $child/@type, $lang, $teiElementNickname, $indexNo, $pos, $dataType)}</a>
                                        
                                        else skosThesau:nodesWithConceptHierarchyInHTMLUl($nts, (), $child/@type, $lang, $teiElementNickname, $indexNo, $pos, $dataType)}
                                        </li>
                                }
                        </ul>
                </div>
               <!-- <input id="{$teiElementNickname}_{$indexNo}_{$pos}selection" class="hidden" value=""/>-->
             </div>
          </div>


};

declare function skosThesau:dropDownThesauForXMLElement($teiElementNickname as xs:string,
                                           $topConceptIdorUri as xs:string,
                                           $lang as xs:string?,
                                           $label as xs:string,
                                           $type as xs:string?,
                                           $index as xs:int?,
                                           $pos as xs:int?,
                                           $dataType as xs:string?){

let $topConceptIdorUri := if(contains($topConceptIdorUri, "http")) then $topConceptIdorUri
        else
            (let $conceptPrefix := functx:substring-before-match($topConceptIdorUri, "[0-9]")
             let $uriRoot := data($skosThesau:appParam//thesauri//thesaurus[@idPrefix = $conceptPrefix]/@uriRoot)
             return $uriRoot || $topConceptIdorUri
            )
let $indexNo := if($index) then $index else "1"
(:let $topConceptsURI :=
            for $tcs in $skosThesau:concept-collection//skos:ConceptScheme[@rdf:about[starts-with(., $skosThesau:thesBaseUri)]]
                return
                    $tcs//skos:hasTopConcept/@rdf:resource
:)
(:let $rootNodes :=
        switch ($topConceptId)
            case "all" return
                       for $uri in $topConceptsURI
                            return
                            $skosThesau:concept-collection/id(substring-after($uri, "/concept/"))
            default return
                        $skosThesau:concept-collection/id($topConceptId)

:)

let $formClass :=
         switch ($type)
            case "row" return "form-group row"
            case "inline" return "dropdown-inline"
            default return "form"

let $col :=
         switch ($label)
            case "noLabel" return ""

            default return "col-sm-10"
let $xslt := doc("/db/apps/ausohnum-library/xslt/jsonTree2html.xsl") 
let $params := <parameters>
    <param name="topConceptUri" value="{$topConceptIdorUri}"/>
    <param name="xmlElement" value="{ $teiElementNickname }"/>
    <param name="dataType" value="{ $dataType }"/>
    <param name="index" value="{ $indexNo }"/>
    <param name="pos" value="{ $pos }"/>
    </parameters>
let $json := skosThesau:getTreeFromConcept($skosThesau:project, $topConceptIdorUri, $lang)
let $htmlTree := transform:transform($json, $xslt, $params)
return

        <div class="{$formClass}">{
            if($label = "noLabel") then()
            else
                <label for="{$teiElementNickname}_{$indexNo}_{$pos}" class="col-sm-2 col-form-label">{$label}</label>}
              <div class="{$col}">{ $htmlTree }</div>
          </div>


};

declare function skosThesau:getTreeFromConcept($project as xs:string, $conceptUri as xs:string, $lang as xs:string){
        let $appParam := doc('/db/apps/' || $project || '/data/app-general-parameters.xml')
        let $thesaurusApp := $appParam//thesaurus-app/text()
        let $thesaurusUriBase := $thesaurusApp//uriBase[@type="thesaurus"]/text()
        let $concepts := doc('/db/apps/' || $thesaurusApp || 'Data/thesaurus/thesaurus-as-tree.xml')//thesaurus[@xml:lang=$lang]
         
        return
(:        $conceptUri:)
        $concepts//children[uri = $conceptUri]
                       };
declare function skosThesau:getTreeFromMultipleConcepts($project as xs:string, $conceptUris as xs:string, $rootLabel as xs:string, $lang as xs:string){
        let $appParam := doc('/db/apps/' || $project || '/data/app-general-parameters.xml')
        let $thesaurusApp := $appParam//thesaurus-app/text()
        let $thesaurus := doc('/db/apps/' || $thesaurusApp || 'Data/thesaurus/thesaurus-as-tree.xml')//thesaurus[@xml:lang=$lang]
        let $thesaurusUriBase := $appParam//uriBase[@type="thesaurus"]/text()
         
        return
            <children xmlns:json="http://www.json.org" json:array="true">
               <title>{ $rootLabel }</title>
                <id>root</id>
                <key>root</key>
                <isFolder>true</isFolder>
                <orderedCollection json:literal="true">true</orderedCollection>
                <lang>{ $lang }</lang>
                { for $conceptUri in tokenize($conceptUris, " ")
                    let $uri := $thesaurusUriBase || "/concept/" || $conceptUri
                    let $concept := $thesaurus//children[uri = $uri]
                    let $docCount := count(skosThesau:retrieveDocuments($project, $uri, ())//li)
                    let $peopleCount := count(skosThesau:retrievePeople($project, $uri)//data)
                    return 
                      if(exists($concept//children)) then $concept
                        else if(($docCount < 1) and ($peopleCount < 1)) then ()
                          else $concept
                        

                 }
            </children>
  };                       
declare function skosThesau:nodesInHTMLUl($nodes as element()*,
                       $visited as node()*,
                       $renderingOrder as xs:string?,
                       $lang as xs:string?,
                       $xmlElementNickname as xs:string?,
                       $index as xs:integer?,
                       $pos as xs:integer?,
                       $dataType as xs:string?){
      
      let $xmlElementNickname:=
        if($xmlElementNickname ='') then 'selectDropDown' else $xmlElementNickname
        
        
        return
            for $childnodes in $nodes
(:            except $visited:)
                let $id := substring-after($childnodes/@rdf:resource, "/concept/")
                let $ntSkosConcept :=
                    $skosThesau:concept-collection/id($id)
                
                let $title := 
                try {
                    if(exists($ntSkosConcept/skos:prefLabel[@xml:lang=$lang])) then
                                ( functx:capitalize-first($ntSkosConcept/skos:prefLabel[@xml:lang=$lang][1]/text())
                                )


                                else if ($ntSkosConcept/skos:prefLabel[@xml:lang='en']/text()) then
                                ( functx:capitalize-first($ntSkosConcept/skos:prefLabel[@xml:lang='en'][1]/text()) || ' (en)'
                                )
                                else if  ($ntSkosConcept/skos:prefLabel[@xml:lang='fr']/text()) then
                                    ( functx:capitalize-first($ntSkosConcept/skos:prefLabel[@xml:lang='fr'][1]/text()) || ' (fr)')
                                else if  ($ntSkosConcept//skos:prefLabel/text()) then
                                    ($ntSkosConcept[1]//skos:prefLabel[1]/text() || ' (' || data($ntSkosConcept/skos:prefLabel[1]/@xml:lang), ')' )
                          



                                else ("No label -")
                            }
                            catch * {"error in retrieving label"}
                
                order by
                           if (not($renderingOrder)) then $ntSkosConcept/skos:prefLabel[@xml:lang=$lang][1]/text() 
                                                                else (reverse($childnodes))
            return

                if ($ntSkosConcept//skos:narrower)
                  then(
                        <li class="dropdown-submenu">
                        <a  menu="#{$xmlElementNickname}_{$index}_{$pos}" value="{
                              if(not($dataType) or $dataType="uri")
                                        then $ntSkosConcept/@rdf:about
                                        else $ntSkosConcept//skos:prefLabel[@xml:lang="xml"]}"
                                        conceptHierarchyUris="{ string-join(($visited//@rdf:resource, $childnodes//@rdf:resource), " ")  }">{$title 
                                        }{
                                        if ($ntSkosConcept/name() ='skos:Collection')then(concat(' ', '&#62;')) else('')
                                        }<span class="caret"></span></a>
                        <ul class="dropdown-menu">
                        <li><a tabindex="-1" menu="#{$xmlElementNickname}_{$index}_{$pos}" value="{$ntSkosConcept/@rdf:about}"
                        conceptHierarchyUris="{ string-join(($visited//@rdf:resource, $childnodes//@rdf:resource), " ")  }">
                               {skosThesau:nodesInHTMLUl($ntSkosConcept//skos:narrower, ($visited, $childnodes), $ntSkosConcept/@type, $lang, $xmlElementNickname, $index, $pos, $dataType)}
                                </a>
                        </li>
                    </ul>
                </li>
                    )
                    else
                    (
                    <li><a tabindex="-1" menu="#{$xmlElementNickname}_{$index}_{$pos}" value="{
                    (:switch($dataType)
                        case "uri" return data($ntSkosConcept/@rdf:about)
                        default return data($ntSkosConcept//skos:prefLabel[@xml:lang="xml"]):)
                        if(not($dataType) or $dataType="uri") then
                            $ntSkosConcept/@rdf:about
                        else $ntSkosConcept//skos:prefLabel[@xml:lang="xml"]
                    }"
                    conceptHierarchyUris="{ string-join(($visited//@rdf:resource, $childnodes//@rdf:resource), " ")  }">{ $title 
                          }</a></li>
                    )



};

declare function skosThesau:nodesWithConceptHierarchyInHTMLUl($nodes as element()*,
                       $visited as node()*,
                       $renderingOrder as xs:string?,
                       $lang as xs:string?,
                       $xmlElementNickname as xs:string?,
                       $index as xs:integer?,
                       $pos as xs:integer?,
                       $dataType as xs:string?){
      
      let $xmlElementNickname:=
        if($xmlElementNickname ='') then 'selectDropDown' else $xmlElementNickname
        
        
        return
            for $childnodes in $nodes
(:            except $visited:)
                let $id := substring-after($childnodes/@rdf:resource, "/concept/")
                let $ntSkosConcept :=
                    $skosThesau:concept-collection/id($id)
                
                let $title := 
                try {
                    if(exists($ntSkosConcept/skos:prefLabel[@xml:lang=$lang])) then
                                ( functx:capitalize-first($ntSkosConcept/skos:prefLabel[@xml:lang=$lang][1]/text())
                                )


                                else if ($ntSkosConcept/skos:prefLabel[@xml:lang='en']/text()) then
                                ( functx:capitalize-first($ntSkosConcept/skos:prefLabel[@xml:lang='en'][1]/text()) || ' (en)'
                                )
                                else if  ($ntSkosConcept/skos:prefLabel[@xml:lang='fr']/text()) then
                                    ( functx:capitalize-first($ntSkosConcept/skos:prefLabel[@xml:lang='fr'][1]/text()) || ' (fr)')
                                else if  ($ntSkosConcept//skos:prefLabel/text()) then
                                    ($ntSkosConcept[1]//skos:prefLabel[1]/text() || ' (' || data($ntSkosConcept/skos:prefLabel[1]/@xml:lang), ')' )
                          



                                else ("No label -")
                            }
                            catch * {"error in retrieving label"}
                
                order by
                           if (not($renderingOrder)) then $ntSkosConcept/skos:prefLabel[@xml:lang=$lang][1]/text() 
                                                                else (reverse($childnodes))
            return

                if ($ntSkosConcept//skos:narrower)
                  then(
                        <li class="dropdown-submenu">
                        <a  menu="#{$xmlElementNickname}_{$index}_{$pos}" value="a{string-join($visited/@rdf:resource/string(), " ")}b{
                              if(not($dataType) or $dataType="uri")
                                        then $ntSkosConcept/@rdf:about
                                        else $ntSkosConcept//skos:prefLabel[@xml:lang="xml"]}">{$title 
                                        }{
                                        if ($ntSkosConcept/name() ='skos:Collection')then(concat(' ', '&#62;')) else('')
                                        }<span class="caret"></span></a>
                        <ul class="dropdown-menu">
                        <li><a tabindex="-1" menu="#{$xmlElementNickname}_{$index}_{$pos}" value="{$ntSkosConcept/@rdf:about}">
                               {skosThesau:nodesWithConceptHierarchyInHTMLUl($ntSkosConcept//skos:narrower, ($visited, $childnodes), $ntSkosConcept/@type, $lang, $xmlElementNickname, $index, $pos, $dataType)}
                                </a>
                        </li>
                    </ul>
                </li>
                    )
                    else
                    (
                    <li><a tabindex="-1" menu="#{$xmlElementNickname}_{$index}_{$pos}" value="a{string-join($visited/@rdf:resource/string(), " ")}b{
                    (:switch($dataType)
                        case "uri" return data($ntSkosConcept/@rdf:about)
                        default return data($ntSkosConcept//skos:prefLabel[@xml:lang="xml"]):)
                        if(not($dataType) or $dataType="uri") then
                            $ntSkosConcept/@rdf:about
                        else $ntSkosConcept//skos:prefLabel[@xml:lang="xml"]
                    }">{ $title 
                          }</a></li>
                    )



};

declare function skosThesau:buildTreeJSon($lang){
(:    let $lang := if(equals($lang, "")) then "en" else $lang:)
    let $collation :=  '?lang=' || lower-case($lang) || "-" || $lang
    let $currentUser := sm:id()//sm:real/sm:username/string()
    let $groups := string-join(sm:get-user-groups($currentUser), ' ')
    let $topConceptsURI :=

       if(
(:       sm:has-access(xs:anyURI('/db/apps/' || $skosThesau:project || '/modules/4access.xql') , 'r-x' ):)
        contains($groups, ('thesaurus_editors'))
       ) then
            (
            for $tcs in $skosThesau:concept-collection//skos:ConceptScheme[@rdf:about[starts-with(., $skosThesau:thesBaseUri)]]
                return
                    $tcs//skos:hasTopConcept/@rdf:resource
            )
        
        else if (
             contains($groups, ('sandbox')))
             then(
             (for $tcs in $skosThesau:concept-collection//skos:ConceptScheme[@status='sandbox'][@rdf:about[starts-with(., $skosThesau:thesBaseUri)]]
                return
                    $tcs//skos:hasTopConcept/@rdf:resource),
              (for $tcs in $skosThesau:concept-collection//skos:ConceptScheme[./@status='published'][@rdf:about[starts-with(., $skosThesau:thesBaseUri)]]
                     return
                $tcs//skos:hasTopConcept/@rdf:resource)
             )
        
        else
            (
            for $tcs in $skosThesau:concept-collection//skos:ConceptScheme[dc:contributor/@ref=$currentUser][@rdf:about[starts-with(., $skosThesau:thesBaseUri)]]|$skosThesau:concept-collection//skos:ConceptScheme[dc:creator/@ref=$currentUser][@rdf:about[starts-with(., $skosThesau:thesBaseUri)]]
            return
                $tcs//skos:hasTopConcept/@rdf:resource,
            for $tcs in $skosThesau:concept-collection//skos:ConceptScheme[skosThesau:admin/@status='published'][@rdf:about[starts-with(., $skosThesau:thesBaseUri)]]
            return
                $tcs//skos:hasTopConcept/@rdf:resource
            )



let $rootNodes :=
    for $uri in $topConceptsURI

    return
        $skosThesau:concept-collection/id(substring-after($uri, "/concept/"))

return
        serialize(
     <children xmlns:json="http://www.json.org" json:array="true">
         <title>Thesaurus {$skosThesau:thesaurus-app}</title>
         <id>{$skosThesau:appParam//idPrefix[@type="concept"]/text()}1</id>
         <key>{$skosThesau:appParam//idPrefix[@type="concept"]/text()}1</key>
          <isFolder>true</isFolder>
         <orderedCollection json:literal="true">true</orderedCollection>
         <lang>{$lang}</lang>
        { 
        sort(
            skosThesau:buildTree($rootNodes, $lang)
        , $collation)
        }
    </children>
        ,  <output:serialization-parameters>
                <output:method>xml</output:method>
                <output:media-type>application/xml</output:media-type>
            </output:serialization-parameters>
        )

};

declare function skosThesau:updateThesaurusTree($lang){
(:    let $lang := if(equals($lang, "")) then "en" else $lang:)
    let $collation :=  '?lang=' || lower-case($lang) || "-" || $lang
    let $currentUser := sm:id()//sm:real/sm:username/string()
    let $groups := string-join(sm:get-user-groups($currentUser), ' ')
    let $topConceptsURI :=
            $tcs//skos:hasTopConcept/@rdf:resource
        


let $rootNodes :=
    for $uri in $topConceptsURI

    return
        $skosThesau:concept-collection/id(substring-after($uri, "/concept/"))

return
        
     <children xmlns:json="http://www.json.org" json:array="true">
         <title>Thesaurus {$skosThesau:thesaurus-app}</title>
         <id>{$skosThesau:appParam//idPrefix[@type="concept"]/text()}1</id>
         <key>{$skosThesau:appParam//idPrefix[@type="concept"]/text()}1</key>
          <isFolder>true</isFolder>
         <orderedCollection json:literal="true">true</orderedCollection>
         <lang>{$lang}</lang>
        { sort(skosThesau:buildTree($rootNodes, $lang), $collation)}
    </children>
        

};
declare function skosThesau:buildThesaurus($topConceptId as xs:string, $lang as xs:string?){


let $topConceptsURI :=
            for $tcs in $skosThesau:concept-collection//skos:ConceptScheme[@rdf:about[starts-with(., $skosThesau:thesBaseUri)]]
                return
                    $tcs//skos:hasTopConcept/@rdf:resource
let $rootNodes :=
        switch ($topConceptId)
            case "all" return
                       for $uri in $topConceptsURI
                            return
                            $skosThesau:concept-collection/id(substring-after($uri, "/apc/concept/"))
            default return
            $skosThesau:concept-collection/id($topConceptId)


return
     <children xmlns:json="http://www.json.org" json:array="true">
                     <title>APC Thesaurus</title>
                     <key>apcc1</key>
                     <id>apcc1</id>
                     <isFolder>true</isFolder>
                     <orderedCollection json:literal="true">true</orderedCollection>
                            <lang>{$lang}</lang>
                        {skosThesau:buildTree($rootNodes, $lang)}
    </children>
};

declare function skosThesau:buildTree($rootNodes, $lang){
(:            let $children :=xmldb:get-child-collections($rootNodes):)
                let $collation :=  '?lang=' || lower-case($lang) || "-" || $lang
                for $child in $rootNodes

                let $nts := $child//skos:narrower
                let $id := data($child/@xml:id)
                let $uri := data($child/@rdf:about)
                let $order :=data($child/@type)
                (:order by
                      lower-case($child/skos:prefLabel[@xml:lang=$lang]/text()) collation "?lang=fr-FR"
:)
              return

              <children json:array="true" status="{data($child/@status)}" type="collectionItem">
                 <title>{ if($child/skos:prefLabel[@xml:lang=$lang][1]/text()) then
                            functx:capitalize-first($child/skos:prefLabel[@xml:lang=$lang][1]/text())
                        else if ($child/skos:prefLabel[@xml:lang="en"]/text()) then
                            (functx:capitalize-first($child/skos:prefLabel[@xml:lang='en'][1]/text()))
                        else if ($child/skos:prefLabel[@xml:lang='fr']/text())
                        then (functx:capitalize-first($child/skos:prefLabel[@xml:lang='fr'][1]/text()))
                        else("no label")

                 }</title>
                 <id>{ $id }</id>
                 <uri>{ $uri }</uri>
                 <key>{ $id }</key>
                 <lang>{$lang}</lang>
                 <isFolder>true</isFolder>{ 
                 skosThesau:nodes($nts, (), data($child/@type), $lang)
                 }</children>

};


declare function skosThesau:nodes($nodes, $visited, $renderingOrder, $lang){
  
  let $draftConcepts := for $concepts in $nodes//skos:Concept[skosThesau:admin[@status='draft']]
                               (: ,
                               $collections in $nodes//skos:Collection[skosThesau:admin[@status='draft']]:)
                              return  ($concepts)

            return

            for $childnodes in $nodes except ($visited, $draftConcepts)
                let $ntUri := $childnodes/@rdf:resource
                let $ntId := substring-after($ntUri, "/concept/")
                let $ntSkosConcept :=
                    $skosThesau:concept-collection/id($ntId)
                let $ntStatus := data($ntSkosConcept/@status)
                let $title := 
                    try {
                    if(exists($ntSkosConcept/skos:prefLabel[@xml:lang=$lang])) then
                                ( functx:capitalize-first($ntSkosConcept/skos:prefLabel[@xml:lang=$lang][1]/text())
                                )


                                else if ($ntSkosConcept/skos:prefLabel[@xml:lang='en']/text()) then
                                ("bb"||
                                    functx:capitalize-first($ntSkosConcept/skos:prefLabel[@xml:lang='en'][1]/text()) || ' (en)'
                                )
                                else if  ($ntSkosConcept/skos:prefLabel[@xml:lang='fr']/text()) then
                                    (functx:capitalize-first($ntSkosConcept/skos:prefLabel[@xml:lang='fr'][1]/text()) || ' (fr)')
                                else if  ($ntSkosConcept//skos:prefLabel/text()) then
                                    (
                                            $ntSkosConcept[1]//skos:prefLabel[1]/text() || ' (' || data($ntSkosConcept/skos:prefLabel[1]/@xml:lang), ')' )
                          



                                else ("No label -")
                }
                catch * {"error in retrieving label"}
                let $order := data($ntSkosConcept/node()/@ype)
                order by 
                    if ($renderingOrder = "ordered") then reverse($childnodes)
                    else (lower-case($title[1]))
                (:order by
                    if ($renderingOrder = "ordered") then reverse($childnodes)
                    else (lower-case(
                           if(exists($ntSkosConcept//skos:prefLabel[@xml:lang=$lang][not(ancestor-or-self::skos:exactMatch)]/text())) then
                           translate($ntSkosConcept//skos:prefLabel[@xml:lang=$lang][1][not(ancestor-or-self::skos:exactMatch)]/text(),'Â, Ê, É','A, E, E')
                            else if(exists($ntSkosConcept//skos:prefLabel[@xml:lang="en"][not(ancestor-or-self::skos:exactMatch)]/text())) then
                            translate($ntSkosConcept//skos:prefLabel[@xml:lang="en"][1][not(ancestor-or-self::skos:exactMatch)]/text(),'Â, Ê, É','A, E, E')
                            else if(exists($ntSkosConcept//skos:prefLabel[@xml:lang="fr"][not(ancestor-or-self::skos:exactMatch)]/text())) then
                            translate($ntSkosConcept//skos:prefLabel[@xml:lang="fr"][1][not(ancestor-or-self::skos:exactMatch)]/text(),'Â, Ê, É','A, E, E')
                            else if(exists($ntSkosConcept//skos:prefLabel[@xml:lang="de"][not(ancestor-or-self::skos:exactMatch)]/text())) then
                            translate($ntSkosConcept//skos:prefLabel[@xml:lang="de"][1][not(ancestor-or-self::skos:exactMatch)]/text(),'Â, Ê, É','A, E, E')
                            else if(exists($ntSkosConcept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)]/text())) then
                            translate($ntSkosConcept//skos:prefLabel[1][not(ancestor-or-self::skos:exactMatch)]/text(),'Â, Ê, É','A, E, E')
                            else if (exists($ntSkosConcept//skos:altLabel/text()))
                            then (translate($ntSkosConcept//skos:altLabel[1]/text(),'Â, Ê, É','A, E, E'))
                            else ("Error")
                    )):)
                    
                    
                     (:
                     if($renderingOrder ="ordered") then order by reverse($childnodes)
                     else order by $ntSkosConcept/skos:prefLabel[@xml:lang=$lang]:)
            return

                if ($ntSkosConcept//skos:narrower)
                  then(
                       <children json:array="true" status="{ $ntStatus }" type="collectionItem">
                                <title>{if ($ntSkosConcept/name() ='skos:Collection')then(concat('&#65308;', ' ')) else('')}{
                                $title
                                }{
                                if ($ntSkosConcept/name() ='skos:Collection') then(concat(' ', '&#65310;')) else('')}</title>
                                <id>{ $ntId }</id>
                                <uri>{ $ntUri }</uri>
                                <key>{ $ntId }</key>
                                <lang>{$lang}</lang>
                                <isFolder>true</isFolder>
                                { skosThesau:nodes($ntSkosConcept//skos:narrower, ($visited, $childnodes), data($ntSkosConcept/@type), $lang)
                                        }
                        </children>
                    )
                    else
                    (
                    <children json:array="false" status="{ $ntStatus}" type="collectionItem">
                        <title>{$title
                        
                        (:if(exists($ntSkosConcept/skos:prefLabel[@xml:lang=$lang])) then
                                (
                                concat(functx:capitalize-first($ntSkosConcept/skos:prefLabel[@xml:lang=$lang][1]/text()),
                                functx:capitalize-first($ntSkosConcept/dc:title/text()))
                                ) else if ($ntSkosConcept/skos:prefLabel[@xml:lang='en']/text()) then
                                (concat(functx:capitalize-first($ntSkosConcept/skos:prefLabel[@xml:lang='en'][1]//text()), ' (en)',
                                functx:capitalize-first($ntSkosConcept/dc:title[1]/text())))
                                else if  ($ntSkosConcept/skos:prefLabel[@xml:lang='fr']/text()) then
                                (concat(functx:capitalize-first($ntSkosConcept/skos:prefLabel[@xml:lang='fr'][1]//text()), ' (fr)',
                                functx:capitalize-first($ntSkosConcept/dc:title[1]/text())))
                                else if  ($ntSkosConcept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)]) then
                                (concat(functx:capitalize-first($ntSkosConcept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][1]), ' (', data($ntSkosConcept/skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][1]/@xml:lang), ')',
                                functx:capitalize-first($ntSkosConcept/dc:title[1]/text())))
                                
                                else ("no label." || serialize($ntSkosConcept))
                        :)        }</title>
                        <id>{ $ntId }</id>
                        <uri>{ $ntUri }</uri>
                        <key>{ $ntId }</key>
                        <lang>{$lang}</lang>
                    </children>
                    )

(:, $collation):)   

};

declare function skosThesau:getTree( $dataFormat as xs:string, $lang as xs:string){
        let $currentUser := sm:id()//sm:real/sm:username/string()
        let $groups := string-join(sm:get-user-groups($currentUser), ' ')
        let $userGroups := 
                for $group in tokenize($groups, " ") return (string($group))
        let $concepts := doc('/db/apps/' || $skosThesau:thesaurus-app || 'Data/thesaurus/thesaurus-as-tree.xml')//thesaurus[@xml:lang=$lang]
         
        let $thesaurus :=
                if(contains($groups, ('thesaurus_editors'))) then 
                        $concepts//children[@groups]        
                else (
                        
                        $concepts//children[@groups][contains(./@status, "published")],
                        $concepts//children[contains(./@groups, $userGroups)])
        return
        switch($dataFormat)
            case "json" return
        serialize(
        <children xmlns:json="http://www.json.org" json:array="true">
    <title>Thesaurus ausohnum</title>
    <id>c1</id>
    <key>c1</key>
    <isFolder>true</isFolder>
    <orderedCollection json:literal="true">true</orderedCollection>
    <lang>en</lang>
        { $thesaurus }
        </children>,  <output:serialization-parameters>
                <output:method>{ $dataFormat}</output:method>
                <output:media-type>application/{ $dataFormat }</output:media-type>
            </output:serialization-parameters>
        )
        case "xml" return 
            <children xmlns:json="http://www.json.org" json:array="true">
                <title>Thesaurus ausohnum</title>
                <id>c1</id>
                <key>c1</key>
                <isFolder>true</isFolder>
                <orderedCollection json:literal="true">true</orderedCollection>
                <lang>en</lang>
            { $thesaurus}
            </children>
        default return 
        <children xmlns:json="http://www.json.org" json:array="true">
                <title>Thesaurus ausohnum</title>
                <id>c1</id>
                <key>c1</key>
                <isFolder>true</isFolder>
                <orderedCollection json:literal="true">true</orderedCollection>
                <lang>en</lang>
            { $thesaurus}
            </children>

        
};

(:declare function skosThesau:getChildren($parentConceptUri as xs:string, $lang as xs:string){
  (\:let $parentConceptId := functx:substring-after-last($uriConcept, '/'):\)
  
  let $parentConcept :=util:eval( "collection('/db/apps/" 
(\:  || "ausohnum":\)
  || $skosThesau:thesaurus-app 
  || "Data/concepts')//node()[matches(./@rdf:about, '" || $parentConceptUri || "')]")
             
  return
   <children>
    {for $child in $parentConcept//skos:narrower
    let $childConcept := $skosThesau:concept-collection//.[matches(./@rdf:about, data($child/@rdf:resource))]
    let $prefLabel := $childConcept//skos:prefLabel[@xml:lang=$lang]/text()
return
        $childConcept
    }
</children>
          
};

:)
declare function skosThesau:updateConceptsForTree($project as xs:string, $conceptUri as xs:string, $concept-collection as item()*){
   let $thesaurus-app  := doc('/db/apps/' || $project || '/data/app-general-parameters.xml')//thesaurus-app/text()
   let $langList := string-join(doc('/db/apps/' || $project || '/data/app-general-parameters.xml')//languages//lang/text(), " ")
   let $topConcept := <concept rdf:resource="{ $conceptUri }"/>
   let $schemesTopConceptsUri := doc('/db/apps/'|| $thesaurus-app || "Data/thesaurus/thesaurus-as-tree.xml")//topConceptsUris
   let $isSchemeTopConcept := exists($schemesTopConceptsUri//topConceptUri[./text() = $topConcept/@rdf:resource])
   return
    <newNodesForConceptTree>{
    for $lang in tokenize($langList, " ")
        let $collation :=  '?lang=' || lower-case($lang) || "-" || $lang
        return
        <thesaurus xml:lang="{ $lang }">
{ sort(skosThesau:rebuildNodeForThesaurus($project, $topConcept, (), $lang, $isSchemeTopConcept))
            }
    </thesaurus>
    }</newNodesForConceptTree>
};

declare function skosThesau:rebuildNodeForThesaurus($project as xs:string,
                                                                                               $nodes, 
                                                                                               $renderingOrder as xs:string?,
                                                                                               $lang as xs:string?,
                                                                                               
                                                                                               $schemeTopConcept as xs:boolean?){
   
   
  
  (:let $draftConcepts := for $concepts in $nodes//skos:Concept[skosThesau:admin[@status='draft']],
                              $collections in $nodes//skos:Collection[skosThesau:admin[@status='draft']]
                              return  ($concepts)
:)
(:            return:)

            for $childnode in $nodes 
(:                        except ($visited):)
                let $id := substring-after($childnode/@rdf:resource, "/concept/")
                let $ntSkosConcept := $skosThesau:concept-collection/id($id)
                let $nonDescriptorStart := if ($ntSkosConcept/name() ='skos:Collection') then (concat('&#65308;', ' ')) else('')
                let $nonDescriptorEnd := 
                        if ($ntSkosConcept/name() ='skos:Collection') then (concat(' ', '&#65310;')) else('')
                let $title := $nonDescriptorStart || 
                            (if($ntSkosConcept/skos:prefLabel[@xml:lang=$lang][1]/text()) then
                            functx:capitalize-first($ntSkosConcept/skos:prefLabel[@xml:lang=$lang][1]/text())
(:                            else ( functx:capitalize-first($ntSkosConcept/skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][1]/text()) :)
                            else ( functx:capitalize-first($ntSkosConcept/child::skos:prefLabel[1]/text())
                                        || " (" || data($ntSkosConcept/child::skos:prefLabel[1]/@xml:lang) || ")"
                            ))
                            || $nonDescriptorEnd
                let $xmlValue := $ntSkosConcept/skos:prefLabel[@xml:lang='xml'][1]/text()
                (:let $title :=
                    for $prefLabel in $ntSkosConcept//skos:prefLabel
                        return
                        if (count( tokenize($prefLabel/@xml:lang, " ")) = 1 ) then 
                            element{ $prefLabel/@xml:lang }{ $nonDescriptorStart || functx:capitalize-first($prefLabel/text()) || $nonDescriptorEnd}
                        else (
                            for $lang in tokenize($prefLabel/@xml:lang, " ") return 
                            element{ $lang }{ $nonDescriptorStart || functx:capitalize-first($prefLabel/text()) || $nonDescriptorEnd}
                        ):)
                 (:try {
                    if(exists($ntSkosConcept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang=$lang])) then
                                ( functx:capitalize-first($ntSkosConcept/skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang=$lang][1]/text())
                                )


                                else if (exists($ntSkosConcept/skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang='en']/text())) then
                                (
                                    functx:capitalize-first($ntSkosConcept/skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang='en'][1]/text()) || ' (en)'
                                )
                                else if  (exists($ntSkosConcept/skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang='fr']/text())) then
                                    (functx:capitalize-first($ntSkosConcept/skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang='fr'][1]/text()) || ' (fr)')
                                else if  (exists($ntSkosConcept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)]/text())) then
                                    ($ntSkosConcept[1]//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][1]/text() || ' (' || data($ntSkosConcept/skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][1]/@xml:lang), ')' )
                          



                                else ("No label -")
                }
                catch * {"error in retrieving label"}:)
                
                let $uri := data($ntSkosConcept/@rdf:about)
                let $status := if(data($ntSkosConcept/@status) != "") then data($ntSkosConcept/@status) else "draft"
               let $order := $ntSkosConcept/@type

                order by
                    if ($renderingOrder = "ordered") then reverse($childnode)
                    else $title[1]
                   (:else (lower-case(if(exists($ntSkosConcept//skos:prefLabel[@xml:lang=$lang][not(ancestor-or-self::skos:exactMatch)]/text())) then
                           translate($ntSkosConcept//skos:prefLabel[@xml:lang=$lang][1][not(ancestor-or-self::skos:exactMatch)]/text(),'Â, Ê, É','A, E, E')
                            else if(exists($ntSkosConcept//skos:prefLabel[@xml:lang="en"][not(ancestor-or-self::skos:exactMatch)]/text())) then
                            translate($ntSkosConcept//skos:prefLabel[@xml:lang="en"][1][not(ancestor-or-self::skos:exactMatch)]/text(),'Â, Ê, É','A, E, E')
                            else if(exists($ntSkosConcept//skos:prefLabel[@xml:lang="fr"][not(ancestor-or-self::skos:exactMatch)]/text())) then
                            translate($ntSkosConcept//skos:prefLabel[@xml:lang="fr"][1][not(ancestor-or-self::skos:exactMatch)]/text(),'Â, Ê, É','A, E, E')
                            else if(exists($ntSkosConcept//skos:prefLabel[@xml:lang="de"][not(ancestor-or-self::skos:exactMatch)]/text())) then
                            translate($ntSkosConcept//skos:prefLabel[@xml:lang="de"][1][not(ancestor-or-self::skos:exactMatch)]/text(),'Â, Ê, É','A, E, E')
                            else if(exists($ntSkosConcept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)]/text())) then
                            translate($ntSkosConcept//skos:prefLabel[1][not(ancestor-or-self::skos:exactMatch)]/text(),'Â, Ê, É','A, E, E')
                            else if (exists($ntSkosConcept//skos:altLabel/text()))
                            then (translate($ntSkosConcept//skos:altLabel[1]/text(),'Â, Ê, É','A, E, E'))
                            else ("Error")
                    )):)
                    
                    
                     (:
                     if($renderingOrder ="ordered") then order by reverse($childnodes)
                     else order by $ntSkosConcept/skos:prefLabel[@xml:lang=$lang]:)
            return

                if ($ntSkosConcept//skos:narrower)
                  then(
                    element children {
                          attribute json:array {"true"},
                          attribute status { $status },
                          attribute type { "collectionItem" },
                          if($schemeTopConcept = true())
                                then (attribute groups {data($ntSkosConcept/@groups)}) else (),
                                    element title { $title },
                                    element id { $id },
                                    element uri { $uri },
                                    element key { $id },
                                    element xmlValue { $xmlValue },
                                    element lang {$lang},
                                    element isFolder {"true"},
                                 skosThesau:rebuildNodeForThesaurus($project, $ntSkosConcept//skos:narrower,
                                                $ntSkosConcept/@type, $lang, ())
                                                    
                                }
                    
                       
                    )
                    else
                    (
                    <children json:array="false" status="{ $status }" type="collectionItem">
                        <title>{ $title }</title>
                        <id>{ $id }</id>
                        <uri>{ $uri }</uri>
                        <key>{ $id }</key>
                        <xmlValue>{ $xmlValue }</xmlValue>
                        <lang>{$lang}</lang>
                    </children>
                    )

(:, $collation):)

};

declare function skosThesau:getChildren($parentConceptUri as xs:string, $project as xs:string){
  (:let $parentConceptId := functx:substring-after-last($uriConcept, '/'):)
  let $thesaurus-app  := doc('/db/apps/' || $project || '/data/app-general-parameters.xml')//thesaurus-app/text()
  let $conceptCollection := collection('/db/apps/'|| $thesaurus-app || "Data/concepts") 
  let $parentConcept :=
    ($conceptCollection//skos:Concept[./@rdf:about = $parentConceptUri],  $conceptCollection//skos:Collection[./@rdf:about = $parentConceptUri])
(:  let $parentConcept := $conceptCollection//skos:Concept[matches(./@rdf:about, $parentConceptUri)]:)
(:  let $parentConcept := $conceptCollection//skos:Concept[./@rdf:about = $parentConceptUri]:)
(:  let $parentConcept :=util:eval( "collection('/db/apps/" 
(\:  || "ausohnum":\)
  || $thesaurus-app 
  || "Data/concepts')//skos:Concept[./@rdf:about = $parentConceptUri]")
:)             
  return
   <children>{
    for $child in $parentConcept//skos:narrower
        let $uri := data($child/@rdf:resource)
        let $childConcept := $conceptCollection//skos:Concept[./@rdf:about = $uri]
        return
        (
            $childConcept,
                    if($childConcept//skos:narrower) then
                      (
                            for $subchild in $childConcept//skos:narrower
                             let $subchildConcept :=
                                    ($conceptCollection//skos:Concept[./@rdf:about = $subchild/@rdf:resource]|
                                    $conceptCollection//skos:Collection[./@rdf:about = $subchild/@rdf:resource])
                         
                             return
                                        (
                                        
                                        skosThesau:getChildNodes($subchildConcept, $project)
                                        
                                        )
                         )
                else(
(:                $childConcept:)
                )
                )
}</children>
          
};


declare function skosThesau:getChildNodes($conceptNode as node(), $project as xs:string){
  (:let $parentConceptId := functx:substring-after-last($uriConcept, '/'):)
  let $thesaurus-app  := doc('/db/apps/' || $project || '/data/app-general-parameters.xml')//thesaurus-app/text()

let $conceptCollection := collection('/db/apps/'|| $thesaurus-app || "Data/concepts") 
  (:let $parentConcept :=
    ($conceptCollection//skos:Concept[./@rdf:about = $parentConceptUri],  $conceptCollection//skos:Collection[./@rdf:about = $parentConceptUri]):)
(:  let $parentConcept := $conceptCollection//skos:Concept[matches(./@rdf:about, $parentConceptUri)]:)
(:  let $parentConcept := $conceptCollection//skos:Concept[./@rdf:about = $parentConceptUri]:)
(:  let $parentConcept :=util:eval( "collection('/db/apps/" 
(\:  || "ausohnum":\)
  || $thesaurus-app 
  || "Data/concepts')//skos:Concept[./@rdf:about = $parentConceptUri]")
:)             
  return
   <child>
   {$conceptNode}
    {for $child in $conceptNode//skos:narrower 
        let $uri := data($child/@rdf:resource)
        let $childConcept := $conceptCollection//skos:Concept[./@rdf:about = $uri]|$conceptCollection//skos:Collection[./@rdf:about = $uri]
        return
            (
            $childConcept,
(:            "HERE" || "URI= " ||  $uri || $childConcept || "THERE",:)
            if($childConcept//skos:narrower) then
                    for $narrower in $childConcept//skos:narrower
                        let $subchildConcept :=
                        ($conceptCollection//skos:Concept[./@rdf:about = data($narrower/@rdf:resource)],
                        $conceptCollection//skos:Collection[./@rdf:about = data($narrower/@rdf:resource)])
                        return 
                            (
(:                            $subchildConcept,:)
                            if($subchildConcept) then
                                skosThesau:getChildNodes($subchildConcept[1], $project)
                            else (
                            $childConcept
                            )
                            )
                else(
                
                )
            
             )   
    }</child>
          
};

declare function skosThesau:listConceptAsCheckboxes($concepts as node(), $lang as xs:string){
        
        <div>
        {
        for $concept at $pos in $concepts//skos:Concept
        return
            <input class="" value="{ $concept/@rdf:about }" type="checkbox" name="feature_{ $pos }">
            { $concept//skos:prefLabel[@xml:lang=$lang]/text()}
            </input>
                }
                </div>
};

(:
**************************
*      Display Data      *
**************************
:)

declare function skosThesau:displayConcept($conceptId as xs:string,
                                           $lang as xs:string,
                                           $project as xs:string)

{
<div  data-template="templates:surround" data-template-with="./templates/page.html" data-template-at="content">
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
                      <img id="lang-en" class="langflag{if($lang='en') then " activeLang" else()}" src="/$ausohnum-lib/resources/images/flags/gb.png"/>
                      <img id="lang-de" class="langflag{if($lang='de') then " activeLang" else()}" src="/$ausohnum-lib/resources/images/flags/de.png"/>
                      <img id="lang-fr" class="langflag{if($lang='fr') then " activeLang" else()}" src="/$ausohnum-lib/resources/images/flags/fr.png"/>
                      <img id="lang-ar" class="langflag{if($lang='ar') then " activeLang" else()}" src="/$ausohnum-lib/resources/images/flags/ar.png"/>
                      <!--            <span class="lang-en lang-lbl" lang="en"></span>-->
                  </div>
                  <div id="collection-tree" data-type="json"/>
              </div>
              <div id="rightSide" class="col-xs-8 col-sm-8 col-md-8">

                  <div id="conceptContent" class="position-sticky">
                          <div data-template="skosThesau:processConcept" data-template-conceptId="{ $conceptId }"
                          data-template-language="{ $lang }" data-template-project="{ $project }" />
                  </div>



              </div>

          </div>
      </div>
      <script type="text/javascript" src="/$ausohnum-lib/resources/scripts/skosThesau/skosThesauTree.js"/>


  </div>
};




declare function skosThesau:templatingProcessConceptOLD($node as node(),
                                            $model as map(*),
                                            $conceptId as xs:string,
                                            $lang as xs:string?){
  let $groups := string-join(sm:get-user-groups(sm:id()//sm:real/sm:username/string()), ' ')
  let $lang := if (not($lang)) then "en" else $lang
  let $concept := $skosThesau:concept-collection/id($conceptId)
  let $conceptUri := data($concept/@rdf:about)
  let $schemeURI := data($concept//skos:inScheme/@rdf:resource)
  let $schemeNode := $skosThesau:concept-collection//skos:ConceptScheme[@rdf:about=$schemeURI]
  let $nodeType := name($concept)
  let $schemeName := $schemeNode//dc:title[@type='short']
  let $conceptStatus := data($concept//skosThesau:admin/@status)
  let $schemeStatus := data($schemeNode//skosThesau:admin/@status)

  let $title :=
    <div class="page-header concept-header">
      <h1 id="prefLabelCurrentLang">
      {if($nodeType = "skos:Collection") then concat("<", " ") else ()}
        { if($concept/skos:prefLabel[@xml:lang=$lang]) then
        (upper-case(substring($concept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang=$lang]/text(), 1, 1)) || substring($concept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang=$lang]/text(), 2)
        )
        else if($concept/skos:prefLabel[@xml:lang="en"]) then
        (upper-case(substring($concept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang="en"]/text(), 1, 1)) || substring($concept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang="en"]/text(), 2)) || " (en)"
        else if($concept/skos:prefLabel[@xml:lang="fr"]) then
        (upper-case(substring($concept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang="fr"]/text(), 1, 1)) || substring($concept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang="fr"]/text(), 2)) || " (fr)"
     else if($concept/skos:prefLabel[@xml:lang="de"]) then
        (upper-case(substring($concept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang="de"]/text(), 1, 1)) || substring($concept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang="de"]/text(), 2)) || " (de)"
        else if($concept/skos:prefLabel[@xml:lang="de"]) then
        (upper-case(substring($concept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang="it"]/text(), 1, 1)) || substring($concept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang="it"]/text(), 2)) || " (it)"
        else ""
        }
          {if($nodeType = "skos:Collection") then concat(" ", ">") else ()}
            <span class="conceptTag"> Concept <em>{$conceptId}</em></span></h1>
        </div>

let $prefLabels :=
    <div class="panel panel-default panel-terms">
           <div class="panel-heading">
              <h2 class="panel-title">Preferred Terms{
              if(contains($groups, ('thesaurus_editors'))
              ) then
                            skosThesau:addPrefLabelButton($conceptId)

                                else()
               }
               <span class="skosLabel"> (skos:prefLabel)
              <a title="" data-html="true" data-toggle="popover" data-content="For more details about skos:prefLabel, see the Skos &lt;a
            ">
                                <i class="glyphicon glyphicon-question-sign
                skosQuestion"></i></a>
                </span></h2>
           </div>
           <div class="panel-body">
              <ul id="prefLabel-list" class="term-list">
                {
                  for $prefLabel at $pos in $concept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)]
                    let $value := if ($prefLabel/@xml:lang = "xml") then ($prefLabel) else upper-case(substring($prefLabel, 1, 1)) || substring($prefLabel, 2)
                    let $lang := data($prefLabel/@xml:lang)

                  return

(:                   let $groups := string-join(sm:get-user-groups(sm:id()//sm:real/sm:username/string()), ' '):)
(:                    return:)
                            if(contains($groups, ('thesaurus_editors')))
                   then (

                     <li class="term-list-item">
                         {skosThesau:displayAndEditLabel($conceptId, $value, 'prefLabel', "test", $lang, $pos)}
                     </li>

                    )
              else (
                    <li class="term-list-item">
                    {$value || " (" || $lang || ")"}
                    </li>
                    )

                }
              </ul>
           </div>
        </div>
let $altLabels :=
    <div class="panel panel-default panel-terms">
           <div class="panel-heading">
              <h2 class="panel-title">Alternative Terms
              {
(:              if(sm:has-access(xs:anyURI('/db/apps/' || $skosThesau:project || '/modules/4access.xql') , 'r-x' )) :)
              let $groups := string-join(sm:get-user-groups(sm:id()//sm:real/sm:username/string()), ' ')
                    return
                           if(contains($groups, ('thesaurus_editors')))
              then
                                (
                            skosThesau:addAltLabelButton($conceptId)
                            )
                                else()
               }
              <span class="skosLabel"> (skos:altLabel)
              <a title="" data-html="true" data-toggle="popover" data-content="For more details about skos:prefLabel, see the Skos &lt;a">
                                <i class="glyphicon glyphicon-question-sign
                skosQuestion"></i></a>
                </span>
                </h2>

           </div>
           <div class="panel-body">
              <ul id="altLabel-list" class="term-list">
                {
                  for $altLabel at $pos in $concept//skos:altLabel[not(ancestor-or-self::skos:exactMatch)]
                    let $value := upper-case(substring($altLabel, 1, 1)) || substring($altLabel, 2)
                    let $lang := data($altLabel/@xml:lang)
                    order by $value

                        return
                            if(contains($groups, ('thesaurus_editors')))
                    then (

                     <li class="term-list-item">
                         {skosThesau:displayAndEditLabel($conceptId, $value, 'altLabel', $lang, "test", $pos)}
                     </li>

                    )
              else (
                    <li class="term-list-item">
                    {$value || " (" || $lang || ")"}
                    </li>
                    )
                }
              </ul>
           </div>
        </div>

let $schemeNote :=
<div class="row">
<div class="panel panel-default panel-genNote">
          <div class="panel-heading">
                  <h2 class="panel-title">Scheme note <span class="skosLabel"> (skos:ConceptScheme)<a title="" data-html="true" data-toggle="popover" data-content="For more "
                  data-original-title="Skos: Concept Scheme"><i class="glyphicon glyphicon-question-sign skosQuestion"></i></a></span></h2>
               </div>
               <div class="panel-body">
                 <span class="h5">Publisher:</span> {$schemeNode/dc:publisher}
                 <br/>
                 <span class="h5">Editor &amp; contributors:</span>
                  <ul>
                    {for $people in  $schemeNode//dc:creator[@role='editor']
                    order by $people ascending
                    return
                      <li>
                      {$people/text()} ({$people/@role/string()})
                    </li>
                    }
                    {for $people in  $schemeNode//dc:creator[@role='contributor']
                    order by functx:substring-after-last($people, ' ') ascending
                    return
                      <li>
                      {$people/text()} ({$people/@role/string()})
                    </li>
                    }
                  </ul>
               </div>
            </div>
            </div>
let $temporalExtent :=
  <div class="panel panel-default panel-date panel-terms">
                 <div class="panel-heading">
                    <h2 class="panel-title">Temporal Extent
                       <span class="skosLabel"> (time:TemporalEntity)<a title="" data-html="true" data-toggle="popover" data-content="For more details about " data-original-title="Time:Temporal
                                      Entity"><i class="glyphicon glyphicon-question-sign
                      skosQuestion"></i></a></span></h2>
                 </div>
                 <div class="panel-body">

                   {for $temp in $concept//time:TemporalEntity
                      return

                          <span class="dateEntry">
                            {if(starts-with($temp/periodo:earliestYear, '-'))
                              then
                              (
                                if($temp/periodo:latestYear <0)
                                then
                                  (
                                    concat(substring($temp/periodo:earliestYear, 2), " - ", substring($temp/periodo:latestYear, 2), " ", $skosThesau:appParam//item[@type='bc'][@xml:lang=$lang])
                                  )
                                  else if($temp/periodo:latestYear >0)
                                  then
                                    (
                                      concat(substring($temp/periodo:earliestYear, 2), " ", $skosThesau:appParam//item[@type='bc'][@xml:lang=$lang], " - ", $temp/periodo:latestYear, " ", $skosThesau:appParam//item[@type='ad'][@xml:lang=$lang])
                                    )
                                    else()
                              )
                            else(
                              concat($temp/periodo:earliestYear, " - ", $temp/periodo:latestYear, " ", $skosThesau:appParam//item[@type='ad'][@xml:lang=$lang])
                            )

                            }
                          </span>
                 }
                 </div>
              </div>
let $exactMatches :=
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
                        let $schemeShortname := $skosThesau:schemes//skos:ConceptScheme[@rdf:about=$schemeURI]/dc:title/dcterms:alternative
                        let $schemeLongname := $skosThesau:schemes//skos:ConceptScheme[@rdf:about=$schemeURI]/dc:title[not(child::dcterms:alternative)]
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


let $logHistory :=
       <div class="row">
       <div class="panel panel-default">
            <div class="panel-heading">
                 <div class="panel-title"> Changes history</div>
              </div>
              <div class="panel-body">
                <table class="table table-striped">
                    <tr>
                        <th>Type of event</th>
                        <th>User</th>
                        <th>When</th>
                        <th>Comments</th>
                    </tr>

                      {
                        for $log in $skosThesau:logs-collection//.[@what=$conceptId]
                            order by $log/@when descending
                        return
                          <tr>
                                <td>{data($log/@type)}</td>

                                <td>{data($log/@who)}</td>
                                <td>{concat(substring(data($log/@when), 1, 10), ' ', substring(data($log/@when), 12, 5))}</td>
                                <td>
                                {$log//description/text()}</td>
                          </tr>
                          }
                 </table>
              </div></div></div>


return
  if(not($concept))
    then (<h3>
      There is no concept with an ID <em>{$conceptId}</em> in project {$skosThesau:project}
  </h3>)
  else if (($schemeStatus != "published"
            and
            not(
                contains($groups, ('thesaurus_editors'))
            )
            )
            or
            ($schemeStatus != "published"
            and
            not(
            contains($groups, ('thesaurus_editors'))
            )
            )
            ) then
            (
            <div>
                <h4>You have to be loggued in to access this resource</h4>
                    <a href="#loginDialog" class="" data-toggle="modal" title="Login"><button type="button" class="btn btn-primary">Login</button></a>
                    </div>
                )
              else

<div>
{$title}
<div class="URI"><span class="pastilleLabelBlue pastilleURI">URI </span>{data($concept/@rdf:about)}
         </div>
    {if(contains($groups, ('thesaurus_editors'))) then (
    <div class="row">
        <div class="pull-right"><span class="pastilleLabelBlue pastilleURI">Concept Status </span>{$conceptStatus}</div>
        <div class="pull-right"><span class="pastilleLabelBlue pastilleURI">Scheme Status </span>{$schemeStatus}</div>
    </div>

              )else()}

 <div class="row">
          {$prefLabels}
             {if( $concept//skos:altLabel) then
                     $altLabels
                       else(
                       if(contains($groups, ('thesaurus_editors'))
                       ) then (
                        $altLabels )
                       else()
                       )
                   }

               {if( $concept//skos:broader) then
                     skosThesau:displayRelatedConceptList($conceptId, "broader", "test", $lang)
                       else if (not($concept//skos:broader) and (sm:has-access(xs:anyURI('/db/apps/' || $skosThesau:project || '/modules/4access.xql'), 'r-x' ))) then
                       skosThesau:displayRelatedConceptList($conceptId, "broader", "editor", $lang)
                       else ()

               }

               {if( $concept//skos:narrower) then
                     (skosThesau:displayRelatedConceptList($conceptId, "narrower", "editor", $lang))
                       else if (not($concept//skos:narrower) and (
                       contains($groups, ('thesaurus_editors')))) then
                       (skosThesau:displayRelatedConceptList($conceptId, "narrower", "editor", $lang))
                       else ()
                   }


                   {if( $concept//time:TemporalEntity) then
                     $temporalExtent
                     else if (not($concept//skos:TemporalEntity) and (
                     contains($groups, ('thesaurus_editors')))
                     ) then
                     $temporalExtent
                     else()
                   }
                   {if($concept//skos:exactMatch) then
                     (
                     $exactMatches)
                     else if (not($concept//skos:exactMatch) and (
                     contains($groups, ('thesaurus_editors')))
                     ) then (
                     $exactMatches)
                     else()

                   }


                   </div>
                   {$schemeNote}
                   {$copyright}

     {if(contains($groups, ('thesaurus_editors'))) then
     ($logHistory)else()}
     <!--Script for fancytree-->
        <!-- Include Fancytree skin and library -->
        <!--
        <link href="$ausohnum-lib/resources/scripts/jquery/fancytree/skin-bootstrap/ui.fancytree.css" rel="stylesheet" type="text/css"/>
        <link href="$ausohnum-lib/resources/css/skosThesau.css" rel="stylesheet" type="text/css"/>
        <script src="$ausohnum-lib/resources/scripts/jquery/fancytree/jquery.fancytree-all.min.js" type="text/javascript"/>
        <script src="$ausohnum-lib/resources/scripts/jquery/fancytree/jquery.fancytree.filter.js" type="text/javascript"/>
        <script src="$ausohnum-lib/resources/scripts/jquery/fancytree/jquery.fancytree.glyph.js" type="text/javascript"/>
        <script src="$ausohnum-lib/resources/scripts/jquery/fancytree/jquery.fancytree.wide.js" type="text/javascript"/>
        <script src="$ausohnum-lib/resources/scripts/skosThesau/skosThesauTree.js" type="text/javascript" />
        <script src="$ausohnum-lib/resources/scripts/skosThesau/skosThesauActions.js" type="text/javascript" />
-->
                 </div>


};

declare function skosThesau:templatingProcessConcept($node as node(),
                                            $model as map(*),
                                            $conceptId as xs:string,
                                            $lang as xs:string?){
                     skosThesau:processConcept($conceptId, (), $lang, 'ausohnum')
};



declare function skosThesau:processConcept(
                                            $conceptId as xs:string,
                                            $conceptUri as xs:string?,
                                            $lang as xs:string?,
                                            $project as xs:string){

let $lang := if (not($lang)) then "en" else $lang
let $currentUser := sm:id()//sm:real/sm:username/string()
let $groups := string-join(sm:get-user-groups($currentUser), ' ')
let $appParam := doc('/db/apps/' || $skosThesau:project || '/data/app-general-parameters.xml')
let $thesaurus-app := $skosThesau:appParam//thesaurus-app/text()
let $concept-collection := collection('/db/apps/' || $skosThesau:thesaurus-app || 'Data/concepts')
  let $concept := if($conceptId) then $concept-collection/id($conceptId)
                                else $conceptUri


  let $conceptUri := data($concept/@rdf:about)
  let $schemeURI := data($concept//skos:inScheme/@rdf:resource)
  let $schemeNode := $skosThesau:concept-collection//skos:ConceptScheme[@rdf:about=$schemeURI]
  let $nodeType := name($concept)
  let $schemeName := $schemeNode//dc:title[@type='short']
  let $conceptStatus := data($concept//skosThesau:admin/@status)
  let $schemeStatus := data($schemeNode//skosThesau:admin/@status)
  let $schemeCreators := data($schemeNode//dc:creator/@ref)
  let $schemeContributors := data($schemeNode//dc:contributor/@ref)
  let $userRights :=
        if (contains($groups, ('sandbox'))) then "sandbox"
        
        else if(contains($groups, ('thesaurus_editors'))) then "editor"
        
        else if (contains($schemeContributors, $currentUser)) then "contributor"
        else if (contains($schemeCreators, $currentUser)) then "editor"
        else ("guest")
 let $orderingType := data($concept/@type)

  let $title :=
    <div class="page-header concept-header">
      <h1 id="prefLabelCurrentLang">
        {if($nodeType = "skos:Collection") then concat("<", " ") else ()}
        { if($concept/skos:prefLabel[@xml:lang=$lang]) then
        ( functx:capitalize-first($concept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang=$lang]/text())
        )
        else if($concept/skos:prefLabel[@xml:lang="en"]) then
        (functx:capitalize-first($concept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang="en"]/text()) || " (en)")
        else if($concept/skos:prefLabel[@xml:lang="fr"]) then
        (functx:capitalize-first($concept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang="fr"]/text()) || " (fr)")
     else if($concept/skos:prefLabel[@xml:lang="de"]) then
        (functx:capitalize-first($concept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang="de"]/text()) || " (de)")
        else if($concept/skos:prefLabel[@xml:lang="de"]) then
        (functx:capitalize-first($concept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang="it"]/text()) || " (it)")
        else if($concept//skos:prefLabel) then
        (functx:capitalize-first($concept//skos:prefLabel[1][not(ancestor-or-self::skos:exactMatch)]/text()) || " (" ||
        data($concept//skos:prefLabel[1][not(ancestor-or-self::skos:exactMatch)]/@xml:lang) || ")"
        )
        
        else ""
        }
          {if($nodeType = "skos:Collection") then concat(" ", ">") else ()}
            <span class="conceptTag"> Concept <em>{$conceptId}</em></span></h1>
        </div>


let $prefLabels :=
    <div class="panel panel-default panel-terms">
           <div class="panel-heading">
              <h2 class="panel-title">Preferred Terms
              {
             if(
                contains($userRights, ('editor', 'contributor'))
                )
              then
                                (
                            skosThesau:addPrefLabelButton($conceptId)
                            )
                                else()
               }
               <span class="skosLabel"> (skos:prefLabel)
              <a title="" data-html="true" data-toggle="popover" data-content="For more details about skos:prefLabel, see the Skos &lt;a
            ">
                                <i class="glyphicon glyphicon-question-sign
                skosQuestion"></i></a>
                </span></h2>
           </div>
           <div class="panel-body">
              <ul id="prefLabel-list" class="term-list">
                {
                  for $prefLabel at $pos in $concept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)]
                    let $value := if ($prefLabel/@xml:lang = "xml") then ($prefLabel) else functx:capitalize-first($prefLabel)
                    let $lang := data($prefLabel/@xml:lang)

                  return
                    if(contains($userRights, ('editor', 'contributor')))
                        then (
                        <li class="term-list-item">
                         {skosThesau:displayAndEditLabel($conceptId, $value, 'prefLabel', $lang, $userRights, $pos)}
                        </li>

                    )
              else (
                    <li class="term-list-item">
                    {$value || " (" || $lang || ")"}
                    </li>
                    )

                }
              </ul>
           </div>
        </div>
let $altLabels :=
    <div class="panel panel-default panel-terms">
           <div class="panel-heading">
              <h2 class="panel-title">Alternative Terms
              {
(:              if(sm:has-access(xs:anyURI('/db/apps/' || $skosThesau:project || '/modules/4access.xql') , 'r-x' )) :)
             (: let $groups := string-join(sm:get-user-groups(sm:id()//sm:real/sm:username/string()), ' ')
                    return:)
                            if(
             contains($userRights, ('editor', 'contributor'))
             )
              then
                                (
                            skosThesau:addAltLabelButton($conceptId)
                            )
                                else()
               }
              <span class="skosLabel"> (skos:altLabel)
              <a title="" data-html="true" data-toggle="popover" data-content="For more details about skos:prefLabel, see the Skos &lt;a">
                                <i class="glyphicon glyphicon-question-sign
                skosQuestion"></i></a>
                </span>
                </h2>

           </div>
           <div class="panel-body">
              <ul id="altLabel-list" class="term-list">
                {
                  for $altLabel at $pos in $concept//skos:altLabel[not(ancestor-or-self::skos:exactMatch)]
                    let $value := functx:capitalize-first($altLabel)
                    let $lang := data($altLabel/@xml:lang)
                    order by $value
                  return
(:                    if (sm:has-access(xs:anyURI('/db/apps/' || $skosThesau:project || '/modules/4access.xql') , 'r-x' )) :)
                   (: let $groups := string-join(sm:get-user-groups(sm:id()//sm:real/sm:username/string()), ' ')
                        return:)
                            if(
                                contains($userRights, ('editor', 'contributor')))
                    then (

                     <li class="term-list-item">
                         {skosThesau:displayAndEditLabel($conceptId, $value, 'altLabel', $lang, $userRights, $pos)}
                     </li>

                    )
              else (
                    <li class="term-list-item">
                    {$value || " (" || $lang || ")"}
                    </li>
                    )
                }
              </ul>
           </div>
        </div>

let $schemeNote :=
<div class="row">
<div class="panel panel-default panel-genNote">
          <div class="panel-heading">
                  <h2 class="panel-title">Scheme note <span class="skosLabel"> (skos:ConceptScheme)<a title="" data-html="true" data-toggle="popover" data-content="For more "
                  data-original-title="Skos: Concept Scheme"><i class="glyphicon glyphicon-question-sign skosQuestion"></i></a></span></h2>
               </div>
               <div class="panel-body">
                 <span class="h5">Publisher:</span> {$schemeNode/dc:publisher}
                 <br/>
                 <span class="h5">Editor &amp; contributors:</span>
                  <ul>
                    {for $people in  $schemeNode//dc:creator[@role='editor']
                    order by $people ascending
                    return
                      <li>
                      {$people/text()} ({ data($people/@role) })
                    </li>
                    }
                    {for $people in  $schemeNode//dc:creator[@role='contributor']
                    order by functx:substring-after-last($people, ' ') ascending
                    return
                      <li>
                      {$people/text()} ({ data($people/@role) })
                    </li>
                    }
                  </ul>
               </div>
            </div>
            </div>
let $temporalExtent :=
if($concept//time:TemporalEntity) then 
  <div class="panel panel-default panel-date panel-terms">
                 <div class="panel-heading">
                    <h2 class="panel-title">Temporal Extent
                       <span class="skosLabel"> (time:TemporalEntity)<a title="" data-html="true" data-toggle="popover" data-content="For more details about " data-original-title="Time:Temporal
                                      Entity"><i class="glyphicon glyphicon-question-sign
                      skosQuestion"></i></a></span></h2>
                 </div>
                 <div class="panel-body">

                   {for $temp in $concept//time:TemporalEntity
                      return

                          <span class="dateEntry">
                            {if(starts-with($temp/periodo:earliestYear, '-'))
                              then
                              (
                                if($temp/periodo:latestYear <0)
                                then
                                  (
                                    concat(substring($temp/periodo:earliestYear, 2), " - ", substring($temp/periodo:latestYear, 2), " ", $skosThesau:appParam//item[@type='bc'][@xml:lang=$lang])
                                  )
                                  else if($temp/periodo:latestYear >0)
                                  then
                                    (
                                      concat(substring($temp/periodo:earliestYear, 2), " ", $skosThesau:appParam//item[@type='bc'][@xml:lang=$lang], " - ", $temp/periodo:latestYear, " ", $skosThesau:appParam//item[@type='ad'][@xml:lang=$lang])
                                    )
                                    else()
                              )
                            else(
                              concat($temp/periodo:earliestYear, " - ", $temp/periodo:latestYear, " ", $skosThesau:appParam//item[@type='ad'][@xml:lang=$lang])
                            )

                            }
                          </span>
                 }
                 </div>
              </div>
          else ()(:No temporal extent:)
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
                        let $schemeShortname := $skosThesau:schemes//skos:ConceptScheme[@rdf:about=$schemeURI]/dc:title/dcterms:alternative
                        let $schemeLongname := $skosThesau:schemes//skos:ConceptScheme[@rdf:about=$schemeURI]/dc:title[not(child::dcterms:alternative)]
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


let $logHistory :=
            if(not(
                contains($userRights, ('editor', 'contributor'))
                )) then ()  else
       <div class="row">
       <div class="panel panel-default">
            <div class="panel-heading">
                 <div class="panel-title"> Changes history</div>
              </div>
              <div class="panel-body">
                <table class="table table-striped">
                    <tr>
                        <th>Type of event</th>
                        <th>User</th>
                        <th>When</th>
                        <th>Comments</th>
                    </tr>

                      {
                        for $log in $skosThesau:logs-collection//log[@what=$conceptId]
                         let $when := data($log/@when)
                            order by $log/@when descending
                        return
                          <tr>
                                <td>{data($log/@type)}</td>

                                <td>{data($log/@who)}</td>
                                <td>{concat(substring($when, 1, 10), ' ', substring($when, 12, 5))}</td>
                                <td>
                                {$log//description/text()}</td>
                          </tr>
                          }
                 </table>
              </div></div></div>


return
  if(not($concept))
    then (<h3>
      There is no concept with an ID <em>{$conceptId}</em> in project {$skosThesau:project}
  </h3>)
  else if (
            ($schemeStatus = "published")
            or
            (
             
                contains($userRights, ('editor', 'contributor'))
                        
            ))
            
  then

<div>
            {if(contains($userRights, ('editor', 'contributor'))) then (
                     <div class="row">
                     <form enctype="multipart/form-data" method="post" action="/$ausohnum-lib/modules/skosThesau/export-scheme.xql">
                        <input type="text" name="schemeUri" value="{ $schemeURI }" class="hidden"></input>
                        <input type="text" name="schemeName" value="{ $schemeName }" class="hidden"></input>
                        <input type="text" name="project" value="{ $skosThesau:project }" class="hidden"></input>
                        
                        <button class="btn btn-warning btn-sm pull-right" type="submit" style="margin: 2px;">Download Scheme</button>
                        </form>
                        <button class="btn btn-warning btn-sm pull-right" onclick="updateThesaurusTree()" style="margin: 2px;">Update thesaurus tree</button>
                     </div>)
              else()}

{$title}
<div class="URI"><span class="pastilleLabelBlue pastilleURI">URI </span>{data($concept/@rdf:about)}
         </div>
    {if(
                contains($userRights, ('editor', 'contributor'))
                ) then (
                     <div class="row">
                         <div class="pull-right"><span class="pastilleLabelBlue pastilleURI">Concept Status </span>{$conceptStatus}</div>
                         <div class="pull-right"><span class="pastilleLabelBlue pastilleURI">Scheme Status </span>{$schemeStatus}</div>
                 
                     </div>,
                     skosThesau:conceptOrCollection($conceptId, $lang)
                 
                               )
              else()}


<div class="row">
             {$prefLabels}
             {if( $concept//skos:altLabel) then
                     $altLabels
                       else(
                       if(
                            contains($userRights, ('editor', 'contributor'))
                            ) then (
                        $altLabels )
                       else()
                       )
                   }

               {if( $concept//skos:broader) then
                     skosThesau:displayRelatedConceptList($conceptId, "broader", $userRights, $lang)
                       else if (not($concept//skos:broader) and (
                                contains($userRights, ('editor', 'contributor'))
                            )
                       ) then
                       skosThesau:displayRelatedConceptList($conceptId, "broader", $userRights, $lang)
                       else ()

               }

               {if( $concept//skos:narrower) then
                     (skosThesau:displayRelatedConceptList($conceptId, "narrower", $userRights, $lang))
                       else if (not($concept//skos:narrower) and (
                            contains($userRights, ('editor', 'contributor'))
                            )) then
                       (skosThesau:displayRelatedConceptList($conceptId, "narrower", $userRights, $lang))
                       else ()
                   }


                   {if( $concept//time:TemporalEntity) then
                     $temporalExtent
                     else if (not($concept//skos:TemporalEntity) and (
                            contains($userRights, ('editor', 'contributor'))
                              )
                              ) then
                     $temporalExtent
                     else()
                   }
                   {if($concept//skos:exactMatch) then
                     (
                     $exactMatches)
                     else if (not($concept//skos:exactMatch) and (
                        contains($userRights, ('editor', 'contributor'))
                )) then (
                     $exactMatches)
                     else()

                   }


                   </div>
                   {$schemeNote}
                   { if(
                contains($userRights, ('editor', 'contributor'))
                ) then (skosThesau:retrieveDocuments("patrimonium", $conceptUri, ()),
                skosThesau:retrievePeople("patrimonium", $conceptUri))else ()}
                
                   {$copyright}
        
     { $logHistory }

        <script type="text/javascript" src="/$ausohnum-lib/resources/scripts/skosThesau/skosThesauActions.js"/>
                 </div>
else 
            (
            <div>Rights of user: {$userRights}
                <h4>You have to be loggued in to access this resource</h4>
                <h5>Group: {$groups} - User : {sm:id()//sm:real/sm:username/string()}</h5>
                <h5>Scheme status: { $schemeStatus } - Concept status: { $conceptStatus  }</h5>
                    <a href="#loginDialog" class="" data-toggle="modal" title="Login"><button type="button" class="btn btn-primary">Login</button></a>
                   { $schemeNode}
                   SchmeNode: {$schemeContributors}
                    </div>
                )
  

};
declare function skosThesau:conceptOrCollection($conceptId as xs:string, $lang as xs:string){
    let $concept := $skosThesau:concept-collection/id($conceptId)
    let $conceptType := $concept/name()
    let $isConcept := if($conceptType ="skos:Concept") then
                                        "primary" else "secondary"
    let $isCollection := if($conceptType ="skos:Collection") then "primary" else
                                        "secondary"

    return
    <div class="panel"><h5>Type of Concept <a title="" data-html="true" data-toggle="popover" data-content="Explication">
                                <i class="glyphicon glyphicon-question-sign
                skosQuestion"></i></a></h5>
        <button id="isConceptButton" type="button" class="btn btn-{$isConcept} btn-xs disabled" onclick="toggleSelectConceptType('{$conceptId}')">concept</button>
        <button id="isCollectionButton" type="button" class="btn btn-{$isCollection} btn-xs disabled" onclick="toggleSelectConceptType('{$conceptId}')">collection</button>
        <button id="editConceptType" class="transparentButton"
                                onclick="editConceptType()"
                                appearance="minimal" type="button"><i class="glyphicon glyphicon-edit"></i></button>
        <button id="saveConceptType" class="btn btn-success btn-xs hidden"
                                    onclick="saveConceptType('{$conceptId}', '{$lang}')"
                                    appearance="minimal" type="button"><i class="glyphicon
                                    glyphicon glyphicon-ok-circle"></i></button>
        <button id="conceptTypeCancelEdit" class="btn btn-danger btn-xs hidden"
                                    onclick="cancelEditConceptType()"
                                    appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>

    </div>

};

declare function skosThesau:sortingOrderInTree($conceptId as xs:string, $lang as xs:string){
    let $concept := $skosThesau:concept-collection/id($conceptId)
    let $orderingType := data($concept/@type)
    let $alpha := if($orderingType ="ordered") then
                                        "secondary" else "primary"
    let $non-alpha := if($orderingType ="ordered") then "primary" else
                                        "secondary"

    return
    <div class="panel"><h5>Sorting order in hierarchical tree</h5>
        <button id="ntsorting_alpha" type="button" class="btn btn-{$alpha} btn-xs disabled" onclick="toggleSelectSortingOrder('{$conceptId}')">alpha</button>
        <button id="ntsorting_nonalpha" type="button" class="btn btn-{$non-alpha} btn-xs disabled" onclick="toggleSelectSortingOrder('{$conceptId}')">non-alpha</button>
        <button id="edit_NT_sorting_order" class="transparentButton"
                                onclick="editNTSortingOrder()"
                                appearance="minimal" type="button"><i class="glyphicon glyphicon-edit"></i></button>
        <button id="saveNT_sorting_orderButton" class="btn btn-success btn-xs hidden"
                                    onclick="saveNTSortingOrderType('{$conceptId}', '{$lang}')"
                                    appearance="minimal" type="button"><i class="glyphicon
                                    glyphicon glyphicon-ok-circle"></i></button>
        <button id="editSortingOrderCancelEdit" class="btn btn-danger btn-xs hidden"
                                    onclick="cancelEditSortingOrder()"
                                    appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>

    </div>

};

declare function skosThesau:loggedInRequired(){
<div>
     <p>You have to be loggued in to access this resource</p>
      <a href="#loginDialog" class="" data-toggle="modal" title="Login"><button type="button" class="btn btn-primary">Login</button></a>

</div>};




declare function skosThesau:displayThesauAsSelect($thesau as xs:string, $label as xs:string, $lang as xs:string?, $valueType as xs:string?, $bootstrapType as xs:string?){
let $thesauNodes := $skosThesau:concept-collection//.[skos:ConceptScheme[dc:title[@type="short"] = $thesau]]


return
<div class="form-group row">
        <label for="personStatus" class="col-sm-2 col-form-label">{functx:capitalize-first($label)}</label>
        <div class="col-sm-10">
        <select id="{$thesau}Select">
            {for $concepts in $thesauNodes//.[skos:prefLabel[not(ancestor-or-self::skos:exactMatch)]]
            let $value := switch ($valueType)
                    case "id" return data($concepts/@xml:id)
                    case "uri" return data($concepts/@rdf:about)
                    default return data($concepts/@rdf:about)
            return

                <option value="{$value}">{$concepts//skos:prefLabel[@xml:lang=$lang]}</option>
             }
          </select>
       </div>
     </div>
};

declare function skosThesau:callConcept(){
    let $conceptId :=  request:get-parameter("conceptId", ())
    let $lang :=  request:get-parameter("lang", "en")

    return
    <div id="thotContent" data-template="processConcept:fullConcept" data-template-conceptId="{ $conceptId }" data-template-language="{ $lang }"/>
};

declare function skosThesau:displayAndEditLabel($conceptId as xs:string,
                                                $labelValue as xs:string,
                                                $elementName as xs:string,
                                                $lang as xs:string,
                                                $userRights as xs:string,
                                                $index as xs:int){
            <div>
            <div id="{$elementName}_{$lang}_display" class="">
                            <div id="{$elementName}_{$lang}_value" class="elementValue">{$labelValue} ({$lang})
                            <button id="edit_{$elementName}_{$lang}" class="transparentButton"
                                onclick="editValue('{$elementName}', '{$lang}', {$index})"
                                appearance="minimal" type="button"><i class="glyphicon glyphicon-edit"></i></button>
                             <button id="delete_{$elementName}_{$lang}" class="transparentButton"
                                onclick="deleteLabel('{$elementName}', '{$conceptId}', '{$lang}', '{$index}', '{$labelValue}')"
                                appearance="minimal" type="button"><i class="glyphicon glyphicon-trash"></i></button>
                                </div>
                        </div>


                        <div id="{$elementName}_{$lang}_edit" class="elementHidden form-group">
                            <div class="input-group" >
                                <input id="{$elementName}_{$lang}_input" class="form-control" name="prefLabel_{$lang}_input" value="{$labelValue}"></input>
                                <button id="{$elementName}_{$lang}SaveButton" class="btn btn-success"
                                    onclick="saveData('{$elementName}', '{$lang}', '{$conceptId}', {$index}, '{$labelValue}')"
                                    appearance="minimal" type="button"><i class="glyphicon
                                    glyphicon glyphicon-ok-circle"></i></button>
                                <button id="{$elementName}_{$lang}CancelEdit" class="btn btn-danger"
                                    onclick="cancelEdit('{$elementName}', '{$lang}', '{$labelValue}', {$index})"
                                    appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>

                            </div>
                         </div>
           </div>
};

declare function skosThesau:displayAndEditRelatedTerm($conceptId as xs:string,
                                                      $rtId as xs:string,
                                                      $rtUri as xs:string,
                                                      $labelValue as xs:string,
                                                      $relationType as xs:string,
                                                      $index as xs:int,
                                                      $userRights,
                                                      $lang as xs:string?){
            let $labelValue := if($labelValue ="") then "Error" else $labelValue
            return
            <div>
            <div id="{$relationType}_display" class="">
                            <div id="{$relationType}_value" class="elementValue">
                            <a class="conceptLink"  onclick="loadOnClickConcept('{$rtId}', '{$lang}')" title="{$rtUri}">
        { $labelValue }</a>


                             <button id="delete_{$relationType}_{$index}" class="transparentButton"
                                onclick="deleteRelatedConcept('{$relationType}', '{$conceptId}', '{$rtId}', '{$rtUri}', '{$lang}')"
                                appearance="minimal" type="button"><i class="glyphicon glyphicon-trash"></i></button>
                                </div>
                        </div>

           </div>
};





declare function skosThesau:displayRelatedConceptList($conceptId as xs:string,
                                                      $relationType as xs:string,
                                                      $userRights as xs:string,
                                                      $language as xs:string?
                                                      )
                                                      {
           let $concept := $skosThesau:concept-collection/id($conceptId)
           let $schemeUri := data($concept//skos:inScheme[not(ancestor-or-self::skos:exactMatch)]/@rdf:resource)
           let $schemeStatus := data($skosThesau:concept-collection//skos:ConceptScheme[@rdf:about=$schemeUri]//skosThesau:admin/@status)
           let $groups := string-join(sm:get-user-groups(sm:id()//sm:real/sm:username/string()), ' ')
           return
           <div id="{$relationType}-panel" class="panel panel-default panel-terms">
                             <div class="panel-heading">
                                <h2 class="panel-title">{upper-case(substring($relationType, 1, 1)) ||  substring($relationType, 2)} Terms
                                {if(
                                    contains($userRights, ('editor', 'contributor'))
                                    )
                                                then
                                (
                                 if($relationType = "narrower") then skosThesau:addNTButton($conceptId)
                                    else()
                            )
                                else()
                                }
                                <span class="skosLabel"> (skos:{$relationType})<a title="" data-html="true" data-toggle="popover" data-content="" data-original-title="skos:
                                                  {$relationType}"><i class="glyphicon glyphicon-question-sign
                                  skosQuestion"></i></a></span>

                                  </h2>
                                   {if(
                                   ($relationType = "narrower") 
                                   and 
                                   (
                                   contains($userRights, ('editor', 'contributor'))
                                   )
                                   )
                                   
                                   
                                   
                                   then
                                        skosThesau:sortingOrderInTree($conceptId, $language)

                                else ()}
                             </div>
                             <div class="panel-body">


                                <ul id="{$relationType}-list" class="term-list">
                                      {
                                         switch($relationType)
                                         case "broader" return
                                         (
                                         for $bt at $pos in $concept//skos:broader
                                            let $btId := substring-after($bt/@rdf:resource, '/concept/')
                                            let $btUri := $bt/@rdf:resource
                                            let $btConcept := $skosThesau:concept-collection/id($btId)
                                           
                                            let $labelValue := (
                                                    if($skosThesau:concept-collection/id($btId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang=$language])
                                                    then
                                                    $skosThesau:concept-collection/id($btId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang=$language][1]
                                                    else if($skosThesau:concept-collection/id($btId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang="en"])
                                                    then
                                                    $skosThesau:concept-collection/id($btId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang="en"][1] || " (en)"
                                                    else if($skosThesau:concept-collection/id($btId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang="fr"])
                                                    then
                                                    $skosThesau:concept-collection/id($btId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang="fr"][1] || " (fr)"

                                                    else if($skosThesau:concept-collection/id($btId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang="de"])
                                                        then
                                                            $skosThesau:concept-collection/id($btId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang="de"][1] || " (de)"

                                                    else if($skosThesau:concept-collection/id($btId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang="it"])
                                                        then
                                                        $skosThesau:concept-collection/id($btId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang="it"][1] || " (it)"
                                                    else $skosThesau:concept-collection/id($btId)//skos:prefLabel[1] [not(ancestor-or-self::skos:exactMatch)]|| " ( "|| data($skosThesau:concept-collection/id($btId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][1]/@xml:lang) ||')'
)
                                            return
                                              
                                              if(
                                                (contains($groups, ('dba', 'thesaurus_editors')))
                                                or
                                                (contains($groups, ('thesaurus_editors', 'sandbox'))
                                                and $schemeStatus ='sandbox')
                                                )
                                              
                                              then
                                              (
                                                 skosThesau:displayAndEditRelatedTerm($conceptId, $btId, $btUri, $labelValue, $relationType, $pos, $userRights, $language)
                                               )
                                              else(
                                             <li  class="term-list-item">
                                             <a class="conceptLink"  onclick="loadOnClickConcept('{$btId}', '{$language}')" title="{$btId}">
                                             {$skosThesau:concept-collection/id($btId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang=$language]}</a></li>
                                             )
                                          )
                                          case "narrower" return
                                          (
                                    for $nt at $pos in $concept//skos:narrower
                                         let $ntId := substring-after($nt/@rdf:resource, '/concept/')
                                         let $ntUri := $nt/@rdf:resource

                                         let $prefLabelNT :=
                                                    (
                                                if($skosThesau:concept-collection/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang=$language])
                                                then concat(upper-case(substring($skosThesau:concept-collection/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang=$language], 1, 1)), substring($skosThesau:concept-collection/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang=$language][1], 2))

                                                else if($skosThesau:concept-collection/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang="en"])
                                                then concat(upper-case(substring($skosThesau:concept-collection/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang="en"], 1, 1)), substring($skosThesau:concept-collection/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang="en"], 2), " (en)")

                                                else if($skosThesau:concept-collection/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang="fr"])
                                                    then concat(upper-case(substring($skosThesau:concept-collection/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang="fr"][1], 1, 1)), substring($skosThesau:concept-collection/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang="fr"][1], 2), " (fr)")
                                                else if($skosThesau:concept-collection/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang="de"])
                                                    then concat(upper-case(substring($skosThesau:concept-collection/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang="de"][1], 1, 1)), substring($skosThesau:concept-collection/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang="de"][1], 2), " (de)")
                                              else if($skosThesau:concept-collection/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang="it"])
                                                    then concat(upper-case(substring($skosThesau:concept-collection/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang="it"][1], 1, 1)), substring($skosThesau:concept-collection/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang="it"][1], 2), " (it)")
                                            else 
                                            concat(upper-case(substring($skosThesau:concept-collection/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][1], 1, 1)), substring($skosThesau:concept-collection/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][1], 2), " (" || 
                                                data($skosThesau:concept-collection/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][1]/@xml:lang)|| ")")
(:                                            ("Error: cannot retrieve label"):)
                                                (:else concat(upper-case(substring($skosThesau:concept-collection/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)], 1, 1)), substring($skosThesau:concept-collection/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][1], 2), " (", 
                                                    data($skosThesau:concept-collection/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][1]/@xml:lang),")"):)
                                            )
                                         let $prefLabelNTinCurrentLang :=
                                          concat(upper-case(substring($skosThesau:concept-collection/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang=$language], 1, 1)), substring($skosThesau:concept-collection/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang=$language], 2))

                                         let $prefLabelNTinEn :=
                                            concat(upper-case(substring($skosThesau:concept-collection/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang='en'], 1, 1)), substring($skosThesau:concept-collection/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang='en'], 2))

                                         let $prefLabelNTin1stAvailableLang :=
                                         concat(upper-case(substring($skosThesau:concept-collection/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][1], 1, 1)), substring($skosThesau:concept-collection/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][1], 2)
                                         , ' (', $skosThesau:concept-collection/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][1]/@xml:lang/string(), ')')

                                         let $prefLabelNT2 := 

                                         $skosThesau:concept-collection/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang=$language]


                                         let $titleNT :=  $skosThesau:concept-collection/id($ntId)//dc:title[not(ancestor-or-self::skos:exactMatch)][@xml:lang=$language]|$skosThesau:concept-collection/id($ntId)//dc:title[not(ancestor-or-self::skos:exactMatch)][1]

                                        order by $prefLabelNT


                                         return
                                         if(
                                                (contains($groups, ('dba', 'thesaurus_editors')))
                                                or
                                                (contains($groups, ('thesaurus_editors', 'sandbox'))
                                                and $schemeStatus ='sandbox')
                                                ) 
                                         then
                                              (
                                                 skosThesau:displayAndEditRelatedTerm($conceptId, $ntId, $ntUri, $prefLabelNT , $relationType, $pos, $userRights, $language)
                                               )
                                              else(
                                           <li  class="term-list-item">
                                             <a class="conceptLink"
                                               onclick="loadOnClickConcept('{$ntId}', '{$language}')">
                                                { $prefLabelNT}
                                               {if($skosThesau:concept-collection//skos:ConceptScheme[node()/@status='published']/id($ntId)//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)]) then
                                                  (
                                                  if($prefLabelNTinCurrentLang != '') then $prefLabelNTinCurrentLang
                                                        else if ($prefLabelNTinEn != '') then $prefLabelNTinEn
                                                        else ($prefLabelNTin1stAvailableLang)
                                                  )
                                                  else $titleNT
                                               }
                                               </a></li>))
                                          default return null
        }
                </ul>
                             </div>
                          </div>


};










declare function skosThesau:addNTButton($conceptId as xs:string){
        if($conceptId = $skosThesau:appParam//idPrefix[@type='concept']//text() || "1")
        then(
      "TODO: for top concept, addition of NT must be creation of new scheme
      
      ")
        else(
        <div>
            <button id="addNTButton" class="smallRoundButton pull-right" appearance="minimal" type="button" onclick="openDialog('dialogInsertNT')"><i class="glyphicon glyphicon-plus"></i></button>

          <div id="dialogInsertNT" title="Add a NT" class="modal fade" tabindex="-1" style="display: none;">

            <!-- Modal content-->
            <div class="modal-content modal4editor">

                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"><i class="glyphicon glyphicon-remove-circle" /></button>
                    <h4 class="modal-title">Add a new Narrower Term</h4>
                </div>
                <div class="modal-body">

                            <div class="form-input">
                            <h3>Look up for an existing concept in current scheme</h3>
                                <label for="conceptLookupInputModal">
                                </label>
                                <input type="text" class="form-control" id="concepts4NTLookupInputModal" name="concepts4NTLookupInputModal"/>
                            </div>
                            <div id="selectedConceptURI" class="hidden">URI of selected concept: <span id="newNTconceptURI"/></div>
                            <button id="addSelectedConceptasNT" class="btn btn-primary" onclick="addSelectedNT2Concept('{$conceptId}')">Add as NT</button>
                            <hr style="display: block; color: black; "/>
                            <h3>Or created a new concept</h3>
                            <br/>
                            <h4>Preferred label(s)</h4>
                            <div class="input-group">
                                <span class="input-group-addon" id="prefLabelEnNTLabel">en</span>
                                <input id="prefLabelEnNT" name="prefLabelEnNT" type="text" class="form-control" placeholder="Preferred label in English" aria-describedby="prefLabelEnLabel" />
                            </div>
                            <div class="input-group">
                                <span class="input-group-addon" id="prefLabelFrNTLabel">fr</span>
                                <input id="prefLabelFrNT" name="prefLabelFrNT" type="text" class="form-control" placeholder="Preferred label in French" aria-describedby="prefLabelFrLabel" />
                            </div>
                            <div class="input-group">
                                <span class="input-group-addon" id="prefLabelDeNTLabel">de</span>
                                <input id="prefLabelDeNT" name="prefLabelDeNT" type="text" class="form-control" placeholder="Preferred label in German" aria-describedby="prefLabelDeLabel" />
                            </div>
                            <div class="input-group">
                                <span class="input-group-addon" id="prefLabelExtraLangNTLabel">lang.</span>
                                <input id="prefLabelExtraLangNT" name="prefLabelExtraLangNT" type="text" class="form-control" placeholder="Enter a language code" aria-describedby="prefLabelExtraLangLabel"
                                size="2"/>
                                <span class="input-group-addon" od="prefLabelExtraValueNTLabel">Value</span>
                                <input id="prefLabelExtraValueNT" name="prefLabelExtraValueNT" type="text" class="form-control" placeholder="Value" aria-describedby="prefLabelExtraValueLabel" />
                            </div>

                     <button id="addNewConceptasNT" class="btn btn-primary" onclick="createConceptAndAddAsNT('{$conceptId}', 'c', '{$skosThesau:thesBaseUri}')">Create concept and add as NT</button>
                     </div>
                     <div class="modal-footer">
                        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                   
                  </div>
                </div>
             </div>
         </div>
         )
};

declare function skosThesau:addPrefLabelButton($conceptId as xs:string){

        <div>
            <button id="addPrefLabelButton" class="smallRoundButton pull-right" appearance="minimal" type="button" onclick="openDialog('dialogInsertPrefLabel')"><i class="glyphicon glyphicon-plus"> </i></button>

          <div id="dialogInsertPrefLabel" title="Add a Preferred Term" class="modal fade" tabindex="-1" style="display: none;">

            <!-- Modal content-->
            <div class="modal-content modal4editor">

                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"><i class="glyphicon glyphicon-remove-circle" /></button>
                    <h4 class="modal-title">Add a new preferred term</h4>
                </div>
                <div class="modal-body">
                            <div class="input-group">
                                <span class="input-group-addon" id="newAltLabelExtraLangLabel">Lang.</span>
                                <input id="newPrefLabelExtraLang" name="newPrefLabelExtraLang" type="text" class="form-control" placeholder="Enter a language code" aria-describedby="newPrefLabelExtraLangLabel"
                                size="2"/>
                                <span class="input-group-addon" id="newPrefLabelExtraValueLabel">Value</span>
                                <input id="newPrefLabelExtraValue" name="newPrefLabelExtraValue" type="text" class="form-control" placeholder="Value" aria-describedby="newPrefLabelExtraValueLabel" />
                            </div>


                     <button id="addNewPrefLabel" class="btn btn-primary" onclick="addNewPrefLabel('{$conceptId}')">Add as new preferred term</button>
                    <div class="form-group modal-footer">



                        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                    </div>

                  </div>
                </div>
             </div>



         </div>
};


declare function skosThesau:addAltLabelButton($conceptId as xs:string){

        <div>
            <button id="addAltLabelButton" class="smallRoundButton pull-right" appearance="minimal" type="button" onclick="openDialog('dialogInsertAltLabel')"><i class="glyphicon glyphicon-plus"> </i></button>

          <div id="dialogInsertAltLabel" title="Add a Alternative Term" class="modal fade" tabindex="-1" style="display: none;">

            <!-- Modal content-->
            <div class="modal-content modal4editor">

                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"><i class="glyphicon glyphicon-remove-circle" /></button>
                    <h4 class="modal-title">Add a new alternative term</h4>
                </div>
                <div class="modal-body">
                            <div class="input-group">
                                <span class="input-group-addon" id="newAltLabelEnLabel">EN</span>
                                <input id="newAltLabelEn" name="newAltLabelEn" type="text" class="form-control" placeholder="Alternative term in English" aria-describedby="newAltLabelEnLabel" />
                            </div>
                            <div class="input-group">
                                <span class="input-group-addon" id="newAltLabelDeLabel">DE</span>
                                <input id="newAltLabelDe" name="newAltLabelDe" type="text" class="form-control" placeholder="Alternative term in German" aria-describedby="newAltLabelDeLabel" />
                            </div>
                            <div class="input-group">
                                <span class="input-group-addon" id="newAltLabelFrLabel">FR</span>
                                <input id="newAltLabelFr" name="newAltLabelFr" type="text" class="form-control" placeholder="Alternative term in French" aria-describedby="newAltLabelFrLabel" />
                            </div>
                            <div class="input-group">
                                <span class="input-group-addon" id="newAltLabelExtraLangLabel">Lang.</span>
                                <input id="newAltLabelExtraLang" name="newAltLabelExtraLang" type="text" class="form-control" placeholder="Enter a language code" aria-describedby="newAltLabelExtraLangLabel"
                                size="2"/>
                                <span class="input-group-addon" id="newAltLabelExtraValueLabel">Value</span>
                                <input id="newAltLabelExtraValue" name="newAltLabelExtraValue" type="text" class="form-control" placeholder="Value" aria-describedby="newAltLabelExtraValueLabel" />
                            </div>


                     <button id="addNewAltLabel" class="btn btn-primary" onclick="addNewAltLabel('{$conceptId}')">Add new Alternative term(s)</button>
                    <div class="form-group modal-footer">



                        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                    </div>

                  </div>
                </div>
             </div>



         </div>



        };

 (:
 ****************************
 *   Interacting with data  *
 ****************************
 :)

 declare function skosThesau:addExistingConceptasNT($data, $project){
    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)
    let $currentConcept := $skosThesau:concept-collection/id($data//currentConceptId/text())
(:    let $narrowerConcept := $skosThesau:concept-collection//.[@rdf:about = $data//ntUri/text()]:)
    let $narrowerConcept := $skosThesau:concept-collection/id(substring-after($data//ntUri/text(), "concept/"))
    let $narrowerNode := <data>
    <skos:narrower rdf:resource="{$data//ntUri/text()}"/></data>
    let $broaderNode := <data>
    <skos:broader rdf:resource="{data($currentConcept/@rdf:about)}"/></data>
    let $addNT :=
                if($currentConcept//skos:narrower) then update insert
                            $narrowerNode/node() following $currentConcept//skos:narrower[last()]
                    else update insert
                            $narrowerNode/node() following $currentConcept//skos:broader[last()]

    let $addCurrentAsBT :=
                    if($narrowerConcept//skos:broader) then
                        update insert $broaderNode/node() following $narrowerConcept//skos:broader[last()]
                        else
                        update insert $broaderNode/node() following $narrowerConcept//skos:prefLabel[last()]

    let $logs := collection("/db/apps/" || $skosThesau:project || "-data/logs")
    
    let $appParam := doc('/db/apps/' || $project || '/data/app-general-parameters.xml')
    let $thesaurus-app := $appParam//thesaurus-app/text()
    let $thesaurusTree := doc('/db/apps/' || $thesaurus-app || 'Data/thesaurus/thesaurus-as-tree.xml')
    let $langList := string-join(doc('/db/apps/' || $project || '/data/app-general-parameters.xml')//languages//lang/text(), " ")
    let $newNodesForTree :=  skosThesau:updateConceptsForTree($project, data($currentConcept/@rdf:about),
        $skosThesau:concept-collection)
    
    let $updateConceptTree :=
                for $lang in tokenize($langList, " ")
                return
                (
                update replace $thesaurusTree//thesaurus[@xml:lang = $lang]//children[id/text() = $currentConcept/@xml:id]
                with $newNodesForTree//thesaurus[@xml:lang= $lang]/children
                 )

    return
    (skosThesau:logEvent("add-concept-as-nt", $data//currentConceptId/text(), $data,
    "URI of new NT: " || data($narrowerNode/node()/@rdf:resource)
    ),
   <data>{$data}</data>)

 };


 declare function skosThesau:addNewConceptasNT($data, $project){
    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)

    let $appParam := doc('/db/apps/' || $project || '/data/app-general-parameters.xml')
    let $thesaurus-app := $appParam//thesaurus-app/text()
    let $conceptId := $data//conceptId/text()
(:    let $concept-collection := collection('/db/apps/' || $thesaurus-app || 'Data/concepts'):)
(:    let $thesaurusTree := doc('/db/apps/' || $thesaurus-app || 'Data/thesaurus/thesaurus-as-tree.xml'):)
    let $langList := string-join(doc('/db/apps/' || $project || '/data/app-general-parameters.xml')//languages//lang/text(), " ")

    let $idPrefix := $data//idPrefix/text()
(:    let $baseUri := $data//baseUri/text():)
    let $idList := for $id in ($skosThesau:concept-collection//skos:Concept[contains(./@xml:id, $idPrefix)],
                        $skosThesau:concept-collection//skos:Collection[contains(./@xml:id, $idPrefix)])
        return
        <item>
        {substring-after($id/@xml:id, $idPrefix)}
        </item>

    let $last-id:= fn:max($idList)
    let $newId := $idPrefix || fn:sum(($last-id, 1))
    let $newUri := $skosThesau:conceptBaseUri || $newId



    let $currentConcept := $skosThesau:concept-collection/id($data//currentConceptId/text())
    let $scheme := $skosThesau:concept-collection//rdf:RDF[skos:ConceptScheme[@rdf:about=data($currentConcept//skos:inScheme/@rdf:resource)]]
    let $newConcept :=
<data>
    <skos:Concept xml:id="{$newId}" rdf:about="{$newUri}">
        {for $labels at $pos in $data//label
        return
        if ($labels != "") then(
        (<skos:prefLabel xml:lang="{data($labels/@xml:lang)}">{$labels/text()}</skos:prefLabel>, if ($pos < count($labels)) then '&#xD;&#xa;' else ()))
        else()}
        <skos:broader rdf:resource="{data($currentConcept/@rdf:about)}"/>
        <skos:inScheme rdf:resource="{data($currentConcept/skos:inScheme/@rdf:resource)}"/>
        <skosThesau:admin status="{data($currentConcept/skosThesau:admin/@status)}"/>
        <dcterms:creator rdf:resource="{$skosThesau:peopleBaseUri}{$currentUser}">{$skosThesau:account-collection//account[@xml:id=$currentUser]/firstname/text()} {$skosThesau:account-collection//account[@xml:id=$currentUser]/lastname/text()}</dcterms:creator>
        <dcterms:created>{$now}</dcterms:created>
    </skos:Concept></data>
    let $narrowerNode :=
<data>
    <skos:narrower rdf:resource="{$newUri}"/></data>

    let $createNewConcept := update insert $newConcept/node() into $scheme

    let $addNT :=
                    if($currentConcept//skos:narrower) then
                            update insert $narrowerNode/node() following $currentConcept//skos:narrower[last()]
                    else if ($currentConcept//skos:narrower) then
                            update insert $narrowerNode/node() following $currentConcept//skos:broader[last()]
                    else
                            update insert $narrowerNode/node() following $currentConcept//skos:prefLabel[last()]
    let $newNodesForTree :=  skosThesau:updateConceptsForTree($project, data($currentConcept/@rdf:about), $skosThesau:concept-collection)
    
    (:let $updateConceptTree :=
                for $lang in tokenize($langList, " ")
                return
                (
(\:                skosThesau:logEvent("test-existing-tree", $data//currentConceptId/text(), $thesaurusTree//thesaurus[@xml:lang = $lang]//children[id/text() = $currentConcept/@xml:id], ()),:\)
                update replace $skosThesau:thesaurusTree//thesaurus[@xml:lang = $lang]//children[id = $data//currentConceptId]
                with $newNodesForTree//thesaurus[@xml:lang= $lang]/children
                 ):)   
    let $modificationDate :=
<data>
    <dcterms:modified>{ $now }</dcterms:modified></data>

    let $addModificationDateToCurrentConcept :=
                    if($currentConcept//dcterms:modified) then
                            update insert $modificationDate/node() following $currentConcept//dcterms:modified[last()]
                    else
                            update insert $modificationDate/node() following $currentConcept//dcterms:created[last()]


    return
    (
(:        skosThesau:logEvent("new-concept-as-nt", $data//currentConceptId/text(), $newConcept, ()),:)
       skosThesau:displayRelatedConceptList($data//currentConceptId/text(), "narrower", "editor", "en")

    )

 };


declare function skosThesau:addNewPrefLabel($data){
    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)
    let $conceptId := $data//conceptId/text()
    let $currentConcept := $skosThesau:concept-collection/id($conceptId)

    let $newPrefLabel :=
<newLabels>{for $labels at $pos in $data//prefLabel
                            return if ($labels != "") then((<skos:prefLabel xml:lang="{data($labels/@xml:lang)}">{$labels/text()}</skos:prefLabel>, if ($pos < count($labels)) then '&#xD;&#xa;' else ()))
                        else()
                        }</newLabels>

    let $insertNewPrefLabels:= if ($currentConcept//skos:prefLabel) then
                                    update insert $newPrefLabel/node() following $currentConcept//skos:prefLabel[last()]
                              else (update insert $newPrefLabel/node() following $currentConcept//text()[1])


    let $updatedConcept := $skosThesau:concept-collection/id($conceptId)
    return
    (skosThesau:logEvent("add-prefLabel", $conceptId, $data, 'New label: ' || $newPrefLabel/text()),
   <div>{for $label at $pos in $updatedConcept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)]
                    let $value := if ($label/@xml:lang = "xml") then ($label) else upper-case(substring($label, 1, 1)) || substring($label, 2)
                    let $lang := data($label/@xml:lang)
                    order by $value
                  return
                     <li class="term-list-item">
                         {skosThesau:displayAndEditLabel($conceptId, $value, 'prefLabel', $lang, "editor", $pos)}
                     </li>

                   }</div>)

 };

declare function skosThesau:addNewAltLabel($data, $project){
    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)

    let $appParam := doc('/db/apps/' || $project || '/data/app-general-parameters.xml')
    let $thesaurus-app := $appParam//thesaurus-app/text()
    let $conceptId := $data//conceptId/text()
    let $concept-collection := collection('/db/apps/' || $thesaurus-app || 'Data/concepts')



    let $currentConcept := $concept-collection/id($conceptId)

    let $newAltLabel := <newLabels>{for $labels in $data//altLabel
                            return
                            if ($labels != "") then(
                        <skos:altLabel xml:lang="{data($labels/@xml:lang)}">{$labels/text()}</skos:altLabel>
                        )
                        else()
                        }</newLabels>

    let $insertNewAltLabels:= update insert $newAltLabel/node() into $currentConcept


    (:let $logInjection :=
    update insert
         <log type="thesaurus-new-altLabel" when="{$now}" what="{data($conceptId)}" who="{$currentUser}">{$data}</log>
         into $skosThesau:logs-collection/rdf:RDF/id('all-logs')
:)
    let $updatedConcept := $concept-collection/id($conceptId)
    return
    (skosThesau:logEvent("new-altLabel", $conceptId, $data,
          for $newLabels in $newAltLabel
            return 'New altLabel "' || $newLabels/skos:altLabel/text() || '" (' || data($newLabels/skos:altLabel/@xml:lang) || ")"),
   <div>{for $label at $pos in $updatedConcept//skos:altLabel[not(ancestor-or-self::skos:exactMatch)]
                    let $value := upper-case(substring($label, 1, 1)) || substring($label, 2)
                    let $lang := data($label/@xml:lang)
                    order by $value
                  return
                     <li class="term-list-item">
                         {skosThesau:displayAndEditLabel($conceptId, $value, 'altLabel', $lang, "editor", $pos)}
                     </li>

                   }</div>)

 };


declare function skosThesau:saveData($data, $project){
    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)

    let $appParam := doc('/db/apps/' || $project || '/data/app-general-parameters.xml')
    let $thesaurus-app := $appParam//thesaurus-app/text()



    let $conceptId := $data//conceptId/text()
    let $elementName := $data//elementName/text()
    let $updatedData := $data//value/text()
    let $oldValue := $data//originalValue/text()
    let $lang := $data//lang/text()

    let $concept :=util:eval( "collection('/db/apps/" || $thesaurus-app || "Data/concepts')/id('"
             ||$conceptId || "')")
    let $valueNode :=  util:eval( "collection('/db/apps/" || $thesaurus-app || "Data/concepts')/id('"
             ||$conceptId || "')//skos:" || $elementName || "[@xml:lang='" || $lang || "']/node()")

(:    let $backupConcept := update insert $concept into $skosThesau:concept-backup-collection:)

    let $updateConcept := update value $valueNode with $updatedData
    let $updatedConcept :=util:eval( "collection('/db/apps/" || $thesaurus-app || "Data/concepts')/id('"
             ||$conceptId || "')")
    
    
    let $thesaurus-app := $appParam//thesaurus-app/text()
(:    let $thesaurusTree := doc('/db/apps/' || $thesaurus-app || 'Data/thesaurus/thesaurus-as-tree.xml'):)
(:    let $langList := string-join(doc('/db/apps/' || $project || '/data/app-general-parameters.xml')//languages//lang/text(), " "):)
    (:let $newNodesForTree :=  skosThesau:updateConceptsForTree($project, data($concept/@rdf:about),
        $skosThesau:concept-collection)
    
    let $updateConceptTree :=
                for $lang in tokenize($langList, " ")
                return
                (
                update replace $thesaurusTree//thesaurus[@xml:lang = $lang]//children[id/text() = $conceptId]
                with $newNodesForTree//thesaurus[@xml:lang= $lang]/children
                 )
:)
    return
    (
(:    skosThesau:logEvent("update-" || $elementName, $conceptId, $data, "Change " ||$elementName || "(" || $lang || '): "' || $oldValue || '" > "' || $updatedData || '"'),:)
     <div>{
        switch($elementName)
        case "prefLabel"
            return
                skosThesau:displayAndEditLabel($conceptId, $updatedData, 'prefLabel', $lang, "editor", 0)

         case "altLabel"
            return
                skosThesau:displayAndEditLabel($conceptId, $updatedData, 'altLabel', "editor", $lang, 0)
         default return
         skosThesau:logEvent("update-" || $elementName, $conceptId, $data, "Change " ||$elementName || "(" || $lang || '): "' || $oldValue || '" > "' || $updatedData || '"')
                   }</div>)



};

declare function skosThesau:saveNTSortingOrderType($data, $project){
    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)

    let $appParam := doc('/db/apps/' || $project || '/data/app-general-parameters.xml')
    let $thesaurus-app := $appParam//thesaurus-app/text()
    let $conceptId := $data//conceptId/text()
    let $orderingType := $data//orderingType/text()

    let $concept :=util:eval( "collection('/db/apps/" || $thesaurus-app || "Data/concepts')/id('"
             ||$conceptId || "')")

    let $updateOrderingType :=
            if(exists($concept/@type)) then (
                if($orderingType ="alpha") then (
                    update delete $concept/@type)
                else(
                  update value $concept/@type with "ordered")
                    )
                else (
                    if($orderingType ="alpha") then ()
                        else(
                        update insert attribute type {'ordered'} into $concept)
                    )

    let $changeDescr := if($orderingType ="") then "Sorting order changed to alphabetical"
                else "Sorting order changed to non-alphabetical"
    return
            (skosThesau:logEvent("update-sorting-order-type", $conceptId, (), $changeDescr),
            <ok>OK</ok>)
    };


declare function skosThesau:saveConceptType($data, $project){
    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)

    let $appParam := doc('/db/apps/' || $project || '/data/app-general-parameters.xml')
    let $thesaurus-app := $appParam//thesaurus-app/text()
    let $conceptId := $data//conceptId/text()
    let $conceptType := $data//conceptType/text()

    let $concept :=util:eval( "collection('/db/apps/" || $thesaurus-app || "Data/concepts')/id('"
             ||$conceptId || "')")
    let $currentElementName := $concept/name()

    let $updateConceptType :=
                if($conceptType = $currentElementName) then ()
                    else  (update rename $concept as $conceptType)

    return
            (skosThesau:logEvent("update-concept-type", $conceptId, (), "Change concept type to " || $conceptType),
            <ok>OK</ok>)
    };


declare function skosThesau:deleteLabel($data){
    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)
    let $groups := string-join(sm:get-user-groups($currentUser), ' ')
   
    let $conceptId := $data//conceptId/text()
    let $labelType := $data//labelType/text()
    let $lang := $data//lang/text()
    let $index := $data//index

    let $selector := if($index >= 1) then ""
                    else "[" || $index || "]"

    let $label2delete :=util:eval( "collection('/db/apps/" || $skosThesau:thesaurus-app || "Data/concepts')/id('"
             ||$conceptId || "')//skos:" || $labelType || "[@xml:lang='" || $lang || "']" || $selector)
    let $deleteLabel := update delete $label2delete/following-sibling::text()[1]
    let $deleteLabel := update delete $label2delete
    (:let $updatedConcept :=
    util:eval( "collection('/db/apps/" || $skosThesau:thesaurus-app || "Data/concepts')/id('"
             ||$conceptId || "')"):)
    let $updatedConcept :=
                $skosThesau:concept-collection/id($conceptId)
   
    let $schemeURI := data($updatedConcept//skos:inScheme/@rdf:resource)
    let $schemeNode := $skosThesau:concept-collection//skos:ConceptScheme[@rdf:about=$schemeURI]
  let $nodeType := name($updatedConcept)
  let $schemeName := $schemeNode//dc:title[@type='short']
  let $conceptStatus := data($updatedConcept//skosThesau:admin/@status)
  let $schemeStatus := data($schemeNode//skosThesau:admin/@status)
  let $schemeCreators := data($schemeNode//dc:creator/@ref)
  let $schemeContributors := data($schemeNode//dc:contributor/@ref)
  
    let $userRights :=
        if (contains($groups, ('sandbox'))) then "sandbox"
        
        else if(contains($groups, ('thesaurus_editors'))) then "editor"
        
        else if (contains($schemeContributors, $currentUser)) then "contributor"
        else if (contains($schemeCreators, $currentUser)) then "editor"
        else ("guest")


   
   
   let $modified :=
<data>
    <dcterms:modified when="{$now}" who="{$currentUser}"/></data>
    let $insertModificationDate := update insert $modified/node() following $updatedConcept//dcterms:modified[last()]
    (:let $log :=
    <data>
    <log type="thesaurus-delete-{$labelType}" when="{$now}" what="{data($data//conceptId)}" who="{$currentUser}">{$data}</log></data>
    let $log-injection := update insert
         $log
         into $skosThesau:logs-collection/rdf:RDF/id('all-logs'):)
   return
   (skosThesau:logEvent("delete-" || $labelType, $conceptId, $data,
                    'Deleted label: "' || $data//labelValue/text() || '" (' || $data//lang/text() || ")"),
    <div>{
        switch($labelType)
        case "prefLabel"
            return
              for $prefLabel at $pos in $updatedConcept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)]
                    let $value := upper-case(substring($prefLabel, 1, 1)) || substring($prefLabel, 2)
                    let $lang := data($prefLabel/@xml:lang)

               return

                   <li class="term-list-item">
                         {skosThesau:displayAndEditLabel($conceptId, $value, 'prefLabel', $lang, $userRights, $pos)}
                     </li>

                   

         case "altLabel"
            return

                  for $label at $pos in $updatedConcept//skos:altLabel[not(ancestor-or-self::skos:exactMatch)]
                    let $value := upper-case(substring($label, 1, 1)) || substring($label, 2)
                    let $lang := data($label/@xml:lang)
                    order by $value
                  return

                   if (sm:has-access(xs:anyURI('/db/apps/' || $skosThesau:project || '/modules/4access.xql') , 'r-x' )) then (

                     <li class="term-list-item">
                         {skosThesau:displayAndEditLabel($conceptId, $value, 'altLabel', "editor", $lang, $pos)}
                     </li>

                    )
                    else (
                          <li class="term-list-item">
                          {$value || " (" || $lang || ")"}
                          </li>
                          )


             default
                return null
   }</div>)

};

declare function skosThesau:deleteAltLabel($data){
let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)

    let $conceptId := $data//conceptId/text()
    let $lang := $data//lang/text()
    let $prefLabel2delete :=util:eval( "collection('/db/apps/" || $skosThesau:thesaurus-app || "Data/concepts')/id('"
             ||$conceptId || "')//skos:prefLabel[@xml:lang='" || $lang || "']")
    let $deletePrefLabel := update delete $prefLabel2delete/following-sibling::text()[1]
    let $deletePrefLabel := update delete $prefLabel2delete
    let $conceptUpdated :=util:eval( "collection('/db/apps/" || $skosThesau:thesaurus-app || "Data/concepts')/id('"
             ||$conceptId || "')")
    let $modified :=
    <data>
    <dcterms:modified when="{$now}" who="{$currentUser}"/></data>
    let $insertModificationDate := update insert $modified/node() following $conceptUpdated//dcterms:modified[last()]

   return
   (skosThesau:logEvent("delete-altLabel", $conceptId, $data,
          'Deleted altLabel: "' || $prefLabel2delete/text() || '" (' || data($prefLabel2delete/@xml:lang) || ")"),
   <div>{
        for $prefLabel at $pos in $conceptUpdated//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)]
            let $value := upper-case(substring($prefLabel, 1, 1)) || substring($prefLabel, 2)
            let $lang := data($prefLabel/@xml:lang)

            return
                if (sm:has-access(xs:anyURI('/db/apps/' || $skosThesau:project || '/modules/4access.xql') , 'r-x' )) then (
                   <li class="term-list-item">{ skosThesau:displayAndEditLabel($conceptId, $value, 'prefLabel', "editor", $lang, $pos) }</li>)
              else
                    <li class="term-list-item">{ $value || " (" || $lang || ")" }</li>
         }</div>)
};

declare function skosThesau:deleteRelation($data){
    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)

    let $conceptId := $data//conceptId/text()
    let $conceptUri := data($skosThesau:concept-collection/id($conceptId)/@rdf:about)
    let $language := $data//language/text()
    let $relatedConceptUri := $data//relatedConceptUri/text()
    let $relatedConceptId := $data//relatedConceptId/text()
    let $relationType  := $data//relationType/text()
    let $reverseRelationType := switch($relationType)
            case "broader" return "narrower"
            case "narrower" return "broader"
            default return null

    let $relation2delete :=util:eval( "collection('/db/apps/" || $skosThesau:thesaurus-app || "Data/concepts')/id('"
             ||$conceptId || "')//skos:" || $relationType || "[@rdf:resource='" || $relatedConceptUri|| "']")

    let $reverseRelation2delete :=util:eval( "collection('/db/apps/" || $skosThesau:thesaurus-app || "Data/concepts')/id('"
             ||$relatedConceptId || "')//skos:" || $reverseRelationType || "[@rdf:resource='" || $conceptUri|| "']")


    let $deleteRelations := (update delete $relation2delete, update delete $reverseRelation2delete)

    let $updatedConcept :=util:eval( "collection('/db/apps/" || $skosThesau:thesaurus-app || "Data/concepts')/id('"
             ||$conceptId || "')")
    let $modified :=
    <data>
    <dcterms:modified when="{$now}" who="{$currentUser}"/></data>
    let $insertModificationDate := update insert $modified/node() following $updatedConcept//dcterms:modified[last()]


   return
   (skosThesau:logEvent("delete-relation", $data//conceptId, $data,
        "Concept " || $relatedConceptUri || " removed as " || $relationType || " term"),
   <div>
                { skosThesau:displayRelatedConceptList($conceptId, $relationType, "editor", $language) }
              </div>)
};

(:declare function skosThesau:getData(){
let $query := request:get-parameter("query", "Please start to enter a term")
let $query-type := request:get-parameter("query-type", "")
let $lang := request:get-parameter("lang", "")
let $project := request:get-parameter("project", "")
let $data-type := request:get-parameter("data-type","")


let  $conceptCollection := collection('/db/apps/' || $project || '-data/concepts')

(\:let $conceptid:= request:get-parameter("concept", "")
let $concept:=$conceptCollection//skos:Concept[@xml:id=$conceptid]
:\)
return
    <data>
        {for $match in subsequence($conceptCollection//skos:prefLabel[starts-with(lower-case(.), lower-case($query))]|$conceptCollection//dc:title[starts-with(lower-case(.), lower-case($query))], 1, 20)

        return
        <matching>
            <label>{$match/text()}</label>
            <value>{$match/text()}</value>
            <id>{$match/parent::node()/@rdf:about/string()}</id>
        </matching>}
    </data>
}
:)

declare function skosThesau:getLabel($uriConcept as xs:string?, $lang as xs:string){
  let $conceptId := functx:substring-after-last($uriConcept, '/')
  let $concept := util:eval( "collection('/db/apps/" || $skosThesau:thesaurus-app || "Data/concepts')/id('"
             ||$conceptId || "')")
  let $prefLabel :=
             if($lang != "" and $concept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang= $lang ][1]) then 
                            $concept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang= $lang ][1]/text() 
           else 
                    $concept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][1]/text()
       
  return
    if($uriConcept != "") then
        if($lang!="xml") then  functx:capitalize-first($prefLabel[1])
                                else $prefLabel[1]
   else ()
};


declare function skosThesau:getLabel($uriConcept as xs:string?, $lang as xs:string, $project as xs:string?){
  let $thesaurus-app := if($skosThesau:thesaurus-app != "") then $skosThesau:thesaurus-app
                                    else
                                    let $appParam := doc('/db/apps/' || $project || '/data/app-general-parameters.xml')
                                    return $appParam//thesaurus-app/text()
                                     
(:  let $thesaurus-app := "ausohnum":)
  let $conceptId := functx:substring-after-last($uriConcept, '/')
  let $concept := util:eval( "collection('/db/apps/" || $thesaurus-app || "Data/concepts')/id('"
             ||$conceptId || "')")
  let $prefLabel :=
             if($lang != "" and $concept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang= $lang ][1]) then 
                            $concept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang= $lang ][1]/text() 
           else 
                    $concept//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][1]/text()
       
  return

    functx:capitalize-first($prefLabel[1]) 

};

declare function skosThesau:getLabelFromXmlValue($xmlValue as xs:string?, $lang as xs:string){
(: let $thesaurus-app := "ausohnum" :)
(:  let $conceptId := functx:substring-after-last($uriConcept, '/'):)
  let $prefLabels := if($xmlValue != "") then util:eval( "collection('/db/apps/" || $skosThesau:thesaurus-app || "Data/concepts')//.[skos:prefLabel[@xml:lang='xml'][text() ='" || $xmlValue || "']]//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)]")
                                else ()
    let $prefLabel:= if($prefLabels//.[@xml:lang= $lang]/text() != "") then $prefLabels//.[@xml:lang= $lang ]/text()
            else ($prefLabels//.[@xml:lang != "xml"][1]/text())
  return
    if($prefLabel[1] != "") then $prefLabel[1] else ""


};



declare function skosThesau:logEvent($eventType as xs:string, $conceptId as xs:string, $data as node()?, $description as xs:string?){
    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)
    let $log :=
<data>
    <log type="thesaurus-{$eventType}" when="{$now}" what="{$conceptId}" who="{$currentUser}">{$data}<description>{$description}</description></log></data>
return
    update insert
         $log/node()
         into $skosThesau:logs-collection/rdf:RDF/id('all-logs')
};




declare function skosThesau:exportConcepts($project){
let $now := fn:current-dateTime()
let $appParam := doc('/db/apps/' || $project || '/data/app-general-parameters.xml')
let $thesaurus-app := $appParam//thesaurus-app/text()
let $data :=  collection("/db/apps/" || $thesaurus-app || "Data/concepts")
let $thesaurusShortTitle := request:get-parameter('thesaurus', ())
let $thesaurus := $data//node()[skos:ConceptScheme[dc:title[@type='short'] = $thesaurusShortTitle]]
let $separatorValue := request:get-parameter('separator', ())

let $nl := "&#10;"
let $tab := '&#9;' (: tab :)

let $separator := switch ($separatorValue)
   case "tab" return "&#9;"
   case "comma" return ', '
   default return ", "
let $lang2export := request:get-parameter('lang', ())
let $langs := distinct-values($thesaurus//skos:prefLabel/@xml:lang)
let $langlist := if ($lang2export = 'all-languages') then
        (string-join(
        for $lang in $langs
                    order by $lang
                    return

                ($lang, $separator))
                )
                else ($lang2export)

let $dateRangeHeader :=
        if(request:get-parameter('daterange', ()) = 'daterange') then ($separator || "earliest date" || $separator || "lastest date")
        else ()
let $headerOLD := string("Thot no.") || $separator || "en" ||$separator || $lang2export ||$dateRangeHeader
let $header := string("Thot no.") || $separator
                || $langlist
                ||$dateRangeHeader

let $concepts := string-join(
      for $concept in $thesaurus//skos:Concept[not(ancestor-or-self::skos:exactMatch)]
            let $englishPrefLabel := if(exists($concept//skos:prefLabel[@xml:lang="en"][not(ancestor-or-self::skos:exactMatch)])) then
                replace($concept//skos:prefLabel[@xml:lang="en"][not(ancestor-or-self::skos:exactMatch)]/text(), $nl, '')
                else $concept//dc:title[@xml:lang="en"]

          let $prefLabels :=
                    if ($lang2export = 'all-languages') then(
                    string-join(
                    for $lang in $langs
                    order by $lang
                    return
                        normalize-space(functx:trim($concept//skos:prefLabel[@xml:lang=$lang][not(ancestor-or-self::skos:exactMatch)/text()])) || $separator
                    ))
                    else(
                        if (exists($concept//skos:prefLabel[@xml:lang=$lang2export])) then
                            (
                            $englishPrefLabel
                            ||
                            normalize-space(functx:trim($concept//skos:prefLabel[@xml:lang=$lang2export][not(ancestor-or-self::skos:exactMatch)]/text())))
                                  else ("")
                            )

    let $dateRange := if(exists($concept//time:hasMember) and request:get-parameter('daterange', ()) = 'daterange') then
        ($separator || $concept//time:hasMember/time:TemporalEntity[1]/periodo:earliestYear || $separator || $concept//time:hasMember/time:TemporalEntity[1]/periodo:latestYear)
        else()
            return
                (
                    data($concept/@xml:id)
                    || $separator
                    ||
                    $prefLabels ||
                    $dateRange
                    || $nl
                 ), ''
                )

 let $fileContent :=
    $header ||
    $nl ||
    $concepts
let $filenameExt := switch ($separator)
    case "tab" return ".txt"
    case "comma" return ".csv"
    default return ".txt"
let $filename := "thot-" || $thesaurusShortTitle
|| "-export-" ||$separator || substring($now, 1, 10) ||'-' || replace(substring($now, 12, 5), ':', '')|| $filenameExt

return
(:    $target-path:)


 response:stream-binary(util:string-to-binary($fileContent), "text/csv", $filename)

};

declare function skosThesau:searchConcepts($topConceptUri as xs:string?){
null

};
declare function skosThesau:conceptLookup($topConceptUri as xs:string, $label as xs:string?, $index as xs:string?){
let $conceptId := functx:substring-after-last($topConceptUri, "/")
let $lookupScript:= '
$( "#' || $conceptId || 'conceptLookup' || $index || '" ).attr("autocomplete","on");
$( "#' || $conceptId || 'conceptLookup' || $index || '" ).autocomplete({
        source: function( request, response ) {
                    console.log("Dans lookup");
                    var elementId = $(this.element).prop("id");
                    var type = elementId.substr(elementId.lastIndexOf("Modal")+ 5);
                    
                    $.ajax({
                         
                        url: "/concepts/search/",
                        dataType : "json",
                        data : {
                                    "query": $("#' || $conceptId || 'conceptLookup' || $index || '").val(),
                                    topConceptUri: "'|| $topConceptUri || '"
                                    },
                        success : function(data){
                            /*console.log("sucess: " + JSON.stringify(data));*/
                            response(
                                $.map(
                                    data.list.items, function(object){
                                    
                                       return {
                                                    
                                                    label: object.title + " " + object.identifier,
                                                    uri: object.identifier,
                                                    //author: object.data.creators[0].lastName,
                                                    //date: object.data.date,
                                                    title:  object.title,
                                                    //title: object.data.title,
                                                    //value: object.key,
                                                   // key: object.data.key,
                                                    fullData: object
                                                    //refType : type
                                                    };
                                                   
                                        }));
            
                            },
                                error:function(){ 
                                console.log("Erreur");
                                }
                        });
        }, //End of Source
      minLength: 3,
      select: function( event, ui ) {
            event.preventDefault();
                    $(this).val(ui.item.label);
                     $("#' || $conceptId|| 'conceptLookupResultUri' || $index  ||'").val(ui.item.uri);
                     $("#' || $conceptId|| 'conceptLookupResultLabel' || $index  ||'").val(ui.item.title);
              
            }
    } );'
return
<div>
    <div class="form-group">
                 {if($label != "") then <label for="bondTypesLookup">{ $label }</label>
                 else ()
                 }
                 <input type="text" class="form-control conceptLookup"
                 id="{$conceptId}conceptLookup{ $index }"
                 name="{ $conceptId }conceptLookup{ $index }"
                 autocomplete="on"
                 />
                 <input type="text" class="form-control conceptLookupResultLabel hidden"
                 id="{$conceptId}conceptLookupResultLabel{ $index }"
                 name="{ $conceptId }conceptLookupResultLabel{ $index }"
                 />
                 <input type="text" class="form-control conceptLookupResultUri hidden"
                 id="{$conceptId}conceptLookupResultUri{ $index }"
                 name="{ $conceptId }conceptLookupResultUri{ $index }"
                 />
    </div>
    <script type="text/javascript" >
    { $lookupScript }
    </script>
</div>
};

declare function skosThesau:retrieveDocuments($project as xs:string, $conceptUri as xs:string, $start as xs:int?){
  (: If $start = () then all documents are returned :)
    let $doc-collection := collection("/db/apps/" || $project || "Data/documents")
    let $startSubseq:=if(not(exists($start))) then 1 else $start
    let $query:= if(not(exists($start))) then $doc-collection//tei:term[@ref = $conceptUri ]|$doc-collection//tei:rs[@ref = $conceptUri ]
                  else subsequence($doc-collection//tei:term[@ref = $conceptUri ]|$doc-collection//tei:rs[@ref = $conceptUri ], $startSubseq, 20)
   
    return
        <ul>
          {
          for $match in $query
          let $doc:= root($match)
          return 
              <li>
                <id>{ data($doc//ancestor-or-self::tei:TEI/@xml:id) }</id>
                <docTitle>{ $doc//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/text() }</docTitle>
                <docUri>{ $doc//tei:publicationStmt/tei:idno[@type="uri"]/text() }</docUri>
                <matchNode>{ node-name($match) }</matchNode>
              </li>
              }
          </ul>
          
};
declare function skosThesau:retrieveDocumentsPanel($project, $conceptUri){
    let $doc-collection := collection("/db/apps/" || $project || "Data/documents")
    return
        <div class="panel panel-default panel-terms">
           <div class="panel-heading">
              <h2 class="panel-title">Documents in { $project } tagged with this concept</h2>
            </div>
            <div class="panel-body">
              <ol>
              {
        for $match in $doc-collection//tei:TEI[.//tei:term[@ref = $conceptUri ]]
            |$doc-collection//tei:TEI[.//tei:rs[@ref = $conceptUri ]]
        return 
            <li>
                { data($match/@xml:id) } - { $match//tei:titleStmt/tei:title/text() }<a href="{ $match//tei:publicationStmt/tei:idno[@type="uri"]/text() }" target="about"><i class="glyphicon glyphicon-new-window" /></a></li>
              }
          </ol>
          </div>
          
        </div>
};
declare function skosThesau:retrievePeople($project, $conceptUri){
    let $docCollection := collection("/db/apps/" || $project || "Data/people")
    let $peopleList := doc("/db/apps/" || $project || "Data/lists/list-people.xml")
    return
        <root>
        {
            for $match in $docCollection//lawd:person[.//apc:hasFunction[@rdf:resource = $conceptUri ]]
            return 
            $peopleList//data[id=substring-before(substring-after($match/@rdf:about, "people/"), "#this") ]
        }
        </root>
};
declare function skosThesau:retrievePeoplePanel($project, $conceptUri){
    let $doc-collection := collection("/db/apps/" || $project || "Data/people")
    return
        <div class="panel panel-default panel-terms">
           <div class="panel-heading">
              <h2 class="panel-title">People in { $project } related to this concept</h2>
            </div>
            <div class="panel-body">
              <ol>
              {
        for $match in $doc-collection//lawd:person[.//apc:hasFunction[@rdf:resource = $conceptUri ]]
        return 
            <li>
                { substring-before(substring-after($match/@rdf:about, "people/"), "#this") } - { $match//lawd:personalName[1]/text() }<a href="{ substring-before($match/@rdf:about, "#this") }" target="about"><i class="glyphicon glyphicon-new-window" /></a></li>
              }
          </ol>
          </div>
          
        </div>
};

declare function skosThesau:retrieveRelatedPlaces($project, $conceptUri){
    let $doc-collection := collection("/db/apps/" || $project || "Data/documents")
    let $place-collection :=collection("/db/apps/" || $project || "Data/places/" || $project)
    let $matches := <matches>
                  {for $match in $doc-collection//tei:rs[@ref = $conceptUri ][tei:placeName]
                    let $matchDoc:= root($match)
                    return 
                        <match>
                          <placeUri>{ $match//tei:placeName/@ref/string() }</placeUri>
                          <placeName>{ $match//tei:placeName/@key/string() }</placeName>
                          <docId>{ $matchDoc//ancestor-or-self::tei:TEI/@xml:id/string() }</docId>
                          <docTitle>{ $matchDoc//ancestor-or-self::tei:titleStmt/tei:title/text() }</docTitle>
                          <docUri>{ $matchDoc//ancestor-or-self::tei:publicationStmt/tei:idno[@type="uri"]/text() }</docUri>
                        </match>
                  }</matches>
    let $distinctPlaces := distinct-values($matches//placeUri)
        
    return
        <data>
       
          {
          for $place in $distinctPlaces
          let $relatedDistinctMatches := distinct-values($matches//match[placeUri = $place]//docId)
          let $relatedMatches := functx:distinct-deep($matches//match[placeUri = $place])

          return 
              <place>
                <placeUri>{ $place }</placeUri>
                <placeName>{ $place-collection//pleiades:Place[@rdf:about = $place]/dcterms:title/text() }</placeName>
                <docs>
                { for $match in $relatedMatches
                    
                  return
                    <doc>
                      <docId>{ $match/docId/text() }</docId>
                      <docTitle>{ $match//docTitle/text() }</docTitle>
                      <docUri>{ $match//docUri }</docUri>
                    </doc>
                  }
                  </docs>
            </place>
              }
          </data>
          
};

declare
function skosThesau:generalIndex($project as xs:string, $lang as xs:string?, $max as xs:int?){
  let $generalInd := doc("/db/apps/" || $project || "Data/list/general-index.xml")
  let $generalIndex := if(normalize-space($generalInd)="") then 
    util:eval('doc("/db/apps/' || $project || 'Data/lists/general-index.xml")')
    else $generalInd
  let $length:= if(not(exists($max))) then 100 else $max
  

let $userGroups := request:get-parameter("userGroups", ())
  
  return 
  <div>
  {
         if(contains($userGroups, $skosThesau:project || "-editors")) then
             
                <div class="">
                  <span class="">[General index last update: { substring-before($generalIndex//ancestor-or-self::node()/@lastUpdate, "T") }]</span>
                  <br/>
                        <button id="btn-regenerate" class="btn btn-warning" onclick="regenerateList()">Re-generate keywords list</button><br/>
                        <img id="f-load-indicator" class="hidden" src="$ausohnum-lib/resources/images/ajax-loader.gif"/>
                        <div id="messages"></div>
                        
                   </div>
          
         else ()
        }
  <div style="display: inline-block; height: auto;">
    { 
      for $item in $generalIndex//keyword
      let $conceptId:=data($item/@conceptId)
      let $conceptUri:=data($item/@conceptUri)
      let $label := normalize-space($item)
      let $weight := xs:int($item/@weight)
      
     
    
      order by $weight descending
      where $weight > 10
      return 
      if($label="") then () else

        <button class="btn btn-xs btn-primary" onclick="loadConcept('{ $conceptId }')"
        style="margin: 3px; float: left; position:relative; transformXXX: scale(); display: inline-block; ">{ $label } [{ $weight }]</button>
      
     }
 
     <br/>
     <script type="text/javascript">
    function loadConcept(conceptId){{
      var sourceFromXql = "/getConceptDetails/" + conceptId ;
      $("#conceptDetails").load(sourceFromXql);

      $("#thesaurus").fancytree("getTree").activateKey(conceptId);
    }};
function regenerateList(){{
    $("#messages").empty();
    $("#btn-regenerate").attr("disabled", true);
    $("#f-load-indicator").removeClass('hidden');
    $("#messages").text("The list of keywords is being regenerated. Request can take several minutes and return a false Proxy error...");
    $.ajax({{
        type: "POST",
        dataType: "json",
        url: "/keywords/update-general-index/",
        success: function (data) {{
        console.log(data);
            $("#f-load-indicator").addClass("hidden");
            
            $("#btn-regenerate").attr("disabled", false);
            if (data.status == "failed") {{
                $("#messages").text(data.message);
            }} else {{
                window.location.href = ".";
            }}
        }}
        }});
    }};
     </script>
   </div>
  </div>
};

