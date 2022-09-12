xquery version "3.1";

import module namespace config = "https://ausohnum.huma-num.fr/apps/eStudium/config" at "../config.xqm";

declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace dct = "http://purl.org/dc/terms/";
declare namespace ev = "http://www.w3.org/2001/xml-events";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace skosThesau = "https://ausohnum.huma-num.fr/skosThesau/";
declare namespace xf = "http://www.w3.org/2002/xforms";
declare namespace local = "local";
declare namespace functx = "http://www.functx.com";

declare option exist:serialize "method=xml media-type=text/html omit-xml-declaration=no indent=yes";

declare variable $thotVariables := doc("/db/apps/thot/data/thot-config.xml");

declare function functx:escape-for-regex
($arg as xs:string?) as xs:string {
    
    replace($arg,
    '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))', '\\$1')
};

declare function functx:substring-after-last
($arg as xs:string?,
$delim as xs:string) as xs:string {
    
    replace($arg, concat('^.*', functx:escape-for-regex($delim)), '')
};


declare variable $appVariables := doc($config:data-root || '/app-general-parameters.xml');


let $now := fn:current-dateTime()
let $currentUser := data(sm:id()//sm:username)
let $userPrimaryGroup := sm:get-user-primary-group($currentUser)
let $people := collection($config:data-collection || "/accounts")//account

let $baseUri := $appVariables//uriBase/text()
let $idPrefix := $appVariables//idPrefix[@type = 'concept']/text()

let $data-collection := collection($config:data-collection || '/concepts')

let $idList := for $id in $data-collection//.[contains(./@xml:id, $idPrefix)]
return
    <item>
        {substring-after($id/@xml:id, $idPrefix)}
    </item>

let $last-id := fn:max($idList)
(: let $increment-id := fn:sum($last-id, '1'):)
let $newId := $idPrefix || fn:sum(($last-id, 1))



let $model := <div
    id="xform_model"
>
    <xf:model
        id="m_scheme"
    
    >
        <xf:instance
            xmlns=""
            id="i_scheme">
            
            
            <skosThesau:xfinstances
                xmlns:thot="http://thot.philo.ulg.ac.be/">
                <skosThesau:xfinstance
                    type="scheme">
                    <skos:ConceptScheme
                        rdf:about="{$baseUri}/apc/thesaurus/">
                        <dc:title
                            type="full"/>
                        <dc:title
                            type="short"/>
                        <dc:publisher>Project Patrimonium</dc:publisher>
                        <dc:creator
                            ref=""
                            role="editor"/>
                        <dct:created>{$now}</dct:created>
                        <skos:hasTopConcept
                            rdf:resource="{$baseUri}/apc/concept/"/>
                        <skosThesau:admin
                            status="draft"/>
                        <skosThesau:adminComment
                            group="apc"
                            ref="https://ausohnum.huma-num.fr/apps/eStudium/apc/thesaurus/"
                            type="scheme-creation"
                            user="{$currentUser}"
                            xml:lang="en"/>
                    </skos:ConceptScheme>
                
                </skosThesau:xfinstance>
                <skosThesau:xfinstance
                    type="templates">
                    <dc:creator
                        role="contributor"/>
                </skosThesau:xfinstance>
                <skosThesau:xfinstance
                    type="conceptCreation">
                    <skos:Concept
                        xml:id="{$newId}"
                        rdf:about="{$baseUri}/apc/concept/{$newId}">
                        <skos:prefLabel
                            xml:lang="en"/>
                        <skos:prefLabel
                            xml:lang="de"/>
                        <skos:prefLabel
                            xml:lang="fr"/>
                        <skos:inScheme
                            rdf:resource="{$baseUri}/apc/thesaurus/"/>
                        <skosThesau:admin
                            status="private"/>
                        <skosThesau:adminComment/>
                        <dct:created>{$now}</dct:created>
                        <dct:modified>{$now}</dct:modified>
                    </skos:Concept>
                </skosThesau:xfinstance>
                <skosThesau:xfinstance
                    xmlns=""
                    type="contributorList">
                    {
                        
                        for $person in $people
                            order by $person/lastname ascending
                        return
                            <people
                                ref="{$person/@xml:id}"
                                type="{$person/role}">
                                {concat($person/firstname, ' ', $person/lastname)}
                            </people>
                    }
                </skosThesau:xfinstance>
                <skosThesau:xfinstance
                    type="selectedvalue">
                    <people>
                        <repeatIndex/>
                        <username></username></people>
                
                </skosThesau:xfinstance>
            </skosThesau:xfinstances>
        
        </xf:instance>
        
        <xf:bind
            id="dcTitleFull"
            ref="instance('i_scheme')/node()[@type='scheme']/node()/*[local-name() = 'title'][@type='full']"
            required="true()"/>
        <xf:bind
            id="dcTitleShort"
            ref="instance('i_scheme')/node()[@type='scheme']/node()/*[local-name() = 'title'][@type='short']"
            required="true()"
            type="ID"
        />
        
        <xf:bind
            id="TTIDsingle"
            ref="instance('i_scheme')/node()[@type='scheme']/node()/*[local-name() = 'hasTopConcept']/@*[local-name() = 'resource']"
        
        />
        
        <xf:bind
            id="dcCreator"
            ref="instance('i_scheme')/node()[@type='scheme']/node()/*[local-name() = 'creator']">
            <xf:bind
                id="dcCreatorName"
                ref="."/>
            <xf:bind
                id="dcCreatorRef"
                ref="./@ref"/>
            <xf:bind
                id="dcCreatorRole"
                ref="./@role"/>
        </xf:bind>
        
        <xf:bind
            id="dcPublisher"
            ref="instance('i_scheme')/node()[@type='scheme']/node()/*[local-name() = 'publisher']"/>
        <xf:bind
            id="schemeNote"
            ref="instance('i_scheme')/node()[@type='scheme']/node()/*[local-name() = 'note']"/>
        
        
        
        
        <xf:bind
            id="adminComment"
            ref="instance('i_scheme')/node()[@type='scheme']/node()/*[local-name() = 'adminComment']/node()"/>
        <xf:bind
            id="status"
            ref="instance('i_scheme')/node()[@type='scheme']/node()/*[local-name() = 'admin']/@status"/>
        
        <xf:bind
            id="conceptPrefLabels"
            ref="instance('i_scheme')/node()[@type='conceptCreation']/node()/*[local-name() = 'prefLabel']"
        >
            <xf:bind
                id="prefLabelAlpha"
                ref="."
                required="substring-after(instance('i_scheme')/node()[@type='scheme']/node()/*[local-name() = 'hasTopConcept']/@*[local-name() = 'resource'], '/concept/') = ''
                   and ./@*[local-name() = 'lang'] = 'en'"/>
            <xf:bind
                id="langPrefLabelAlpha"
                ref="./@*[local-name() = 'lang']"/>
        </xf:bind>
        
        
        
        
        <xf:submission
            id="s_save"
            method="post"
            resource="/modules/skosThesau/scheme-create.xql"
        />
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
    
    </xf:model>
</div>
return
    <div
        data-template="templates:surround"
        data-template-with="./templates/page.html"
        data-template-at="content">
        <script
            src="/resources/scripts/skosThesau.js"
            type="text/javascript"/>
        
        {$model}
        <div
            class="container">
            <div
                class="row">
                <div
                    class="container-fluid">
                    
                    <h1>New scheme</h1>
                    
                    
                    
                    <div
                        class="col-xs-9 col-sm-9 col-md-9">
                        
                        <xf:select1
                            id="input_scheme_status"
                            class="bottom-line"
                            bind="status"
                            incremental="true">
                            <xf:label
                                class="pastilleLabelBlue pastilleSquare">Scheme status</xf:label>
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
                        <div
                            class="admin-subpanel">
                            <div
                                class="form-group">
                                <h3>Titles</h3>
                                <xf:input
                                    id="dcTitleInputFull"
                                    appearance="minimal"
                                    bind="dcTitleFull"
                                    incremental="true"
                                    class="form-control"
                                    size="100%">
                                    <xf:label
                                        id="dctitle_label">Full title</xf:label>
                                    <xf:hint>Title for this thesaurus</xf:hint>
                                </xf:input>
                                
                                <xf:input
                                    id="dcTitleInputShort"
                                    appearance="minimal"
                                    bind="dcTitleShort"
                                    incremental="true"
                                    class="form-control"
                                    size="40">
                                    <xf:label
                                        id="dctitle_label">Short title</xf:label>
                                    <xf:hint>Short title for this thesaurus, to be used in URI</xf:hint>
                                    
                                    <xf:alert>Space and special characters not permitted</xf:alert>
                                </xf:input>
                            
                            
                            </div>
                        </div>
                        <div
                            class="admin-subpanel">
                            <div
                                class="form-group">
                                
                                <h3>Top Concept</h3>
                                
                                <xf:switch>
                                    <xf:case
                                        id="newConcept"
                                        selected="true()">
                                        <p>Create a new concept with the following values</p>
                                        <xf:repeat
                                            id="conceptPrefLabelsRepeat"
                                            bind="conceptPrefLabels"
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
                                                <xf:hint>Enter a language</xf:hint>
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
                                        <!--
 <xf:trigger appearance="minimal"  class="btn-primary btn-xs">
            <xf:label>OR Link to an existing Concept</xf:label>
            <xf:toggle case="existingConcept"></xf:toggle>
        </xf:trigger>      
     -->
                                    </xf:case>
                                    <xf:case
                                        id="existingConcept">
                                        <xf:input
                                            bind="TTIDsingle"
                                            size="50">
                                            <xf:label>Link to an existing Concept by entering its URL</xf:label></xf:input>
                                        <xf:trigger
                                            appearance="minimal"
                                            class="btn-primary btn-xs">
                                            <xf:label>OR create a new Concept</xf:label>
                                            <xf:toggle
                                                case="newConcept"></xf:toggle>
                                        </xf:trigger>
                                    
                                    </xf:case>
                                
                                </xf:switch>
                            
                            </div>
                        </div>
                        
                        <div
                            class="admin-subpanel">
                            <div
                                class="form-group">
                                <xf:input
                                    id="inputPublsher"
                                    appearance="minimal"
                                    bind="dcPublisher"
                                    incremental="true"
                                    class="form-control"
                                    size="100%">
                                    <xf:label
                                        id="publisher_label">Publisher</xf:label>
                                    <xf:hint>Enter a publisher</xf:hint>
                                </xf:input>
                                
                                <xf:trigger
                                    appearance="minimal"
                                    class="btn-primary btn-xs pull-right">
                                    <xf:label><i
                                            class="glyphicon glyphicon-minus"/></xf:label>
                                    <xf:action
                                        ev:event="DOMActivate">
                                        <xf:delete
                                            bind="dcCreator"
                                            at="index('repeatCreators')"/>
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
                                            bind="dcCreator"
                                            position="after"
                                            at="last()"
                                            origin="instance('i_scheme')/node()[@type='templates']/*[local-name() = 'creator']"
                                        />
                                        
                                        <xf:insert
                                            context="instance('i_scheme')/node()[@type='scheme']/*[local-name() = 'ConceptScheme']"
                                            at="last()"
                                            position="after"
                                            origin="instance('i_scheme')/node()[@type='templates']/*[local-name() = 'creator']"
                                            
                                            if="count(instance('i_scheme')/node()[@type='scheme']/node()/*[local-name() = 'creator']) = 0"/>
                                        
                                        
                                        
                                        
                                        <xf:setvalue
                                            ref="val[last()]"
                                            value="count(/data/val)"/>
                                    </xf:action>
                                </xf:trigger>
                                
                                
                                <xf:group
                                    class="form-control">
                                    <xf:label>Creator(s)</xf:label>
                                    <xf:repeat
                                        id="repeatCreators"
                                        bind="dcCreator"
                                        appearance="compact"
                                        class="orderListRepeat">
                                        
                                        
                                        <xf:select1
                                            id="creatorDropDown"
                                            appearance="minimal"
                                            bind="dcCreatorRef"
                                            incremental="true">
                                            <xf:label
                                                id="dcCNLabel">Name</xf:label>
                                            <xf:hint>Select someone</xf:hint>
                                            <xf:itemset
                                                ref="instance('i_scheme')/node()[@type='contributorList']/*[local-name() = 'people']">
                                                <xf:label
                                                    ref="."/>
                                                <xf:value
                                                    ref="./@ref"/>
                                            </xf:itemset>
                                            
                                            <xf:action
                                                ev:event="xforms-value-changed">
                                                
                                                <xf:setvalue
                                                    ref="instance('i_scheme')/node()[@type='selectedvalue']/people/repeatIndex"
                                                    value="index('repeatCreators')"/>
                                                <xf:setvalue
                                                    ref="instance('i_scheme')/node()[@type='selectedvalue']/people/username"
                                                    value="string(instance('i_scheme')/node()[@type='scheme']/node()/*[local-name() = 'creator'][xs:integer(instance('i_scheme')/node()[@type='selectedvalue']/people/repeatIndex/text())]/@ref)"/>
                                                
                                                <xf:setvalue
                                                    ref="instance('i_scheme')/node()[@type='selectedvalue']/people/username"
                                                    value="instance('i_scheme')/node()[@type='scheme']/node()/*[local-name() = 'creator'][xs:integer(instance('i_scheme')/node()[@type='selectedvalue']/people/repeatIndex/text())]"/>
                                                
                                                
                                                <xf:setvalue
                                                    ref="instance('i_scheme')/node()[@type='scheme']/node()/*[local-name() = 'creator'][xs:integer(instance('i_scheme')/node()[@type='selectedvalue']/people/repeatIndex/text())]"
                                                    value="string(instance('i_scheme')/node()[@type='contributorList']/*[local-name() = 'people'][@ref=string(instance('i_scheme')/node()[@type='scheme']/node()/*[local-name() = 'creator'][xs:integer(instance('i_scheme')/node()[@type='selectedvalue']/people/repeatIndex/text())]/@ref)])"/>
                                                <xf:message
                                                    level="ephemeral">Data changed</xf:message>
                                            
                                            </xf:action>
                                        
                                        
                                        </xf:select1>
                                        
                                        
                                        
                                        <xf:select1
                                            id="creatorRoleInput"
                                            appearance="minimal"
                                            bind="dcCreatorRole"
                                            incremental="true">
                                            <xf:label
                                                id="dcCNLabel">Role</xf:label>
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
                        </div>
                        <div
                            class="form-group">
                            <xf:textarea
                                id="SchemeNoteInput"
                                appearance="minimal"
                                class="form-control"
                                bind="schemeNote"
                                incremental="true">
                                <xf:label>Scheme Note</xf:label>
                                <xf:hint>Scheme Note</xf:hint>
                            </xf:textarea>
                        </div>
                    
                    
                    
                    
                    </div>
                    
                    
                    <div
                        class="col-xs-3 col-sm-3 col-md-3">
                        <div
                            class="admin-subpanel">
                            <xf:textarea
                                id="adminCommentInput"
                                rows="2"
                                bind="adminComment"
                                class=""
                            >
                                <xf:label
                                    for='adminCommentInput'>Leave a comment about this creation</xf:label>
                            </xf:textarea>
                            
                            <xf:trigger
                                id="saveUpadtesButton"
                                appearance="minimal"
                                class="btn btn-primary">
                                <xf:label>Create Scheme</xf:label>
                                <xf:action
                                    ev:event="DOMActivate">
                                    <xf:send
                                        submission="s_save"/>
                                    <xf:load
                                        resource="javascript:loadDashboard()"/>
                                </xf:action>
                            
                            
                            </xf:trigger>
                            <xf:trigger
                                id="cancelEdition"
                                appearance="minimal"
                                class="btn btn-warning">
                                <xf:label>Cancel</xf:label>
                                <xf:action>
                                    <xf:load
                                        resource="javascript:loadDashboard()"/>
                                </xf:action>
                            </xf:trigger>
                        </div>
                    
                    </div>
                </div>
            </div>
        </div>
    
    </div>