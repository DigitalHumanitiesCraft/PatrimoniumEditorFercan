xquery version "3.0";

import module namespace templates="http://exist-db.org/xquery/templates" ;

declare namespace apc = "https://ausohnum.huma-num.fr/apps/eStudium/onto#";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace dct = "http://purl.org/dc/terms/";
declare namespace ev = "http://www.w3.org/2001/xml-events";
declare namespace functx = "http://www.functx.com";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace thot = "http://thot.philo.ulg.ac.be/";
declare namespace xf = "http://www.w3.org/2002/xforms";

declare namespace local = "local";


declare option exist:serialize "method=xhtml media-type=text/html
omit-xml-declaration=yes indent=yes";

declare function functx:trim
  ( $arg as xs:string? )  as xs:string {

   replace(replace($arg,'\s+$',''),'^\s+','')
 } ;


let $now := fn:current-dateTime()
let $currentUser := sm:id()
let $userPrimaryGroup := sm:get-user-primary-group($currentUser)
(:let $template := <document>{doc('/db/apps/patrimonium/data/templates/doc-template.xml')}</document>:)
(:let $template := doc('/db/apps/patrimonium/data/templates/doc-simple.xml'):)
let $templateEmptyapcDoc := doc('/db/apps/patrimonium/data/templates/empty-doc.xml')
 let $teiTemplate :=
 xmldb:document('/db/apps/ausohnum-library/data/templates/tei-template.xml')/node()
 
let $xfBindings:=
doc('/db/apps/ausohnum-library/data/templates/tei_xforms_model_bindings.xml')/bindings/node()

let $serializationParam :=

<output:serialization-parameters
        xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">

        <output:xml value="suppress-indentation: . lb gap ab div supplied; indent:no"/>
        <output:line-length value="10"/>



</output:serialization-parameters>

let $text
:=normalize-space(serialize($teiTemplate//div[@type='edition']/div[@type='textpart']/ab/node(),
$serializationParam))
let $model :=
<div id="model" >
    <xf:model id="m_document">
      <xf:instance xmlns="" id="i_teidoc" >
        {$teiTemplate}
      </xf:instance>
        <xf:instance xmlns="" id="i_admin">
            <apc:document>
              <dct:created>{$now}</dct:created>
              <dct:contributor>{$currentUser}</dct:contributor>

            </apc:document>

        </xf:instance>

        <xf:instance xmlns=""  id="i_doc_types">
            {doc('/db/apps/patrimonium/data/templates/document-types.xml')}
        </xf:instance>
        <xf:instance id="datations">
            <data xmlns="">
                <datations></datations>
            </data>
        </xf:instance>
        
        {$xfBindings}
        <!--<xf:instance xmlns="" type="places">

        </xf:instance>
        -->
        <!--
        <xf:submission id="loadThesaurus" method="GET" replace="instance" instance="datations"
        resource="http://thot.philo.ulg.ac.be/api/xml/get-thesaurus/scripts/fr" >
            <xf:action ev:event="xforms-submit">
                <xf:message level="ephemeral">
                    about to send your data...
                </xf:message>
            </xf:action>
        <xf:action ev:event="xforms-submit-done">
          <xf:message level="ephemeral">success!</xf:message>
      </xf:action>
      <xf:action ev:event="xforms-submit-error">
          <xf:message>oops, an error occurred</xf:message>
      </xf:action>
 </xf:submission>
        -->









<!--
         <xf:bind
            id="doc_type"
            ref="instance('i_document')/*[local-name() = 'docType']"/>
       <xf:bind
            id="doc_origin"
            ref="instance('i_document')/*[local-name() = 'origin']"/>
       <xf:bind
            id="doc_prov"
            ref="instance('i_document')/*[local-name() = 'provenance']"/>
       <xf:bind
            id="doc_prov_note"
            ref="instance('i_document')/*[local-name() = 'provenance']/*[local-name() = 'place']/*[local-name() = 'note']"/>
       <xf:bind
            id="doc_biblio_editionRaw"
            ref="instance('i_document')/div[@type='bibliography']/div[@type='editionRaw']"/>

       <xf:bind
            id="doc_text_commentary"
            ref="instance('i_document')/div[@type='textCommentary']"/>
       <xf:bind
            id="doc_note"
            ref="instance('i_document')/note"/>

       <xf:bind
            id="doc_biblio_edition"
            ref="instance('i_document')/div[@type='bibliography']/listBibl[@type='edition']//bibl">
                <xf:bind id="doc_biblio_edition_id" ref="./@ref" />
                <xf:bind id="doc_biblio_edition_citedRange" ref="./*[local-name() = 'citedRange']" />
            </xf:bind>
       <xf:bind
            id="doc_biblio_secondary"
            ref="instance('i_document')//listBibl/div[@type='secondary']">
            </xf:bind>
       <xf:bind
            id="document_types"
            ref="instance('i_doc_types')/*[local-name() = 'div'][@type='biblio']">
            </xf:bind>
       <xf:bind
            id="document_text"
            ref="instance('i_document')/div[@type='edition']/ab">
            </xf:bind>

       <xf:bind
            id="datations"
            ref="instance('i_doc_types')/*[local-name() = 'div'][@type='biblio']">
            </xf:bind>

       <xf:bind
            id="datationStart"
            ref="instance('i_document')/*[local-name() = 'origin']/*[local-name() = 'origDate']/*[local-name() = 'date'][@type='earliest']/@notBefore">
            </xf:bind>
       <xf:bind
            id="datationEnd"
            ref="instance('i_document')/*[local-name() = 'origin']/*[local-name() = 'origDate']/*[local-name() = 'date'][@type='latest']/@notAfter">
            </xf:bind>
       <xf:bind
            id="datationStartCert"
            ref="instance('i_document')/*[local-name() = 'origin']/*[local-name() = 'origDate']/*[local-name() = 'certainty']/@degree">
            </xf:bind>

        <xf:bind
            id="dateCreated"
            ref="instance('i_document')/*[local-name() = 'created']">
            </xf:bind>
        <xf:bind
            id="keywords"
            ref="instance('i_document')//*[local-name() = 'keyword']">
                <xf:bind id="keywordPrefLabel" ref="." />
                        <xf:bind id="keywordUri" ref="./@*[local-name() = 'resource']"  />

            </xf:bind>

        <xf:bind
            id="currentContributor"
            ref="instance('i_document')/*[local-name() = 'contributor']">
            </xf:bind>


       <xf:submission
            id="s_create_document"
            method="post"
            ref="instance('i_teidoc')"
            resource="/modules/create-document.xql"
            includenamespaceprefixes="skos thot apc tei"
            >


        <xf:action ev:event="xforms-submit">
                <xf:message level="ephemeral">
                    about to send your data...
                </xf:message>
            </xf:action>
        <xf:action ev:event="xforms-submit-done">
          <xf:message level="ephemeral">success!</xf:message>
      </xf:action>

         <xf:action ev:event="xforms-submit-error">
        <xf:message level="ephemeral">Submit Error! Resource-uri: <xf:output value="event('resource-uri')"/>
                Response-reason-phrase: <xf:output value="event('response-reason-phrase')"/>
    </xf:message>
    </xf:action>
        </xf:submission>
-->
</xf:model>

</div>



return
    <div data-template="templates:surround" data-template-with="templates/page-admin.html" data-template-at="content"
       >
        <script src="/resources/scripts/ace/src-noconflict/ace.js" type="text/javascript" charset="utf-8"/>
        
<!--        <div class="hidden" >-->
            {$model}
        <!--</div>-->
      
    <div class="" id="newDoc">
          
                <div class="col-xs-12 col-sm-12 col-md-12">
                    <h2>Create a new document</h2>
                    
                    <xf:trigger id="createConceptButton" appearance="minimal" class="btn btn-primary">
            <xf:label>Save</xf:label>    
            <xf:action ev:event="DOMActivate">
                <xf:send submission="s_create_document"/>
                
            </xf:action>
            
       </xf:trigger>
          
          </div>
          <div class="col-xs-4 col-sm-4 col-md-4">
          
<!--          TABS-->
<ul class="nav nav-pills mb-3" id="pills-tab" role="tablist">
  <li class="nav-item  active">
    <a class="nav-link" id="pills-home-tab" data-toggle="pill" href="#nav-metadata" role="tab" aria-controls="pills-home" aria-selected="true">Metadata</a>
  </li>
  <li class="nav-item">
    <a class="nav-link" id="pills-profile-tab" data-toggle="pill" href="#nav-commentary" role="tab" aria-controls="pills-profile" aria-selected="false">Commentary</a>
  </li>
</ul>

<div class="tab-content" id="nav-tabContent">
    <div class="tab-pane fade in active" id="nav-metadata" role="tabpanel" aria-labelledby="nav-metadata-tab">
  
                        <!--
                        </div>
                                  <ul class="nav nav-pills nav-justified">
                                  <li role="presentation" class="active"><a href="#">Metadata</a></li>
                                  <li role="presentation"><a href="#">Text</a></li>
                          <li role="presentation"><a href="#">Logs</a></li>
                          </ul>
                        -->      
          
                <div class="panel panel-default">
                
                <!-- For callapsing other, add this attribute to following div: data-parent="#nav-metadata" -->
                
                    <div class="panel-heading"  data-toggle="collapse"  href="#titlepanel">Title &amp; Edition</div>
                        <div id="titlepanel" class="panel-collapse collapse in">
                              <div class="panel-body">
                                      <xf:group appearance="minimal" >
                                                  <xf:textarea id="docTitleInput" class="fullwidth" bind="doc_stmtTitle" incremental="true" row="2">
                                                              <xf:label class="labelOut" id="docTitle_label">Title for this document</xf:label>
                                                              <xf:hint>Enter a title for this document</xf:hint>
                                                  </xf:textarea>
                                                  <xf:select1 id="docTypeSelect" bind="doc_objectType" incremental="true">
                                                      <xf:label class="labelInline" id="docTypeSelectLabel">Document type</xf:label>
                                                      <xf:hint>Choose a document type</xf:hint>
                                                      <xf:itemset ref="instance('i_doc_types')/./type">
                                                          <xf:label ref="./label"/>
                                                          <xf:value ref="./value"/>
                                                      </xf:itemset>
                                                   </xf:select1>
                                                   
                                                   <!--
                                                   <xf:reapeat id="repeatBiblioEdition" bind="doc_biblio" appearance="compact" >
                                                         <xf:input id="doc_biblio_edition_input_id" class="bfHidden" appearance="minimal" bind="doc_biblio_edition_id" incremental="true">
                                                         
                                                         <xf:label id="doc_bblio_edition_input_idlabel">id</xf:label>
                                                        </xf:input>
                                                         <input type="text" class="form-control zoteroLookup" name="zoteroLookup"/>
                                                   
                                                         <xf:input id="doc_biblio_edition_input_citedRange" appearance="minimal" bind="doc_biblio_edition_citedRange" incremental="true" size="3">
                                                         <xf:label id="doc_biblio_edition_input_citedRangelabel">Cited range</xf:label>
                                                        </xf:input>
                                                    </xf:reapeat>
                                                    -->
                                                   
                                                   
                                                   
                                                   
                                                   
                                                   <xf:textarea id="editionRawTextArea" class="fullwidth" bind="doc_biblioRaw" >
                                                      <xf:label class="labelOut" id="docBiblioRawLabel">Edition [1 reference per line]</xf:label>
                                                      <xf:hint>One reference per line</xf:hint>
                                                   </xf:textarea>
                                          </xf:group>
                                        
                            </div>
                      </div>
                </div>
                <div class="panel panel-default">
                    <div class="panel-heading"  data-toggle="collapse" href="#placespanel">Places</div>
                        <div id="placespanel" class="panel-collapse collapse">
                              <div class="panel-body">
                                          <xf:group appearance="minimal" >
                                          <h4>Place of finding  <button id="callProvenance"  class="btn btn-default btn-xs pull-right" data-target="#dialogProvenance"><i class="glyphicon glyphicon-search"/></button></h4>
                                                  <!--
                                                  <xf:input id="provenanceInput" class="fullwidth" bind="doc_prov" incremental="true" >
                                                              <xf:label class="labelOut" id="docTitle_label">Provenance</xf:label>
                                                             
                                                              <xf:hint>Start to enter a place-name</xf:hint>
                                                  </xf:input>
                                                  -->
                                                  <div id="provenancePlaceName"/>
                                             <!--
                                             <xf:textarea id="docprovnote" type="html/text" bind="doc_prov_note">
                                             <xf:label class="labelOut" id="docprovnote_label">Note</xf:label>
                                             </xf:textarea>
                                                 -->
                                          </xf:group>
                                   <!--
                                   <xf:group appearance="minimal" >
                                          <h4>Place(s) <button id="callPlace"  class="btn btn-default btn-xs pull-right" data-target="#dialogProvenance"><i class="glyphicon glyphicon-search"/></button>         </h4>
                                                  <xf:input id="provenanceInput" class="fullwidth" bind="doc_prov" incremental="true" >
                                                              <xf:label class="labelOut" id="docTitle_label">Provenance</xf:label>
                                                              <xf:hint>Start to enter a place-name</xf:hint>
                                                  </xf:input>
                                                  <br/>
                                        
                                          </xf:group>
                                          -->
                           </div>
                      </div>
                </div>

             <div class="panel panel-default">
                           <div class="panel-heading"  data-toggle="collapse"  href="#datationpanel">Datation</div>
                  <div id="datationpanel" class="panel-collapse collapse">
                  <div class="panel-body">
                          <form class="form-horizontal">
                              <!--
                              <xf:group class="form-group">
                                     <xf:label id="docTitle_label">Numerical datation</xf:label>
                                     <xf:input id="dateStartInput" class="dateInput" bind="datationStart" incremental="true" size="6">
                                                
                                                <xf:hint>Start</xf:hint>
                                    </xf:input>
                                    
                                    <xf:input id="dateEndInput" class="dateInput" bind="datationEnd" incremental="true" size="6">
                                                <xf:label id="docTitle_label">-</xf:label>
                                                <xf:hint>End</xf:hint>
                                    </xf:input>
                            </xf:group>
                            -->
                </form>
                </div>
                </div>
           </div>
           
           <div class="panel panel-default">
                           <div class="panel-heading"  data-toggle="collapse"  href="#keywordspanel">Keywords</div>
                  <div id="keywordspanel" class="panel-collapse collapse">
                  <div class="panel-body">
                          <form class="form-horizontal">
                             <!--
                             <xf:group class="form-group">
                           <xf:reapeat id="repeatKeyword" bind="keywords" appearance="compact" >
                                  <xf:input id="prefLabelKeyword" appearance="minimal" bind="keywordPrefLabel" incremental="true" >
                                  <xf:label id="prefLabelKeyword_label">URI</xf:label>
                       
                   </xf:input>
                                  </xf:reapeat>
                                    
                                    
                                    
                            </xf:group>
                            -->
                </form>
                </div>
                </div>
           </div>
           
           <div class="panel panel-default">
                           <div class="panel-heading"  data-toggle="collapse"  href="#authorspanel">Autor(s)</div>
                  <div id="authorspanel" class="panel-collapse collapse">
                  <div class="panel-body">
                          <form class="form-horizontal">
                              <xf:group class="form-group">
                                    <!--
                                    <xf:input id="currentAuthor" class="" bind="currentContributor" incremental="true" >
                                                <xf:label id="docTitle_label">Contributor</xf:label>
                                                
                                    </xf:input>
                                    -->
                                    <!--
                                    <xf:input id="dateCreatedInput" class="" bind="dateCreated" incremental="true">
                                                <xf:label id="dateCreation_label">Date of creation</xf:label>
                                                
                                    </xf:input>
                                    -->
                                    
                            </xf:group>
                </form>
                </div>
                </div>
           </div>
           
          
  </div>
  
  <div class="tab-pane fade" id="nav-commentary" role="tabpanel" aria-labelledby="nav-commentary-tab">
  
  
   <button id="callInsertBiblio"  class="btn btn-default" data-target="#dialogInsertBiblio">Insert Biblio.</button>
  <!--
        <xf:textarea id="editionRawTextArea" class="fullwidth" bind="doc_text_commentary" >
            <xf:label class="labelOut" id="docBiblioRawLabel">Commentary</xf:label>
            <xf:hint>Enter a commentary</xf:hint> 
        </xf:textarea>
        -->
  
  </div><!--End of Commentary tab-->
          
          </div> 
          </div><!--End of row-->
        <div class="col-xs-7 col-sm-7 col-md-7">
       
        <h4>Ancient Text<button id="callTextImport"  class="btn btn-default pull-right" data-target="#dialogTextImport">Import text</button></h4>
        
            <div id="editor">{$text}</div>
            <h5>Preview</h5>
            <div id="textPreviewHTML"/>
            <xf:textarea id="ancientText" class="fullwidth bfHidden"
            bind="doc_textEdition" >
            <xf:label class="labelOut" id="docBiblioRawLabel">Ancient Text (betterform): </xf:label>
            
        </xf:textarea>
            
        </div><!--End of row-->
         <div class="col-xs-1 col-sm-1 col-md-1">
         <h5>TEI Elements Insertion</h5>
         <div class="btn-group-vertical" role="group">
              <button id="callSupplied"  class="btn btn-default" data-target="#dialogSupplied">Supplied</button>
              <button id="callGap" class="btn btn-default" data-target="#dialogSupplied">Lacuna</button>
              <button id="callGap" class="btn btn-default" data-target="#dialogSupplied">Line break</button>
         
         </div>
                 <xf:group ref="instance('save-results')/.[@code='200']">
            <div class="success">
               <xf:output ref="instance('save-results')//message"/>
            </div>
        </xf:group>
        <xf:group ref="instance('save-results')/.[@code='400']">
            <div class="failure">
                <xf:output ref="instance('save-results')//message"/>
            </div>
        </xf:group>
         </div><!--End of row-->
        
        </div><!--End of container-->



        
    <script>
        
        
        
        
    </script>            
  
   </div>
