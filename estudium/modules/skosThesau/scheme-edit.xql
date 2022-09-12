xquery version "3.1";

import module namespace app="https://ausohnum.huma-num.fr/apps/eStudium/templates" at "../app.xql";
import module namespace config="https://ausohnum.huma-num.fr/apps/eStudium/config" at "../config.xqm";

declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";


declare namespace ev = "http://www.w3.org/2001/xml-events";
declare namespace thot = "http://thot.philo.ulg.ac.be/";
declare namespace xf = "http://www.w3.org/2002/xforms";
declare namespace dct = "http://purl.org/dc/terms/";
declare namespace local = "local";
declare namespace functx = "http://www.functx.com";

declare option exist:serialize "method=xml media-type=text/html omit-xml-declaration=no indent=yes";

declare variable $baseUri := doc($config:data-root || '/app-general-parameters.xml')//uriBase/text();

declare function functx:escape-for-regex
  ( $arg as xs:string? )  as xs:string {

   replace($arg,
           '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')
 } ;

declare function functx:substring-before-last
  ( $arg as xs:string? ,
    $delim as xs:string )  as xs:string {

   if (matches($arg, functx:escape-for-regex($delim)))
   then replace($arg,
            concat('^(.*)', functx:escape-for-regex($delim),'.*'),
            '$1')
   else ''
 } ;
  declare function functx:substring-after-last
  ( $arg as xs:string? ,
    $delim as xs:string )  as xs:string {

   replace ($arg,concat('^.*',functx:escape-for-regex($delim)),'')
 } ;




let $currentUser := data(sm:id()//sm:username)
(:let $thotPeopleOLD := sm:get-group-members('thot'):)
let $people := collection($config:data-collection || "/accounts")//account

(:let $editorList:= sm:get-group-members('thot-editors'):)
(:let $contributorList := xmldb:get-users('thot-contributors'):)

(:let $currentConcept := request:get-parameter("concept", ""):)
(:let $collection-xml := collection("/db/apps/thot/data/coll/xml"):)

let $concept-collection := collection($config:data-collection || '/concepts')

let $currentUri := request:get-effective-uri()
let $conceptEdited :=request:get-parameter("concept", "")

let $scheme-name :=request:get-parameter("scheme", "")
let $scheme-uri := $baseUri || '/apc/thesaurus/' || $scheme-name || '/'
let $scheme := $concept-collection//skos:ConceptScheme[@rdf:about=$scheme-uri]
let $listOfConceptsAndCollections := $scheme/parent::node()//skos:Concept|$scheme/parent::node()//skos:Collection


   let $orphans := $listOfConceptsAndCollections[not(./skos:broader)]
   let $noOfTopConcepts := count($scheme/skos:hasTopConcept)

   let $noOfOrphans := count($orphans) - $noOfTopConcepts



(:       let $currentConceptScheme := data($concept-collection//node()[@xml:id=$currentConcept]//skos:inScheme/@rdf:resource):)
let $currentConceptSchemeTopConcept := data($scheme/skos:hasTopConcept/@rdf:resource)
let $topConceptId := functx:substring-after-last($currentConceptSchemeTopConcept, "/")
(:let $thesaurusToEdit := $collection-xml/children[id = $topConceptId]:)

        let $userPrimaryGroup := sm:get-user-primary-group($currentUser)
(:        let  $input := collection("/db/apps/thot/data/concepts"):)
(:        let $adminCollection := collection("/db/apps/thot/data/coll/admin"):)
(:        let $provThs := update insert <thot:ths>{$currentConcept}{$thesaurusToEdit}</thot:ths> into $adminCollection/rdf:RDF[@xml:id='buffer']:)



        let $model := <div id="xform_model">
<xf:model id="m_scheme" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:thot="http://thot.philo.ulg.ac.be/"
                              xmlns:dc="http://purl.org/dc/elements/1.1/">
        <xf:instance xmlns="" id="i_scheme">
             <thot:xfinstances xmlns:thot="http://thot.philo.ulg.ac.be/">
                        <thot:xfinstance type="scheme">
                            {$scheme}
                    </thot:xfinstance>

                <thot:xfinstance type="templates">
                    <dc:creator ref="" role="contributor"/>
                    <skos:hasTopTerm rdf:resource=""/>
                </thot:xfinstance>
                <thot:xfinstance xmlns="" type="admin" >
                    <thot:adminComment ref="{$scheme-uri}" group="{$userPrimaryGroup}" user="{$currentUser}" type="scheme-update" xml:lang="en">
                    <dct:created>{fn:current-dateTime()}</dct:created>
                    </thot:adminComment>
                </thot:xfinstance>
                <thot:xfinstance xmlns="" type="contributorList" >
                    {for $person in $people
                        order by $person/lastname ascending
                    return
                        <people ref="{$person/@xml:id}" type="{$person/role}">
                         {concat($person/firstname, ' ', $person/lastname)} 
                        </people>

                    }
                </thot:xfinstance>
                <thot:xfinstance type="selectedvalue">
                  <people>
                  <repeatIndex/>
                  <username>dede</username></people>
                  
                </thot:xfinstance>
            </thot:xfinstances>
          </xf:instance>
          <xf:instance xmlns="" id="selectedvalue">
          <selected-values>
             <fullname/>
          </selected-values>
        </xf:instance>

        <xf:bind id="dcTitle" ref="instance('i_scheme')/node()[@type='scheme']/node()/*[local-name() = 'title']"/>
        <xf:bind id="dcTitleFull" ref="instance('i_scheme')/node()[@type='scheme']/node()/*[local-name() = 'title'][@type='full']" required="true()"/>
        <xf:bind id="dcTitleShort"
        ref="instance('i_scheme')/node()[@type='scheme']/node()/*[local-name() = 'title'][@type='short']"
        required="true()"
        type="ID"
        />
        <xf:bind id="dcCreator" ref="instance('i_scheme')/node()[@type='scheme']/node()/*[local-name() = 'creator']">
           <xf:bind id="dcCreatorName" ref="." />
           <xf:bind id="dcCreatorRef" ref="./@ref" />
           <xf:bind id="dcCreatorRole" ref="./@role"  />
        </xf:bind>

        <xf:bind id="hasTopTerms" ref="instance('i_scheme')/node()[@type='scheme']/node()/*[local-name() = 'hasTopConcept']">
           <xf:bind id="TTID" ref="./@*[local-name() = 'resource']" />
           <xf:bind id="readonly" ref="./@*[local-name() = 'readonly']" />
        </xf:bind>
        <xf:bind id="TTIDsingle"
        ref="instance('i_scheme')/node()[@type='scheme']/node()/*[local-name() = 'hasTopConcept']/@*[local-name() = 'resource']"
        readonly="true()"
        />


        <xf:bind id="dcPublisher" ref="instance('i_scheme')/node()[@type='scheme']/node()/*[local-name() = 'publisher']"/>
        <xf:bind id="schemeNote" ref="instance('i_scheme')/node()[@type='scheme']/node()/*[local-name() = 'note']"/>




        <xf:bind id="adminComment" ref="instance('i_scheme')/node()[@type='admin']/*[local-name() = 'adminComment']/node()" />
        <xf:bind id="status" ref="instance('i_scheme')/node()[@type='scheme']/node()/*[local-name() = 'admin']/@*[local-name() = 'status']" />

                
       

        <xf:submission
            id="s_save"
            method="post"
            resource="/modules/admin/update-scheme.xql"
         >
          <xf:action
            ev:observer="s_save"
            ev:event="xforms-submit">
            <xf:message
                level="ephemeral">Saving data...</xf:message>
        </xf:action>
        <xf:action
            ev:observer="s_save"
            ev:event="xforms-submit-done">
            <xf:message
                level="ephemeral">Data saved</xf:message>
        </xf:action>
        </xf:submission>

        <!--
        <xf:action
            ev:observer="s_save"
            ev:event="xforms-submit-error">
            <xf:message
                level="modal">Cannot submit!</xf:message>
        </xf:action>
        -->
 
    </xf:model>
</div>
let $requests := collection("/db/apps/thot/data/requests")

let $revisionSuggestions :=
    if(not(exists($requests//.[@scheme=$scheme-name]))) then () else
    <div>
    <h3>Revisions suggested on concepts from current scheme</h3>
    <table class="table table-striped">

             <tr>
                  <th>Request id</th>
                  <th>Suggested by</th>
                  <th>When</th>
                  <th>Concept</th>
                  <td/>
                  <th>Description</th>
                  <th>Overview</th>
                  
            </tr>
            
    
    {
  for $revision in $requests//.[@scheme=$scheme-name]
  
  
  order by $revision/@created
  
  return
  <tr>
  <td>{$revision/@xml:id/string()}</td>
        <td>{$revision/@creator/string()}</td>
        <td>{concat(substring(data($revision/@created), 1, 10), ' ', substring(data($revision/@created), 12, 5))}</td>
        <td>{$revision/@object/string()}</td>
        <td><a href="/admin/concept/{$revision/@object/string()}" target="_blank"><i class="glyphicon glyphicon-eye-open"/></a></td>
        <td>{$revision/description}</td>
        <td>
        <ul>
        {
        
        for $nodes at $pos in $revision/skos:Concept//*
        
            let $nodeName := node-name($nodes)
            
            return
                if(compare($nodes, $concept-collection//id($revision/@object/string())[$pos+1]) = -1) then (
                    if (string($nodeName) eq "") then () else(
                        <li>
                            {$pos}{$nodes}  [original: {$concept-collection//id($revision/@object/string())}] [{$nodeName} ({$nodes/@xml:lang/string()})]</li>
                        )
                ) else ()
          
           }
            </ul>                                            
        </td>
        
      </tr>  
  }
    </table>
 </div>


        return
         <div data-template="templates:surround"
                 data-template-with="./templates/page.html" data-template-at="content">
                  <script
            src="/resources/scripts/admin.js"
            type="text/javascript"/>
       {$model}
<!--        <script src="/resources/scripts/admin.js" type="text/javascript"/>-->

    <div class="col-xs-12 col-sm-12 col-md-12" id="xforms">
       <div class="row">
        <div class="panelAdminScheme col-xs-5 col-sm-5 col-md-5">
            <h2 class="">Edit Scheme Metadata</h2>
                <xf:form class="form-horizontal">
                    <xf:select1 id="input_scheme_status" class="bottom-line" bind="status" incremental="true">
                            <xf:label class="pastilleLabelBlue pastilleSquare">Scheme status</xf:label>
                            <xf:hint>Select a status</xf:hint>
                                <xf:help>help for select1</xf:help>
                                <xf:alert>invalid</xf:alert>
                            <xf:item>
                                <xf:label>Pending</xf:label>
                                <xf:value>pending</xf:value>
                            </xf:item>
                            <xf:item>
                                <xf:label>Draft</xf:label>
                                <xf:value>draft</xf:value>
                            </xf:item>
                            <xf:item>
                                <xf:label>Published</xf:label>
                                <xf:value>published</xf:value>
                            </xf:item>
                            <xf:item>
                                <xf:label>Thot Collaborators only</xf:label>
                                <xf:value>private-thot</xf:value>
                            </xf:item>
                            <xf:item>
                                <xf:label>Trash</xf:label>
                                <xf:value>trash</xf:value>
                            </xf:item>
                    </xf:select1>
                    <div class="form-group">
                       <xf:input id="dcTitleInputFull"
                            appearance="minimal" bind="dcTitleFull" incremental="true" class="form-control"
                            size="100%">
                            <xf:label id="dctitle_label">Full title</xf:label>
                            <xf:hint>Title for this thesaurus</xf:hint>
                        </xf:input>
                        <xf:input id="dcTitleInputShort" appearance="minimal" bind="dcTitleShort" incremental="true" class="form-control" size="100%">
                            <xf:label id="dctitle_label">Short title</xf:label>
                            <xf:hint>Short title for this thesaurus, to be used in URI</xf:hint>
                            <xf:alert>Space and special characters not permitted</xf:alert>
                        </xf:input>
                     </div>

        <div class="form-group">
<xf:input id="dcPublisherInput" appearance="minimal" bind="dcPublisher" incremental="true" class="form-control"
size="100%">
                        <xf:label id="dctitle_label">Publisher</xf:label>
                        <xf:hint>Publisher responsible for making this thesaurus available</xf:hint>
                        </xf:input>
     </div>

<div class="form-group">
<xf:trigger appearance="minimal" class="btn-primary btn-xs pull-right">
         <xf:label><i class="glyphicon glyphicon-minus"/></xf:label>
    <xf:action ev:event="DOMActivate">
        <xf:delete bind="dcCreator" at="index('repeatCreators')"/>
     </xf:action>
</xf:trigger>
<xf:trigger appearance="minimal" class="btn-primary btn-xs pull-right">
            <xf:label><i class="glyphicon glyphicon-plus" /></xf:label>
            <xf:action ev:event="DOMActivate">

             <xf:insert bind="dcCreator"
             position="after"
             at="last()"
             origin="instance('i_scheme')/node()[@type='templates']/*[local-name() = 'creator']"
               />

            <xf:insert
                    context="instance('i_scheme')/node()[@type='scheme']/*[local-name() = 'ConceptScheme']"
                    at="last()" position="after"
                    origin="instance('i_scheme')/node()[@type='templates']/*[local-name() = 'creator']"

               if="count(instance('i_scheme')/node()[@type='scheme']/node()/*[local-name() = 'creator']) = 0"/>




               <xf:setvalue ref="val[last()]" value="count(/data/val)" />
            </xf:action>
         </xf:trigger>


                  <xf:group class="form-control">
                        <xf:label>Creator(s)</xf:label>
                        <xf:repeat id="repeatCreators" bind="dcCreator" appearance="compact" class="orderListRepeat">

                        <xf:select1 id="creatorDropDown" appearance="minimal" bind="dcCreatorRef" incremental="true" >
                                    <xf:label id="dcCNLabel">Name</xf:label>
                                     <xf:hint>Select someone</xf:hint>
                            <xf:itemset ref="instance('i_scheme')/node()[@type='contributorList']/*[local-name() = 'people']">
                                <xf:label ref="."/>
                                <xf:value ref="./@ref"/>
                            </xf:itemset>
                
            <xf:action ev:event="xforms-value-changed" >
          
                          <xf:setvalue ref="instance('i_scheme')/node()[@type='selectedvalue']/people/repeatIndex"
                              value="index('repeatCreators')" />
                          <xf:setvalue ref="instance('i_scheme')/node()[@type='selectedvalue']/people/username"
                              value="string(instance('i_scheme')/node()[@type='scheme']/node()/*[local-name() = 'creator'][xs:integer(instance('i_scheme')/node()[@type='selectedvalue']/people/repeatIndex/text())]/@ref)" />
                              
                          <xf:setvalue ref="instance('i_scheme')/node()[@type='selectedvalue']/people/username"
                              value="instance('i_scheme')/node()[@type='scheme']/node()/*[local-name() = 'creator'][xs:integer(instance('i_scheme')/node()[@type='selectedvalue']/people/repeatIndex/text())]" />
                          
                          
                          <xf:setvalue ref="instance('i_scheme')/node()[@type='scheme']/node()/*[local-name() = 'creator'][xs:integer(instance('i_scheme')/node()[@type='selectedvalue']/people/repeatIndex/text())]"
                              value="string(instance('i_scheme')/node()[@type='contributorList']/*[local-name() = 'people'][@ref=string(instance('i_scheme')/node()[@type='scheme']/node()/*[local-name() = 'creator'][xs:integer(instance('i_scheme')/node()[@type='selectedvalue']/people/repeatIndex/text())]/@ref)])" />
                     <xf:message
                            level="ephemeral">Data changed</xf:message>
                    
                </xf:action> 
         </xf:select1>
                      
                           

              <xf:select1 id="creatorRoleInput" appearance="minimal" bind="dcCreatorRole" incremental="true" >
                                    <xf:label id="dcCNLabel">Role</xf:label>
                                     <xf:hint>Select a role</xf:hint>
                           <xf:item>
                            <xf:label>Author</xf:label>
                            <xf:value>author</xf:value>
                            </xf:item>
                            <xf:item>
                            <xf:label>Contributor</xf:label>
                            <xf:value>contributor</xf:value>
                            </xf:item>
                            <xf:item>
                            <xf:label>Editor</xf:label>
                            <xf:value>editor</xf:value>
                            </xf:item>
                            </xf:select1>

                   </xf:repeat>

                </xf:group>
</div>

<div class="form-group">
<xf:textarea id="SchemeNoteInput" appearance="minimal" class="form-control" bind="schemeNote" incremental="true" >
                <xf:label>Scheme Note</xf:label>
                        <xf:hint>Scheme Note</xf:hint>
                        </xf:textarea>
                        
</div>



<div class="form-group">
             <xf:group class="form-control">
                <xf:label>Top concept: </xf:label>
                <p>{$concept-collection//.[@xml:id=$topConceptId]/skos:prefLabel[@xml:lang='en']} <a href="{$currentConceptSchemeTopConcept}" target="_blank" ><i class="glyphicon glyphicon-eye-open"/></a></p>

                <xf:input bind="TTIDsingle" size="50"><xf:label>URL</xf:label></xf:input>




                </xf:group>
</div>









</xf:form>



  </div>


  <div class="col-xs-5 col-sm-5 col-md-5">
  <div class="admin-subpanel">
  <h2>Save</h2>
            <xf:textarea
                 id="adminCommentInput"
                 rows="2"
                 bind="adminComment"
                 class=""
                 >
             <xf:label for='adminCommentInput'>Leave a comment about changes</xf:label>
       </xf:textarea>

       <xf:trigger id="saveUpadtesButton" appearance="minimal" class="btn btn-primary">
            <xf:label>Save</xf:label>
            <xf:action ev:event="DOMActivate">
                <xf:send submission="s_save"/>
            <xf:load resource="javascript:loadConcept('{if ($conceptEdited) then $conceptEdited
                                else $currentConceptSchemeTopConcept}')"/>
            </xf:action>
<!--            <xf:action >
                <xf:load resource="javascript:reloadPage()"/>
            </xf:action>
            -->
       </xf:trigger>
            <xf:trigger
                        id="cancelEdition"
                        appearance="minimal"
                        class="btn btn-warning">
                        <xf:label>Cancel</xf:label>
                        <xf:action>
                            <xf:load
                                resource="javascript:loadConcept('{if ($conceptEdited) then $conceptEdited
                                else $currentConceptSchemeTopConcept}')"/>
                        </xf:action>
                    </xf:trigger>

            </div>




      <xf:trigger id="createNewConcept" appearance="minimal" class="btn btn-primary">
            <xf:label>
            <a href="/admin/new-concept/{$scheme-name}" target="_blank" >
            <i class="glyphicon glyphicon-plus"/> new concept
            </a>
            </xf:label>

            <xf:action >
                <xf:load resource="javascript:newConcept('{$scheme-name}')"/>
            </xf:action>
       </xf:trigger>

      <xf:trigger id="browseConcept" appearance="minimal" class="btn btn-primary">
            <xf:label><a href="{$currentConceptSchemeTopConcept}" target="_blank" ><i class="glyphicon glyphicon-eye-open"/> Browse concepts</a>
                    </xf:label>

            <!--<xf:action >
                <xf:load resource="{$currentConceptSchemeTopConcept}" show="new"/>
            </xf:action>
            -->
       </xf:trigger>



    <h2 class="">Orphan Concepts{
    if($noOfOrphans>0) then (<span> ({$noOfOrphans})</span>) else()
    }</h2>

    {if($noOfOrphans = 0) then
        (<p>There is no orphan concept in this scheme</p>)
        else
        (
                <table class="table table-striped">

               <tr>
              <th>prefLabel</th>
              <th>id</th>
              <th>Edit</th>

              </tr>

                {

                  for $orphans in $listOfConceptsAndCollections[not(skos:broader)]
                  return
                     if($orphans/@xml:id != $topConceptId) then
                   <tr>
                   <td>{$orphans/skos:prefLabel[@xml:lang='en']}</td>
                   <td>{data($orphans/@xml:id)}</td>
                   <td><a href="{concat('/admin/concept/', data($orphans/@xml:id)) }" target="_blank"><i class="glyphicon glyphicon-edit"/></a></td>
                   </tr>
                   else()
                }
                </table>
         )
         }
    </div>
    
    </div>
    <div class="row">
    {$revisionSuggestions}
    </div>
    </div>


       </div>
