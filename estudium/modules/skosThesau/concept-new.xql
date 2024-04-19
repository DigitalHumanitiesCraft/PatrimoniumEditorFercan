xquery version "3.1";

import module namespace config="https://ausohnum.huma-num.fr/apps/eStudium/config" at "../config.xqm";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";


declare namespace ev = "http://www.w3.org/2001/xml-events";
declare namespace thot = "http://thot.ulg.ac.be/";
declare namespace xf = "http://www.w3.org/2002/xforms";
declare namespace dct = "http://purl.org/dc/terms/";
declare namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/";


declare namespace local = "local";

declare option exist:serialize "method=xml media-type=text/html omit-xml-declaration=no indent=yes";
(:declare option output:method "html5";
declare option output:media-type "text/html";
:)
declare variable $appVariables := doc($config:data-root || "/app-general-parameters.xml");

let $now := fn:current-dateTime()
let $baseUri := doc($config:data-root || "/app-general-parameters.xml")//uriBase/text()
let $data-collection := collection($config:data-root || "/concepts")
let $concept := request:get-parameter('concept', '')
let $path2CreateXql := xs:anyURI($appVariables//uriBase/text() || "/modules/skosThesau/concept-create.xql")


let $schemeShortName := request:get-parameter('scheme', '')

let $btConceptId := request:get-parameter('conceptId', '')
let $btConcept := $data-collection//id($btConceptId)
let $btConceptUri := $btConcept/@rdf:about/string()

let $scheme-uri :=
        if($schemeShortName) then $data-collection//skos:ConceptScheme[@rdf:about[contains(., $schemeShortName)]]/@rdf:about
        else($btConcept//skos:inScheme/@rdf:resource/string())
        

let $currentConceptSchemeTopConcept := substring-after($data-collection//skos:ConceptScheme[@rdf:about = $scheme-uri]/skos:hasTopConcept/@rdf:resource/string(), '/concept/')
let $currentUser := data(sm:id()//sm:username)
let $userPrimaryGroup := sm:get-user-primary-group($currentUser)
let $schemes := $data-collection//rdf:RDF/skos:ConceptScheme[dc:publisher="Thot Project"]
let $schemeList :=
        for $scheme in $schemes
        order by $scheme/dc:title[@xml:lang='en']/text() ascending
        return
        (<xf:item>
        <xf:label>{$scheme/dc:title[@xml:lang='en']/text()}</xf:label>
        <xf:value>{data($scheme/@rdf:about)}</xf:value>
        </xf:item>)
 let $idList := for $id in $data-collection//.[contains(./@xml:id, 'thot-')]
        return
        <item>
        {substring-after($id/@xml:id, 'thot-')}
        </item>

 let $last-id:= fn:max($idList)
(: let $increment-id := fn:sum($last-id, '1'):)
let $thotNum := concat('thot-', fn:sum($last-id, '1'))

let $model := <div
    id="xform_model"
>
    <xf:model
        id="m_concept"

        xmlns:skos="http://www.w3.org/2004/02/skos/core#"
        xmlns:skosThesau="https://ausohnum.huma-num.fr/skosThesau/"
        
    >

        <xf:instance
            xmlns=""
            id="i_concept"
            
            >
            <!--skos:Concept xml:id="thot-{fn:sum(($last-id, 1))}" rdf:about="{$baseUri}/concept/thot-{fn:sum(($last-id, 1))}" -->
            <skos:Concept
                    type="non-ordered" nodeLabel="">
                    <skos:prefLabel xml:lang="ar"/>
                    <skos:prefLabel xml:lang="de"/>
                    <skos:prefLabel xml:lang="en"/>
                    <skos:prefLabel xml:lang="fr"/>
                    <skos:prefLabel xml:lang="xml"/>
                    <skos:altLabel xml:lang="en"/>

                    <skos:scopeNote xml:lang="en"/>
                    <skos:inScheme rdf:resource="{$scheme-uri}"/>

                    <skos:broader rdf:resource="{$btConceptUri}"/>
                    <skosThesau:admin status="private"/>
                    <skosThesau:adminComment/>
                    <dct:created>{$now}</dct:created>
                    <dct:modified>{$now}</dct:modified>
                </skos:Concept>
            </xf:instance>
        <xf:instance xmlns=""
            id="i_templates">
              <data>
                <skos:prefLabel xml:lang=""/>
                <skos:altLabel xml:lang=""/>
                <dc:title xml:lang=""/>
                <skos:narrower rdf:resource=""/>
                <skos:broader rdf:resource=""/>

              </data>
           </xf:instance>
    <xf:instance xmlns="" id="i_template4prefLabel">
        <skos:prefLabel xml:lang=""/>
    </xf:instance>
    <xf:instance xmlns="" id="template4dcTitle">
        <dc:title xml:lang=""/>
    </xf:instance>
    <xf:instance xmlns="" id="all_concepts"
    src="modules/skosThesau/getSchemeItems.xql?schemeUri={$scheme-uri}"
    />




        <!--
        <xf:instance
            xmlns=""
            id="current_scheme_concepts"
            src="http://thot.philo.ulg.ac.be/apps/thot/modules/instance_gen_current_scheme.xql?concept={$concept}"
        />
      -->



       <!--BINDINGS to canonical Concept-->
       <xf:bind
            id="i_concept_id"
            ref="instance('i_concept')/./@xml:id"/>
            <xf:bind
            id="i_concept_uri"
            ref="instance('i_concept')/./@*[local-name() = 'about']"/>


        <xf:bind
            id="i_concept_scopenote"
            ref="instance('i_concept')/./*[local-name() = 'scopeNote']"
           />

        <xf:bind
            id="i_concept_adminComment"
            ref="instance('i_concept')/./*[local-name() = 'adminComment']"
            />

       <xf:bind
            id="i_concept_status"
            ref="instance('i_concept')/./*[local-name() = 'admin']/@status"/>

       <xf:bind
            id="i_concept_inScheme"
            ref="instance('i_concept')/./*[local-name() = 'inScheme']/@*[local-name() = 'resource']"/>

       <!--      Bindings for PrefLabels Terms as table     -->

          <xf:bind id="prefLabels"
          ref="instance('i_concept')/./*[local-name() = 'prefLabel']"
            required=".[@*[local-name() = 'lang'] ='en'] and not(exists(./parent::node()/*[local-name() = 'title']))"
          >
                        <xf:bind id="prefLabelAlpha" ref="." />
                        <xf:bind id="langPrefLabelAlpha" ref="./@*[local-name() = 'lang']" />

          </xf:bind>

       <!--      Bindings for dc:title as table     -->

          <xf:bind id="dcTitles"
          ref="instance('i_concept')/./*[local-name() = 'title']"
          >
                        <xf:bind id="dcTitleAlpha" ref="." />
                        <xf:bind id="langDcTitleAlpha" ref="./@*[local-name() = 'lang']"  />

          </xf:bind>

       <!--      Bindings for AltLabels' Terms as table     -->

          <xf:bind id="altLabels"
          ref="instance('i_concept')/./*[local-name() = 'altLabel']"

          >
                        <xf:bind id="altLabelAlpha" ref="." />
                        <xf:bind id="langAltLabelAlpha" ref="./@*[local-name() = 'lang']" />

          </xf:bind>

<!--         Bindings pour Narrower Terms     -->

          <xf:bind id="narrowerterms"
          ref="instance('i_concept')/./*[local-name() = 'narrower']"
          >
                        <xf:bind id="prefLabelEn" ref="./*[local-name() = 'prefLabel'][@*[local-name()='lang'] ='en']" required="true()"/>
                        <xf:bind id="conceptNo" ref="./@*[local-name() = 'resource']"  />

          </xf:bind>

<!--         Bindings pour Broader Terms     -->

          <xf:bind id="broaderterms"
          ref="instance('i_concept')/./*[local-name() = 'broader']">
                        <xf:bind id="prefLabelEnBT" ref="./*[local-name() = 'prefLabel'][@*[local-name()='lang'] ='en']" required="true()" />
                        <xf:bind id="conceptNo" ref="./@*[local-name() = 'resource']"  />

          </xf:bind>

           <xf:bind
            id="collectionType"
            ref="instance('i_concept')/./@type"
           />
           <xf:bind
            id="nodeLabel"
            ref="instance('i_concept')/./@nodeLabel"
           />


         <xf:schema id="s-schema">

    <xs:element name="xmlvalue">
   <xf:simpleType>
      <xf:restriction base="xs:integer">
         <!--<xs:length value="8"/>
         <xf:pattern value="[A-Za-z0-9]+"/>  -->
      </xf:restriction>
       </xf:simpleType>
       </xs:element>
    </xf:schema>

       <!--
        <xf:submission
            id="s_concept"
            validate="false"
            replace="instance"
            method="post"

            resource="http://thot.philo.ulg.ac.be/apps/thot-studio/data/concept"
            instance="i_concept"

        />
        -->
            <!--
                <xf:action ev:event="xforms-submit-done">
                 <xf:message level="ephemeral">Submitted data from model-1 to model-2</xf:message>
                    </xf:action>
                     <xf:action ev:event="xforms-submit-error">
                         <xf:message>Submitted data from model-1 to model-2 failed.</xf:message>
                     </xf:action>
                     -->

        <xf:submission
            id="s_create"
            method="post"
            ref="instance('i_concept')"
            resource="{$path2CreateXql}"
            includenamespaceprefixes="skos thot skosThesau"
        >
        <!--<xf:message ev:event="xforms-submit-error" level="ephemeral">submission1 error (<xf:output value="event('response-status-code')"/>)</xf:message>
        -->
        </xf:submission>


        <!--
        <xf:submission
            id="s_submit_revision"
            method="post"

 ref="instance('i_conceptFull{string($concept)}')"
            action="http://thot.philo.ulg.ac.be/apps/thot/modules/update-concept.xql"
        />

            -->

        <xf:action
            ev:observer="s_create"
            ev:event="xforms-submit">
            <xf:message
                level="ephemeral">Saving data...</xf:message>
        </xf:action>
        <xf:action
            ev:observer="s_create"
            ev:event="xforms-submit-error">
            <xf:message
                level="ephemeral">Error in submission!</xf:message>
        </xf:action>


        <xf:action
            ev:observer="s_create"
            ev:event="xforms-submit-done">
            <xf:load resource="javascript:loadConcept({{fn:sum(($last-id, 1))}})"/>

        </xf:action>


    </xf:model>
</div>



let $prefLabels :=

<div class="admin-subpanel">
                            <h3>Preferred label(s)</h3>

            <xf:group appearance="minimal">

              <xf:repeat id="prefLabelsRepeat" bind="prefLabels" appearance="compact" class="orderListRepeat">
                   <xf:input id="prefLabelLang" appearance="minimal" bind="langPrefLabelAlpha" incremental="true" size="3">
                        <xf:label id="langprefLabels_label">Lang.</xf:label>
                        <xf:hint>Enter a language</xf:hint>
                   </xf:input>
                   <xf:input id="prefLabelInput" appearance="minimal" bind="prefLabelAlpha" size="100%" incremental="true">
                        <xf:label id="prefLabels_label">Preferred Label</xf:label>
                        <xf:hint>Enter a term</xf:hint>

                   </xf:input>
              </xf:repeat>
    <xf:trigger appearance="minimal" class="btn btn-default">
            <xf:label>Add a Preferred Label</xf:label>
            <xf:action ev:event="DOMActivate">
            <xf:insert bind="prefLabels"
            context="instance('i_concept')"

               origin="instance('i_templates')/*[local-name() = 'prefLabel']"
               position="after"
              at="last()"
              />


               <xf:setvalue ref="val[last()]" value="count(/data/val)" />
            </xf:action>
         </xf:trigger>
         <xf:trigger appearance="minimal" class="btn btn-default">
         <xf:label>Delete selected</xf:label>
    <xf:action ev:event="DOMActivate">
        <xf:delete bind="prefLabels" at="index('prefLabelsRepeat')"/>
     </xf:action>
</xf:trigger>

                </xf:group>


</div>



let $dcTitles :=

<div class="admin-subpanel">
                            <h3>dc:Title(s)</h3>

            <xf:group appearance="minimal">


                    <xf:repeat id="dcTitleRepeat" bind="dcTitles" appearance="compact" class="orderListRepeat">
                    <xf:input id="dcTitleLangInput" appearance="minimal" bind="langDcTitleAlpha" incremental="true" size="3">
                        <xf:label id="langdctitle_label">Lang.</xf:label>
                        <xf:hint>Enter a language</xf:hint>
                      </xf:input>
                            <xf:input id="dcTitleInput" appearance="minimal" bind="dcTitleAlpha" size="100%" incremental="true">
                        <xf:label id="prefLabels_label">dc:title</xf:label>
                        <xf:hint>Enter a term</xf:hint>

                    </xf:input>



                        </xf:repeat>
<xf:trigger appearance="minimal" class="btn btn-default">
            <xf:label>Add a dc:title</xf:label>
            <xf:action ev:event="DOMActivate">

               <xf:insert bind="dcTitles"
               position="after"
               at="last()"
               origin="instance('i_templates')/*[local-name() = 'title']"
               />

               <xf:insert bind="dcTitles"
               context="instance('i_concept')"
               at="last()" position="after"
               origin="instance('i_templates')/*[local-name() = 'title']"
               nodeset="instance('i_concept')/*[local-name() = 'prefLabel']"
               if="count(instance('i_concept')/*[local-name() = 'title']) = 0"

               />

               <xf:setvalue ref="val[last()]" value="count(/data/val)" />
            </xf:action>
         </xf:trigger>
                    <xf:trigger appearance="minimal" class="btn btn-default">
  <xf:label>Delete selected</xf:label>
    <xf:action ev:event="DOMActivate">
        <xf:delete bind="dcTitles" at="index('dcTitleRepeat')"/>
     </xf:action>
</xf:trigger>
                </xf:group>


</div>


let $altLabels :=

<div class="admin-subpanel">
                            <h3>Alternative label(s)</h3>

            <xf:group appearance="minimal">

              <xf:repeat id="altLabelsRepeat" bind="altLabels" appearance="compact" class="orderListRepeat">
                   <xf:input id="altLabelLang" appearance="minimal" bind="langAltLabelAlpha" incremental="true" size="3">
                        <xf:label id="langAltLabels_label">Lang.</xf:label>
                        <xf:hint>Enter a language</xf:hint>
                   </xf:input>
                   <xf:input id="altLabelInput" appearance="minimal" bind="altLabelAlpha" size="100%" incremental="true">
                        <xf:label id="altLabels_label">Preferred Label</xf:label>
                        <xf:hint>Enter a term</xf:hint>

                   </xf:input>
              </xf:repeat>
    <xf:trigger appearance="minimal" class="btn btn-default">
            <xf:label>Add an Alternative Label</xf:label>
            <xf:action ev:event="DOMActivate">
            <xf:insert bind="altLabels"
            context="instance('i_concept')"

               origin="instance('i_templates')/*[local-name() = 'altLabel']"
               position="after"
              at="last()"
              />


               <xf:setvalue ref="val[last()]" value="count(/data/val)" />
            </xf:action>
         </xf:trigger>
         <xf:trigger appearance="minimal" class="btn btn-default">
         <xf:label>Delete selected</xf:label>
    <xf:action ev:event="DOMActivate">
        <xf:delete bind="prefLabels" at="index('altLabelsRepeat')"/>
     </xf:action>
</xf:trigger>

                </xf:group>


</div>


let $narrowertTerms :=

<div class="admin-subpanel">
                            <h3>Narrower term(s)</h3>

            <xf:group appearance="minimal">
                        <xf:repeat id="repeatNT" bind="narrowerterms" appearance="compact" class="orderListRepeat">

                            <xf:select1 id="NTConcept" bind="conceptNo" incremental="true">
                        <xf:label id="labelPrefLabel">PreferredLabel </xf:label>
                        <xf:hint>Choose a concept to be added as Narrower term</xf:hint>



                        <xf:itemset ref="instance('all_concepts')/./concept">
                            <xf:label ref="./label"/>
                            <xf:value ref="./url"/>
                        </xf:itemset>

                    </xf:select1>
                            <xf:output bind="conceptNo" class="text-right" incremental="true">
                                <xf:label class="contactsRepeatHeader">Concept ID</xf:label>
                            </xf:output>


                        </xf:repeat>
<xf:trigger appearance="minimal" class="btn btn-default">
            <xf:label>Add a Narrower Term</xf:label>
            <xf:action ev:event="DOMActivate">

              <xf:insert
              bind="narrowerterms"

              context="instance('i_concept')"
              origin="instance('i_templates')/*[local-name() = 'narrower']"

              position="after"
              at="last()"
              if="exists(instance('i_concept')/node()/*[local-name() = 'narrower'])"
              />

              <xf:insert
              context="instance('i_concept')"
              nodeset="instance('i_concept')/*[local-name() = 'narrower']|instance('i_concept')/*[local-name() = 'prefLabel']"
              position="after"
              at="last()"

              origin="instance('i_templates')/*[local-name() = 'narrower']"

              if="count(instance('i_concept')/*[local-name() = 'narrower']) = 0"/>




              <xf:setvalue ref="val[last()]" value="count(/data/val)" />
            </xf:action>
         </xf:trigger>
  <xf:trigger appearance="minimal" class="btn btn-default">
  <xf:label>Delete selected</xf:label>
    <xf:action ev:event="DOMActivate">
        <xf:delete bind="narrowerterms" at="index('repeatNT')"/>
     </xf:action>
</xf:trigger>

                </xf:group>






</div>


let $broaderTerms :=

<div class="admin-subpanel">
                            <h3>Broader term(s)
                            <xf:trigger appearance="minimal" class="btn-primary btn-xs pull-right">
  <xf:label><i
                    class="glyphicon glyphicon-minus"/></xf:label>
    <xf:action ev:event="DOMActivate">
        <xf:delete bind="broaderterms" at="index('repeatBT')"/>
     </xf:action>
</xf:trigger>


   </h3>

            <xf:group appearance="minimal">
                        <xf:repeat id="repeatBT" bind="broaderterms" appearance="compact" class="orderListRepeat">

<!--
                            <xf:select1 id="BTConcept" appearance="minimal" bind="conceptNo" incremental="true" >
                                    <xf:label id="region">PreferredLabel</xf:label>
                                     <xf:hint>Choose a concept to be added as Broader term</xf:hint>
                        <xf:itemset ref="instance('all_concepts')/./concept">
                            <xf:label ref="./label"/>
                            <xf:value ref="./url"/>
                        </xf:itemset>
                    </xf:select1>

<xf:output bind="prefLabelEnBT" class="text-right" >
                                <xf:label class="contactsRepeatHeader">prefLabel</xf:label>
                    </xf:output>
                    <xf:output bind="conceptNo" class="text-right" incremental="true">
                                <xf:label class="contactsRepeatHeader">Concept ID</xf:label>
                    </xf:output>
-->
                    <xf:input id="btUriInput" bind="conceptNo" size="100%"/>

                    

                        </xf:repeat>

                </xf:group>


</div>

return
    <div data-template="templates:surround"
    data-template-with="./templates/page.html" data-template-at="content"
    xmlns:bf="http://betterform.sourceforge.net/xforms"
    bf:toaster-position="br-up"
    >


    <!--

     <script src="http://thot.philo.ulg.ac.be/apps/thot-studio/resources/scripts/loadthesaurus.js" type="text/javascript"/>
    <script src="http://thot.philo.ulg.ac.be/apps/thot-studio/resources/scripts/thottree.js" type="text/javascript"/>   -->

    <script
            src="/resources/scripts/skosThesau.js"
            type="text/javascript"/>
   <div class="container">
   <div class="row">
            <div class="container-fluid">

        {$model}





<div class="col-xs-9 col-sm-9 col-md-9"
            id="xforms">
            <div class="row">
                <h3>New Concept

               <xf:output id="conceptidoutput" bind="i_concept_id">
               </xf:output>
</h3>

                <xf:select1 id="input_concept_status" class="pull-right" bind="i_concept_status" incremental="true">
                        <xf:label>Record status</xf:label>
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
                            <xf:label>Collaborators only</xf:label>
                            <xf:value>private</xf:value>
                        </xf:item>
                        <xf:item>
                            <xf:label>Trash</xf:label>
                            <xf:value>trash</xf:value>
                        </xf:item>

                </xf:select1>
                


                <xf:output id="output_concept_scheme"  bind="i_concept_inScheme" incremental="true">
                        <xf:label>This concept is being added to Scheme: </xf:label>

                </xf:output>
                



            </div>
   <div class="row">
   <xf:output id="concepturloutput" bind="i_concept_uri"><xf:label>URI will be: </xf:label>
               </xf:output>
   <div class="admin-subpanel">
    <h3>Type of record</h3>

           <xf:select id="nodeLabelInput" bind="nodeLabel" appearance="full" incremental="true">
                <xf:item>
                    <xf:label>'Node Label' for facet entry</xf:label>
                    <xf:value>nodeLabel</xf:value>
                 </xf:item>
            </xf:select>
            <br/>
            <xf:select id="typeInput" bind="collectionType" appearance="full" incremental="true">
                <xf:item>
                    <xf:label>Narrower Terms below are sorted alphabetically</xf:label>
                    <xf:value>ordered</xf:value>
                 </xf:item>
            </xf:select>

                </div>
                    {$prefLabels}
                    {$altLabels}
                    {$dcTitles}

                    {$broaderTerms}
                    {$narrowertTerms}


                <div
                    class="col-md-6">

                </div>
            </div>
            <div
                class="row">

         <br/>


            </div>
        </div>

  <div class="validation col-xs-3 col-sm-3 col-md-3">
        <h2>Save</h2>
       <xf:textarea
                 id="textarea_comment"
                 bind="i_concept_adminComment"
                 class="small-textarea">
             <xf:label>Leave a comment about changes</xf:label>
       </xf:textarea>

       <xf:trigger id="createConceptButton" appearance="minimal" class="btn btn-primary">
            <xf:label>Create Concept</xf:label>
            <xf:action ev:event="DOMActivate">
                <xf:send submission="s_create"/>
                <xf:load resource="javascript:loadConcept('{$thotNum}')"/>
            </xf:action>

       </xf:trigger>
           <xf:trigger
                        id="cancelEdition"
                        appearance="minimal"
                        class="btn btn-warning">
                        <xf:label>Cancel</xf:label>
                        <xf:action>
                            <xf:load
                                resource="javascript:loadConcept('{$currentConceptSchemeTopConcept}')"/>
                        </xf:action>
                    </xf:trigger>
       <!--
       <xf:trigger id="submitForRevision" appearance="minimal" class="btn btn-primary">
            <xf:label>Submit for revision</xf:label>
            <xf:action ev:event="DOMActivate">
                <xf:send submission="s_submit_revision"/>
            </xf:action>
            <xf:action >
                <xf:load resource="javascript:reloadPage()"/>
            </xf:action>
       </xf:trigger>
     -->
</div>


        </div>
</div>
</div>

</div>
