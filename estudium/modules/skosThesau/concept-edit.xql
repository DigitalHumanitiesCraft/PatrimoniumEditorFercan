xquery version "3.1";

import module namespace config="https://ausohnum.huma-num.fr/apps/eStudium/config" at "../config.xqm";

declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace processConcept="https://ausohnum.huma-num.fr/skosThesau/processConcept";

declare namespace ev = "http://www.w3.org/2001/xml-events";
declare namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/";

declare namespace xf = "http://www.w3.org/2002/xforms";
declare namespace dct = "http://purl.org/dc/terms/";
declare namespace local = "local";
declare option exist:serialize "method=xml media-type=text/html omit-xml-declaration=no indent=yes";
declare variable $appVariables := doc($config:data-root || "/app-config.xml");
declare variable $processConcept:requests := collection("/db/apps/thot/data/requests");

let $input := collection($config:data-root ||"/concepts")
let $conceptId := request:get-parameter('concept', '')
let $currentUser := data(sm:id()//sm:username)
let $userPrimaryGroup := sm:get-user-primary-group($currentUser)
let $path2updateXql := xs:anyURI($appVariables//uriBase/text() || "/modules/skosThesau/concept-update.xql")
let $path2SubmitRevisionXql := xs:anyURI($appVariables//uriBase/text() || "/modules/skosThesau/concept-submit-revision.xql")

let $conceptNode :=  $input//id($conceptId)
let $schemeEditors := $input//rdf:RDF/skos:ConceptScheme[@rdf:about=$conceptNode/skos:inScheme/@rdf:resource]//dc:creator[@role='editor']/@ref/string()


let $model :=
<div
    id="xform_model">
    <xf:model
        id="m_concept">

        <xf:instance
            xmlns=""
            id="i_concept">
        <skosThesau:xfinstances>
            <skosThesau:xfinstance type="original">
                {$input//skos:Concept[@xml:id eq $conceptId]|$input//skos:Collection[@xml:id eq $conceptId]}
            </skosThesau:xfinstance>

            <skosThesau:xfinstance type="update">
            {$input//skos:Concept[@xml:id eq $conceptId]|$input//skos:Collection[@xml:id eq $conceptId]}
            <skos:scopeNote xml:lang="en"/>
            </skosThesau:xfinstance>
                <skosThesau:xfinstance type="admin">
            <skosThesau:adminComment ref="{$conceptId}" group="{$userPrimaryGroup}" user="{$currentUser}" type="concept-update" xml:lang="en">
            <dct:created>{fn:current-dateTime()}</dct:created>
            </skosThesau:adminComment>
            </skosThesau:xfinstance>
            <skosThesau:xfinstance type="template4NBT">
                   <skos:narrower rdf:resource='newNT'><skos:prefLabel xml:lang=""/></skos:narrower>
                   <skos:broader rdf:resource=''/>
                </skosThesau:xfinstance >
                <skosThesau:xfinstance type="template4prefLabel">
                   <skos:prefLabel xml:lang=''/>
                </skosThesau:xfinstance>
                <skosThesau:xfinstance type="template4dcTitle">
                   <dc:title xml:lang=''/>
                </skosThesau:xfinstance>
                <skosThesau:xfinstance type="template4altLabel">
                   <skos:altLabel xml:lang=''/>
                </skosThesau:xfinstance>
                <skosThesau:xfinstance type="template4exactMatch">
                   <skos:exactMatch>
                <skos:Concept rdf:about="">
                    <skos:prefLabel xml:lang="en"/>
                    <skos:notation/>
                    <skos:inScheme rdf:resource=""/>
                </skos:Concept>
            </skos:exactMatch>
                </skosThesau:xfinstance>
                <skosThesau:xfinstance type="tempInstance4NT">
                   <data>
                    <delete-topic-trigger/>
                    <tmp/>
                   </data>
                </skosThesau:xfinstance>
                <skosThesau:xfinstance type="addBT">
                   <data>
                    <delete-topic-trigger/>
                    <tmp/>
                   </data>
                </skosThesau:xfinstance >

            </skosThesau:xfinstances>


        </xf:instance>

        <xf:instance
            xmlns=""
            id="external_schemes"
        >
        {doc($config:data-root || '/schemes/external-schemes.rdf')}
        </xf:instance>

        <!--        BINDINGS to i_concept:)-->
        <xf:bind
            id="i_concept_id"
            ref="instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/@xml:id"/>
        <xf:bind
            id="i_concept_status"
            ref="instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/*[local-name() = 'admin']/@status"
            relevant="not(boolean(string(instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/*[local-name() = 'admin']/@status) =''))"/>

        <xf:bind
            id="i_concept_collection_type"
            ref="instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/@type"/>

        <xf:bind
            id="i_concept_scopenote"

            ref="instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/*[local-name() = 'scopeNote']"
            relevant="exists(instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/*[local-name() = 'scopeNote'])"/>



        <xf:bind
            id="i_concept_new_scopenote"
            ref="instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/*[local-name() = 'scopeNote']"
            relevant="not(exists(instance('i_concept')/*[local-name() = 'xfinstance'][@type='original']/node()/*[local-name() = 'scopeNote']))"/>


        <!--      Bindings for PrefLabels Terms as table     -->

        <xf:bind
            id="prefLabels"
            ref="instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/*[local-name() = 'prefLabel']"
        >
            <xf:bind
                id="prefLabelAlpha"
                ref="."
                required="true()"/>
            <xf:bind
                id="langPrefLabelAlpha"
                ref="./@*[local-name() = 'lang']"
                required="true()"/>

        </xf:bind>

        <!--      Bindings for dc:title as table     -->

        <xf:bind
            id="dcTitles"
            ref="instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/*[local-name() = 'title']"
        >
            <xf:bind
                id="dcTitleAlpha"
                ref="."
                required="true()"/>
            <xf:bind
                id="langDcTitleAlpha"
                ref="./@*[local-name() = 'lang']"/>

        </xf:bind>



        <!--         Bindings pour Narrower Terms     -->

        <xf:bind
            id="narrowerterms"
            ref="instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/*[local-name() = 'narrower']"
        >

            <xf:bind
                id="conceptNo"
                ref="./@*[local-name() = 'resource']"/>
            <xf:bind
                id="prefLabelNT"
                ref="./*[local-name() = 'prefLabel']"
                relevant="../@*[local-name()='resource'] = 'newNT'"
                required="true()"/>
            <xf:bind
                id="prefLabelNTLang"
                ref="./*[local-name() = 'prefLabel']/@*[local-name()='lang']"
                required="true()"/>

        </xf:bind>

        <!-- Binding for re-sorted NTs -->
         <xf:bind id="delete-ordering-nt"
         nodeset="instance('i_concept')/*[local-name() = 'xfinstance'][@type='tempInstance4NT']/node()/delete-topic-trigger"
        relevant="instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/@type='ordered'"/>

        <!--         Bindings pour Broader Terms     -->

        <xf:bind
            id="broaderterms"
            ref="instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/*[local-name() = 'broader']" >
            <xf:bind
                id="prefLabelEnBT"
                ref="./*[local-name() = 'prefLabel'][@*[local-name()='lang'] ='en']"

               />
            <xf:bind
                id="conceptNo"
                ref="./@*[local-name() = 'resource']"/>

        </xf:bind>

         <!-- Binding for allowing addition of BTs -->
         <xf:bind id="delete-addBT-trigger"
         nodeset="instance('i_concept')/*[local-name() = 'xfinstance'][@type='addBT']/node()/delete-topic-trigger"
        relevant="instance('i_concept')/*[local-name() = 'xfinstance'][@type='original']/node()/@id= substring-after(instance('current_scheme_concepts')//*[local-name() = 'hasTopConcept']/@*[local-name() = 'resource'], '/concept/')"/>


        <!--         Bindings for altLabel     -->

        <xf:bind
            id="altLabels"
            ref="instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/*[local-name() = 'altLabel']"
        >
            <xf:bind
                id="langAltLabel"
                ref="./@*[local-name()='lang']"
                required="true()"/>
            <xf:bind
                id="valueAltLabel"
                ref="."/>

        </xf:bind>
        <!-- Bindings exactMatch   -->
        <xf:bind
            id="exactMatches"
            ref="instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/*[local-name() = 'exactMatch']">
            <xf:bind
                id="exactMatchURL"
                ref="./*[local-name()='Concept']/@*[local-name()='resource']"
                required="true()"/>

            <xf:bind
                id="exactMatchThesaurus"
                ref="./*[local-name()='Concept']/*[local-name()='inScheme']/@*[local-name()='resource']"
                />
            <xf:bind
                id="exactMatchesPrefLabel"
                ref="./*[local-name()='Concept']/*[local-name()='prefLabel']"
                />
                <xf:bind
                id="exactMatchesPrefLabelLang"
                ref="./*[local-name()='Concept']/*[local-name()='prefLabel']/@*[local-name()='lang']"
                />
            <xf:bind
                id="exactMatchesNotation"
                ref="./*[local-name()='Concept']/*[local-name()='notation']"
                />

        </xf:bind>


        <xf:bind
            id="i_concept_adminComment"
            ref="instance('i_concept')/*[local-name() = 'xfinstance'][@type='admin']/*[local-name() = 'adminComment']"
            relevant="not(boolean(instance('i_concept')/*[local-name() = 'xfinstance'][@type='original']/*[local-name() = 'Concept']/*[local-name() = 'adminComment']))"/>




       <xf:submission
                 id="s_save_and_update"
                 method="post"
                 ref="instance('i_concept')"
                 replace="instance"
                 resource="{$path2updateXql}">

              <xf:message ev:event="xforms-submit-error" level="ephemeral">
                 Submit-error; resource-uri: <xf:output value="event('resource-uri')"/>
                 response-status-code: <xf:output value="event('response-status-code')"/>
                 Response-reason-phrase: <xf:output value="event('response-reason-phrase')"/>
              </xf:message>
              <xf:message ev:event="xforms-submit" level="ephemeral">Submitting...</xf:message>

              <xf:message ev:event="xforms-submit-done" level="ephemeral">
                 Data saved <xf:output value="event('response-message')"/>
              </xf:message>

              <xf:message ev:event="xforms-submit-error" level="ephemeral">
                 Submit-error; resource-uri: <xf:output value="event('resource-uri')"/>
                 response-status-code: <xf:output value="event('response-status-code')"/>
                 Response-reason-phrase: <xf:output value="event('response-reason-phrase')"/>
              </xf:message>
        </xf:submission>

        <xf:submission
                id="s_submit_revision"
                method="post"
                ref="instance('i_concept')"
                     replace="instance"
                action="{$path2SubmitRevisionXql}">
            <xf:message
                ev:event="xforms-submit"
                level="ephemeral">Submitting...
            </xf:message>

            <xf:message
                ev:event="xforms-submit-done"
                level="ephemeral">Data saved <xf:output value="event('response-message')"/>
            </xf:message>
       </xf:submission>

        <xf:action
            ev:observer="s_save_and_update"
            ev:event="xforms-submit-done">
            <xf:load resource="/apc/concept/{$conceptId}"/>

        </xf:action>
        <xf:action
            ev:observer="s_submit_revision"
            ev:event="xforms-submit-done">
            <xf:load resource="javascript:loadConcept('{$conceptId}')"/>
        </xf:action>



    </xf:model>
</div>



let $prefLabels :=

<div
    class="admin-subpanel">
    <h3>Preferred label(s)

        <xf:trigger
            appearance="minimal"
            class="btn-primary btn-xs pull-right">
            <xf:label><i
                    class="glyphicon glyphicon-minus"/></xf:label>
            <xf:action
                ev:event="DOMActivate">
                <xf:delete
                    bind="prefLabels"
                    at="index('prefLabelsRepeat')"/>
            </xf:action>
        </xf:trigger>
        <xf:trigger
            appearance="minimal"
            class="btn-primary btn-xs pull-right">
            <xf:label><i
                    class="glyphicon glyphicon-plus"/></xf:label>
            <xf:action
                ev:event="DOMActivate">

                <xf:insert
                    bind="prefLabels"
                    position="after"
                    at="last()"
                    origin="instance('i_concept')/*[local-name() = 'xfinstance'][@type='template4prefLabel']/*[local-name() = 'prefLabel']"
                />
                <xf:insert
                    context="instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()"
                    at="last()"
                    position="after"
                    origin="instance('i_concept')/*[local-name() = 'xfinstance'][@type='template4prefLabel']/*[local-name() = 'prefLabel']"

                    if="count(instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/*[local-name() = 'prefLabel']) = 0"/>


                <xf:setvalue
                    ref="val[last()]"
                    value="count(/data/val)"/>
            </xf:action>
        </xf:trigger>
    </h3>

    <xf:group
        appearance="minimal">


        <xf:repeat
            id="prefLabelsRepeat"
            bind="prefLabels"
            appearance="compact"
            class="orderListRepeat">
            <xf:input
                id="prefLabelLang"
                appearance="minimal"
                bind="langPrefLabelAlpha"
                incremental="true"
                size="3">
                <xf:label
                    id="langprefLabels_label">Lang.</xf:label>
                <xf:hint>Language</xf:hint>
            </xf:input>
            <xf:input
                id="prefLabelInput"
                appearance="minimal"
                bind="prefLabelAlpha"
                size="100%"
                incremental="true">
                <xf:label
                    id="prefLabels_label">Preferred Label</xf:label>
                <xf:hint>Enter a term</xf:hint>

            </xf:input>



        </xf:repeat>



    </xf:group>


</div>

let $altLabels :=

<div
    class="admin-subpanel">
    <h3>Alternate label(s)

        <xf:trigger
            appearance="minimal"
            class="btn-primary btn-xs pull-right">
            <xf:label><i
                    class="glyphicon glyphicon-minus"/></xf:label>
            <xf:action
                ev:event="DOMActivate">
                <xf:delete
                    bind="altLabels"
                    at="index('altLabelsRepeat')"/>
            </xf:action>
        </xf:trigger>
        <xf:trigger
            appearance="minimal"
            class="btn-primary btn-xs pull-right">
            <xf:label><i
                    class="glyphicon glyphicon-plus"/></xf:label>
            <xf:action
                ev:event="DOMActivate">

                <xf:insert
                    bind="altLabels"
                    context="instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()"
                    position="after"
                    at="last()"

                    origin="instance('i_concept')/*[local-name() = 'xfinstance'][@type='template4altLabel']/*[local-name() = 'altLabel']"
                    if="exists(instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/*[local-name() = 'altLabel'])"/>

                <xf:insert
                    context="instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()"
                    nodeset="instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/*[local-name() = 'prefLabel']|instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/*[local-name() = 'title']"
                    at="last()"
                    position="after"
                    origin="instance('i_concept')/*[local-name() = 'xfinstance'][@type='template4altLabel']/*[local-name() = 'altLabel']"

                    if="count(instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/*[local-name() = 'altLabel']) = 0"/>


                <xf:setvalue
                    ref="val[last()]"
                    value="count(/data/val)"/>
            </xf:action>
        </xf:trigger>
    </h3>

    <xf:group
        appearance="minimal">

        <xf:repeat
            id="altLabelsRepeat"
            bind="altLabels"
            appearance="compact"
            class="orderListRepeat">
            <xf:input
                id="altLabelLang"
                appearance="minimal"
                bind="langAltLabel"
                incremental="true"
                size="3">
                <xf:label
                    id="langAltLabel_label">Lang.</xf:label>
                <xf:hint>Language</xf:hint>
            </xf:input>
            <xf:input
                id="altLabelInput"
                appearance="minimal"
                bind="valueAltLabel"
                size="100%"
                incremental="true">
                <xf:label
                    id="valueAltLabel_label">Preferred Label</xf:label>
                <xf:hint>Enter a term</xf:hint>

            </xf:input>



        </xf:repeat>


    </xf:group>


</div>








let $exactMatches :=

<div
    class="admin-subpanel">
    <h3>Exact match(es)

        <xf:trigger
            appearance="minimal"
            class="btn-primary btn-xs pull-right">
            <xf:label><i
                    class="glyphicon glyphicon-minus"/></xf:label>
            <xf:action
                ev:event="DOMActivate">
                <xf:delete
                    bind="exactMatches"
                    at="index('exactMatchesRepeat')"/>
            </xf:action>
        </xf:trigger>
        <xf:trigger
            appearance="minimal"
            class="btn-primary btn-xs pull-right">
            <xf:label><i
                    class="glyphicon glyphicon-plus"/></xf:label>
            <xf:action
                ev:event="DOMActivate">

                <xf:insert
                    bind="exactMatches"
                    context="instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()"
                    position="after"
                    at="last()"

                    origin="instance('i_concept')/*[local-name() = 'xfinstance'][@type='template4exactMatch']/*[local-name() = 'exactMatch']"
                    if="exists(instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/*[local-name() = 'exactMatch'])"/>
                    />

                <xf:insert

                    context="instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()"
                    nodeset="instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/*[local-name() = 'broader']|instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/*[local-name() = 'prefLabel']"
                    position="after"
                    at="last()"

                    origin="instance('i_concept')/*[local-name() = 'xfinstance'][@type='template4exactMatch']/node()"

                    if="count(instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/*[local-name() = 'exactMatch']) = 0"/>


                <xf:setvalue
                    ref="val[last()]"
                    value="count(/data/val)"/>
            </xf:action>
        </xf:trigger>
    </h3>

    <xf:group
        appearance="minimal">

        <xf:repeat
            id="exactMatchesRepeat"
            bind="exactMatches"
            appearance="compact"
            class="orderListRepeat">


           <xf:select1
                id="exactMatchExtThesaurus"
                bind="exactMatchThesaurus"
                incremental="true"
                size="20">
                <xf:label
                    id="labelPrefLabel">External Scheme</xf:label>
                <xf:hint>Choose a external Scheme</xf:hint>
                <xf:itemset
                    ref="instance('external_schemes')/./*[local-name() = 'ConceptScheme']">
                    <xf:label
                        ref="./*[local-name() = 'title']"/>
                    <xf:value
                        ref="./@*[local-name() = 'about']"/>
                </xf:itemset>
            </xf:select1>

            <xf:input
                id="exactMatchesPrefLabelInput"
                appearance="minimal"
                bind="exactMatchesPrefLabel"
                incremental="true"
                size="100%">
                <xf:label
                    id="exactMatchPrefLabel_label">prefLabel</xf:label>
                <xf:hint>Preferred label</xf:hint>
            </xf:input>

             <xf:input
                id="exactMatchesPrefLabelLangInput"
                appearance="minimal"
                bind="exactMatchesPrefLabelLang"
                incremental="true"
                size="3">
                <xf:label
                    id="exactMatchPrefLabelLang_label">Lang.</xf:label>
                <xf:hint>lang.</xf:hint>
            </xf:input>


            <xf:input
                id="exactMatchesNotationInput"
                appearance="minimal"
                bind="exactMatchesNotation"
                incremental="true"
                size="100%">
                <xf:label
                    id="exactMatchNotation_label">Notation</xf:label>
                <xf:hint>Notation</xf:hint>
            </xf:input>



        </xf:repeat>


    </xf:group>


</div>









let $dcTitles :=

<div
    class="admin-subpanel">
    <h3>dc:Title(s)
        <xf:trigger
            appearance="minimal"
            class="btn-primary btn-xs pull-right">
            <xf:label><i
                    class="glyphicon glyphicon-minus"/></xf:label>
            <xf:action
                ev:event="DOMActivate">
                <xf:delete
                    bind="dcTitles"
                    at="index('dcTitleRepeat')"/>
            </xf:action>
        </xf:trigger>
        <xf:trigger
            appearance="minimal"
            class="btn-primary btn-xs pull-right">
            <xf:label><i
                    class="glyphicon glyphicon-plus"/></xf:label>
            <xf:action
                ev:event="DOMActivate">
                <xf:insert
                    bind="dcTitles"
                    context="instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()"
                    position="after"
                    at="last()"
                    origin="instance('i_concept')/*[local-name() = 'xfinstance'][@type='template4dcTitle']/*[local-name() = 'title']"
                    if="exists(instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/*[local-name() = 'title'])"/>
                <xf:insert
                    context="instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()"
                    nodeset="instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/*[local-name() = 'prefLabel']"
                    at="last()"
                    position="after"
                    origin="instance('i_concept')/*[local-name() = 'xfinstance'][@type='template4dcTitle']/*[local-name() = 'title']"

                    if="count(instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/*[local-name() = 'title']) = 0"

                />

                <xf:setvalue
                    ref="val[last()]"
                    value="count(/data/val)"/>
            </xf:action>
        </xf:trigger>
    </h3>
    <xf:group
        appearance="minimal">
        <xf:repeat
            id="dcTitleRepeat"
            bind="dcTitles"
            appearance="compact"
            class="orderListRepeat">
            <xf:input
                id="dcTitleLang"
                appearance="minimal"
                bind="langDcTitleAlpha"
                incremental="true"
                size="3">
                <xf:label
                    id="langdctitle_label">Lang.</xf:label>
                <xf:hint>Language</xf:hint>
            </xf:input>
            <xf:input
                id="dcTitleInput"
                appearance="minimal"
                bind="dcTitleAlpha"
                size="100%"
                incremental="true">
                <xf:label
                    id="prefLabels_label">dc:title</xf:label>
                <xf:hint>Enter a term</xf:hint>
            </xf:input>
        </xf:repeat>


    </xf:group>


</div>





let $narrowertTerms :=

<div
    class="admin-subpanel">
    <h3>Narrower term(s)
        <xf:trigger
            appearance="minimal"
            class="btn-primary btn-xs pull-right">
            <xf:label><i class="glyphicon glyphicon-minus"/></xf:label>
            <xf:action
                ev:event="DOMActivate">
                <xf:delete
                    bind="narrowerterms"
                    at="index('repeatNT')"/>
            </xf:action>
        </xf:trigger>
        <xf:trigger
            appearance="minimal"
            class="btn-primary btn-xs pull-right">
            <xf:label><i
                    class="glyphicon glyphicon-plus"/></xf:label>
            <xf:action
                ev:event="DOMActivate">

                <xf:insert
                    bind="narrowerterms"
                   context="instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()"
                   position="after"
                    at="last()"
                    origin="instance('i_concept')/*[local-name() = 'xfinstance'][@type='template4NBT']/*[local-name() = 'narrower']"

                    if="exists(instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/*[local-name() = 'narrower'])"/>
                <xf:insert
                    context="instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()"
                    nodeset="instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/*[local-name() = 'broader']|instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/*[local-name() = 'prefLabel']"
                    position="after"
                    at="last()"

                    origin="instance('i_concept')/*[local-name() = 'xfinstance'][@type='template4NBT']/*[local-name() = 'narrower']"

                    if="count(instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/*[local-name() = 'narrower']) = 0"/>
                <xf:setvalue
                    ref="val[last()]"
                    value="count(/data/val)"/>
            </xf:action>
        </xf:trigger>
    </h3>
    <xf:group
        appearance="minimal">
          <xf:label>Sorting order in hierachical tree</xf:label>
    <xf:select1 id="collectionTypeInput" bind="i_concept_collection_type" appearance="full" incremental="true" >
                <xf:item>
                    <xf:label>Sort NT alphabetically</xf:label>
                    <xf:value>non-ordered</xf:value>
                 </xf:item>
                 <xf:item>
                    <xf:label>Sort NT as below</xf:label>
                    <xf:value>ordered</xf:value>
                 </xf:item>
            </xf:select1>
 </xf:group>
  <xf:group
        appearance="minimal">

        <xf:repeat
            id="repeatNT"
            bind="narrowerterms"
            appearance="compact"
            class="orderListRepeat">

            <xf:input id="ntInput" bind="conceptNo" size="100%" class="ntBt fullWidth"></xf:input>

            <xf:select1
                id="NTConcept"
                bind="conceptNo"
                incremental="true"
                size="100%"
                readonly="true"
                class="hidden"
                >
                <xf:label
                    id="labelPrefLabel"
                    class="hidden"

                    >PreferredLabel</xf:label>
                <xf:hint>Choose an already existing concept to be added as Narrower term</xf:hint>



                <xf:itemset
                    ref="instance('current_scheme_concepts')/*[local-name() = 'Concept']|instance('current_scheme_concepts')/*[local-name() = 'Collection']">

                    <!-- <xf:itemset nodeset="{$input}//skos:Concept">
                        -->

                    <xf:label
                        ref="./*[local-name() = 'prefLabel'][@*[local-name() = 'lang']='en']/text()"/>
                    <xf:value
                        ref="./@*[local-name() = 'about']"/>


                </xf:itemset>

            </xf:select1>

            <xf:input
                id="prefLabelNTInput"
                appearance="minimal"
                bind="prefLabelNT"
                size="60%"
                incremental="true">
                <xf:label
                    id="prefLabelsNT_label">Preferred Label</xf:label>
                <xf:hint>Enter a preferred label</xf:hint>

            </xf:input>
            <xf:input
                id="prefLabelLangNT"
                appearance="minimal"
                bind="prefLabelNTLang"
                incremental="true"
                size="3">
            <xf:label
                    id="langprefLabelsNT_label" class="contactsRepeatHeader">Lang.</xf:label>
                <xf:hint>Language</xf:hint>
            </xf:input>

          <!--
          <xf:output
                bind="conceptNo"
                class="text-right"
                incremental="true"
                size="100%">
                <xf:label
                    class="contactsRepeatHeader">Concept ID</xf:label>
            </xf:output>
        -->





        </xf:repeat>

     <xf:group id="moveNT" bind="delete-ordering-nt">

 <span>Move up or down selected Narrower Term
 <xf:trigger
 appearance="minimal"

 class="btn-primary btn-xs">
        <xf:label><i class="glyphicon glyphicon-arrow-up"/></xf:label>
        <xf:action ev:event="DOMActivate">
            <xf:setvalue ref="instance('i_concept')/*[local-name() = 'xfinstance'][@type='tempInstance4NT']/node()/tmp"
            value="index('repeatNT')"/>
            <xf:insert origin="instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/*[local-name() = 'narrower'][index('repeatNT')]"
                       nodeset="instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/*[local-name() = 'narrower']" at="index('repeatNT')-1" position="before"/>
           <xf:delete nodeset="instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/*[local-name() = 'narrower'][instance('i_concept')/*[local-name() = 'xfinstance'][@type='tempInstance4NT']/node()/tmp +1]"/>
        </xf:action>
    </xf:trigger>

 <xf:trigger  appearance="minimal" class="btn-primary btn-xs">
        <xf:label><i class="glyphicon glyphicon-arrow-down"/></xf:label>
        <xf:action ev:event="DOMActivate">
            <xf:setvalue ref="instance('i_concept')/*[local-name() = 'xfinstance'][@type='tempInstance4NT']/node()/tmp"
            value="index('repeatNT')"/>
            <xf:insert origin="instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/*[local-name() = 'narrower'][index('repeatNT')]"
                       nodeset="instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/*[local-name() = 'narrower']" at="index('repeatNT') +1" />

           <xf:delete nodeset="instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/*[local-name() = 'narrower'][instance('i_concept')/*[local-name() = 'xfinstance'][@type='tempInstance4NT']/node()/tmp +0]"/>
           <xf:setindex repeat="repeatNT" index="instance('i_concept')/*[local-name() = 'xfinstance'][@type='tempInstance4NT']/node()/tmp + 1"/>
        </xf:action>
    </xf:trigger>
</span>
</xf:group>


    </xf:group>






</div>


let $broaderTerms :=

<div
    class="admin-subpanel">
    <h3>Broader term(s)
    <!-- Addition and deletion of BT not activated in order not to intefer with addition / deletion of NT-->

   <xf:trigger appearance="minimal" class="btn-primary btn-xs pull-right">
  <xf:label><i
                    class="glyphicon glyphicon-minus"/></xf:label>
    <xf:action ev:event="DOMActivate">
        <xf:delete bind="broaderterms" at="index('repeatBT')"/>
     </xf:action>
</xf:trigger>

<xf:trigger appearance="minimal" class="btn-primary btn-xs pull-right" >
            <xf:label><i
                    class="glyphicon glyphicon-plus"/></xf:label>
            <xf:action ev:event="DOMActivate">
               <xf:insert bind="broaderterms"
               context="instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/*[local-name() = 'broader']"
               position="after"
               at="last()"
               origin="instance('i_concept')/*[local-name() = 'xfinstance'][@type='template4NBT']/*[local-name() = 'broader']"
              if="exists(instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/*[local-name() = 'broader'])"/>

               <xf:insert
               context="instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()"
               at="last()"
               nodeset="instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/*[local-name() = 'prefLabel']"
               position="after"
               origin="instance('i_concept')/*[local-name() = 'xfinstance'][@type='template4NBT']/*[local-name() = 'broader']"

               if="count(instance('i_concept')/*[local-name() = 'xfinstance'][@type='update']/node()/*[local-name() = 'broader']) = 0"/>

               <xf:setvalue ref="val[last()]" value="count(/data/val)" />
            </xf:action>
         </xf:trigger>


    </h3>

    <xf:group
        appearance="minimal">
        <xf:repeat
            id="repeatBT"
            bind="broaderterms"
            appearance="compact"
            class="orderListRepeat">

            <xf:input id="btInput" bind="conceptNo" size="100%" class="fullWidth"></xf:input>

            <xf:select1
                id="BTConcept"
                appearance="minimal"
                bind="conceptNo"
                incremental="true"
                class="hidden">
                <xf:label
                    id="region">PreferredLabel</xf:label>
                <xf:hint>Choose a concept to be added as Broader term</xf:hint>
                <xf:itemset
                    ref="instance('current_scheme_concepts')/*[local-name() = 'Concept']|instance('current_scheme_concepts')/*[local-name() = 'Collection']">
                    <xf:label
                        ref="./*[local-name() = 'prefLabel'][@*[local-name() = 'lang']='en']/text()"/>
                    <xf:value
                        ref="./@*[local-name() = 'about']"/>
                </xf:itemset>
            </xf:select1>

            <!--
            <xf:output
                bind="prefLabelEnBT"
                class="text-right">
                <xf:label
                    class="contactsRepeatHeader">prefLabel</xf:label>
            </xf:output>
            <xf:output
                bind="conceptNo"
                class="text-right"
                incremental="true">
                <xf:label
                    class="contactsRepeatHeader">sConcept ID</xf:label>
            </xf:output>
            -->

        </xf:repeat>


    </xf:group>


</div>

let $saveButton :=
                        <xf:trigger
                        id="saveUpdatesButton"
                        appearance="minimal"
                        class="btn btn-primary">
                            <xf:label>Save changes</xf:label>
                            <xf:action
                                ev:event="DOMActivate">
                                <xf:send
                                    submission="s_save_and_update"/>
                            </xf:action>
                    </xf:trigger>

let $triggerRevision :=
                        <xf:trigger
                        id="submitRevisionButton"
                        appearance="minimal"
                        class="btn btn-primary">
                            <xf:label>Submit revision</xf:label>
                            <xf:action
                                ev:event="DOMActivate">
                                <xf:send
                                    submission="s_submit_revision"/>

                            </xf:action>
                              <xf:action ev:event="DOMActivate">
                                <xf:load
                                    resource="/apc/concept/{$conceptId}"/>
                               </xf:action>
                    </xf:trigger>

let $revisionSuggestions :=
    if(not(exists($processConcept:requests//.[@object=$conceptId]))) then () else
    <div>
    <h3>Revision suggestions</h3>
    <table class="table table-striped">

             <tr>
                  <th>Request id</th>
                  <th>Suggested by</th>
                  <th>When</th>
                  <th>Description</th>
                  <th>Overview</th>

            </tr>


    {
  for $revision in $processConcept:requests//.[@object=$conceptId]


  order by $revision/@created

  return
  <tr>
  <td>{$revision/@xml:id/string()}</td>
        <td>{$revision/@creator/string()}</td>
        <td>{concat(substring(data($revision/@created), 1, 10), ' ', substring(data($revision/@created), 12, 5))}</td>
        <td>{$revision/description}</td>
        <td>
        <ul>
        {

        for $nodes at $pos in $revision/skos:Concept//.[position()>1]
          let $nodeName := node-name($nodes)

        return

                if(compare($nodes, $conceptNode//.[$pos+1]) = -1) then (
                    if (string($nodeName) eq "") then () else(
                <li>
                {$nodes}  [original: {$conceptNode//.[$pos+1]}] [{$nodeName} ({$nodes/@xml:lang/string()})]</li>
                )) else ()

           }
            </ul>
        </td>

      </tr>
  }
    </table>
 </div>

return
    (

    <div

        data-template="templates:surround"
        data-template-with="/templates/page.html"
        data-template-at="content">


        <!--

     <script src="http://thot.philo.ulg.ac.be/apps/thot-studio/resources/scripts/loadthesaurus.js" type="text/javascript"/>
    <script src="http://thot.philo.ulg.ac.be/apps/thot-studio/resources/scripts/thottree.js" type="text/javascript"/>   -->

        <script
            src="/resources/scripts/admin.js"
            type="text/javascript"/>

        <div
            class="container">

            <div
                class="container-fluid">
                {$model}
                <div class="col-xs-9 col-sm-9 col-md-9" id="xforms">
                    <div class="row">
                        <h2 class="noMarginTop">Editing Concept
                            <xf:output
                                id="input_concept_id"
                                bind="i_concept_id"
                                readonly="readonly">
                                <!--<xf:label>Thot-number</xf:label>-->
                            </xf:output>
                            <xf:select1
                                id="input_concept_status"
                                class="pull-right bottom-line"
                                bind="i_concept_status"
                                incremental="true">
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
                                    <xf:label>Thot Collaborators only</xf:label>
                                    <xf:value>private-thot</xf:value>
                                </xf:item>
                                <xf:item>
                                    <xf:label>Deleted</xf:label>
                                    <xf:value>deleted</xf:value>
                                </xf:item>
                            </xf:select1>
                        </h2>
                    </div>
                    <div
                        class="row">
                        {$prefLabels}
                        {$dcTitles}

                        {$broaderTerms}
                        {$narrowertTerms}
                        {$altLabels}
                        {$exactMatches}

                    </div>
                    <div
                        class="row">
                        <div
                            class="admin-subpanel">


                            <h3>Scope note</h3>


                            <xf:textarea
                                id="textarea_scopenote_input"
                                bind="i_concept_scopenote"

                                mediatype="text/html"></xf:textarea>



                            <xf:textarea
                                id="textarea_scopenoteNew_input"
                                bind="i_concept_new_scopenote"
                                appearance="full"
                                class="small-textarea"
                                mediatype="text/html">
                                <xf:label>There is currently no ScopeNote but you can add one below:</xf:label>
                                <hint>Enter a new scope note</hint>
                            </xf:textarea>

                        </div>
                        <div
                            class="col-md-6">

                        </div>
                    </div>
                    <div
                        class="row">

                        <br/>


                    </div>
                </div>

                <div
                    class="validation col-xs-3 col-sm-3 col-md-3">
                    <h2>Save</h2>
                    <xf:textarea
                        id="textarea_comment"
                        bind="i_concept_adminComment"
                        class="small-textarea">
                        <xf:label>Leave a comment about changes</xf:label>
                    </xf:textarea>


 {
 if(contains($schemeEditors, $currentUser) or $currentUser = 'admin' or $currentUser = 'vrazanajao') then
            ($saveButton)
            else($triggerRevision)}

                   <xf:trigger
                        id="cancelEdition"
                        appearance="minimal"
                        class="btn btn-warning">
                        <xf:label>Cancel</xf:label>
                        <xf:action ev:event="DOMActivate">
                            <xf:load
                                resource="/apc/concept/{$conceptId}"/>
                        </xf:action>
                    </xf:trigger>
                </div>


            </div>

        </div>
        <div class="row">
        {$revisionSuggestions}
        </div>
    </div>
)
