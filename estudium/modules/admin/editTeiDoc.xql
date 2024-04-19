xquery version "3.0";

import module namespace templates="http://exist-db.org/xquery/templates" ;

declare namespace apc = "https://ausohnum.huma-num.fr/apps/eStudium/onto#";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace dct = "http://purl.org/dc/terms/";
declare namespace ev = "http://www.w3.org/2001/xml-events";
declare namespace functx = "http://www.functx.com";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace thot = "http://thot.philo.ulg.ac.be/";
declare namespace xf = "http://www.w3.org/2002/xforms";

(:declare default element namespace "http://www.tei-c.org/ns/1.0";:)

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
let $docId := request:get-parameter('docid', '')
let $doc-collection := collection('/db/apps/patrimonium/data/documents')
let $teiDoc := $doc-collection/id($docId)
let $xfBindings:=
doc('/db/apps/ausohnum-library/data/xformsModels/tei_xforms_model_bindings.xml')/bindings/node()

let $logs := collection("/db/apps/patrimonium/data/logs")



(:let $template := <document>{doc('/db/apps/patrimonium/data/templates/doc-template.xml')}</document>:)
(:let $template := doc('/db/apps/patrimonium/data/templates/doc-simple.xml'):)
let $templateEmptyapcDoc := doc('/db/apps/patrimonium/data/templates/empty-doc.xml')
 let $teiTemplate := doc('/db/apps/ausohnum-library/data/templates/tei-template.xml') 
(:let $text := $templateEmptyapcDoc//text/string():)
(:let $serializationParam :=

<output:serialization-parameters
        xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">

        <output:xml value="suppress-indentation: . lb gap ab div supplied; indent:no"/>
        <output:line-length value="80"/>



</output:serialization-parameters>

let $serializationParam2 :=

<output:serialization-parameters
        xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
        <output:indent value="false"/>
        <output:suppress-indentation value="body div ab"/>
        <!--<output:indent-spaces value="1"/>-->
        <output:method value="application/xml"/>
        <output:omit-xml-declaration value="yes"/>
        <!--<output:xml value="suppress-indentation: . body ab lb gap div supplied;
        indent:no"/>
        -->
</output:serialization-parameters>

:)
(:let $text :=serialize(<ab>exemple de <lb n="3"/>ckkc,d c,cdkc,c :;lv; lc;v; cl;difj<lb n="6"/>d,d,ekd,d,ek,d,dk,de,dkd,dked,,kddlld,dd, dd,kde,d,,d,d</ab>,
$serializationParam):)

(:let $text :=normalize-space(serialize($teiDoc/text/body/div[@type='edition']/div[@type='textpart']/ab/node(),
$serializationParam2))
:)(:let $text :=serialize($teiDoc//div[@type='edition']/div[@type='textpart']/ab/node(),
$serializationParam):)
(:let $text
:=normalize-space(serialize($teiDoc//div[@type='edition']/div[@type='textpart']/ab,
$serializationParam))
:)
let $xslCleanDiv := xs:anyURI("xmldb:exist:///db/apps/ausohnum-library/xslt/cleanTextEdition.xsl")

let $cleanTeiFile :=  transform:transform($teiDoc, $xslCleanDiv, ())


let $logInjection := 
    update insert <apc:log type='document-open' when='{$now}' what="{$docId}" who='{$currentUser}'>
    <raw>{$teiDoc}</raw>
    {$cleanTeiFile}
</apc:log> into $logs/rdf:RDF/id('all-logs')




let $model :=

<div id="model" >
<xf:model id="m_document">
<xf:instance xmlns="" id="i_teidoc" >
<data>
    <teiFile>
    {$teiDoc}
    </teiFile>
    <teiText>
       {for $text in $cleanTeiFile/*[local-name() = 'text']/*[local-name()='body']//*[local-name()='div'][@type='textpart']
        return
            <ab/>
        }
    <!--{$teiDoc/*[local-name() = 'text']/*[local-name()='body']/*[local-name()='div'][@type="edition"]}-->
    </teiText>
    <teiTextMultiple>
        {for $text in $cleanTeiFile/*[local-name() = 'text']/*[local-name()='body']//*[local-name()='div'][@type='textpart']
        return
        $text
        }
    </teiTextMultiple>
</data>
</xf:instance>
<xf:instance xmlns="" id="i_teidata" >
<data>
    <teiFile>
    {$cleanTeiFile}
    </teiFile>
    
    <teiText>
    {$cleanTeiFile/*[local-name() = 'text']/*[local-name()='body']/node()}
    </teiText>
    
</data>
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
                <datations/>
            </data>
        </xf:instance>
        <xf:instance id="langUsage" xmlns="">
            {doc('/db/apps/ausohnum-library/data/langUsage.xml')/langUsage}
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





       <xf:submission
            id="s_save_document"
            method="post"
            ref="instance('i_teidoc')"
            resource="/modules/admin/save-document.xql"
            
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

</xf:model>

</div>

let $titleEditionPanel :=
<xf:group appearance="minimal" >
                                                  <xf:textarea id="docTitleInput" class="fullwidth" bind="doc_stmtTitle" incremental="true" row="2">
                                                              <xf:label class="labelOut" id="docTitle_label">Title for this document</xf:label>
                                                              <xf:hint>Enter a title for this document</xf:hint>
                                                  </xf:textarea>
                                                  
                                                  
                                                  
                                                  
                                                  <xf:select1 id="docTypeSelect" bind="doc_objectType" incremental="true">
                                                      <xf:label class="labelInline" id="docTypeSelectLabel">Object type</xf:label>
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
let $textManagerPane :=
        
<div class="">
    <xf:group
        appearance="minimal">
        <xf:repeat
            id="msItemsRepeat"
            bind="doc_msItems"
            appearance="full"
            class="orderListRepeat">
            <h4>MsItem <xf:output value="count(preceding-sibling::*)" class="inlineXfControl"/></h4>
            
            <xf:select1 id="msItemMainLangInput" class=""
            bind="msItemMainLang" >
            <xf:label class="" id="msItemMainLangLabel">Language</xf:label>
            <xf:itemset
                    ref="instance('langUsage')/./*[local-name() = 'language']">
                    <xf:label
                        ref="."/>
                    <xf:value
                        ref="./@*[local-name() = 'ident']"/>
                </xf:itemset>
        </xf:select1>
        <xf:input id="msItemModernTitleInput" bind="msItemModernTitle" class="fullwidth">
             <xf:label class="" id="msItemModernTitleInputLabel">Modern title</xf:label>   
        </xf:input>
        </xf:repeat>
    
    </xf:group>
    </div>
let $editionPane :=
    <div class="editionPane">
    {for $text at $index in $cleanTeiFile/*[local-name() = 'text']/*[local-name()='body']/*[local-name()='div'][@type='edition']//*[local-name()='div'][@type='textpart']
        return
        <div class="textpartPane" id="editionPane-{$index}">
                <!--
                <button id="editionPaneFullScreen"  class="btn btn-default btn-xs pull-right" onclick="toggleFullScreenEditionPane({$index})"><i class="glyphicon glyphicon-fullscreen"/></button>
                -->    
            <h3>Text {$index}<button id="callTextImport-{$index}"  onclick="openTextImporter({$index})" class="btn btn-default pull-right" data-target="#dialogTextImport">Import text</button></h3>
            
            
            
            <!--
            <ul class="nav nav-pills mb-3" id="pills-edition-tab-{$index}" role="tablist">
                <li class="nav-item active">
                    <a class="nav-link" id="pills-edition-xml-tab-{$index}" data-toggle="pill" href="#nav-edition-xml" role="tab" aria-controls="pills-home" aria-selected="false">XML</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" id="pills-edition-leiden-tab-{$index}" data-toggle="pill" href="#nav-edition-leiden" role="tab" aria-controls="pills-home" aria-selected="false">Leiden+</a>
                </li>
             </ul>
             -->
             <!--Was for the tab XML/Leiden+   -->
            
            <!--<div class="tab-content" id="nav-tabContent">
                <div class="tab-pane fade in active" id="nav-edition-xml" role="tabpanel" aria-labelledby="nav-metadata-tab">
                -->
                <!--Was for the tab XML/Leiden+   -->
                
                <div id="nav-edition-xml"  class="btn-group" role="group" aria-label="...">
                <xf:select1 id="msItemMainLangInput-{$index}" class=""
            bind="msItemMainLang" size="50%">
            <xf:label class="" id="msItemMainLangLabel-{$index}">Language</xf:label>
            <xf:itemset
                    ref="instance('langUsage')/./*[local-name() = 'language']">
                    <xf:label
                        ref="."/>
                    <xf:value
                        ref="./@*[local-name() = 'ident']"/>
                </xf:itemset>
        </xf:select1>               
                </div>
                
                
                    <div id="edition-toolbar-{$index}" class="btn-group xmlToolBar" role="group" aria-label="..." >
                            
                            
                       <div class="dropdown btn-group" role="group">
                            <a id="insertLb" role="button" data-toggle="dropdown" class="btn btn-default btn-xs" data-target="#" >
                                (1)<span class="caret"></span>
                            </a>
                    		<ul class="dropdown-menu multi-level" role="menu" aria-labelledby="dropdownMenu">
                              
                              <li class="dropdown-submenu">
                                    <a href="#">Line break</a>
                                    <ul class="dropdown-menu">
                                        <li><a role="button" onclick="insertLb({$index}, 1)">1</a></li>
                                    	<li><a role="button" onclick="insertLb({$index}, 2)">2</a></li>
                                    	<li><a role="button" onclick="insertLb({$index}, 3)">3</a></li>
                                    	<li><a role="button" onclick="insertLb({$index}, 4)">4</a></li>
                                    	<li><a role="button" onclick="insertLb({$index}, 5)">5</a></li>
                                    	<li><a role="button" onclick="insertLb({$index}, 6)">6</a></li>
                                    	<li><a role="button" onclick="insertLb({$index}, 7)">7</a></li>
                                    	<li><a role="button" onclick="insertLb({$index}, 8)">8</a></li>
                                    	<li><a role="button" onclick="insertLb({$index}, 9)">9</a></li>
                                    	<li><a role="button" onclick="insertLb({$index}, 10)">10</a></li>
                                    </ul>
                                  </li>
                              <li class="dropdown-submenu">
                                    <a href="#">Column break</a>
                                    <ul class="dropdown-menu">
                                        <li><a role="button" onclick="insertCb({$index}, 1)">1</a></li>
                                    	<li><a role="button" onclick="insertCb({$index}, 2)">2</a></li>
                                    	<li><a role="button" onclick="insertCb({$index}, 3)">3</a></li>
                                    	<li><a role="button" onclick="insertCb({$index}, 4)">4</a></li>
                                    	<li><a role="button" onclick="insertCb({$index}, 5)">5</a></li>
                                    </ul>
                                  </li>
                              
                            </ul>
        </div>

                            
                            <button type="button" class="btn btn-xs btn-default" onclick="unclear({$index});" title="Unclear character(s)">Ạ</button>
                            <button type="button" class="btn btn-xs btn-default" onclick="supplied({$index}, 'lost')" title="Restauration">[a]</button>
                            <button type="button" class="btn btn-xs btn-default" onclick="surplus({$index})" title="Surplus">&#123;a&#125;</button>
                            <button type="button" class="btn btn-xs btn-default" onclick="supplied({$index}, 'omitted')" title="Supplied - erroneously omitted">&#60;a&#62;</button>
                            <button type="button" class="btn btn-xs btn-default" onclick="erasure({$index})" title="Erasure"> ⟦a⟧</button>
                            
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
                            
<div class="dropdown btn-group" role="group">
            <a id="dLabel" role="button" data-toggle="dropdown" class="btn btn-default btn-xs" data-target="#" >
                Illegible<span class="caret"></span>
            </a>
    		<ul class="dropdown-menu multi-level" role="menu" aria-labelledby="dropdownMenu">
              
              <li class="dropdown-submenu">
                    <a href="#">Character</a>
                    <ul class="dropdown-menu">
                        <li><a role="button" onclick="illegible({$index}, 'character', 'unknown')">Unknown</a></li>
                        <li><a role="button" onclick="illegible({$index}, 'character', 1)">1</a></li>
                    	<li><a role="button" onclick="illegible({$index}, 'character', 2)">2</a></li>
                    	<li><a role="button" onclick="illegible({$index}, 'character', 3)">3</a></li>
                    	<li><a role="button" onclick="illegible({$index}, 'character', 4)">4</a></li>
                    	<li><a role="button" onclick="illegible({$index}, 'character', 5)">5</a></li>
                    	<li><a role="button" onclick="illegible({$index}, 'character', 6)">6</a></li>
                    	<li><a role="button" onclick="illegible({$index}, 'character', 7)">7</a></li>
                    	<li><a role="button" onclick="illegible({$index}, 'character', 8)">8</a></li>
                    	<li><a role="button" onclick="illegible({$index}, 'character', 9)">9</a></li>
                    	<li><a role="button" onclick="illegible({$index}, 'character', 10)">10</a></li>
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


                          

<div class="dropdown btn-group" role="group">
            <a id="dLabel" role="button" data-toggle="dropdown" class="btn btn-default btn-xs" >
                Vacat<span class="caret"></span>
            </a>
    		<ul class="dropdown-menu multi-level" role="menu" aria-labelledby="dropdownMenu">
              
              <li class="dropdown-submenu">
                    <a href="#">Character</a>
                    <ul class="dropdown-menu">
                        <li><a href="#" role="button" onclick="vacat_char({$index}, 1)">1</a></li>
                    	<li><a href="#" role="button" onclick="vacat_char({$index}, 2)">2</a></li>
                    	<li><a href="#" role="button" onclick="vacat_char({$index}, 3)">3</a></li>
                    	<li><a href="#" role="button" onclick="vacat_char({$index}, 4)">4</a></li>
                    	<li><a href="#" role="button" onclick="vacat_char({$index}, 5)">5</a></li>
                    	<li><a href="#" role="button" onclick="vacat_char({$index}, 6)">6</a></li>
                    	<li><a href="#" role="button" onclick="vacat_char({$index}, 7)">7</a></li>
                    	<li><a href="#" role="button" onclick="vacat_char({$index}, 8)">8</a></li>
                    	<li><a href="#" role="button" onclick="vacat_char({$index}, 9)">9</a></li>
                    	<li><a href="#" role="button" onclick="vacat_char({$index}, 10)">10</a></li>
                    </ul>
                  </li>
              <li class="dropdown-submenu">
                    <a href="#">Line</a>
                    <ul class="dropdown-menu">
                        <li><a href="#" role="button" onclick="vacat_line({$index}, 1)">1</a></li>
                    	<li><a href="#" role="button" onclick="vacat_line({$index}, 2)">2</a></li>
                    	<li><a href="#" role="button" onclick="vacat_line({$index}, 3)">3</a></li>
                    	<li><a href="#" role="button" onclick="vacat_line({$index}, 4)">4</a></li>
                    	<li><a href="#" role="button" onclick="vacat_line({$index}, 5)">5</a></li>
                    	
                    </ul>
                  </li>
              
            </ul>
        </div>
        <!--</div>           
            </div>--><!--Was for the tab XML/Leiden+   -->
                    <div class="col-xs-12 col-sm-12 col-md-12">
                    <div id="xml-editor-{$index}" class="xmlEditor"></div>
                    
                    <div class="col-xs-8 col-sm-8 col-md-8">
                    <h4>Preview</h4>
                    <div id="textPreviewHTML-{$index}" class="textPreviewHTML"/>
                    </div>
                    <div class="col-xs-4 col-sm-4 col-md-4"> 
                    <h4>Current element</h4>
                    <div id="current-xml-element-{$index}" />
                    </div>
                 </div>
                 <!--
                 <div class="tab-pane fade in" id="nav-edition-leiden" role="tabpanel" aria-labelledby="nav-metadata-tab">
                    <div id="leiden-editor-{$index}" class="leidenEditor">
               </div>
                 </div>
                 --><!--Was for the tab XML/Leiden+   -->
                 </div>
            
        </div>
        
    }
    </div>


let $textEditionSection :=
    <xf:group
        appearance="minimal" class="">
        <xf:repeat
            id="textEditionRepeat"
            bind="doc_textEdition"
            appearance="full"
            class="orderListRepeat">
            
            <xf:textarea id="ancientTextInRepeat" class="fullwidth"
            bind="doc_textpart" >
            <xf:label class="labelOut" id="docBiblioRawLabel">Ancient Text (betterform): </xf:label>
            
        </xf:textarea>
        </xf:repeat>
    
    </xf:group>


return
    <div data-template="templates:surround" data-template-with="templates/page-admin.html" data-template-at="content"
       >
        
        
<!--        <div class="hidden" >-->
{$model}
        <!--</div>-->
      
    <div class="" id="newDoc">
          
                <div class="col-xs-12 col-sm-12 col-md-12">
                    <h3><xf:output bind="doc_stmtTitle"></xf:output> <span class="pull-right">{$docId}</span></h3>
                    <xf:trigger id="createConceptButton" appearance="minimal" class="btn btn-primary">
            <xf:label>Save</xf:label>    
            <xf:action ev:event="DOMActivate">
                <xf:send submission="s_save_document"/>
                
            </xf:action>
            
       </xf:trigger>
          
          </div>
          <div class="col-xs-12 col-sm-12 col-md-12">
          
<!--          TABS-->
<ul class="nav nav-pills mb-3" id="pills-tab" role="tablist">
  <li class="nav-item">
    <a class="nav-link" id="pills-home-tab" data-toggle="pill" href="#nav-metadata" role="tab" aria-controls="pills-home" aria-selected="false">Metadata</a>
  </li>
  <li class="nav-item active">
    <a class="nav-link" id="pills-text-tab" data-toggle="pill" href="#nav-text" role="tab" aria-controls="pills-profile" aria-selected="true">Text</a>
  </li>
  <li class="nav-item">
    <a class="nav-link" id="pills-profile-tab" data-toggle="pill" href="#nav-commentary" role="tab" aria-controls="pills-profile" aria-selected="false">Commentary</a>
  </li>
</ul>

<div class="tab-content" id="nav-tabContent">
    <div class="tab-pane fade" id="nav-metadata" role="tabpanel" aria-labelledby="nav-metadata-tab">
  
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
                                      {$titleEditionPanel}
                                        
                            </div>
                      </div>
                </div>
                <div class="panel panel-default">
                <div class="panel-heading"  data-toggle="collapse"  href="#titlepanel">msItems</div>
                        <div id="msItemspanel" class="panel-collapse collapse in">
                              <div class="panel-body">
                                 {$textManagerPane}     
                                        
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



  <div class="tab-pane fade in active" id="nav-text" role="tabpanel" aria-labelledby="nav-text-tab">
  
  {$editionPane}
  <br/>************************************
  {$textEditionSection}
  
  
  
 
        <div class="col-xs-10 col-sm-10 col-md-10">
             <div id="editor"></div>
            <h5>Preview</h5>
            <div id="textPreviewHTML" class="" />
            
            <xf:textarea id="ancientText" class="fullwidth hiddenbfTextArea"
            bind="doc_textEditionSingle" >
            <xf:label class="labelOut" id="docBiblioRawLabel">Ancient Text (betterform): </xf:label>
            
        </xf:textarea>
        
          <!--<div id="testValue">{$text}</div>-->  
       </div>
      <!--End of row--> 
         <div class="col-xs-1 col-sm-1 col-md-1">
         <h5>TEI Elements Insertion</h5>
         
         <div class="btn-group-vertical" role="group">
              <button id="callSupplied"  class="btn btn-default" data-target="#dialogSupplied">Supplied</button>
              <button id="callGap" class="btn btn-default" data-target="#dialogSupplied">Lacuna</button>
              <button id="callLb" class="btn btn-default" data-target="#dialogSupplied">Line break</button>
         
         </div>
          
         <div class="btn-group-vertical" role="group">
              <button id="callPlaceName"  class="btn btn-default"
              data-target="#dialogPlaceName">Place name</button>
             
         
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
        </div>
        
  
  </div><!--End of Text tab-->








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
  
        
        </div><!--End of container-->



        
    <script>
        
        
        
        
    </script>            
  
   </div>
