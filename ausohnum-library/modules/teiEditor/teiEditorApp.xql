(:~
: AusoHNum Library - teiEditor module
: This module contains the main functions of the teiEditor module.
: @author Vincent Razanajao
:)


xquery version "3.1";

module namespace teiEditor="http://ausonius.huma-num.fr/teiEditor";

import module namespace config="http://ausonius.huma-num.fr/ausohnum-library/config" at "../config.xqm";

import module namespace dbutil="http://exist-db.org/xquery/dbutil" at "/db/apps/shared-resources/content/dbutils.xql";
import module namespace functx="http://www.functx.com";
(:import module namespace httpclient="http://exist-db.org/xquery/httpclient" at "java:org.exist.xquery.modules.httpclient.HTTPClientModule";:)
import module namespace http="http://expath.org/ns/http-client" at "java:org.expath.exist.HttpClientModule";
import module namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/" at "../skosThesau/skosThesauApp.xql";
import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace zoteroPlugin="http://ausonius.huma-num.fr/zoteroPlugin" at "../zoteroPlugin/zoteroPlugin.xql";
(:import module namespace tan="http://alpheios.net/namespaces/text-analysis" at "./cts-3/textanalysis_utils.xquery";:)
(:import module namespace templates="http://exist-db.org/xquery/templates" ;:)
(:import module namespace config="http://patrimonium.huma-num.fr/config" at "../config.xqm";:)


declare boundary-space preserve;

declare namespace apc="http://patrimonium.huma-num.fr/onto#";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace dct = "http://purl.org/dc/terms/";
declare namespace dcterms="http://purl.org/dc/terms/";
declare namespace err = "http://www.w3.org/2005/xqt-errors";
declare namespace ev = "http://www.w3.org/2001/xml-events";
declare namespace foaf = "http://xmlns.com/foaf/0.1/";
declare namespace geo = "http://www.w3.org/2003/01/geo/wgs84_pos#";
declare namespace lawd="http://lawd.info/ontology/";
declare namespace owl="http://www.w3.org/2002/07/owl#";
declare namespace pleiades="https://pleiades.stoa.org/places/vocab#";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfs = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace snap="http://onto.snapdrgn.net/snap#";
declare namespace spatial="http://geovocab.org/spatial#";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace thot = "http://thot.philo.ulg.ac.be/";
declare namespace xf = "http://www.w3.org/2002/xforms";
declare namespace local = "local";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
(:declare option output:item-separator "&#xa;";:)

declare variable $teiEditor:library-path := "/db/apps/ausohnum-library/";
declare variable $teiEditor:project :=request:get-parameter('project', ());
declare variable $teiEditor:mode :=request:get-parameter('mode', ());
declare variable $teiEditor:appVariables := doc("/db/apps/" || $teiEditor:project || "/data/app-general-parameters.xml");
declare variable $teiEditor:data := request:get-data();
declare variable $teiEditor:docId :=  request:get-parameter('docid', ());

declare variable $teiEditor:lang :=request:get-parameter('lang', "en");
declare variable $teiEditor:languages := $teiEditor:appVariables//languages;


(:declare variable $teiEditor:project := "patrimonium";:)
(:declare variable $teiEditor:data-repository := collection("/db/apps/" || $teiEditor:project || "Data");:)
declare variable $teiEditor:data-repository-path := "/db/apps/" || $teiEditor:project || "Data";

declare variable $teiEditor:doc-collection-path := $teiEditor:data-repository-path || "/documents";
declare variable $teiEditor:doc-collection := collection($teiEditor:doc-collection-path);
declare variable $teiEditor:concept-collection-path := "/db/apps/" || $teiEditor:appVariables//thesaurus-app/text() || "Data/concepts";
declare variable $teiEditor:concept-collection := collection( $teiEditor:concept-collection-path);
declare variable $teiEditor:biblioRepo := doc($teiEditor:data-repository-path || "/biblio/biblio.xml");
declare variable $teiEditor:peopleRepo := doc($teiEditor:data-repository-path || "/people/people.xml");
declare variable $teiEditor:peopleCollection := collection($teiEditor:data-repository-path || "/people");
declare variable $teiEditor:placeCollection := collection($teiEditor:data-repository-path || "/places");
declare variable $teiEditor:projectPlaceCollection := collection($teiEditor:data-repository-path || "/places/" || $teiEditor:project);
declare variable $teiEditor:placeRepo := doc($teiEditor:data-repository-path || "/places/listOfPlaces.xml");
declare variable $teiEditor:objectRepositoriesUri := $teiEditor:appVariables//objectRepositoriesUri/text();

declare variable $teiEditor:baseUri := $teiEditor:appVariables//uriBase[@type='app']/text();


declare variable $teiEditor:teiElements := doc($teiEditor:library-path || 'data/teiEditor/teiElements.xml');
declare variable $teiEditor:teiElementsCustom := doc("/db/apps/" || $teiEditor:project || '/data/teiEditor/teiElements.xml');
declare variable $teiEditor:docTemplates := collection($teiEditor:library-path || 'data/teiEditor/docTemplates');
declare variable $teiEditor:teiTemplate := doc($teiEditor:library-path || 'data/teiEditor/teiTemplate.xml');
declare variable $teiEditor:externalResources := doc($teiEditor:library-path || 'data/teiEditor/externalResources.xml');
declare variable $teiEditor:teiDoc := $teiEditor:doc-collection/id($teiEditor:docId) ;
declare variable $teiEditor:docTitle :=  $teiEditor:teiDoc//tei:fileDesc/tei:titleStmt/tei:title/text() ;

declare variable $teiEditor:logs := collection($teiEditor:data-repository-path || '/logs');
declare variable $teiEditor:now := fn:current-dateTime();
declare variable $teiEditor:currentUser := data(sm:id()//sm:username);
declare variable $teiEditor:currentUserUri := concat($teiEditor:baseUri, '/people/' , data(sm:id()//sm:username));
declare variable $teiEditor:zoteroGroup :=request:get-parameter('zoteroGroup', ());

declare variable $teiEditor:nl := "&#10;"; (:New Line:)

declare
    %templates:wrap
    function teiEditor:version($node as node(), $model as map(*)){
    data( $config:expath-descriptor//@version)

};
declare
    %templates:wrap
    function teiEditor:variables($docId as xs:string, $project as xs:string){
    <div class="hidden">
        <div id="currentDocId">{ $docId }</div>
        <div id="currentProject">{ $project } </div>
    </div>

};

declare function teiEditor:newUserForm($project){

 <div data-template="templates:surround" data-template-with="templates/page.html" data-template-at="content">
       <div class="container form">
            <div class="row">
                <div class="col-xs-12 col-sm-12 col-md-12">
                <div>
                        <form id="newUserForm" role="form" data-toggle="validator" novalidate="true">
                                      <div class="form-group row">
                                                <label for="newUserFirstName" class="col-sm-2 col-form-label">Firstname</label>
                                                <div class="col-sm-10">
                                                <input type="text" class="form-control" id="newUserFirstName" name="newUserFirstName" required="required" />
                                                </div>
                                      </div>
                                       <div class="form-group row">
                                                <label for="newUserLastName" class="col-sm-2 col-form-label">Lastname</label>
                                                <div class="col-sm-10">
                                                <input type="text" class="form-control" id="newUserLastName" name="newUserLastName" required="required" />
                                                </div>
                                        </div>
                                        <div class="form-group row">
                                                <label for="newUserUsername" class="col-sm-2 col-form-label">Username</label>
                                                <div class="col-sm-10">
                                                <input type="text" class="form-control" id="newUserUsername" name="newUserUsername" required="required"/>
                                                </div>
                                        </div>
                                        <div class="form-group row">
                                                <label for="newUserPassword" class="col-sm-2 col-form-label">Password</label>
                                                <div class="col-sm-10">
                                                <input type="password" class="form-control" placeholder="Password" id="newUserPassword" name="newUserPassword" autocomplete="off" required="required"/>
                                                 <input type="password"  class="form-control" placeholder="Confirm Password" id="confirm_password" autocomplete="off" required="required"/>
                                                  <span id='message'></span>
                                                </div>
                                        </div>
                                </form>
                                    <div class="modal-footer">
                                        <button id="createUser" class="pull-left" onclick="createUser()">Create User</button>
                                        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                                    </div>
                    </div>
                    </div>
                    </div>
                    </div>
                    <script type="text/javascript" src="$ausohnum-lib/resources/scripts/teiEditor/teiEditor-dashboard.js"/>
                    </div>
};

declare function teiEditor:createUser($data, $project) {
    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)

    let $template := collection('/db/apps/ausohnum-library/data/teiEditor/docTemplates')//.[@xml:id=$data//template/text()]
    let $doc-collection := collection($teiEditor:data-repository-path || "/documents/" || $data//collection/text())
    let $doc-collection-path := $teiEditor:data-repository-path || "/documents/" || $data//collection/text()
    let $collectionPrefix := doc($teiEditor:data-repository-path || "/documents/" || $data//collection/text() || ".xml")//docPrefix/text()
(:    let $docIdPrefix := $teiEditor:appVariables//idPrefix[@type='document']/text():)

    let $firstName := $data//newUserFirstName/text()
    let $lastName := $data//newUserLastName/text()
    let $username := $data//newUserUsername/text()
    let $password := $data//newUserPassword/text()
    let $createUser := sm:create-account($username , $password, "sandbox", ())


let $logEvent := teiEditor:logEvent("new-user" , $username, (),
                        "New user " || $username || " has been created in in group sandbox")
    return
    <result>
    <sentData>{ $data }</sentData>

    </result>
};








declare function teiEditor:displayElement($teiElementNickname as xs:string,
                                          $docId as xs:string?,
                                          $index as xs:int?,
                                          $xpath_root as xs:string?) {
   
   let $elementNode := if (not(exists($teiEditor:teiElementsCustom//teiElement[nm=$teiElementNickname]))) 
                                        then $teiEditor:teiElements//teiElement[nm=$teiElementNickname] 
                                        else $teiEditor:teiElementsCustom//teiElement[nm=$teiElementNickname]
(:    let $elementNode := util:eval(doc($teiEditor:library-path || 'data/teiEditor/teiElements.xml')):)


    let $elementIndex := if ($index ) then ("[" || string($index) || "]" ) else ("")
    let $fieldType := $elementNode/fieldType/text()
    let $attributeValueType := $elementNode/attributeValueType/text()
    let $conceptTopId := if($elementNode/thesauDb/text()) then
                        substring-after($elementNode/thesauTopConceptURI, '/concept/')
                        else()
    let $xpathRaw := $elementNode/xpath/text()
    let $xpathEnd := if(contains($xpathRaw, "/@"))
            then( functx:substring-before-last($xpathRaw[1], '/') || $elementIndex || "/" || functx:substring-after-last($xpathRaw[1], '/'))
            else($xpathRaw)
    let $elementAncestors := $elementNode/ancestor::teiElement
    let $teiXPath := if($xpath_root !="")
                    then
                        $xpath_root 
(:                        || $xpathRaw:)
                    else
                     if($elementNode/ancestor::teiElement)
                                then
                                    string-join(
                                    for $ancestor at $pos in $elementAncestors
                                        let $ancestorIndex := if($pos > 1 ) then
                                            if($index) then "[" || string($index -1) || "]" else ("")
                                            else ("")
                                    return
                                    if (contains($ancestor/xpath/text(), '/@'))
                                         then
                                             substring-before($ancestor/xpath/text(), '/@')
                                             || $ancestorIndex
                                          else $ancestor/xpath/text() ||
                                        $ancestorIndex
                                    )
                                 || $xpathEnd
                            else
                        $xpathEnd


    let $teiElementDataType := $teiEditor:teiElements//teiElement[nm=$teiElementNickname]/contentType/text()
    let $teiElementFormLabel := $teiEditor:teiElements//teiElement[nm=$teiElementNickname]/formLabel[@xml:lang=$teiEditor:lang]/text()
    let $docID := if($docId != "") then $docId else $teiEditor:docId
(:    let $teiDoc := $teiEditor:doc-collection/id($teiEditor:docId):)
    (:let $teiElementValue :=
         (data(
            util:eval( "$teiEditor:doc-collection/id('" ||$docID ||"')/" || $teiXPath)))
    :)        
            
              
 (:   let $teiElementValue :=
         (data(
            util:eval( "$teiEditor:doc-collection/id('" ||$docID ||"')/" || $teiXPath)))
    :)        
(:    let $logEventTest:= teiEditor:logEvent("test-before-display-Element", $docID, <data>{"teiElementNM: " || $teiElementNickname ||
    " ; $conceptTopId: " || (if ($conceptTopId) then $conceptTopId else ())|| " ; docId: " || $docID || " ; index: " || (if ($index ) then $index else ()) || "teiXPath: " || $teiXPath}</data>, "test")
:)
    return

        switch ($fieldType)
        case "input" return
        teiEditor:displayTeiElementCardiMultiLang($teiElementNickname, $docID, $index, 'input', $teiXPath)
        case "textarea" return
        teiEditor:displayTeiElementCardiMultiLang($teiElementNickname, $docID, $index, 'textarea', $teiXPath)
        case "combobox" return
        teiEditor:displayTeiElementWithThesauCardi($teiElementNickname, $conceptTopId, $docID, $index, $teiXPath)
        
        case "comboboxAndInput" return
        teiEditor:displayTeiElementWithThesauComboInputCardi($teiElementNickname, $elementNode/thesauTopConceptURI/text(), $docID, $index, $teiXPath)
        case "place" return
        teiEditor:displayPlace($teiElementNickname, $docID, $index, $teiXPath)
        case "group" return
         teiEditor:displayGroup($teiElementNickname, $docID, $index, (), $teiXPath)
(:        teiEditor:displayTeiElementAndChildren($teiElementNickname, $docID, $index, 'input', $teiXPath):)
        default return
                "Error: Element type not found in teiElement definitions."
(:                teiEditor:displayTeiElement($teiElementNickname, $index, 'input', $teiXPath):)
};

declare function teiEditor:displayElementWithDef($elementNode as node(),
                                          $docId as xs:string?,
                                          $index as xs:int?,
                                          $xpath_root as xs:string?) {
   
  (: let $elementNode := if (not(exists($teiEditor:teiElementsCustom//teiElement[nm=$teiElementNickname]))) 
                                        then $teiEditor:teiElements//teiElement[nm=$teiElementNickname] 
                                        else $teiEditor:teiElementsCustom//teiElement[nm=$teiElementNickname]:)
(:    let $elementNode := util:eval(doc($teiEditor:library-path || 'data/teiEditor/teiElements.xml')):)
let $teiElementNickname := $elementNode/nm/text()

    let $elementIndex := if ($index ) then ("[" || string($index) || "]" ) else ("")
    let $fieldType := $elementNode/fieldType/text()
    let $attributeValueType := $elementNode/attributeValueType/text()
    let $conceptTopId := if($elementNode/thesauDb/text()) then
                        substring-after($elementNode/thesauTopConceptURI, '/concept/')
                        else()
    let $xpathRaw := $elementNode/xpath/text()
    let $xpathEnd := if(contains($xpathRaw, "/@"))
            then( functx:substring-before-last($xpathRaw[1], '/') || $elementIndex || "/" || functx:substring-after-last($xpathRaw[1], '/'))
            else($xpathRaw)
    let $elementAncestors := $elementNode/ancestor::teiElement
    let $teiXPath := if($xpath_root !="")
                    then
                        $xpath_root 
(:                        || $xpathRaw:)
                    else
                     if($elementNode/ancestor::teiElement)
                                then
                                    string-join(
                                    for $ancestor at $pos in $elementAncestors
                                        let $ancestorIndex := if($pos > 1 ) then
                                            if($index) then "[" || string($index -1) || "]" else ("")
                                            else ("")
                                    return
                                    if (contains($ancestor/xpath/text(), '/@'))
                                         then
                                             substring-before($ancestor/xpath/text(), '/@')
                                             || $ancestorIndex
                                          else $ancestor/xpath/text() ||
                                        $ancestorIndex
                                    )
                                 || $xpathEnd
                            else
                        $xpathEnd


    let $teiElementDataType := $teiEditor:teiElements//teiElement[nm=$teiElementNickname]/contentType/text()
    let $teiElementFormLabel := $teiEditor:teiElements//teiElement[nm=$teiElementNickname]/formLabel[@xml:lang=$teiEditor:lang]/text()
    let $docID := if($docId != "") then $docId else $teiEditor:docId
(:    let $teiDoc := $teiEditor:doc-collection/id($teiEditor:docId):)
    (:let $teiElementValue :=
         (data(
            util:eval( "$teiEditor:doc-collection/id('" ||$docID ||"')/" || $teiXPath)))
    :)        
            
              
 (:   let $teiElementValue :=
         (data(
            util:eval( "$teiEditor:doc-collection/id('" ||$docID ||"')/" || $teiXPath)))
    :)        
(:    let $logEventTest:= teiEditor:logEvent("test-before-display-Element", $docID, <data>{"teiElementNM: " || $teiElementNickname ||
    " ; $conceptTopId: " || (if ($conceptTopId) then $conceptTopId else ())|| " ; docId: " || $docID || " ; index: " || (if ($index ) then $index else ()) || "teiXPath: " || $teiXPath}</data>, "test")
:)
    return

        switch ($fieldType)
        case "input" return
        teiEditor:displayTeiElementCardiMultiLang($teiElementNickname, $docID, $index, 'input', $teiXPath)
        case "textarea" return
        teiEditor:displayTeiElementCardiMultiLang($teiElementNickname, $docID, $index, 'textarea', $teiXPath)
        case "combobox" return
        teiEditor:displayTeiElementWithThesauCardi($teiElementNickname, $conceptTopId, $docID, $index, $teiXPath)
        
        case "comboboxAndInput" return
        teiEditor:displayTeiElementWithThesauComboInputCardi($teiElementNickname, $elementNode/thesauTopConceptURI/text(), $docID, $index, $teiXPath)
        case "place" return
        teiEditor:displayPlace($teiElementNickname, $docID, $index, $teiXPath)
        case "group" return
         teiEditor:displayGroup($teiElementNickname, $docID, $index, (), $teiXPath)
(:        teiEditor:displayTeiElementAndChildren($teiElementNickname, $docID, $index, 'input', $teiXPath):)
        default return
                "Error: Element type not found in."
(:                teiEditor:displayTeiElement($teiElementNickname, $index, 'input', $teiXPath):)
};

declare function teiEditor:displayTeiElement($teiElementNickname as xs:string, $index as xs:int?, $type as xs:string?, $xpath_root as xs:string?) {
(:    PLESE NOT USE this function but displayTeiElementCardi:)


    let $elementNode := if (exists($teiEditor:teiElementsCustom//teiElement[nm=$teiElementNickname])) then
                        $teiEditor:teiElementsCustom//teiElement[nm=$teiElementNickname]
                        else ($teiEditor:teiElements//teiElement[nm=$teiElementNickname])
    let $cardinality := $elementNode/cardinality/text()
    let $elementIndex := if($index ) then
                         if($cardinality != "1") then ("[" || string($index) || "]" ) else ("") else ("")
    let $xpathRaw := $elementNode/xpath/text()
    let $xpathEnd := if(contains($xpathRaw, "/@"))
            then( functx:substring-before-last($xpathRaw, '/') || $elementIndex || "/" || functx:substring-after-last($xpathRaw, '/'))
            else($xpathRaw)

    let $elementAncestors := $elementNode/ancestor::teiElement/.
    let $teiXPath := if($elementNode/ancestor::teiElement)
                    then
                        string-join(
                        for $ancestor at $pos in $elementAncestors
                        let $ancestorIndex := if($pos = 1 ) then
                            if($index) then "[" || string($index) || "]" else ("")
                            else ("")
                        return
                        if (contains($ancestor/xpath/text(), '/@'))
                        then
                            substring-before($ancestor/xpath/text(), '/@')
                            || $ancestorIndex
                            else $ancestor/xpath/text() ||
                            $ancestorIndex
                        )
                     || $xpathEnd
                    else
                        $xpathEnd


    let $teiElementDataType := $teiEditor:teiElements//teiElement[nm=$teiElementNickname]/contentType/text()
    let $teiElementFormLabel := $teiEditor:teiElements//teiElement[nm=$teiElementNickname]/formLabel[@xml:lang=$teiEditor:lang]/text()
    let $teiDoc := $teiEditor:doc-collection/id($teiEditor:docId)
    let $teiElementAttributeValue :=
         (data(util:eval( "$teiEditor:doc-collection/id('" ||$teiEditor:docId ||"')/" || $teiXPath)))
    let $teiElementTextNodeValue := if($teiElementDataType = "textNodeAndAttribute" ) then
         (data(util:eval( "$teiEditor:doc-collection/id('" ||$teiEditor:docId ||"')/" || substring-before($teiXPath, '/@'))))
                                    else(data(util:eval( "collection('" || $teiEditor:doc-collection-path || "')//id('" ||$teiEditor:docId ||"')/" || $teiXPath)))
    return

        <div class="teiElementGroup">
        <div id="{$teiElementNickname}_display_{$index}_1" class="">
        <div class="TeiElementGroupHeaderInline">
        <span class="labelForm">{$teiElementFormLabel} <span class="teiInfo">
            <a title="TEI element: {$teiXPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
            </span></span>
            </div>
            <div id="{$teiElementNickname}_value_{$index}_1" class="teiElementValue" style="{if($type= "textarea") then "width: 100%;" else ()}">
            {switch ($teiElementDataType)
                    case "text" return $teiElementTextNodeValue
                    case "textNodeAndAttribute" return
                        (<span>{$teiElementTextNodeValue}
                        <a href="{$teiElementAttributeValue}" target="_blank" class="urlInTeiElement">{$teiElementAttributeValue}</a></span>)
                    default return "Error! check type of field"
            }</div>
            <button id="edit{$teiElementNickname}_{$index}_1" class="btn btn-primary editbutton pull-right"
             onclick="editValue('{$teiElementNickname}', '{$index}', '1')"
                    appearance="minimal" type="button"><i class="glyphicon glyphicon-edit
                              editConceptIcon"></i></button>
        </div>

        <div id="{$teiElementNickname}_edit_{$index}_1" class="teiElementHidden form-group">
        <div class="input-group" >
        <span class="labelForm">{$teiElementFormLabel} <span class="teiInfo">
            <a title="TEI element: {$teiXPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
            </span></span>po

                {switch ($type)
                 case "input" return
                    switch ($teiElementDataType)
                    case "text" return
                    <input id="{$teiElementNickname}_{$index}_1" class="form-control" name="{$teiElementNickname}_{$index}_1" value="{$teiElementAttributeValue}"></input>
                    case "textNodeAndAttribute" return
                    <div>
                    <span>Value of <em>Attribute</em> {functx:substring-after-last($teiXPath, '/')}</span>
                    <input id="{$teiElementNickname}_text_{$index}_1" class="form-control" name="{$teiElementNickname}_text_{$index}_1"
                     placeholder="Value of Attribute{functx:substring-after-last($teiXPath, '/')}"
                    value="{ $teiElementAttributeValue }"></input>
                    <span> Value of <em>Node Text</em></span><input id="{$teiElementNickname}_attrib_{$index}_1" class="form-control" name="{$teiElementNickname}_attrib_{$index}_1" value="{ $teiElementTextNodeValue }" placeholder="Value of Text node"></input>
                    </div>
                    default return "Error! Check data type - l. 351"

                 case "textarea" return
                 <textarea id="{$teiElementNickname}_{$index}_1" class="form-control summernote" name="{$teiElementNickname}_{$index}_1">{ $teiElementTextNodeValue }</textarea>
                 default return null
                 }
                <button id="{$teiElementNickname}SaveButton" class="btn btn-success"
                onclick="saveData('{$teiEditor:docId}', '{$teiElementNickname}', '{$teiXPath}',
                    '{$teiElementDataType}', '{$index}', {$cardinality})"
                        appearance="minimal" type="button"><i class="glyphicon
glyphicon glyphicon-ok-circle"></i></button>
                <button id="{$teiElementNickname}CancelEdit" class="btn btn-danger"
                onclick="cancelEdit('{$teiElementNickname}', '{$index}', '{$teiElementTextNodeValue}', 'input', '1') "
                        appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>

        </div></div>
        </div>
};

declare function teiEditor:displayTeiElementCardi($teiElementNickname as xs:string,
             $docId as xs:string?,
             $index as xs:integer?,
             $type as xs:string?,
             $xpath_root as xs:string?) {


let $currentDocId := if($docId != "") then $docId else  $teiEditor:docId
        let $indexNo := if($index) then data($index) else "1"
        let $elementNode := $teiEditor:teiElements//teiElement[nm=$teiElementNickname]
        let $elementIndex := if($elementNode/ancestor::teiElement)
                    then ""
                    else if
                        ($index) then ("[" || string($index) || "]" ) else ("")

        let $xpathEnd := if(contains($elementNode//xpath[1]/text(), "/@"))
            then(functx:substring-before-last($elementNode//xpath/text(), '/') || $elementIndex || "/"
            || functx:substring-after-last($elementNode//xpath/text(), '/')
            )
            else (
            $elementNode/./xpath/text()
            )
       let $elementAncestors := $elementNode/ancestor::teiElement
    let $teiXPath :=
                if($xpath_root)
                    then
                        $xpath_root
                                else if($elementNode/ancestor::teiElement)
                                then
                                    string-join(
                                    for $ancestor at $pos in $elementAncestors
                                    let $ancestorIndex := if($pos = 1 ) then
                                        if($index) then "[" || string($index) || "]" else ("")
                                        else ("")
                                    return
                                    if (contains($ancestor/xpath/text(), '/@'))
                                    then
                                        substring-before($ancestor/xpath/text(), '/@')
                                        || $ancestorIndex
                                        else $ancestor/xpath/text() ||
                                        $ancestorIndex
                                    )
                                 || $xpathEnd
                                else
                                    $xpathEnd




     let $xpathBaseForCardinalityX :=
            if (contains($teiXPath, "/@")) then
            (functx:substring-before-last(functx:substring-before-last($teiXPath, "/@"), '/'))
            else
                ($teiXPath)

     let $selectorForCardinalityX :=
            if (contains($teiXPath, "/@")) then
            (functx:substring-after-last(functx:substring-before-last($teiXPath, "/@"), "/"))
            else
                (functx:substring-after-last($teiXPath, "/"))

    let $contentType :=$elementNode/contentType/text()
    let $teiElementDataType := $elementNode/contentType/text()
    let $teiElementFormLabel := $elementNode/formLabel[@xml:lang=$teiEditor:lang]/text()
    let $teiElementCardinality := $elementNode/cardinality/text()
    let $attributeValueType := $elementNode/attributeValueType/text()

(:    let $teiDoc := $teiEditor:doc-collection/id($teiEditor:docId):)

    let $teiElementValue :=
        if($teiElementCardinality = "1" ) then (
         util:eval( "$teiEditor:doc-collection/id('"||$currentDocId ||"')/" || $teiXPath ))
         else if($teiElementCardinality = "x" ) then (
         util:eval( "$teiEditor:doc-collection/id('"|| $currentDocId ||"')/"
         || $xpathBaseForCardinalityX || "/" || $selectorForCardinalityX ))
         else(util:eval( "collection('" || $teiEditor:doc-collection-path ||"')/id('"|| $currentDocId ||"')/" || $teiXPath ))
    let $valuesTotal := count($teiElementValue)
    (:let $data2display :=
    if($teiElementCardinality = "1" ) then ( "e"||
        data(util:eval( "collection('" || $teiEditor:doc-collection-path ||"')//.[@rdf:about='" || $teiElementValue || "']//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang='en']"))
        ) else():)
    let $inputName := 'selectDropDown' (:||$topConceptId:)

    (:let $itemList :=
        util:eval( "collection('/db/apps/" || $teiEditor:project || "/data/documents')//id('"||$teiEditor:docId
                    ||"')/"
                    || functx:substring-before-last($teiXPath2Ref, '/') || "//tei:category"):)
    return

        (
        if($teiElementCardinality ="1") then

        (
                let $teiElementAttributeValue :=
                  (data(util:eval( "$teiEditor:doc-collection/id('" ||$teiEditor:docId ||"')/" || $teiXPath)))
             let $teiElementTextNodeValue :=
                     if($teiElementDataType = "textNodeAndAttribute" ) then
                    (data(util:eval( "$teiEditor:doc-collection/id('" ||$teiEditor:docId ||"')/" || substring-before($teiXPath, '/@'))))
(:                  ANCIENNE VERSION"là" || (serialize(functx:change-element-ns-deep(util:eval( "collection('" || $teiEditor:doc-collection-path || "')//id('" ||$teiEditor:docId ||"')/" || substring-before($teiXPath, '/@')), "", ""))):)
                   else
                  (serialize(functx:change-element-ns-deep(util:eval( "$teiEditor:doc-collection/id('" ||$teiEditor:docId ||"')/" || $teiXPath || "/node()"), "", "")))
             return

                 <div class="teiElementGroup">
                 <div id="{$teiElementNickname}_display_{$index}_1" class="">
                 <div class="TeiElementGroupHeaderInline">
                 <span class="labelForm">{$teiElementFormLabel} <span class="teiInfo">
                     <a title="TEI element: {$teiXPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                     </span></span>
                     </div>
                     { if($valuesTotal = 0) then <span>This document has no {$xpathEnd}</span>
                        else ()}
                     <div id="{$teiElementNickname}_value_{$index}_1" class="teiElementValue"  style="{if($type= "textarea") then "width: 100%;" else ()}">
                     {switch ($teiElementDataType)
                             case "text" return $teiElementTextNodeValue
                             case "attribute" return $teiElementAttributeValue
                             case "textNodeAndAttribute" return
                                 (<span>{$teiElementTextNodeValue}
                                 <a href="{$teiElementTextNodeValue}" target="_blank" class="urlInTeiElement">{$teiElementAttributeValue}</a></span>)
                             default return "Error; check type of field l466"
                     }</div>
                     <button id="edit{$teiElementNickname}_{$index}_1" class="btn btn-primary editbutton pull-right"
                      onclick="editValue('{$teiElementNickname}', '{$index}', '1')"
                             appearance="minimal" type="button"><i class="glyphicon glyphicon-edit
                                       editConceptIcon"></i></button>
                 </div>

                 <div id="{$teiElementNickname}_edit_{$index}_1" class="teiElementHidden form-group">
                 <div class="input-group" >
                 <span class="labelForm">{$teiElementFormLabel} <span class="teiInfo">
                     <a title="TEI element: {$teiXPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                     </span></span>

                         {switch ($type)
                          case "input" return
                             switch ($teiElementDataType)
                             case "text" return
                             <input id="{$teiElementNickname}_{$index}_1" class="form-control" name="{$teiElementNickname}_{$index}_1" value="{$teiElementAttributeValue}"></input>
                             case "textNodeAndAttribute" return
                             <div class="input-group">
                             <div class="input-group-prepend">
                                <span>Value of <em>Attribute</em> {functx:substring-after-last($teiXPath, '/')}</span>
                             </div>
                             <input id="{$teiElementNickname}_text_{$index}_1" class="form-control" name="{$teiElementNickname}_text_{$index}_1" value="{ $teiElementAttributeValue }"></input>
                             <span>Value of <em>Node Text</em></span><input id="{$teiElementNickname}_attrib_{$index}_1" class="form-control" name="{$teiElementNickname}_attrib_{$index}_1" value="{ $teiElementTextNodeValue }"></input>
                             </div>
                             default return "Error! Check data type - l. 515"

                          case "textarea" return
                          <textarea id="{$teiElementNickname}_{$index}_1" class="form-control summernote" name="{$teiElementNickname}_{$index}_1">{$teiElementTextNodeValue}</textarea>
                          default return null
                          }
                         <button id="{$teiElementNickname}SaveButton" class="btn btn-success"
                         onclick="saveData('{$teiEditor:docId}', '{$teiElementNickname}', '{$teiXPath}',
                             '{$teiElementDataType}', '{$index}', {$teiElementCardinality})"
                                 appearance="minimal" type="button"><i class="glyphicon
         glyphicon glyphicon-ok-circle"></i></button>
                         <button id="{$teiElementNickname}CancelEdit" class="btn btn-danger"
                         onclick="javascript:cancelEdit('{$teiElementNickname}', '{$index}', '{$teiElementTextNodeValue}', 'input', '1') "
                                 appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>

                 </div></div>
                 </div>
        )
        else
        <div id="{$teiElementNickname}_group_{$indexNo}" class="teiElementGroup">
        <div class="TeiElementGroupHeaderBlock">
            <span class="labelForm">{$teiElementFormLabel} <span class="teiInfo">
                    <a title="TEI element: {$teiXPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                    </span></span>
                    { if($teiElementCardinality ="x") then
                    <button id="{$teiElementNickname}addItem_{$indexNo}" class="btn btn-primary addItem"
                        onclick="addItem(this, '{ $inputName }_add_{ $indexNo }', '{ $indexNo }')"
                                appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-plus"></i></button>



                  else()
                     }
              </div>
              {
              for $item at $pos in $teiElementValue

                let $teiElementAttributeValue :=
                                                (util:eval( "collection('" || $teiEditor:doc-collection-path || "')//id('" ||$teiEditor:docId ||"')/"
                                                || substring-before($teiXPath, '/@') || "[" || $pos || "]/" || functx:substring-after-last($teiXPath, '/')  ))
                let $teiElementTextNodeValue := if($teiElementDataType = "textNodeAndAttribute") then
                                        (util:eval( "collection('" || $teiEditor:doc-collection-path || "')//id('" ||$teiEditor:docId ||"')/" || substring-before($teiXPath, '/@') || "[" || $pos || "]" ))
                                        else()

              return
              (
              <div class="teiElementGroup">
                    <div id="{$teiElementNickname}_display_{$index}_{$pos}" class="">
                    <div class="TeiElementGroupHeaderInline">
                    <span class="labelForm">{$teiElementFormLabel} <span class="teiInfo">
                        <a title="TEI element: {$teiXPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                        </span></span>
                        </div>
                        <div id="{$teiElementNickname}_value_{$index}_{$pos}" class="teiElementValue">{ $teiElementTextNodeValue } <a href="{$teiElementAttributeValue}" target="_blank" class="urlInTeiElement">{$teiElementAttributeValue}</a></div>
                        <button id="edit{$teiElementNickname}_{$index}_{$pos}" class="btn btn-primary editbutton pull-right"
                         onclick="editValue('{$teiElementNickname}', '{$index}', {$pos})"
                                appearance="minimal" type="button"><i class="glyphicon glyphicon-edit
                                          editConceptIcon"></i></button>
                    </div>

        <div id="{$teiElementNickname}_edit_{$index}_{$pos}" class="teiElementHidden form-group">
        <div class="input-group" >
        <span class="labelForm">{$teiElementFormLabel} <span class="teiInfo">
            <a title="TEI element: {$teiXPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
            </span></span>

                {switch ($type)
                 case "input" return
                    switch ($teiElementDataType)
                    case "text" return

                    <input id="{$teiElementNickname}_{$index}_{$pos}" class="form-control" name="{$teiElementNickname}_{$index}_{$pos}" value="{$teiElementAttributeValue}"></input>

                    case "textNodeAndAttribute" return

                            <div>
                            <div class="input-group">
                            <span class="input-group-prepend" id="{$teiElementNickname}_text_{$index}_{$pos}_addon">Text</span>

                            <input id="{$teiElementNickname}_text_{$index}_{$pos}" class="form-control" name="{$teiElementNickname}_text_{$index}_{$pos}" value="{ $teiElementTextNodeValue  }" aria-describedby="{$teiElementNickname}_text_{$index}_{$pos}_addon"></input>
                            </div>

                            <div class="input-group">
                            <span class="input-group-prepend" id="{$teiElementNickname}_attrib_{$index}_{$pos}_addon">{functx:substring-after-last($teiXPath, '/')}</span>
                                <input id="{$teiElementNickname}_attrib_{$index}_{$pos}" class="form-control" name="{$teiElementNickname}_attrib_{$index}_{$pos}" value="{ $teiElementAttributeValue }" aria-describedby="{$teiElementNickname}_attrib_{$index}_{$pos}_addon"></input>
                            </div>
                            </div>

                    default return "Error! Check data type  l. 603"

                 case "textarea" return
                 <textarea id="{$teiElementNickname}_{$index}_1" class="form-control" name="{$teiElementNickname}_{$index}_1">{$teiElementAttributeValue}</textarea>
                 default return null
                 }
                <button id="{$teiElementNickname}SaveButton" class="btn btn-success"
                onclick="saveData('{$teiEditor:docId}', '{$teiElementNickname}', '{$teiXPath}',
                    '{$teiElementDataType}', '{$index}', '{$pos}')"
                        appearance="minimal" type="button"><i class="glyphicon
glyphicon glyphicon-ok-circle"></i></button>
                <button id="{$teiElementNickname}CancelEdit" class="btn btn-danger"
                onclick="cancelEdit('{$teiElementNickname}', '{$index}', '{$teiElementValue}', 'input', '{$pos}') "
                        appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>

        </div></div>
        </div>
                      )}


                <div id="{$inputName}_add_{$indexNo}" class="teiElement teiElementAddItem teiElementHidden">

                    { switch ($teiElementDataType)
                    case "text" return
                    <input id="{$teiElementNickname}_text_{$index}_1" class="form-control" name="{$teiElementNickname}_{$index}_1" value=""></input>
                    case "textNodeAndAttribute" return
                    <div>
                    <div class="input-group">
                    <div class="input-group-prepend">
                          <span>Value of <em>Attribute</em>{ functx:substring-after-last($teiXPath, '/') }</span>
                          </div>
                          <input id="{$teiElementNickname}_add_attrib_{$index}_1" class="form-control" name="{$teiElementNickname}_text_{$index}_1" value=""></input>
                    </div>
                    <span>Value of <em>Node Text</em></span><input id="{$teiElementNickname}_add_text_{$index}_1" class="form-control" name="{$teiElementNickname}_add_text_{$index}_1" value=""></input>
                    </div>
                    default return "Error! Check data type - l. 638" }


                        <button id="addNewItem" class="btn btn-success" onclick="addData(this, '{$currentDocId}', '{$inputName}_add_{$indexNo}', '{$teiElementNickname}', '{$teiXPath}', '{$contentType}', '{$indexNo}', '')"
                                appearance="minimal" type="button"><i class="glyphicon glyphicon-ok-circle"></i></button>
                                <button id="{$teiElementNickname}CancelEdit_{$indexNo}_add" class="btn btn-danger"
                        onclick="cancelEdit('{$inputName}_add_{$indexNo}', '{$indexNo}', '{$teiElementValue}', 'thesau', {$valuesTotal +1}) "
                                appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>
                </div>
            </div>
        )
};

declare function teiEditor:displayTeiElementCardiMultiLang($teiElementNickname as xs:string,
                                                                                             $docId as xs:string?,
                                                                                             $index as xs:integer?,
                                                                                             $type as xs:string?,
                                                                                             $xpath_root as xs:string?) {


        let $currentDocId := if($docId != "") then $docId
                            else if ( $docId ="getFunctions.xql") then "eee"
                            else  $teiEditor:docId

        let $doc := $teiEditor:doc-collection/id($docId)    
    

        let $indexNo := if($index) then data($index) else "1"
        let $index := if($index) then data($index) else "1"
        let $elementNode := if (not(exists($teiEditor:teiElementsCustom//teiElement[nm=$teiElementNickname]))) then
                        $teiEditor:teiElements//teiElement[nm=$teiElementNickname]
                        else ($teiEditor:teiElementsCustom//teiElement[nm=$teiElementNickname])
        let $elementIndex := if($elementNode/ancestor::teiElement)
                    then ""
                    else if
                        ($index) then ("[" || string($index) || "]" ) else ("")

        let $xpathEnd := if(contains($elementNode//xpath[1]/text(), "/@"))
            then(functx:substring-before-last($elementNode//xpath/text(), '/') || $elementIndex || "/"
            || functx:substring-after-last($elementNode//xpath/text(), '/')
            )
            else (
            $elementNode//xpath[1]/text()
            )
       let $elementAncestors := $elementNode/ancestor::teiElement
       let $teiXPath :=
                if($xpath_root !="")
                    then
                        $xpath_root
                                else if($elementNode/ancestor::teiElement)
                                then
                                    (
                                    string-join(
                                    for $ancestor at $pos in $elementAncestors
                                        let $ancestorIndex := if($pos = 1 ) then
                                            if($index) then "[" || string($index) || "]" else ("")
                                                else ("")
                                        return
                                            if (contains($ancestor/xpath/text(), '/@'))
                                                then substring-before($ancestor/xpath/text(), '/@')
                                                        || $ancestorIndex
                                                else $ancestor/xpath/text() || $ancestorIndex)
                                        || $xpathEnd
                                        )
                                else
                                    $xpathEnd

     let $xpathBaseForCardinalityX :=
            if (contains($teiXPath, "/@")) then
            (functx:substring-before-last(functx:substring-before-last($teiXPath, "/@"), '/'))
            else
                ($teiXPath)

     let $selectorForCardinalityX :=
            if (contains($teiXPath, "/@")) then
            (functx:substring-after-last(functx:substring-before-last($teiXPath, "/@"), "/"))
            else
                (
                functx:substring-after-last($teiXPath, "/")
                )

    let $contentType :=$elementNode/contentType/text()
    let $teiElementDataType := $elementNode/contentType/text()
    let $teiElementFormLabel := $elementNode/formLabel[@xml:lang=$teiEditor:lang]/text()
    let $teiElementCardinality := $elementNode/cardinality/text()
    let $attributeValueType := $elementNode/attributeValueType/text()

(:    let $teiDoc := $teiEditor:doc-collection/id($teiEditor:docId):)

    let $teiElementValue :=
        if($teiElementCardinality = "1" )
            then (
                    util:eval( "$doc/" || $teiXPath ))

            else if($teiElementCardinality = "x" ) then (

                    util:eval( "$doc/" || $teiXPath )
                    (:util:eval( "$teiEditor:doc-collection/id('"|| $currentDocId ||"')"
                    || $xpathBaseForCardinalityX
                    || "/" || $selectorForCardinalityX
                    ):)
                    )
            else
                (<test>test</test>
(:         util:eval( "collection('" || $teiEditor:doc-collection-path ||"')/id('"|| $currentDocId ||"')/" || $teiXPath ):)
                )
(: let $unit :=    if(util:eval( "$teiEditor:doc-collection/id('"||$currentDocId ||"')/" || $teiXPath || "/@unit" ))
                                then (" " ||
                                    util:eval( "$teiEditor:doc-collection/id('"||$currentDocId ||"')/" || $teiXPath || "/@unit" ))
           else ()
:)
 let $unit :=    try {
                           " " || util:eval( "$doc/" || $teiXPath || "/@unit" )
                            }
                      catch * { "" }

let $valuesTotal := count($teiElementValue)
    (:let $data2display :=
    if($teiElementCardinality = "1" ) then ( "e"||
        data(util:eval( "collection('" || $teiEditor:doc-collection-path ||"')//.[@rdf:about='" || $teiElementValue || "']//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang='en']"))
        ) else():)
let $inputName := 'selectDropDown' (:||$topConceptId:)

    (:let $itemList :=
        util:eval( "collection('/db/apps/" || $teiEditor:project || "/data/documents')//id('"||$teiEditor:docId
                    ||"')/"
                    || functx:substring-before-last($teiXPath2Ref, '/') || "//tei:category"):)
    return

        (
        if($teiElementCardinality ="1") then
            (let $teiElementAttributeValue :=
                  (util:eval( "$doc/" || $teiXPath))

             let $teiElementTextNodeValue :=
                switch($teiElementDataType)
                    case "textNodeAndAttribute" return
                                    util:eval( "$doc/" || substring-before($teiXPath, '/@')) || $unit 
    (:                  ANCIENNE VERSION"là" || (serialize(functx:change-element-ns-deep(util:eval( "collection('" || $teiEditor:doc-collection-path || "')//id('" ||$teiEditor:docId ||"')/" || substring-before($teiXPath, '/@')), "", ""))):)
                    case "enrichedText" return
                    (:serialize( :)
                    functx:change-element-ns-deep(
                                    util:eval( "$doc/" || $teiXPath), "", "")/node()
(:                                    ) :)
                    default return 
                        serialize(
                            functx:change-element-ns-deep(
                                util:eval( "collection('" || $teiEditor:doc-collection-path || "')/id('" || $currentDocId ||"')/" || $teiXPath || "/node()")
                                , "", "")) 
                          
                    
             return

                 <div class="teiElementGroup">
                 <div id="{$teiElementNickname}_display_{$index}_1" class="">
                 <div class="{switch($teiElementDataType)
                                case 'enrichedText' return 'TeiElementGroupHeaderBlock'
                                default return 'TeiElementGroupHeaderInline'}">
                 <span class="labelForm">{$teiElementFormLabel} <span class="teiInfo">
                     <a title="TEI element: {$teiXPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                     </span></span>
                     </div>
                     <div id="{$teiElementNickname}_value_{$index}_1" class="teiElementValue"  style="{if($type= "textarea") then "width: 100%;" else ()}">
                     {switch ($teiElementDataType)
                             case "text" return <span>{$teiElementTextNodeValue}
                             {if(starts-with($teiElementTextNodeValue, "http")) then <a href="{$teiElementTextNodeValue}" target="_blank" class="urlInTeiElement"><i class="glyphicon glyphicon-new-window"/></a>else()}
                                </span>
                             case "attribute" return 
                                <span>{data($teiElementAttributeValue)}
                                {if(starts-with($teiElementAttributeValue, "http")) then <a href="{$teiElementTextNodeValue}" target="_blank" class="urlInTeiElement"><i class="glyphicon glyphicon-new-window"/></a>else()}
                                </span>
                             case "textNodeAndAttribute" return

                                 (<span>{$teiElementTextNodeValue}
                                 <a href="{$teiElementTextNodeValue}" target="_blank" class="urlInTeiElement">{$teiElementAttributeValue}</a></span>)
                             case "nodes" return $teiElementTextNodeValue
                             case "enrichedText" return 
                               (
                                   <div>
                                        <textarea id="{$teiElementNickname}_{$index}_1" class="form-control summernote" name="{$teiElementNickname}_{$index}_1">{
                                        $teiElementTextNodeValue
                                        }</textarea>
                                            <span id="{$teiElementNickname}_{$index}_1_message"/>
                                            <script>
                                                           // markupStr = '';
                                                         $('#{$teiElementNickname}_{$index}_1').summernote(
                                                               //'pasteHTML', markupStr,
                                                         {{
                                                         toolbar: [
                                                           ['style', ['style']],
                                                           ['font', ['italic','bold','underline','clear']],
                                                           //['para', ['ul','ol','paragraph']],
                                                           ['insert', ['link']],
                                                           ['view', ['fullscreen','codeview','help']],
                                                             ],
                                                       
                                                            callbacks: {{
                                                            onChange: function(){{
                                                              $("#{$teiElementNickname}_{$indexNo}_1_message").css("display", "block");
                                                                $("#{$teiElementNickname}_{$indexNo}_1_message").html("Text modified and not saved...");
                                                                $("#{$teiElementNickname}_{$indexNo}_1_message").css('background-color', '#ffaa99');
                                                              }},
                                                              onBlur: function(contents, $editable) {{
                                                                $("#{$teiElementNickname}_{$indexNo}_1_message").css("display", "block");
                                                                $("#{$teiElementNickname}_{$indexNo}_1_message").html("Saving text...");
                                                                $("#{$teiElementNickname}_{$indexNo}_1_message").css('background-color', '#e6f4ff');
                                                                saveTextarea('{$currentDocId}', '{$teiElementNickname}_{$index}_1', 
                                                                '{$teiElementNickname}', '{replace($teiXPath, "'", "&quot;")}', {$index})
                                                              }}
                                                            }}
                                                          }}
                                                       );
                                                       
                                               </script>
                                           </div>
                               )
                            case "enrichedTextTEI" return 
                             ( <div>
                                    <textarea id="{$teiElementNickname}_{$index}_1" class="form-control summernote" name="{$teiElementNickname}_{$index}_1">{
                                        $teiElementTextNodeValue
                                    }</textarea>
                                    <span id="{$teiElementNickname}_{$index}_1_message"/>
                                    <script type="text/javascript" src="$ausohnum-lib/resources/scripts/summerNoteTEI.js"/>

                                    <script>
                                            
                                                           // markupStr = '';
                                                         $('#{$teiElementNickname}_{$index}_1').summernote(
                                                               //'pasteHTML', markupStr,
                                                         {{
                                                         toolbar: [
                                                           ['style', ['style']],
                                                          
                                                           ['font', ['italicTEI','bold','underline','clear']],
                                                           //['para', ['ul','ol','paragraph']],
                                                           ['insert', ['link']],
                                                           ['view', ['fullscreen','codeview','help']],
                                                           ['teiButtons', ['note', 'clear']]
                                                             ],
                                                            
                                                            buttons: {{
                                                                    italicTEI: italicTEI,
                                                                    note:noteBottom
                                                                }},

                                                            callbacks: {{

                                                            onChange: function(){{
                                                              $("#{$teiElementNickname}_{$indexNo}_1_message").css("display", "block");
                                                                $("#{$teiElementNickname}_{$indexNo}_1_message").html("Text modified and not saved...");
                                                                $("#{$teiElementNickname}_{$indexNo}_1_message").css('background-color', '#ffaa99');
                                                              }},
                                                              onBlur: function(contents, $editable) {{
                                                                $("#{$teiElementNickname}_{$indexNo}_1_message").css("display", "block");
                                                                $("#{$teiElementNickname}_{$indexNo}_1_message").html("Saving text...");
                                                                $("#{$teiElementNickname}_{$indexNo}_1_message").css('background-color', '#e6f4ff');
                                                                saveTextarea('{$currentDocId}', '{$teiElementNickname}_{$index}_1', 
                                                                '{$teiElementNickname}', '{replace($teiXPath, "'", "&quot;")}', {$index})
                                                              }}
                                                            }}
                                                          }}
                                                       );
                                                       
                                        </script>
                                        <style>
                                               hi[rend='italic']{{font-style: italic}}
                                               note{{font-size: smaller;
                                                background-color: lightgrey;
                                                vertical-align: super;
                                                padding: 2px;}}
                                                note::before{{content: '[note ';
                                                vertical-align: super;
                                                font-size: smaller;
                                                }}
                                                note::after{{content: ']';
                                                vertical-align: super;
                                                font-size: small;
                                                }}

                                        </style>
                                    </div>
                                    )
                             default return "Error; check type of field l766"
                             
                     }
                     
                     </div>
                       {switch ($teiElementDataType)
                          case "enrichedText" case "enrichedTextTEI" return
                                <button id="saveTextareaButton{$index}" class="saveTextButton btn btn-primary" onclick="saveTextarea('{$currentDocId}', '{$teiElementNickname}_{$index}_1', 
                                '{$teiElementNickname}', '{replace($teiXPath, "'", "&quot;")}', {$index})" appearance="minimal" type="button"><i class="glyphicon glyphicon-floppy-save"></i></button>
                          default return 
                     <button id="edit{$teiElementNickname}_{$index}_1" class="btn btn-primary editbutton pull-right"
                      onclick="editValue('{$teiElementNickname}', '{$index}', '1')"
                             appearance="minimal" type="button"><i class="glyphicon glyphicon-edit
                                       editConceptIcon"></i></button>
                                       
                 }</div>

                 <div id="{$teiElementNickname}_edit_{$index}_1" class="teiElementHidden form-group">
                 <div class="input-group" >
                 <span class="labelForm">{$teiElementFormLabel} <span class="teiInfo">
                     <a title="TEI element: {$teiXPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                     </span></span>

                         {switch ($type)
                          case "input" return
                            (
                             switch ($teiElementDataType)
                             case "text" case "attribute"  return
                                    <input id="{$teiElementNickname}_{$index}_1" class="form-control" name="{$teiElementNickname}_{$index}_1" value="{$teiElementAttributeValue}"></input>
                             case "textNodeAndAttribute" return
                                 <div>
                                    <div class="input-group">
                                        <div class="input-group-addon">
                                        <em>Text</em>
                                        </div>
                                        <input id="{$teiElementNickname}_text_{$index}_1" class="form-control" name="{$teiElementNickname}_attrib_{$index}_1" value="{ $teiElementTextNodeValue }"></input>
                                    </div>
                                    <div class="input-group">
                                       <div class="input-group-addon">
                                            <span>{functx:substring-after-last($teiXPath, '/')}</span>
                                        </div><input id="{$teiElementNickname}_attrib_{$index}_1" class="form-control" name="{$teiElementNickname}_text_{$index}_1" value="{ $teiElementAttributeValue }"></input>
                                    </div>
                                </div>
                             default return "Error! Check data type l799"
                          )
                          case "textarea" return
                          <textarea id="{$teiElementNickname}_{$index}_1" class="form-control" name="{$teiElementNickname}_{$index}_1">{$teiElementTextNodeValue}</textarea>
                          default return null
                          }
                         <button id="{$teiElementNickname}SaveButton" class="btn btn-success"
                         onclick="saveData2(this, '{$currentDocId}', '{switch ($teiElementDataType)
                            case "text" return $teiElementNickname || "_" || $index || "_1"
                            case "textNodeAndAttribute" return $teiElementNickname || "_text_" || $index || "_1"
                            default return $teiElementNickname || "_" || $index || "_1"
                            }',
                         '{switch ($teiElementDataType)
                            case "text" return ""
                            case "textNodeAndAttribute" return $teiElementNickname || "_attrib_" || $index || "_1"
                            default return ""
                            }',
                            '{$teiElementNickname}', '{$teiXPath}',
                             '{$teiElementDataType}', '{$index}', {$teiElementCardinality})"
                                 appearance="minimal" type="button"><i class="glyphicon
         glyphicon glyphicon-ok-circle"></i></button>
                         <button id="{$teiElementNickname}CancelEdit" class="btn btn-danger"
                         onclick="javascript:cancelEdit('{$teiElementNickname}', '{$index}', '{$teiElementTextNodeValue}', 'input', '1') "
                                 appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>

                 </div></div>
                 </div>
        )
  else (:cardinality > 1:)

        <div id="{$teiElementNickname}_group_{$indexNo}" class="teiElementGroup">
        <div class="TeiElementGroupHeaderBlock">
            <span class="labelForm">{$teiElementFormLabel} <span class="teiInfo">
                    <a title="TEI element: {$teiXPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                    </span></span>
                    { if($teiElementCardinality ="x") then
                    <button id="{$teiElementNickname}addItem_{$indexNo}" class="btn btn-primary addItem"
                        onclick="addItem(this, '{ $inputName }_add_{ $indexNo }', '{ $indexNo }')"
                                appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-plus"></i></button>



                  else()
                     }
              </div>
              {
              for $item at $pos in $teiElementValue

                let $teiElementAttributeValue :=
                                                 if($teiElementDataType = "textNodeAndAttribute" ) then
                                                (util:eval( "$doc/"
                                                || substring-before($teiXPath, '/@') || "[" || $pos || "]/" || functx:substring-after-last($teiXPath, '/')  ))
                                                else()
                let $teiElementTextNodeValue :=
                                    if($teiElementDataType = "textNodeAndAttribute") then
                                        (util:eval( "$doc/" || substring-before($teiXPath, '/@') || "[" || $pos || "]" ))
                                        else($item/text())
                let $lang := if(exists($item/@xml:lang)) then
                    <span class="labelForm">{data($item/@xml:lang)}</span> else ("")

              return
              (
                <div class="teiElementGroup">
                    <div id="{$teiElementNickname}_display_{$index}_{$pos}">
                        <div id="{$teiElementNickname}_value_{$index}_{$pos}" class="teiElementValue">
                        {$lang}<span>{ if(starts-with($teiElementTextNodeValue, "http")) then 
                        <a href="{$teiElementTextNodeValue}" target="_blank" class="urlInTeiElement">{$teiElementTextNodeValue}</a>
                        else  $teiElementTextNodeValue } <a href="{$teiElementAttributeValue}" target="_blank" class="urlInTeiElement">{$teiElementAttributeValue}</a></span></div>
                        <button id="edit{$teiElementNickname}_{$index}_{$pos}" class="btn btn-primary editbutton pull-right"
                         onclick="editValue('{$teiElementNickname}', '{$index}', {$pos})"
                                appearance="minimal" type="button"><i class="glyphicon glyphicon-edit
                                          editConceptIcon"></i></button>
                           <button class="removeItem btn btn-warning pull-right"
                                          onclick="removeItemFromList('{$currentDocId}', '{$teiElementNickname}', 'xmlNode', {$pos}, '')"><i class="glyphicon glyphicon-trash" title="Remove reference from list"/></button>
                </div>

        <div id="{$teiElementNickname}_edit_{$index}_{$pos}" class="teiElementHidden form-group">
        <div class="input-group" >
            <!--
            <span class="labelForm">{$teiElementFormLabel} <span class="teiInfo">
            <a title="TEI element: {$teiXPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
            </span></span>
              -->
                {switch ($type)
                 case "input" return
                    switch ($teiElementDataType)
                    case "text" return
                    <div class="input-group">
                    {
                    if(exists($item/@xml:lang)) then
                    (

                     <div class="input-group-prepend">
                            <!--<span class="input-group-text">lang.</span>-->
                            <span class="labelForm">{$lang}</span>
                    </div>

                    )

                    else()
                    }
                    <input id="{$teiElementNickname}_{$index}_{$pos}" class="form-control" name="{$teiElementNickname}_{$index}_{$pos}" value="{$teiElementTextNodeValue}"></input>
                    </div>
                    case "textNodeAndAttribute" return

                            <div>
                            <div class="input-group">
                            <span class="input-group-addon" id="{$teiElementNickname}_text_{$index}_{$pos}_addon">Text</span>

                            <input id="{$teiElementNickname}_text_{$index}_{$pos}" class="form-control" name="{$teiElementNickname}_text_{$index}_{$pos}" value="{ $teiElementTextNodeValue  }" aria-describedby="{$teiElementNickname}_text_{$index}_{$pos}_addon"></input>
                            </div>

                            <div class="input-group">
                            <span class="input-group-addon" id="{$teiElementNickname}_attrib_{$index}_{$pos}_addon">{functx:substring-after-last($teiXPath, '/')}</span>
                                <input id="{$teiElementNickname}_attrib_{$index}_{$pos}" class="form-control" name="{$teiElementNickname}_attrib_{$index}_{$pos}" value="{ $teiElementAttributeValue }" aria-describedby="{$teiElementNickname}_attrib_{$index}_{$pos}_addon"></input>
                            </div>
                            </div>

                    default return "Error! Check data type - l. 955"

                 case "textarea" return
                 <textarea id="{$teiElementNickname}_{$index}_{$pos}" class="form-control" name="{$teiElementNickname}_{$index}_1">{$teiElementAttributeValue}</textarea>
                 default return null
                 }

<button id="{$teiElementNickname}SaveButton" class="btn btn-success"
                onclick="saveData2(this, '{$currentDocId}',
                '{switch ($teiElementDataType)
                            case "text" return $teiElementNickname || "_" || $index || "_" || $pos
                            case "textNodeAndAttribute" return $teiElementNickname || "_text_" || $index || "_" || $pos
                            default return $teiElementNickname || "_" || $index || "_" || $pos
                            }',
                         '{switch ($teiElementDataType)
                            case "text" return ""
                            case "textNodeAndAttribute" return $teiElementNickname || "_attrib_" || $index || "_" || $pos
                            default return ""
                            }',
                 '{$teiElementNickname}', '{replace($teiXPath, "'", "&quot;")}',
                    '{$teiElementDataType}', '{$index}', '{$pos}')"
                        appearance="minimal" type="button"><i class="glyphicon
glyphicon glyphicon-ok-circle"></i></button>
                <button id="{$teiElementNickname}CancelEdit" class="btn btn-danger"
                onclick="cancelEdit('{$teiElementNickname}', '{$index}', '{$teiElementValue}', 'input', '{$pos}') "
                        appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>

        </div></div>
        </div>
                      )}


                <div id="{$inputName}_add_{$indexNo}" class="teiElement teiElementAddItem teiElementHidden">

                                { switch ($teiElementDataType)
                                case "text" return

                                                <div class="input-group">
                                                 <div class="input-group-prepend">
                                                        <!--<span class="input-group-text">lang.</span>-->
                                                        <span class="input-group-text">
                                                        {teiEditor:projectLangDropDown('', $docId, $teiElementNickname, "add")}

                                                        </span>
                                                </div>


                                            <input id="{$teiElementNickname}_text_{$index}_1" class="form-control elementWithValue" name="{$teiElementNickname}_text_{$index}_1" value=""></input>
                                            </div>

                                case "textNodeAndAttribute" return
                                            <div>
                                            <span>Value of <em>Attribute</em> {functx:substring-after-last($teiXPath, '/')}</span><input id="{$teiElementNickname}_add_attrib_{$index}_1" class="form-control" name="{$teiElementNickname}_text_{$index}_1" value=""></input>
                                            <span>Value of <em>Node Text</em></span><input id="{$teiElementNickname}_add_text_{$index}_1" class="form-control" name="{$teiElementNickname}_add_text_{$index}_1" value=""></input>
                                            </div>
                                default return "Error! Check data type - l. 1010"
                                }


                        <button id="addNewItem" class="btn btn-success" onclick="addData(this, '{$currentDocId}', '{$inputName}_add_{$indexNo}',
                        '{$teiElementNickname}', '{$teiXPath}', '{$contentType}', '{$indexNo}', '')"
                                appearance="minimal" type="button"><i class="glyphicon glyphicon-ok-circle"></i></button>
                                <button id="{$teiElementNickname}CancelEdit_{$indexNo}_add" class="btn btn-danger"
                        onclick="cancelEdit('{$inputName}_add_{$indexNo}', '{$indexNo}', '{$teiElementValue}', 'thesau', {$valuesTotal +1}) "
                                appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>
                </div>
            </div>
        )
};
declare function teiEditor:displayTeiElementAndChildren($teiElementNickname as xs:string,
                                                        $docId as xs:string?,
                                                        $index as xs:int?,
                                                        $type as xs:string?,
                                                        $xpath_root as xs:string?) {
     
     let $elementNode := if (not(exists($teiEditor:teiElementsCustom//teiElement[nm=$teiElementNickname]))) then
                        $teiEditor:teiElements//teiElement[nm=$teiElementNickname]
                        else ($teiEditor:teiElementsCustom//teiElement[nm=$teiElementNickname])
    
    let $elementIndex := if($index ) then ("[" || string($index) || "]" ) else ("")
    let $xpathRaw := $elementNode/xpath/text()
    let $xpathEnd := if(contains($xpathRaw, "/@"))
            then( functx:substring-before-last($xpathRaw, '/') || $elementIndex || "/" || functx:substring-after-last($xpathRaw, '/'))
            else($xpathRaw)
    let $elementAncestors := $elementNode/ancestor::teiElement
    let $elementChildren := $elementNode//child::teiElement

    let $teiXPath := if($xpath_root)
                    then $xpath_root
                    
                    else
                        string-join(
                        for $ancestor in $elementAncestors
                        return
                        if (contains($ancestor/xpath/text(), '/@')) then
                            substring-before($ancestor/xpath/text(), '/@')
                            else $ancestor/xpath/text()
                        )
                    || $elementIndex || $xpathEnd
                    (:else
                        $xpathEnd
:)


    let $teiElementDataType := $elementNode/contentType/text()
    let $teiElementFormLabel := $elementNode/formLabel[@xml:lang=$teiEditor:lang]/text()
    let $teiDoc := $teiEditor:doc-collection/id($teiEditor:docId)
    let $teiElementValue :=
         (util:eval( "$teiEditor:doc-collection/id('" ||$teiEditor:docId ||"')/tei:TEI" || $teiXPath))
    
    (:let $unit :=       if(util:eval( "$teiEditor:doc-collection/id('"||$teiEditor:docId ||"')/" || $teiXPath || "/@unit" ))
                                then (" (" ||
                                    util:eval( "$teiEditor:doc-collection/id('"||$teiEditor:docId ||"')/" || $teiXPath || "/@unit" )
                                    || ")")
                        else ():)
    let $unit :=        try {
                    " (" || util:eval( "$teiEditor:doc-collection/id('"||$teiEditor:docId ||"')/" || $teiXPath || "/@unit" ) || ")"
                        }
                        catch * { " "}
    return
        <div id="{$teiElementNickname}_display_{$index}_1" class="teiElement">
        <span class="labelForm">{$teiElementFormLabel} {$unit}<span class="teiInfo">
            <a title="TEI element: {$teiXPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
            </span></span>

        {
        for $child at $pos in $elementChildren
        return
            if ($child/child::teiElement) then
                for $subchildren at $position in $child//teiElement
                     return
                           <div>{teiEditor:displayElement($subchildren/nm/text(), $teiEditor:docId, $position, $teiXPath)}</div>

                else
                    <div>{$child/nm/text()}; pos: { $pos }{teiEditor:displayElement($child/nm/text(), $teiEditor:docId, $pos, $teiXPath)}</div>

        }
      </div>

};


declare function teiEditor:displayGroup($teiElementNickname as xs:string,
                                                        $docId as xs:string?,
                                                        $index as xs:int?,
                                                        $type as xs:string?,
                                                        $xpath_root as xs:string?) {
     
     let $elementNode := if (not(exists($teiEditor:teiElementsCustom//teiElement[nm=$teiElementNickname]))) then
                        $teiEditor:teiElements//teiElement[nm=$teiElementNickname]
                        else ($teiEditor:teiElementsCustom//teiElement[nm=$teiElementNickname])
    let $teiElementFormLabel := $elementNode/formLabel[@xml:lang=$teiEditor:lang]/text()
    let $teiElementCardinality := $elementNode/cardinality/text()
    let $indexNo := if($index) then data($index) else "1"
    let $elementAncestors := $elementNode/ancestor::teiElement
    let $xpathRootWhenSubGroup :=
        if($elementNode/ancestor::teiElement)
            then (
                                    string-join(
                                                    for $ancestor at $pos in $elementAncestors
                                                        let $ancestorIndex := 
                                                                    if($pos = 1 ) 
                                                                            then if($index) 
                                                                                    then "[" || string($index) || "]" 
                                                                                    else ("")
                                                                             else ("")
                                                        return
                                                            if (contains($ancestor/xpath/text(), '/@'))
                                                                then substring-before($ancestor/xpath/text(), '/@')
                                                                        || $ancestorIndex
                                                                else $ancestor/xpath/text() || $ancestorIndex
                                                )
                                        
                                        )
           else ()
    let $xpathRoot := 
                (if($xpathRootWhenSubGroup != "") then $xpathRootWhenSubGroup || "/" 
                else ())
                || (if(ends-with($elementNode/xpath[1]/text(), '/self')) then
                                       substring-before($elementNode/xpath/text(), '/self')
                                       else $elementNode/xpath[1]/text())
                                       
                                       
    let $docId2Use := if($docId != "") then $docId else $teiEditor:docId  
    let $groupNodeBaseXPath := functx:substring-before-last($xpathRoot, "/")
    let $groupNodeXPath := functx:substring-after-last($xpathRoot, "/")
    (:let $groupNodes := util:eval( "collection('" || $teiEditor:doc-collection-path || "')//id('" ||$teiEditor:docId ||"')/" || $groupNodeBaseXPath
                                 || "/" || $groupNodeXPath):)
    let $groupNodes := util:eval( "$teiEditor:doc-collection/id('" || 
                $docId2Use ||"')/" || $xpathRoot)
    let $elementChildren := $elementNode//child::teiElement                             
    return 
    <div id="{ $teiElementNickname }_group_{ $index }" class="teiElementGroup">
        <div id="{ $teiElementNickname }_display_{$index}_1" class="panel">
           <h5>{ $teiElementFormLabel }{ if($teiElementCardinality ="x") then
                    <button id="{$teiElementNickname}addItem_{$indexNo}" class="btn btn-primary addItem pull-right"
                        onclick="addGroupItem(this, '{ $teiElementNickname }_add_{ $indexNo }', '{ $indexNo }')"
                                appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-plus"></i></button>
                     else()
         }</h5> 
    <ul class="list-group">
            
    {
                    for $group at $pos in $groupNodes
                        
                        return
                            <li class="list-group-item elementsByGroup">
                            <div class="TeiElementGroupHeaderBlock">
                <!--<span class="labelForm">{ $teiElementFormLabel } <span class="teiInfo">
                    <a title="TEI element: { $xpathRoot }"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                </span></span>
                -->
                <button class="removeItem btn btn-xs btn-warning pull-right"
                                          onclick="removeItemFromList('{$docId}', '{$teiElementNickname}', 'xmlNode', {$pos}, '')"><i class="glyphicon glyphicon-trash" title="Remove reference from list"/></button>
            </div>
            
            
            {
                                    for $elementChild in $elementChildren
                                        let $xpathEnd := $elementChild/xpath/text()
                                        
                                        return
                                        <div class="d-block">
                                           {teiEditor:displayElementWithDef($elementChild,
                                                $docId2Use,
                                                $pos,
                                                $xpathRoot || "[" || $pos || "]" || $xpathEnd )
                                            }</div>
                                        }
                           </li>
             }</ul>
        </div>
        <div id="{$teiElementNickname}_add_{$indexNo}" class="teiElement teiElementAddGroup teiElementAddGroupItem teiElementHidden">
        <div class="TeiElementGroupHeaderBlock">
                <span class="labelForm">New { $teiElementFormLabel } <span class="teiInfo">
                    <a title="TEI element: { $xpathRoot }"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                </span></span>
                </div>
            {
            
            for $elementChild at $pos in $elementChildren
                                        let $teiElementNickname := $elementChild/nm/text()
                                        let $xpathEnd := $elementChild/xpath/text()
                                        let $teiElementDataType := $elementChild/contentType/text()
                                        let $teiElementFieldType := $elementChild/fieldType/text()
                                        let $attributeValueType := $elementChild/attributeValueType/text()
                                        let $label :=$elementChild/formLabel[@xml:lang=$teiEditor:lang]/text()
                                        let $topConceptUri := functx:substring-after-last($elementChild/thesauTopConceptURI/text(), "/")
                                        return 
                                            switch ($teiElementFieldType)
                                                case "combobox"
                                                   return 
                                                    <div>
                                                        {skosThesau:dropDownThesauForElement($teiElementNickname, $topConceptUri, $teiEditor:lang, $label, 'inline', 
                                                            sum(9999, $pos), $pos, $attributeValueType)}
                                                    
                                                    </div>
                                                case "input"
                                                    return
                                                    <div>
                                                    <div class="input-group-prepend">
                                                      <span>{ $label }</span>
                                                      </div>
                                                        <input id="{$teiElementNickname}_add_{$index}_1" class="form-control elementWithValue" name="{$teiElementNickname}" value=""></input>
                                                        </div>
                                                
                                                case "textarea"
                                                    return
                                                     <div>
                                                    <div class="input-group-prepend">
                                                      <span>{ $label }</span>
                                                      </div>
                                                       <textarea id="{$teiElementNickname}_add_{$index}_1" class="form-control elementWithValue" name="{$teiElementNickname}"></textarea>
                                                   </div>
                                                case "textNodeAndAttribute" return
                                                <div/>
                                                
                                                default return "Error! Check data type (" || $teiElementDataType || ")- l. 1172"
                                    (:switch ($teiElementDataType)
                                                case "text"
                                                case "attribute"
                                                return
                                                <div>
                                                type{$teiElementFieldType}
                                                <input id="{$teiElementNickname}_text_{$index}_1" class="form-control" name="{$teiElementNickname}_{$index}_1" value=""></input>
                                                </div>
                                                case "textNodeAndAttribute" return
                                                <div>
                                                type{$teiElementFieldType}<div class="input-group">
                                                <div class="input-group-prepend">
                                                      <span>Value of <em>Attribute</em>{ functx:substring-after-last($xpathRoot, '/') }</span>
                                                      </div>
                                                      <input id="{$teiElementNickname}_add_attrib_  {$index}_1" class="form-control" name="{$teiElementNickname}_text_{$index}_1" value=""></input>
                                                </div>
                                                <span>Value of <em>Node Text</em></span><input id="{$teiElementNickname}_add_text_{$index}_1" class="form-control" name="{$teiElementNickname}_add_text_{$index}_1" value=""></input>
                                                </div>
                                                default return "Error! Check data type (" || $teiElementDataType || ")- l. 1172":)
                                                                
                                                                }
                                                                
                         <button id="{$teiElementNickname}addNewGroup" class="btn btn-success"
                        onclick=""
                                appearance="minimal" type="button"><i class="glyphicon glyphicon-ok-circle"></i></button>
                         <button id="{$teiElementNickname}CancelEdit_{$indexNo}_add" class="btn btn-danger"
                        onclick="cancelAddItem(this)"
                                appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>
                                    
                                    </div>
                                    <script>
                                    $({$teiElementNickname}addNewGroup).on("click", function(){{
                                      addGroupData(this, '{$docId}', '{$teiElementNickname}', '{$indexNo}')
                                    }});
                                    </script>
                                    </div>
};


declare function teiEditor:displayTeiElementWithTaxo($teiElementNickname as xs:string, $index as xs:int?, $xpath_root as xs:string?) {
        let $elementNode := $teiEditor:teiElements//teiElement[nm=$teiElementNickname]
        let $elementIndex := if($index) then ("[" || string($index) || "]" ) else ("")
        let $taxoId := if ($elementNode/taxoId/text()) then $elementNode/taxoId/text() else ()

        let $xpathEnd := if(contains($elementNode//xpath/text(), "/@"))
            then(functx:substring-before-last($elementNode//xpath/text(), '/') || $elementIndex || "/" || functx:substring-after-last($elementNode//xpath/text(), '/')) else(
            $elementNode//xpath/text())
        let $teiXPath := if($elementNode/ancestor::teiElement)
                    then $elementNode/ancestor::teiElement/xpath/text() || $xpathEnd
                    else
                        $xpathEnd

    let $teiXPath2Ref := $teiEditor:teiElements//teiElement[nm=$teiElementNickname]/xpath2ref/text()
    let $teiElementDataType := $teiEditor:teiElements//teiElement[nm=$teiElementNickname]/contentType/text()
    let $teiElementFormLabel := $teiEditor:teiElements//teiElement[nm=$teiElementNickname]/formLabel[@xml:lang=$teiEditor:lang]/text()

    let $teiDoc := $teiEditor:doc-collection/id($teiEditor:docId)

    let $teiElementValue :=
         util:eval( "collection('" || $teiEditor:doc-collection-path || "')//id('"||$teiEditor:docId ||"')/" || $teiXPath)
    let $data2display :=
            substring($teiElementValue, 2) ||
                util:eval( "$teiEditor:doc-collection/id('" ||$teiEditor:docId
                    ||"')/"
                    || $teiXPath2Ref || "[@xml:id='" || substring($teiElementValue, 2) || "']/string()")


    let $itemList :=
       util:eval( "collection('" || $teiEditor:doc-collection-path || "')//id('"||$teiEditor:docId
                    ||"')/"
                    || functx:substring-before-last($teiXPath2Ref, '/') || "//tei:category")
    return

        <div>
        <div id="{$teiElementNickname}_display_{$index}_1" class="teiElement">
        <span class="labelForm">{$teiElementFormLabel} <span class="teiInfo">
            <a title="TEI element: {$teiXPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
            </span></span>
            <div id="{$teiElementNickname}_value_{$index}_1" title="{normalize-space($data2display)} = concept {substring($teiElementValue, 2)}" class="teiElementValue">{$data2display}</div>

            <button id="edit{$teiElementNickname}{$index}_1" class="btn btn-primary editbutton pull-right"
             onclick="editValue('{$teiElementNickname}', '{$index}', '1')"
                    appearance="minimal" type="button"><i class="glyphicon glyphicon-edit editConceptIcon"></i></button>
        </div>
        <div id="{$teiElementNickname}_edit_{$index}_1" class="teiElement teiElementHidden">
        <span class="labelForm">{$teiElementFormLabel} <span class="teiInfo">
            <a title="TEI element: {$teiXPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
            </span></span>
                <select id="{$teiElementNickname}_{$index}_1" name="{$teiElementNickname}{$index}">
                    {for $items in $itemList
                    return
                        if ($items/@xml:id = $teiElementValue)
                        then (<option value="#{$items/@xml:id}" selected="selected">{$items/tei:catDesc/string()} </option>) else (
                        <option value="#{$items/@xml:id}">{$items/tei:catDesc/string()} </option>
                        )

                     }


                    </select>


                <button id="saveTitleStmt" class="btn btn-success"
                onclick="saveData('{$teiEditor:docId}', '{$teiElementNickname}', '{$teiXPath}', '{$teiElementDataType}', '{$index}', '1')"
                        appearance="minimal" type="button"><i class="glyphicon glyphicon-ok-circle"></i></button>
                        <button id="{$teiElementNickname}CancelEdit" class="btn btn-danger"
                onclick="javascript:cancelEdit('{$teiElementNickname}', '{$index}', '', 'taxo', '1') "
                        appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>
        </div>
        </div>
};

declare function teiEditor:displayTeiElementWithThesau($teiElementNickname as xs:string,
            $topConceptId as xs:string,
            $index as xs:int?,
            $xpath_root as xs:string?) {


         let $elementNode := $teiEditor:teiElements//teiElement[nm=$teiElementNickname]

        let $elementIndex := if($index) then ("[" || string($index) || "]" ) else ("")
        let $xpathEnd := if(contains($elementNode//xpath/text(), "/@"))
            then(functx:substring-before-last($elementNode//xpath/text(), '/') || $elementIndex || "/" || functx:substring-after-last($elementNode//xpath/text(), '/')) else(
            $elementNode//xpath/text())
        let $teiXPath := if($elementNode/ancestor::teiElement)
                    then $elementNode/ancestor::teiElement/xpath/text() || $xpathEnd
                    else
                        $xpathEnd

    let $contentType :=$elementNode/contentType/text()
    let $teiElementDataType := $elementNode/contentType/text()
    let $teiElementFormLabel := $elementNode/formLabel[@xml:lang=$teiEditor:lang]/text()
    let $teiElementCardinality := $elementNode/cardinality/text()

(:    let $teiDoc := $teiEditor:doc-collection/id($teiEditor:docId):)

    let $teiElementValue :=
         util:eval( "collection('" || $teiEditor:doc-collection-path || "')//id('"||$teiEditor:docId ||"')/" || $teiXPath )

    let $data2display :=
        if ($teiElementCardinality = "1" ) then
        util:eval( "collection('" || $teiEditor:doc-collection-path || "')//.[@rdf:about='" || $teiElementValue || "']//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang='en']")
        else()
    let $inputName := 'selectDropDown' ||$topConceptId

    (:let $itemList :=
        util:eval( "collection('/db/apps/" || $teiEditor:project || "/data/documents')//id('"||$teiEditor:docId
                    ||"')/"
                    || functx:substring-before-last($teiXPath2Ref, '/') || "//tei:category"):)
    return
        if ($teiElementCardinality = "1") then(
        <div>{$teiElementCardinality}
        <div id="{$inputName}-display{$index}" class="teiElement">
        <span class="labelForm">{$teiElementFormLabel} <span class="teiInfo">
            <a title="TEI element: {$teiXPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
            </span></span>

            <div id="{$teiElementNickname}-value{$index}" title="{normalize-space($data2display)} = concept {substring($teiElementValue, 2)}" class="teiElementValue">{string($data2display)}</div>

            <button id="edit{$teiElementNickname}{$index}" class="btn btn-primary editbutton pull-right"
             onclick="editValue('{$teiElementNickname}', '{$index}')"
                    appearance="minimal" type="button"><i class="glyphicon glyphicon-edit
                              editConceptIcon"></i></button>
        </div>
        <div id="{$teiElementNickname}-edit{$index}" class="teiElement teiElementHidden">
        <span class="labelForm">{$teiElementFormLabel} <span class="teiInfo">
            <a title="TEI element: {$teiXPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
            </span></span>
                {skosThesau:dropDownThesauForXMLElement($teiElementNickname, $topConceptId, 'en', 'noLabel', 'inline', $index, 1, ())}


                <button id="saveTitleStmt" class="btn btn-success"
                onclick="saveData('{$teiEditor:docId}', '{$teiElementNickname}', '{$teiXPath}', '{$contentType}', '{$index}')"
                        appearance="minimal" type="button"><i class="glyphicon glyphicon-ok-circle"></i></button>
                        <button id="{$teiElementNickname}CancelEdit" class="btn btn-danger"
                onclick="cancelEdit('{$teiElementNickname}', '{$index}', '{$teiElementValue}', 'thesau') "
                        appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>
        </div>
        </div>)
        else()

};

declare function teiEditor:displayTeiElementWithThesauCardi($teiElementNickname as xs:string,
             $topConceptId as xs:string,
             $docId as xs:string?,
             $index as xs:integer?,
             $xpath_root as xs:string?) {

        let $currentDocId := if($docId != "") then $docId else  $teiEditor:docId
      
        let $doc := $teiEditor:doc-collection/id($currentDocId)    
        
        let $indexNo := if(string($index) != "") then data($index) else "1"
(:        let $elementNode := $teiEditor:teiElements//teiElement[nm=$teiElementNickname]:)
        let $elementNode := if (exists($teiEditor:teiElementsCustom//teiElement[nm=$teiElementNickname])) then
                        $teiEditor:teiElementsCustom//teiElement[nm=$teiElementNickname]
                        else ($teiEditor:teiElements//teiElement[nm=$teiElementNickname])
        let $contentType :=$elementNode/contentType/text()
        let $teiElementDataType := $elementNode/contentType/text()
        let $teiElementFormLabel := $elementNode/formLabel[@xml:lang=$teiEditor:lang]/text()
        let $teiElementCardinality := $elementNode/cardinality/text()
        let $attributeValueType := $elementNode/attributeValueType/text()

        let $elementIndex := if($index) then ("[" || string($index) || "]" ) else ("")

        let $xpathEnd := if(contains($elementNode//xpath/text(), "/@"))
            then(functx:substring-before-last($elementNode//xpath/text(), '/') || $elementIndex || "/"
            || functx:substring-after-last($elementNode//xpath/text(), '/')
            )
            else (
            $elementNode/./xpath/text()
            )
        let $elementAncestors := $elementNode/ancestor::teiElement
        let $teiXPath := 
                    if($xpath_root != "") then $xpath_root
                else if($elementNode/ancestor::teiElement)
                    then
                        string-join(
                        for $ancestor in $elementAncestors
                        return
                        if (contains($ancestor/xpath/text(), '/@')) then
                            substring-before($ancestor/xpath/text(), '/@')
                            else $ancestor/xpath/text()
                        )
                    || $elementIndex || $xpathEnd
                    else
                        $xpathEnd
        let $xpathBaseForCardinalityX :=
               if (contains($teiXPath, "/@")) then
               (functx:substring-before-last(functx:substring-before-last($teiXPath, "/@"), '/'))
               else
                   ($teiXPath)
        let $xpathBaseForCardinalityOne :=
   (:                    Test on $contentType:)
                       if($contentType ="textNodeAndAttribute") then
                       (:(if 
                       (contains($teiXPath, "/@")) then:) 
                       substring-before($teiXPath, "/@"
                       ) else 
                        $teiXPath
        let $selectorForCardinalityX :=
               if (contains($teiXPath, "/@")) then
               (functx:substring-after-last(functx:substring-before-last($teiXPath, "/@"), "/"))
               else
                   (functx:substring-after-last($teiXPath, "/"))

    
(:    let $teiDoc := $teiEditor:doc-collection/id($teiEditor:docId):)

    let $teiElementValue :=
        if($teiElementCardinality = "1" ) then (
            util:eval( "$doc/" || 
            $xpathBaseForCardinalityOne ))
         
         else if($teiElementCardinality = "x" ) then (
                    util:eval( "$doc/" || $xpathBaseForCardinalityX || "//" || $selectorForCardinalityX ))
         else (util:eval( "$doc/" || $teiXPath ))
    let $valuesTotal := count($teiElementValue)
(:    let $data2display :=
                if(($teiElementCardinality = "1" ) 
                and (util:eval( "collection('" || $teiEditor:concept-collection-path ||"')//skos:Concept[@rdf:about='" || data($teiElementValue[1]) || "']//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang='en']"))
                ) then (
                     data(util:eval( "collection('" || $teiEditor:concept-collection-path ||"')//skos:Concept[@rdf:about='" || $teiElementValue || "']//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang='en']"))
                   ) else()
:)  
  let $data2display :=
                if($teiElementCardinality = "1"  ) 
                    then (
                        try{
                            util:eval( "$teiEditor:concept-collection//skos:Concept[@rdf:about='" || $teiElementValue || "']//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang='en']")
                            }
                            catch * {""}
                          )
                     else ()

  

let $inputName := 'selectDropDown' ||$topConceptId

    (:let $itemList :=
        util:eval( "collection('/db/apps/" || $teiEditor:project || "/data/documents')//id('"||$teiEditor:docId
                    ||"')/"
                    || functx:substring-before-last($teiXPath2Ref, '/') || "//tei:category"):)
    return

        (
        <div id="{$teiElementNickname}_group_{$indexNo}" class="teiElementGroup">
        <div class="TeiElementGroupHeaderBlock">
            <span class="labelForm">{$teiElementFormLabel} <span class="teiInfo">
                    <a title="TEI element: {$teiXPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                    </span></span>
                    { if($teiElementCardinality ="x") then
                    <button id="{$teiElementNickname}addItem_1_{$indexNo}" class="btn btn-primary addItem"
                        onclick="addItem(this, '{ $teiElementNickname }_add_{ $indexNo }', '{ $indexNo }')"
                                appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-plus"></i></button>

                  else()
                     }
              </div>
              <div class="itemList" id="{$teiElementNickname}List"> 
              {
              for $item at $pos in $teiElementValue
                    let $itemPathEnding := if(contains($teiXPath, '/@')) then "/@" || substring-after($teiXPath, '/@')
                                                  else ()
                                                  
                     let $value2Bedisplayed:= 
                        if (not(contains($contentType, 'text'))) 
                            then (
                                            if (not($attributeValueType) or $attributeValueType="uri") then
                                                     util:eval( "$teiEditor:concept-collection//skos:Concept[@rdf:about='" || $item || $itemPathEnding || "/string()" 
                                                     || "']//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang='en']/text()")
                                           else 
                                            (skosThesau:getLabelFromXmlValue($item, $teiEditor:lang))
                                    
                                    )
                           else if (($contentType ="text") and ($attributeValueType="xml-value") and (not($item[.='']))) then
                       data(util:eval( "$teiEditor:concept-collection//skos:Concept[skos:prefLabel[@xml:lang='xml']='" || $item/string() || "']//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang='en']/text()"))
                        else if (contains($contentType, "textNodeAndAttribute")) then  $item/text()

                        else(
                               $contentType || " " || (if ($attributeValueType) then $attributeValueType
                                                                else ($item/string())       
                                                                )           
                                )
                    return
              (
              <div class="itemInDisplayElement">
                      <div id="{$teiElementNickname}_display_{$indexNo}_{$pos}" class="teiElement">
                      <!--<span class="labelForm">{$teiElementFormLabel} <span class="teiInfo">
                          <a title="TEI element: {$teiXPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                          </span></span>
                          -->
                          <div id="{$teiElementNickname}_value_{$indexNo}_{$pos}"
                          title="{normalize-space(string-join($item/string(), ""))} = concept {$item/@ref/string()}" class="teiElementValue">{ $value2Bedisplayed }</div>
                          <button id="edit{$teiElementNickname}_{$indexNo}_{$pos}" class="btn btn-primary editbutton pull-right"
                           onclick="editValue('{$teiElementNickname}', '{$indexNo}', '{$pos}')"
                                  appearance="minimal" type="button"><i class="glyphicon glyphicon-edit
                                            editConceptIcon"></i></button>

{if($teiElementCardinality ="x") then
<a class="removeItem" onclick="removeItemFromList('{$currentDocId}', '{$teiElementNickname}', '{functx:substring-before-last($xpathEnd, '/@')}', {$pos}, '{$topConceptId}')"><i class="glyphicon glyphicon-trash" title="Remove reference from list"/></a>
else()}
                      </div>
                      <div id="{$teiElementNickname}_edit_{$indexNo}_{$pos}" class="teiElement teiElementHidden">

                      <!--
                      <span class="labelForm">{$teiElementFormLabel} <span class="teiInfo">
                          <a title="TEI element: {$teiXPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                          </span></span>
                          -->
                             {skosThesau:dropDownThesauForXMLElement($teiElementNickname, $topConceptId, $teiEditor:lang, 'noLabel', 'inline', $index, $pos, $attributeValueType)}


                              <button class="btn btn-success"
                              onclick="saveData2(this, '{$currentDocId}',
                                            '{$teiElementNickname}_{$indexNo}_{$pos}',
                                            '',
                                            '{$teiElementNickname}',
                                            '{$teiXPath}', '{$contentType}', '{$indexNo}', '{$pos}')"
                                      appearance="minimal" type="button"><i class="glyphicon glyphicon-ok-circle"></i></button>
                                      <button id="{$teiElementNickname}CancelEdit_{$indexNo}_{$pos}" class="btn btn-danger"
                              onclick="cancelEdit('{$teiElementNickname}', '{$indexNo}', '{functx:trim(string-join($teiElementValue))}', 'thesau', '{$pos}') "
                                      appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>
                      </div>

                      </div>

                      )}
                      </div>


                <div id="{$teiElementNickname}_add_{$indexNo}" class="teiElement teiElementAddItem teiElementHidden">

                        {skosThesau:dropDownThesauForXMLElement($teiElementNickname, $topConceptId, 'en', 'noLabel', 'inline', $index + 1, (), ())}


                        <button id="{$teiElementNickname}addNewItem" class="btn btn-success"
                        onclick="addData(this, '{$currentDocId}', '{$teiElementNickname}_add_{$indexNo}', '{$teiElementNickname}', '{$teiXPath}', '{$contentType}', '{$indexNo}', '{ $topConceptId }')"
                                appearance="minimal" type="button"><i class="glyphicon glyphicon-ok-circle"></i></button>
                                <button id="{$teiElementNickname}CancelEdit_{$indexNo}_add" class="btn btn-danger"
                        onclick="cancelAddItem(this)"
                                appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>
                </div>



        </div>
        )
};

declare function teiEditor:displayTeiElementWithThesauComboInputCardi($teiElementNickname as xs:string,
             $topConceptUri as xs:string,
             $docId as xs:string?,
             $index as xs:integer?,
             $xpath_root as xs:string?) {
        let $topConceptId := functx:substring-after-last($topConceptUri, '/')
        let $currentDocId := if($docId != "") then $docId else  $teiEditor:docId
        let $doc := $teiEditor:doc-collection/id($currentDocId)
        let $indexNo := if(string($index) != "") then data($index) else "1"
(:        let $elementNode := $teiEditor:teiElements//teiElement[nm=$teiElementNickname]:)
        let $elementNode := if (exists($teiEditor:teiElementsCustom//teiElement[nm=$teiElementNickname])) then
                        $teiEditor:teiElementsCustom//teiElement[nm=$teiElementNickname]
                        else ($teiEditor:teiElements//teiElement[nm=$teiElementNickname])
        let $contentType :=$elementNode/contentType/text()
        let $teiElementDataType := $elementNode/contentType/text()
        let $teiElementFormLabel := $elementNode/formLabel[@xml:lang=$teiEditor:lang]/text()
        let $teiElementCardinality := $elementNode/cardinality/text()
        let $attributeValueType := $elementNode/attributeValueType/text()

        let $elementIndex := if($index) then ("[" || string($index) || "]" ) else ("")

        let $xpathEnd := if(contains($elementNode//xpath/text(), "/@"))
            then(functx:substring-before-last($elementNode//xpath/text(), '/') || $elementIndex || "/"
            || functx:substring-after-last($elementNode//xpath/text(), '/')
            )
            else (
            $elementNode/./xpath/text()
            )
        let $elementAncestors := $elementNode/ancestor::teiElement
        let $teiXPath := if($elementNode/ancestor::teiElement)
                    then
                        string-join(
                        for $ancestor in $elementAncestors
                        return
                        if (contains($ancestor/xpath/text(), '/@')) then
                            substring-before($ancestor/xpath/text(), '/@')
                            else $ancestor/xpath/text()
                        )
                    || $elementIndex || $xpathEnd
                    else
                        $xpathEnd
        let $xpathBaseForCardinalityX :=
               if (contains($teiXPath, "/@")) then
               (functx:substring-before-last(functx:substring-before-last($teiXPath, "/@"), '/'))
               else
                   ($teiXPath)
        let $xpathBaseForCardinalityOne :=
   (:                    Test on $contentType:)
                       if($contentType ="textNodeAndAttribute") then
                       (:(if 
                       (contains($teiXPath, "/@")) then:) 
                       substring-before($teiXPath, "/@"
                       ) else 
                        $teiXPath
        let $selectorForCardinalityX :=
               if (contains($teiXPath, "/@")) then
               (functx:substring-after-last(functx:substring-before-last($teiXPath, "/@"), "/"))
               else
                   (functx:substring-after-last($teiXPath, "/"))

    
(:    let $teiDoc := $teiEditor:doc-collection/id($teiEditor:docId):)

    let $teiElementValue :=
        if($teiElementCardinality = "1" ) then (
            util:eval( "$doc/" || 
            $xpathBaseForCardinalityOne ))
         
         else if($teiElementCardinality = "x" ) then (
                    util:eval( "$doc/" || $xpathBaseForCardinalityX || "//" || $selectorForCardinalityX ))
         else (util:eval( "$doc/" || $teiXPath ))
    let $valuesTotal := count($teiElementValue)
    let $data2display :=
                if(($teiElementCardinality = "1" ) 
                and (util:eval( "$teiEditor:concept-collection//skos:Concept[@rdf:about='" || data($teiElementValue[1]) || "']//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang='en']"))) then (
                     data(util:eval( "$teiEditor:concept-collection//skos:Concept[@rdf:about='" || $teiElementValue || "']//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang='en']"))
                   ) else()
    let $inputName := 'selectDropDown' ||$topConceptId

    (:let $itemList :=
        util:eval( "collection('/db/apps/" || $teiEditor:project || "/data/documents')//id('"||$teiEditor:docId
                    ||"')/"
                    || functx:substring-before-last($teiXPath2Ref, '/') || "//tei:category"):)
    return

        (
        <div id="{$teiElementNickname}_group_{$indexNo}" class="teiElementGroup">
        <div class="TeiElementGroupHeaderBlock">
            <span class="labelForm">{$teiElementFormLabel} <span class="teiInfo">
                    <a title="TEI element: {$teiXPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                    </span></span>
                    { if($teiElementCardinality ="x") then
                    <button id="{$teiElementNickname}addItem_1_{$indexNo}" class="btn btn-primary addItem"
                        onclick="addItem(this, '{ $teiElementNickname }_add_{ $indexNo }', '{ $indexNo }')"
                                appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-plus"></i></button>

                  else()
                     }
              </div>
              <div class="itemList" id="{$teiElementNickname}List"> 
              {
              for $item at $pos in $teiElementValue
              let $itemPathEnding := if(contains($teiXPath, '/@')) then "/@" || substring-after($teiXPath, '/@')
                                                  else ()
                                                  
              let $value2Bedisplayed:= 
                        if (not(contains($contentType, 'text'))) 
                            then (
                                            if (not($attributeValueType) or $attributeValueType="uri") then
                                                     data(util:eval( "$teiEditor:concept-collection//skos:Concept[@rdf:about='" || $item || $itemPathEnding || "/string()" 
                                                     || "']//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang='en']/text()"))
                                           else 
                                            (skosThesau:getLabelFromXmlValue($item, $teiEditor:lang))
                                    
                                    )
                        else if (($contentType ="text") and ($attributeValueType="xml-value") and (not($item[.='']))) then
                       data(util:eval( "$teiEditor:concept-collection//skos:Concept[skos:prefLabel[@xml:lang='xml']='" || $item/string() || "']//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang='en']/text()"))
                        else if (contains($contentType, "textNodeAndAttribute")) then  $item/text()

                        else(
                               $contentType || " " || (if ($attributeValueType) then $attributeValueType
                                                                else ($item/string())       
                                                                )           
                                )
              return
              (
              <div class="itemInDisplayElement">
                      <div id="{$teiElementNickname}_display_{$indexNo}_{$pos}" class="teiElement">
                      <!--<span class="labelForm">{$teiElementFormLabel} <span class="teiInfo">
                          <a title="TEI element: {$teiXPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                          </span></span>
                          -->
                          <div id="{$teiElementNickname}_value_{$indexNo}_{$pos}"
                          title="{normalize-space(($item[1]/text()))} = concept {$item/@ref/string()}" class="teiElementValue">{ $value2Bedisplayed }</div>
                          <!--
                          <button id="edit{$teiElementNickname}_{$indexNo}_{$pos}" class="btn btn-primary editbutton pull-right"
                           onclick="editValue('{$teiElementNickname}', '{$indexNo}', '{$pos}')"
                                  appearance="minimal" type="button"><i class="glyphicon glyphicon-edit
                                            editConceptIcon"></i></button>
                            -->

<a class="removeItem" onclick="removeItemFromList('{$currentDocId}', '{$teiElementNickname}', '{functx:substring-before-last($xpathEnd, '/@')}', {$pos}, '{$topConceptId}')"><i class="glyphicon glyphicon-trash" title="Remove reference from list"/></a>

                      </div>
                      <div id="{$teiElementNickname}_edit_{$indexNo}_{$pos}" class="teiElement teiElementHidden">

                      <!--
                      <span class="labelForm">{$teiElementFormLabel} <span class="teiInfo">
                          <a title="TEI element: {$teiXPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                          </span></span>
                          -->
                             Current value: { $value2Bedisplayed }<br/>
                             {""
(:                             skosThesau:dropDownThesauForElement($teiElementNickname, $topConceptId, $teiEditor:lang, 'noLabel', 'inline', $index, $pos, $attributeValueType):)
                             }
                             
                             { skosThesau:conceptLookup($topConceptUri, "... or search", string($pos))}

                              <button class="btn btn-success"
                              onclick="saveNewKeyword('{$currentDocId}',
                                            '{$teiElementNickname}_{$indexNo}_{$pos}',
                                            '',
                                            '{$teiElementNickname}',
                                            '{$teiXPath}', '{$contentType}', '{$indexNo}', '{$pos}')"
                                      appearance="minimal" type="button"><i class="glyphicon glyphicon-ok-circle"></i></button>
                                      <button id="{$teiElementNickname}CancelEdit_{$indexNo}_{$pos}" class="btn btn-danger"
                              onclick="cancelEdit('{$teiElementNickname}', '{$indexNo}', '{functx:trim($teiElementValue[1]/text())}', 'thesau', '{$pos}') "
                                      appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>
                      </div>

                      </div>

                      )}
                      </div>


                <div id="{$teiElementNickname}_add_{$indexNo}" class="teiElement teiElementAddItem teiElementHidden">
                        Add a new value:<br/>
                        {skosThesau:dropDownThesauForXMLElement($teiElementNickname, 
                        $topConceptId, 'en', 'noLabel', 'inline', $index + 1, (), 'uri')}
                        
                        { skosThesau:conceptLookup($topConceptUri, "or search...", "add" ||$indexNo)}

                        <button id="{$teiElementNickname}addNewItem" class="btn btn-success"
                        onclick="addDataComboAndInput(this, '{$currentDocId}', '{$teiElementNickname}_add_{$indexNo}', '{$teiElementNickname}', '{$teiXPath}', '{$contentType}', '{$indexNo}', '{ $topConceptId }')"
                                appearance="minimal" type="button"><i class="glyphicon glyphicon-ok-circle"></i></button>
                                <button id="{$teiElementNickname}CancelEdit_{$indexNo}_add" class="btn btn-danger"
                        onclick="cancelAddItem(this)"
                                appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>
                </div>



        </div>
        )
};

declare function teiEditor:displayTeiElementWithThesauInputCardi($teiElementNickname as xs:string,
             $topConceptUri as xs:string,
             $docId as xs:string?,
             $index as xs:integer?,
             $xpath_root as xs:string?) {
        let $topConceptId := functx:substring-after-last($topConceptUri, '/')
        let $currentDocId := if($docId != "") then $docId else  $teiEditor:docId
        let $indexNo := if(string($index) != "") then data($index) else "1"
(:        let $elementNode := $teiEditor:teiElements//teiElement[nm=$teiElementNickname]:)
        let $elementNode := if (exists($teiEditor:teiElementsCustom//teiElement[nm=$teiElementNickname])) then
                        $teiEditor:teiElementsCustom//teiElement[nm=$teiElementNickname]
                        else ($teiEditor:teiElements//teiElement[nm=$teiElementNickname])
        let $contentType :=$elementNode/contentType/text()
        let $teiElementDataType := $elementNode/contentType/text()
        let $teiElementFormLabel := $elementNode/formLabel[@xml:lang=$teiEditor:lang]/text()
        let $teiElementCardinality := $elementNode/cardinality/text()
        let $attributeValueType := $elementNode/attributeValueType/text()

        let $elementIndex := if($index) then ("[" || string($index) || "]" ) else ("")

        let $xpathEnd := if(contains($elementNode//xpath/text(), "/@"))
            then(functx:substring-before-last($elementNode//xpath/text(), '/') || $elementIndex || "/"
            || functx:substring-after-last($elementNode//xpath/text(), '/')
            )
            else (
            $elementNode/./xpath/text()
            )
        let $elementAncestors := $elementNode/ancestor::teiElement
        let $teiXPath := if($elementNode/ancestor::teiElement)
                    then
                        string-join(
                        for $ancestor in $elementAncestors
                        return
                        if (contains($ancestor/xpath/text(), '/@')) then
                            substring-before($ancestor/xpath/text(), '/@')
                            else $ancestor/xpath/text()
                        )
                    || $elementIndex || $xpathEnd
                    else
                        $xpathEnd
        let $xpathBaseForCardinalityX :=
               if (contains($teiXPath, "/@")) then
               (functx:substring-before-last(functx:substring-before-last($teiXPath, "/@"), '/'))
               else
                   ($teiXPath)
        let $xpathBaseForCardinalityOne :=
   (:                    Test on $contentType:)
                       if($contentType ="textNodeAndAttribute") then
                       (:(if 
                       (contains($teiXPath, "/@")) then:) 
                       substring-before($teiXPath, "/@"
                       ) else 
                        $teiXPath
        let $selectorForCardinalityX :=
               if (contains($teiXPath, "/@")) then
               (functx:substring-after-last(functx:substring-before-last($teiXPath, "/@"), "/"))
               else
                   (functx:substring-after-last($teiXPath, "/"))

    
(:    let $teiDoc := $teiEditor:doc-collection/id($teiEditor:docId):)

    let $teiElementValue :=
        if($teiElementCardinality = "1" ) then (
            util:eval( "$teiEditor:doc-collection/id('"||$currentDocId ||"')/" || 
            $xpathBaseForCardinalityOne ))
         
         else if($teiElementCardinality = "x" ) then (
                    util:eval( "$teiEditor:doc-collection/id('"|| $currentDocId ||"')/" || $xpathBaseForCardinalityX || "//" || $selectorForCardinalityX ))
         else (util:eval( "collection('" || $teiEditor:doc-collection-path ||"')/id('"|| $currentDocId ||"')/" || $teiXPath ))
    let $valuesTotal := count($teiElementValue)
    let $data2display :=
                if(($teiElementCardinality = "1" ) 
                and (util:eval( "collection('" || $teiEditor:concept-collection-path ||"')//skos:Concept[@rdf:about='" || data($teiElementValue[1]) || "']//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang='en']"))) then (
                     data(util:eval( "collection('" || $teiEditor:concept-collection-path ||"')//skos:Concept[@rdf:about='" || $teiElementValue || "']//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang='en']"))
                   ) else()
    let $inputName := 'selectDropDown' ||$topConceptId

    (:let $itemList :=
        util:eval( "collection('/db/apps/" || $teiEditor:project || "/data/documents')//id('"||$teiEditor:docId
                    ||"')/"
                    || functx:substring-before-last($teiXPath2Ref, '/') || "//tei:category"):)
    return

        (
        <div id="{$teiElementNickname}_group_{$indexNo}" class="teiElementGroup">
        <div class="TeiElementGroupHeaderBlock">
            <span class="labelForm">{$teiElementFormLabel} <span class="teiInfo">
                    <a title="TEI element: {$teiXPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                    </span></span>
                    { if($teiElementCardinality ="x") then
                    <button id="{$teiElementNickname}addItem_1_{$indexNo}" class="btn btn-primary addItem"
                        onclick="addItem(this, '{ $teiElementNickname }_add_{ $indexNo }', '{ $indexNo }')"
                                appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-plus"></i></button>

                  else()
                     }
              </div>
              <div class="itemList" id="{$teiElementNickname}List"> 
              {
              for $item at $pos in $teiElementValue
              let $itemPathEnding := if(contains($teiXPath, '/@')) then "/@" || substring-after($teiXPath, '/@')
                                                  else ()
                                                  
              let $value2Bedisplayed:= 
                        if (not(contains($contentType, 'text'))) 
                            then (
                                            if (not($attributeValueType) or $attributeValueType="uri") then
                                                     data(util:eval( "collection('" || $teiEditor:concept-collection-path 
                                                     ||"')//skos:Concept[@rdf:about='" || $item || $itemPathEnding || "/string()" 
                                                     || "']//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang='en']/text()"))
                                           else 
                                            (skosThesau:getLabelFromXmlValue($item, $teiEditor:lang))
                                    
                                    )
                        else if (($contentType ="text") and ($attributeValueType="xml-value") and (not($item[.='']))) then
                       data(util:eval( "collection('" || $teiEditor:concept-collection-path ||"')//skos:Concept[skos:prefLabel[@xml:lang='xml']='" || $item/string() || "']//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang='en']/text()"))
                        else if (contains($contentType, "textNodeAndAttribute")) then  $item/text()

                        else(
                               $contentType || " " || (if ($attributeValueType) then $attributeValueType
                                                                else ($item/string())       
                                                                )           
                                )
              return
              (
              <div class="itemInDisplayElement">
                      <div id="{$teiElementNickname}_display_{$indexNo}_{$pos}" class="teiElement">
                      <!--<span class="labelForm">{$teiElementFormLabel} <span class="teiInfo">
                          <a title="TEI element: {$teiXPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                          </span></span>
                          -->
                          <div id="{$teiElementNickname}_value_{$indexNo}_{$pos}"
                          title="{normalize-space(($item[1]/text()))} = concept {$item/@ref/string()}" class="teiElementValue">{ $value2Bedisplayed }</div>
                          <button id="edit{$teiElementNickname}_{$indexNo}_{$pos}" class="btn btn-primary editbutton pull-right"
                           onclick="editValue('{$teiElementNickname}', '{$indexNo}', '{$pos}')"
                                  appearance="minimal" type="button"><i class="glyphicon glyphicon-edit
                                            editConceptIcon"></i></button>


<a class="removeItem" onclick="removeItemFromList('{$currentDocId}', '{$teiElementNickname}', '{functx:substring-before-last($xpathEnd, '/@')}', {$pos}, '{$topConceptId}')"><i class="glyphicon glyphicon-trash" title="Remove reference from list"/></a>

                      </div>
                      <div id="{$teiElementNickname}_edit_{$indexNo}_{$pos}" class="teiElement teiElementHidden">

                      <!--
                      <span class="labelForm">{$teiElementFormLabel} <span class="teiInfo">
                          <a title="TEI element: {$teiXPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                          </span></span>
                          -->
                             Current value: { $value2Bedisplayed }<br/>
                             
                             { skosThesau:conceptLookup($topConceptUri, "... or search", string($pos))}

                              <button class="btn btn-success"
                              onclick="saveNewKeyword('{$currentDocId}',
                                            '{$teiElementNickname}_{$indexNo}_{$pos}',
                                            '',
                                            '{$teiElementNickname}',
                                            '{$teiXPath}', '{$contentType}', '{$indexNo}', '{$pos}')"
                                      appearance="minimal" type="button"><i class="glyphicon glyphicon-ok-circle"></i></button>
                                      <button id="{$teiElementNickname}CancelEdit_{$indexNo}_{$pos}" class="btn btn-danger"
                              onclick="cancelEdit('{$teiElementNickname}', '{$indexNo}', '{functx:trim($teiElementValue[1]/text())}', 'thesau', '{$pos}') "
                                      appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>
                      </div>

                      </div>

                      )}
                      </div>


                <div id="{$teiElementNickname}_add_{$indexNo}" class="teiElement teiElementAddItem teiElementHidden">
                        Add a new value:<br/>
                        
                        
                        { skosThesau:conceptLookup($topConceptUri, "or search...", "add" ||$indexNo)}

                        <button id="{$teiElementNickname}addNewItem" class="btn btn-success"
                        onclick="addDataComboAndInput(this, '{$currentDocId}', '{$teiElementNickname}_add_{$indexNo}', '{$teiElementNickname}', '{$teiXPath}', '{$contentType}', '{$indexNo}', '{ $topConceptId }')"
                                appearance="minimal" type="button"><i class="glyphicon glyphicon-ok-circle"></i></button>
                                <button id="{$teiElementNickname}CancelEdit_{$indexNo}_add" class="btn btn-danger"
                        onclick="cancelAddItem(this)"
                                appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>
                </div>



        </div>
        )
};


declare function teiEditor:displayPlace($elementNickName as xs:string, $docId as xs:string?, $index as xs:int?, $teiXPath){

    let $elementNode := $teiEditor:teiElements//teiElement[nm=$elementNickName]
     let $elementFormLabel := $elementNode/formLabel[@xml:lang=$teiEditor:lang]/text()
    let $currentDocId := if($docId != "") then $docId else $teiEditor:docId
    let $placeRef :=
         (data(
            util:eval( "$teiEditor:doc-collection/id('" ||$currentDocId ||"')/" || $teiXPath)))
    let $numberOfPlaceRef := count(tokenize($placeRef, ' '))
    let $placeProjectUri := for $uri in tokenize($placeRef, ' ')
                                    where contains($uri,  $teiEditor:baseUri)
                                return functx:trim($uri)
    let $placeRecord := 
    util:eval( "collection('" || $teiEditor:data-repository-path || "/places')//pleiades:Place[@rdf:about ='" || $placeProjectUri || "']")
(:    $teiEditor:placeRepo//pleiades:Place[@rdf:about = $placeProjectUri]:)
    let $placePrefLabel := $placeRecord//skos:prefLabel[@xml:lang="en"]/text()
    let $placeRefsAsLink := <ul class="list-inline">
                                            {for $uri in tokenize($placeRef, ' ')

                                            return
                                                 <li class="list-inline-item"><a class="uriAsLink" href="{ $uri }" target="_blank">{ $uri }</a></li>
                                                }
                                            </ul>
    let $element2Display :=
    <div class="teiElementGroup">

                    <div class="itemInDisplayElement">
                    <div class="TeiElementGroupHeader">
                            <span class="labelForm">{$elementFormLabel} <span class="teiInfo">
                                    <a title="TEI element: {$teiXPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                                </span>
                                </span>
                      </div>
                             <div id="{$elementNickName}_display_{$index}_1" class="teiElement">
                                <div id="{$elementNickName}_value_{$index}_1" title="{ $placeRef }" class="teiElementValue">{ $placePrefLabel } {$placeRefsAsLink}
                                </div>
                                <button id="edit{$elementNickName}" class="btn btn-primary editbutton pull-right" onclick="editValue('{$elementNickName}', '{$index}', '1')"
                                        appearance="minimal" type="button"><i class="glyphicon glyphicon-edit editConceptIcon"></i></button>
                             </div>

                             <div id="{$elementNickName}_edit_{ $index }_1" class="teiElementHidden form-group">
                             <select id="{$elementNickName}_{$index}_1" name="{$elementNickName}_{$index}_">
                         {for $items in $teiEditor:placeRepo//pleiades:Place
                            order by $items//skos:prefLabel[@xml:lang='en']
                            return
                                if ($items/@rdf:about = $placeProjectUri)
                                then (<option value="{$items/@rdf:about}{
                                    if($items//skos:exactMatch) then ' ' || concat(data($items//skos:exactMatch/@rdf:resource), ' ') else ()}"
                                    textValue="{$items//skos:prefLabel[@xml:lang='en']}"
                                    selected="selected">
                                    {$items//skos:prefLabel[@xml:lang='en']} {data($items/@rdf:about)}</option>)
                                        else (
                                <option value="{$items/@rdf:about}{if($items//skos:exactMatch) then ' ' || concat(data($items//skos:exactMatch/@rdf:resource), ' ') else ()}"
                                textValue="{$items//skos:prefLabel[@xml:lang='en']}">{$items//skos:prefLabel[@xml:lang='en']} {data($items/@rdf:about)}</option>
                                )
                         }</select>
<button id="save{ $elementNickName }" class="btn btn-success"
                onclick="saveData2(this, '{$currentDocId}', '{$elementNickName}_{$index}_1', '{$elementNickName}_{$index}_1', '{$elementNickName}', '{$teiXPath}', 'textNodeAndAttribute', '{ $index }', '1')"
                        appearance="minimal" type="button"><i class="glyphicon glyphicon-ok-circle"></i></button>
                        <button id="{$elementNickName}CancelEdit" class="btn btn-danger"
                onclick="cancelEdit('{$elementNickName}', '{ $index }', '', 'taxo', '1') "
                        appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>
                             </div>

                    </div>
                    </div>
return

    $element2Display




};

declare function teiEditor:docProvenance() {
    let $elementNode := $teiEditor:teiElements//teiElement[nm="fragProvenanceFound"]
    let $teiXPath := $elementNode/xpath/text()
    let $teiElementNickname := $elementNode/nm/text()

    let $teiElementDataType := $elementNode/contentType/text()
    let $teiElementFormLabel := $elementNode/formLabel/text()
    let $teiDoc := $teiEditor:doc-collection/id($teiEditor:docId)
    let $teiElementValue :=
         (util:eval( "collection('" || $teiEditor:doc-collection-path ||"')//id('"||$teiEditor:docId ||"')/" || $teiXPath))

    return
        <div>
        <h4>Provenance (findspot)</h4>
        
        {if (exists($teiElementValue/text())) then
        
            (
            <div id="{$teiElementNickname}-display" class="teiElement">
                <span class="labelForm">{$teiElementFormLabel} <span class="teiInfo">
                    <a title="TEI element: {$teiXPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                    </span>
                 </span>
            <div id="{$teiElementNickname}-value" class="teiElementValue">{$teiElementValue}</div>
            <button id="edit{$teiElementNickname}" class="btn btn-xs btn-primary editbutton pull-right"
             onclick="javascript:editValue('{$teiElementNickname}')"
                    appearance="minimal" type="button"><i class="glyphicon glyphicon-edit
                              editConceptIcon"></i></button>
        </div>)
        else("de")
        }
         <div id="{$teiElementNickname}-edit" class="teiElement teiElementHidden">
        <span class="labelForm">{$teiElementFormLabel} <span class="teiInfo">
            <a title="TEI element: {$teiXPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
            </span></span>
                <input id="{$teiElementNickname}" class="" name="{$teiElementNickname}" value="{$teiElementValue}"></input>
                <button id="saveTitleStmt" class="btn btn-primary"
                onclick="saveData('{$teiEditor:docId}', {$teiElementNickname}, '{$teiElementDataType}' '{$teiXPath}')"
                        appearance="minimal" type="button"><i class="glyphicon glyphicon-floppy-save"></i></button>

        </div>
        </div>
};


(:
*************************************
*            BIBLIOGRAPHY           *
*************************************:)


declare function teiEditor:displayBibRef($docId as xs:string, $bibRef as node(), $refType as xs:string, $index as xs:int){
    let $targetType := if(starts-with($bibRef/tei:ptr/@target, "#")) then "ref" else "uri"
    let $bibId := if( $targetType ="ref") then substring(data($bibRef[1]/tei:ptr/@target), 2)
                                    else data($bibRef/tei:ptr/@target)
    let $teiBibRef := if( $targetType ="ref") then $teiEditor:biblioRepo/id($bibId)
                                else $teiEditor:biblioRepo//tei:biblStruct[@corresp = $bibId]
    let $authorLastName := <span class="lastname">{ 
                if($teiBibRef[1]//tei:author[1]/tei:surname) then 
                        if(count($teiBibRef[1]//tei:author) = 1) then data($teiBibRef[1]//tei:author[1]/tei:surname)
                        else if(count($teiBibRef[1]//tei:author) = 2) then data($teiBibRef[1]//tei:author[1]/tei:surname) || " &amp; " || data($teiBibRef[1]//tei:author[2]/tei:surname)
                        else if(count($teiBibRef[1]//tei:author) > 2) then  <span>{ data($teiBibRef[1]//tei:author[1]/tei:surname)} <em> et al.</em></span>
                        else ()
                        
                
                
                else if ($teiBibRef[1]//tei:editor[1]/tei:surname) then
                            if(count($teiBibRef[1]//tei:editor) = 1) then data($teiBibRef[1]//tei:editor[1]/tei:surname)
                        else if(count($teiBibRef[1]//tei:editor) = 2) then data($teiBibRef[1]//tei:editor[1]/tei:surname) || " &amp; " || data($teiBibRef[1]//tei:editor[2]/tei:surname)
                        else if(count($teiBibRef[1]//tei:editor) > 2) then  <span>{ data($teiBibRef[1]//tei:editor[1]/tei:surname)} <em> et al.</em></span>
                        else ()
                        
                else ("[no name]")
                }</span>
    let $date := data($teiBibRef[1]//tei:imprint/tei:date)
    let $citedRange :=if($bibRef//tei:citedRange != "") then
                                   
                                     if (starts-with(data($bibRef[1]//tei:citedRange), ',')) 
                                     then data($bibRef[1]//tei:citedRange)
                                     else (', ' || data($bibRef[1]//tei:citedRange))
                                  else ()
    let $suffixLetter := 
    if (matches(
    substring(data($teiBibRef[1]/@xml:id), string-length(data($teiBibRef[1]/@xml:id))),
    '[a-z]'))
    then substring(data($teiBibRef[1]/@xml:id), string-length(data($teiBibRef[1]/@xml:id)))
    else ''
(:    if (matches(functx:substring-after-last-match($teiBibRef/@xml:id, [0-9]), [a-z])) then functx:substring-after-last-match($teiBibRef/@xml:id, [0-9]) else ""    :)
    let $ref2display :=    if($teiBibRef[1]//tei:title[@type="short"]) then
            (
               data($teiBibRef[1]//tei:title[@type="short"]) || substring-after($citedRange, ',')
            )
            else (
                $authorLastName  || " " || $date || $suffixLetter || $citedRange 

            ) 

    return

    <span class="bibRef"><a href="{data($teiBibRef[1]/@corresp)}" target="_blank" class="btn btn-primary">{$ref2display}</a>
    { if ( $refType != "info") then 
    <a class="removeItem" onclick="removeItemFromList('{$docId}', '{ $refType }Biblio', '{$bibId}', '{ $index }')"><i class="glyphicon glyphicon-trash" title="Remove reference from list"/></a> else ()}
    {if($targetType ="ref") then ("️ Please change to URI") else ()}
    
    </span>

};

declare function teiEditor:displayPersonItem($docId as xs:string, $personUri as xs:string?, $index as xs:string?){
            let $personId := functx:substring-after-last($personUri, '/')
            let $personRecord := $teiEditor:peopleRepo/id($personId)
            let $names := string-join($personRecord//persName, ' ')
(:          order by $personRecord/persName:)

            return
            <span class="btn btn-light listItem">

            <span title="Annotate selected text with reference to {functx:trim(normalize-space($names))}"
            onclick="addPeople({$index}, '{$personUri}')">{$names}</span>
            <a class="removeItem" onclick="removeItemFromList('{$teiEditor:docId}', 'people', '{$personUri}', {$index})"><i class="glyphicon glyphicon-trash" title="Remove reference from list"/></a></span>

};
declare function teiEditor:bibliographyEdition($docId as xs:string?){
let $teiDoc := util:eval( "collection('" || $teiEditor:doc-collection-path || "')//id('" || $docId ||"')" )
(:   let $teiDoc := $teiEditor:doc-collection/id($teiEditor:docId):)

   return
   <div class="teiElementGroup">

   <div class="TeiElementGroupHeaderBlock">
   <span class="labelForm">Editions</span>
   <button id="docBilioAddItem" class="btn btn-primary addItem" onclick="openBiblioDialog()" appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-plus"></i></button>


   </div>
      <div id="mainBiblioList" class="itemList">
   {for $bibRef at $pos in $teiDoc//tei:text/tei:body/tei:div[@type='bibliography'][@subtype='edition']/tei:listBibl//tei:bibl
   order by $bibRef//tei:ptr/@target
    return
    teiEditor:displayBibRef($teiEditor:docId, $bibRef, "main", $pos)
(:    teiEditor:displayBibRef($teiEditor:docId, substring(data($bibRef/tei:ptr/@target), 2)):)
   }
   </div>



    <!--Dialog for Biblio-->
    <div id="dialogInsertBiblio" title="Add a Bibliographical Reference" class="modal fade" tabindex="-1" style="display: none;">

            <!-- Modal content-->
            <div class="modal-content modal4editor">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"/>
                    <h4 class="modal-title">Insert a bibliographical reference</h4>
                </div>
                <div class="modal-body">
                      <form id="addBiblioForm" role="form" data-toggle="validator" novalidate="true">
                            <div class="form-group">
                                <label for="nameLookupInputModal">Search in <a href="https://www.zotero.org/groups/{$teiEditor:appVariables//zoteroGroup/text()}" target="_blank">Zotero Group {$teiEditor:appVariables//zoteroGroup/text()}</a>
                                </label>
                                <input type="text" class="form-control zoteroLookup" id="zoteroLookupInputModal" name="zoteroLookupInputModal" autocomplete="on"
                                placeholder="Start to enter a author name or a word..."/>
                            </div>
                            <div class="form-group">
                                <label for="citedRange">Cited Range
                                </label>
                                <input type="text" class="form-control" id="citedRange" name="citedRange" 
                                data-error="Please enter your full name."/>
                                 
                            </div>
                            <div id="zoteroGroupNo" class="hidden">{$teiEditor:appVariables//zoteroGroup/text()}</div>
                            <div id="selectedBiblioAuthor" class="lookupSelectionPreview"/>
                            <div id="selectedBiblioDate" class="lookupSelectionPreview"/>
                            <div id="selectedBiblioTitle" class="lookupSelectionPreview"/>
                            <div id="selectedBiblioUri" class="lookupSelectionPreview"/>
                            <div id="selectedBiblioId" class="lookupSelectionPreview"/>


                    <div class="form-group modal-footer">


                        <button  class="pull-left" type="submit" onclick="addBiblioRef('{$teiEditor:docId}', '{$teiEditor:appVariables//zoteroGroup/text()}', 'main')">Add reference</button>
                        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                    </div>
                  </form>
                    <!--                <a href="javascript: void(0);" onclick="tests()">Test</a>        -->

                </div>

            </div>


    </div>

   </div>

};
declare function teiEditor:principalBibliography($docId as xs:string?){
let $teiDoc := util:eval( "collection('" || $teiEditor:doc-collection-path || "')//id('" || $docId ||"')" )
(:   let $teiDoc := $teiEditor:doc-collection/id($teiEditor:docId):)

   return
   <div class="teiElementGroup">

   <div class="TeiElementGroupHeaderBlock">
   <span class="labelForm">General Bibliography</span>
   <button id="docBilioAddItem" class="btn btn-primary addItem" onclick="openBiblioDialog()" appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-plus"></i></button>


   </div>
      <div id="mainBiblioList" class="itemList">
   {for $bibRef at $pos in $teiDoc//tei:text/tei:body/tei:div[@type='bibliography'][@subtype='editions']/tei:listBibl//tei:bibl
   order by $bibRef//tei:ptr/@target
    return
    teiEditor:displayBibRef($teiEditor:docId, $bibRef, "main", $pos)
(:    teiEditor:displayBibRef($teiEditor:docId, substring(data($bibRef/tei:ptr/@target), 2)):)
   }
   </div>



    <!--Dialog for Biblio-->
    <div id="dialogInsertBiblio" title="Add a Bibliographical Reference" class="modal fade" tabindex="-1" style="display: none;">

            <!-- Modal content-->
            <div class="modal-content modal4editor">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"/>
                    <h4 class="modal-title">Insert a bibliographical reference</h4>
                </div>
                <div class="modal-body">
                      <form id="addBiblioForm" role="form" data-toggle="validator" novalidate="true">
                            <div class="form-group">
                                <label for="nameLookupInputModal">Search in <a href="https://www.zotero.org/groups/{$teiEditor:appVariables//zoteroGroup/text()}" target="_blank">Zotero Group {$teiEditor:appVariables//zoteroGroup/text()}</a>
                                </label>
                                <input type="text" class="form-control zoteroLookup" id="zoteroLookupInputModal" name="zoteroLookupInputModal" placeholder="Start to enter a author name or a word..."/>
                            </div>
                            <div class="form-group">
                                <label for="citedRange">Cited Range
                                </label>
                                <input type="text" class="form-control" id="citedRange" name="citedRange" 
                                data-error="Please enter your full name."/>
                                 
                            </div>
                            <div id="zoteroGroupNo" class="hidden">{$teiEditor:appVariables//zoteroGroup/text()}</div>
                            <div id="selectedBiblioAuthor" class="lookupSelectionPreview"/>
                            <div id="selectedBiblioDate" class="lookupSelectionPreview"/>
                            <div id="selectedBiblioTitle" class="lookupSelectionPreview"/>
                            <div id="selectedBiblioUri" class="lookupSelectionPreview"/>
                            <div id="selectedBiblioId" class="lookupSelectionPreview"/>


                    <div class="form-group modal-footer">


                        <button  class="pull-left" type="submit" onclick="addBiblioRef('{$teiEditor:docId}', '{$teiEditor:appVariables//zoteroGroup/text()}', 'main')">Add reference</button>
                        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                    </div>
                  </form>
                    <!--                <a href="javascript: void(0);" onclick="tests()">Test</a>        -->

                </div>

            </div>


    </div>

   </div>

};


declare function teiEditor:bibliographyPanel($docId as xs:string?, $type as xs:string){
let $teiDoc := util:eval( "collection('" || $teiEditor:doc-collection-path || "')//id('" || $docId ||"')" )
(:   let $teiDoc := $teiEditor:doc-collection/id($teiEditor:docId):)
let $fieldLabel := switch ($type)
                            case "edition" return "Editions"
                            case "reference" return "References"
                             case "secondary" return "General bibliography"
                             default return "Bibliography"


   return
   <div class="teiElementGroup">

   <div class="TeiElementGroupHeaderBlock">
   <span class="labelForm">{ $fieldLabel }</span>
   <button id="doc{ $type }BiblioAddItem" class="btn btn-primary addItem" onclick="openDialog('dialogInsert{ $type }Biblio')" appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-plus"></i></button>


   </div>
                {if ($type ="edition") then  
                  <div id="{ $type }BiblioList" class="itemList">
                                {for $bibRef at $pos in $teiDoc//tei:text/tei:body/tei:div[@type='bibliography'][@subtype=$type]/tei:listBibl//tei:bibl
                                       
                                 return
                                 teiEditor:displayBibRef($teiEditor:docId, $bibRef, $type, $pos)
                             (:    teiEditor:displayBibRef($teiEditor:docId, substring(data($bibRef/tei:ptr/@target), 2)):)
                                }
               </div>
                    else (
                         <div id="{ $type }BiblioList" class="itemList">
                                       {for $bibRef at $pos in $teiDoc//tei:text/tei:body/tei:div[@type='bibliography'][@subtype=$type]/tei:listBibl//tei:bibl
                                order by 
                                       $bibRef//tei:ptr/@target
                                
                                return
                                        teiEditor:displayBibRef($teiEditor:docId, $bibRef, $type, $pos)
                                    (:    teiEditor:displayBibRef($teiEditor:docId, substring(data($bibRef/tei:ptr/@target), 2)):)
                                       }
                      </div>
                      )
            }

    <!--Dialog for Biblio-->
    <div id="dialogInsert{ $type }Biblio" title="Add a Bibliographical Reference" class="modal fade" tabindex="-1" style="display: none;">

            <!-- Modal content-->
            <div class="modal-content modal4editor">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"/>
                    <h4 class="modal-title">Insert a bibliographical reference</h4>
                </div>
                <div class="modal-body">
                      <form id="add{ $type }BiblioForm" class="addBiblioForm" role="form" data-toggle="validator" novalidate="true">
                            <div class="form-group">
                                <label for="nameLookupInputModal">Search in <a href="https://www.zotero.org/groups/{$teiEditor:appVariables//zoteroGroup/text()}" target="_blank">Zotero Group {$teiEditor:appVariables//zoteroGroup/text()}</a>
                                </label>
                                <input type="text" class="form-control zoteroLookup" id="zoteroLookupInputModal{ $type }" name="zoteroLookupInputModal" 
                                placeholder="Start to enter a author name or a word..."/>
                            </div>
                            <div class="form-group">
                                <label for="citedRange">Cited Range
                                </label>
                                <input type="text" class="form-control" id="citedRange{ $type }" name="citedRange" 
                                data-error="Please enter your full name."/>
                                 
                            </div>
                            <div id="zoteroGroupNo" class="hidden">{ $teiEditor:appVariables//zoteroGroup/text() }</div>
                            <div id="selectedBiblioAuthor{ $type } " class="lookupSelectionPreview"/>
                            <div id="selectedBiblioDate{ $type }" class="lookupSelectionPreview"/>
                            <div id="selectedBiblioTitle{ $type }" class="lookupSelectionPreview"/>
                            <div id="selectedBiblioUri{ $type }" class="lookupSelectionPreview"/>
                            <div id="selectedBiblioId{ $type }" class="lookupSelectionPreview"/>
                    
                    </form>
                    </div>
                    <div class="modal-footer">


                        <button  class="pull-left" type="submit" onclick="addBiblioRef('{$teiEditor:docId}', '{$teiEditor:appVariables//zoteroGroup/text()}', '{ $type }')">Add reference</button>
                        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                    </div>
                  
                    <!--                <a href="javascript: void(0);" onclick="tests()">Test</a>        -->

                </div>

            </div>
        </div>

};


declare function teiEditor:placesList($docId as xs:string){
            (:let $teiDoc := $teiEditdor:doc-collection/id($docId):)
            let $teiDoc := util:eval( "$teiEditor:doc-collection/id('"||$docId ||"')" )
            let $places := $teiDoc//tei:sourceDesc/tei:listPlace//tei:place
            
            return
            <div class="xmlElementGroup">
                                     <span class="subSectionTitle">List of places linked to this document ({count($places)})</span>
                                     <div id="listOfPlacesOverview" class="listOfPlaces">
                            <ul>{
                            
                                            for $place at $pos in $places
                                                        
                                                        let $placeName := $place/tei:placeName/string()
                                                        let $placeUris := data($place/tei:placeName/@ref)
                                                        let $placeUriInternal :=
                                                            for $uri in tokenize($placeUris, " ")
                                                            return 
                                                                if (contains($uri, $teiEditor:project)) then $uri else ()
                                                        let $placeStatus := data($place/tei:placeName/@ana)
                                                       (:let $placeStatus2 := teiEditor:displayElement("placeStatus", $docId, $pos, '/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:listPlace/tei:place/tei:placeName['|| $pos ||']')       
                                                                order by $place/tei:placeName:)
                                                        let $placeRecord:= if($placeUriInternal != "") then $teiEditor:projectPlaceCollection//pleiades:Place[@rdf:about = $placeUriInternal][1] else()
                                                        return
                                                            <li class="placeInList">
                                                                <a href="{ $placeUriInternal }" title="Open details of { $placeUriInternal }" target="_self">
                                                                {$placeRecord[1]//dcterms:title[1]/text()}</a>
                                                                <span class="geoLat hidden">{$placeRecord[1]//geo:lat/text()}</span>
                                                                <span class="geoLong hidden">{$placeRecord[1]//geo:long/text()}</span>
                                                                <!--
                                                                { teiEditor:displayElement("placeStatus", $docId, $pos, '/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:listPlace/tei:place/tei:placeName['|| $pos ||']')}
                                                                -->
                                                                [{$placeStatus}]
                                                                <a href="{ $placeUriInternal }" title="Open details of { $placeUriInternal } in a new window" target="_blank">
                                                                    <i class="glyphicon glyphicon-new-window"/></a>
                                                                    <a class="removeItem" onclick="removeItemFromList('{$docId}', 'place', '{$placeUriInternal}', {$pos}, '')"><i class="glyphicon glyphicon-trash" title="Remove reference from list"/></a>
                                                            </li>
                            }</ul>
                            </div>
                            </div>
};


declare function teiEditor:placesListNoHeader($docId as xs:string){
            (:let $teiDoc := $teiEditdor:doc-collection/id($docId):)
            let $teiDoc := util:eval( "$teiEditor:doc-collection/id('"
                         ||$docId ||"')" )
            
            
            return
            
                                     <div id="listOfPlacesOverview" class="listOfPlaces">
                            <ul>{
                            
                                            for $place at $pos in $teiDoc//tei:sourceDesc/tei:listPlace//tei:place
                                                        let $placeName := $place/tei:placeName/string()
                                                        let $placeUris := data($place/tei:placeName/@ref)
                                                        let $placeUriInternal :=
                                                            for $uri in tokenize($placeUris, " ")
                                                            return 
                                                                if (contains($uri, $teiEditor:project)) then $uri else ()
                                                        let $placeStatus := data($place/tei:placeName/@ana)
                                                        
                                                                order by $place/tei:placeName
                                                                return
                                                                <li><a href="{ $placeUriInternal }" title="Open details of { $placeUriInternal }" target="_self">
                                                                {$placeName}</a>
                                                                {$placeStatus}
                                                                <a href="{ $placeUriInternal }" title="Open details of { $placeUriInternal } in a new window" target="_blank">
                                                       <i class="glyphicon glyphicon-new-window"/></a>
                                                                    <a class="removeItem" onclick="removeItemFromList('{$docId}', 'place', '{$placeUriInternal}', {$pos}, '')"><i class="glyphicon glyphicon-trash" title="Remove reference from list"/></a>
                                                                </li>
                            }</ul>
                            </div>
};


declare function teiEditor:peopleList($docId as xs:string){
let $teiDoc := $teiEditor:doc-collection/id($docId)
(:let $teiDoc := util:eval( "$teiEditor:doc-collection/id('"||$docId ||"')" ):)
let $peopleInDoc := $teiDoc//tei:listPerson[@type="peopleInDocument"]//tei:person


return
<div class="xmlElementGroup listOfPeople">
                         <span class="subSectionTitle">List of people linked to this document ({count($teiDoc//tei:listPerson[@type="peopleInDocument"]//tei:person)})</span>
                         <button class="btn btn-sm btn-primary pull-right" onclick="openDialog('dialogAddPeopleToDoc')"><i class="glyphicon glyphicon-plus"/>person</button>
                         <div id="listOfPeople">
<ul>{""
(:if(count($peopleInDoc) > 50) then ("Only 50 persons are listed here"):)
(:else ():)
}
{
    for $person at $pos in $peopleInDoc
(:            where $pos < 50:)
           
            let $personUris := data($person/@corresp)
            let $personUriInternal :=
                for $uri in tokenize($personUris, " ")
                return 
                    if (contains($uri, $teiEditor:project)) then $uri else ()
             let $personUriInternalLong := $personUriInternal || "#this"       
            let $personDetails := $teiEditor:peopleCollection//lawd:person[@rdf:about=$personUriInternalLong]
            let $persName := if($personDetails//lawd:personalName[@xml:lang="en"]) then $personDetails//lawd:personalName[@xml:lang="en"]/text() else $personDetails//lawd:personalName[1]/text()
            
            let $juridicalStatus := skosThesau:getLabel($personDetails//apc:juridicalStatus/@rdf:resource, $teiEditor:lang)
            let $personStatus := skosThesau:getLabel($personDetails//apc:personalStatus/@rdf:resource, $teiEditor:lang)
            let $personRank := skosThesau:getLabel($personDetails//apc:socialStatus/@rdf:resource, $teiEditor:lang)
                    order by $person/tei:persName
                    return
                    <li><a href="{ $personUriInternal }" title="Open details of { $personUriInternal }" target="_self">
                    {$persName}</a>
                     <span>{ if($personDetails//apc:juridicalStatus/text()) then "[" || $juridicalStatus || "]" else ()}</span>
                    <span>{ if($personDetails//apc:personalStatus/text()) then "[" || $personStatus || "]" else ()}</span>
                    { if($personDetails//skos:exactMatch) then 
                        (
                        let $uri := data($personDetails//skos:exactMatch[1]/@rdf:resource)
                        return
                            <span style="font-size: smaller;">[
                                <a href="{ $uri }" title="Open details of { $uri } in a new window" target="_blank">
                                    { if(contains($uri, "trism")) then "TM " || substring-after($uri, "person/") else $uri }
                                </a> ] 
                    </span>)
                        else ()}
                   <a href="{ $personUriInternal }" title="Open details of { $personUriInternal } in a new window" target="_blank">
           <i class="glyphicon glyphicon-new-window"/></a>
           <a class="removeItem"
                                          onclick="removeItemFromList('{$docId}', 'people', '{$personUriInternal}', {$pos}, '')"><i class="glyphicon glyphicon-trash" title="Remove reference from list"/></a>
                      <!--  <i class="glyphicon glyphicon-trash" title="Remove place from list"/>-->
                    </li>
}</ul>
</div></div>
                                };

declare function teiEditor:peopleListLight($docId as xs:string){
(:let $teiDoc := $teiEditor:doc-collection/id($docId):)
let $teiDoc := util:eval( "$teiEditor:doc-collection/id('"||$docId ||"')" )
let $peopleCollection := util:eval( "$teiEditor:peopleCollection" )
let $peopleList := $teiDoc//tei:profileDesc/tei:listPerson[@type="peopleInDocument"]

return
<div class="xmlElementGroup listOfPeople">
                         <span class="subSectionTitle">List of people linked to this document ({count($teiDoc//tei:listPerson[@type="peopleInDocument"]//tei:person)})</span>
                         <button class="btn btn-sm btn-primary pull-right" onclick="openDialog('dialogAddPeopleToDoc')"><i class="glyphicon glyphicon-plus"/>person</button>
                         <div id="listOfPeople">
                         {""
(:                         if(count($peopleList//tei:person) > 100) then ("Only 200 persons are listed here") else ():)
                         }
<ul>
{
    for $person at $pos in $peopleList//tei:person
(:    where $pos <50:)
(:            let $persName := data($person/tei:persName):)
            let $personUris := data($person/@corresp)
            let $personUriInternal :=
                for $uri in tokenize($personUris, " ")
                    return 
                        if (contains($uri, $teiEditor:project)) then $uri else ()
            let $personDetails := $peopleCollection//lawd:person[@rdf:about=$personUriInternal || "#this"]        
(:            let $personDetails := $teiEditor:peopleCollection//apc:people[@rdf:about=$personUriInternal ]:)
           let $persName := $personDetails//lawd:personalName/text()
           let $personStatus := $personDetails//apc:personalStatus/text()
           let $personFunction := $personDetails//apc:hasFunction[1]
                let $personFunctionType := switch($personFunction/@rdf:resource)
                    case "https://ausohnum.huma-num.fr/concept/c23690" return "administrator"
                    case "https://ausohnum.huma-num.fr/concept/c23687" return "georgos"
                    case "https://ausohnum.huma-num.fr/concept/c23688" return "mistothes"
                    default return "unknown fonction"
           let $personFunctionTarget := data($personFunction/@target)
           let $targetName := try{$teiEditor:placeCollection//pleiades:Place[@rdf:about = $personFunctionTarget]//dcterms:title/text()} catch * {<error/>}         
                    order by $person/tei:persName
                    return
                    <li>
                    <a href="{ $personUriInternal }" title="Open details of { $personUriInternal }" target="_self">
                    {$persName}</a>
                    <span>{ if($personDetails//apc:juridicalStatus/text()) then "[" || $personDetails//apc:juridicalStatus/text() || "]" else ()}</span>
                    <span>{ if($personDetails//apc:personalStatus/text()) then "[" || $personDetails//apc:personalStatus/text() || "]" else ()}</span>
                    <span>{ if($personFunction)
                            then <span>{$personFunctionType } of { $targetName } (<a href="{ $personFunctionTarget }" target="_blank">{substring-after($personFunctionTarget, "/places/")}</a>]</span> else ()}</span>
                            
                            { if($personDetails//skos:exactMatch) then 
                        (
                        let $uri := data($personDetails//skos:exactMatch[1]/@rdf:resource)
                        return
                            <span style="font-size: smaller;">[
                                <a href="{ $uri }" title="Open details of { $uri } in a new window" target="_blank">
                                    { if(contains($uri, "trism")) then "TM " || substring-after($uri, "person/") else $uri }
                                </a> ] 
                    </span>)
                        else ()}
                    <a href="{ $personUriInternal }" title="Open details of { $personUriInternal } in a new window" target="_blank">
           <i class="glyphicon glyphicon-new-window"/></a>
           <a class="removeItem"
                                          onclick="removeItemFromList('{$docId}', 'people', '{$personUriInternal}', {$pos}, '')"><i class="glyphicon glyphicon-trash" title="Remove reference from list"/></a>
                      <!--  <i class="glyphicon glyphicon-trash" title="Remove place from list"/>-->
                    </li>
}</ul>
</div></div>
                                };

declare function teiEditor:peopleMentionsInDoc($docId as xs:string){
(:Developped for the cleaning up of the Egyptian material:)

let $teiDoc := $teiEditor:doc-collection/id($docId)
let $file := doc( "/db/apps/patrimoniumData/egyptianMaterial/people/mentions-in-texts.xml")
let $mentions := $file//file[@apcd = $docId ]

(:let $teiDoc := util:eval( "$teiEditor:doc-collection/id('"||$docId ||"')" ):)


return
<div id="listOfMentionedNames" class="xmlElementGroup">
                         <span class="subSectionTitle">List of the {count($mentions//mention)} mentions of a name in the document (line / word position)</span>
                         <div>
                         {""
(:                         if(count($mentions//mention) > 100) then ("Only 100 persons are listed here") else ():)
                         }
<ul>{
    for $mention at $pos in $mentions//mention
(:            where $pos < 50:)
            let $personTm := data($mention/@corresp)
            let $personUri := data($mention/@apc) 
            
           let $persName := $mention/persName[@type="regularized"]/text()
           
           
(:                    order by $person/tei:persName:)
                    return
                    <li><span style="font-size: smaller;">{ data($mention/@row)} / { data($mention/@token)}</span> 
                    <a href="{ $personUri }" title="Open details of { $personUri }" target="_self">
                    {$persName}</a>
                    <span style="font-size: smaller;">[<a href="{ $personUri }" title="Open details of { $personUri }" target="_blank">apc {substring-after($personUri, "/people/")}</a>]</span>
                    <span style="font-size: smaller;">[<a href="{ $personTm }" title="Open details of { $personTm }" target="_blank">TM {substring-after($personTm, "/person/")}</a>]</span>
                    
                    <a href="{ $personUri }" title="Open details of { $personUri } in a new window" target="_blank">
           <i class="glyphicon glyphicon-new-window"/></a>
           {if( $teiDoc//tei:listPerson[@type="peopleInDocument"]//tei:person[@corresp = $personUri]) then 
           <a class="removeItem" onclick="removeItemFromList('{$docId}', 'people', '{$personUri}', '', '')" title="Remove corresponding person"><i class="glyphicon glyphicon-trash"/><span style="font-size: smaller; vertical-align: super;">Remove corresponding person</span></a>
           else()}
                    </li>
}</ul>
</div></div>
                                };




(:
*************************************
*            TEXT EDITOR            *
*************************************:)
declare function teiEditor:previewToolBar($index as xs:int?){
        let $optionalButtons :=
                    <span><button id="displayfunctionButton" class="btn btn-default btn-xs"
                    onclick="displaySemanticAnnotations('function', {$index})"><i class="glyphicon glyphicon-eye-close"/>&#160;function ♦ </button>
                    <button id="displayeventsButton" class="btn btn-default btn-xs"
                    onclick="displaySemanticAnnotations('subject', {$index})"><i class="glyphicon glyphicon-eye-close"/>&#160;keyword</button>
                    </span>
        return
<div class="previewToolbar">
                    <button id="displayplaceButton" class="btn btn-default btn-xs"
                    onclick="displaySemanticAnnotations('place', {$index})"><i class="glyphicon glyphicon-eye-close"/>&#160;places ⌘</button>
                    <button id="displaypersonButton" class="btn btn-default btn-xs"
                    onclick="displaySemanticAnnotations('person', {$index})"><i class="glyphicon glyphicon-eye-close"/>&#160;people 👤</button>
                    
                    {if( $teiEditor:mode = "edition") then $optionalButtons else()}
                    
                    
                    </div>
                    };

declare function teiEditor:textEditor($docId as xs:string, $editorType as xs:string?){
(:    let $xslCleanDiv := xs:anyURI("xmldb:exist:///db/apps/ausohnum-library/xslt/cleanTextEdition.xsl"):)
    let $teiDoc := $teiEditor:doc-collection/id($docId)
(:    let $teiDoc := util:eval( "collection('" || $teiEditor:doc-collection-path || "')//id('" ||$docId ||"')" ):)

    let $teiElementNickname :=
                if (exists($teiDoc//div[@type="textpart"])) then ('docTextSingle')
                    else if (not(exists($teiDoc//div[@type="textpart"]))) then ('docTextSingle')

                else ('docTextSingle')

    
    let $elementNode := $teiEditor:teiElements//teiElement[nm=$teiElementNickname]
    let $teiElementNode := if (exists($teiEditor:teiElementsCustom//teiElement[nm=$teiElementNickname])) then
                        $teiEditor:teiElementsCustom//teiElement[nm=$teiElementNickname]
                        else ($teiEditor:teiElements//teiElement[nm=$teiElementNickname])
    let $teiXPath := $teiElementNode//teiElement[nm=$teiElementNickname]/xpath/text()


    let $params :=
        <output:serialization-parameters
        xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
            <output:omit-xml-declaration value="yes"/>
            <output:method value="xml"/>
            <output:indent value="yes"/>
            <output:item-separator value="\n"/>
            <output:undeclare-prefixes value="yes"/>
        </output:serialization-parameters>
    let $paramMap :=
        map {
            "method": "xml",
            "indent": false(),
            "item-separator": ""

   }

    return
    <div class="editionPane">
    {if(count($teiDoc//tei:div[@type='textpart']) > 12) then <h5>⚠ Only 12 on a total of {count($teiDoc//tei:div[@type='textpart'])} textparts are displayed ⚠</h5> else ()}
        {

           (:else if($teiEditor:teiDoc//tei:div[@type='edition']//tei:div[@type='textpart']):)
           if($teiDoc/tei:text/tei:body//tei:div[@type= "edition"]//tei:div[@type='textpart'])
            then
           (
           for $textPart at $index in $teiDoc//tei:div[@type='edition']//tei:div[@type='textpart']
(:                where $index < 13:)
            let $surface := data($teiDoc/id(substring(data($textPart/@corresp), 2))/tei:desc/text())
            
            let $text :=
                    replace(functx:trim(serialize(functx:change-element-ns-deep(
                        $teiDoc//tei:div[@type="textpart"][$index]/tei:ab, '', '')/node(), $paramMap)),
                        '&#9;', '')
            
            (:let $textOLD := <div><?xml-model href="http://www.stoa.org/epidoc/schema/latest/tei-epidoc.rng" schematypens="http://relaxng.org/ns/structure/1.0"?><?xml-model href="http://www.stoa.org/epidoc/schema/latest/tei-epidoc.rng" schematypens="http://purl.oclc.org/dsdl/schematron"?>
              {normalize-space(serialize(functx:change-element-ns-deep($teiEditor:teiDoc//tei:div[@type="textpart"][$index]/tei:ab, '', '')/node(), $paramMap))}</div>
:)
            return


                <div class="textpartPane" id="editionPane-{$index}">

                    <h3> 
                        {
(:                        This is for surface:)
                        if($surface) then "" || $surface
                        else ()}
                        {
(:                        Temporary solution taking only @subtype and @n from div[@type="textpart']:)
                        if($textPart/@subtype) then "" || data($textPart/@subtype) || " " || data($textPart/@n)
                        else ()}
                        {
(:                        Temporary solution taking only @subtype and @n from div[@type="textpart']:)
                        if($textPart/@subtype) then <div id="textPartLabel{$index}" class="hidden">{if($index>1) then <br/> else()}<strong>{data($textPart/@subtype) || " " || data($textPart/@n)}</strong>{if($index=1) then <br/> else()}</div>
                        else ()}
                    </h3>
                    <div id="editionAlert{$index}" class="textModifiedAlert">


                    <div class="pull-left" id="textModifiedAlert{$index}">Text has been modified</div>
                    <textarea id="changeComment{$index}" placeholder="Enter a short description of your changes (optional)"></textarea>
                    <button id="saveTextButton{$index}" class="saveTextButton btn btn-primary" onclick="saveText('{$teiEditor:docId}', {$index})" appearance="minimal" type="button"><i class="glyphicon glyphicon-floppy-save"></i></button>
                    </div>
                    <div class="row">
                    <div class="col-xs-12 col-sm-12 col-md-12">
                                {teiEditor:annotationMenuEpigraphy($index)}
                                {teiEditor:textConverter($index)}
                     {switch($editorType)
                     case "side"
                        return ( 
                     <div>
                     <div class="editorColumn col-xs-6 col-sm-6 col-md-6">
                        <h4>XML Editor {$index}</h4>
                        <div id="xml-editor-{$index}" class="xmlEditor">{$text}</div>
                        </div><!--
                        {teiEditor:displaySurface()}
                        -->
                        <div class="previewPane col-xs-6 col-sm-6 col-md-6">
                            <h4>Preview {teiEditor:previewToolBar($index)}</h4>
                                <div id="textPreviewHTML-{$index}" class="textPreviewHTML"/>
                        </div></div>
                        )
                        case "top"
                            return
                            ( <div>
                     
                     <div class="editorColumn col-xs-12 col-sm-12 col-md-12">
                        <h4>XML Editor {$index}</h4>
                        <div id="xml-editor-{$index}" class="xmlEditor">{$text}</div>
                        </div><!--
                        {teiEditor:displaySurface()}
                        -->
                        <div class="previewPane col-xs-12 col-sm-12 col-md-12">
                            <h4>Preview {teiEditor:previewToolBar($index)}</h4>
                                <div id="textPreviewHTML-{$index}" class="textPreviewHTML"/>
                        </div>
                        </div>
                        )
                          default return
                          ( 
                     <div>
                            <div class="editorColumn col-xs-6 col-sm-6 col-md-6">
                               <h4>XML Editor {$index}</h4>
                               <div id="xml-editor-{$index}" class="xmlEditor">{$text}</div>
                               </div><!--
                               {teiEditor:displaySurface()}
                               -->
                               <div class="previewPane col-xs-6 col-sm-6 col-md-6">
                                   <h4>Preview {teiEditor:previewToolBar($index)}</h4>
                                       <div id="textPreviewHTML-{$index}" class="textPreviewHTML"/>
                               </div>
                        </div>)
                        }
                        </div>
                        <!--
                        <div class="currentXMLElement col-xs-2 col-sm-2 col-md-2">
                            <h5>Info on XML selection</h5>
                            <div id="current-xml-element-{$index}" />
                        </div>
                        -->
                    </div>
                    </div>
            )
             (:if (not(exists($teiDoc//tei:div[@type="edition"]//tei:div[@type="textpart"]))) then:)
         else if (not(exists($teiDoc//tei:div[@type="textpart"]))) then
           (
            let $text := functx:trim(serialize(functx:change-element-ns-deep($teiDoc//tei:div/tei:ab, '', '')/node(), $paramMap))

                return
                        <div class="textpartPane" id="editionPane-1">
                        <div class="alert alert-info">
                        *** This document has no textpart ***
                         </div>
                         {teiEditor:textConverter(1)}
                            <!--
                            <button id="callTextImport-1"  onclick="openTextImporter(1)" class="btn btn-default pull-right" data-target="#dialogTextImport">Import text</button>
                             -->
                            <div id="editionAlert1" class="textModifiedAlert">

                            <div class="pull-left" >Text has been modified</div>
                            <textarea id="changeComment1" placeholder="Enter a short description of your changes (optional)"></textarea>
                            <button id="saveTextButton1" class="saveTextButton btn btn-primary" onclick="javascript:saveText('{$teiEditor:docId}', 1)" appearance="minimal" type="button"><i class="glyphicon glyphicon-floppy-save"></i></button>
                            </div>
                            {teiEditor:annotationMenuEpigraphy(1)}
                            <div id="xml-editor-1" class="xmlEditor">{$text}</div>
                        <!--
                        {normalize-space(serialize(functx:change-element-ns-deep($teiEditor:teiDoc//tei:div[@type="edition"]/tei:ab, '', '')/node(), $paramMap))}
                        {normalize-space(functx:trim(serialize(functx:change-element-ns-deep($teiDoc//tei:div[@type="edition"]/tei:ab, '', '')/node(), $paramMap)))}
                        {serialize(functx:change-element-ns-deep($teiDoc//tei:div[@type="edition"]/tei:ab, '', ''), $paramMap)}
                        -->
                        <div class="previewpanel col-xs-10 col-sm-10 col-md-10">
                                 <h4>Preview {teiEditor:previewToolBar(1)}
                                 </h4>

                                 <div id="textPreviewHTML-1" class="textPreviewHTML col-xs-8 col-sm-8 col-md-8"/>
                                 <div id="pseudoLeiden-editor-1" class="textPreviewHTML hidden"/>
                        </div>
                                 <div class="col-xs-2 col-sm-2 col-md-2">
                                 <h4>Current selection</h4>
                                  <div id="current-xml-element-1" />
                                 </div>
                        </div>
           )
            else()
            }
            <div id="currentEditorIndexVariable"/>
            <div id="editionDivForLoading" class="hidden">{
                        if(count($teiDoc//tei:div[@type="edition"]//tei:div[@type="textpart"]) >12)
                            then <div type="edition">{$teiDoc//tei:div[@type="edition"]//tei:div[@type="textpart"][position() <13 ]}</div>
                            else $teiDoc//tei:div[@type="edition"]}</div>
    </div>



    };

declare function teiEditor:textPreview($docId as xs:string){
    <div class="textPreviewPane">
    <div id="test"/>
                <div class="textpartPane" id="editionPane-9999">
                    <div class="previewPane">
                            <h4>Text Preview {teiEditor:previewToolBar(9999)}</h4>

                            <div id="textPreviewHTML-9999" class="textPreviewHTMLOverview"/>
                        </div>    
                        
                    </div>
    </div>



    };
declare function teiEditor:textPreview($docId as xs:string, $numberOfTextparts as xs:integer){
    <div class="textPreviewPane">
        <div id="test"/>
        <div class="textpartPane" id="editionPane-9999">
            <div class="previewPane">
                <h4>Text Preview {teiEditor:previewToolBar(9999)}</h4>
                {if($numberOfTextparts > 12) then <h5>⚠ Only 12 on a total of { $numberOfTextparts } textparts are displayed ⚠</h5> else ()}
                <div id="textPreviewHTML-9999" class="textPreviewHTMLOverview"/>
            </div>      
        </div>
    </div>



    };
declare function teiEditor:textPreviewMulti($docId as xs:string){
(:    let $xslCleanDiv := xs:anyURI("xmldb:exist:///db/apps/ausohnum-library/xslt/cleanTextEdition.xsl"):)
    let $teiDoc := $teiEditor:doc-collection/id($docId)
(:    let $teiDoc := util:eval( "collection('" || $teiEditor:doc-collection-path || "')//id('" ||$docId ||"')" ):)

    let $teiElementNickname :=
                if (exists($teiDoc//div[@type="textpart"])) then ('docTextSingle')
                    else if (not(exists($teiDoc//div[@type="textpart"]))) then ('docTextSingle')

                else ('docTextSingle')

    let $elementNode := $teiEditor:teiElements//teiElement[nm=$teiElementNickname]
    let $teiElementNode := if (exists($teiEditor:teiElementsCustom//teiElement[nm=$teiElementNickname])) then
                        $teiEditor:teiElementsCustom//teiElement[nm=$teiElementNickname]
                        else ($teiEditor:teiElements//teiElement[nm=$teiElementNickname])
    let $teiXPath := $teiElementNode//teiElement[nm=$teiElementNickname]/xpath/text()


    let $params :=
        <output:serialization-parameters
        xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
            <output:omit-xml-declaration value="yes"/>
            <output:method value="xml"/>
            <output:indent value="yes"/>
            <output:item-separator value="\n"/>
            <output:undeclare-prefixes value="yes"/>
        </output:serialization-parameters>
    let $paramMap :=
        map {
            "method": "xml",
            "indent": false(),
            "item-separator": ""

   }

    return
    <div class="textPreviewPane">
        {

           (:else if($teiEditor:teiDoc//tei:div[@type='edition']//tei:div[@type='textpart']):)
           if(exists($teiDoc//tei:div[@type='textpart']))
            then
           (
           for $textpart at $index in $teiDoc//tei:div[@type='edition']//tei:div[@type='textpart']
            where $index < 13
            let $surface := data($teiDoc/id(substring(data($textpart/@corresp), 2))/tei:desc/text())
            let $text :=
                    replace(functx:trim(serialize(functx:change-element-ns-deep(
                       $textpart/tei:ab, '', '')/node(), $paramMap)),
                        '&#9;', '')
            let $textOLD := <div><?xml-model href="http://www.stoa.org/epidoc/schema/latest/tei-epidoc.rng" schematypens="http://relaxng.org/ns/structure/1.0"?><?xml-model href="http://www.stoa.org/epidoc/schema/latest/tei-epidoc.rng" schematypens="http://purl.oclc.org/dsdl/schematron"?>
              {normalize-space(serialize(functx:change-element-ns-deep($teiEditor:teiDoc//tei:div[@type="textpart"][$index]/tei:ab, '', '')/node(), $paramMap))}</div>

            return
                <div class="textpartPane" id="editionPane-9999">
                    <h3> {if($surface) then "Text on " || $surface
                        else ()}
                    </h3>
                    {if(count($teiDoc//tei:div[@type='edition']//tei:div[@type='textpart']) > 12) then <h5>Only 12 on a total of {count($teiDoc//tei:div[@type='edition']//tei:div[@type='textpart'])} textparts are displayed</h5> else ()}
                    <div class="previewPane">
                            <h4>Text Preview {teiEditor:previewToolBar(9999)}</h4>
{if(count($teiDoc//tei:div[@type='edition']//tei:div[@type='textpart']) > 12) then <h5>Only 12 on a total of {count($teiDoc//tei:div[@type='edition']//tei:div[@type='textpart'])} textparts are displayed</h5> else ("r")}
                            <div id="textPreviewHTML-9999" class="textPreviewHTMLOverview"/>
                        </div>    
                        
                    </div>
            )
             (:if (not(exists($teiDoc//tei:div[@type="edition"]//tei:div[@type="textpart"]))) then:)
         else if (not(exists($teiDoc//tei:div[@type="textpart"]))) then
           (
            let $text := functx:trim(serialize(functx:change-element-ns-deep($teiDoc//tei:div/tei:ab, '', '')/node(), $paramMap))

                return
                        <div class="textpartPane" id="editionPane-9999">
                        <div class="alert alert-info">
                        This document has no textpart
                         </div>
                        
                        <div class="previewpanel col-xs-10 col-sm-10 col-md-10">
                                 <h4>Text preview {teiEditor:previewToolBar(1)}
                                 </h4>

                                 <div id="textPreviewHTML-9999" class="textPreviewHTMLOverview"/>
                         </div>
                     </div>
           )
            else()
            }
            <div id="currentEditorIndexVariable"/>
    </div>



    };


declare %templates:wrap function teiEditor:textConverter($index){
    <div style="display: inline;">
    <button id="callTextImport-{$index}"  onclick="openTextImporter({$index})" class="btn btn-xs btn-primary pull-right" data-target="#dialogTextImport">Text Converter</button>
    <div id="dialogTextTmport" title="Import a text" class="modal fade" tabindex="-1" style="display: none;">

            <!-- Modal content-->
            <div class="modal-content modal4editor">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"/>
                    <span class="modal-title">Text converter</span>
                </div>
                <div class="modal-body small-font">
                <p>You can paste any text formatted according to main epigraphical standards.</p>
                    <div class="form-group row">
                                <label for="langSource">Select a script</label>
                                <select id="langSource" name="langSource">
                                     <option value="grc">Ancient Greek</option>
                                     <option value="la">Latin</option>
                                     <option value="egy-Egyd">Ancient Egyptian in demotic script (latin transliteration)</option>
                                     <option value="egy-Egyh">Ancient Egyptian in hieratic script (latin transliteration)</option>
                                     <option value="egy-Egyp">Ancient Egyptian in hieroglyphic script (latin transliteration)</option>
                                </select>

                    </div>
                    <div class="form-group row">
                                <label for="importSource">Select source format</label>
                                <select id="importSource" name="importSource">
                                     <option value="petrae">PETRAE</option>
                                     <option value="edr">EDR</option>
                                     <option value="edcs">EDCS / EDH</option>
                                     <option value="phi">PHI</option>
                                </select>
                    </div>
                     <div class="form-group row">
                                <label for="textImportStartingLine">Starting line number (if not 1)</label>
                                <input id="textImportStartingLine" name="textImportStartingLine" type="text"/>
                    </div>
                    <input id="editorIndex{$index}" name="editorIndex" type="text" class="hidden"/>
                    <input id="textImportMode" name="textImportMode" type="text" class="hidden"/>
                            <!--
                           <label for="text2import">Paste text to import below</label>

                            <textarea class="form-control" name="text2import" id="text2import" row="10" ></textarea>
                            -->
                                <p>Paste your text below</p>
                                <span id="conversionInProcess" class="hidden"><img id="f-load-indicator" class="" src="/$ausohnum-lib/resources/images/ajax-loader.gif"/></span>
                                <div class="text2importInput">
                                <div id="text2importInputEditor"/>
                                </div>
                                <label for="text2importXMLPreview">XML preview</label>
                                <div id="text2importXMLPreview"/>

                    <div class="modal-footer">
                        <button  class="btn btn-primary" onclick="importText({$index})">OK</button>
                        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                    </div>



                </div>

            </div>



    </div>
    </div>
};


declare function teiEditor:annotationMenuEpigraphy($index){
(:    let $teiDoc := $teiEditor:doc-collection/id($teiEditor:docId):)
    (:let $index :=
        if (not(exists($teiDoc//div[@type="edition"]/div[@type="textpart"]))) then 1
            else (
            count($teiDoc//div[@type="edition"]/div[@type="textpart"])
            ):)
(:     return:)
            <div id="edition-toolbar-{$index}" class="btn-group xmlToolBar" role="group" aria-label="..." >

                      <span class="toolBarTitle">Epigraphic annotations</span>

                       <div class="dropdown btn-group" role="group">
                            <a id="insertLb" role="button" data-toggle="dropdown" class="btn btn-default btn-xs" data-target="#" >
                                (1)<span class="caret"></span>
                            </a>
                            <ul class="dropdown-menu multi-level" role="menu" aria-labelledby="dropdownMenu">

                                  <li class="dropdown-submenu">
                                    <a  role="button" onclick="insertLb({$index}, 1)">Line beginning</a>
                                    <ul class="dropdown-menu">
                                        <li><a role="button" onclick="insertLb({$index}, 1, '')">1</a><a role="button" onclick="insertLb({$index}, 1, 'no')"><em class="small">- in word</em></a></li>
                                        <li><a role="button" onclick="insertLb({$index}, 2, '')">2</a><a role="button" onclick="insertLb({$index}, 2, 'no')"><em class="small">- in word</em></a></li>
                                    	<li><a role="button" onclick="insertLb({$index}, 3, '')">3</a><a role="button" onclick="insertLb({$index}, 3, 'no')"><em class="small">- in word</em></a></li>
                                    	<li><a role="button" onclick="insertLb({$index}, 4, '')">4</a><a role="button" onclick="insertLb({$index}, 4, 'no')"><em class="small">- in word</em></a></li>
                                    	<li><a role="button" onclick="insertLb({$index}, 5, '')">5</a><a role="button" onclick="insertLb({$index}, 5, 'no')"><em class="small">- in word</em></a></li>
                                    	<li><a role="button" onclick="insertLb({$index}, 6, '')">6</a><a role="button" onclick="insertLb({$index}, 6, 'no')"><em class="small">- in word</em></a></li>
                                    	<li><a role="button" onclick="insertLb({$index}, 7, '')">7</a><a role="button" onclick="insertLb({$index}, 7, 'no')"><em class="small">- in word</em></a></li>
                                    	<li><a role="button" onclick="insertLb({$index}, 8, '')">8</a><a role="button" onclick="insertLb({$index}, 8, 'no')"><em class="small">- in word</em></a></li>
                                    	<li><a role="button" onclick="insertLb({$index}, 9, '')">9</a><a role="button" onclick="insertLb({$index}, 9, 'no')"><em class="small">- in word</em></a></li>
                                    	<li><a role="button" onclick="insertLb({$index}, 10, '')">10</a><a role="button" onclick="insertLb({$index}, 10, 'no')"><em class="small">- in word</em></a></li>
                                    </ul>
                                  </li>
                              <li class="dropdown-submenu">
                                    <a href="#">Column beginning</a>
                                    <ul class="dropdown-menu">
                                        <li><a role="button" onclick="insertCb({$index}, 1, '')">1</a><a role="button" onclick="insertCb({$index}, 1, 'no')"><em class="small">- in word</em></a></li>
                                    	<li><a role="button" onclick="insertCb({$index}, 2, '')">2</a><a role="button" onclick="insertCb({$index}, 2, 'no')"><em class="small">- in word</em></a></li>
                                    	<li><a role="button" onclick="insertCb({$index}, 3, '')">3</a><a role="button" onclick="insertCb({$index}, 3, 'no')"><em class="small">- in word</em></a></li>
                                    	<li><a role="button" onclick="insertCb({$index}, 4, '')">4</a><a role="button" onclick="insertCb({$index}, 4, 'no')"><em class="small">- in word</em></a></li>
                                    	<li><a role="button" onclick="insertCb({$index}, 5, '')">5</a><a role="button" onclick="insertCb({$index}, 5, 'no')"><em class="small">- in word</em></a></li>
                                    </ul>
                                  </li>

                            </ul>
        </div>

                             <button type="button" class="btn btn-xs btn-default" onclick="unclear({$index});" title="Unclear letter(s)">ạ</button>
                            <button type="button" class="btn btn-xs btn-default" onclick="apex({$index});" title="Letter with apex">á</button>
                            <button type="button" class="btn btn-xs btn-default" onclick="supraline({$index});" title="Letter with supraline">ā</button>
                            <button type="button" class="btn btn-xs btn-default" onclick="intraline({$index});" title="Struck through letter"><strike>A</strike></button>
                            <button type="button" class="btn btn-xs btn-default" onclick="ligature({$index});" title="Letters with ligature">a͡b</button>
                            <button type="button" class="btn btn-xs btn-default" onclick="supplied({$index}, 'lost', '')" title="Restauration">[a]</button>
                            <button type="button" class="btn btn-xs btn-default" onclick="supplied({$index}, 'lost', 'low')" title="Uncertain restauration">[a?]</button>
                            <button type="button" class="btn btn-xs btn-default" onclick="surplus({$index})" title="Surplus">&#123;a&#125;</button>
                            <button type="button" class="btn btn-xs btn-default" onclick="corr({$index})" title="Correction">⸢a⸣</button>
                            <button type="button" class="btn btn-xs btn-default" onclick="supplied({$index}, 'omitted', '')" title="Letters added by editor">&#60;a&#62;</button>
                            <button type="button" class="btn btn-xs btn-default" onclick="erasure({$index})" title="Erasure">⟦a⟧</button>
                            <button type="button" class="btn btn-xs btn-default" onclick="abbrev({$index}, '')" title="Expansion of an abbreviation">a(bc)</button>
                           
                           
                           <div class="btn-group" role="group">
                              <button type="button" class="btn btn-xs btn-default dropdown-toggle"
                              data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"
                              title="Complex abbreviations">a(b)c(d)
                                <span class="caret"></span>
                              </button>
                              <ul class="dropdown-menu">
                                        <li><a role="button" onclick="insertComplexAbbrev({$index}, 'consul')">co(n)s(ul)</a></li>
                                        <li><a role="button" onclick="insertComplexAbbrev({$index}, 'proconsul')">proco(n)s(ul)</a></li>
                                        <li><a role="button" onclick="insertComplexAbbrev({$index}, 'cohors')">c(o)ho(rs)</a></li>
                              </ul>
                                
                            </div>
 
                            
                            <button type="button" class="btn btn-xs btn-default" onclick="abbrev({$index}, 'low')" title="Tentative expansion of an abbreviation">a(bc?)</button>
                            
                            
                            <button type="button" class="btn btn-xs btn-default" onclick="abbrevShort({$index})" title="Abbreviation with unknown development">a(- - -)</button>
                            
                            <button type="button" class="btn btn-xs btn-default" onclick="abbrevSymbol({$index})" title="Expansion of a symbol">(abc)</button>
                            
                           <div class="btn-group" role="group">
                              <button type="button" class="btn btn-xs btn-default dropdown-toggle"
                              data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"
                              title="Lacuna">Lacuna
                                <span class="caret"></span>
                              </button>
                              <ul class="dropdown-menu">
                                <li class="dropdown-submenu">
                                    <a onclick="insertGap({$index}, 'lost', 'unknown', '')">Letters</a>
                                    <ul class="dropdown-menu">
                                        <li><a role="button" onclick="insertGap({$index}, 'lost', 'unknown', 'character')">Extent unknown  [– – –]</a></li>
                                        <li><a role="button" onclick="insertGap({$index}, 'lost', 1, 'character')">1 letter</a></li>
                                    	<li><a role="button" onclick="insertGap({$index}, 'lost', 2, 'character')">2 letters</a></li>
                                    	<li><a role="button" onclick="insertGap({$index}, 'lost', 3, 'character')">3 letters</a></li>
                                    	<li><a role="button" onclick="insertGap({$index}, 'lost', 4, 'character')">4 letters</a></li>
                                    	<li><a role="button" onclick="insertGap({$index}, 'lost', 5, 'character')">5 letters</a></li>
                                    	<li><a role="button" onclick="insertGap({$index}, 'lost', 5, 'character', 'low')">Approximate extent [– ca.5 –]</a></li>
                                    	<li><a role="button" onclick="insertGap({$index}, 'lost', 'range', 'character')">Range of possible extent [– 5-7 –]</a></li>
                                    	
                                    </ul>
                                  </li>
                                    <li class="dropdown-submenu">
                                    <a onclick="insertGap({$index}, 'omitted', 'unknown', '')">Lines</a>
                                    <ul class="dropdown-menu">
                                    <li><a role="button" onclick="insertGap({$index}, 'lost', 'unknown', 'line')">Number unknown - - - - - - -</a></li>
                                    <li><a role="button" onclick="insertGap({$index}, 'lost', 1, 'line')">1 line</a></li>
                                    	
                                    </ul>
                                  </li>
                                    <!--
                                    <li class="dropdown-submenu">
                                    <a onclick="insertGap({$index}, 'omitted', 'unknown', '')">Omitted</a>
                                    <ul class="dropdown-menu">
                                        <li><a role="button" onclick="insertGap({$index}, 'omitted', 1, 'character')">1 letter</a></li>
                                    	<li><a role="button" onclick="insertGap({$index}, 'omitted', 2, 'character')">2 letters</a></li>
                                    	<li><a role="button" onclick="insertGap({$index}, 'omitted', 3, 'character')">3 letters</a></li>
                                    	<li><a role="button" onclick="insertGap({$index}, 'omitted', 4, 'character')">4 letters</a></li>
                                    	<li><a role="button" onclick="insertGap({$index}, 'omitted', 5, 'character')">5 letters</a></li>
                                    	<li><a role="button" onclick="insertGap({$index}, 'omitted', 1, 'line')">1 line</a></li>
                                    	<li><a role="button" onclick="insertGap({$index}, 'omitted', 2, 'line')">2 lines</a></li>
                                    </ul>
                                  </li>
                                    -->
                              </ul>
                            </div>

                            <div class="btn-group" role="group">
                              <button type="button" class="btn btn-xs btn-default dropdown-toggle"
                              data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"
                              title="Addition">Addition
                                <span class="caret"></span>
                              </button>
                              <ul class="dropdown-menu">
                                <li><a role="button" onclick="add_above({$index})">Above</a></li>
                                <li><a role="button" onclick="add_below({$index})">Below</a></li>
                              </ul>
                            </div>
                                
                            <div class="btn-group" role="group">
                              <button type="button" class="btn btn-xs btn-default dropdown-toggle"
                              data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"
                              title="Illegible">Illegible
                                <span class="caret"></span>
                              </button>
                              <ul class="dropdown-menu">
                                <li><a role="button" onclick="illegible({$index}, 'character', 1)">1 letter</a></li>
                    	<li><a role="button" onclick="illegible({$index}, 'character', 2)">2 letters</a></li>
                    	<li><a role="button" onclick="illegible({$index}, 'character', 3)">3 letters</a></li>
                    	<li><a role="button" onclick="illegible({$index}, 'character', 4)">4 letters</a></li>
                    	<li><a role="button" onclick="illegible({$index}, 'character', 5)">5 letters</a></li>
                              </ul>
                            </div>    
                                
<!--        <div class="dropdown btn-group" role="group">
            <a id="dLabel" role="button" data-toggle="dropdown" class="btn btn-default btn-xs" data-target="#" >
                Illegible<span class="caret"></span>
            </a>
    		<ul class="dropdown-menu multi-level" role="menu" aria-labelledby="dropdownMenu">

              <li class="dropdown-submenu">
                    <a href="#">Letter</a>
                    <ul class="dropdown-menu">
                        <li><a role="button" onclick="illegible({$index}, 'character', 'unknown')">Unknown</a></li>
                        <li><a role="button" onclick="illegible({$index}, 'character', 1)">1</a></li>
                    	<li><a role="button" onclick="illegible({$index}, 'character', 2)">2</a></li>
                    	<li><a role="button" onclick="illegible({$index}, 'character', 3)">3</a></li>
                    	<li><a role="button" onclick="illegible({$index}, 'character', 4)">4</a></li>
                    	<li><a role="button" onclick="illegible({$index}, 'character', 5)">5</a></li>
                    </ul>
                  </li>
              <li class="dropdown-submenu">
                    <a href="#">Line</a>
                    <ul class="dropdown-menu">
                        <li><a role="button" onclick="illegible({$index}, 'line', 'unknown')">Unknown</a></li>
                        <li><a role="button" onclick="illegible({$index}, 'line', 1)">1</a></li>
                    	<li><a role="button" onclick="illegible({$index}, 'line', 2)">2</a></li>
                    	<li><a role="button" onclick="illegible({$index}, 'line', 3)">3</a></li>
                    	<li><a role="button" onclick="illegible({$index}, 'line', 4)">4</a></li>
                    	<li><a role="button" onclick="illegible({$index}, 'line', 5)">5</a></li>
                    </ul>
                  </li>
                    
            </ul>
        </div>
        -->




<div class="dropdown btn-group" role="group">
            <a id="dLabel" role="button" data-toggle="dropdown" class="btn btn-default btn-xs" title="Vacat">
                Vacat<span class="caret"></span>
            </a>
    		<ul class="dropdown-menu multi-level" role="menu" aria-labelledby="dropdownMenu">

              <li class="dropdown-submenu">
                    <a href="#">Letter</a>
                    <ul class="dropdown-menu">
                        <li><a href="#" role="button" onclick="vacat({$index}, 'character', 0)">Undetermined <em>vacat.</em></a></li>
                        <li><a href="#" role="button" onclick="vacat({$index}, 'character', 1)">1</a></li>
                        <li><a href="#" role="button" onclick="vacat({$index}, 'character', 2)">2</a></li>
                        <li><a href="#" role="button" onclick="vacat({$index}, 'character', 3)">3</a></li>
                        <li><a href="#" role="button" onclick="vacat({$index}, 'character', 4)">4</a></li>
                        <li><a href="#" role="button" onclick="vacat({$index}, 'character', 5)">5</a></li>
                        
                    </ul>
                  </li>
              <li class="dropdown-submenu">
                    <a href="#">Line</a>
                    <ul class="dropdown-menu">
                        <li><a href="#" role="button" onclick="vacat({$index}, 'line', 1)">1</a></li>
                    </ul>
                  </li>

            </ul>
        </div>
        
        
        
        
        
        <button type="button" class="btn btn-xs btn-default" onclick="insertGap({$index}, 'omitted', 'unknown', 'character')" title="Text left uncompleted by stonecutter">(- - -)</button>
        
        <div class="dropdown btn-group" role="group">
            <a id="dLabel" role="button" data-toggle="dropdown" class="btn btn-default btn-xs" >
                IX<span class="caret"></span>
            </a>
    	<ul class="dropdown-menu multi-level" role="menu" aria-labelledby="dropdownMenu">
                     <li><a href="#" role="button" onclick="romanNumber({$index}, 'convert')">Convert selection</a></li>
                     <li><a href="#" role="button" onclick="romanNumber({$index}, 1)">I</a></li>
                    <li><a href="#" role="button" onclick="romanNumber({$index}, 2)">II</a></li>
                    <li><a href="#" role="button" onclick="romanNumber({$index}, 3)">III</a></li>
                    <li><a href="#" role="button" onclick="romanNumber({$index}, 4)">IV</a></li>
                    <li><a href="#" role="button" onclick="romanNumber({$index}, 5)">V</a></li>
                    <li><a href="#" role="button" onclick="romanNumber({$index}, 6)">VI</a></li>
                    <li><a href="#" role="button" onclick="romanNumber({$index}, 7)">VII</a></li>
                    <li><a href="#" role="button" onclick="romanNumber({$index}, 8)">VIII</a></li>
                    <li><a href="#" role="button" onclick="romanNumber({$index}, 9)">IX</a></li>
                    <li><a href="#" role="button" onclick="romanNumber({$index}, 10)">X</a></li>
               </ul>
       </div>
        
        <div class="dropdown btn-group" role="group">
            <a id="dLabel" role="button" data-toggle="dropdown" class="btn btn-default btn-xs" >
                Symbols<span class="caret"></span>
            </a>
    	<ul class="dropdown-menu multi-level" role="menu" aria-labelledby="dropdownMenu">
        
        <li><a href="#" role="button" onclick="insertHedera({$index});" title="hedera">❦</a></li>
        <li><a href="#" role="button" onclick="insertChiRho({$index});" title="chirho">☧</a></li>
       <li><a href="#" role="button" onclick="insertInterpunct({$index});" title="Symbol Interpunct">▴</a></li>
        <li><a href="#" role="button" onclick="insertDenarius({$index});" title="Symbol Denarius">Ӿ</a></li>
        
               </ul>
       </div>
        
        <button type="button" class="btn btn-xs btn-default" onclick="insertNote({$index}, '!')" title="(!)">(!)</button>
        <button id="saveTextButton{$index}" class="saveTextButton btn btn-primary pull-right" onclick="saveText('{$teiEditor:docId}', {$index})" appearance="minimal" type="button"><i class="glyphicon glyphicon-floppy-save"></i></button>
        </div>
};

declare function teiEditor:semanticAnnotation($annotationLabel as xs:string,
                                              $annotationType as xs:string,
                                              $teiElement as xs:string,
                                              $topConceptId as xs:string){
    <div id="annotation_{$annotationLabel}_" class="sectionInPanel">
    <h4>Semantic Annotations</h4>
      <span class="subSectionTitle">{$annotationLabel}</span>
                                    <div class="insertTagWithDropDown">
                                            {skosThesau:dropDownThesauXML($topConceptId, 'en', 'noLabel', 'inline', 1, 1, ())}
                            <button class="inline btn btn-primary btn-xs"
                            onclick="addReferenceString('1', '{$annotationType}', '{$topConceptId}', 1)">Annotate</button>
                                    </div>

                                </div>
};

declare function teiEditor:manualLemmatizer(){
    let $teiDoc := $teiEditor:doc-collection/id($teiEditor:docId)
    let $index :=
        if (not(exists($teiDoc//div[@type="edition"]/div[@type="textpart"]))) then 1
            else (
            count($teiDoc//div[@type="edition"]/div[@type="textpart"])
            )
     return
            <div id="lemmatizer-toolbar-{$index}" class="btn-group xmlToolBar" role="group" aria-label="..." >
                  <h4 class="toolBarTitle">Word Lemmatizer</h4>
                                    <div class="sectionInPanel panel panel-primary ">
                                                    <div class="input-group">
                                                             <span class="input-group-addon">Lemmata</span>
                                                                <input type="text" class="form-control" id="lemmataForm" name="lemmataForm"
                                        placeHolder="Lemmata"/>
                                                            <span class="input-group-addon">
                                                            <button class="inline btn btn-primary btn-xs" title="Copy &amp; paste selected text from editor"
                                                        onclick="pasteSelectedText({$index}, 'lemmataForm')"><i class="glyphicon glyphicon-transfer"/></button>
                                                            </span>
                                                       </div>
                                            <button class="inline btn btn-primary btn-xs"
                                                onclick="lemmatizeWord({$index})">Lemmatize Selected Word</button>
                        </div>
                      </div>
};

declare function teiEditor:annotationPlacePeopleTime(){
    let $teiDoc := $teiEditor:doc-collection/id($teiEditor:docId)
    let $index :=
        if (not(exists($teiDoc//div[@type="edition"]/div[@type="textpart"]))) then 1
            else (
            count($teiDoc//div[@type="edition"]/div[@type="textpart"])
            )
     return
            <div id="edition-toolbar-{$index}" class="btn-group xmlToolBar" role="group" aria-label="..." >

                      <h4 class="toolBarTitle">Annotate Place, People &amp; Time</h4>
                        <div class="panel panel-default">
                           <div class="panel-heading"  data-toggle="collapse"  href="#annotation-places-panel">&#x2318; Places</div>
                           <div id="annotation-places-panel" class="panel-collapse">
                                <div class="panel-body">
                                <div><span class="subSectionTitle">List of places attached to this doc.</span>
                                <!--
                                {
                                teiEditor:listsPlaces()
                                }
                                
                                <button class="inline btn btn-secondary btn-xs"
                                                onclick="addPlaceToDoc({$index})">Tag with selected Place</button>
                                                <br/>
                         -->
                        <div id="listOfPlaces">
                                { teiEditor:placeListForAnnotation($teiEditor:docId, $index) }
                                </div>
                                </div>
                                <!--
                                <div id="placeLookUpPanel" class="sectionInPanel"><span class="subSectionTitle">Add a new place</span>

                                        <div class="form-group">
                                                    <label for="placesLookupInputSemantic">Search in <a href="http://pelagios.org/peripleo/map" target="_blank">Pelagios Peripleo</a>
                                                    </label>
                                                    <input type="text" class="form-control" id="placesLookupInputSemantic" name="placesLookupInputSemantic"/>
                                                </div>
                                                 <div class="">

                            <iframe id="peripleoWidget" allowfullscreen="true" height="380" src="" style="display:none;"> </iframe>
                            <div id="previewMap" class="hidden"/>
                            <div id="placePreviewPanel" class="hidden"/>
                            <button id="addNewPlaceButton" class="btn btn-success hidden" onclick="addPlaceToDoc('{$teiEditor:docId}')" appearance="minimal" type="button">Add place to document<i class="glyphicon glyphicon glyphicon-saved"></i></button>
                        </div>
                                </div>
                                -->
                                </div>
                           </div>
                        </div>

                      <div class="panel panel-default">
                           <div class="panel-heading"  data-toggle="collapse"  href="#annotation-people-panel">&#x1F464; People</div>
                           <div id="annotation-people-panel" class="panel-collapse">
                                <div class="panel-body">
                      <div><span class="subSectionTitle">List of people attached to this doc. ({count($teiDoc//tei:listPerson[@type="peopleInDocument"]//tei:person)})
                      <!--
                      <button class="btn btn-sm btn-primary pull-right" onclick="openDialog('dialogAddPeopleToDoc')"><i class="glyphicon glyphicon-plus"/>person</button></span>
                      --></span>
                       <!--
                       <div id="peopleList" class="itemList">
                                {
                                for $people in $teiDoc//tei:listPerson[@type="peopleInDocument"]//tei:person
                                    let $personUri := $people/@corresp/string()
                                    let $personId := functx:substring-after-last($personUri, '/')
                                    let $personRecord := $teiEditor:peopleRepo/id($personId)
                                    let $names := string-join($personRecord//tei:persName, ' ') || "ee"
(:                                order by $personRecord/persName:)

                                return
                                teiEditor:displayPersonItem($teiEditor:docId, $personUri, $index)
                                }
                     </div>
                     -->
                     {
                                teiEditor:listPeople($teiEditor:docId, $index)
                                }
                                </div>
                                <div class="sectionInPanel">
                                    <span class="subSectionTitle">Annotate Names</span>


                                     <div class="sectionInPanel panel panel-primary ">
                                     <span class="subSectionTitle">PersName</span>
                                    <div class="insertTagWithDropDown">
                                            <div id="persNameType">{skosThesau:dropDownThesauXML('c19928', 'en', 'Type', 'inline', (), 1, ())}</div>
                            <button class="inline btn btn-primary btn-xs"
                                                onclick="addPersName({$index}, '')">PersName</button>

                                    </div>

                                            <div class="sectionInPanel panel panel-primary ">
                                                    <span class="subSectionTitle">Names</span>
                                                    <div class="input-group">
                                                             <span class="input-group-addon">NymRef</span>


                                                                <input type="text" class="form-control" id="standardizedForm" name="standardizedForm"
                                        placeHolder="Standardized form"/>
                                                            <span class="input-group-addon">
                                                            <button class="inline btn btn-primary btn-xs" title="Copy &amp; paste selected text from editor"
                                                        onclick="pasteSelectedText({$index}, 'standardizedForm')"><i class="glyphicon glyphicon-transfer"/></button>
                                                            </span>
                                                       </div>

                                              <button class="inline btn btn-primary btn-xs"
                                                onclick="addName({$index}, 'name')">Name</button>
                                                <br/>

                                            <button class="inline btn btn-primary btn-xs"
                                                onclick="addName({$index}, 'praenomen')">Praenomen</button>
                                                <button class="inline btn btn-primary btn-xs"
                                                onclick="addName({$index}, 'nomen')">Nomen</button>
                                            <button class="inline btn btn-primary btn-xs"
                                                onclick="addName({$index}, 'cognomen')">Cognomen</button>
                                              <br/>

                                   </div>
                                    </div>
                                </div>


                                <div class="sectionInPanel">
                                    <span class="subSectionTitle">♦ functions</span>
                                    <div class="insertTagWithDropDown">
                                            {skosThesau:dropDownThesauXML('c19307', 'en', 'noLabel', 'inline', (), 1, ())}
                                            <button class="inline btn btn-primary btn-xs"
                                                onclick="addReferenceString({$index}, 'function', 'c19307', 1)">&lt;insert function&gt;</button>
                                    </div>
                                </div>
                               </div>


                           </div>










                        </div>

                      <div class="panel panel-default">
                           <div class="panel-heading"  data-toggle="collapse"  href="#annotation-places-panel">Events</div>
                           <div id="annotation-events-panel" class="panel-collapse collapse">
                                <div class="panel-body">

                                </div>
                           </div>
                        </div>

                        <div class="div4Modals">
                        
 <!--Dialog for People-->
    <div id="dialogNewPerson" title="Add a new person" class="modal fade" tabindex="-1" style="display: none;">

            <!-- Modal content-->
            <div class="modal-content modal4editor">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"/>
                    <h4 class="modal-title">Create a new person</h4>
                </div>
                <div class="modal-body">
                <div>
                     {skosThesau:dropDownThesauXML('c19291', 'en', 'Status', 'row', (), 1, ())}
                     {skosThesau:dropDownThesauXML('c19297', 'en', 'Rank', 'row', (), 1, ())}
                     {skosThesau:dropDownThesauXML('c19303', 'en', 'Citizenship', 'row', (), 1, ())}
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


                        <button id="addPeople" class="pull-left" onclick="createAndAddPerson('{$teiEditor:docId}', {$index})">Create person</button>
                        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                    </div>

                    <!--                <a href="javascript: void(0);" onclick="tests()">Test</a>        -->
                </div>
            </div>
       </div><!--End of dialog-->











<!--Dialog for new document-->
    <div id="dialogInsertNymRef" title="Insert name nymRef" class="modal fade" tabindex="-1" style="display: none;">

            <!-- Modal content-->
            <div class="modal-content modal4editor">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"/>
                    <h4 class="modal-title">Create a new Collection of documents</h4>
                </div>
                <div class="modal-body">
                <div class="form-group row">
                                <label for="standardizedForm" class="col-sm-2 col-form-label">Standardized form</label>
                                <div class="col-sm-10">
                                <input type="text" class="form-control" id="standardizedForm" name="standardizedForm"
                                placeHolder="Insert a standardized name"/>
                                </div>
                </div>

                    <div class="form-group modal-footer">
                        <button id="addNymRef" class="pull-left" onclick="addNymRef({$index})">Insert NymRef</button>
                        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                    </div>

                    <!--                <a href="javascript: void(0);" onclick="tests()">Test</a>        -->
                </div>
            </div>
       </div><!--End of dialog-->






                        </div>


                      </div>
};

declare function teiEditor:placeListForAnnotation($docId as xs:string, $index as xs:integer){

let $teiDoc := $teiEditor:doc-collection/id($docId)
(:let $teiDoc := util:eval( "$teiEditor:doc-collection/id('"||$docId ||"')" ):)


return
for $place at $pos in $teiDoc//tei:sourceDesc/tei:listPlace//tei:place
    let $splitRef := tokenize(data($place/tei:placeName/@ref), " ")
    let $placeUri := 
                        for $uri in $splitRef
                            return
                                  if(contains($uri, $teiEditor:baseUri)) then 
                                       normalize-space($uri[1]) else ()      
    (: let $placeUriInternal := 
                        for $uri in tokenize($splitRef, " ")
                            return 
                                if (contains($uri, $teiEditor:project)) then $uri else ():)
     let $placeRecord:= if($placeUri != "" ) then $teiEditor:projectPlaceCollection//pleiades:Place[@rdf:about = $placeUri] else ()
                                                                         
                                order by $place/tei:placeName
                                return
                                <span class="btn btn-light listItem">
                                <span title="Annotate selected text with reference to {functx:trim(normalize-space($placeRecord[1]//dcterms:title[1]/text()))} ({ $placeUri })"
                                onclick="addPlace({$index}, '{functx:trim(normalize-space(data($place/tei:placeName/string())))}', '{$placeUri}')">{$placeRecord//dcterms:title[1]/text()}</span>
                                </span>

};
                                
declare function teiEditor:placeAnnotatorWithCombo($docId as xs:string){
let $teiDoc := $teiEditor:doc-collection/id($docId)
(:let $teiDoc := util:eval( "$teiEditor:doc-collection/id('"
             ||$docId ||"')" ):)



return
<div>
{teiEditor:listsPlacesAsCombo()}
<button class="inline btn btn-primary btn-xs"
                                                onclick="addPlaceRefToText()">Tag with placeName</button>
                                                </div>                                                        
                                };
                                
declare function teiEditor:listPeople($docId as xs:string, $index as xs:integer){
let $teiDoc := $teiEditor:doc-collection/id($docId)
(:let $teiDoc := util:eval( "$teiEditor:doc-collection/id('"||$docId ||"')" ):)


return
<div id="peopleList" class="itemList">{
        for $person in $teiDoc//tei:listPerson[@type='peopleInDocument']//tei:person
                                order by $person/tei:persName[1]/string()
                                return
                                <span class="btn btn-light listItem">
                                <span title="Annotate selected text with reference to {functx:trim(normalize-space($person/tei:persName[1]/string()))} ({ $person/@corresp })"
                                onclick="addPeople({$index}, '{ $person/@corresp }')">{$person/tei:persName[1]/string()} [{ substring-after($person/@corresp, "/people/") }]</span>
                                </span>
                                }
                                </div>
                                };

declare function teiEditor:annotatePersNames(){
 <div class="sectionInPanel">
                                    <span class="subSectionTitle">Annotate Names</span>


                                     <div class="sectionInPanel panel panel-primary ">
                                     <span class="subSectionTitle">PersName</span>
                                    <div class="insertTagWithDropDown">
                                            <div id="persNameType">{skosThesau:dropDownThesauXML('c19928', 'en', 'Type', 'inline', (), 1, ())}</div>
                            <button class="inline btn btn-primary btn-xs"
                                                onclick="addPersName('', '')">PersName</button>

                                    </div>

                                            <div class="sectionInPanel panel panel-primary ">
                                                    <span class="subSectionTitle">Names</span>
                                                    <div class="input-group">
                                                             <span class="input-group-addon">NymRef</span>


                                                                <input type="text" class="form-control" id="standardizedForm" name="standardizedForm"
                                        placeHolder="Standardized form"/>
                                                            <span class="input-group-addon">
                                                            <button class="inline btn btn-primary btn-xs" title="Copy &amp; paste selected text from editor"
                                                        onclick="pasteSelectedText('', 'standardizedForm')"><i class="glyphicon glyphicon-transfer"/></button>
                                                            </span>
                                                       </div>

                                              <button class="inline btn btn-primary btn-xs"
                                                onclick="addName('', 'name')">Name</button>
                                                <br/>

                                            <button class="inline btn btn-primary btn-xs"
                                                onclick="addName('', 'praenomen')">Praenomen</button>
                                                <button class="inline btn btn-primary btn-xs"
                                                onclick="addName('', 'nomen')">Nomen</button>
                                            <button class="inline btn btn-primary btn-xs"
                                                onclick="addName('', 'cognomen')">Cognomen</button>
                                              <br/>

                                   </div>
                                    </div>
                                </div>


};

declare function teiEditor:xmlFileEditor(){
     let $teiDoc := $teiEditor:doc-collection/id($teiEditor:docId)
    return
    <div>

               <div class="textModifiedAlert" id="fileModifiedAlert">File has been modified</div>
               <button id="saveFileButton" class="saveTextButton btn btn-primary" onclick="saveFile('{$teiEditor:docId}', 1)" appearance="minimal" type="button"><i class="glyphicon glyphicon-floppy-save"></i></button>
               <div id="xml-editor-file" class="">{serialize($teiDoc, ())}</div>
   </div>
};


declare function teiEditor:comboboxThes($thesaurus as xs:string){
<select id="{$teiElementNickname}" name="{$teiElementNickname}">
                    {for $items in $itemList
                    return
                        if ($items/@xml:id = $teiElementValue)
                        then (
                        <option value="#{$items/@xml:id}" selected="selected">{$items/tei:catDesc/string()} </option>)
                        else (
                        <option value="#{$items/@xml:id}">{$items/tei:catDesc/string()} </option>
                        )
                     }
</select>
};

declare function teiEditor:displayFragment($docId as xs:string?){
let $teiDoc := $teiEditor:doc-collection/id($teiEditor:docId)
(:let $teiDoc := util:eval( "$teiEditor:doc-collection/id('"
             ||$docId ||"')" )
:)

return
    <div class="sectionPanel">

    {for $frag at $pos in $teiDoc//tei:msFrag
    let $teiXPath := "/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msFrag"
        return
        <div id="fragment_display_{$pos}" class="teiElement">
        <h5 class="subSectionTitle">Object  {if(count($teiEditor:teiDoc//tei:msFrag) > 1) then $pos else ()}
        <span class="teiInfo">
            <a title="TEI element: {$teiXPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
            </span>
        </h5>
            <div>
           { ""
(:           teiEditor:displayElement('fragProvenance', $docId, $pos, ()) :)
           }
           {"" 
(:           teiEditor:displayElement('fragmentDimensions', $docId, $pos, ()) :)
           }
           { 
           teiEditor:displayElement('msFragmentTown', $docId, $pos, ()) 
           }
            {teiEditor:displayElement('msFragmentRepository', $docId, $pos, ()) }
<!--           teiEditor:displayElement('msFragmentAltIdentifier', $docId, $pos, ())-->
            </div>

           </div>

    }
    </div>
};


declare function teiEditor:displaySurface(){
    <div class="col-sm-3 col-md-3 hidden-xs-down surfaceImage">
    {for $surface in $teiEditor:teiDoc//tei:sourceDoc//tei:surface
        return

        <img src="{$surface//tei:graphic/@url}">
        </img>
    }
    </div>
};





(: CP: removed:  , $project :)
declare function teiEditor:saveData($data, $project ){

let $now := fn:current-dateTime()
let $currentUser := data(sm:id()//sm:username)

(:let $doc-collection := collection($config:data-root || "/" || $teiEditor:project || "/documents"):)

let $contentType := $data//contentType/text()
let $docId := $data//docId/text()

let $index := $data//index/text()

let $xpath := replace($data//xpath/text(), 'tei:', '')
let $xpathEnd := if(contains(functx:substring-after-last($xpath, '/'), "/@") or contains(functx:substring-after-last($xpath, '/'), "self"))
            then(
                functx:substring-after-last(functx:substring-before-last($xpath, '/'), '/')
                )
            else
            (functx:substring-after-last($xpath, '/')
            )
let $xpathEndNoSelector :=if(contains($xpathEnd, "["))
        then substring-before($xpathEnd, '[')
        else $xpathEnd 
        
        
let $xpathEndSelector := if(contains($xpathEnd, "[@")) then
                    substring-before(substring-after($xpathEnd, '[@'), ']') else ""
let $xpathEndSelectorName :=
                    substring-before($xpathEndSelector, '=')
let $xpathEndSelectorValue :=
                    substring-before(substring-after($xpathEndSelector, '="'), '"')

let $endingSelector := if(contains(functx:substring-after-last($xpath, '/'), "@"))
            then(
                functx:substring-after-last($xpath, '/@')
                )
            else
            (
            )

(:let $docId := request:get-parameter('docid', ()):)
(:let $teiDoc := $teiEditor:doc-collection/id($docId):)
let $paramMap :=
        map {
            "method": "xml",
            "indent": false(),
            "item-separator": ""}
let $updatedData := if($data//value/text())
                then ($data//value)
                    else " "


let $newElement := if($contentType = "text") then
                if(contains(functx:substring-after-last($xpath, '/'), "@")) then(
                    <newElement>{element {string($xpathEndNoSelector)}
                    
                        {attribute {string($xpathEndSelectorName)} {$xpathEndSelectorValue }, functx:trim($data//value/node())
                      }}</newElement>
                     )
                     
                    else(
                        <newElement>{
                            element {string($xpathEndNoSelector)}
                            
                            { 
(:                            functx:trim(
:)
                            
                            $data//value/node()
(:                            ):)
                            }
                              }</newElement>)


            else ""



let $updatedDataTextValue := $data//valueTxt/text()


let $xpathWithTeiPrefix := 

if(contains($data//xpath/text(), "/@"))
                                          then
                                          $data//xpath/text()
(:                                          substring-before($data//xpath/text(), '/@') || '[' || $index || ']/' || functx:substring-after-last($data//xpath/text(), '/'):)
                                          else
                                          $data//xpath/text() 
(:                                          || '[' || $index || ']':)

(:if($index = 0) then $data//xpath/text()
                                          else if ($index >= 1) then
                                          $data//xpath/text() || '[' || $index || ']'
(\:                                            substring-before($data//xpath/text(), '/@') || "[" || $index || "]/" || functx:substring-after-last($data//xpath/text(), '/'):\)
                                          else ( $data//xpath/text() )
:)
let $quote := "&amp;quote;"
(:let $xpathWithTeiPrefix := replace($xpathWithTeiPrefix, $quote, '"') :)




        (:let $nodesArray := tokenize($xpath, '/')
        let $lastNode := $nodesArray[last()]:)

(:let $log := teiEditor:logEvent("test-before-updateData", $docId, (), <data>
$index {$index}
$contentType: {$contentType};
$updatedDataTextValue: {$updatedDataTextValue}
$updatedData: {$updatedData}
$docId: {$docId}
$teiEditor:doc-collection-path : {$teiEditor:doc-collection-path }
$xpathWithTeiPrefix: { $xpathWithTeiPrefix}
replace($xpathWithTeiPrefix, '[1]', "") {replace($xpathWithTeiPrefix, "\[1\]", "") }
$endingSelector: { $endingSelector }
OriginalNode : {util:eval( "$teiEditor:doc-collection/id('"
             ||$docId ||"')" || $xpathWithTeiPrefix)}
 $xpathWithTeiPrefix {$xpathWithTeiPrefix}
 $newElement: {$newElement}
 $xpathEndNoSelector: { $xpathEndNoSelector } | {string($xpathEndNoSelector)}
$xpathEndSelectorName: {$xpathEndSelectorName}
 functx:trim($data//value/node()): <node>{  serialize($data//value/node(), $paramMap) }</node>
</data>):)

let $originalTEINode :=util:eval( "$teiEditor:doc-collection/id('"
             ||$docId ||"')" || $xpathWithTeiPrefix)


let $oldValueTxt := data($originalTEINode)

let $originalTEINodeWithoutAttribute := 
            if(contains($xpathWithTeiPrefix, '/@')) then util:eval( "collection('" || $teiEditor:doc-collection-path ||"')/id('"
             ||$docId ||"')/" || functx:substring-before-last($xpathWithTeiPrefix, '/') )
             else (util:eval( "collection('" || $teiEditor:doc-collection-path ||"')/id('"
             ||$docId ||"')" || $xpathWithTeiPrefix ))

(:let $originalTEINodeWithoutAttribute := 
            if(contains($xpathWithTeiPrefix, '/@')) then util:eval( "collection('" || $teiEditor:doc-collection-path ||"')/id('"
             ||$docId ||"')/" || functx:substring-before-last($xpath, '/') )
             else (util:eval( "collection('" || $teiEditor:doc-collection-path ||"')/id('"
             ||$docId ||"')" || $xpath )):)

(:            let $updatedNode :=  <updatedNode  xmlns="http://www.tei-c.org/ns/1.0">{parse-xml('<' || $lastNode || ">" || $updatedData|| '</' || $lastNode || '>')}</updatedNode>        :)
(:let $updatedTEINode :=  <updatedNode>{parse-xml('<' || $lastNode || ">" || $updatedData|| '</' || $lastNode || '>')}</updatedNode>:)

(:let $updatedTEINode := functx:change-element-ns-deep($updatedNode, 'http://www.tei-c.org/ns/1.0', ''):)

(:let $logs := collection($config:data-root || $teiEditor:project || "/logs"):)

(:let $updateXml := update insert $aaa/node() following $originalTEINode :)

let $elementNickname := $data//elementNickname/text()


let $upateData :=
        switch ($contentType)

         case "textNodeAndAttribute" return
                (
                    (if( exists($originalTEINode)) then update value $originalTEINode with $updatedData
                    else
                    update insert attribute ref { functx:trim($data//value/node()) } into $originalTEINodeWithoutAttribute,
                    update value $originalTEINode with $updatedData),
                update value $originalTEINodeWithoutAttribute with $updatedDataTextValue
                )
         case "attribute" return
                update value $originalTEINode with data($updatedData)
         case "text"  return
                    if($updatedData = " ") then update value $originalTEINodeWithoutAttribute/text() with $updatedData
                    else  update value $originalTEINodeWithoutAttribute with $updatedData/text()
(:                        update replace $originalTEINode with functx:change-element-ns-deep($newElement, "http://www.tei-c.org/ns/1.0", "")/node():)
         case "enrichedText"  return
                    if($updatedData = " ") then update value
                    $originalTEINodeWithoutAttribute/text() with $updatedData
                    else  update value $originalTEINodeWithoutAttribute with $updatedData/*[local-name()='p']/node()
        case "nodes" return
                update value $originalTEINode with $updatedData/node()
         default return
                update replace $originalTEINode with functx:change-element-ns-deep($newElement, "http://www.tei-c.org/ns/1.0", "")
(:            update replace $originalTEINode/node() with $updatedData/node():)

(:let $newContent := util:eval( "$teiEditor:doc-collection/id('"
             ||$docId ||"')" ):)
let $newContent := $teiEditor:doc-collection/id($docId)             

(:let $log := teiEditor:logEvent("test-before-new-Element", $docId, (), <data>

</data>):)
let $elementNode := if (not(exists($teiEditor:teiElementsCustom//teiElement[nm=$elementNickname]))) 
    then $teiEditor:teiElements//teiElement[nm=$elementNickname] 
                        else $teiEditor:teiElementsCustom//teiElement[nm=$elementNickname]
let $elementNickname4update := if($elementNode/ancestor::teiElement[1]/fieldType/text() = "group")
                                                    then $elementNode/ancestor::teiElement[1]/nm/text()
                                                    else $elementNickname
 let $index4Update:= if($elementNode/ancestor::teiElement[1]/fieldType/text() = "group")
                                                    then ()
                                                    else 
                                                    (
                                                    if( $index="") then "1" else $index)
let $xpath4Update:= if($elementNode/ancestor::teiElement[1]/fieldType/text() = "group")
                                                    then $elementNode/ancestor::teiElement[1]/xpath/text()
                                                    else 
                                                    (
                                                    )


let $updatedElement := if($elementNode/ancestor::teiElement[1]/fieldType/text() = "group")
                                                    then 
                                                    teiEditor:displayGroup($elementNickname4update, $docId, $index4Update, (), $xpath4Update)
                                                    else 
                                                    teiEditor:displayElement($elementNickname4update, $docId, $index4Update, $xpath4Update)

let $log := teiEditor:logEvent("document-update" ||$index, $docId,
    (), "Change in " || $docId ||
    " $elementNickname: " || $elementNickname ||
    " $elementNickname4update: " || $elementNickname4update ||
    " $xpathWithTeiPrefix: " || $xpathWithTeiPrefix ||
    " $xpath: " || $xpath ||
    " index: " || $index ||
    " $index4Update: " || $index4Update || "END$index4Update"||
    "; $contentType: " || $contentType || "; New element: " || $newElement
    )



    return
<http:response status="200"> 
                    <http:header name="Cache-Control" value="no-cache"/> 
                    <http:header name="TESTUM" value="no-cache"/>
                    <data>{$data}
    <oldContent>{ $oldValueTxt }</oldContent>
    <newContent>{ $newContent }</newContent>
    <updatedElement>{ $updatedElement }</updatedElement>

</data>

                </http:response> 


};

declare function teiEditor:saveText($data, $project){
let $now := fn:current-dateTime()
let $currentUser := sm:id()//sm:real/sm:username
(:let $currentUser := 

                            if(count($currentUser//sm:real) > 1) then 
                            for $user at $pos in $currentUser
                            return
                                if (contains($user//sm:username, 'admin'))
                                then ()
                                else(data($user[1]//sm:username[1]) || $pos)
                            
                            else $currentUser :)

let $currentUserUri := concat($teiEditor:baseUri[1], '/people/' , $currentUser)
(:let $doc-collection := collection($config:data-root || $teiEditor:project || "/documents"):)


let $docId := $data//docId/text()
(:let $docId := request:get-parameter('docid', ()):)
(:let $teiDoc := $teiEditor:doc-collection//id($docId):)
let $teiDoc := util:eval( "$teiEditor:doc-collection/id('"
             ||$docId ||"')")


let $elementNickname :=
if (exists($teiDoc//tei:div[@type="edition"]//tei:div[@type="textpart"])) then ('docTextsMultiple')
                    else  ('docTextSingles')

let $elementNode := $teiEditor:teiElements//teiElement[nm=$elementNickname]
let $teiXPath := $teiEditor:teiElements//teiElement[nm=$elementNickname]/xpath/text()
let $index := data($data//index)


let $newText := functx:change-element-ns-deep(<ab>{$data//newText/node()}</ab>, 'http://www.tei-c.org/ns/1.0', '')


let $abNode2beReplaced := if(exists(util:eval( "collection('" || $teiEditor:doc-collection-path ||"')/id('"
             ||$docId || "')//tei:div[@type='textpart'][" || $index || "]/tei:ab")))
        
                                                        then (util:eval( "collection('" || $teiEditor:doc-collection-path ||"')/id('"
             ||$docId || "')//tei:div[@type='textpart'][" || $index || "]/tei:ab"))
                                                 else if (exists($teiDoc//tei:div[@type='edition']/tei:ab))
                                                 then ($teiDoc//tei:div[@type='edition']/tei:ab)
                                                 else()


(:BEFORE fixing index problem:)
(:let $abNode2beReplaced := if(exists($teiDoc//tei:div[@type='textpart'][" || $index || "]/tei:ab))
        
                                                        then ($teiDoc//tei:div[@type='textpart'][" || $index || "]/tei:ab)
                                                 else if (exists($teiDoc//tei:div[@type='edition']/tei:ab))
                                                 then ($teiDoc//tei:div[@type='edition']/tei:ab)
                                                 else()
:)

(:
util:eval( "collection('" || $teiEditor:doc-collection-path ||"')/id('"
             ||$docId || "')//tei:div[@type='textpart'][" || $index || "]/tei:ab")
:)
(:            let $updatedNode :=  <updatedNode  xmlns="http://www.tei-c.org/ns/1.0">{parse-xml('<' || $lastNode || ">" || $updatedData|| '</' || $lastNode || '>')}</updatedNode>        :)
(:let $updatedTEINode :=  <updatedNode>{parse-xml('<' || $lastNode || ">" || $updatedData|| '</' || $lastNode || '>')}</updatedNode>:)

(:let $updatedTEINode := functx:change-element-ns-deep($updatedNode, 'http://www.tei-c.org/ns/1.0', ''):)

(:let $logs := collection($config:data-root || $teiEditor:project || "/logs"):)

(:let $updateXml := update insert $aaa/node() following $originalTEINode :)

let $logTest := teiEditor:logEvent("test" , "", (),
                        "$abNode2beReplaced: " || serialize($abNode2beReplaced, ())
                        ||
                        "$newText: " || $newText
                        )




let $updateXml :=if (not(exists($teiDoc//tei:div[@type="edition"]//tei:div[@type="textpart"]))) 
                    then (
(:                    update replace $teiDoc//tei:div[@type="edition"][$index]/tei:ab with $newText:)
                    )
                    else if (exists($teiDoc//tei:body/tei:div[@type="edition"]/tei:div[@type="textpart"][string($index)])) then(
                    update replace $abNode2beReplaced with $newText
(:                        update replace $teiDoc//tei:div[@type='textpart'][string($index)]/tei:ab with $newText:)
                    )
                    else(update replace $abNode2beReplaced with $newText)
let $teiDoc := util:eval( "$teiEditor:doc-collection/id('"
             ||$docId ||"')")

let $changeNode := <node>
           <change when="{$teiEditor:now}" who="{$currentUserUri}">{$data//comment/text()}</change></node>
let $insertRevisionChange := if($teiDoc//tei:revisionDesc/tei:listChange/tei:change) then
                            update insert
                            ('&#xD;&#xa;',
                            functx:change-element-ns-deep($changeNode, "http://www.tei-c.org/ns/1.0", "")/node())
                              following $teiDoc//tei:revisionDesc/tei:listChange/tei:change[last()]
                            else update insert
                                functx:change-element-ns-deep($changeNode, "http://www.tei-c.org/ns/1.0", "")/node()
                                into $teiDoc//tei:revisionDesc/tei:listChange

(:

let $logInjection :=
    update insert
    <apc:log type="document-update-text-{$index}" when="{$now}" what="{data($data/xml/docId)}" who="{$currentUser}">
        {$data}
        <docId>{$docId}</docId>
        <!--<lastNode>{$lastNode}</lastNode>
        -->
        <!--<origNode2>{$originalTEINode}</origNode2>
        -->
      <index>{$index}</index>
        <updatedData>{$newText}</updatedData>

    </apc:log>
    into $teiEditor:logs/id('all-logs')
    :)


(:let $save := teiEditor:saveData(string($data/xml/docId), string($data/xml/input), string($updatedData)):)
let $log := teiEditor:logEvent("document-update-text-" ||$index, $docId, $data, "" || exists($teiDoc//tei:div[@type="edition"]//tei:div[@type="textpart"]))
let $newContent := util:eval( "$teiEditor:doc-collection/id('"
             ||$docId ||"')" )

return

<data>
<newContent>{ $newContent}</newContent>
</data>


};


declare function teiEditor:saveTextarea($data, $project){
let $now := fn:current-dateTime()
let $currentUser := sm:id()//sm:real/sm:username

let $currentUserUri := concat($teiEditor:baseUri[1], '/people/' , $currentUser)

let $docId := $data//docId/text()
let $teiDoc := util:eval( "$teiEditor:doc-collection/id('"||$docId ||"')")

let $elementNickname :=
            $data//elementNickName/text()
let $elementNode :=if (not(exists($teiEditor:teiElementsCustom//teiElement[nm=$elementNickname]))) 
                                        then $teiEditor:teiElements//teiElement[nm=$elementNickname] 
                                        else $teiEditor:teiElementsCustom//teiElement[nm=$elementNickname]

let $xpath :=  $data//xpath/text()
let $index := data($data//index)


let $newText := $data//newText 
(:functx:change-element-ns-deep(<ab>{$data//newText/node()}</ab>, 'http://www.tei-c.org/ns/1.0', ''):)



let $originalTEINodeWithoutAttribute := 
            if(contains($xpath, '/@')) then util:eval( "collection('" || $teiEditor:doc-collection-path ||"')/id('"
             ||$docId ||"')/" || functx:substring-before-last($xpath, '/') )
             else (util:eval( "collection('" || $teiEditor:doc-collection-path ||"')/id('"
             ||$docId ||"')" || $xpath ))

let $updateXml :=
            if($newText = " " or $newText = "")
                then update value $originalTEINodeWithoutAttribute/text() with $newText
           (: else  if ($newText/*[local-name()='p']) then update value $originalTEINodeWithoutAttribute 
                    with functx:change-element-ns-deep($newText/*[local-name()='p']/node(), "", ""):)
           else update value $originalTEINodeWithoutAttribute 
                    with functx:change-element-ns-deep($newText/node(), "http://www.tei-c.org/ns/1.0", "")
let $log := teiEditor:logEvent("document-update-" ||$index, $docId, $data, $xpath )

let $newContent := util:eval( "$teiEditor:doc-collection/id('"
             ||$docId ||"')" )

return

<data>{$data}
<originalTEINodeWithoutAttribute>{ serialize( $originalTEINodeWithoutAttribute ) }</originalTEINodeWithoutAttribute> 
<newContent>{ $newContent}</newContent>
</data>


};


declare function teiEditor:saveFile($data, $project){

let $docId := $data//docId/text()
(:let $teiDoc := $teiEditor:doc-collection//id($docId):)

let $teiDoc := util:eval( "$teiEditor:doc-collection/id('"
             ||$docId ||"')")

let $newContent := functx:change-element-ns-deep(<teiFile>{$data//newContent/node()}</teiFile>, 'http://www.tei-c.org/ns/1.0', '')
(:let $newContent := $data//newContent//TEI/node():)
let $originalFile :=util:eval( "collection('" || $teiEditor:doc-collection-path ||"')/id('"
             ||$docId || "')")

let $updateHeader := update replace $teiDoc//tei:teiHeader with $newContent//tei:teiHeader
let $updateText := update replace $teiDoc//tei:text with $newContent//tei:text
let $updateSourceDoc := if($teiDoc//tei:SourceDoc) then update replace $teiDoc//tei:SourceDoc with $newContent//tei:sourceDoc else()
let $updateFacSim := if($teiDoc//tei:facsimile) then update replace $teiDoc//tei:facsimile with $newContent//tei:facsimile else()

(:let $updateXml :=   update replace $teiDoc//tei:TEI/node() with $newContent/././././node():)
return


teiEditor:logEvent('document-saveXmlFile', $docId, <originalData>{$originalFile}</originalData>, ''),
<data>{$data}</data>

};

declare function teiEditor:addData( $data as node(), $project as xs:string){

    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)

    (:let $data := request:get-data():)
(:    let $doc-collection := collection($config:data-root || $teiEditor:project || "/documents"):)

    let $docId := $data//docId/text()
    let $topConceptId := $data//topConceptId/text()
    let $xpath := replace($data//xpath/text(), 'tei:', '')
    let $lang := $data//lang/text()

    (:let $docId := request:get-parameter('docid', ()):)
    let $teiDoc := $teiEditor:doc-collection/id($docId)
    let $xpathEnd := if(contains(functx:substring-after-last($xpath, '/'), "@"))
            then(
                functx:substring-after-last(functx:substring-before-last($xpath, '/'), '/')
                )
            else
            (functx:substring-after-last($xpath, '/')
            )
    let $endingSelector := if(contains(functx:substring-after-last($xpath, '/'), "@"))
            then(
                functx:substring-after-last($xpath, '/@')
                )
            else
            (
            )
    let $xpathInsertLocation :=
                if(contains(functx:substring-after-last($data//xpath/text(), '/'), "@"))
(:                 if xpath is ending with \@, this must be removed:)
                    then(
                      if(util:eval( "collection('" || $teiEditor:doc-collection-path ||"')//id('"
                             || $docId ||"')" || $data//xpath/text()) )
(:                             If there is already one node with same xpath, then location is last:)
                             then (
                               functx:substring-before-last($data//xpath/text(), '/') || '[last()]'
                                )
                          else(functx:substring-before-last(functx:substring-before-last($data//xpath/text(), '/'), '/'))
                        )
                    else
                    (
                    $data//xpath/text()
(:                    functx:substring-before-last($data//xpath/text(), '/'):)
                    )

  let $insertLocationElement :=
    (: If same element exists, then location is the last existing element, otherwise location is parent node :)
    if(util:eval( "collection('" || $teiEditor:doc-collection-path ||"')/id('"
           || $docId ||"')" || $data//xpath/text()) )
           then (
             util:eval( "collection('" || $teiEditor:doc-collection-path ||"')/id('"
                    || $docId ||"')" || $xpathInsertLocation)
         )
         else(

                util:eval( "collection('" || $teiEditor:doc-collection-path ||"')/id('"
                || $docId ||"')" ||

                $xpathInsertLocation
              ))




    let $newElement :=
      if(contains(functx:substring-after-last($xpath, '/'), "@"))
              then(<newElement>
                      {element {string($xpathEnd)}
                      {attribute {string($endingSelector)} {$data//value/text() },
                                 if($lang and $lang!= "undefined") then attribute xml:lang {$lang} else (),
                       functx:trim($data//valueTxt/text())


          }}</newElement>
          )
        else(<newElement>
        {
          element {string($xpathEnd)}
               {attribute xml:lang {$lang},
               $data//valueTxt/text()
                }
            }</newElement>
        )


      let $log := teiEditor:logEvent("test-before-insertNewElement", $docId, (),
        <result>

             {exists(util:eval( "collection('" || $teiEditor:doc-collection-path ||"')/id('"
                   || $docId ||"')" || $data//xpath/text()))}
            $data//xpath/text(){ $data//xpath/text()}
            $insertLocationElement::: {$insertLocationElement}
            $xpathInsertLocation::: {$xpathInsertLocation}
            Exist? {exists(util:eval( "collection('" || $teiEditor:doc-collection-path ||"')/id('"
           || $docId ||"')" || $data//xpath/text()) )}
           Ending selector : { $endingSelector }
           $newElement: {serialize($newElement)}
        </result>
)



      let $insertNewElement :=
            if(util:eval( "collection('" || $teiEditor:doc-collection-path ||"')/id('"
                   || $docId ||"')" || $data//xpath/text()) )
                   then (
                     update insert
                     ('&#xD;&#xa;',
                     functx:change-element-ns-deep($newElement, "http://www.tei-c.org/ns/1.0", "")/node())
(:                     following $insertLocationElement:)
                     following $insertLocationElement
                   )
            else(
            update insert functx:change-element-ns-deep($newElement, "http://www.tei-c.org/ns/1.0", "")/node() into $insertLocationElement
            )

    let $insertLog :=
      update insert
      <log type="document-add-data" when="{$now}" what="{data($data/xml/docId)}" who="{$currentUser}">aa{$newElement}
      <nm>sd{$data/xml/teiElementNickname/text()}</nm>
      <xpath>{$data//xpath/text()}</xpath>
      <inserrtLoc>{$xpathInsertLocation}</inserrtLoc>
      <insertLocationElement>{ $insertLocationElement }</insertLocationElement>
      </log> into $teiEditor:logs/id('all-logs')


    (:let $updateXml := update value $originalTEINode with $updatedData:)




    (:let $save := teiEditor:saveData(string($data/xml/docId), string($data/xml/input), string($updatedData)):)

return
teiEditor:displayElement( $data/xml/teiElementNickname/text(),$docId,  (), ())
};

declare function teiEditor:addGroupData( $data as node(), $project as xs:string){

    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)
    let $teiElementNickname := $data//teiElementNickname/text()
    let $elementNode := if (not(exists($teiEditor:teiElementsCustom//teiElement[nm=$teiElementNickname]))) 
                                        then $teiEditor:teiElements//teiElement[nm=$teiElementNickname] 
                                        else $teiEditor:teiElementsCustom//teiElement[nm=$teiElementNickname]
    (:let $data := request:get-data():)
(:    let $doc-collection := collection($config:data-root || $teiEditor:project || "/documents"):)

    let $docId := $data//docId/text()
    let $topConceptId := $data//topConceptId/text()
    let $xpath := replace($data//xpath/text(), 'tei:', '')
    let $dataTemplate := serialize($elementNode/template)
    (:let $updateTemplate :=
        for $item in $data//groupItem
            let $template := $dataTemplate
            let $element := "\$" || data($item/@teiElement)
            let $value := $item/text()
            let $updatedData := teiEditor:replaceData($dataTemplate, $element, $value)
                return
            $updatedData:)
    
    let $variables :=
        for $item in $data//groupItem
            
                return
             "\$" || data($item/@teiElement)
    let $values :=
        for $item in $data//groupItem
            return
             $item/text()
    let $node2insert := parse-xml(functx:replace-multi($dataTemplate, $variables, $values))
    let $xpath := functx:substring-before-last($elementNode/xpath, '/')
    let $insertNode := update insert functx:change-element-ns-deep($node2insert/template, "http://www.tei-c.org/ns/1.0", "")/node() into util:eval( "$teiEditor:doc-collection/id('" ||$docId ||"')/" || $xpath)

return 
<data>
<dataTemplate>{$dataTemplate}</dataTemplate>
<node2insert>{ $node2insert }</node2insert>
<updatedElement>
{teiEditor:displayGroup($teiElementNickname, $docId, (), (), ())}</updatedElement>
</data>

};


declare function teiEditor:addBiblio( $data as node(), $project as xs:string){

    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)

    (:let $data := request:get-data():)
(:    let $doc-collection := collection($config:data-root || $teiEditor:project || "/documents"):)

    let $docId := $data//docId/text()
    (:let $docId := request:get-parameter('docid', ()):)
    let $teiDoc := $teiEditor:doc-collection/id($docId)
    let $teiDoc := util:eval( "$teiEditor:doc-collection/id('"||$docId ||"')")

    let $bibRef := $data//biblioId/text()
    let $typeRef := $data//type/text()
    let $citedRange := $data//citedRange/text()
    let $calculatedCitedRange := if($citedRange != '') then 
                            <citedRange>{$citedRange}</citedRange>
                            else ()
    let $zoteroGroup := $data//zoteroGroup/text()
    let $xpath :=
    switch ($typeRef)
       case "main"
       case "edition" return
                '//tei:div[@type="bibliography"][@subtype="edition"]/tei:listBibl'
       case "secondary" return
                '//tei:div[@type="bibliography"][@subtype="secondary"]/tei:listBibl'

       default return null


            (:let $nodesArray := tokenize($xpath, '/')
            let $lastNode := $nodesArray[last()]:)
(:    let $BibRefAsTei := zoteroPlugin:get-bibItem($zoteroGroup, $bibRef, "tei"):)
    let $BibRefAsTei := functx:change-element-ns-deep(zoteroPlugin:get-bibItem($zoteroGroup, $bibRef, "tei")
                                            , 'http://www.tei-c.org/ns/1.0', 'tei')

    let $bibTeiId := data($BibRefAsTei//tei:biblStruct/@xml:id)
    let $bibUri := data($BibRefAsTei//tei:biblStruct/@corresp)
    let $bibTeiIdRef := if ($bibUri != "") then $bibUri else concat("#", $bibTeiId)





    (:let $originalTEINode :=util:eval( "collection('/db/apps/" || $saveFunctions:project || "/data/documents')//id('"
                 ||$docId ||"')/" || $xpathWithTeiPrefix)
    :)



    (:insert new reference in main bibliography:)
    let $insertBiblioInBiblioRepo :=
        if ($teiEditor:biblioRepo//tei:biblStruct[@corresp = $bibUri])
            then (update replace $teiEditor:biblioRepo//tei:biblStruct[@corresp = $bibUri] with $BibRefAsTei//tei:biblStruct)
            else(
                   update insert $BibRefAsTei//tei:biblStruct into $teiEditor:biblioRepo//tei:listBibl[@xml:id="mainBiblio"]
            )


(:let $insertLocationElementInDoc :=         util:eval( "collection('" || $teiEditor:doc-collection-path ||"')/id('"
                || $docId ||"')" || '//tei:div[@type="bibliography"][@subtype="edition"]/tei:listBibl'  )

:)


    let $insertBiblioInTeiDocument :=
        switch ($typeRef)
           case "main" 
           case "edition" return
           let $biblNode := <bibl xmlns="http://www.tei-c.org/ns/1.0">
                                 <ptr target="{$bibTeiIdRef}" />,
                                 <citedRange>{$citedRange}</citedRange>
                             </bibl>
                          return
                          update insert $biblNode into
                          $teiDoc//tei:div[@type="bibliography"][@subtype="edition"]/tei:listBibl
                          
 (:                  if (not(exists($teiDoc//tei:div[@type="bibliography"][@subtype="edition"]//tei:ptr[@target =  $bibTeiIdRef])))
                        then (
                        let $biblNode := <bibl xmlns="http://www.tei-c.org/ns/1.0">
                                 <ptr target="{$bibTeiIdRef}" />,
                                 <citedRange>{$citedRange}</citedRange>
                             </bibl>
                          return
                          update insert $biblNode into
                          $teiDoc//tei:div[@type="bibliography"][@subtype="edition"]/tei:listBibl
                        )
                        
                   else()
:)
           case "secondary" return
                   (: //tei:div[@type="bibliography"][@subtype="secondary"]/tei:listBibl:)
                   if (not(exists($teiDoc//tei:div[@type="bibliography"][@subtype="seconday"]//tei:ptr[@target =  $bibTeiIdRef])))
                        then (
                        let $biblNode := <bibl xmlns="http://www.tei-c.org/ns/1.0">
                                 <ptr target="{$bibTeiIdRef}"/>,
                                 <citedRange>{$citedRange}</citedRange>
                             </bibl>
                          return
                          update insert $biblNode into
                          $teiDoc//tei:div[@type="bibliography"][@subtype="secondary"]/tei:listBibl
                        )
                        
                   else()

           default return "ERROR!"
(:    let $logs := collection($config:data-root || $teiEditor:project || "/logs"):)



    (:let $updateXml := update value $originalTEINode with $updatedData:)

let $newContent := util:eval( "$teiEditor:doc-collection/id('"
             ||$docId ||"')" )

let $newBiblList :=  <div>
        
        {
        (:for $bibRef in  util:eval( "$teiEditor:doc-collection/id('"
             ||$docId ||"')" )//tei:text/tei:body/tei:div[@type='bibliography'][@subtype='edition']/tei:listBibl//tei:bibl:)
          if ($typeRef ="edition") then
             for $bibRef at $pos in  util:eval( "$teiEditor:doc-collection/id('"
             ||$docId ||"')//tei:text/tei:body" || $xpath || "//tei:bibl" )
           
                return
            teiEditor:displayBibRef($docId, $bibRef, $typeRef, $pos)
          else
          
             for $bibRef at $pos in  util:eval( "$teiEditor:doc-collection/id('"
                       ||$docId ||"')//tei:text/tei:body" || $xpath || "//tei:bibl" )
                  order by $bibRef//tei:ptr/@target 
                  return
                      teiEditor:displayBibRef($docId, $bibRef, $typeRef, $pos)
          
          }
           </div>



    let $logInjection :=
        update insert
        <apc:log type="document-update-add-biblio" when="{$now}" what="{data($data/xml/docId)}" who="{$currentUser}">
            {$data}
            <docId>{$docId}</docId>
            <!--<lastNode>{$lastNode}</lastNode>
            -->
            <origNode2>$originalTEINode</origNode2>
            <bibType>{$typeRef}</bibType>

            <teiBibRef>{$teiEditor:zoteroGroup} - {$BibRefAsTei//tei:biblStruct}</teiBibRef>
        </apc:log>
        into $teiEditor:logs/id('all-logs')

    (:let $save := teiEditor:saveData(string($data/xml/docId), string($data/xml/input), string($updatedData)):)

return
        <data>
        <newBiblList>
 { switch($typeRef)
     case "main"
     case "edition"
     case "secondary" return
        $newBiblList
(:     teiEditor:principalBibliography( $docId ) :)
     default return 
(:     teiEditor:principalBibliography( $docId ) :)
     for $bibRef at $pos in $teiDoc//tei:text/tei:body/tei:div[@type='bibliography'][@subtype='edition']/tei:listBibl//tei:bibl
        order by $bibRef//tei:ptr/@target
        return
            teiEditor:displayBibRef($docId, $bibRef, $typeRef, $pos)
           
     }
       </newBiblList>
       <newContent>{ $newContent}</newContent>
        </data>
};

declare function teiEditor:createAndAddPersonToDoc( $data as node(), $project as xs:string){

let $now := fn:current-dateTime()
let $currentUser := data(sm:id()//sm:username)

(:let $data := request:get-data():)
(:let $doc-collection := collection($config:data-root || $teiEditor:project || "/documents"):)

let $docId := $data//docId/text()
(:let $docId := request:get-parameter('docid', ()):)
let $teiDoc := $teiEditor:doc-collection/id($docId)

let $idPrefix := $teiEditor:appVariables//idPrefix[@type='people']/text()

let $idList := for $id in $teiEditor:peopleRepo//.[contains(./@xml:id, $idPrefix)]
        return
        <item>
        {substring-after($id/@xml:id, $idPrefix)}
        </item>

let $last-id:= fn:max($idList)
let $newId := $idPrefix || fn:sum(($last-id, 1))
let $newUri := $teiEditor:baseUri|| "/apc/people/" || $newId


let $personRef :=
    <nodeToInsert>
        <person corresp="{$newUri}"/>
    </nodeToInsert>
let $personRecord :=
    <nodeToInsert>
        <person rdf:about="{$newUri}" xml:id="{$newId}" sex="">
            {for $names at $pos in $data//persName[text()]
            return
            (<persName type="{data($names/@type)}">{$names/text()}</persName>,
            if($pos < count($data//persName[text()])) then ('&#xD;&#xa;') else())}
        <dct:created>{$now}</dct:created>
        </person>
    </nodeToInsert>

(:let $addSex := if($data//sex[string()]) then (functx:add-attributes($personRecord/self, xs:QName('sex'),
   $data//sex))
                else():)

(:insert new reference in main bibliography:)
(:let $insertPeopleInRepo :=
    if ($teiEditor:biblioRepo//tei:biblStruct[@xml:id = $bibTeiId]) then ()
    else(
               update insert $BibRefAsTei//tei:biblStruct into $teiEditor:biblioRepo//.[@xml:id="mainBiblio"]
        )
:)

let $insertRefToPeopleInTeiDocument :=
    if($teiDoc//tei:listPerson[@type="peopleInDocument"]//tei:person[@corresp=$newUri]) then()
    else(
            if($teiDoc//tei:profileDesc/tei:particDesc/tei:listPerson[@type="peopleInDocument"]//tei:person) then(
            update insert ('&#xD;&#xa;',
                functx:change-element-ns-deep($personRef, "http://www.tei-c.org/ns/1.0", "")/node())
                    following
                 $teiDoc//tei:profileDesc/tei:particDesc/tei:listPerson[@type="peopleInDocument"]//tei:person[last()]
            )
            else(
             update insert functx:change-element-ns-deep($personRef, "http://www.tei-c.org/ns/1.0", "")/node() into
                 $teiDoc//tei:profileDesc/tei:particDesc/tei:listPerson[@type="peopleInDocument"]
                 )
                 )

let $createPersonInPeopleRep :=
             update insert $personRecord/node() into
                 $teiEditor:peopleRepo//.[@type="ancientPeople"]



(:let $logs := collection($config:data-root || $teiEditor:project || "/logs"):)



(:let $updateXml := update value $originalTEINode with $updatedData:)





let $logInjection :=
    update insert
    <apc:log type="document-update-add-person" when="{$now}" what="{data($data/xml/docId)}" who="{$currentUser}">

        {$personRecord}
    </apc:log>
    into $teiEditor:logs/id('all-logs')

(:let $save := teiEditor:saveData(string($data/xml/docId), string($data/xml/input), string($updatedData)):)

return

<div>
                        {
                                for $people in $teiDoc//tei:listPerson[@type="peopleInDocument"]/tei:person
                                    let $personUri := data($people/@corresp)
                                    let $personId := functx:substring-after-last($personUri, '/')
                                    let $personRecord := $teiEditor:peopleRepo/id($personId)
                                    let $names := string-join($personRecord//persName, ' ')
(:                                order by $personRecord/persName:)

                                return
                                <span class="btn btn-light listItem">

                                <span title="Annotate selected text with reference to {functx:trim(normalize-space($names))}"
                                onclick="addPeople({$data//index}, '{functx:trim(normalize-space(data($personUri)))}')">
                                {$names}</span>
                                </span>
                                }
                                </div>

};

declare function teiEditor:addPlaceToDoc( $data as node(), $project as xs:string){
(: FUNCTION CAN BE DISCARDED :)
let $now := fn:current-dateTime()
let $currentUser := data(sm:id()//sm:real//sm:username)

(:let $data := request:get-data():)
(:let $doc-collection := collection($config:data-root || $teiEditor:project || "/documents"):)

let $docId := $data//docId/text()
(:let $docId := request:get-parameter('docid', ()):)
let $teiDoc := $teiEditor:doc-collection/id($docId)
let $placeCollection := collection($teiEditor:data-repository-path || "/places")
let $placeCollectionProject := collection($teiEditor:data-repository-path|| "/places/" || $project)
let $placeIdPrefix := doc("/db/apps/" || $teiEditor:project || "/data/app-general-parameters.xml")//idPrefix[@type='place']/text()
let $uriBase := doc("/db/apps/" || $teiEditor:project  || "/data/app-general-parameters.xml")//uriBase[@type='app']/text()
let $placeNumberList := for $place in $placeCollectionProject//pleiades:Place[contains(./@rdf:about, $uriBase)]
        return
        <item>
        {functx:substring-after-last($place/@rdf:about, "/" )}
        </item>

let $last-id:= fn:max($placeNumberList)
let $newId := $placeIdPrefix || fn:sum(($last-id, 1))
let $newUri := $teiEditor:baseUri|| "/" || "places" || "/" || fn:sum(($last-id, 1))


let $placeUri := $data//placeUri/text()
let $sourceUri := substring-before(substring-after($placeUri, '//'), '/')


let $url4httpRequest := switch ($sourceUri)
                                    case "pleiades.stoa.org"
                                    case "vici.org" return $placeUri || "/rdf"

                                    case "gazetteer.dainst.org" return replace($placeUri, '/place/', '/doc/')  || '.rdf'

                                    case "sws.geonames.org" return $placeUri || "/about.rdf"
                                    default return $placeUri || "/rdf"




    let $http-request-data := <request xmlns="http://expath.org/ns/http-client"
    method="GET" href="{$url4httpRequest}"/>

    let $responses :=
    http:send-request($http-request-data)
    let $response :=
    <results>
      {if ($responses[1]/@status ne '200')
         then
             <failure>{$responses[1]}</failure>
         else
           <success>
             {$responses[2]}
             {'' (: todo - use string to JSON serializer lib here :) }
           </success>
      }
    </results>

let $placeRecord := if ($response//rdf:RDF) then $response//rdf:RDF

                                   else (<error>Can't get place</error>)

    (:let $placeRecord := if ($response//rdf:RDF/*[local-name()="Feature"]) then $response//rdf:RDF/*[local-name()="Feature"]

                                   else if ($response//rdf:RDF/*[local-name()="Place"]) then $response//rdf:RDF/*[local-name()="Place"]

                                   else (<error>Can't get place</error>)
:)

(:let $placeSource := substring-before(substring-after($placeUri, '//'), '/'):)

(:let $placePrefLabel := $pleiadesRecord//*[namespace-uri()='http://geovocab.org/spatial#' and local-name()='Feature']/*[namespace-uri()='http://xmlns.com/foaf/0.1/' and local-name()='primaryTopicOf']/skos:Concept/dct:title:)

(:let $placePrefLabel := $placeRecord//*[local-name()='Feature']/*[local-name()='primaryTopicOf']/skos:Concept/dct:title/text():)

let $placeLabel :=
                if ($placeRecord/*[local-name()="Feature"]/*[local-name()="label"]) then $placeRecord/*[local-name()="Feature"]/*[local-name()="label"][1]/text()
                            else if ($placeRecord/*[local-name()="Feature"]/*[local-name()="title"]) then $placeRecord//*[local-name()="title"][1]/text()
                            else if ($placeRecord/*[local-name()="Feature"]/*[local-name()="name"]) then $placeRecord//*[local-name()="name"][1]/text()
                            else ("No label or name found")

let $placeLocation :=
                    <geo:Point>
                    {
                    if ($placeRecord/*[local-name()="Feature"]/*[local-name()="primaryTopicOf"]/*[local-name()="Place"][1]/*[local-name()="lat"]) then 
                    $placeRecord/*[local-name()="Feature"]/*[local-name()="primaryTopicOf"]/*[local-name()="Place"][1]/*[local-name()="lat"]
                    else if ($placeRecord/*[local-name()="Feature"]/*[local-name()="primaryTopicOf"]/*[local-name()="Concept"][1]/*[local-name()="lat"]) then 
                    $placeRecord/*[local-name()="Feature"]/*[local-name()="primaryTopicOf"]/*[local-name()="Concept"][1]/*[local-name()="lat"]
                    else if ($placeRecord/*[local-name()="AbstractGeometry"]) then $placeRecord/*[local-name()="AbstractGeometry"]
                            else ()
                            }
                    {
                    if ($placeRecord/*[local-name()="Feature"]/*[local-name()="primaryTopicOf"]/*[local-name()="Place"][1]/*[local-name()="long"]) then 
                    $placeRecord/*[local-name()="Feature"]/*[local-name()="primaryTopicOf"]/*[local-name()="Place"][1]/*[local-name()="long"]
                    else if ($placeRecord/*[local-name()="Feature"]/*[local-name()="primaryTopicOf"]/*[local-name()="Concept"][1]/*[local-name()="long"]) then 
                    $placeRecord/*[local-name()="Feature"]/*[local-name()="primaryTopicOf"]/*[local-name()="Concept"][1]/*[local-name()="long"]
                    else if ($placeRecord/*[local-name()="AbstractGeometry"]) then $placeRecord/*[local-name()="AbstractGeometry"]
                            else ()
                            }        
                    </geo:Point>


let $projectUriOfPlace :=
    if (exists($placeCollectionProject//Place[owl:sameAs[contains(./@rdf:resource, $placeUri)]])) then
            data($placeCollectionProject//Place[owl:sameAs[contains(./@rdf:resource, $placeUri)]]/@rdf:about)
            else $newUri


let $newPlaceRecord :=
        <rdf:RDF  xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:lawdi="http://lawd.info/ontology/"   xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:pleiades="https://pleiades.stoa.org/places/vocab#"
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:spatium="http://ausonius.huma-num.fr/spatium-ontoology">
        <spatial:Feature rdf:about="{$newUri}#this">
             <skos:exactMatch rdf:resource="{$placeUri}"/>
            <foaf:primaryTopicOf>
                <pleiades:Place rdf:about="{$newUri}">
                    <dcterms:title xml:lang="en">{$placeLabel}</dcterms:title>
                            { $placeLocation }
                            </pleiades:Place>
                            </foaf:primaryTopicOf>
                            </spatial:Feature>
                            </rdf:RDF>

let $placeAlreadyListedCheck := if($teiDoc//tei:fileDesc/tei:sourceDesc/tei:listPlace//tei:place/tei:idno[contains(., $placeUri)])
    then 'placeAlreadyListed'
    else if (exists($placeCollectionProject//Place[owl:sameAs[contains(./@rdf:resource, $placeUri)]])) then 'placeNotListedButAlreadyInProjectRepo'
    else 'placeNotListedAndNotInProjectRepo'

let $placeRefinDoc :=
            if(not($teiDoc//tei:fileDesc/tei:sourceDesc//tei:listPlace)) then(
            <nodeToInsert>
        <listPlace>
    <place >
            <placeName ref="{$projectUriOfPlace}{if($placeUri) then ' ' || $placeUri else()}">{$placeLabel}</placeName>
            
        </place>
        </listPlace>

    </nodeToInsert>
)
            else
<nodeToInsert>
    <place>
            <placeName ref="{$projectUriOfPlace}{if($placeUri) then ' ' || $placeUri else()}">{$placeLabel}</placeName>
        </place>

    </nodeToInsert>


let $path2placeRepoRoot := $teiEditor:data-repository-path || "/places"

let $duplicateOriginalSource :=
        if (exists($placeCollection//.[contains(./@rdf:about, $newUri)])) then ()
        else
        xmldb:store($path2placeRepoRoot || "/" || $sourceUri, functx:substring-after-last($placeUri, "/") || ".xml", $placeRecord)

let $createPlaceProjectRecordInPlaceRepo :=
     if (not($placeCollectionProject//owl:sameAs[contains(./@rdf:resource, $placeUri)]
     )) then
     xmldb:store($path2placeRepoRoot || "/" || $project, $newId || ".xml", $newPlaceRecord)
    else ()



let $insertRefToPlaceInTeiDocument :=

    if($teiDoc//tei:fileDesc/tei:sourceDesc/tei:listPlace//tei:place[@corresp=$projectUriOfPlace]) then()
    else(



         if($teiDoc//tei:fileDesc/tei:sourceDesc/tei:listPlace//tei:place) then(
            update insert ('&#xD;&#xa;',
                functx:change-element-ns-deep($placeRefinDoc, "http://www.tei-c.org/ns/1.0", "")/node())
                    following
                 $teiDoc//tei:sourceDesc/tei:listPlace//tei:place[last()]
            )
            else(
                  if($teiDoc//tei:fileDesc/tei:sourceDesc//tei:listPlace) then(
                  update insert functx:change-element-ns-deep($placeRefinDoc, "http://www.tei-c.org/ns/1.0", "")/node() into
                 $teiDoc//tei:sourceDesc/tei:listPlace
                 )
                  else

             update insert functx:change-element-ns-deep($placeRefinDoc, "http://www.tei-c.org/ns/1.0", "")/node() into
                 $teiDoc//tei:sourceDesc
                 )
                 )



(:let $createPlaceInPlaceRep :=
             update insert $newPlaceRecord/node() into
                 $teiEditor:placeRepo//listPlace:)



(:let $logs := collection($config:data-root || $teiEditor:project || "/logs"):)



(:let $updateXml := update value $originalTEINode with $updatedData:)


(:let $save := teiEditor:saveData(string($data/xml/docId), string($data/xml/input), string($updatedData)):)

return
(:    teiEditor:logEvent("document-insert-place" , $docId, $newPlaceRecord, ()),:)
    <result>
        <alrExisting>{ exists($placeCollection//.[contains(./@owl:sameAs, $placeUri)]) }</alrExisting>
        <placeRefinDoc>{ $placeRefinDoc }</placeRefinDoc>
        <newUri>{ $newUri}</newUri>
        <placeIdPrefix>{ $placeIdPrefix }</placeIdPrefix>
        <lastId>{ $last-id}</lastId>
        <message>{
        switch($placeAlreadyListedCheck)
        case "placeAlreadyListed" return 'This place is already listed in your document'
        case "placeNotListedButAlreadyInProjectRepo" return 'Reference to place '  || $projectUriOfPlace ||' added to document'
        case "placeNotListedAndNotInProjectRepo" return 'Place record created in Project Repository and Reference added to document'
        default return null
        }</message>
        <newPlaceUri>{$newUri}</newPlaceUri>
      <newList>{
        
       teiEditor:placesListNoHeader($docId)
       
      }
      </newList>
        <newListForAnnotation><div id="listOfPlaces">{ teiEditor:placeListForAnnotation($docId, 1)}</div>
      </newListForAnnotation>

    {
    if($teiDoc//tei:fileDesc/tei:sourceDesc/tei:listPlace//tei:place/tei:idno[contains(., $placeUri)])
    then
    (<result>{$placeUri} Place already listed</result>)
    else(
            if($teiDoc//tei:fileDesc/tei:sourceDesc/tei:listPlace//tei:placeName) then(
            <div id="listOfPlacesOverview">{ teiEditor:placesList($docId)}</div>
            )
            else(
                  if($teiDoc//tei:fileDesc/tei:sourceDesc//tei:listPlace) then(
              <div id="listOfPlacesOverview">{ teiEditor:placesList($docId)}</div>

                 )
                  else

             <div id="listOfPlaces">{ teiEditor:placesList($docId)}</div>

                 )
                 )
}</result>

};

declare function teiEditor:addPlaceToListOfPlace( $data as node(), $project as xs:string){
(: FUNCTION CAN BE DISCARDED :)
let $now := fn:current-dateTime()
let $currentUser := data(sm:id()//sm:username)

(:let $data := request:get-data():)
(:let $doc-collection := collection($config:data-root || $teiEditor:project || "/documents"):)

let $docId := $data//docId/text()
(:let $docId := request:get-parameter('docid', ()):)
let $teiDoc := $teiEditor:doc-collection/id($docId)
let $placeCollection := collection($teiEditor:data-repository-path || "/places")
let $placeCollectionProject := collection($teiEditor:data-repository-path || "/places/" || $project)
let $placeIdPrefix := doc("/db/apps/" || $teiEditor:project || "/data/app-general-parameters.xml")//idPrefix[@type='place']/text()

let $idList := for $id in $placeCollectionProject//.[contains(./@xml:id, $placeIdPrefix)]
        return
        <item>
        {substring-after($id/@xml:id, $placeIdPrefix)}
        </item>

let $last-id:= fn:max($idList)
let $newId := $placeIdPrefix || fn:sum(($last-id, 1))
let $newUri := $teiEditor:baseUri|| "/" || $placeIdPrefix || "/" || fn:sum(($last-id, 1))


let $placeUri := $data//placeUri/text()
let $sourceUri := substring-before(substring-after($placeUri, '//'), '/')


let $url4httpRequest := switch ($sourceUri)
                                    case "pleiades.stoa.org"
                                    case "vici.org" return $placeUri || "/rdf"

                                    case "gazetteer.dainst.org" return replace($placeUri, '/place/', '/doc/')  || '.rdf'

                                    case "sws.geonames.org" return $placeUri || "/about.rdf"
                                    default return $placeUri || "/rdf"




    let $http-request-data := <request xmlns="http://expath.org/ns/http-client"
    method="GET" href="{$url4httpRequest}"/>

    let $responses :=
    http:send-request($http-request-data)
    let $response :=
    <results>
      {if ($responses[1]/@status ne '200')
         then
             <failure>{$responses[1]}</failure>
         else
           <success>
             {$responses[2]}
             {'' (: todo - use string to JSON serializer lib here :) }
           </success>
      }
    </results>

    let $placeRecord := if ($response//rdf:RDF/*[local-name()="Feature"]) then $response//rdf:RDF/*[local-name()="Feature"]

                                   else if ($response//rdf:RDF/*[local-name()="Place"]) then $response//rdf:RDF/*[local-name()="Place"]

                                   else (<error>Can't get place</error>)


(:let $placeSource := substring-before(substring-after($placeUri, '//'), '/'):)

(:let $placePrefLabel := $pleiadesRecord//*[namespace-uri()='http://geovocab.org/spatial#' and local-name()='Feature']/*[namespace-uri()='http://xmlns.com/foaf/0.1/' and local-name()='primaryTopicOf']/skos:Concept/dct:title:)

(:let $placePrefLabel := $placeRecord//*[local-name()='Feature']/*[local-name()='primaryTopicOf']/skos:Concept/dct:title/text():)

let $placeLabel :=
                if ($placeRecord/*[local-name()="label"]) then $placeRecord/*[local-name()="label"][1]/text()
                            else if ($placeRecord/*[local-name()="title"]) then $placeRecord//*[local-name()="title"][1]/text()
                            else if ($placeRecord/*[local-name()="name"]) then $placeRecord//*[local-name()="name"][1]/text()
                            else ("No label or name found")

let $placeAlreadyListedCheck := if($teiDoc//tei:fileDesc/tei:sourceDesc/tei:listPlace//tei:place/tei:idno[contains(., $placeUri)])
    then 'placeAlreadyListed'
    else if (exists($placeCollectionProject//Place[owl:sameAs[contains(./@rdf:resource, $placeUri)]])) then 'placeNotListedButAlreadyInProjectRepo'
    else 'placeNotListedAndNotInProjectRepo'



let $projectUriOfPlace :=
    if (exists($placeCollectionProject//Place[owl:sameAs[contains(./@rdf:resource, $placeUri)]])) then
            data($placeCollectionProject//Place[owl:sameAs[contains(./@rdf:resource, $placeUri)]]/@rdf:about)
            else $newUri


let $placeRefinDoc :=
            if(not($teiDoc//tei:fileDesc/tei:sourceDesc//tei:listPlace)) then(
            <nodeToInsert>
        <listPlace>
    <place corresp="{$projectUriOfPlace}">
            <placeName xml:lang="en">{$placeLabel}</placeName>
            <idno type="source">{$placeUri}</idno>
        </place>
        </listPlace>

    </nodeToInsert>
)
            else
<nodeToInsert>
    <place corresp="{$projectUriOfPlace}">
            <placeName xml:lang="en">{$placeLabel}</placeName>
            <idno type="source">{$placeUri}</idno>
        </place>

    </nodeToInsert>

let $newPlaceRecord :=

        <Place xml:id="{$newId}" rdf:about="{$newUri}">
            <skos:prefLabel xml:lang="en">{$placeLabel}</skos:prefLabel>
            <skos:exactMatch rdf:resource="{$placeUri}"/>
        </Place>


let $path2placeRepoRoot := $teiEditor:data-repository-path || "/places"

let $duplicateOriginalSource :=
        if (exists($placeCollection//.[contains(./@rdf:about, $newUri)])) then ()
        else
        xmldb:store($path2placeRepoRoot || "/" || $sourceUri, functx:substring-after-last($placeUri, "/") || ".xml", $placeRecord)

let $createPlaceProjectRecordInPlaceRepo :=
     if (not($placeCollectionProject//owl:sameAs[contains(./@rdf:resource, $placeUri)]
     )) then
     xmldb:store($path2placeRepoRoot || "/" || $project, $newId || ".xml", $newPlaceRecord)
    else ()



let $listOfPlaces := doc($teiEditor:data-repository-path || "/places/" || $teiEditor:project || "/list.xml")

let $createPlaceInPlaceRep :=
             update insert $newPlaceRecord/node() following
                 $listOfPlace//Place[last()]



(:let $logs := collection($config:data-root || $teiEditor:project || "/logs"):)



(:let $updateXml := update value $originalTEINode with $updatedData:)


(:let $save := teiEditor:saveData(string($data/xml/docId), string($data/xml/input), string($updatedData)):)

return
(:    teiEditor:logEvent("document-insert-place" , $docId, $newPlaceRecord, ()),:)
    <result>
        <alrExisting>{ exists($placeCollection//.[contains(./@owl:sameAs, $placeUri)]) }</alrExisting>
        <placeRefinDoc>{ $placeRefinDoc }</placeRefinDoc>
        <newUri>{ $newUri}</newUri>
        <placeIdPrefix>{ $placeIdPrefix }</placeIdPrefix>
        <lastId>{ $last-id}</lastId>
        <message>{
        switch($placeAlreadyListedCheck)
        case "placeAlreadyListed" return 'This place is already listed in your document'
        case "placeNotListedButAlreadyInProjectRepo" return 'Reference to place '  || $projectUriOfPlace ||' added to document'
        case "placeNotListedAndNotInProjectRepo" return 'Place record created in Project Repository and Reference added to document'
        default return null
        }</message>
      <newList>{
       <div id="listOfPlaces">{ teiEditor:placeListForAnnotation($docId, 1)}</div>
      }
      </newList>


    {
    if($teiDoc//tei:fileDesc/tei:sourceDesc/tei:listPlace//tei:place/tei:idno[contains(., $placeUri)])
    then
    (<result>{$placeUri} Place already listed</result>)
    else(
            if($teiDoc//tei:fileDesc/tei:sourceDesc/tei:listPlace//tei:placeName) then(
            <div id="listOfPlaces">{ teiEditor:placeListForAnnotation($docId, 1)}</div>
            )
            else(
                  if($teiDoc//tei:fileDesc/tei:sourceDesc//tei:listPlace) then(
              <div id="listOfPlaces">{ teiEditor:placeListForAnnotation($docId, 1)}</div>

                 )
                  else

             <div id="listOfPlaces">{ teiEditor:placeListForAnnotation($docId, 1)}</div>

                 )
                 )
}</result>

};

declare function teiEditor:addProjectPlaceToDoc( $data as node(), $project as xs:string){

let $now := fn:current-dateTime()
let $currentUser := data(sm:id()//sm:real//sm:username)

(:let $data := request:get-data():)
(:let $doc-collection := collection($config:data-root || $teiEditor:project || "/documents"):)

let $docId := $data//docId/text()
let $placeUri := $data//placeUri/text()
let $placeUriShort := substring-before($placeUri, "#this")
let $placeType := skosThesau:getLabel($data//placeType/text(), 'xml')

(:let $docId := request:get-parameter('docid', ()):)
let $teiDoc := $teiEditor:doc-collection/id($docId)
let $placeCollectionProject := collection($teiEditor:data-repository-path|| "/places/" || $project)
let $placeDetails := $placeCollectionProject//spatial:Feature[@rdf:about=$placeUri][1]
let $placeExactMatch := if($placeDetails//skos:exactMatch/@rdf:resource != "") then
                ( for $exactMatch in functx:distinct-nodes($placeDetails//skos:exactMatch)
                return ' ' || $exactMatch/@rdf:resource )
                else()
let $placeRefinDoc :=
            if(not($teiDoc//tei:fileDesc/tei:sourceDesc//tei:listPlace)) then(
            <nodeToInsert>
        <listPlace>
            <place>
                    <placeName ref="{$placeUriShort}{ $placeExactMatch }" ana="{ $placeType }">{$placeDetails//dcterms:title/text()}</placeName>
                </place>
                </listPlace>

    </nodeToInsert>
)
            else
<nodeToInsert>
    <place>
        <placeName ref="{$placeUriShort}{ $placeExactMatch }" ana="{ $placeType }">{$placeDetails//dcterms:title/text()}</placeName>
        </place>

    </nodeToInsert>





let $insertRefToPlaceInTeiDocument :=

    if($teiDoc//tei:fileDesc/tei:sourceDesc/tei:listPlace//tei:place[@corresp=$placeUriShort]) then()
    else(
       if($teiDoc//tei:fileDesc/tei:sourceDesc/tei:listPlace//tei:place) then(
            update insert ('&#xD;&#xa;',
                functx:change-element-ns-deep($placeRefinDoc, "http://www.tei-c.org/ns/1.0", "")/node())
                    following
                 $teiDoc//tei:sourceDesc/tei:listPlace//tei:place[last()]
            )
            else(
                  if($teiDoc//tei:fileDesc/tei:sourceDesc//tei:listPlace) then(
                  update insert functx:change-element-ns-deep($placeRefinDoc, "http://www.tei-c.org/ns/1.0", "")/node() into
                 $teiDoc//tei:sourceDesc/tei:listPlace
                 )
                  else

             update insert functx:change-element-ns-deep($placeRefinDoc, "http://www.tei-c.org/ns/1.0", "")/node() into
                 $teiDoc//tei:sourceDesc
                 )
                 )

let $updateProvenance := 
        if(lower-case($placeType) = "provenance") then
            update value $teiDoc//tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:provenance/tei:location/tei:placeName/@ref with $placeUriShort
        else ()
let $updateOrigPlace := 
        if(lower-case($placeType) = "origin") then
        (: Check if place already as origPlace :)
            if($teiDoc//tei:origPlace/tei:placeName[contains(./@ref, $placeUriShort)])
                then ()
        (: Check if placeName node exists :)
            else if(exists($teiDoc//tei:origPlace/tei:placeName[@ref=""]))
                then (update value $teiDoc//tei:origPlace/tei:placeName/@ref with concat($placeUriShort, $placeExactMatch),
                    update value $teiDoc//tei:origPlace/tei:placeName with $placeDetails//dcterms:title/text())
        (: Check if origPlace no exists :)
            else if(exists($teiDoc//tei:origPlace))
                then (
                    let $newPlaceName := <node>
                        <placeName type="ancient" ref="{ concat($placeUriShort, $placeExactMatch) }">{ $placeDetails//dcterms:title/text() }</placeName>
                        </node>
                    return
                        update insert functx:change-element-ns-deep($newPlaceName/node(), "http://www.tei-c.org/ns/1.0", "") into $teiDoc//tei:origPlace
                    )
        (: if no origPlace, then creates node :)
            else (
                    let $newOrigPlace := <node>
                        <origPlace>
                            <placeName type="ancient" ref="{ concat($placeUriShort, $placeExactMatch) }">{ $placeDetails//dcterms:title/text() }</placeName>
                        </origPlace>
                        </node>
                    return
                        update insert functx:change-element-ns-deep($newOrigPlace/node(), "http://www.tei-c.org/ns/1.0", "") following $teiDoc//tei:origDate
            )
        else ()


return
(:    teiEditor:logEvent("document-insert-place" , $docId, $newPlaceRecord, ()),:)
    <result>
      <newList>{
        
       teiEditor:placesListNoHeader($docId)
       
      }
      </newList>
        <newListForAnnotation><div id="listOfPlaces">{ teiEditor:placeListForAnnotation($docId, 1)}</div>
      </newListForAnnotation>

    {
    if($teiDoc//tei:fileDesc/tei:sourceDesc/tei:listPlace//tei:place/tei:idno[contains(., $placeUri)])
    then
    (<result>{$placeUri} Place already listed</result>)
    else(
            if($teiDoc//tei:fileDesc/tei:sourceDesc/tei:listPlace//tei:placeName) then(
            <div id="listOfPlacesOverview">{ teiEditor:placesList($docId)}</div>
            )
            else(
                  if($teiDoc//tei:fileDesc/tei:sourceDesc//tei:listPlace) then(
              <div id="listOfPlacesOverview">{ teiEditor:placesList($docId)}</div>

                 )
                  else

             <div id="listOfPlaces">{ teiEditor:placesList($docId)}</div>

                 )
                 )
}</result>

};



declare function teiEditor:addProjectPersonToDoc( $data as node(), $project as xs:string){

let $now := fn:current-dateTime()
let $currentUser := data(sm:id()//sm:real//sm:username)

(:let $data := request:get-data():)
(:let $doc-collection := collection($config:data-root || $teiEditor:project || "/documents"):)

let $docId := $data//docId/text()
let $personUri := $data//peopleUri/text()
let $personUriShort := substring-before($personUri, "#this")

(:let $docId := request:get-parameter('docid', ()):)
let $teiDoc := $teiEditor:doc-collection/id($docId)
let $peopleCollectionProject := collection($teiEditor:data-repository-path|| "/people")
let $personDetails := $peopleCollectionProject//lawd:person[@rdf:about=$personUri][1]

let $personRefinDoc :=
            if(not($teiDoc//tei:listPerson[@type="peopleInDocument"]
            )) then(
            <nodeToInsert>
        <listPerson type="peopleInDocument">
    <person corresp="{$personUriShort}">
            <persName xml:lang="en">{ $personDetails//lawd:personalName[@xml:lang='en']/text() }</persName>
        </person>
        </listPerson>

    </nodeToInsert>
)
            else
<nodeToInsert>
    <person corresp="{$personUriShort}">
            <persName xml:lang="en">{ $personDetails//lawd:personalName[@xml:lang='en']/text() }</persName>
        </person>
    </nodeToInsert>





let $insertRefToPresonInTeiDocument :=

    if($teiDoc//tei:listPerson[@type="peopleInDocument"]//tei:person[@corresp=$personUriShort]) then()
    else(




         if($teiDoc//tei:listPerson[@type="peopleInDocument"]//tei:person) then(
            update insert ('&#xD;&#xa;',
                functx:change-element-ns-deep($personRefinDoc, "http://www.tei-c.org/ns/1.0", "")/node())
                    following
                 $teiDoc//tei:listPerson[@type="peopleInDocument"]/tei:person[last()]
            )

        else(
                  if($teiDoc//tei:listPerson[@type="peopleInDocument"]) then(
                  update insert functx:change-element-ns-deep($personRefinDoc, "http://www.tei-c.org/ns/1.0", "")/node() into
                 $teiDoc//tei:listPerson[@type="peopleInDocument"]
                 )
                  
                  else


             update insert functx:change-element-ns-deep($personRefinDoc, "http://www.tei-c.org/ns/1.0", "")/node() into
                 $teiDoc//tei:profileDesc
                 )
                 )




return
(:    teiEditor:logEvent("document-insert-place" , $docId, $newPlaceRecord, ()),:)
    <result>
      <newList>{
        
       teiEditor:peopleList($docId)
       
      }
      
      </newList>
        <newListForAnnotation><div id="listOfPeople">{ teiEditor:listPeople($docId, 1) }</div>
      </newListForAnnotation>

    {
    if($teiDoc//tei:profileDesc//tei:listPerson//tei:person[contains(./@corresp, $personUri)])
    then 
    (<result>{$personUri} This person is already listed</result>)
    else(
            if($teiDoc//tei:listPerson[@type="peopleInDocument"]//tei:person) then(
            <div id="listOfPlacesOverview">{ teiEditor:peopleList($docId)}</div>
            )
            else(
                  if($teiDoc//tei:listPerson[@type="peopleInDocument"]) then(
              <div id="listOfPlacesOverview">{ teiEditor:peopleList($docId)}</div>

                 )
                  else

             <div id="listOfPlaces">{ teiEditor:peopleList($docId) }</div>

                 )
                 )
}</result>

};










declare function teiEditor:removeItemFromList( $data as node(), $project as xs:string){
            let $now := fn:current-dateTime()
            let $currentUser := data(sm:id()//sm:username)
            (:let $data := request:get-data():)
            (: let $doc-collection := collection($config:data-root || $teiEditor:project || "/documents") :)
            let $docId := $data//docId/text()
            (:let $docId := request:get-parameter('docid', ()):)
            let $teiDoc :=util:eval( "collection('" || $teiEditor:doc-collection-path || "')//id('" || $docId ||"')" ) 
            (:$teiEditor:doc-collection/id($docId):)
            let $item := $data//item/text()
            let $topConceptId := $data//topConceptId/text()
            let $refId := if (starts-with($item, "http")) then $item else "#" || $item
            
            let $index := if($data//index/text()) then xs:int($data//index/text())
                        else "1"
            
            let $list := $data//list/text()
            (:let $citedRange := $data//citedRange/text():)
            let $nodeToRemove :=
            switch ($list)
               case "editionBiblio"
                return
                        let $node := $teiDoc//tei:div[@type="bibliography"][@subtype="edition"]/tei:listBibl//tei:bibl[$index]
                        return
                        update delete $node
               case "secondaryBiblio" return
                        let $node := $teiDoc//tei:div[@type="bibliography"][@subtype="secondary"]/tei:listBibl//tei:bibl[$index]
                        return(
                        update delete $node
                        (:,
                        if ($teiEditor:doc-collection//tei:ptr[@target = $refId]) then ()
                        else(
                                   update delete $teiEditor:biblioRepo//.[@xml:id=$item]
                            ):)
                            )
               case "people" return
                        let $node := $teiDoc//tei:person[@corresp=$item]
                        return
                        update delete $node
            case "place" return
                        let $node := $teiDoc//tei:place[tei:placeName[contains(./@ref, $item)]]
                        return
                        update delete $node
              default return
                      let $elementNode :=if (exists($teiEditor:teiElementsCustom//teiElement[nm=$list])) then
                        $teiEditor:teiElementsCustom//teiElement[nm=$list]
                        else ($teiEditor:teiElements//teiElement[nm=$list]) 
                      
                let $elementAncestors := $elementNode/ancestor::teiElement
                let $xpathRootWhenSubGroup :=
                    if($elementNode/ancestor::teiElement)
                        then (
                                                string-join(
                                                    for $ancestor at $pos in $elementAncestors
                                                        let $ancestorIndex := "[1]"  (:index on ancestor not really handled:)
                                                                    (:if($pos = 1 ) 
                                                                            then if($index) 
                                                                                    then "[" || string($index) || "]" 
                                                                                    else ("")
                                                                             else (""):)
                                                        return
                                                            if (contains($ancestor/xpath/text(), '/@'))
                                                                then substring-before($ancestor/xpath/text(), '/@')
                                                                        || $ancestorIndex
                                                                else $ancestor/xpath/text() || $ancestorIndex
                                                )
                                        
                                        )
           else ()
    
          let $teiXPath := if (contains($elementNode/xpath/text(), '/@')) then substring-before($elementNode/xpath/text(), '/@')
                                            else $elementNode/xpath/text()
          let $constructedXPath := (if($xpathRootWhenSubGroup != "") then
                        $xpathRootWhenSubGroup else ()) || $teiXPath
                      let $node := util:eval( "collection('" || $teiEditor:doc-collection-path ||"')/id('"
                             || $docId ||"')" || $constructedXPath || "[" || $index ||"]")
                      
                      return
                      update delete $node
            
            
            
            (: let $deleteBiblioFromBiblioRepo :=
                if ($teiEditor:doc-collection//tei:ptr[@target = $refId]) then ()
                else(
                           update delete $teiEditor:biblioRepo//.[@xml:id=$item]
                    ) :)
            
            (:let $logInjection :=
                update insert
                <log type="document-update-remove-item-from-{$list}" when="{$now}" what="{data($data/xml/docId)}" who="{$currentUser}">
                    {$data}
                    <docId>{$docId}</docId>
                    <!--<lastNode>{$lastNode}</lastNode>
                    -->
                    <origNode2>$originalTEINode</origNode2>
                    <refId>{$item}</refId>
                      <node2beDeleted>{util:eval( "collection('" || $teiEditor:doc-collection-path ||"')/id('"
                             || $docId ||"')" || $item || "[" || $index ||"]")}</node2beDeleted>
            
                </log>
                into $teiEditor:logs/id('all-logs'):)
            
            (:let $save := teiEditor:saveData(string($data/xml/docId), string($data/xml/input), string($updatedData)):)
            
            
            
            return  (:Main return:)
            switch ($list)
               case "editionBiblio" return
                <div><newList>
                    {for $bibRef at $pos in $teiDoc//tei:text/tei:body/tei:div[@type='bibliography'][@subtype='edition']/tei:listBibl//tei:bibl
                    
                    return
                        teiEditor:displayBibRef($docId, $bibRef, "edition", $pos)
                       }</newList></div>
                case "secondaryBiblio" return
                    <div><newList>
                        {for $bibRef at $pos in $teiDoc//tei:text/tei:body/tei:div[@type='bibliography'][@subtype='secondary']/tei:listBibl//tei:bibl
                        order by $bibRef//tei:ptr/@target
                        return
                            teiEditor:displayBibRef($docId, $bibRef, "secondary", $pos)
                           }
                           </newList></div>
                (:case "people" return
                            (
                                            for $people in $teiDoc//tei:listPerson[@type="peopleInDocument"]/tei:person
                                                let $personUri := data($people/@corresp)
                                                let $personId := functx:substring-after-last($personUri, '/')
                                                let $personRecord := $teiEditor:peopleRepo/id($personId)
                                                let $names := string-join($personRecord//persName, ' ')
            (\:                                order by $personRecord/persName:\)
            
                                            return
                                            teiEditor:displayPersonItem($teiEditor:docId, $personUri, $index)
                             ):)
                case "place" return
                            <div>
                            <newList>{
                        teiEditor:placesListNoHeader($docId)
                        }</newList>
                        <newListForAnnotation>
                             <div id="listOfPlaces">{ teiEditor:placeListForAnnotation($docId, 1)}</div>
                        </newListForAnnotation>
                        </div>
                case "people" return
                            <div>
                            <newList>{
                       teiEditor:peopleList($docId)
                        }</newList>
                        <newListForAnnotation>
                            <div id="listOfPeople">{ teiEditor:listPeople($docId, 1) }</div>
                        </newListForAnnotation>
                        <newListForMentionedNames>
                            <div id="newListOfMentionedNames">{ teiEditor:peopleMentionsInDoc($docId) }</div>
                        </newListForMentionedNames>
                        </div>        
                case  "xmlElement" return
                teiEditor:displayElement($list, $docId, (), ())
            (:      teiEditor:displayTeiElementWithThesauCardi($list, $topConceptId, $docId, $index):)
                default return 
                <div><newList>{teiEditor:displayElement($list, $docId, 1, ())}</newList></div>
};

declare function teiEditor:getTextGeneralClass(){
    <result>
    {for $item in $teiEditor:teiTemplate
    order by $item
    return
    <item>
        <label>{$item/text()}</label>
        <id>{data($item/@xml:id)}</id>
    </item>
    }
    </result>
};

declare function teiEditor:surfaceManager(){
 <div class="sectionPanel">
    <h4 class="subSectionTitle">Writing Support(s)<a onclick="openDialog('dialogNewSurface')"><i class="glyphicon glyphicon-plus"/></a></h4>
    <p>This TEI document has { count($teiEditor:teiDoc//tei:sourceDoc//tei:surface) } /sourceDoc/surface element{ if (count($teiEditor:teiDoc//tei:sourceDoc//tei:surface) > 1) then "s" else ""}</p>
        <ul>
            {
              for $surface at $index in $teiEditor:teiDoc//tei:sourceDoc//tei:surface
              return
              <li class="sectionPanel">
              <h4 class="subSectionTitle">
              <span class="labelForm">{$index}</span>
              <span class="labelForm">{data($surface/@ana)}</span>
              <span class="surfaceId">{data($surface/@xml:id)}</span>
              </h4>
              <div class="surfaceDesc">
              {teiEditor:displayElement('docTextSurfaceType', (), (), ())}</div>
              <div class="sectionPanel">
              <h5>Figures <a title="Not implemented yet"><i class="glyphicon glyphicon-plus"/></a></h5>
              {for $graphic in $surface//tei:graphic
              return
              <img src="{$graphic/@url}" alt="" height="50px"/>
              }
              </div>
             </li>
             }
        </ul>

         <!--Dialog for Surface-->
    <div id="dialogNewSurface" title="Add a new surface" class="modal fade" tabindex="-1" style="display: none;">

            <!-- Modal content-->
            <div class="modal-content modal4editor">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"/>
                    <h4 class="modal-title">Create a new surface</h4>
                </div>
                <div class="modal-body">

                <div>

                </div>



                    <div class="form-group modal-footer">


                        <button id="addPeople" class="pull-left" onclick="createAndAddPerson('{$teiEditor:docId}')">Create person</button>
                        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                    </div>

                    <!--                <a href="javascript: void(0);" onclick="tests()">Test</a>        -->
                </div>
            </div>
       </div><!--End of dialog-->
  </div>


};

declare function teiEditor:layoutManager(){
 <div class="sectionPanel">
    <h4 class="subSectionTitle">Text Layout Metadata</h4>
    <p>This TEI document has <strong>{ count($teiEditor:teiDoc//tei:physDesc/tei:objectDesc/tei:layoutDesc//tei:layout) } layout </strong> Element{ if (count($teiEditor:teiDoc//tei:msItem) > 1) then "s" else ""}</p>
    {teiEditor:displayTeiElement('docTextLayoutSummmary', (), 'textarea', ())}
        <ul>
            {
              for $layout in $teiEditor:teiDoc//tei:physDesc/tei:objectDesc/tei:layoutDesc//tei:layout
              let $description := if ($layout//tei:desc) then <span class="surfaceDesc"><strong>Description: </strong>{data($layout//tei:desc)}</span>
                                                else <span class="surfaceDesc">No description</span>
              let $correspondingItems := tokenize(data($layout/@corresp), ' ')

              let $correspondingElement :=
                    for $item in $correspondingItems

                    let $matchingElement :=
                            if ($teiEditor:teiDoc//tei:surface[contains(./@xml:id, substring($item, 2))]) then
                            <matchingElement type="surface">{ data($teiEditor:teiDoc//tei:surface[contains(./@xml:id, substring($item, 2))]/@ana) }</matchingElement>
                            else if ($teiEditor:teiDoc//tei:decoNote[contains(./@xml:id, substring($item, 2))]) then
                            <matchingElement type="deco">{ data($teiEditor:teiDoc//tei:decoNote[contains(./@xml:id, substring($item, 2))]/tei:desc/text()) }</matchingElement>
                           else ()

                    return $matchingElement


              return
              <li>
              <span class="label label-primary">{data($layout/@xml:id)}</span>
              {for $item in $correspondingElement
                let $label := switch($item/@type)
                    case "surface" return "Surface"
                    case "deco" return "Fig."
                    default return null

                return
                    <span><span class="surfaceDesc">{ $label || ": " }</span> {$item/text()} | </span>
              }


              {$description}


             </li>
             }
        </ul>
  </div>
  };

declare function teiEditor:msItemManager(){
    <div class="sectionPanel">
    <h4 class="subSectionTitle">Abstract Text Metadata</h4>
    <p>This TEI document has <strong>{ count($teiEditor:teiDoc//tei:msItem) } msItem </strong> Element{ if (count($teiEditor:teiDoc//tei:msItem) > 1) then "s" else ""}</p>
    <ul>
    {
      for $msItems at $index in $teiEditor:teiDoc//tei:msItem

     return
     <li class="sectionPanel">
        <span class=""><h4>msItem {$index}</h4>
        {teiEditor:displayTeiElement('msItemModernTitle', $index, 'input', ())}
        {teiEditor:displayElement('textMainLang', (), 1, ())}
        {teiEditor:displayElement('textOtherLangs', (), $index, ())}

        {teiEditor:displayTeiElementWithThesau('msItemClassification', 'apcc19298', $index, ())}
        {teiEditor:displayTeiElement('msItemRefToCanonical', $index, 'input', ())}
        </span>


     </li>
     }
     </ul>
  </div>
};

declare function teiEditor:getXmlFile($docId){
    (:let $docId := $data//docId/text():)

(:    return:)
      util:eval( "collection('" || $teiEditor:data-repository-path || "/documents')/id('"
             || $docId ||"')")
};

declare function teiEditor:logEvent($eventType as xs:string,
                                                      $docId as xs:string,
                                                      $data as node()?,
                                                      $description as xs:string?){
    let $project := request:get-parameter("project", ())
    let $logs := collection($teiEditor:data-repository-path || '/logs')
    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:real/sm:username)
    let $log :=
<data>
    <log type="{$eventType}" when="{$now}" what="{$docId}" who="{$currentUser}">{$data}<description>{$description}</description></log>
 </data>
return
    update insert
         $log/node()
         into $logs/rdf:RDF/id('all-logs')
};

(:DASHBOARD:)

declare function teiEditor:dashboard($corpus as xs:string?){
    let $newDocType :=  $teiEditor:appVariables//newDocType/text()
    let $documentCollection := collection("/db/apps/" || $teiEditor:project || "Data/documents")
    let $documentList := doc("/db/apps/" || $teiEditor:project || "Data/lists/list-documents.xml")
    let $docDiff:= (count($documentCollection//tei:TEI) - count($documentList//data))
        return
  <div data-template="templates:surround" data-template-with="templates/page.html" data-template-at="content">
      <div class="container form">
            <div class="row">
                <div class="col-xs-12 col-sm-12 col-md-12">
                    <h2>Corpora</h2>
                </div>
            </div>
            <div class="row">
                <!-- Tab panes -->
                <div class="tab-content">
                    <div role="tabpanel" class="tab-pane active" id="documents">
<!--                  { teiEditor:newCollectionPanel() } -->
                       <div class="row">
                                <div class = "col-xs-2 col-sm-2 col-md-2">
                                         { teiEditor:corpusList($corpus) }
                                </div>
                                {if ($corpus !="") then
                                <div class = "col-xs-10 col-sm-10 col-md-10">
                                  { switch($newDocType)
                                                                case "simpleTitle" return (teiEditor:newDocumentSimpleTitlePanel($corpus), teiEditor:newDocumentSimpleTitleWithEditionFromExtResourcePanel($corpus))
                                                                case "multi" return teiEditor:newDocumentPanelMultipleChoice($corpus)
                                                                default return teiEditor:newDocumentPanelMultipleChoice($corpus)
                                                         }
                                  {  teiEditor:documentList($corpus) }
                                </div>
                                else if($teiEditor:appVariables//dasboardFullList/text() = "yes") then 
                                (
                                <div class= "col-xs-10 col-sm-10 col-md-10">
                                <h4>All documents</h4>
                                {if($docDiff = 0) then "" 
                                else if($docDiff = 1) then "There is 1 document not included in the generated list of documents"
                                else "There are " || $docDiff || " documents not included in the generated list of documents"}
                                {if($docDiff > 0) then
                                    <div class="form-group">
                                            <div class="">
                                                
                                                    <button id="btn-regenerate" class="btn btn-warning" onclick="regenerate()">Re-generate list</button><br/>
                                                    <img id="f-load-indicator" class="hidden" src="/resources/images/ajax-loader.gif"/>
                                                    <div id="messages"></div>
                                            </div>
                                        </div>
                                    else()}
                                <p>To browse by corpus, click on a corpus name in the left column</p>
                                     <table id="fullList" class="table">
                                       <thead>
                                            <tr>
                                                <td class="sortingActive">ID</td>
                                                <td>Document title</td>
                                                <td>Provenance</td>
                                                <td>Dating</td>
                                                <td></td>
                                                <td>Other IDs</td><!--Header for TM -->
                                                <td>Last modified</td>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            {for $doc in $documentCollection//tei:TEI

                                            let $resourceName := if($doc) then util:document-name($doc) else ()
                                          
                                            let $collectionName := if($doc) then  util:collection-name($doc) else ()
                                            let $lastModified := if($doc) then substring-before(string(xmldb:last-modified($collectionName, $resourceName)), "T")
                                                                else "No doc"
                                            let $document:= $documentList//data[id = $doc/@xml:id]
                                            return
                                            <tr>
                                                <td>{ $doc/@xml:id/string() }</td>
                                                <td><span>{ if($document/title/text() ="") then "Cannot retrieve title as doc not in list" else $document/title/text() }
                                                    <a href="/exist/apps/estudium/edit-documents/{$doc/@xml:id/string()}" target="_blank" title="Edit document in a new window"><i class="glyphicon glyphicon-edit"/></a>
                                                    <a href="/exist/apps/estudium/documents/{$doc/@xml:id/string()}" target="_blank" title="Open public view in a new window"><i class="glyphicon glyphicon-eye-open"/></a>
                                                    </span></td>
                                                <td><a href="{ $document/provenanceUri/text()}" target="_blank">{ $document/provenance/text() }</a></td>
                                                <td>{ $document/datingNotBefore/text() }</td>
                                                <td>{ $document/datingNotAfter/text() }</td>
                                                <td style="overflow-wrap: anywhere; width: 100px">{ $document/otherId/text() }</td>
                                                <td>{ $lastModified }</td>
                                            </tr>
                                            }
                                        </tbody>
                                        </table>
                                </div>
                                )
                                else()
                                }
                       </div>
                    </div>
                </div>
            </div>
        </div>
         <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.20/css/jquery.dataTables.css"/>
    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.20/js/jquery.dataTables.js"></script>
    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/plug-ins/1.10.21/sorting/any-number.js"/>
    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/buttons/1.7.0/js/dataTables.buttons.min.js"/>
    <script type="text/javascript" charset="utf8" src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.1.3/jszip.min.js"/>
    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/buttons/1.7.0/js/buttons.html5.min.js"/>
    <script type="text/javascript" src="$ausohnum-lib/resources/scripts/teiEditor/teiEditor-dashboard.js"/>
    <link href="$ausohnum-lib/resources/css/skosThesau.css" rel="stylesheet" type="text/css"/>
    <script type="text/javascript">$(document).ready( function () {{
                      $('#fullList').DataTable({{
                        //scrollY:        "600px",
                        scrollX:        false,
                        scrollCollapse: true,
                        paging: false,
                        dom: <![CDATA[
                            "<'row'<'col-sm-2'l><'col-sm-4'B><'col-sm-6'f>>" +
                                                        
                                                         "<'row'<'col-sm-12'tr>>" +
                                                         "<'row'<'col-sm-5'i><'col-sm-7'p>>",
                            ]]>
                        buttons: [
                                {{extend: 'csv',
                                className: 'exportButton',
                                text: '<i class="glyphicon glyphicon-export"/> csv'
                                }},
                                {{
                                extend: 'excel',
                                className: 'exportButton',
                                text: '<i class="glyphicon glyphicon-export"/> excel'
                                }},
                                {{
                                extend: 'copy',
                                className: 'exportButton',
                                text: '<i class="glyphicon glyphicon-copy"/> copy'
                                }}],
                        columnDefs: [
                                                 
                                                   {{
                                                       "type": "any-number", targets: [1]
                                                       
                                                   }},
                                                   {{
                                                       "type": "any-number", targets: [3]
                                                       
                                                   }},
                                                   {{
                                                       "type": "any-number", targets: [4]
                                                       
                                                   }},
                                                   {{
                                                       "width": "20%",
                                                       "render": function (data, type, full, meta) {{
                                                        return '<div>'
                                                            + data + "</div>";
                                                            }},
                                                            targets: [5]
                                                       
                                                   }},  
                                                ],
                          fixedColumns: false,
                          language: {{
                                            search: "Suche:"
                                                }}
                            
                            }});

                            $( '#fullList' ).searchable();
                        }} );
                        
                        function regenerate() {{
                            $("#messages").empty();
                            $("#btn-regenerate").attr("disabled", true);
                            $("#f-load-indicator").removeClass('hidden');
                            $("#messages").text("The list of documents is being regenerated. Page will be reloaded once this process is finished...");
                            $.ajax({{
                                type: "POST",
                                dataType: "json",
                                url: "/documents/update-list/",
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
                        }}
</script>
    </div>


};



declare function teiEditor:corpusList($corpus as xs:string?){
(:            let $collections := xmldb:get-child-collections($teiEditor:doc-collection):)

            let $corpora := dbutil:scan-collections(
                                xs:anyURI($teiEditor:doc-collection-path),
                        function($collection) { $collection }
                        )
           
           let $noOfCorpus :=  count($corpora)

           let $collections :=
                            for $child at $pos  in $corpora
                                    let $collectionName := functx:substring-after-last($child, '/')
                                    order by $collectionName
                                    return
                                    if ($pos > 1) then 
                                        (if(sm:has-access($child, 'rw-')) then $child else ())
                                else ()


            return
         
         if ($noOfCorpus = 1 ) then 
                            (
                            
                            )
            
            else if ($noOfCorpus > 1 ) then
                (
                        <div class = "list-group">
                                   
                                        { for $child at $order in $collections
                                                let $collectionName := functx:substring-after-last($child, '/')
                                        let $corpusTitle :=
                                   doc(xs:anyURI($teiEditor:doc-collection-path || '/' || $collectionName ||'.xml'))//title[@type="full"]/text()
                                                            
                                                return
            
            
                   <a href="/exist/apps/estudium/admin/corpus/{$collectionName}" class="list-group-item{if($corpus =$collectionName) then ' active' else()}">
                      <h4 class="list-group-item-heading">{ functx:capitalize-first($corpusTitle)}</h4>
                      <p class="list-group-item-text">{teiEditor:countDocumentsInCollection($collectionName)}
                                            document{if(teiEditor:countDocumentsInCollection($collectionName) > 1) then "s" else ()}</p>
                    </a>
                                         }
                </div>
                
                
                )
                
    else ("no corpus yet")

};
declare function teiEditor:corpusListWithDocuments(){
(:            let $collections := xmldb:get-child-collections($teiEditor:doc-collection):)
            let $newDocType :=  $teiEditor:appVariables//newDocType/text()
            let $corpus := dbutil:scan-collections(
                                xs:anyURI($teiEditor:doc-collection-path),
                        function($collection) { $collection }
                        )
           
           let $noOfCoprus :=  count($corpus)

           let $collections :=
                            for $child at $pos  in $corpus
                                    let $collectionName := functx:substring-after-last($child, '/')
                                    order by $collectionName
                                    return
                                    if ($pos > 1) then $child else ()

            return
            if ($noOfCoprus > 1 ) then
            <div class = "container">
                        <div class="panel-group" id="collectionList">
                            { for $child at $order in $collections
                                    let $collectionName := functx:substring-after-last($child, '/')

                                    return


                                     <div class="panel panel-default">
                                                <div class="panel-heading" id="heading{$order}">
                                                    <a class="accordion-toggle" data-toggle="collapse" data-parent="#collectionList" href="#collectionCollapse{$order}">
                                                          Collection <em>{ functx:capitalize-first($collectionName)}</em>
                                                            ({teiEditor:countDocumentsInCollection($collectionName)}
                                                            document{if(teiEditor:countDocumentsInCollection($collectionName) > 1) then "s" else ()})
                                                      </a>
                                                </div>
                                                <div id="collectionCollapse{$order}" class="panel-collapse collapse{if ($order = 1) then "in" else()}" >
                                                      <div class="panel-body">{ switch($newDocType)
                                                                case "simpleTitle" return teiEditor:newDocumentPanel($collectionName)
                                                                case "multi" return teiEditor:newDocumentPanelMultipleChoice($collectionName)
                                                                default return teiEditor:newDocumentPanelMultipleChoice($collectionName)
                                                         }

                                                          { teiEditor:documentList(functx:substring-after-last($child, '/')) }
                                                      </div>
                                                </div>
                                      </div>
                                     }
                                 </div>



    </div>
    else ("no corpus yet")

};


declare function teiEditor:documentList($collection as xs:string){
let $documents := collection($teiEditor:doc-collection-path || "/" || $collection)//tei:TEI
let $docPrefix := doc($teiEditor:doc-collection-path || "/" || $collection || ".xml")//docPrefix
let $placeToDisplay := $teiEditor:appVariables//dashboardPlaceToDisplay/text()
let $lang := request:get-parameter("lang", ())
(:let $docPrefix := $teiEditor:appVariables//idPrefix[@type='document']/text():)
  
return
    <div id="documentListDiv">
    <table id="documentList" class="table">
     <span class="pull-right">Sortierung: {$lang}</span>
     <thead>
        <tr>
        <td></td>
        <td>Titel</td>
        <td class="sortingActive">ID</td>
        <td>Fundort</td>
        <td>notBefore</td>
        <td>notAfter</td>
        <td>TM no.</td><!--Header for TM -->
        <td>Edition</td>
        <td>GAMS</td><!--Header for other identifiers-->
        </tr>
        </thead>
        <tbody>
      
      {for $document at $pos in $documents
        let $title := concat($document//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/tei:title[1]/text(), ', ', $document//*:teiHeader/*:fileDesc/*:titleStmt/*:title/*:title[2])
        let $provenance := $document//tei:sourceDesc/tei:msDesc/tei:history/tei:provenance/tei:placeName/tei:ref
        let $datingNotBefore := data($document//tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate/@notBefore)
        let $datingNotAfter := data($document//tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate/@notAfter)
        let $editions := $document//tei:div[@type="bibliography"][@subtype="editions"]//tei:bibl/text()
        
       order by xs:int(substring-after(data($document/@xml:id), $docPrefix ))
               return
           <tr>
           <td>
           { if (contains($document//tei:div[@type="edition"]/tei:div[@type="textpart"]/tei:ab/text(), "Error")) then ("&#9888;")
           else ()}
           </td>
           <td>{$title}<a href="/exist/apps/estudium/documents/{data($document/@xml:id)}" target="_blank">
           <i class="glyphicon glyphicon-eye-open"/></a>
           <a href="/exist/apps/estudium/edit-documents/{data($document/@xml:id)}" target="_blank">
           <i class="glyphicon glyphicon-edit"/></a>
           </td>
           <td>{ data($document/@xml:id)}</td>
           <td>{ $provenance }</td>
           <td>{ $datingNotBefore }</td>
           <td>{ $datingNotAfter }</td>
           <td>{ $document//tei:idno[@subtype="tm"]/text()}</td>
           <td><ul>{ for $edition in $editions return <li>{$edition}</li>}</ul></td>
           <td><a href="{concat('https://gams.uni-graz.at/', $document//tei:idno[@type='PID']/text())}" target="_blank">{concat('https://gams.uni-graz.at/', $document//tei:idno[@type='PID']/text())}</a></td>
           </tr>
           

    }
    </tbody>
    </table>
   
    <script type="text/javascript">$(document).ready( function () {{
                        $('#documentList').DataTable({{
                        //scrollY:        "600px",
                        scrollX:        false,
                        scrollCollapse: true,
                        paging: false,
                        columnDefs: [
                                                 {{
                                                       width: 400, targets: [1]
                                                       
                                                   }},  
                                                   {{
                                                       "type": "any-number", targets: [2]
                                                       
                                                   }},
                                                   {{
                                                       "type": "any-number", targets: [4]
                                                       
                                                   }},
                                                   {{
                                                       "type": "any-number", targets: [5]
                                                       
                                                   }},
                                                   {{
                                                       targets: [ 6 ],
                                                       visible: false
                                                   }},
                                                   {{
                                                       targets: [7],
                                                       width: 10
                                                   }},
                                                   {{
                                                       targets: [8],
                                                       width: 200
                                                   }},
                                                ],
                          fixedColumns: true,
                          language: {{
                                            search: "Suche:"
                                                }}
                            }});
                        }} );</script>
    
    <script type="text/javascript">$( '#documentList' ).searchable();</script>
    </div>
};

declare function teiEditor:countDocumentsInCollection($collection){
 count(collection($teiEditor:doc-collection-path || "/" || $collection)//tei:TEI)

};

declare function teiEditor:listDocuments(){

    <table id="documentList"
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
    {for $document in $teiEditor:doc-collection//tei:TEI
    order by data($document/@xml:id)
    return
    <tr>
    <td><a href="documents/{data($document/@xml:id)}" >
    <i class="glyphicon glyphicon-eye-open"/></a>
    </td>
    <td>
    {$document//tei:fileDesc/tei:titleStmt/tei:title/text()}
    </td>
    <td>
    {data($document/@xml:id)}
    </td>
    <td>
    {$document//tei:sourceDesc/tei:msDesc/tei:history/tei:provenance/string()}
    
    </td>
    </tr>
    }
    </table>

};



(:CREATE NEW DOCUMENT:)

(:Function to be included in a dashboard:)

declare function teiEditor:newCollectionPanel(){
    let $templateList :=  collection( $teiEditor:library-path || 'data/teiEditor/docTemplates')

    return
    <div>
    <a onclick="openDialog('dialogNewCollection')" class="newDocButton"><i class="glyphicon glyphicon-plus"/>New collection</a>
    <!--Dialog for new document-->
    <div id="dialogNewCollection" title="Create a new collection" class="modal fade" tabindex="-1" style="display: none;">

            <!-- Modal content-->
            <div class="modal-content modal4editor">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"/>
                    <h4 class="modal-title">Create a new Collection of documents</h4>
                </div>
                <div class="modal-body">
                <div>
                      <div class="form-group row">
                                <label for="newCollectionTitleFull" class="col-sm-2 col-form-label">Full Title</label>
                                <div class="col-sm-10">
                                <input type="text" class="form-control" id="newCollectionTitleFull" name="newCollectionTitleFull"/>
                                </div>
                      </div>
                       <div class="form-group row">
                                <label for="newCollectionTitleShort" class="col-sm-2 col-form-label">Short Title</label>
                                <div class="col-sm-10">
                                <input type="text" class="form-control" id="newCollectionTitleShort" name="newCollectionTitleShort"/>
                                </div>
                            </div>
                            <div class="form-group row">
                                <label for="newCollectionPrefix" class="col-sm-2 col-form-label">Prefix for Doc IDs</label>
                                <div class="col-sm-10">
                                <input type="text" class="form-control" id="newCollectionPrefix" name="newCollectionPrefix"/>
                                </div>
                            </div>
                </div>
                    <div class="form-group modal-footer">
                        <button id="createCollection" class="pull-left" onclick="createNewCollection()">Create Collection</button>
                        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                    </div>

                    <!--                <a href="javascript: void(0);" onclick="tests()">Test</a>        -->
                </div>
            </div>
       </div><!--End of dialog-->
    </div>
};


declare function teiEditor:newDocumentPanel($collection as xs:string){
(:    let $templateList :=  collection( $teiEditor:library-path || '/data/teiEditor/docTemplates'):)
let $templateList :=  collection('/db/apps/' || $teiEditor:project || '/data/teiEditor/docTemplates')
    let $project := request:get-parameter("project", ())
    return
    <div>
    <a onclick="openDialog('dialogNewDocument{$collection}', '{$project}')" class="newDocButton"><i class="glyphicon glyphicon-plus"/>New document</a>
    <!--Dialog for new document-->
    <div id="dialogNewDocument{$collection}" title="Create a new document" class="modal fade" tabindex="-1" style="display: none;">

            <!-- Modal content-->
            <div class="modal-content modal4editor">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"/>
                    <h4 class="modal-title">Create a new document in {$collection}</h4>
                </div>
                <div class="modal-body">
                <div>
                <form autocomplete="off" >
                  <div class="form-group row">
                        <label for="newDocTemplate{$collection}" class="col-sm-2 col-form-label">Select a template</label>
                        <div class="col-sm-10">
                        { <select id="newDocTemplate{$collection}">
                              {for $items in $templateList//tei:TEI
                              order by $items[@xml:id = $teiEditor:project], $items/@xml:id

                                    return
                                        if (($items/@xml:id = $teiEditor:project))
                                        then (<option value="{data($items/@xml:id)}" selected='selected'>{data($items/@xml:id)}</option>)
                                        else (
                                        <option value="{data($items/@xml:id)}">{data($items/@xml:id)}</option>
                                        )

                                     }
                        </select>}

                        </div>
                    </div>
                    <div class="form-group row">
                                <label for="newDocTitle{$collection}" class="col-sm-2 col-form-label">Title</label>
                                <div class="col-sm-10">
                                <input type="text" class="form-control" id="newDocTitle{$collection}" name="newDocTitle{$collection}"/>
                                </div>
                            </div>
                     {skosThesau:dropDownThesauXML('c21851', 'en', 'Type', 'row', (), 1, ())}
                     {skosThesau:dropDownThesauXML('c39', 'en', 'Language', 'row', (), 1, 'xml')}
                     {skosThesau:dropDownThesauXML('c66', 'en', 'Script', 'row', (), 1, 'xml')}
                     <!--<div class="form-group">
                                <label for="zoteroLookupCreateNewDoc">Search in <a href="" target="_blank">Zotero</a>
                                </label>
                                <input type="text" class="form-control zoteroLookup" id="zoteroLookupCreateNewDoc" name="zoteroLookupInputModal"/>
                            </div>

                            <div class="form-group">
                                <label for="citedRange">Cited Range
                                </label>
                                <input type="text" class="form-control" id="citedRange" name="citedRange"/>
                            </div>
                            <div id="selectedBiblioAuthor"/>
                            <div id="selectedBiblioDate"/>
                            <div id="selectedBiblioTitle"/>
                            <div id="selectedBiblioId"/>
                            -->
                 </form></div>
               




                    <div class="form-group modal-footer">


                        <button id="createDocument{ $collection }" class="pull-left" onclick="createNewDocument('{ $collection }')">Create document</button>
                        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                    </div>

                    <!--                <a href="javascript: void(0);" onclick="tests()">Test</a>        -->
                </div>
            </div>
       </div><!--End of dialog-->
    </div>
};

declare function teiEditor:newDocumentSimpleTitlePanel($collection as xs:string){
    let $templateList :=  collection('/db/apps/' || $teiEditor:project || '/data/teiEditor/docTemplates')
    let $project := request:get-parameter("project", ())
    return
    <div>
    <a onclick="openDialog('dialogNewDocument{$collection}')" class="newDocButton"><i class="glyphicon glyphicon-plus"/>New document</a>
    <!--Dialog for new document-->
    <div id="dialogNewDocument{$collection}" title="Create a new document" class="modal fade" tabindex="-1" style="display: none;">
            
            <!-- Modal content-->
            <div class="modal-content modal4editor">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"/>
                    <h4 class="modal-title">Create a new document in {$collection}</h4>
                </div>
                <div class="modal-body">
                <div>
                  <div class="form-group row">
                        <label for="newDocTemplate{$collection}" class="col-sm-2 col-form-label">Template</label>
                        <div class="col-sm-10">
                        { <select id="newDocTemplate{$collection}" name="newDocTemplate{$collection}">
                              {for $items in $templateList//tei:TEI
                                 
                                    return
                                        if (($items/@xml:id = $teiEditor:project))
                                        then (<option value="{data($items/@xml:id)}" selected="selected">{data($items/@xml:id)}</option>)
                                        else (
                                        <option value="{data($items/@xml:id)}">{data($items/@xml:id)}</option>
                                        )
                
                                     }
                        </select>}
                       
                        </div>
                    </div>
                    <div class="form-group row">
                                <label for="newDocTitle{$collection}" class="col-sm-2 col-form-label">Title</label>
                                <div class="col-sm-10">
                                <input type="text" class="form-control" id="newDocTitle{$collection}" name="newDocTitle{$collection}"/>
                                </div>
                            </div>
                            <button id="selectDropDownc19361_1_1" name="selectDropDownc19361_1_1" value="https://ausohnum.huma-num.fr/concept/c21852" class="btn btn-xs btn-default dropdown-toggle elementWithValue hidden" type="button" data-toggle="dropdown">
                       Epigraphic
                                <span class="caret"></span></button>
                             <button id="selectDropDownc39_1_1" name="selectDropDownc39_1_1" value="grc" class="btn btn-xs btn-default dropdown-toggle elementWithValue hidden" type="button" data-toggle="dropdown">
                       Ancient Greek
                                <span class="caret"></span></button>
                            
                            
                     <!--
                     {skosThesau:dropDownThesauXML('c19361', 'en', 'Type', 'row', (), 1, ())}
                     
                     {skosThesau:dropDownThesauXML('c39', 'en', 'Language', 'row', (), 1, ())}
                     -->
                     <!--<div class="form-group">
                                <label for="zoteroLookupCreateNewDoc">Search in <a href="" target="_blank">Zotero</a>
                                </label>
                                <input type="text" class="form-control zoteroLookup" id="zoteroLookupCreateNewDoc" name="zoteroLookupInputModal"/>
                            </div>
                            
                            <div class="form-group">
                                <label for="citedRange">Cited Range
                                </label>
                                <input type="text" class="form-control" id="citedRange" name="citedRange"/>
                            </div>
                            <div id="selectedBiblioAuthor"/>
                            <div id="selectedBiblioDate"/>
                            <div id="selectedBiblioTitle"/>
                            <div id="selectedBiblioId"/>
                            -->
                </div>

                    <div class="form-group">
                                <label for="externalResourceUri{ $collection }" >Value (URI or id)</label>
                                <input type="text" class="form-control" id="externalResourceUri{ $collection }" name="externalResourceUri{ $collection }"/>
                    </div>
                    <div class="form-group modal-footer">


                        <button id="createDocument{$collection}" class="pull-left" onclick="createNewDocument('{ $collection }')">Create document</button>
                        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                    </div>

                    <!--                <a href="javascript: void(0);" onclick="tests()">Test</a>        -->
                </div>
            </div>
       </div><!--End of dialog-->
    </div>
};


declare function teiEditor:newDocumentSimpleTitleWithEditionFromExtResourcePanel($collection as xs:string){
    let $templateList :=  collection('/db/apps/' || $teiEditor:project || '/data/teiEditor/docTemplates')
    let $project := request:get-parameter("project", ())
    return
    <div>
    <a onclick="openDialog('dialogNewDocumentWithEditionFromExtResource{$collection}')" class="newDocButton"><i class="glyphicon glyphicon-plus"/>New document with Edition from external resource</a>
    <!--Dialog for new document-->
    <div id="dialogNewDocumentWithEditionFromExtResource{$collection}" title="Create a new document" class="modal fade" tabindex="-1" style="display: none;">
            
            <!-- Modal content-->
            <div class="modal-content modal4editor">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"/>
                    <h4 class="modal-title">Create a new document in {$collection}</h4>
                </div>
                <div class="modal-body">
                <div>
                  <div class="form-group row">
                        <label for="newDocTemplateWithEditionFromExtResource{$collection}" class="col-sm-2 col-form-label">Template</label>
                        <div class="col-sm-10">
                        { <select id="newDocTemplateWithEditionFromExtResource{$collection}" name="newDocTemplateWithEditionFromExtResource{$collection}">
                              {for $items in $templateList//tei:TEI
                                 
                                    return
                                        if (($items/@xml:id = $teiEditor:project))
                                        then (<option value="{data($items/@xml:id)}" selected="selected">{data($items/@xml:id)}</option>)
                                        else (
                                        <option value="{data($items/@xml:id)}">{data($items/@xml:id)}</option>
                                        )
                
                                     }
                        </select>}
                   
                        </div>
                    </div>
                    <div class="form-group row">
                                <label for="newDocTitleWithEditionFromExtResource{$collection}" class="col-sm-2 col-form-label">Title</label>
                                <div class="col-sm-10">
                                <input type="text" class="form-control" id="newDocTitleWithEditionFromExtResource{$collection}" name="newDocTitleWithEditionFromExtResource{$collection}"/>
                                </div>
                            </div>
                            
                                <div class="form-group">
                                <label for="externalResourceUriWithEditionFromExtResource{ $collection }">External resource URI (optional)</label>
                                
                                <input type="text" class="form-control externalResourceURI" id="externalResourceUriWithEditionFromExtResource{ $collection }" name="externalResourceUri{ $collection }"/>
                                
                        </div>
                        <button class="btn btn-primary" id="retrieveEditionFromExtRes" onclick="retrieveEditionFromExternalResource('{$collection}')">Check external resource</button>
                        <div id="externalResourceEditionPreview"/>
                        <button id="selectDropDownc19361_1_1" name="selectDropDownc19361_1_1" value="https://ausohnum.huma-num.fr/concept/c21852" class="btn btn-xs btn-default dropdown-toggle elementWithValue hidden" type="button" data-toggle="dropdown">
                       Epigraphic
                                <span class="caret"></span></button>
                             <button id="selectDropDownc39_1_1" name="selectDropDownc39_1_1" value="grc" class="btn btn-xs btn-default dropdown-toggle elementWithValue hidden" type="button" data-toggle="dropdown">
                       Ancient Greek
                                <span class="caret"></span></button>
                            
                            
                     <!--
                     {skosThesau:dropDownThesauXML('c19361', 'en', 'Type', 'row', (), 1, ())}
                     
                     {skosThesau:dropDownThesauXML('c39', 'en', 'Language', 'row', (), 1, ())}
                     -->
                     <!--<div class="form-group">
                                <label for="zoteroLookupCreateNewDoc">Search in <a href="" target="_blank">Zotero</a>
                                </label>
                                <input type="text" class="form-control zoteroLookup" id="zoteroLookupCreateNewDoc" name="zoteroLookupInputModal"/>
                            </div>
                            
                            <div class="form-group">
                                <label for="citedRange">Cited Range
                                </label>
                                <input type="text" class="form-control" id="citedRange" name="citedRange"/>
                            </div>
                            <div id="selectedBiblioAuthor"/>
                            <div id="selectedBiblioDate"/>
                            <div id="selectedBiblioTitle"/>
                            <div id="selectedBiblioId"/>
                            -->
                </div>

                        



                    <div class="form-group modal-footer">


                        <button id="createDocumentWithEditionFromExtResource{$collection}" class="pull-left"
                        onclick="createNewDocumentFromTemplateWithEditionFromExternalResource('{ $collection }')">Create document</button>
                        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                    </div>

                    <!--                <a href="javascript: void(0);" onclick="tests()">Test</a>        -->
                </div>
            </div>
       </div><!--End of dialog-->
    </div>
};

declare function teiEditor:newDocumentPanelMultipleChoice($collection as xs:string){
(:    let $templateList :=  collection( $teiEditor:library-path || '/data/teiEditor/docTemplates'):)
let $templateList :=  collection('/db/apps/' || $teiEditor:project || '/data/teiEditor/docTemplates')
    let $project := request:get-parameter("project", ())
    return
    <div>
    <a onclick="openDialog('dialogNewDocument{$collection}', '{$project }')" class="newDocButton"><i class="glyphicon glyphicon-plus"/>New document</a>
    <!--Dialog for new document-->
    <div id="dialogNewDocument{$collection}" title="Create a new document" class="modal fade" tabindex="-1" style="display: none;">

            <!-- Modal content-->
            <div class="modal-content modal4editor">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"/>
                    <h4 class="modal-title">Create a new document in {$collection}</h4>
                </div>
                <div class="modal-body">
                
                <div id="" class="row">
                        
                      <!--  
                        <div class="col-xs-6 col-sm-6 col-md-6">
    
                            <h3>Import from an external resource</h3>
                        
      
                        <div class="form-group">
                            <label for="externalResource{ $collection }">Select an external resource</label>
                        
                                   <select id="externalResource{ $collection }" name="externalResource{ $collection }">
                                       {for $resource in $teiEditor:externalResources//resource
                                       let $name := $resource//name[@type='full']
                                       order by $name
                                       return
                                           <option value="{data($resource/@xml:id)}">
                                           {$name}
                                           </option>
                                        }
                                     </select>
                        
                        </div>
                        <div class="form-group">
                                <label for="docId{ $collection }">Document ID</label>
                                <input type="text" class="form-control" id="docId{ $collection }" name="docId{ $collection }"/>
                                
                        </div>
                        <hr/>
                        <p class="text-center big-text">- OR - </p>
                        <div class="form-group">
                                <label for="docUri{ $collection }">Insert a Document URI (only EDH)</label>
                                
                                <input type="text" class="form-control" id="docUri{ $collection }" name="docUri{ $collection }"/>
                                
                        </div>
                        <br/>
                        <button id="createDocumentFromExternalResource{ $collection }" 
                        
                        onclick="createNewDocumentFromExternalResource('{ $collection }')">Create document</button>
                        <br/>
                 </div>
                 -->
  
     <div class="col-xs-6 col-sm-6 col-md-6">
    
            <h3>Create from a template</h3>
                  <div class="">
                        <label for="newDocTemplate{$collection}" >Select a template</label>
                        
                        { 
                        <select id="newDocTemplate{$collection}" name="newDocTemplate{$collection}" 
                        class="templateSelect">
                        
                              {for $items in $templateList//tei:TEI
(:                              order by $items[@xml:id = $teiEditor:project], $items/@xml:id:)
                                  return
                                  <option value="{data($items/@xml:id)}">{data($items/@xml:id)}</option>
 (:                                       if ((contains(data($items/@xml:id), $teiEditor:project)))
                                        then (
                                        <option value="{data($items/@xml:id)}" selected="selected">{data($items/@xml:id)}</option>)
                                        else (
                                        <option value="{data($items/@xml:id)}">{data($items/@xml:id)}</option>
                                        ):)

                                     }
                        </select>}
                    </div>
                    <br/>
                    <div class="form-group">
                        <label for="newDocTitle{$collection}" >Give a Title</label>
                        <input type="text" class="form-control" id="newDocTitle{$collection}" name="newDocTitle{$collection}"/>
                    </div>
                    <br/>                 
                    <button id="createDocument{ $collection }" onclick="createNewDocument('{ $collection }')">Create document</button>
                 </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
            </div>    
            </div>
            </div>
       </div><!--End of dialog-->
    </div>
};
declare function teiEditor:newCollection($data, $project) {
    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)

    let $doc-collection := collection($teiEditor:data-repository-path || "/documents")
    let $doc-collection-path := $teiEditor:data-repository-path || "/documents"
    let $collectionPrefix := $data//collectionPrefix/text()
    let $collectionTitleFull := $data//titleFull/text()
    let $collectionTitleShort := $data//titleShort/text()


   let $filename := $collectionTitleShort || '.xml'
   let $metadataFile :=<corpus>
   <title type="full">{ $collectionTitleFull }</title>
   <title type="short">{ $collectionTitleShort }</title>
   <editor ref="{ $collectionTitleFull }">{ $collectionTitleFull }</editor>
   <docPrefix>{ $collectionPrefix }</docPrefix>
</corpus>

    let $collectionList := dbutil:scan-collections(xs:anyURI($doc-collection-path),
                                            function($collection) { $collection })
let $testIfExists :=  for $child at $pos  in $collectionList
                                    let $collectionName := functx:substring-after-last($child, '/')
                                    return
                                    if (matches($collectionName, "^" || $collectionTitleShort || "$")) then "collectionExists" else ()

return
           if ($testIfExists) then <result>erreur {$testIfExists}</result>
            else
            (
                    let $storeMetadataFile := xmldb:store($doc-collection-path, $filename, $metadataFile)
                    let $createCollection := xmldb:create-collection($doc-collection-path, $collectionTitleShort)
                    let $logEvent := teiEditor:logEvent("collection-new" , $collectionTitleShort, (),
                        "New collection " || $collectionTitleShort || " created in repository " || "by " || $currentUser)

                        return
                            <result><newCollection>Collection "{$collectionTitleShort }" created in { $doc-collection-path }</newCollection>
                            <newList>{ teiEditor:corpusList(()) }</newList>
                            </result>
                      )

};


declare function teiEditor:newDocument($data, $project) {
    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)
    let $template := collection( $teiEditor:library-path || '/data/teiEditor/docTemplates')//.[@xml:id=$data//template/text()]
    let $doc-collection := collection($teiEditor:data-repository-path || "/documents/" || $data//collection/text())
    let $doc-collection-path := $teiEditor:data-repository-path || "/documents/" || $data//collection/text()
    let $collectionPrefix := doc($teiEditor:data-repository-path || "/documents/" || $data//collection/text() || ".xml")//docPrefix/text()
(:    let $docIdPrefix := $teiEditor:appVariables//idPrefix[@type='document']/text():)
    let $docIdList := for $id in $doc-collection//tei:TEI[contains(./@xml:id, $collectionPrefix)]
        return
        <item>
        {substring-after($id/@xml:id, $collectionPrefix)}
        </item>

let $logEventTEST := teiEditor:logEvent("document-new-TEST" , 'test-new-doc', (),
                        "Test:" || $teiEditor:library-path || " created in Collection " || $data//collection/text() || " by " || $currentUser)


let $last-id:= fn:max($docIdList)
let $newDocId := $collectionPrefix || fn:sum(($last-id, 1))
let $newDocUri := $teiEditor:baseUri || "/" || "documents" ||"/" || $newDocId

let $filename := $newDocId || ".xml"


   let $storeNewFile := xmldb:store($doc-collection-path, $filename, $template)

   let $changeMod := sm:chmod(xs:anyURI(concat($doc-collection-path, "/", $filename)), "rw-rw-r--")
   let $changeGroup := sm:chgrp(xs:anyURI(concat($doc-collection-path, "/", $filename)), $data//collection/text())

   let $updateId := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/@xml:id
                            with $newDocId
  let $updateTitle := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/text()
                            with $data//title/text()
  let $updateTypeAtt := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:teiHeader/tei:profileDesc/tei:textClass/tei:catRef/@ref
                            with $data//typeAttributeValue/text()
let $updateTypeText := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:teiHeader/tei:profileDesc/tei:textClass/tei:catRef/text()
                            with $data//scriptTextValue/text()

let $updateMainLang := if (string-length($data//langAttributeValue/text()) > 0) then
                                update replace  util:eval( "doc('" || $doc-collection-path || "/" || $filename
                                ||"')")/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msContents/tei:msItem/tei:textLang/@mainLang
                                with $data//langAttributeValue/text()
                            else ()
(:Update IDs and references to ID with ID of new doc:)

let $updateSurfaceID := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:sourceDoc/tei:surface/@xml:id
                            with $newDocId || "-surface1"

let $updateLayoutID := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:layoutDesc/tei:layout/@xml:id
                            with $newDocId || "-layout1"
let $updateLayoutCorresp := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:layoutDesc/tei:layout/@corresp
                            with "#" || $newDocId || "-surface1"
let $updateMsItemID := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msContents/tei:msItem/@xml:id
                            with $newDocId || "-msItem1"
let $updateDivPartCorresp := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:text/tei:body/tei:div/tei:div[@type="textpart"]/@corresp
                            with "#" || $newDocId || "-surface1"






let $creationNode :=
    <change who="{$currentUser}" when="{$now}">Creation of this file</change>

let $updateCreationChange := update replace util:eval( "doc('" || $doc-collection-path || "/" || $filename
                                ||"')")/tei:TEI/tei:teiHeader/tei:revisionDesc/tei:listChange/tei:change
                                with functx:change-element-ns-deep($creationNode, "http://www.tei-c.org/ns/1.0", "")




let $logEvent := teiEditor:logEvent("document-new" , $newDocId, (),
                        "New document " || $newDocId || " created in Collection " || $data//collection/text() || " by " || $currentUser)
    return
    <result><newDocId>{ $newDocId }</newDocId>
    <sentData>{ $data }</sentData>
    <newList>{ teiEditor:listDocuments() }</newList>
    </result>
};

declare function teiEditor:newDocumentFromExternalResource($data, $project) {
    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)
    let $template := collection( $teiEditor:library-path || '/data/teiEditor/docTemplates')//.[@xml:id=$data//template/text()]
    let $doc-collection := collection($teiEditor:data-repository-path || "/documents/" || $data//collection/text())
    let $doc-collection-path := $teiEditor:data-repository-path || "/documents/" || $data//collection/text()
    let $collectionPrefix := doc($teiEditor:data-repository-path || "/documents/" || $data//collection/text() || ".xml")//docPrefix/text()
(:    let $docIdPrefix := $teiEditor:appVariables//idPrefix[@type='document']/text():)
    let $docIdList := for $id in $doc-collection//tei:TEI[contains(./@xml:id, $collectionPrefix)]
        return
        <item>
        {substring-after($id/@xml:id, $collectionPrefix)}
        </item>



(:Get document from external resource:)
let $sourceUri := $data//externalResource/text()
let $externalResourceDetails := $teiEditor:externalResources//.[@xml:id=$sourceUri]
let $UriPrefix := $externalResourceDetails/url[@type='teiDocPrefix']/text()
let $UriSuffix := $externalResourceDetails/url[@type='teiDocSuffix']/text()
let $externalDocId := $data//docId/text()
let $externalDocUri := $data//docUri/text()

let $logEventTEST := teiEditor:logEvent("document-new-TEST" , 'test-new-doc', (),
                        "$UriPrefix || $externalDocId || $UriSuffix:" || $UriPrefix || $externalDocId || $UriSuffix || " $externalDocId" || $externalDocId || " by " || $currentUser)


let $url4httpRequest := 
                    if($externalDocUri !='' ) then 
                            $externalDocUri || ".xml"
                            else if ($externalDocId != "") then
                            $UriPrefix || $externalDocId || $UriSuffix
                            else ($UriPrefix || $externalDocId || $UriSuffix)
                            
                    
let $http-request-data := <request xmlns="http://expath.org/ns/http-client"
    method="GET" href="{$url4httpRequest}"/>




    let $responses :=
    http:send-request($http-request-data)

let $logEventTEST := teiEditor:logEvent("document-new-from-External-resource" , 'test-new-docdddd', <data>{ $responses }</data>,
                        "$responses:" || "ee" || " created in Collection " || $data//collection/text() || " by " || $currentUser )


let $response :=
    <results>
      {if ($responses[1]/@status ne '200')
         then
             <failure>{$responses[1]}</failure>
         else
           <success>
             {$responses[2]}
             {'' (: todo - use string to JSON serializer lib here :) }
           </success>
      }
    </results>

        
(:let $newDocFromExternalResource := $response//*[local-name()="success"]:)

let $newDocFromExternalResource := $response//*[local-name()='TEI']


let $last-id:= fn:max($docIdList)
let $newDocId := $collectionPrefix || fn:sum(($last-id, 1))
let $newDocUri := $teiEditor:baseUri || "/" || $collectionPrefix ||"/" || $newDocId

let $filename := $newDocId || ".xml"


   let $storeNewFile := 
   xmldb:store($doc-collection-path, $filename, $newDocFromExternalResource)

   let $changeMod := sm:chmod(xs:anyURI(concat($doc-collection-path, "/", $filename)), "rw-rw-r--")
   let $changeGroup := sm:chgrp(xs:anyURI(concat($doc-collection-path, "/", $filename)), $data//collection/text())

   let $updateId := if(util:eval( "doc('" || $doc-collection-path ||"/" || $filename||"')")/tei:TEI/@xml:id) then
                            (update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/@xml:id
                            with $newDocId)
                            else 
                            (update insert attribute xml:id {$newDocId} into util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI)
  
(:let $updateTypeAtt := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:teiHeader/tei:profileDesc/tei:textClass/tei:catRef/@ref
                            with $data//typeAttributeValue/text()
:)
(:let $updateTypeText := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:teiHeader/tei:profileDesc/tei:textClass/tei:catRef/text()
                            with $data//scriptTextValue/text()
:)
(:let $updateMainLang := if (string-length($data//langAttributeValue/text()) > 0) then
                                update replace  util:eval( "doc('" || $doc-collection-path || "/" || $filename
                                ||"')")/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msContents/tei:msItem/tei:textLang/@mainLang
                                with $data//langAttributeValue/text()
                            else ():)
(:Update IDs and references to ID with ID of new doc:)

let $updateSurfaceID := 
                                if(util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:sourceDoc/tei:surface/@xml:id) then
                                update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:sourceDoc/tei:surface/@xml:id
                            with $newDocId || "-surface1"
                            else
                            if (util:eval( "doc('" || $doc-collection-path ||"/" || $filename ||"')")/tei:TEI/tei:sourceDoc/tei:surface)
                            then (
                            update insert attribute xml:id {$newDocId || "-surface1"} into util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:sourceDoc/tei:surface
                            )(:INSERT @xml:id:)
                            else if (util:eval( "doc('" || $doc-collection-path ||"/" || $filename ||"')")/tei:TEI/tei:sourceDoc)
                            then (
                            update insert 
                            functx:change-element-ns-deep(
<node>
                            <tei:surface xml:id="{$newDocId || '-surface1'}"></tei:surface>
</node>
, "http://www.tei-c.org/ns/1.0", "")/node()
into
                            util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:sourceDoc
                            )(:Insert /surface:)
                            else (
                            update insert 
                            functx:change-element-ns-deep(
<node>
    <tei:sourceDoc>
        <tei:surface xml:id="{$newDocId || '-surface1'}" ana="front-face">
            <desc>Main written surface of the monument</desc>
       </tei:surface>
   </tei:sourceDoc>
</node>
                            , "http://www.tei-c.org/ns/1.0", "")/node()
                            following
                            util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:teiHeader
                            )(:insert sourceDoc/surface/@xml:id='':)

let $updateLayoutID := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:layoutDesc/tei:layout/@xml:id
                            with $newDocId || "-layout1"
                            
                            
let $updateLayoutCorresp := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:layoutDesc/tei:layout/@corresp
                            with "#" || $newDocId || "-surface1"
let $updateMsItemID := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msContents/tei:msItem/@xml:id
                            with $newDocId || "-msItem1"
let $updateDivPartCorresp := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:text/tei:body/tei:div/tei:div[@type="textpart"]/@corresp
                            with "#" || $newDocId || "-surface1"






let $creationNode :=
    <change who="{$currentUser}" when="{$now}">Creation of this file</change>

let $updateCreationChange := update replace util:eval( "doc('" || $doc-collection-path || "/" || $filename
                                ||"')")/tei:TEI/tei:teiHeader/tei:revisionDesc/tei:listChange/tei:change
                                with functx:change-element-ns-deep($creationNode, "http://www.tei-c.org/ns/1.0", "")




let $logEvent := teiEditor:logEvent("document-new" , $newDocId, (),
                        "New document " || $newDocId || " created in Collection " || $data//collection/text() || " by " || $currentUser)
    return
    <result><newDocId>{ $newDocId }</newDocId>
    <sentData>{ $data }</sentData>
    <newList>{ teiEditor:listDocuments() }</newList>
    </result>
};

declare function teiEditor:loginForm($project, $username){

<div xmlns="http://www.w3.org/1999/xhtml" data-template="templates:surround"
    data-template-with="./templates/page.html" data-template-at="content">

   <div class="container">
   <div class="row">
            <div class="container-fluid">
                 <h2>Welcome { data(sm:id()//sm:username) }!</h2>
                 { if ($username != 'guest') then
                        <p>Your account does not include access to the Editor. Please contact <a href="mailto:vincent.razanajao@u-bordeaux-montaigne.fr">vincent.razanajao@u-bordeaux-montaigne.fr</a>.</p>
                 else
                 <p>Access not authorized. Please log in with your account from the <a href="/" target="_self">homepage</a>. 
                 </p>}
                 <!--<form class="form form-horizontal" action="" method="POST">
                        <div class="modal-body">
                            <div class="form-group">
                                <label class="control-label col-sm-2">
                                    Username
                                </label>
                                <div class="col-sm-10">
                                    <input type="text" name="user" class="form-control" value="{$username}">{$username}</input>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-sm-2">
                                    Password
                                </label>
                                <div class="col-sm-10">
                                    <input type="password" name="password" class="form-control"/>

                                </div>
                            </div>

                                <div class="col-sm-12">
                                    <a class="pull-right" href="/admin/new-user/" >Create a user</a>
                                </div>

                        </div>
                        <div class="modal-footer">
                            <button type="submit" class="btn btn-primary">Login</button>
                        </div>
                        <input type="hidden" name="duration" value="P7D"/>

                    </form>
                    -->
                </div>
</div></div></div>   };

declare function teiEditor:listsPlacesAsCombo(){
    let $places := doc($teiEditor:data-repository-path || "/places/" || $teiEditor:project || "/list.xml")

    return
     <select id="placeList" name="placeList">
                    {for $items in $places//Place
                    return
                        <option value="{data($items/@rdf:about)} {data($items/skos:exactMatch/@rdf:resource)}">
                        {$items/skos:prefLabel[@xml:lang="en"]/text()} </option>}</select>
        };

 declare function teiEditor:projectLangDropDown($selectedLang as xs:string,
                                                                            $docid as xs:string,
                                                                            $elementNickname as xs:string,
                                                                            $indexNo as xs:string){
                <select id="lang_{$elementNickname}_{$indexNo}" name="lang_{$elementNickname}_{$indexNo}" class="langSelector">
                    {for $lang in $teiEditor:languages//lang
                            return
                            if($lang=$selectedLang) then
                                     <option value="{$lang}"
                                     selected="selected">{$lang}</option>
                               else
                                     <option value="{$lang}">{$lang}</option>

                      }
                      </select>
                };
declare function teiEditor:listPlacesOfProvenance($docId){
let $teiDoc := util:eval( "$teiEditor:doc-collection/id('"
             ||$docId ||"')" )

let $plural := if (count($teiDoc//tei:msFrag/tei:history/tei:provenance/tei:placeName) >1) then "s" else ()
return
<div class="panel panel-default">
    <div class="panel-body">
        <h4>Place{$plural} of provenance</h4>
        {
        if (count($teiDoc//tei:msFrag/tei:history/tei:provenance/tei:placeName) >1) then (
                       <ul>
                       {for $placeOfProvenance at $pos in $teiDoc//tei:msFrag/tei:history/tei:provenance/tei:placeName
                                order by $pos
                                return
                                
                              <li>
                              <span>Fragment {$pos}: </span><span>{$placeOfProvenance}</span>
                              
                              </li>
                              }
                              </ul>
                              )
        else ( 
                let $placeName := $teiDoc//tei:msFrag/tei:history/tei:provenance/tei:placeName/text()
                let $placeURI := if (data($teiDoc//tei:msFrag/tei:history/tei:provenance/tei:placeName/@ref) != "") then
                        data($teiDoc//tei:msFrag/tei:history/tei:provenance/tei:placeName/@ref)
                        else ("no URI")
                 return
        
           <div>
           <p>{ $placeName }</p>
           <em>{ $placeURI }</em>
           <a class="nav-link" id="pills-textbearer-tab" data-toggle="pill" href="#nav-textbearer" role="tab" aria-controls="pills-textbearer" aria-selected="false">
<i class="glyphicon glyphicon-edit"/>Edit place{$plural} in 'Support' tab</a>
           </div>                   
               )
                              }
           
           </div>  
           </div>
};
declare function teiEditor:placesManager($docId){
let $teiDoc := util:eval( "$teiEditor:doc-collection/id('"
             ||$docId ||"')" )
        let $placeOfOrigin := $teiDoc//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origPlace
      
      return
        <div class="row">
             
                 <div class="sideToolPane col-sm-3 col-md-3 col-lg-3">
                     <div class="panel panel-default">
                          <div class="panel-body">
                          <h4>List of places linked to this document</h4>
                          {teiEditor:placesList($docId)}
                          
                      <div id="add-place" class="btn-group xmlToolBar"
                            role="group" aria-label="..." >
                        <div class="panel panel-default">
                           <div class="panel-heading collapsed"  data-toggle="collapse"  href="#add-places-panel">Link a place to the document</div>
                           <div id="add-places-panel" class="panel-collapse">
                                <div class="panel-body">
                                <input type="text" class="form-control hidden"
                                     id="newPlaceUri" 
                                     name="newPlaceUri"
                                     />
                                <span class="subSectionTitle">Search project's places</span>
                                <input type="text" class="form-control projectPlacesLookUp" id="projectPlacesLookUp" name="projectPlacesLookUp" autocomplete="on"
                                placeholder="Start to enter a place name or a place ID"/>
                                <span id="projectPlaceDetailsPreview"/>
                               <span id="newProjectPlaceTypeContainer" class="hidden">
                               {if($teiEditor:appVariables//placeRelationToDocTypesUri/text() !="") then skosThesau:dropDownThesauXML($teiEditor:appVariables//placeRelationToDocTypesUri/text(), 'en', 'Type', 'inline', 1, 1, 'uri')
                               else "Error. Variable placeRelationToDocTypesUri is not set in the application general paramaters"}
                               </span>
                               <button id="addProjectPlaceButtonDocPlaces" class="btn btn-success hidden" onclick="addProjectPlaceToDoc('{$teiEditor:docId}')" appearance="minimal" type="button">Add place to document<i class="glyphicon glyphicon glyphicon-saved"></i></button>
                               <!-- 
                                <div id="placeLookUpPanel" class="sectionInPanel"><span class="subSectionTitle">Add from Pelagios datasets</span>
                             <div class="form-group">
                             
                                    <label for="placesLookupInputDocPlaces">Search in <a href="http://pelagios.org/peripleo/map" target="_blank">Pelagios Peripleo</a></label>
                                     <input type="text" class="form-control"
                                     id="placesLookupInputDocPlaces" 
                                     name="placesLookupInputDocPlaces"
                                     />
                                     
                              </div>
                       <div class="">
                             <iframe id="placesLookupInputDocPlaces_peripleoWidget" allowfullscreen="true" height="380" src="" style="display:none;"> </iframe>
                                     <div id="previewMapDocPlaces" class="hidden"/>
                                     <div id="placePreviewPanelDocPlaces" class="hidden"/>
                                     <span id="newPlaceTypeContainer" class="hidden">
                                     <h4>Add place to document</h4>
                               {skosThesau:dropDownThesauXML('c22114', 'en', 'Relation', 'row', (), 1, ())}
                               </span>
                                     <button id="addNewPlaceButtonDocPlaces" class="btn btn-success hidden" onclick="addPlaceToDoc('{$teiEditor:docId}')" appearance="minimal" type="button">Add <i class="glyphicon glyphicon glyphicon-saved"></i></button>
                         </div>
                     </div>-->
                   </div>
                 </div>
               </div>
             </div>
           </div>
         </div>
         </div>
                    <div class="col-sm-8 col-md-8 col-lg-8">                                      
                   
                   <div id="editorMap"></div>
                               <div id="positionInfo"/>
            <div id="savedPositionInfo">Click to store current position: </div>
                   <!--
                   <div id="mapid"></div>
                   -->
                   </div>

 

   
               </div>
};

declare function teiEditor:convertIntoEpiDoc($textInput as xs:string){
         let $textBackup :=$textInput
         let $quote := "&#34;"
         
         
(: Clean tabs:)
(:    text = text.toString().replace(/\t+/g, '')        :)
    let $textInput:= replace($textInput, "\t+", "") 
      
(:Clean Former line numbers:)
(:   let $regex := "(n=)(&quot;)([0-9]*)&quot;(/>\s?)([0-9]*)(\s?)"
    let $replacement := "$1&quot;$3&quot;$4"
:)
let $regex := "([0-9]*)"
    let $replacement := ""
let $textInput := replace($textInput,
                            $regex,
                            $replacement, "")      
      
(:New lines:)
let $textInput:= if (contains($textInput, "|")) then replace($textInput, "\|", "/") 
                                  else $textInput

let $lineSeparator := if (contains($textInput, "/")) then "/"
                                   
                                  else "\n"
let $lineNumber := count(tokenize($textInput,  $lineSeparator))




let $textInput := 
"<lb n='1'/>" || string-join(
                            (for $line at $count in tokenize($textInput, $lineSeparator)
                                
                                let $newLine :=
                                    if (contains($line, "-")) then
                                    
                                     replace($line, '-', '') || codepoints-to-string(10) || "<lb n='"||
                                        $count +1 || "' break='no'/>"
                                else 
                                    $line || codepoints-to-string(10) || 
                                    (if ($count < $lineNumber)
                                        then "<lb n='"||$count +1 || "'/>"
                                         else ()
                                    )
                            return 
                            $newLine),
                    "")
   



   

(::)
(:let $regex := "\\n|\\r":)
(:let $replacement := '\\n' || "ff":)
(:let $textInput := replace($textInput,:)
(:                            $regex,:)
(:                            $replacement, 'm':)
(:                       ):)

(::)
(:Corrections:)
(::)
(:<t>]:)
let $regex := "<(\w*)>"
let $replacement := "<supplied reason='omitted'>$1</supplied>"
let $textInput := replace($textInput,
                            $regex,
                            $replacement, "")

let $regex := "&lt;(\w*)&gt;>"
let $replacement := "<supplied reason='omitted'>$1</supplied>"
let $textInput := replace($textInput,
                            $regex,
                            $replacement, "")



(::)
(:Superfluous:)
(::)
let $regex := "\{(\w*)\}"
let $replacement := "<surplus>$1</surplus>"
let $textInput := replace($textInput,
                            $regex,
                            $replacement, "")

(::)
(:Gaps and Lacunaes:)
(::)

(:Line in Lacuna [— — — —]:)
let $regex := "\[(— — — —)\]"
let $replacement := "<gap unit='line'/>"
let $textInput := replace($textInput,
                            $regex,
                            $replacement, "")

(:let $regex := "\-"   
let $replacement := "<gap unit='line'/>"
let $textInput := replace($textInput,
                            $regex,
                            $replacement, "")
:)

(:Basic Abbreviations:)
let $regex := '(\w*)\((\w*)\)'
let $replacement := '<expan><abbr>$1</abbr><ex>$2</ex></expan>'
let $textInput := replace($textInput,
                            $regex,
                            $replacement, "")

(:
(\:Abbreviations in lacunae:\)

let $regex := "\[(\w*)\((\w*)\)(\])"
let $replacement := "<supplied reason='lost'><expan><abbr>$1</abbr><ex>$2</ex></expan></supplied>"
let $textInput := replace($textInput,
                            $regex,
                            $replacement, "")

:)
(:Abbreviation with uncertain resolution:)
let $regex := "(\w*)\((\w*\?)\)"
let $replacement := "<expan><abbr>$1</abbr><ex cert='low'>$2</ex></expan>"
let $textInput := replace($textInput,
                            $regex,
                            $replacement, "")

(:Lacunae not ended in original text:)
let $regex := "\[(\w*)\s*(— — —)+"
let $replacement := "<supplied reason='lost'>$1</supplied>ss<gap reason='lost' extent='unknown'/>"
let $textInput := replace($textInput,
                            $regex,
                            $replacement, "")

(:supplied:)
(:let $textInput := replace($textInput, '\[', "<supplied reason='lost'>"):)
(:let $textInput := replace($textInput, '\]', '</supplied>'):)
let $regex := "(\[)(\w*([^\[])*)(\])"
let $replacement := "<supplied reason='lost'>$2</supplied>"
let $textInput := replace($textInput,
                            $regex,
                            $replacement, "")
(:
(\:Correction to supplied:\)
(\:let $textInput := replace($textInput, '\[', "<supplied reason='lost'>"):\)
(\:let $textInput := replace($textInput, '\]', '</supplied>'):\)
let $regex := "(\])(.*([^\[])*)(\[)"
let $replacement := "</supplied>$2<supplied reason='lost'>"
let $textInput := replace($textInput,
                            $regex,
                            $replacement, "")

:)

(:Dotted letters:)
let $regex := '(\w)̣'
let $replacement := '<unclear>$1</unclear>'
let $textInput := replace($textInput,
                            $regex,
                            $replacement, "")
 
 
 
 
 
 
    let $logs := collection("xmldb:exist:///db/apps/patrimoniumData" || '/logs')
    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:real/sm:username)
    let $log :=
<data>
    <log type="regex-test" when="{$now}" what="test-regex" who="{$currentUser}"><description>{$textInput}</description></log>
 </data>
 let $logTrigger :=
    update insert
         $log/node()
         into $logs/rdf:RDF/id('all-logs')
         

return 
        try { 
            parse-xml('<ab>' || replace($textInput, "'", '"') || "</ab>")
            }
          catch err:FODC0006 { <ab>{
          "XML Error during conversion: text could not be processed:" || $teiEditor:nl || 
          $textBackup } </ab>}


};

declare function teiEditor:getTextDivFromXml($externalDocUri as xs:string){
    let $url4httpRequest := 
                    if($externalDocUri !='' ) then 
                               (if(contains($externalDocUri, 'edh-www.adw.uni-heidelberg.de/edh/inschrift/')) then
                                            $externalDocUri || ".xml"
                               else if(contains($externalDocUri, 'http://papyri.info/ddbdp')) then
                                            $externalDocUri || "/source"
                               else if(contains($externalDocUri, 'http://mama.csad.ox.ac.uk/monuments/MAMA-XI')) then
                                            (
                                            let $externalDocId := substring-before(substring-after($externalDocUri, "http://mama.csad.ox.ac.uk/monuments/"), ".html")
                                            return 
                                            "http://mama.csad.ox.ac.uk/xml/" || $externalDocId || ".xml"
                                            )
                                            else())
                            else ()

let $logEvent := teiEditor:logEvent("test-import" , "vdrazanajao", <description>{ "$url4httpRequest: " || $url4httpRequest }</description>,
                        "$url4httpRequest: " || $url4httpRequest)


    let $http-request-data := <request xmlns="http://expath.org/ns/http-client"
        method="GET" href="{$url4httpRequest}"/>
    let $responses :=
        http:send-request($http-request-data)
    let $response :=
        <results>
          {if ($responses[1]/@status ne '200')
             then
                 <failure>{$responses[1]}</failure>
             else
               <success>
                 {$responses[2]}
                 {'' (: todo - use string to JSON serializer lib here :) }
               </success>
          }
        </results>
    let $textDiv := $response//tei:div[@type='edition']
    
    return $textDiv
};

declare function teiEditor:edcsMatcher($edcsID as xs:string){
           let $cleanEdcsID := if(contains($edcsID, "EDCS-")) then substring-after($edcsID, "EDCS-") else $edcsID
           let $url4httpRequest := "https://www.trismegistos.org/dataservices/texrelations/xml/" || $cleanEdcsID || "?source=edcs"
           
           let $http-request-data := <request xmlns="http://expath.org/ns/http-client"
          method="GET" href="{$url4httpRequest}">
              
          </request>
          
          let $responses := 
          http:send-request($http-request-data)
          let $response :=
          <results>
            {if ($responses[1]/@status ne '200')
               then
                   <failure>{$responses[1]}</failure>
               else
                 <success>
                   {$responses[2]}
                   {'' (: todo - use string to JSON serializer lib here :) }
                 </success>
            }
          </results>
          
          let $xmlDocUri :=
              if(contains($response//link/@cp, "EDH")) then
                  let $docId := $response//link[@cp="EDH"]/text() 
                  let $uri := "https://edh-www.adw.uni-heidelberg.de/edh/inschrift/" || $docId || ".xml"
                  return $uri
              else if(contains($response//link/@cp, "ddpdb")) then
                  let $docId := $response//link[@cp="EDH"]/text() 
                  let $uri := "http://papyri.info/ddbdp/" || $docId || "/source"
                  return $uri    
              else("Cannot get any uri")
              
          return 
              $xmlDocUri
};
declare function teiEditor:buildDocumentUri($docId as xs:string){
    $teiEditor:baseUri || "/documents/" || $docId  
};

declare function teiEditor:searchProjectPeopleModal(){

    <div id="dialogAddPeopleToDoc" title="Add a Person to the document" class="modal fade" tabindex="-1" style="display: none;">

            <!-- Modal content-->
            <div class="modal-content modal4editor">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"/>
                    <h4 class="modal-title">Search in people's project</h4>
                </div>
                <div class="modal-body">
                        <div class="form-group">
                                  <label for="projectPeopleLookup">Search in project's people</label>
                                   <input type="text" class="form-control projectPeopleLookup"
                                   id="projectPeopleLookup"
                                   name="projectPeopleLookup"
                                   autocomplete="on"
                                   />
                        </div>
                        <div id="projectPeopleDetailsPreview" class=""/>
                        <input id="currentDocumentUri" type="text" class="hidden"/>
                        <input id="selectedPeopleUri" type="text" class="hidden"/>
                  </div>
                  <div class="modal-footer">
                      <button  id="addPersonToDocButton" class="btn btn-primary pull-left" type="submit" onclick="addProjectPersonToDoc()">Validate</button>
                        <button type="button" class="btn btn-default" onclick="closeAddPersonToDocModal()">Cancel</button>
                    </div>
                  
                    <!--                <a href="javascript: void(0);" onclick="tests()">Test</a>        -->

                </div>
</div>

};

declare function teiEditor:TMTextRelations($TMNo as xs:string, $projectCode){
           
           let $url4httpRequest := "https://www.trismegistos.org/dataservices/texrelations/uri/" || $TMNo
           
           let $http-request-data := <request xmlns="http://expath.org/ns/http-client"
          method="GET" href="{$url4httpRequest}">
              
          </request>
          
          let $responses := http:send-request($http-request-data)
          let $response :=
          <results>
            {if ($responses[1]/@status ne '200')
               then
                   <failure>{$responses[1]}</failure>
               else
                 <success>
                   {$responses[2]}
                   {'' (: todo - use string to JSON serializer lib here :) }
                 </success>
            }
          </results>
          
          let $result :=
          if($projectCode = "all")
           then $responses
           else $responses[1]
          
              
          return
              $result
(:          <data>{ $TMNo}:)
(:              {$result}</data>:)
};

declare function teiEditor:epiConverter(){

<div xmlns="http://www.w3.org/1999/xhtml" data-template="templates:surround"
    data-template-with="./templates/page.html" data-template-at="content">

   <div class="container">
            <div class="row">
                     <div class="container-fluid">
                            <div class="form-group row">
                                       <label for="langSource">Select a script</label>
                                       <select id="langSource" name="langSource">
                                            <option value="grc">Ancient Greek</option>
                                            <option value="la">Latin</option>
                                            <option value="egy-Egyd">Ancient Egyptian in demotic script (latin transliteration)</option>
                                            <option value="egy-Egyh">Ancient Egyptian in hieratic script (latin transliteration)</option>
                                            <option value="egy-Egyp">Ancient Egyptian in hieroglyphic script (latin transliteration)</option>
                                       </select>
       
                           </div>
                            <div class="form-group row">
                                        <label for="importSource">Select source format</label>
                                        <select id="importSource" name="importSource">
                                             <option value="petrae">PETRAE</option>
                                             <option value="edr">EDR</option>
                                             <option value="edcs">EDCS / EDH</option>
                                             <option value="phi">PHI</option>
                                        </select>
                                
                                <input id="textImportMode" name="textImportMode" type="text" class="hidden" value="newText"/>
                            </div>
                            <!--
                           <label for="text2import">Paste text to import below</label>

                            <textarea class="form-control" name="text2import" id="text2import" row="10" ></textarea>
                            -->
                     
                     <div class="col-xs-5 col-sm-5 col-md-5">
                            <label for="text2beConvertedEditor">Epigraphic Text input</label>
                            <div class="text2importInput">
                                <div id="text2beConvertedEditor"/>
                            </div>
                    </div>
                    <div class="col-xs-7 col-sm-7 col-md-7">           
                     <label for="text2importXMLPreview">HTML preview</label>
                               <div id="textPreviewHTML-9999" class="textPreviewHTML"/>
                          
                     </div>
 
                    </div>
                     <div class="row">
                     
                                <label for="text2importXMLPreview">XML Preview</label>
                                { teiEditor:annotationMenuEpigraphy("1")}
                                <div id="xml-editor-1"/>
                    </div>
                    </div>
</div>
 <link rel="stylesheet" href="$ausohnum-lib/resources/css/teiEditor.css"/>
        <link href="$ausohnum-lib/resources/css/skosThesau.css" rel="stylesheet" type="text/css"/>
        <link href="/resources/css/editor.css" rel="stylesheet" type="text/css"/>
        
        
        
     

  

        <script type="text/javascript" src="$ausohnum-lib/resources/scripts/teiEditor/teiEditorEvents.js"/>
        <script type="text/javascript" src="$ausohnum-lib/resources/scripts/teiEditor/ancientTextImportRules.js"/>
         <script type="text/javascript" src="$ausohnum-lib/resources/scripts/teiEditor/tei2Html4Preview.js"/>
        <script type="text/javascript" src="$ausohnum-lib/resources/scripts/teiEditor/tei2leiden.js"/>
<script type="text/javascript">
editor_options ={{
    enableBasicAutocompletion: true,
                    enableSnippets: true,
                    enableLiveAutocompletion: true,
    
        //mergeUndoDeltas: "always",
                    //maxLines: Infinity,
                    behavioursEnabled: true, // autopairing of brackets and tags
                    wrapBehavioursEnabled: false,
                    showLineNumbers: true, 
                    wrap: 'free',
                    showPrintMargin: false,
                    printMarginColumn: false,
                    printMargin: false,
                    //fadeFoldWidgets: true,
                    //showFoldWidgets: true,
                    showInvisibles: true,
                    showGutter: true, // hide or show the gutter 
                    displayIndentGuides: false,
                    cursorStyle: "wide",
                    //navigateWithinSoftTabs: false,
                    highlightGutterLine: true,
                    
                    //printMarginColumn: 20,
                    //printMargin: 70,
                    fontSize: 14,
                    fixedWidthGutter: false,
                    //showInvisibles: false,
                    newLineMode: 'auto',
                    maxLines: 30,
                    minLines: 10,
                    //enableBlockSelect: true
                    //printMarginColumn: true,
//                    printMarginColumn: false,
                    //readOnly: true,
                    
                    highlightSelectedWord: true,
                    wrapBehavioursEnabled: true,
                    highlightGutterLine: true
                    
                    //tabSize: 15
                    
}};

    var importEditor = ace.edit("text2beConvertedEditor");
    importEditor.setOptions(editor_options);
    var text2importXMLPreview = ace.edit("xml-editor-1");
    text2importXMLPreview.setOptions(editor_options);
       
       text2importXMLPreview.session.setMode("ace/mode/xml");
      
      text2importXMLPreview.setOptions({{
            maxLines: Infinity
            }});

$("#text2beConvertedEditor").keydown(function(){{
   
   
        var importEditor = ace.edit("text2beConvertedEditor");
       var importEditorPreview = ace.edit("xml-editor-1");
       
    importEditor.getSession().on('change', function(){{

         //var text2convert = $(this).val();

                var editorPreview = ace.edit("xml-editor-1");
                var importSource = $( "#importSource option:selected" ).val();
                
                editorPreview.getSession().setValue(
                    convertAncientText(importEditor.getValue(), importSource));
                $("#textPreviewHTML-9999").html(tei2Html4Preview(
                    convertAncientText(importEditor.getValue(), importSource)));    
            /*                editorPreview.getSession().setValue(convertEDR2TEI(importEditor.getValue()));*/
}});
       
        }});
 
 $("#xml-editor-1").keydown(function(){{
    var importEditorPreview = ace.edit("xml-editor-1");
    
    importEditorPreview .getSession().on('change', function(){{
                var importSource = $( "#importSource option:selected" ).val();
                
                $("#textPreviewHTML-9999").html(tei2Html4Preview(
                    convertAncientText(text2importXMLPreview.getValue(), importSource)));    
            /*                editorPreview.getSession().setValue(convertEDR2TEI(importEditor.getValue()));*/
}});
       
}});

</script>

</div>
};

declare function teiEditor:getEditionDivFromDoc($docId as xs:string, $project as xs:string){
let $doc-collection := collection('/db/apps/' || $project || 'Data/documents')
let $teiDoc := $doc-collection/id($docId)
return
    <data>
        {
        if (exists($teiDoc//*[local-name() = 'div'][@type="edition"]/*[local-name() = 'div'][@type="textpart"])) then
            (
            for $text in $teiDoc/*[local-name() = 'text']/*[local-name()='body']/*[local-name() = 'div'][@type='edition']//*[local-name()='div'][@type='textpart']
            return
            $text
    (:        $text/*[local-name()='ab']):)
            )
         else (
               <ab>{$teiDoc/*[local-name() = 'text']/*[local-name()='body']/*[local-name() = 'div'][@type='edition']//*[local-name()='ab']/node()}</ab>
               )
        }     
    </data>
};

declare function teiEditor:displayOpenArchivesFlux($node as node(), $model as map(*), $europeanProject_id as xs:string)  as element(div) {
   
   let $url4httpRequest := encode-for-uri('https://api.archives-ouvertes.fr/search/?wt=xml-tei&amp;q=europeanProjectReference_s:" ' || $europeanProject_id || '"')
   let $http-request-data := <request xmlns="http://expath.org/ns/http-client"
    method="GET" href="{$url4httpRequest}"/>

    let $responses := try {
            http:send-request($http-request-data)
            }
            catch * { "error"}
    let $response :=
    <results>
      {if ($responses[1]/@status ne '200')
         then
             <failure>{$responses[1]}</failure>
         else
           <success>
             {$responses[2]}
             {'' (: todo - use string to JSON serializer lib here :) }
           </success>
      }
    </results>      
    return 
    <div>{ $response }</div>
    
};

declare function teiEditor:repositoryManager($docId as xs:string?){
   
  let $objectRepositoriesUri := $teiEditor:appVariables//objectRepositoriesUri/text()
  let $msFragList := if($docId = "") then $teiEditor:teiDoc//tei:msFrag
        else util:eval( "$teiEditor:doc-collection/id('"
             ||$docId ||"')")//tei:msFrag
  
  return
<div id="repositoryPanel" class="teiElementGroup">

   <div class="TeiElementGroupHeaderBlock">
   <span class="labelForm">Repository</span>
   <button id="docRepositoryAddItem" class="btn btn-primary addItem" onclick="openDialog('dialogAddRepository')" appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-plus"></i></button>
    <div id="repositoryDetailsPanel">
        {for $frag at $index in $msFragList
            let $repositoryUri := data($frag//tei:repository/@ref)
            let $townName := if(normalize-space($frag//tei:settlement/@ref) != "") then skosThesau:getLabel($frag//tei:settlement/@ref, $teiEditor:lang) else()
            let $repositoryName := if(normalize-space($frag//tei:repository/@ref) != "") then skosThesau:getLabel($frag//tei:repository/@ref, $teiEditor:lang) else()
  
        return
        <div id="repositoryDetails{$index}" class="teiElementGroup">
            <div id="repository_display_{$index}_1" class="">
                   <div class="TeiElementGroupHeaderInline">
                       <span class="labelForm">Town<span class="teiInfo">
                     <a title="TEI element: "><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                     </span></span>
                   { $townName }
                   </div>
                   <div class="TeiElementGroupHeaderInline">
                       <span class="labelForm">Museum<span class="teiInfo">
                     <a title="TEI element: "><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                     </span></span>
                   { $repositoryName }
                   </div>
                   <button id="editRepository{ $index }Button" class="btn btn-xs btn-primary editbutton pull-right"
             onclick="openDialog('dialogEditRepository{ $index }')"
                    appearance="minimal" type="button"><i class="glyphicon glyphicon-edit
                              editConceptIcon"></i></button>
                              
            { teiEditor:displayElement("msFragmentMainIdno", $teiEditor:docId, $index, ())}
            { teiEditor:displayElement("msFragmentAltIdentifier", $teiEditor:docId, $index, ())}
            
            </div>
    
    
    <div id="dialogEditRepository{ $index }" title="Edit Repository" class="modal fade" tabindex="-1" style="display: none;">

            <!-- Modal content-->
            <div class="modal-content modal4editor">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"/>
                    <h4 class="modal-title">Edit repository</h4>
                </div>
                <div class="modal-body">
                    <div>{
                    if(( $townName = "") and ($repositoryName = ""))
                            then "There is currently no Reposotiry"
                            else if ( $townName  = "") then ("No town - museum: " || $repositoryName) 
                            else if ( $repositoryName = "") then ("Town: " || $townName || " - no Museum")
                            else (<span><strong>Current repository</strong>: { $repositoryName} ({ $townName }) [{ $repositoryUri }]</span>)
                    }</div>
                    <br/>
                        <div class="form-group">
                                  <label for="repositoryLookup">Search another Repository</label>
                                   <input type="text" class="form-control repositoryLookup"
                                   id="repositoryLookup"
                                   name="repositoryLookup"
                                   />
                        </div>
                        <div id="repositoryDetailsPreview" class=""/>
                        <br/>
                        <input id="currentDocumentUri" type="text" class="hidden" value="{  teiEditor:buildDocumentUri($teiEditor:docId)  }"/>
                        <input id="repositoryUri" type="text" class="hidden"/>
                       <input id="repositoryLabel" type="text" class="hidden"/>
                       <input id="townRepositoryUri" type="text" class="hidden"/>
                       <input id="townRepositoryLabel" type="text" class="hidden"/>
                        <input id="countryRepositoryUri" type="text" class="hidden"/>
                        
                  </div>
                  <div class="modal-footer">
                      <button  id="updateRepositoryButton" class="btn btn-primary pull-left" type="submit" onclick="updateRepository('{ $index }')">Validate</button>
                        <button type="button" class="btn btn-default" onclick="closeDialog('dialogEditRepository{ $index }')">Cancel</button>
                    </div>
                  
                    <!--                <a href="javascript: void(0);" onclick="tests()">Test</a>        -->

                </div>
</div><!-- End of dialog -->
    
    
    </div>
        
 (:    END of loop on ListFrag        :)       
        }

            
    </div>

   </div>
     
    
    
    
    
    
    
    
    <div id="dialogAddRepository" title="Add a Repository to the document" class="modal fade" tabindex="-1" style="display: none;">

            <!-- Modal content-->
            <div class="modal-content modal4editor">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"/>
                    <h4 class="modal-title">Search a Repository</h4>
                </div>
                <div class="modal-body">
                        <div class="form-group">
                                  <label for="repositoryLookup">Search a Repository</label>
                                   <input type="text" class="form-control repositoryLookup"
                                   id="repositoryLookup"
                                   name="repositoryLookup"
                                   />
                        </div>
                        <div id="repositoryDetailsPreview" class=""/>
                       currentDocumentUri <input id="currentDocumentUri" type="text" class=""/>
                        repositoryUri<input id="repositoryUri" type="text" class=""/>
                       repositoryLabel <input id="repositoryLabel" type="text" class=""/>
                        townRepositoryUri<input id="townRepositoryUri" type="text" class=""/>
                       townRepositoryLabel <input id="townRepositoryLabel" type="text" class=""/>
                        <input id="countryRepositoryUri" type="text" class=""/>
                        
                          {skosThesau:dropDownThesauXML('thot-6197', 'en', 'noLabel', 'inline', 1, 1, ())}
                                                    
                        
                  </div>
                  <div class="modal-footer">
                      <button  id="addPersonToDocButton" class="btn btn-primary pull-left" type="submit" onclick="addProjectPersonToDoc()">Validate</button>
                        <button type="button" class="btn btn-default" onclick="closeDialog('dialogAddRepository')">Cancel</button>
                    </div>
                  
                    <!--                <a href="javascript: void(0);" onclick="tests()">Test</a>        -->

                </div>
</div>
</div>
};

declare function teiEditor:repositoryDetails($townName as xs:string, $repositoryName as xs:string, $index as xs:string){
 <div id="repositoryDetails{$index}" class="teiElementGroup">
            <div id="repository_display_{$index}_1" class="">
                   <div class="TeiElementGroupHeaderInline">
                       <span class="labelForm">Town<span class="teiInfo">
                     <a title="TEI element: "><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                     </span></span>
                   { $townName }
                   </div>
                   <div class="TeiElementGroupHeaderInline">
                       <span class="labelForm">Museum<span class="teiInfo">
                     <a title="TEI element: "><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                     </span></span>
                   { $repositoryName }
                   </div>
                   <button id="editRepository{ $index }Button" class="btn btn-xs btn-primary editbutton pull-right"
             onclick="openDialog('dialogEditRepository{ $index }')"
                    appearance="minimal" type="button"><i class="glyphicon glyphicon-edit
                              editConceptIcon"></i></button>
            </div>
</div>
};


declare function teiEditor:addRepositoryToDocument($data, $project){
    let $repositoryUri := $data//repositoryUri/text()
    let $repositoryLabel := $data//repositoryLabel/text()
    let $townUri := $data//townUri/text()
    let $townLabel := $data//townLabel/text()
    let $countryUri := $data//countryUri/text()
    let $countryLabel := $data//countryLabel/text()
    
    let $settlementNode := <node><settlement>
                            <placeName ref="{ $townUri }">{ $townLabel }</placeName>
                        </settlement></node>
   let $repositoryNode := <repository ref="{ $repositoryLabel }">{ $repositoryLabel }</repository>
   
   let $updateSettlement :=
        if(exists($teiEditor:teiDoc//tei:msIdentifier//tei:settlement))
            then (if(exists($teiEditor:teiDoc//tei:msIdentifier//tei:settlement/@ref))
                      then update value $teiEditor:teiDoc//tei:msIdentifier//tei:settlement/@ref with $townUri 
                    else update insert attribute ref { $townUri } into $teiEditor:teiDoc//tei:msIdentifier//tei:settlement
                    ,
                    update value $teiEditor:teiDoc//tei:msIdentifier//tei:settlement with $townLabel
                    )
           else update insert $settlementNode/node into $teiEditor:teiDoc//tei:msIdentifier
   let $updateRepository :=
        if(exists($teiEditor:teiDoc//tei:msIdentifier//tei:repository))
            then (if(exists($teiEditor:teiDoc//tei:msIdentifier//tei:repository/@ref))
                      then update value $teiEditor:teiDoc//tei:msIdentifier//tei:repository/@ref with $townUri 
                    else update insert attribute ref { $townUri } into $teiEditor:teiDoc//tei:msIdentifier//tei:repository
                    ,
                    update value $teiEditor:teiDoc//tei:msIdentifier//tei:settlement with $townLabel
                    )
           else update insert $repositoryNode/node following $teiEditor:teiDoc//tei:msIdentifier/tei:settlement
   let $updatedElement := teiEditor:repositoryManager($teiEditor:docId)
   return
        <data>
        <newContent>{ $teiEditor:teiDoc }</newContent>
        <updatedElement>{ $updatedElement }</updatedElement>
        </data>
        
};

declare function teiEditor:updateRepository($data, $project){
    let $docId := $data//docId/text()  
  let $repositoryUri := $data//repositoryUri/text()
    let $repositoryLabel := $data//repositoryLabel/text()
    let $townUri := $data//townUri/text()
    let $townLabel := $data//townLabel/text()
    let $index := $data//index/text()
    
    let $settlementNode := <node><settlement>
                            <placeName ref="{ $townUri }">{ $townLabel }</placeName>
                        </settlement></node>
   let $repositoryNode := <repository ref="{ $repositoryLabel }">{ $repositoryLabel }</repository>
   
   let $originalNodeSettlement :=util:eval( "$teiEditor:doc-collection/id('"
             ||$docId ||"')" || "//tei:msFrag//tei:msIdentifier//tei:settlement")

   let $updateSettlement :=
        if(exists($originalNodeSettlement))
            then ( 
                    update value $originalNodeSettlement/@ref with 
                      $townUri 
                     ,
                    update value $originalNodeSettlement/tei:placeName/text() with  
                        $townLabel
                    )
           else ()

let $originalNodeRepository:=util:eval( "$teiEditor:doc-collection/id('"
             ||$docId ||"')" || "//tei:msFrag//tei:msIdentifier//tei:repository")

   let $updateRepository:=
        if(exists($originalNodeRepository))
            then ( 
                    update value $originalNodeRepository/@ref with 
                      $repositoryUri 
                     ,
                    update value $originalNodeRepository/text() with  
                        $repositoryLabel
                    )
           else ()

   (:let $updateRepository :=
        if(exists($teiEditor:teiDoc//tei:msFrag//tei:msIdentifier//tei:repository))
            then (if(exists($teiEditor:teiDoc//tei:msFrag//tei:msIdentifier//tei:repository/@ref))
                      then update value $teiEditor:teiDoc//tei:msFrag//tei:msIdentifier//tei:repository/@ref with $townUri 
                    else update insert attribute ref { $townUri } into $teiEditor:teiDoc//tei:msFrag//tei:msIdentifier//tei:repository
                    ,
                    update value $teiEditor:teiDoc//tei:msFrag//tei:msIdentifier//tei:settlement/text() with $townLabel
                    )
           else update insert $repositoryNode/node following $teiEditor:teiDoc//tei:msIdentifier/tei:settlement:)
   let $updatedElement := teiEditor:repositoryDetails($townLabel, $repositoryLabel, $index)
   return
        <data>
        <newContent>{ $teiEditor:doc-collection/id($docId) } </newContent>
        <updatedElement>{ $updatedElement }</updatedElement>
        </data>
        
};

declare function teiEditor:peopleManager($docId as xs:string){
    let $teiDoc := $teiEditor:doc-collection/id($docId)
    let $people:= $teiDoc//tei:listPerson[@type="peopleInDocument"]
    let $owner := $people//tei:person[@role="owner"] 
    let $otherPeople:= $people//tei:person[@role !="owner"]
    let $temp := $teiEditor:peopleCollection//lawd:Person[@rdf:about= data($people//tei:person[@role="owner"]/@corresp)]
    let $ownerRecord := $teiEditor:peopleCollection//lawd:Person[@rdf:about= data($owner[1]/@corresp)]
    return
<div id="peoplePanel" class="teiElementGroup">
   <div class="TeiElementGroupHeaderBlock"><span class="labelForm">People Manager</span></div>

            <div id="erPanel" class="teiElementGroup">
                    <div class="TeiElementGroupHeaderBlock"><span class="labelForm">Owner</span></div>
                        {if(count($owner) = 1) then $owner//tei:persName[1]/text()
                            else if(count($owner) > 1)
                                then <ul>
                        {for $owner in $owner
                            return
                            <li>{$owner//tei:persName[1]/text()}</li>}
                        </ul>
                        else 
                        <button onclick="openAddPersonToDocDialog('owner', '')">Add Owner</button>
                        }
                        {if(count($owner) >0) then (<div>
                                    {if(count($otherPeople) = 0) then "There is not any other person linked to this document" else 
                                    <ul>{
                                    for $person in $otherPeople
                                        return
                                        <li>{ $person//tei:persName[1]/text() } [{ data($ownerRecord//snap:hasBond[@rdf:resource = $person/@corresp]/@rdf:type)}]</li>
                                    }
                                    </ul>
                                    }         
                        <h4>Add a person</h4>
                <button class="btn btn-primary" onclick="openAddPersonToDocDialog('', '{ $owner/@corresp }', 'father')">Father</button>
                <button class="btn btn-primary" onclick="openAddPersonToDocDialog('', '{ $owner/@corresp }', 'mother')">Mother</button>
                <button class="btn btn-primary" onclick="openAddPersonToDocDialog('', '{ $owner/@corresp }', 'spouse')">Spouse</button>
                <button class="btn btn-primary" onclick="openAddPersonToDocDialog('dedicator', '{ $owner/@corresp }', 'child')">Child</button>
                </div>) 
                else ()
                }
            </div>
                

<div id="dialogAddPersonToDocument" title="Add a Person to a Resource" class="modal fade" tabindex="-1" style="display: none;">

            <!-- Modal content-->
            <div class="modal-content modal4editor">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"/>
                    <h4 class="modal-title">Link a Person to Document</h4>
                </div>
                <div class="modal-body">
                      <form id="addPersonForm" class="addPersonForm" role="form" data-toggle="validator" novalidate="true">
                      <h4>Link to a person already in database</h4>
                            <div class="form-group">
                                  <label for="projectPeopleLookup">Search</label>
                                   <input type="text" class="form-control projectPeopleLookup"
                                   id="projectPeopleLookup"
                                   name="projectPeopleLookup"
                                   autocomplete="on"
                                   />
                        </div>
                        <div id="projectPeopleDetailsPreview" class=""/>
                        <input id="currentDocumentUri" type="text" class="hidden"/>
                        <input id="selectedPeopleUri" type="text" class="hidden"/>
                        <button  id="addPersonToDocButton" class="btn btn-primary pull-left" type="submit" onclick="addProjectPersonToDoc()">Validate</button>         
                            <hr/>
                            <h4 >Create a new person record</h4>
                            <div class="form-group">
                                <label for="citedRange">Standardized name (in English)</label>
                                <input type="text" class="form-control" id="newPersonStandardizedNameEn" name="newPersonStandardizedNameEn"
                                data-error="Please enter your full name."/>
                            </div>
                            <div class="form-group">
                                <label for="citedRange">Standardized name (in French)</label>
                                <input type="text" class="form-control" id="newPersonStandardizedNameFr" name="newPersonStandardizedNameFr"
                                data-error="Please enter your full name."/>
                            </div>
                            <div class="form-group">
                                <label for="citedRange">Name in translitteration</label>
                                <input type="text" class="form-control" id="newPersonTranslitteredName" name="newPersonTranslitteredName"
                                data-error="Please enter your full name."/>
                            </div>
                            
                            {skosThesau:dropDownThesauForElement("sex", "c23490", "en", 'Sex', 'row', (), (), "uri")}
                            
                            <input id="person2AddType" class="valueField"/>
                            <input id="person2AddOwner" class="valueField"/>
                            <input id="person2AddBondType" class="valueField"/>
                            
                        <div class="modal-footer">


                        <button  class="btn btn-primary pull-left" type="submit" onclick="createAndAddPersonToDoc('{ $teiEditor:docId }')">Add</button>
                        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                    </div>
                  </form>
                    <!--                <a href="javascript: void(0);" onclick="tests()">Test</a>        -->

                </div>

            </div>


    </div>


</div>
};