xquery version "3.1";

import module namespace functx="http://www.functx.com" at "/db/system/repo/functx-1.0/functx/functx.xql";
import module namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/" at "skosThesauApp.xql";

declare namespace op= "http://www.w3.org/2002/08/xquery-operators";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";


declare namespace ev = "http://www.w3.org/2001/xml-events";
declare namespace thot = "http://thot.philo.ulg.ac.be/";
declare namespace xf = "http://www.w3.org/2002/xforms";
declare namespace dct = "http://purl.org/dc/terms/";
declare namespace local = "local";

declare option exist:serialize "method=xml media-type=text/html omit-xml-declaration=no indent=yes";

declare variable $project := request:get-parameter('project', ());
declare variable $concepts-collection := collection('/db/data/' || $project || '/concepts');
declare variable $concept-backup-collection := collection('/db/data/' || $project || '/backups/concepts');
declare variable $account-collection := collection('/db/data/' || $project || '/accounts');
declare variable $logs := collection('/db/data/' || $project || '/logs');

declare variable $schemes := $concepts-collection//rdf:RDF/skos:ConceptScheme[.[functx:contains-case-insensitive(dc:publisher, $project)]];
declare variable $importedSchemes := $concepts-collection//rdf:RDF/skos:ConceptScheme[not(.[functx:contains-case-insensitive(dc:publisher, $project)])];
declare variable $externalSchemes := doc('/db/apps/' || $project || '-data/schemes/external-schemes.rdf')//skos:ConceptScheme;



declare variable $currentUser := sm:id();
declare variable $userPrimaryGroup := sm:get-user-primary-group($currentUser);
declare variable $now := fn:current-dateTime();


let $langs := distinct-values($concepts-collection//skos:Concept//skos:prefLabel/@xml:lang)


let $loglist :=
<table class="table table-striped">
    <tr>
        <th>Type of event</th>
        <th>Thot Concept</th>
        <th>User</th>
        <th>When</th>
        <th>Comments</th>
    </tr>
   {
  for $log in $logs//.[@type[contains(., 'delete-prefLabel')]]
      order by $log/@when descending
        return
          <tr>
                <td>{data($log/@type)}</td>
                <td>{data($log/@what)}</td>
                <td>{data($log/@who)}</td>
                <td>{concat(substring(data($log/@when), 1, 10), ' ', substring(data($log/@when), 12, 5))}</td>
                <td>
                {
                  if (starts-with($log/@type, 'request')) then ($log/thot:request/dc:title/text())
                  else if ($log/thot:adminComment) then ($log/thot:adminComment/text())
                    else()
                }</td>
          </tr>
    }
</table>




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

let $personalSchemeList :=

<table class="table table-striped">
   <tr>
  <th>Name</th>
  <th>URL</th>
  <th/>
  <th/>
  <th>Status</th>
  <th>No. of <br/>Concepts</th>
  <th>No. of <br/>prefLabels</th>
  <th>No. of <br/>orphan Concepts</th>
  </tr>
   {
  for $scheme in $schemes[dc:creator[@role="editor"]/@ref=$currentUser]
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
  <td><a href="{$topConceptUri}" ><i class="glyphicon glyphicon-eye-open"/></a></td>
  <td><a href="{concat('/admin/scheme/', $schemeShortName) }" ><i class="glyphicon glyphicon-edit"/></a></td>
  <td>{data($scheme/thot:admin/@status)}</td>
  <td>{count($scheme/ancestor::*/skos:Concept)}</td>
  <td>{count($scheme/ancestor::*//skos:prefLabel)}</td>
  <td>{$noOfOrphans}</td>
  </tr>
}
</table>


let $externalSchemeList :=
    <table class="table table-striped">

   <tr>
  <th>Name</th>
  <th>Short name</th>
  <th>URL</th>
  <th/>

  </tr>
   {
  for $scheme in $externalSchemes
            let $schemeShortName := data(functx:substring-after-last(functx:substring-before-last($scheme/@rdf:about, '/'), '/'))
            let $topConceptUri := data($scheme/skos:hasTopConcept/@rdf:resource)
            let $noOfTopConcepts := count($scheme/skos:hasTopConcept)
(:            data(functx:substring-after-last($scheme/skos:hasTopConcept/@rdf:resource, '/')):)

    let $listOfConceptsAndCollections := $scheme/parent::node()//skos:Concept|$scheme/parent::node()//skos:Collection
    let $orphans := $listOfConceptsAndCollections[not(skos:broader)][@xml:id != $topConceptUri]
    let $noOfOrphans := count($orphans) - $noOfTopConcepts

order by $scheme/dc:title[1]/text() ascending
  return

  <tr>
  <td>{$scheme/dc:title/text()}</td>
  <td>{$scheme/dc:title/dct:alternative/text()}</td>
  <td>{data($scheme/@rdf:about)}</td>

  </tr>
}
</table>

let $requests:= collection("/db/apps/thot/data/requests")
let $personalRequestList :=
<table class="table table-striped">

   <tr>
        <th>Id</th>
        <th>Title</th>
        <th>Description</th>
        <th>Priority</th>
        <th>Status</th>
        <th>Scheme</th>
        <th>Object</th>
  </tr>
  {
  for $request in $requests//thot:request[@assignee=$currentUser]
  order by $request/@created
  return
  <tr>
  <td>{$request/@xml:id/string()}</td>
        <td>{$request/dc:title}</td>
        <td>{$request/description}</td>
        <td>{$request/@priority/string()}</td>
        <td>{$request/@status/string()}</td>
        <td>{$request/@scheme/string()}</td>
        <td>{$request/@object/string()} <a href="/admin/concept/{$request/@object/string()}" target="blank" ><i class="glyphicon glyphicon-eye-open"/></a></td>
      </tr>
  }
  </table>

let $allTeamRequestList :=
<table class="table table-striped">

   <tr>
        <th>Id</th>
        <th>Creator</th>
        <th>Title</th>
        <th>Priority</th>
        <th>Status</th>
        <th>Scheme</th>
        <th>Object</th>
        <th/>
  </tr>
  {
  for $request in $requests//thot:request[@assignee='all-team']
  order by $request/@created
  return
  <tr>
  <td>{$request/@xml:id/string()}</td>
  <td>{$request/@creator/string()}</td>
        <td>{$request/dc:title}</td>
        <td>{$request/@priority/string()}</td>
        <td>{$request/@status/string()}</td>
        <td>{
            if($request/@scheme/string() !="")
            then $request/@scheme/string()
            else("N/A")}</td>
        <td>{
            if($request/@object/string() !="")
            then (<span>{$request/@object/string()} &#160;<a href="/admin/concept/{$request/@object/string()}" target="blank" ><i class="glyphicon glyphicon-eye-open"/></a></span>)
            else("N/A")}</td>
            <td><a href="{$request}" ><i class="glyphicon glyphicon-eye-open"/></a></td>
      </tr>

  }
  </table>

let $adminAllRequestList :=

<table class="table table-striped">

   <tr>
        <th>Id</th>
        <th>Title</th>
        <th>Description</th>
        <th>Priority</th>
        <th>Status</th>
        <th>Scheme</th>
        <th>Object</th>
  </tr>
  {
  for $request in $requests//thot:request
  order by $request/@created
  return
  <tr>
  <td>{$request/@xml:id/string()}</td>
        <td>{$request/dc:title}</td>
        <td>{$request/description}</td>
        <td>{$request/@priority/string()}</td>
        <td>{$request/@status/string()}</td>
        <td>{$request/@scheme/string()}</td>
        <td>{$request/@object/string()}&#160;<a href="/admin/concept/{$request/@object/string()}" target="blank" ><i class="glyphicon glyphicon-eye-open"/></a></td>
      </tr>
  }
  </table>

let $importPrefLabels:=
  <div class="panel col-sm-3 col-lg-3">
    <h3>Import preferred labels in existing concepts (based on Concept ID)</h3>
    
    <h4>Data format</h4>
        <p>2 columns: concept ID | preferred label</p>
        <h4>Data sample</h4>
        <p>thot-6200	Materiale<br/>
thot-6201	non organico<br/>
thot-6202	pietra<br/>
thot-6203	anortosite<br/>
thot-6204	basalto<br/></p>
        
        <form enctype="multipart/form-data" method="post" action="/modules/admin/import-new-labels.xql">

            <fieldset>
            <legend>Upload an csv file (tab separated)</legend>
            <input type="file" name="file"/>
            <div class="input-group">
          <span class="input-group-addon">Language</span>
          <input type="text" class="form-control" aria-label="Iso language code" name="language"/>
          
            </div>

            <button id="f-btn-upload" name="f-btn-upload" type="submit" class="btn btn-default">Import</button>
        </fieldset>
    </form>
</div>


let $importPrefLabelExactMatch :=
  <div class="panel col-sm-3 col-lg-3">
    <h3>Import preferred labels in existing concepts based (based on exactMatch with external thesaurus)</h3>
    
    <h4>Data format</h4>
        <p>2 columns: skos:notation | preferred label</p>
        <h4>Data sample</h4>
        <p>05/0001/1	niet-organisch<br/>
05/0002/2	Gesteente<br/>
05/0003/3	anorthosiet<br/>
05/0004/3	basalt</p>
        
        <form enctype="multipart/form-data" method="post" action="/modules/admin/import-new-labels-exactmatch.xql">

            <fieldset>
            <legend>Upload an csv file (tab separated)</legend>
            <input type="file" name="file"/>
            <div class="input-group">
          <span class="input-group-addon">Language</span>
          <input type="text" class="form-control" aria-label="Iso language code" name="language"/>
          
            </div>

            <button id="f-btn-upload" name="f-btn-upload" type="submit" class="btn btn-default">Import</button>
        </fieldset>
    </form>
</div>

let $exportConcepts :=
  <div class="panel col-sm-3 col-lg-3">
    <h3>Export data</h3>
    
        <form enctype="multipart/form-data" method="post" action="/modules/admin/export-concepts.xql">
<h4>This feature exports data as a csv file, which includes the Thot no, the English prefLabel and the prefLabel of the language of your choice</h4>
            <fieldset>
            
        <div class="form-group">
          <label for="thesaurus">Thesaurus</label>
          <select class="form-control" name="thesaurus">
            { for $scheme in $schemes
                        let $schemeShortName := data(functx:substring-after-last(functx:substring-before-last($scheme/@rdf:about, '/'), '/'))
                        order by $scheme/dc:title[@type='full']/text() ascending
          
                        return
                        <option value="{$schemeShortName}">{$schemeShortName}</option>
                        
                    }
          </select>
        </div>
                    <div class="form-group">
          <label for="lang">Language</label>
          <select class="form-control" name="lang">
          <option value="all-languages">All languages</option>
            { for $lang in $langs
                order by $lang
                return
                <option value="{$lang}">{$lang}</option>
                
            }
          </select>
        </div>
            
            
            <div class="input-group">
            <label for="type">Type</label>
            <select name="type">
                <option value="csv" selected="selected">csv</option>
                
            </select>
            </div>
          <div class="input-group">
          <label for="separator">Separator</label>
            <select name="separator">
                <option value="tab" selected="selected">tab (perfect for spreadsheets)</option>
                <option value="csv">comma</option>
            </select>
          
          
           </div>
           <h4>Extra options</h4>
           <div class="checkbox">
                <label><input type="checkbox" value="daterange" name="daterange">Date ranges</input></label>
              </div>
              <!--
              <div class="checkbox">
                <label><input type="checkbox" value="">Option 2</label>
           </div>
           -->

            <button id="exportButton" name="exportButton" type="submit" class="btn btn-default">Export</button>
        </fieldset>
    </form>
</div>
(:
**********************
*    MAIN RETURN     *
**********************
:)

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


     <!-- Tab panes -->
      <div class="tab-content">
        <div role="tabpanel" class="tab-pane active" id="scheme">
        <a href="/admin/new-scheme/"><button id="newScheme" class="btn btn-primary editbutton" appearance="minimal" type="button">

<i class="glyphicon glyphicon-plus"></i>&#160;Scheme</button></a>
<h2>My {if(count($schemes[dc:creator[@role="editor"]/@ref=$currentUser]) > 1)
        then concat(count($schemes[dc:creator[@role="editor"]/@ref=$currentUser]), " ") else ()}scheme{if(count($schemes[dc:creator[@role="editor"]/@ref=$currentUser]) > 1)
        then "s" else ()}

</h2>
{$personalSchemeList}
 <h2>All Schemes {if(count($schemes) > 1)
        then concat(" (", count($schemes), ")") else ()}


 </h2>
 {$allSchemeList}
 <h2>External Schemes used for alignment
 <button id="newExternalScheme" class="btn btn-primary editbutton  pull-right" appearance="minimal" type="button">
<i class="glyphicon glyphicon-plus"></i>&#160;External Scheme</button></h2>
 {$externalSchemeList}
</div>
<div role="tabpanel" class="tab-pane" id="issues">
<a href="/admin/new-request/"><button id="newRequest" class="btn btn-primary editbutton" appearance="minimal" type="button">

<i class="glyphicon glyphicon-plus"> </i>&#160;Request</button></a>
  <h2>Requests assigned to me</h2>
{if(exists($requests//thot:request[@assignee=$currentUser]))
then $personalRequestList
else (<p>There is curently no request assigned to you.</p>)}
 <h2>Requests assigned to all members</h2>
 {if(exists($requests//thot:request[@assignee=$currentUser]))
then $allTeamRequestList
else (<p>There is currently no request assigned to all members.</p>)}


{if (contains(sm:get-user-groups($currentUser), 'dba')) then
    (<h2>All requests</h2>, $adminAllRequestList)
    else()
}

</div>

<div role="tabpanel" class="tab-pane" id="logs">
 <h2>Logs</h2>
 {$loglist}
</div>
  <div role="tabpanel" class="tab-pane" id="exportAndImport">
   <h2>Export and import data</h2>
      {$exportConcepts}
      {$importPrefLabels}
      {$importPrefLabelExactMatch}
      
  </div>

</div>
 </div>
</div>
