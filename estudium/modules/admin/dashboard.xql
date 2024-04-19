xquery version "3.1";

import module namespace config = "https://ausohnum.huma-num.fr/apps/eStudium/config" at "../config.xqm";
import module namespace functx="http://www.functx.com" at "/db/system/repo/functx-1.0/functx/functx.xql";
import module namespace teiEditor="http://ausonius.huma-num.fr/teiEditor"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/teiEditor/teiEditorApp.xql";

import module namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/" at "xmldb:exist:///db/apps/ausohnum-library/modules/skosThesau/skosThesauApp.xql";


declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace dct = "http://purl.org/dc/terms/";
declare namespace ev = "http://www.w3.org/2001/xml-events";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";

declare namespace local = "local";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xf = "http://www.w3.org/2002/xforms";

declare option exist:serialize "method=xml media-type=text/html omit-xml-declaration=no indent=yes";

declare variable $documents-collection := collection($config:project-data-root  || '/documents');
declare variable $concepts-collection := collection($config:data-root  || '/concepts');
declare variable $now := fn:current-dateTime();
declare variable $currentUser := sm:id()//username/text();
declare variable $userPrimaryGroup := sm:id()//group/text();

declare variable $schemes := $concepts-collection//rdf:RDF/skos:ConceptScheme[dc:publisher = "Project Patrimonium"];

declare function local:listDocuments(){

    <table
    class="table table-striped">

    <tr>
        <th/>
        <th>Title</th>
        <th>id</th>
        <th>Provenance</th>
        <th/>
        <th/>
        <th>Places</th>
        <th>People</th>
        <th>Events</th>

    </tr>
    {for $document in $documents-collection//tei:TEI
    return
    <tr>
    <td><a href="edit/document/{data($document/@xml:id)}" target="_blank">
    <i class="glyphicon glyphicon-eye-open"/></a>
    </td>
    <td>
    {$document//tei:fileDesc/tei:titleStmt/tei:title/text()}
    </td>
    <td>
    {data($document/@xml:id)}
    </td>
    <td>
    {$document//tei:sourceDesc/tei:msDesc/tei:msFrag/tei:history/tei:provenance/string()}
    </td>
    </tr>
    }
    </table>

};

declare function local:newDocument(){
    <div>
    <a onclick="openDialog('dialogNewDocument')"><i class="glyphicon glyphicon-plus"/>Create a new document</a>
    <!--Dialog for new document-->
    <div id="dialogNewDocument" title="Create a new document" class="modal fade" tabindex="-1" style="display: none;">

            <!-- Modal content-->
            <div class="modal-content modal4editor">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"/>
                    <h4 class="modal-title">Create a new document</h4>
                </div>
                <div class="modal-body">
                <div>
                    
                     {skosThesau:dropDownThesau('c19291', 'en', 'Status', 'row', (), 1, ())}

                     {skosThesau:dropDownThesau('c19297', 'en', 'Rank', 'row', (), 1, ())}
                     {skosThesau:dropDownThesau('c19303', 'en', 'Citizenship', 'row', (), 1, ())}
                </div>

                        <div class="form-group row">
                                <label for="personSex" class="col-sm-2 col-form-label">Sex</label>
                                <div class="col-sm-10">
                                <select id="personSex">
                                    <option value="m" selected="selected">Male</option>
                                    <option value="f" >Female</option>
                                    <option value="unknown">Unknown</option>
                                </select>
                                </div>
                            </div>

                            <div class="form-group row">
                                <label for="newPersonPraenomen" class="col-sm-2 col-form-label">Praenomen</label>
                                <div class="col-sm-10">
                                <input type="text" class="form-control" id="newPersonPraenomen" name="newPersonPraenomen"/>
                                </div>
                            </div>
                            <div class="form-group row">
                                <label for="newPersonNomen" class="col-sm-2 col-form-label">Nomen</label>
                                <div class="col-sm-10">
                                <input type="text" class="form-control" id="newPersonNomen" name="newPersonNomen"/>
                                </div>
                            </div>
                            <div class="form-group row">
                                <label for="newPersonCognomen" class="col-sm-2 col-form-label">Cognomen</label>
                                <div class="col-sm-10">
                                <input type="text" class="form-control" id="newPersonCognomen" name="newPersonCognomen"/>
                                </div>
                            </div>



                    <div class="form-group modal-footer">


                        <button id="addPeople" class="pull-left" onclick="createNewDocument()">Create person</button>
                        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                    </div>

                    <!--                <a href="javascript: void(0);" onclick="tests()">Test</a>        -->
                </div>
            </div>
       </div><!--End of dialog-->
    </div>
};

let $allSchemeList :=
(<table
    class="table table-striped">

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

        let $listOfConceptsAndCollections := $scheme/parent::node()//skos:Concept | $scheme/parent::node()//skos:Collection
        let $orphans := $listOfConceptsAndCollections[not(skos:broader)][@xml:id != $topConceptUri]
        let $noOfOrphans := count($orphans) - $noOfTopConcepts

            order by $scheme/dc:title[@type = 'full']/text() ascending
        return

            <tr>
                <td>{data($scheme/dc:title[@type = 'full']/text())}</td>
                <td>{data($scheme/@rdf:about)}</td>
                <td>{
                        for $editors at $pos in $scheme/dc:creator[@role = 'editor']
                        return
                            (concat(if ($pos > 1) then
                                ', '
                            else
                                (), $editors/text()))
                    }</td>
                <td><a
                        href="{$topConceptUri}"><i
                            class="glyphicon glyphicon-eye-open"/></a></td>
                <td><a
                        href="{concat('/admin/scheme/', $schemeShortName)}"><i
                            class="glyphicon glyphicon-edit"/></a></td>
                <td>{data($scheme/skosThesau:admin/@status)}</td>
                <td>{count($scheme/ancestor::*/skos:Concept)}</td>
                <td>{count($scheme/ancestor::*//skos:prefLabel)}</td>
                <td>{$noOfOrphans}</td>
            </tr>
    }
</table>)







return
    <div
        data-template="templates:surround"
        data-template-with="templates/page.html"
        data-template-at="content">

        <div
            class="container form">
            <div
                class="row">
                <div
                    class="col-xs-12 col-sm-12 col-md-12">
                    <h2>Admin Dashboard</h2>
                </div>
            </div>
            <div
                class="row">
                <ul
                    class="nav nav-tabs"
                    role="tablist">
                    <li
                        role="presentation"
                        class="active"><a
                            href="#documents"
                            aria-controls="documents"
                            role="tab"
                            data-toggle="tab">Documents</a></li>
                    <li
                        role="presentation"><a
                            href="#thesaurus"
                            aria-controls="thesaurus"
                            role="tab"
                            data-toggle="tab">Thesaurus</a></li>
                    <li
                        role="presentation"><a
                            href="#logs"
                            aria-controls="logs"
                            role="tab"
                            data-toggle="tab">Logs</a></li>

                </ul>


                <!-- Tab panes -->
                <div
                    class="tab-content">
                    <div
                        role="tabpanel"
                        class="tab-pane active"
                        id="documents">
                        
                        {teiEditor:listCollections()}
                        
                    </div>

                        <div
                            role="tabpanel"
                            class="tab-pane"
                            id="thesaurus">

                            <h2>Thesaurus</h2>
                            <a
                                href="/admin/new-scheme/"><button
                                    id="newScheme"
                                    class="btn btn-primary editbutton"
                                    appearance="minimal"
                                    type="button">

                                    <i
                                        class="glyphicon glyphicon-plus"></i>&#160;Scheme</button></a>
                            {$allSchemeList}
                        </div>
                   <div
                        role="tabpanel"
                        class="tab-pane"
                        id="logs">
                    </div>
                </div>
            </div>
        </div>
        <script type="text/javascript" src="$ausohnum-lib/resources/scripts/teiEditor/teiEditor-dashboard.js"/>
    </div>
