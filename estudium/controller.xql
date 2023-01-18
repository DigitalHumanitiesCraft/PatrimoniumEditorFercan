xquery version "3.1";

import module namespace login = "http://exist-db.org/xquery/login" at "resource:org/exist/xquery/modules/persistentlogin/login.xql";
import module namespace config = "https://ausohnum.huma-num.fr/apps/eStudium/config" at "modules/config.xqm";
(:import module namespace console = "http://exist-db.org/xquery/console";:)
import module namespace functx="http://www.functx.com";
import module namespace response="http://exist-db.org/xquery/response";
(:import module namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/" at "xmldb:exist:///db/apps/ausohnum-library/modules/skosThesau/skosThesauApp.xql";:)

declare namespace apc="https://ausohnum.huma-num.fr/apps/eStudium/onto#";

declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;
declare variable $general-parameters := doc("/db/apps/" || $config:project || "/data/app-general-parameters.xml");
declare variable $thesBaseUri := $general-parameters//uriBase[@type='thesaurus']/text() ||'/thesaurus';
declare variable $dbprefix := $general-parameters//idPrefix[@type='db']/text() ;

declare variable $logout := request:get-parameter("logout", ());
declare variable $login := request:get-parameter("user", ());

declare variable $ausohnum-lib-path := "/ausohnum-library/";
declare variable $dataCollection-path := "/" || $config:project || "Data/";
declare variable $userClientLang := if(request:get-parameter("selectedLang", ()) != "") then request:get-parameter("selectedLang", ())
                                                         else if(
                                                                         (substring-before(request:get-header("Accept-Language"), ",") = "") 
                                                                         or not(
                                                                                 (substring-before(request:get-header("Accept-Language"), ",") = "en")
                                                                                 or (substring-before(request:get-header("Accept-Language"), ",") = "fr")
                                                                                 )
                                                                 )
                                                                 then ("en")
                                                                 else (substring-before(request:get-header("Accept-Language"), ","));


if ($exist:path eq '') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{request:get-uri()}/"/>
       <add-parameter name='lang' value='{ $userClientLang }'/>
     </dispatch>

    (: Resource paths starting with $nav-base are resolved relative to app :)
      else
         if (contains($exist:path, "/$nav-base/")) then
            <dispatch
               xmlns="http://exist.sourceforge.net/NS/exist">
               <forward
                  url="{concat($exist:controller, '/', substring-after($exist:path, '/$nav-base/'))}">
                  <set-header
                     name="Cache-Control"
                     value="max-age=3600, must-revalidate"/>
               </forward>
            </dispatch>
     
(: Resource paths starting with $shared are loaded from the shared-resources app :)
else if (contains($exist:path, "/$shared/")) then
    <dispatch
        xmlns="http://exist.sourceforge.net/NS/exist">
        <forward
            url="/shared-resources/{substring-after($exist:path, '/$shared/')}">
            <set-header
                name="Cache-Control"
                value="max-age=3600, must-revalidate"/>
            <add-parameter
                name='lang'
                value='en'/>

        </forward>
    </dispatch>


(: Resource paths starting with $ausohnum-lib are loaded from the ausohnum-library app :)
(:Need to be placed before rule on "/" otherwise js are processed by view.xql:)
else if (contains($exist:path, "/$ausohnum-lib/")) then
    (login:set-user($config:login-domain, (), false()),
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="/ausohnum-library/{substring-after($exist:path, '/$ausohnum-lib/')}">
            <set-header
                name="Cache-Control"
                value="max-age=3600, must-revalidate"/>

                <add-parameter name='docid' value='{$exist:resource}'/>
                <add-parameter name='project' value='{$config:project}'/>
            </forward>
    </dispatch>)
(: Resource paths starting with $ausohnum-lib are loaded from the ausohnum-library app :)
(:Need to be placed before rule on "/" otherwise js are processed by view.xql:)
else if (contains($exist:path, "/$ausohnum-lib-dev/")) then
    (login:set-user($config:login-domain, (), false()),
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="/ausohnum-library/{substring-after($exist:path, '/$ausohnum-lib-dev/')}">
            <set-header
                name="Cache-Control"
                value="max-age=3600, must-revalidate"/>

                <add-parameter name='docid' value='{$exist:resource}'/>
                <add-parameter name='project' value='{$config:project}'/>
            </forward>
    </dispatch>)
else if (contains($exist:path, "/$epidocLib/")) then
    (login:set-user($config:login-domain, (), false()),
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="/epidocLib/{substring-after($exist:path, '/$epidocLib/')}">
            <set-header
                name="Cache-Control"
                value="max-age=3600, must-revalidate"/>

                <add-parameter name='docid' value='{$exist:resource}'/>
                <add-parameter name='project' value='{$config:project}'/>
            </forward>
    </dispatch>)

else if (starts-with($exist:path, "/project/")) then
        (
        login:set-user($config:login-domain, (), false()),
        let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
       let $groups := string-join(sm:get-user-groups($user), ' ')
       let $lang := if(($exist:resource ="") or ($exist:resource !="en|fr")) then "fr"
                            else $exist:resource
                            
     return
            <dispatch
                xmlns="http://exist.sourceforge.net/NS/exist">
                <forward
                    url="{concat($exist:controller, '/project.html')}">
                    <add-parameter name='lang' value='{$lang}'/>
                     
                    <add-parameter name='project' value='{$config:project}'/>
                    <add-parameter name="path" value="{$exist:path}"/>
                            
               </forward>
                <view>
                        <forward url="{$exist:controller}/modules/view.xql">
                            <add-parameter name='lang' value='{ $lang }'/>
                            <add-parameter name="resourceType" value="landingpage"/>
                        </forward>
                    </view>
            </dispatch>
            )
 
else if (starts-with($exist:path, "/executeftSearch/")) then
        (
        login:set-user($config:login-domain, (), false()),
        let $user := if(request:get-attribute($config:login-domain||".user")) then request:get-attribute($config:login-domain||".user")
                    else "guest"
        let $groups := string-join(sm:get-user-groups($user), ' ')
        return
            (
            <dispatch
                xmlns="http://exist.sourceforge.net/NS/exist">
                <forward
                    url="{concat($exist:controller, '/modules/requestsHandler.xql')}">
                        <add-parameter name='type' value='executeftSearch'/>
                        <add-parameter name='lang' value='en'/>

                        <add-parameter name='selectedLang' value='en'/>
                        <add-parameter name='project' value='{$config:project}'/>
                        <add-parameter name='user' value='{ $user }'/>
                        <add-parameter name="path" value="{$exist:path}"/>
                        <set-attribute name="ausohnumSearch:results" value="{session:get-attribute('ausohnumSearch:results')}"/>
                </forward>
        </dispatch>)
        )


else if (starts-with($exist:path, "/search-results/")) then
        (
        login:set-user($config:login-domain, (), false()),
        let $user := if(request:get-attribute($config:login-domain||".user")) then request:get-attribute($config:login-domain||".user")
                    else "guest"
        let $groups := string-join(sm:get-user-groups($user), ' ')
        return
            (
            <dispatch
                xmlns="http://exist.sourceforge.net/NS/exist">
                <forward
                    url="{concat($exist:controller, '/modules/requestsHandler.xql')}">
                        <add-parameter name='type' value='searchDisplayResults'/>
                        <add-parameter name='lang' value='en'/>

                        <add-parameter name='selectedLang' value='en'/>
                        <add-parameter name='project' value='{$config:project}'/>
                        <add-parameter name='user' value='{ $user }'/>
                        <add-parameter name="path" value="{$exist:path}"/>
                        <set-attribute name="ausohnumSearch:results" value="{session:get-attribute('ausohnumSearch:results')}"/>
                </forward>
                <view>
                        <forward url="{$exist:controller}/modules/view.xql">
                            <set-header name="Cache-Control" value="no-cache"/>
                            <add-parameter name='project' value='{$config:project}'/>
                            <add-parameter name='lang' value='en'/>
                            <add-parameter name='selectedLang' value='en'/>
                            <add-parameter name='user' value='{ $user }'/>
                            <add-parameter name="userGroups" value="{ $groups }"/>
                            <set-attribute name="ausohnumSearch:results" value="{session:get-attribute('ausohnumSearch:results')}"/>
                        </forward>
                    </view>
                <error-handler>
                    <forward url="{$exist:controller}/error-page.html" method="get"/>
                    <forward url="{$exist:controller}/modules/view.xql"/>
                </error-handler>
            </dispatch>
            )
        
        )  


else if (equals($exist:path, "/search/")) then
        (
        login:set-user($config:login-domain, (), false()),
        let $user := if(request:get-attribute($config:login-domain||".user")) then request:get-attribute($config:login-domain||".user")
                    else "guest"
        let $groups := string-join(sm:get-user-groups($user), ' ')
        return
            (
            <dispatch
                xmlns="http://exist.sourceforge.net/NS/exist">
                <forward
                    url="{concat($exist:controller, '/modules/searchBuilder/search-form.xql')}">
                    <add-parameter name='lang' value='en'/>
                        <add-parameter name='selectedLang' value='en'/>
                        <add-parameter name='project' value='{$config:project}'/>
                        <add-parameter name='user' value='{ $user }'/>
                        <add-parameter name="path" value="{$exist:path}"/>
                        
                </forward>
                <view>
                        <forward url="{$exist:controller}/modules/view.xql">
                            <set-header name="Cache-Control" value="no-cache"/>
                            <add-parameter name='project' value='{$config:project}'/>
                            <add-parameter name='lang' value='en'/>
                            <add-parameter name='selectedLang' value='en'/>
                            <add-parameter name='user' value='{ $user }'/>
                            <add-parameter name="userGroups" value="{ $groups }"/>
                        </forward>
                    </view>
                <error-handler>
                    <forward url="{$exist:controller}/error-page.html" method="get"/>
                    <forward url="{$exist:controller}/modules/view.xql"/>
                </error-handler>
            </dispatch>
            )
        
        )  
else if (starts-with($exist:path, "/search/getTextPreview/")) then
        (
        login:set-user($config:login-domain, (), false()),
        let $user := if(request:get-attribute($config:login-domain||".user")) then request:get-attribute($config:login-domain||".user")
                    else "guest"
        let $groups := string-join(sm:get-user-groups($user), ' ')
        return
            (
            <dispatch
                xmlns="http://exist.sourceforge.net/NS/exist">
                <forward
                    url="{concat($exist:controller, '/modules/requestsHandler.xql')}">
                    <add-parameter name='lang' value='en'/>
                        <add-parameter name='selectedLang' value='en'/>
                        <add-parameter name='project' value='{$config:project}'/>
                        <add-parameter name='type' value='getTextPreview'/>
                        <add-parameter name='resource' value='{ $exist:resource }'/>
                 </forward>
                
                
            </dispatch>
            )
        
        )  


else if (ends-with($exist:path, "/admin/")) then
    (
    login:set-user($config:login-domain, (), false()),
    let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
       
        let $groups := string-join(sm:get-user-groups($user), ' ')
                    return
                            if(contains($groups, ($config:authorized-groups)))

    then
        (
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <forward
                url="{concat($ausohnum-lib-path, '/modules/teiEditor/getFunctions.xql')}">
               <add-parameter name='lang' value='{ $userClientLang }'/>
                    <add-parameter name="type" value="dashboard"/>
                      
                        <add-parameter name='project' value='{$config:project}'/>

            </forward>
            <view>
                <forward url="{$exist:controller}/modules/view.xql">
                   <add-parameter name='lang' value='{ $userClientLang }'/>
                    
                    <add-parameter name='project' value='{$config:project}'/>
                </forward>
            </view>
        </dispatch>
        )
    else
        (
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{concat($ausohnum-lib-path, '/modules/teiEditor/getFunctions.xql')}">
                <add-parameter name="type" value="loginForm"/>
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value="{$config:project}"/>
            </forward>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                       <add-parameter name='lang' value='{ $userClientLang }'/>
                        
                    </forward>
                </view>
            </dispatch>
        )
    )

else if (starts-with($exist:path, "/admin/corpus/")) then
        (
        login:set-user($config:login-domain, (), false()),
(:        if (sm:has-access(xs:anyURI('/db/apps/' || $config:project || '/modules/4access.xql'), 'r-x')) :)
        (:if(
        functx:contains-any-of(string-join(sm:get-user-groups(request:get-attribute($config:login-domain || ".user"))),
        ('dba', 'tester'))
        ):)
    let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
           let $groups := string-join(sm:get-user-groups($user), ' ')
        
                    return
                            if(functx:contains-any-of($groups, ($config:authorized-groups)))
        then
            (
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{concat($ausohnum-lib-path, '/modules/teiEditor/getFunctions.xql')}">
                <add-parameter name="type" value="dashboard4corpus"/>
                                       <add-parameter name='lang' value='{ $userClientLang }'/>
                                        
                                        <add-parameter name='project' value="{$config:project}"/>
                                        <add-parameter name='corpus' value='{$exist:resource}'/>

                </forward>
                <cache-control
                cache="no"/>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                       <add-parameter name='lang' value='{ $userClientLang }'/>
                        
                    </forward>
                </view>
            </dispatch>
            )
        else
            (
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{concat($ausohnum-lib-path, '/modules/teiEditor/getFunctions.xql')}">
                <add-parameter name="type" value="loginForm"/>
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value="{$config:project}"/>
                <add-parameter name='usergroups' value="{$groups}"/>
            </forward>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                       <add-parameter name='lang' value='{ $userClientLang }'/>
                        
                    </forward>
                </view>
            </dispatch>
            )
        )


(:Used by teiEditor to load all texts related to one document:)
else if (starts-with($exist:path, "/getdoctext/")) then
        (
        login:set-user($config:login-domain, (), false()),
    let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
           let $groups := string-join(sm:get-user-groups($user), ' ')
                    return
                            if(contains($groups, ($config:authorized-groups)))
                            then
            (
            <dispatch
                xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{concat($ausohnum-lib-path, '/modules/teiEditor/get-texts-from-document.xql')}">
                    <add-parameter
                        name='lang'
                        value='en'/>
                        <add-parameter
                        name='project'
                        value='{$config:project}'/>
                    <add-parameter
                        name='docid'
                        value='{$exist:resource}'/>
                </forward>
                <view>
                    <forward
            url="{$exist:controller}/modules/view.xql">
                  <add-parameter
                            name='lang'
                            value='en'/>
                        <add-parameter
                            name='selectedLang'
                            value='en'/>
        </forward>
                </view>
            </dispatch>
            )
        else
            (
           <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{concat($ausohnum-lib-path, '/modules/teiEditor/getFunctions.xql')}">
                <add-parameter name="type" value="loginForm"/>
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value="{$config:project}"/>
            </forward>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                       <add-parameter name='lang' value='{ $userClientLang }'/>
                        
                    </forward>
                </view>
            </dispatch>
            )
        )


else if (starts-with($exist:path, "/edit-documents/")) then
        (
        login:set-user($config:login-domain, (), false()),
        
(:        if (sm:has-access(xs:anyURI('/db/apps/' || $config:project || '/modules/4access.xql'), 'r-x')) :)
        let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
       
       
       let $groups := string-join(sm:get-user-groups($user), ' ')
       
       return
            if(contains($groups, ($config:authorized-groups)))
                then
                        (    if ($exist:resource eq '') then
                                (
                                <dispatch
                                    xmlns="http://exist.sourceforge.net/NS/exist">
                                    <forward
                                        url="{concat($ausohnum-lib-path, '/modules/teiEditor/getFunctions.xql')}">
                                       <add-parameter name='lang' value='{ $userClientLang }'/>
                                            <add-parameter name="type" value="dashboard"/>
                                              
                                              <add-parameter name='project' value='{$config:project}'/>
                                              
                        
                                    </forward>
                                    <view>
                                        <forward url="{$exist:controller}/modules/view.xql">
                                            <!--<set-header name="Last-Modified" value="{current-dateTime()}"/>-->
                                           <add-parameter name='lang' value='{ $userClientLang }'/>
                                            
                                            <add-parameter name='project' value='{$config:project}'/>
                                        </forward>
                                    </view>
                                </dispatch>
                                )
                        else 
                        (
                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                            <forward url="{concat($exist:controller, '/modules/teiEditor/document-editor.xql')}">
                            <!--<forward url="{concat('/ausohnum-library/', '/modules/teiEditor/document-editor.xql')}">-->
                               <add-parameter name='lang' value='{ $userClientLang }'/>
                                <add-parameter name='docid' value='{$exist:resource}'/>
                                <add-parameter name='project' value='{$config:project}'/>
                                <add-parameter name='mode' value='edition'/>
                            </forward>
                            <view>
                                <forward url="{$exist:controller}/modules/view.xql">
                                <set-header name="Last-Modified" value="{current-dateTime()}"/>
                                   <add-parameter name='lang' value='{ $userClientLang }'/>
                                    
                                    <add-parameter name='project' value='{$config:project}'/>
                                </forward>
                            </view>
                        </dispatch>
                        )
                        )
        else
            (
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{concat($ausohnum-lib-path, '/modules/teiEditor/getFunctions.xql')}">
                <add-parameter name="type" value="loginForm"/>
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value="{$groups}"/>
                
            </forward>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                       <add-parameter name='lang' value='{ $userClientLang }'/>
                        
                        <add-parameter name='project' value='{$config:project}'/>
                    </forward>
                </view>
            </dispatch>
    )   )
        
        
else if (starts-with($exist:path, "/egypt-documents/")) then
        (
        login:set-user($config:login-domain, (), false()),
        
(:        if (sm:has-access(xs:anyURI('/db/apps/' || $config:project || '/modules/4access.xql'), 'r-x')) :)
        let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
       
       
       let $groups := string-join(sm:get-user-groups($user), ' ')
       
       return
            if(contains($groups, ($config:authorized-groups)))
                then
                        (    if ($exist:resource eq '') then
                                (
                                <dispatch
                                    xmlns="http://exist.sourceforge.net/NS/exist">
                                    <forward
                                        url="{concat($ausohnum-lib-path, '/modules/teiEditor/getFunctions.xql')}">
                                       <add-parameter name='lang' value='{ $userClientLang }'/>
                                            <add-parameter name="type" value="dashboard"/>
                                              
                                                <add-parameter name='project' value='{$config:project}'/>
                        
                                    </forward>
                                    <view>
                                        <forward url="{$exist:controller}/modules/view.xql">
                                            <!--<set-header name="Last-Modified" value="{current-dateTime()}"/>-->
                                           <add-parameter name='lang' value='{ $userClientLang }'/>
                                            
                                            <add-parameter name='project' value='{$config:project}'/>
                                        </forward>
                                    </view>
                                </dispatch>
                                )
                        else 
                        (
                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                            <forward url="{concat($exist:controller, '/modules/teiEditor/egyptianMaterial-editor.xql')}">
                            <!--<forward url="{concat('/ausohnum-library/', '/modules/teiEditor/document-editor.xql')}">-->
                                <set-header name="Cache-Control" value="no-cache"/>
                               <add-parameter name='lang' value='{ $userClientLang }'/>
                                <add-parameter name='docid' value='{$exist:resource}'/>
                                <add-parameter name='project' value='{$config:project}'/>
                            </forward>
                            <view>
                                <forward url="{$exist:controller}/modules/view.xql">
                                   <add-parameter name='lang' value='{ $userClientLang }'/>
                                    
                                    <add-parameter name='project' value='{$config:project}'/>
                                </forward>
                            </view>
                        </dispatch>
                        )
                        )
        else
            (
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{concat($ausohnum-lib-path, '/modules/teiEditor/getFunctions.xql')}">
                <add-parameter name="type" value="loginForm"/>
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value="{$groups}"/>
                
            </forward>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                       <add-parameter name='lang' value='{ $userClientLang }'/>
                        
                    </forward>
                </view>
            </dispatch>
    )   )
else if (equals($exist:path, "/documents/update-list/")) then
    (
    login:set-user($config:login-domain, (), false()),
        let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
        let $groups := string-join(sm:get-user-groups($user), ' ')
    return
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <!--
            <forward url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/getFunctions.xql')}">    
            -->
            
            <!-- <forward
                url="{concat($exist:controller, '/modules/teiEditor/getDocumentsList.xql')}">-->
                <forward
                url="{concat($exist:controller, '/modules/teiEditor/buildDocumentsList.xql')}">
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value='{$config:project}'/>
                <add-parameter name="format" value="json"/>
                
            </forward>

        </dispatch>
    )        
else if (equals($exist:path, "/documents/list/json")) then
    (
    login:set-user($config:login-domain, (), false()),
        let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
        let $groups := string-join(sm:get-user-groups($user), ' ')
        let $response:= response:set-header("Content-Type", "text/javascript; charset=UTF-8")
    return
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <!--
            <forward url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/getFunctions.xql')}">    
            -->
            <forward
                url="{concat($ausohnum-lib-path, '/modules/teiEditor/getDocumentsList.xql')}">
                
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value='{$config:project}'/>
                <add-parameter name="format" value="json"/>
                
            </forward>

        </dispatch>
    )

else if (equals($exist:path, "/documents/list/")) then
    (
    login:set-user($config:login-domain, (), false()),
        let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
        let $groups := string-join(sm:get-user-groups($user), ' ')
    return
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <!--
            <forward url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/getFunctions.xql')}">    
            -->
            <forward
                url="{concat($exist:controller, '/atlas/documents.html')}">
                
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value='{$config:project}'/>
                <add-parameter name="format" value="json"/>
                <add-parameter name="userGroups" value="{ $groups }"/>
            </forward>
            <view>
                <forward url="{$exist:controller}/modules/view.xql">
                    <!--<set-header name="Last-Modified" value="{current-dateTime()}"/>-->
                   <add-parameter name='lang' value='{ $userClientLang }'/>
                    
                    <add-parameter name='project' value='{$config:project}'/>
                    <add-parameter name='resourceType' value='documentsList'/>
                    <add-parameter name="userGroups" value="{ $groups }"/>
                </forward>
            </view>
        </dispatch>
    )


        
    

else if (starts-with($exist:path, "/debug/documents/")) then
        (
        login:set-user($config:login-domain, (), false()),
(:        if (sm:has-access(xs:anyURI('/db/apps/' || $config:project || '/modules/4access.xql'), 'r-x')) :)
    let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
           let $groups := string-join(sm:get-user-groups($user), ' ')
                    return
                            if(contains($groups, ($config:authorized-groups)))
        then
            if ($exist:resource = '') then
            (
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <forward
                url="{concat($ausohnum-lib-path, '/modules/teiEditor/getFunctions.xql')}">
               <add-parameter name='lang' value='{ $userClientLang }'/>
                    <add-parameter name="type" value="dashboard"/>
                      
                        <add-parameter name='project' value='{$config:project}'/>

            </forward>
            <view>
                <forward url="{$exist:controller}/modules/view.xql">
                   <add-parameter name='lang' value='{ $userClientLang }'/>
                    
                    <add-parameter name='project' value='{$config:project}'/>
                </forward>
            </view>
        </dispatch>
        )
            
            else 
            (
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{concat($exist:controller, '/modules/teiEditor/document-editor-debug.xql')}">
                <!--<forward url="{concat('/ausohnum-library/', '/modules/teiEditor/document-editor.xql')}">-->
                   <add-parameter name='lang' value='{ $userClientLang }'/>
                    <add-parameter name='docid' value='{$exist:resource}'/>
                    <add-parameter name='project' value='{$config:project}'/>
                </forward>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                       <add-parameter name='lang' value='{ $userClientLang }'/>
                        
                    </forward>
                </view>
            </dispatch>
         )
         
         else()  
        )

else if (starts-with($exist:path, "/documents/")) then
        (
        login:set-user($config:login-domain, (), false()),
        
(:        if (sm:has-access(xs:anyURI('/db/apps/' || $config:project || '/modules/4access.xql'), 'r-x')) :)
        let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
       
       
       let $groups := string-join(sm:get-user-groups($user), ' ')
        let $userStatus :=  if(contains($groups, ($config:authorized-groups))) then "editor" else "guest"
                                       
       return
            
                        (
                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                            <forward url="{concat($exist:controller, '/modules/teiEditor/document-publisher.xql')}">
                            <!--<forward url="{concat('/ausohnum-library/', '/modules/teiEditor/document-editor.xql')}">-->
                               <add-parameter name='lang' value='{ $userClientLang }'/>
                                <add-parameter name='docid' value='{$exist:resource}'/>
                                <add-parameter name="userStatus" value="{ $userStatus }"/>
                                <add-parameter name='resourceType' value='document'/>
                                <add-parameter name='project' value='{$config:project}'/>
                                <add-parameter name='mode' value='publication'/>
                            </forward>
                            <view>
                                <forward url="{$exist:controller}/modules/view.xql">
                                   <add-parameter name='lang' value='{ $userClientLang }'/>
                                    
                                    <add-parameter name='project' value='{$config:project}'/>
                                    <add-parameter name="userGroups" value="{ $groups }"/>
                                    <add-parameter name='resourceType' value='document'/>
                                    <add-parameter name="docid" value="{ $exist:resource }"/>
                                </forward>
                            </view>
                        </dispatch>
                        )
            )
        


else if (starts-with($exist:path, "/epiconverter/")) then
        (
        login:set-user($config:login-domain, (), false()),
        
(:        if (sm:has-access(xs:anyURI('/db/apps/' || $config:project || '/modules/4access.xql'), 'r-x')) :)
        let $user := request:get-attribute($config:login-domain||".user")
       let $groups := string-join(sm:get-user-groups($user), ' ')
       
       return
            if(contains($groups, ($config:authorized-groups)))
                then
                          
                        (
                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                            <forward url="{concat($ausohnum-lib-path, '/modules/teiEditor/getFunctions.xql')}">
                            <!--<forward url="{concat('/ausohnum-library/', '/modules/teiEditor/document-editor.xql')}">-->
                                <add-parameter name='type' value='epiconverter'/>
                               <add-parameter name='lang' value='{ $userClientLang }'/>
                                <add-parameter name='docid' value='{$exist:resource}'/>
                                <add-parameter name='project' value='{$config:project}'/>
                            </forward>
                            <view>
                                <forward url="{$exist:controller}/modules/view.xql">
                                   <add-parameter name='lang' value='{ $userClientLang }'/>
                                    
                                </forward>
                            </view>
                        </dispatch>
                        
                        )
        else
            (
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{concat($ausohnum-lib-path, '/modules/teiEditor/getFunctions.xql')}">
                <add-parameter name="type" value="loginForm"/>
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value="{$groups}"/>
                
            </forward>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                       <add-parameter name='lang' value='{ $userClientLang }'/>
                        
                    </forward>
                </view>
            </dispatch>
            )
        )



else if (equals($exist:path, "/places/update-gazetteer/")) then
    (
    login:set-user($config:login-domain, (), false()),
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <!--<forward url="{concat('/ausohnum-library', '/modules/skosThesau/', 'build-tree.xql')}">-->
        <forward url="{concat($exist:controller, '/modules/spatiumStructor/buildGazetteer.xql')}">
            <add-parameter name='type' value='buildPlaceTree'/>
            <add-parameter name='lang' value='{$exist:resource}'/>
            
            <add-parameter name='project' value='{$config:project}'/>
            <add-parameter name="thesBaseUri" value="{$thesBaseUri}"/>
            <add-parameter name="loginDomain" value="{$config:login-domain}"/>
            
        </forward>
    </dispatch>
    )

else if (equals($exist:path, "/places/list/")) then
    (
    login:set-user($config:login-domain, (), false()),
        let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
        let $groups := string-join(sm:get-user-groups($user), ' ')
    return
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <!--
            <forward url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/getFunctions.xql')}">    
            -->
            <forward
                url="{concat($exist:controller, '/atlas/places.html')}">
                
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value='{$config:project}'/>
                
                
            </forward>
        <view>
            <forward url="{$exist:controller}/modules/view.xql">
                <!--<set-header name="Last-Modified" value="{current-dateTime()}"/>-->
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value='{$config:project}'/>
                <add-parameter name='resourceType' value='placeList'/>
                <add-parameter name="userGroups" value="{ $groups }"/>
            </forward>
        </view>
        </dispatch>
    )

else if (starts-with($exist:path, "/places-manager/")) then
    (
    login:set-user($config:login-domain, (), false()),
    let $user := request:get-attribute($config:login-domain||".user")
        let $groups := string-join(sm:get-user-groups($user), ' ')
                    return
                            if(contains($groups, ($config:authorized-groups)))

    then
        (
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <forward
                url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/getFunctions.xql')}">
               <add-parameter name='lang' value='{ $userClientLang }'/>
                    <add-parameter name="type" value="places-manager"/>
                      
                        <add-parameter name='project' value='{$config:project}'/>
                        <add-parameter name="path" value="{$exist:path}"/>
                        <add-parameter name="resource" value="{$exist:resource}"/>

            </forward>
            <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                    <set-header name="Cache-Control" value="no-cache"/>
                       <add-parameter name='lang' value='{ $userClientLang }'/>
                        
                    </forward>
                </view>
        </dispatch>
        )
    else
        (
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{concat($ausohnum-lib-path, '/modules/teiEditor/getFunctions.xql')}">
                <add-parameter name="type" value="loginForm"/>
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value="{$config:project}"/>
            </forward>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                       <add-parameter name='lang' value='{ $userClientLang }'/>
                        
                    </forward>
                </view>
            </dispatch>
        )
    )

else if (equals($exist:path, "/exist/apps/estudium/geo/list")) then
    (
    login:set-user($config:login-domain, (), false()),
        let $user := request:get-attribute($config:login-domain||".user")
        let $groups := string-join(sm:get-user-groups($user), ' ')
                    return
                            if(contains($groups, ($config:authorized-groups)))

    then
        (
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <!--
            <forward url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/getFunctions.xql')}">    
            -->
            <forward
                url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/getPlacesList.xql')}">
                
               <add-parameter name='lang' value='{ $userClientLang }'/>
                      
                        <add-parameter name='project' value='{$config:project}'/>
                        <add-parameter name="format" value="json"/>
                        <set-header name="Connection" value="close"/>
 <set-header
                name="Cache-Control"
                value="max-age=3600, must-revalidate"/>                        
            </forward>

        </dispatch>
        )
    else
        (
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{concat($ausohnum-lib-path, '/modules/teiEditor/getFunctions.xql')}">
                <add-parameter name="type" value="loginForm"/>
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value="{$config:project}"/>
            </forward>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                       <add-parameter name='lang' value='{ $userClientLang }'/>
                        
                    </forward>
                </view>
            </dispatch>
        )
    )
    
else if (starts-with($exist:path, "/places/get-record/")) then
            (
            <dispatch
                xmlns="http://exist.sourceforge.net/NS/exist">
                <forward
                    url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/getFunctions.xql')}">
                   <add-parameter name='lang' value='{ $userClientLang }'/>
                        <add-parameter name="type" value="getPlaceHTML2"/>
                          
                            <add-parameter name='project' value='{$config:project}'/>
                            <add-parameter name="path" value="{$exist:path}"/>
                             <add-parameter name="resource" value="{if($exist:resource) then $exist:resource else 'root'}"/> 
                            <!--<set-header name="Cache-Control" value="no-cache"/>-->
                        <!-- <set-header name="Connection" value="close"/> -->
                </forward>
                </dispatch>
)        
    


else if (starts-with($exist:path, "/edit-places/")) then
        (
        login:set-user($config:login-domain, (), false()),
        let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
       let $groups := string-join(sm:get-user-groups($user), ' ')
                        return
                                if(contains($groups, ($config:authorized-groups)))

        then
            (
            <dispatch
                xmlns="http://exist.sourceforge.net/NS/exist">
                <forward
                    url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/getFunctions.xql')}">
                   <add-parameter name='lang' value='{ $userClientLang }'/>
                        <add-parameter name="type" value="places-manager2"/>
                          
                            <add-parameter name='project' value='{$config:project}'/>
                            <add-parameter name="path" value="{$exist:path}"/>
                            <add-parameter name="resource" value="{ $exist:resource }"/>
                            <add-parameter name="placeEditorType" value="{ $exist:resource }"/>

                </forward>
                <view>
                        <forward url="{$exist:controller}/modules/view.xql">
                           <add-parameter name="placeEditorType" value="places-manager"/>
                           <add-parameter name='lang' value='{ $userClientLang }'/>
                            
                        </forward>
                    </view>
            </dispatch>
            )
        else
            (
              <dispatch
                  xmlns="http://exist.sourceforge.net/NS/exist">
                  <forward
                      url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/getFunctions.xql')}">
                     <add-parameter name='lang' value='{ $userClientLang }'/>
                          <add-parameter name="type" value="displayPlaceDetails"/>
                            
                              <add-parameter name='project' value='{$config:project}'/>
                              <add-parameter name="path" value="{$exist:path}"/>
                              <add-parameter name="resource" value="{if(data($exist:resource) ='') then 'root' else $exist:resource}"/>

                  </forward>
                  <view>
                          <forward url="{$exist:controller}/modules/view.xql">
                          <set-header name="Cache-Control" value="no-cache"/>
                             <add-parameter name='lang' value='{ $userClientLang }'/>
                              
                          </forward>
                      </view>
              </dispatch>
            )
        )

else if (starts-with($exist:path, "/atlas/map/")) then
        (
        login:set-user($config:login-domain, (), false()),
        let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
       let $groups := string-join(sm:get-user-groups($user), ' ')
                        return
            <dispatch
                xmlns="http://exist.sourceforge.net/NS/exist">
                <forward
                    url="{concat($exist:controller, '/atlas/map.html')}">
                   <add-parameter name='lang' value='{ $userClientLang }'/>
                        <add-parameter name="type" value="map"/>
                          
                            <add-parameter name='project' value='{$config:project}'/>
                            <add-parameter name="path" value="{$exist:path}"/>
                            <add-parameter name="resource" value="Atlas"/>
                            <add-parameter name="docid" value="Atlas"/>
               </forward>
                <view>
                        <forward url="{$exist:controller}/modules/view.xql">
                           <add-parameter name='lang' value='{ $userClientLang }'/>
                            
                            <add-parameter name="resourceType" value="atlas"/>
                        </forward>
                    </view>
            </dispatch>
            )
else if (starts-with($exist:path, "/atlas/editor/")) then
        (
        login:set-user($config:login-domain, (), false()),
        let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
       let $groups := string-join(sm:get-user-groups($user), ' ')
                        return
            <dispatch
                xmlns="http://exist.sourceforge.net/NS/exist">
                <forward
                    url="{concat($exist:controller, '/atlas/editor.html')}">
                   <add-parameter name='lang' value='{ $userClientLang }'/>
                        <add-parameter name="type" value="map"/>
                          
                            <add-parameter name='project' value='{$config:project}'/>
                            <add-parameter name="path" value="{$exist:path}"/>
                            <add-parameter name="resource" value="Atlas"/>
                            <add-parameter name="docid" value="Atlas"/>
                </forward>
                <view>
                        <forward url="{$exist:controller}/modules/view.xql">
                           <add-parameter name='lang' value='{ $userClientLang }'/>
                            
                            <add-parameter name="resourceType" value="atlasEditor"/>
                        </forward>
                    </view>
            </dispatch>
            )
else if (equals($exist:path, "/atlas/")) then
        (
        login:set-user($config:login-domain, (), false()),
        let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
       let $groups := string-join(sm:get-user-groups($user), ' ')
                        return
            <dispatch
                xmlns="http://exist.sourceforge.net/NS/exist">
                <forward
                    url="{concat($exist:controller, '/atlas/index.html')}">
                   <add-parameter name='lang' value='{ $userClientLang }'/>
                     
                    <add-parameter name='project' value='{$config:project}'/>
                    <add-parameter name="path" value="{$exist:path}"/>
                            
               </forward>
                <view>
                        <forward url="{$exist:controller}/modules/view.xql">
                           <add-parameter name='lang' value='{ $userClientLang }'/>
                            
                            <add-parameter name="resourceType" value="landingpage"/>
                        </forward>
                    </view>
            </dispatch>
            )
 
(:Used by teiEditor to load all texts related to one document:)
else if (starts-with($exist:path, "/geo/search-place/")) then
        (
        login:set-user($config:login-domain, (), false()),
             let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
           let $groups := string-join(sm:get-user-groups($user), ' ')
                    return
                            if(contains($groups, ($config:authorized-groups)))
                            then
            (
            <dispatch
                xmlns="http://exist.sourceforge.net/NS/exist">
                <forward 
                url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/getFunctions.xql')}">
                <add-parameter name="type" value="searchPlace"/>
                    <add-parameter
                        name='lang'
                        value='en'/>
                        <add-parameter
                        name='project'
                        value='{$config:project}'/>
                    <add-parameter
                        name='query'
                        value='{$exist:resource}'/>
                </forward>
                
            </dispatch>
            )
        else
            (
           <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{concat($ausohnum-lib-path, '/modules/teiEditor/getFunctions.xql')}">
                <add-parameter name="type" value="loginForm"/>
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value="{$config:project}"/>
            </forward>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                       <add-parameter name='lang' value='{ $userClientLang }'/>
                        
                    </forward>
                </view>
            </dispatch>
            )
        )
else if (starts-with($exist:path, "/places/list/json/")) then
    (
    login:set-user($config:login-domain, (), false()),
        let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
        let $groups := string-join(sm:get-user-groups($user), ' ')
    return
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <!--
            <forward url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/getFunctions.xql')}">    
            -->
            <forward
                url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/getPlacesList.xql?listType=public')}">
                
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value='{$config:project}'/>
                <add-parameter name="format" value="json"/>
                <add-parameter name="listType" value="{ $exist:resource }"/>
                
            </forward>

        </dispatch>
    )

else if (starts-with($exist:path, "/places/get-place-record/")) then
        (
        
            login:set-user($config:login-domain, (), false()),
            let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                else "guest"
            let $groups := string-join(sm:get-user-groups($user), ' ')
            let $userStatus :=  if(contains($groups, ($config:authorized-groups))) then "editor" else "guest"
        
        return
                                
            <dispatch
                xmlns="http://exist.sourceforge.net/NS/exist">
                <forward
                    url="{concat($exist:controller, '/modules/spatiumStructor/place-publisher.xql')}">
                   <add-parameter name='lang' value='{ $userClientLang }'/>
                          
                            <add-parameter name='project' value='{$config:project}'/>
                            <add-parameter name="userStatus" value="{ $userStatus }"/>
                            <add-parameter name="path" value="{$exist:path}"/>
                            <add-parameter name="resource" value="{ $exist:resource }"/>
                            <add-parameter name="docid" value="{ $exist:resource }"/>
                            <add-parameter name="origin" value="call"/>
                            <add-parameter name="resourceType" value="place"/>
                            
                </forward>
                
            </dispatch>
            
        )
else if (starts-with($exist:path, "/places/get-related-places/")) then
(<dispatch
                xmlns="http://exist.sourceforge.net/NS/exist">
                <forward
                    url="{concat($ausohnum-lib-path, '/modules/commons/getList.xql')}">
                   <add-parameter name='lang' value='{ $userClientLang }'/>
                          
                            <add-parameter name='project' value='{$config:project}'/>
                            <add-parameter name="path" value="{$exist:path}"/>
                            <add-parameter name="listType" value="relatedPlaces"/>
                            <add-parameter name="resourceId" value="{ $exist:resource }"/>
                            <add-parameter name="resourceType" value="place"/>

                </forward>
</dispatch>)

else if (starts-with($exist:path, "/places/get-related-people/")) then
(<dispatch
                xmlns="http://exist.sourceforge.net/NS/exist">
                <forward
                    url="{concat($ausohnum-lib-path, '/modules/commons/getList.xql')}">
                   <add-parameter name='lang' value='{ $userClientLang }'/>
                          
                            <add-parameter name='project' value='{$config:project}'/>
                            <add-parameter name="path" value="{$exist:path}"/>
                            <add-parameter name="listType" value="relatedPeople"/>
                            <add-parameter name="resourceId" value="{ $exist:resource }"/>
                            <add-parameter name="resourceType" value="people"/>

                </forward>
</dispatch>)

else if (starts-with($exist:path, "/places/get-related-documents/")) then
(<dispatch
                xmlns="http://exist.sourceforge.net/NS/exist">
                <forward
                    url="{concat($ausohnum-lib-path, '/modules/commons/getList.xql')}">
                   <add-parameter name='lang' value='{ $userClientLang }'/>
                          
                            <add-parameter name='project' value='{$config:project}'/>
                            <add-parameter name="path" value="{$exist:path}"/>
                            <add-parameter name="listType" value="relatedDocuments"/>
                            <add-parameter name="resourceId" value="{ $exist:resource }"/>
                            <add-parameter name="resourceType" value="place"/>

                </forward>
</dispatch>)

else if (starts-with($exist:path, "/places/get-temporal-scale/")) then
(<dispatch
                xmlns="http://exist.sourceforge.net/NS/exist">
                <forward
                    url="{concat($ausohnum-lib-path, '/modules/commons/getList.xql')}">
                   <add-parameter name='lang' value='{ $userClientLang }'/>
                          
                            <add-parameter name='project' value='{$config:project}'/>
                            <add-parameter name="path" value="{$exist:path}"/>
                            <add-parameter name="listType" value="temporalScale"/>
                            <add-parameter name="resourceId" value="{ $exist:resource }"/>
                            <add-parameter name="resourceType" value="place"/>

                </forward>
</dispatch>)

else if (starts-with($exist:path, "/places/roman-provinces/")) then
        (
        login:set-user($config:login-domain, (), false()),
        let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
       let $groups := string-join(sm:get-user-groups($user), ' ')
       let $userStatus :=  if(contains($groups, ($config:authorized-groups))) then "editor" else "guest"
                            
                        return
            <dispatch
                xmlns="http://exist.sourceforge.net/NS/exist">
                <forward
                    url="{concat($dataCollection-path, 'places/romanProvinces/', $exist:resource)}">
                   <add-parameter name='lang' value='{ $userClientLang }'/>
                        <add-parameter name="type" value="places-manager2"/>
                          
                            <add-parameter name='project' value='{$config:project}'/>
                            <add-parameter name="userStatus" value="{ $userStatus }"/>
                            <add-parameter name="path" value="{$exist:path}"/>
                            <add-parameter name="resource" value="{ $exist:resource }"/>
                            <add-parameter name="docid" value="{ $exist:resource }"/>
                            <add-parameter name="resourceType" value="place"/>

                </forward>
              
            </dispatch>
            )
else if (starts-with($exist:path, "/places/")) then
        (
        login:set-user($config:login-domain, (), false()),
        let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
       let $groups := string-join(sm:get-user-groups($user), ' ')
       let $userStatus :=  if(contains($groups, ($config:authorized-groups))) then "editor" else "guest"
       
                        return
            <dispatch
                xmlns="http://exist.sourceforge.net/NS/exist">
                <forward
                    url="{concat($exist:controller, '/modules/spatiumStructor/place-publisher.xql')}">
                   <add-parameter name='lang' value='{ $userClientLang }'/>
                        <add-parameter name="type" value="places-manager2"/>
                          
                            <add-parameter name='project' value='{$config:project}'/>
                            <add-parameter name="userStatus" value="{ $userStatus }"/>
                            <add-parameter name="path" value="{$exist:path}"/>
                            <add-parameter name="resource" value="{ $exist:resource }"/>
                            <add-parameter name="docid" value="{ $exist:resource }"/>
                            <add-parameter name="resourceType" value="place"/>
                            

                </forward>
                <view>
                        <forward url="{$exist:controller}/modules/view.xql">
                           <add-parameter name='lang' value='{ $userClientLang }'/>
                            
                            <add-parameter name="userGroups" value="{ $groups }"/>
                            <add-parameter name="docid" value="{ $exist:resource }"/>
                            <add-parameter name="resourceType" value="place"/>
                        </forward>
                    </view>
            </dispatch>
            )

else if (equals($exist:path, "/people/list/")) then
    (
    login:set-user($config:login-domain, (), false()),
        let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
        let $groups := string-join(sm:get-user-groups($user), ' ')
    return
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <!--
            <forward url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/getFunctions.xql')}">    
            -->
            <forward
                url="{concat($exist:controller, '/atlas/people.html')}">
                
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value='{$config:project}'/>
                <add-parameter name="format" value="json"/>
                <add-parameter name="userGroups" value="{ $groups }"/>
                
            </forward>
        <view>
            <forward url="{$exist:controller}/modules/view.xql">
                <!--<set-header name="Last-Modified" value="{current-dateTime()}"/>-->
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value='{$config:project}'/>
                <add-parameter name='resourceType' value='peopleList'/>
                <add-parameter name="userGroups" value="{ $groups }"/>
            </forward>
        </view>
        </dispatch>
    )
else if (equals($exist:path, "/people/update-list/")) then
    (
    login:set-user($config:login-domain, (), false()),
        let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
        let $groups := string-join(sm:get-user-groups($user), ' ')
    return
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <!--
            <forward url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/getFunctions.xql')}">    
            -->
            
            <!-- <forward
                url="{concat($exist:controller, '/modules/teiEditor/getDocumentsList.xql')}">-->
                <forward
                url="{concat($exist:controller, '/modules/prosopoManager/buildPeopleList.xql')}">
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value='{$config:project}'/>
                <add-parameter name="format" value="json"/>
                
            </forward>

        </dispatch>
    )
    
else if (equals($exist:path, "/people/list/json")) then
    (
    login:set-user($config:login-domain, (), false()),
        let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
        let $groups := string-join(sm:get-user-groups($user), ' ')
    return
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <!--
            <forward url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/getFunctions.xql')}">    
            -->
            <forward
                url="{concat($ausohnum-lib-path, '/modules/prosopoManager/getPeopleList.xql')}">
                
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value='{$config:project}'/>
                <add-parameter name="format" value="json"/>
                <add-parameter name="resourceType" value="people"/>
            </forward>

        </dispatch>
    )

else if (equals($exist:path, "/people/build-list/")) then
    (
    login:set-user($config:login-domain, (), false()),
        let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
        let $groups := string-join(sm:get-user-groups($user), ' ')
    return
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <!--
            <forward url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/getFunctions.xql')}">    
            -->
            <forward
                url="{concat($ausohnum-lib-path, '/modules/prosopoManager/buildPeopleList.xql')}">
                
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value='{$config:project}'/>
                <add-parameter name="format" value="json"/>
                <add-parameter name="resourceType" value="people"/>
            </forward>

        </dispatch>
    )

 else if (equals($exist:path, "/people/json")) then
    (
    login:set-user($config:login-domain, (), false()),
           let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
           let $groups := string-join(sm:get-user-groups($user), ' ')
                    return
                            if(contains($groups, ($config:authorized-groups)))

    then
        (
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <!--
            <forward url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/getFunctions.xql')}">    
            -->
            <forward
                url="{concat($ausohnum-lib-path, '/modules/prosopoManager/getAllPeople.xql')}">
                
               <add-parameter name='lang' value='{ $userClientLang }'/>
                    <add-parameter name="type" value="processUrl"/>
                      
                        <add-parameter name='project' value='{$config:project}'/>
                        <add-parameter name="path" value="{$exist:path}"/>
                        <add-parameter name="resource" value="{$exist:resource}"/>
                        <add-parameter name="format" value="json"/>
                        <set-header name="Connection" value="close"/>                        
            </forward>

        </dispatch>
        )
    else
        (
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{concat($ausohnum-lib-path, '/modules/teiEditor/getFunctions.xql')}">
                <add-parameter name="type" value="loginForm"/>
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value="{$config:project}"/>
            </forward>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                       <add-parameter name='lang' value='{ $userClientLang }'/>
                        
                    </forward>
                </view>
            </dispatch>
        )
    )
else if (starts-with($exist:path, "/people/search/")) then
    (
    login:set-user($config:login-domain, (), false()),
    let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
           let $groups := string-join(sm:get-user-groups($user), ' ')
                    return
                            if(contains($groups, ($config:authorized-groups)))

    then
        (
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <!--
            <forward url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/getFunctions.xql')}">    
            -->
            <forward
                url="{concat($ausohnum-lib-path, '/modules/prosopoManager/searchPeople.xql')}">
                
               <add-parameter name='lang' value='{ $userClientLang }'/>
                    <add-parameter name="type" value="processUrl"/>
                      
                        <add-parameter name='project' value='{$config:project}'/>
                        <add-parameter name="path" value="{$exist:path}"/>
                        
                        <add-parameter name="format" value="json"/>
            </forward>

        </dispatch>
        )
    else
        (
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{concat($ausohnum-lib-path, '/modules/teiEditor/getFunctions.xql')}">
                <add-parameter name="type" value="loginForm"/>
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value="{$config:project}"/>
            </forward>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                       <add-parameter name='lang' value='{ $userClientLang }'/>
                        
                    </forward>
                </view>
            </dispatch>
        )
    )
else if (starts-with($exist:path, "/people/build-tree")) then
    (
    login:set-user($config:login-domain, (), false()),
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{concat('/ausohnum-library', '/modules/skosThesau/', 'build-tree.xql')}">
        <!--<forward url="{concat($ausohnum-lib-path, '/modules/prosopoManager/getFunctions.xql')}">-->
            <add-parameter name='type' value='buildPeopleTree'/>
            <add-parameter name='lang' value='{$exist:resource}'/>
            
            <add-parameter name='project' value='{$config:project}'/>
            <add-parameter name="thesBaseUri" value="{$thesBaseUri}"/>
            <add-parameter name="loginDomain" value="{$config:login-domain}"/>
        </forward>
    </dispatch>
    )

else if (starts-with($exist:path, "/people/get-record/")) then
            (
            <dispatch
                xmlns="http://exist.sourceforge.net/NS/exist">
                <forward
                    url="{concat($ausohnum-lib-path, '/modules/prosopoManager/getFunctions.xql')}">
                   <add-parameter name='lang' value='{ $userClientLang }'/>
                        <add-parameter name="type" value="getPeopleHTML2"/>
                          
                            <add-parameter name='project' value='{$config:project}'/>
                            <add-parameter name="path" value="{$exist:path}"/>
                             <add-parameter name="resource" value="{if($exist:resource) then $exist:resource else 'root'}"/> 
            <!--                <set-header name="Cache-Control" value="no-cache"/>-->
             <!--            <set-header name="Connection" value="close"/> -->
                </forward>
                </dispatch>
)        
else if (starts-with($exist:path, "/people/get-person-record/")) then
        (
        
            login:set-user($config:login-domain, (), false()),
            let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                else "guest"
            let $groups := string-join(sm:get-user-groups($user), ' ')
            let $userStatus :=  if(contains($groups, ($config:authorized-groups))) then "editor" else "guest"
        
        return
                                
            <dispatch
                xmlns="http://exist.sourceforge.net/NS/exist">
                <forward
                    url="{concat($exist:controller, '/modules/prosopoManager/person-publisher.xql')}">
                   <add-parameter name='lang' value='{ $userClientLang }'/>
                          
                            <add-parameter name='project' value='{$config:project}'/>
                            <add-parameter name="userStatus" value="{ $userStatus }"/>
                            <add-parameter name="path" value="{$exist:path}"/>
                            <add-parameter name="resource" value="{ $exist:resource }"/>
                            <add-parameter name="docid" value="{ $exist:resource }"/>
                            <add-parameter name="origin" value="call"/>
                            <add-parameter name="resourceType" value="people"/>
                            
                </forward>
                
            </dispatch>
            
        )


else if (starts-with($exist:path, "/people/query")) then
            (
            <dispatch
                xmlns="http://exist.sourceforge.net/NS/exist">
                <forward
                    url="{concat($ausohnum-lib-path, '/modules/prosopoManager/queryPeople.xql')}">
                   <add-parameter name='lang' value='{ $userClientLang }'/>
                          
                            <add-parameter name='project' value='{$config:project}'/>
                            <add-parameter name="query" value="{ $exist:resource }"/>
                            <set-header name="Cache-Control" value="no-cache"/>
                        <!-- <set-header name="Connection" value="close"/> -->
                </forward>
                </dispatch>
)        

else if (starts-with($exist:path, "/edit-people/")) then
        (
        
        login:set-user($config:login-domain, (), false()),
        let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
            else "guest"
        let $groups := string-join(sm:get-user-groups($user), ' ')
                        return
                                if(contains($groups, ($config:authorized-groups)))

        then
            (
            <dispatch
                xmlns="http://exist.sourceforge.net/NS/exist">
                <forward
                    url="{concat($ausohnum-lib-path, '/modules/prosopoManager/getFunctions.xql')}">
                   <add-parameter name='lang' value='{ $userClientLang }'/>
                        <add-parameter name="type" value="people-manager2"/>
                          
                            <add-parameter name='project' value='{$config:project}'/>
                            <add-parameter name="path" value="{$exist:path}"/>
                            <add-parameter name="resource" value="{ $exist:resource }"/>
                            <set-header name="Cache-Control" value="no-cache"/>
                        <!--<set-header name="Connection" value="close"/>-->
                </forward>
                <view>
                        <forward url="{$exist:controller}/modules/view.xql">
                            <set-header name="Cache-Control" value="no-cache"/>
                           <add-parameter name='lang' value='{ $userClientLang }'/>
                            

                        </forward>
                    </view>
            </dispatch>
            )
        else
            (
              <dispatch
                  xmlns="http://exist.sourceforge.net/NS/exist">
                  <forward
                      url="{concat($ausohnum-lib-path, '/modules/teiEditor/getFunctions.xql')}">
                     <add-parameter name='lang' value='{ $userClientLang }'/>
                          <add-parameter name="type" value="loginForm"/>
                            
                              <add-parameter name='project' value='{$config:project}'/>
                              <add-parameter name="path" value="{$exist:path}"/>
                              <add-parameter name="resource" value="{if(data($exist:resource) ='') then 'root' else $exist:resource}"/>

                  </forward>
                  <view>
                          <forward url="{$exist:controller}/modules/view.xql">
                              <set-header name="Cache-Control" value="no-cache"/>
                             <add-parameter name='lang' value='{ $userClientLang }'/>
                              
                          </forward>
                      </view>
              </dispatch>
            )
        )
else if (equals($exist:path, "/people/update-date-ranges/")) then
    (
    login:set-user($config:login-domain, (), false()),
        let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
        let $groups := string-join(sm:get-user-groups($user), ' ')
        
        return
            if(contains($groups, ($config:authorized-groups)))
                then
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <!--
            <forward url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/getFunctions.xql')}">    
            -->
            <forward
                url="{concat($ausohnum-lib-path, '/modules/prosopoManager/updateDateRangeInPeople.xql')}">
                <add-parameter name='project' value='{$config:project}'/>
             </forward>

        </dispatch>
        
        else
            (
              <dispatch
                  xmlns="http://exist.sourceforge.net/NS/exist">
                  <forward
                      url="{concat($ausohnum-lib-path, '/modules/teiEditor/getFunctions.xql')}">
                     <add-parameter name='lang' value='{ $userClientLang }'/>
                          <add-parameter name="type" value="loginForm"/>
                            
                              <add-parameter name='project' value='{$config:project}'/>
                              <add-parameter name="path" value="{$exist:path}"/>
                              <add-parameter name="resource" value="{if(data($exist:resource) ='') then 'root' else $exist:resource}"/>

                  </forward>
                  <view>
                          <forward url="{$exist:controller}/modules/view.xql">
                              <set-header name="Cache-Control" value="no-cache"/>
                             <add-parameter name='lang' value='{ $userClientLang }'/>
                              
                          </forward>
                      </view>
              </dispatch>
            )
    )
    
else if (starts-with($exist:path, "/people/")) then
        (
        
        login:set-user($config:login-domain, (), false()),
        let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
            else "guest"
        let $groups := string-join(sm:get-user-groups($user), ' ')
        let $editor :=  contains($groups, ($config:authorized-groups))
        let $userStatus :=  if(contains($groups, ($config:authorized-groups))) then "editor" else "guest"
                                
        return
            if($exist:resource ="") then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    	       <redirect url="/people/list/"/>
            </dispatch>
            else                    
            <dispatch
                xmlns="http://exist.sourceforge.net/NS/exist">
                <forward
                    url="{concat($exist:controller, '/modules/prosopoManager/person-publisher.xql')}">
                   <add-parameter name='lang' value='{ $userClientLang }'/>
                          
                          <add-parameter name="editor" value="{ $editor }"/>
                            <add-parameter name='project' value='{$config:project}'/>
                            <add-parameter name="userStatus" value="{ $userStatus }"/>
                            <add-parameter name="path" value="{$exist:path}"/>
                            <add-parameter name="resource" value="{ $exist:resource }"/>
                            <add-parameter name="docid" value="{ $exist:resource }"/>
                            <add-parameter name="resourceType" value="people"/>
                            
                </forward>
                <view>
                        <forward url="{$exist:controller}/modules/view.xql">
                            <set-header name="Cache-Control" value="no-cache"/>
                           <add-parameter name='lang' value='{ $userClientLang }'/>
                            
                            <add-parameter name="userGroups" value="{ $groups }"/>
                            <add-parameter name="resourceType" value="people"/>
                            <add-parameter name="docid" value="{ $exist:resource }"/>
                        </forward>
                    </view>
            </dispatch>
            
        )

        
else if (starts-with($exist:path, "/people-functions/search/")) then
    (
    login:set-user($config:login-domain, (), false()),
    let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
           let $groups := string-join(sm:get-user-groups($user), ' ')
                    return
                            if(contains($groups, ($config:authorized-groups)))

    then
        (
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <!--
            <forward url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/getFunctions.xql')}">    
            -->
            <forward
                url="{concat($ausohnum-lib-path, '/modules/prosopoManager/searchFunctions.xql')}">
                
               <add-parameter name='lang' value='{ $userClientLang }'/>
                    <add-parameter name="type" value="processUrl"/>
                      
                        <add-parameter name='project' value='{$config:project}'/>
                        <add-parameter name="path" value="{$exist:path}"/>
                        
                        <add-parameter name="format" value="json"/>
            </forward>

        </dispatch>
        )
    else
        (
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{concat($ausohnum-lib-path, '/modules/teiEditor/getFunctions.xql')}">
                <add-parameter name="type" value="loginForm"/>
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value="{$config:project}"/>
            </forward>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                       <add-parameter name='lang' value='{ $userClientLang }'/>
                        
                    </forward>
                </view>
            </dispatch>
        )
    )

else if (starts-with($exist:path, "/people-functionTarget/search/")) then
    (
    login:set-user($config:login-domain, (), false()),
    let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
       let $user := request:get-attribute($config:login-domain||".user")
        let $groups := string-join(sm:get-user-groups($user), ' ')
                    return
                            if(contains($groups, ($config:authorized-groups)))

    then
        (
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <!--
            <forward url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/getFunctions.xql')}">    
            -->
            <forward
                url="{concat($ausohnum-lib-path, '/modules/prosopoManager/searchFunctionTarget.xql')}">
                
               <add-parameter name='lang' value='{ $userClientLang }'/>
                    <add-parameter name="type" value="processUrl"/>
                      
                        <add-parameter name='project' value='{$config:project}'/>
                        <add-parameter name="path" value="{$exist:path}"/>
                        
                        <add-parameter name="format" value="json"/>
            </forward>

        </dispatch>
        )
    else
        (
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{concat($ausohnum-lib-path, '/modules/teiEditor/getFunctions.xql')}">
                <add-parameter name="type" value="loginForm"/>
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value="{$config:project}"/>
            </forward>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                       <add-parameter name='lang' value='{ $userClientLang }'/>
                        
                    </forward>
                </view>
            </dispatch>
        )
    )

else if (starts-with($exist:path, "/people-bondtypes/search/")) then
    (
    login:set-user($config:login-domain, (), false()),
    let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
           let $groups := string-join(sm:get-user-groups($user), ' ')
                    return
                            if(contains($groups, ($config:authorized-groups)))

    then
        (
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <!--
            <forward url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/getFunctions.xql')}">    
            -->
            <forward
                url="{concat($ausohnum-lib-path, '/modules/prosopoManager/searchBondTypes.xql')}">
                
               <add-parameter name='lang' value='{ $userClientLang }'/>
                    <add-parameter name="type" value="processUrl"/>
                      
                        <add-parameter name='project' value='{$config:project}'/>
                        <add-parameter name="path" value="{$exist:path}"/>
                        
                        <add-parameter name="format" value="json"/>
            </forward>

        </dispatch>
        )
    else
        (
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{concat($ausohnum-lib-path, '/modules/teiEditor/getFunctions.xql')}">
                <add-parameter name="type" value="loginForm"/>
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value="{$config:project}"/>
            </forward>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                       <add-parameter name='lang' value='{ $userClientLang }'/>
                        
                    </forward>
                </view>
            </dispatch>
        )
    )
    
else if (starts-with($exist:path, "/geo/build-tree")) then
    (
    login:set-user($config:login-domain, (), false()),
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <!--<forward url="{concat('/ausohnum-library', '/modules/skosThesau/', 'build-tree.xql')}">-->
        <forward url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/getFunctions.xql')}">
            <add-parameter name='type' value='buildPlaceTree'/>
            <add-parameter name='lang' value='{$exist:resource}'/>
            
            <add-parameter name='project' value='{$config:project}'/>
            <add-parameter name="thesBaseUri" value="{$thesBaseUri}"/>
            <add-parameter name="loginDomain" value="{$config:login-domain}"/>
            <set-header name="Connection" value="close"/>
        </forward>
    </dispatch>
    )



else if (starts-with($exist:path, "/places/get-rdf/")) then
    (
    login:set-user($config:login-domain, (), false()),
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/', 'getFunctions.xql')}">
            <add-parameter name='type' value='getPlaceRecord'/>
            <add-parameter name='resource' value='{substring-after($exist:path, '/places/get-rdf/')}'/>
           <add-parameter name='lang' value='{ $userClientLang }'/>
        </forward>
       <!--
       <view>
            <forward url="{$exist:controller}/modules/view.xql">
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value='patrimonium'/>
            </forward>

        </view>
       -->
    </dispatch>
    )


else if (equals($exist:path, "/geo/places/json")) then
    (
    login:set-user($config:login-domain, (), false()),
    let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
           let $groups := string-join(sm:get-user-groups($user), ' ')
                    return
                            if(contains($groups, ($config:authorized-groups)))

    then
        (
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <!--
            <forward url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/getFunctions.xql')}">    
            -->
            <forward
                url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/projectPlaces2GeoJSon.xql')}">
                
               <add-parameter name='lang' value='{ $userClientLang }'/>
                    <add-parameter name="type" value="processUrl"/>
                      
                        <add-parameter name='project' value='{$config:project}'/>
                        <add-parameter name="path" value="{$exist:path}"/>
                        <add-parameter name="resource" value="{$exist:resource}"/>
                        <add-parameter name="format" value="json"/>
                        <set-header name="Connection" value="close"/>
 <set-header
                name="Cache-Control"
                value="max-age=3600, must-revalidate"/>                        
            </forward>

        </dispatch>
        )
    else
        (
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{concat($ausohnum-lib-path, '/modules/teiEditor/getFunctions.xql')}">
                <add-parameter name="type" value="loginForm"/>
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value="{$config:project}"/>
            </forward>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                       <add-parameter name='lang' value='{ $userClientLang }'/>
                        
                    </forward>
                </view>
            </dispatch>
        )
    )
    
    
else if (starts-with($exist:path, "/geo/document/")) then
    (
    login:set-user($config:login-domain, (), false()),
    let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
           let $groups := string-join(sm:get-user-groups($user), ' ')
                    return
                    
        (
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <!--
            <forward url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/getFunctions.xql')}">    
            -->
            <forward
                url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/documentPlaces2GeoJSon.xql')}">
                
               <add-parameter name='lang' value='{ $userClientLang }'/>
                    <add-parameter name="type" value="processUrl"/>
                      
                        <add-parameter name='project' value='{$config:project}'/>
                        <add-parameter name="path" value="{$exist:path}"/>
                        <add-parameter name="docId" value="{$exist:resource}"/>
                        <add-parameter name="format" value="json"/>
                        <set-header name="Connection" value="close"/>
 <set-header
                name="Cache-Control"
                value="max-age=3600, must-revalidate"/>                        
            </forward>

        </dispatch>
        )
    
    )
    
else if (starts-with($exist:path, "/geo/production-units")) then
    (
    login:set-user($config:login-domain, (), false()),
    let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
           let $groups := string-join(sm:get-user-groups($user), ' ')
                    return
                            if(contains($groups, ($config:authorized-groups)))

    then
        (
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <!--
            <forward url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/getFunctions.xql')}">    
            -->
            <forward
                url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/productionUnits2GeoJSon.xql')}">
                
               <add-parameter name='lang' value='{ $userClientLang }'/>
                    <add-parameter name="type" value="processUrl"/>
                      
                        <add-parameter name='project' value='{$config:project}'/>
                      
                        <add-parameter name="format" value="json"/>
                        <set-header name="Connection" value="close"/>
 <set-header
                name="Cache-Control"
                value="max-age=3600, must-revalidate"/>                        
            </forward>

        </dispatch>
        )
    else
        (
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{concat($ausohnum-lib-path, '/modules/teiEditor/getFunctions.xql')}">
                <add-parameter name="type" value="loginForm"/>
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value="{$config:project}"/>
            </forward>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                       <add-parameter name='lang' value='{ $userClientLang }'/>
                        
                    </forward>
                </view>
            </dispatch>
        )
    )
    

else if (starts-with($exist:path, "/geo/places/search/")) then
    (
    login:set-user($config:login-domain, (), false()),
    let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
           let $groups := string-join(sm:get-user-groups($user), ' ')
                    return
                            if(contains($groups, ($config:authorized-groups)))

    then
        (
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <!--
            <forward url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/getFunctions.xql')}">    
            -->
            <forward
                url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/searchPlaces.xql')}">
                
               <add-parameter name='lang' value='{ $userClientLang }'/>
                    <add-parameter name="type" value="processUrl"/>
                      
                        <add-parameter name='project' value='{$config:project}'/>
                        <add-parameter name="path" value="{$exist:path}"/>
                        
                        <add-parameter name="format" value="json"/>
            </forward>

        </dispatch>
        )
    else
        (
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{concat($ausohnum-lib-path, '/modules/teiEditor/getFunctions.xql')}">
                <add-parameter name="type" value="loginForm"/>
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value="{$config:project}"/>
            </forward>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                       <add-parameter name='lang' value='{ $userClientLang }'/>
                        
                    </forward>
                </view>
            </dispatch>
        )
    )

    
else if (starts-with($exist:path, "/geo/gazetteer/")) then
    (
    login:set-user($config:login-domain, (), false()),
    let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
           let $groups := string-join(sm:get-user-groups($user), ' ')
     return
                            
        (
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <forward
                url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/getGazetteer.xql')}">
               <add-parameter name='lang' value='{ $userClientLang }'/>
                    <add-parameter name="type" value="getPlacesGazetteer"/>
                      
                        <add-parameter name='project' value='{$config:project}'/>
                        <add-parameter name="format" value="json"/>
                        <add-parameter name="resource" value="{$exist:resource}"/>

            </forward>

        </dispatch>
        )
    
    )
    
else if (starts-with($exist:path, "/geo/pleiades-gazetteer/")) then
    (
    login:set-user($config:login-domain, (), false()),
        let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
        let $groups := string-join(sm:get-user-groups($user), ' ')
    return
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <!--
            <forward url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/getFunctions.xql')}">    
            -->
            <forward
                url="{concat($config:project, 'Data/places/pleiades.stoa.org/name_index.json')}">
                
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value='{$config:project}'/>
                <add-parameter name="format" value="json"/>
                
                
            </forward>

        </dispatch>
    )

else if (starts-with($exist:path, "/geo/")) then
    (
    login:set-user($config:login-domain, (), false()),
    let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
           let $groups := string-join(sm:get-user-groups($user), ' ')
                    return
                            if(contains($groups, ($config:authorized-groups)))

    then
        (
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <forward
                url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/getFunctions.xql')}">
               <add-parameter name='lang' value='{ $userClientLang }'/>
                    <add-parameter name="type" value="processUrl"/>
                      
                        <add-parameter name='project' value='{$config:project}'/>
                        <add-parameter name="path" value="{$exist:path}"/>
                        <add-parameter name="resource" value="{$exist:resource}"/>

            </forward>

        </dispatch>
        )
    else
        (
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{concat($ausohnum-lib-path, '/modules/teiEditor/getFunctions.xql')}">
                <add-parameter name="type" value="loginForm"/>
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value="{$config:project}"/>
            </forward>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                       <add-parameter name='lang' value='{ $userClientLang }'/>
                        
                    </forward>
                </view>
            </dispatch>
        )
    )


(:else if (starts-with($exist:path, "/geo/project-places")) then
    (
    login:set-user($config:login-domain, (), false()),
    let $user := request:get-attribute($config:login-domain||".user")
        let $groups := string-join(sm:get-user-groups($user), ' ')
                    return
                            if(contains($groups, ($config:authorized-groups)))

    then
        (
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <forward
                url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/getFunctions.xql')}">
               <add-parameter name='lang' value='{ $userClientLang }'/>
                    <add-parameter name="type" value="processUrl"/>
                      
                        <add-parameter name='project' value='{$config:project}'/>
                        <add-parameter name="path" value="{$exist:path}"/>
                        <add-parameter name="resource" value="{$exist:resource}"/>

            </forward>

        </dispatch>
        )
    else
        (
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{concat($ausohnum-lib-path, '/modules/teiEditor/getFunctions.xql')}">
                <add-parameter name="type" value="loginForm"/>
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value="{$config:project}"/>
            </forward>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                       <add-parameter name='lang' value='{ $userClientLang }'/>
                        
                    </forward>
                </view>
            </dispatch>
        )
    )
:)



else if (starts-with($exist:path, "/geo")) then
    (
    login:set-user($config:login-domain, (), false()),
    let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
           let $groups := string-join(sm:get-user-groups($user), ' ')
                    return
                            if(contains($groups, ($config:authorized-groups)))

    then
        (
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <forward
                url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/getFunctions.xql')}">
               <add-parameter name='lang' value='{ $userClientLang }'/>
                    <add-parameter name="type" value="processUrl"/>
                      
                        <add-parameter name='project' value='{$config:project}'/>
                        <add-parameter name="path" value="{$exist:path}"/>
                        <add-parameter name="resource" value="{$exist:resource}"/>

            </forward>

        </dispatch>
        )
    else
        (
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{concat($ausohnum-lib-path, '/modules/teiEditor/getFunctions.xql')}">
                <add-parameter name="type" value="loginForm"/>
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value="{$config:project}"/>
            </forward>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                       <add-parameter name='lang' value='{ $userClientLang }'/>
                        
                    </forward>
                </view>
            </dispatch>
        )
    )



else if (starts-with($exist:path, "/sandbox-editor/")) then
    (
    login:set-user($config:login-domain, (), false()),
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <forward
                url="{concat($exist:controller, '/modules/teiEditor/document-editor.xql')}">
               <add-parameter name='lang' value='{ $userClientLang }'/>
                <add-parameter name='docid' value='{$exist:resource}'/>
                <add-parameter name='project' value='patrimonium'/>
            </forward>
            <view>
                <forward url="{$exist:controller}/modules/view.xql">
                   <add-parameter name='lang' value='{ $userClientLang }'/>
                    

                </forward>
            </view>
        </dispatch>
    )

else if (starts-with($exist:path, "/admin/save/document/")) then
    (
    login:set-user($config:login-domain, (), false()),
    let $data := request:get-data()
    let $now := fn:current-dateTime()
    let $currentUser := sm:id()
    let $logs := collection("/db/apps/" || 'patrimonium' || "/data/logs")
    let $logInjection :=
        update insert
        <apc:log type="document-update-in-controller" when="{$now}" what="{string($data/xml/docId)}" who="{$currentUser}">
            {$data}

        </apc:log>
        into $logs/rdf:RDF/id('all-logs')

     return
        (: the html page is run through view.xql to expand templates :)
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">

            <forward
                url="{concat($exist:controller, '/modules/teiEditor/passDataToLibrary.xql')}">
               <add-parameter name='lang' value='{ $userClientLang }'/>
                <add-parameter name='type' value='{$exist:resource}'/>
                <add-parameter name='project' value='patrimonium'/>

            </forward>
            </dispatch>
    )


else if (equals($exist:path, "/atlas/keywords/")) then
    (
    login:set-user($config:login-domain, (), false()),
        let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
        let $groups := string-join(sm:get-user-groups($user), ' ')
    return
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <!--<forward url="{concat('/ausohnum-library', '/modules/skosThesau/', 'build-tree.xql')}">-->
        <forward url="{concat($exist:controller, '/atlas/keywords.html')}">
            <add-parameter name='lang' value='{$exist:resource}'/>
            <add-parameter name='project' value='{$config:project}'/>
            
        </forward>
         <view>
            <forward url="{$exist:controller}/modules/view.xql">
               <add-parameter name='lang' value='{ $userClientLang }'/>
           <add-parameter name='userGroups' value='{ $groups }'/>
            </forward>
        </view>
    </dispatch>
    ) 
else if (equals($exist:path, "/keywords/update-general-index/")) then
    (
    login:set-user($config:login-domain, (), false()),
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <!--<forward url="{concat('/ausohnum-library', '/modules/skosThesau/', 'build-tree.xql')}">-->
        <forward url="{concat($exist:controller, '/modules/skosThesau/updateGeneralIndex.xql')}">
            <add-parameter name='lang' value='{$exist:resource}'/>
            <add-parameter name='project' value='{$config:project}'/>
        </forward>
    </dispatch>
    ) 
else if (starts-with($exist:path, "/concept/")) then
(:else if (starts-with($exist:path, "/" || $dbprefix ||"/concept/")) then:)
    (
    login:set-user($config:login-domain, (), false()),
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">

        <forward url="{concat($ausohnum-lib-path, '/modules/skosThesau/', 'concept-display.xql')}">

        </forward>

       <!--
        <forward url="{concat($exist:controller, '/modules/skosThesau/', 'passDataToLibrary.xql')}">
                     <add-parameter name='conceptId' value='{if($exist:resource) then $exist:resource else ("apcc1")}'/>
                     <add-parameter name='type' value='displayConcept'/>
                    <add-parameter name='lang' value='{ $userClientLang }'/>
                     <add-parameter name='project' value='{$config:project}'/>
                     </forward>
        -->

        <view>
            <forward url="{$exist:controller}/modules/view.xql">
                 <add-parameter name='conceptId' value='{if($exist:resource) then $exist:resource else ("c1")}'/>
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value='{$config:project}'/>
                <add-parameter name='authorized-groups' value='{$config:authorized-groups}'/>
                <add-parameter name='user' value='{$login}'/>
                 <set-attribute name="$exist:path" value="{$exist:path}"/>
            </forward>

        </view>

    </dispatch>
    )

else if (starts-with($exist:path, "/concepts/search/")) then
    (
    login:set-user($config:login-domain, (), false()),
    let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
           let $groups := string-join(sm:get-user-groups($user), ' ')
                    return
                            if(contains($groups, ($config:authorized-groups)))

    then
        (
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <!--
            <forward url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/getFunctions.xql')}">    
            -->
            <forward
                url="{concat($ausohnum-lib-path, '/modules/skosThesau/searchConcepts.xql')}">
                
               <add-parameter name='lang' value='{ $userClientLang }'/>
                    
                      
                        <add-parameter name='project' value='{$config:project}'/>
                        <add-parameter name="path" value="{$exist:path}"/>
                        
                        <add-parameter name="format" value="json"/>
            </forward>

        </dispatch>
        )
    else
        (
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{concat($ausohnum-lib-path, '/modules/teiEditor/getFunctions.xql')}">
                <add-parameter name="type" value="loginForm"/>
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value="{$config:project}"/>
            </forward>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                       <add-parameter name='lang' value='{ $userClientLang }'/>
                        
                    </forward>
                </view>
            </dispatch>
        )
    )
else if (starts-with($exist:path, "/thesaurus/getTreeFromConcept/")) then
(:else if (starts-with($exist:path, "/" || $dbprefix ||"/concept/")) then:)
    (
    login:set-user($config:login-domain, (), false()),
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">

        <forward url="{concat($ausohnum-lib-path, '/modules/skosThesau/getFunctions.xql')}">
            <add-parameter name='conceptId' value='{if($exist:resource) then $exist:resource else ("C1")}'/>
            <add-parameter name='type' value='getTreeFromConcept'/>
            <add-parameter name='lang' value='en'/>
            <add-parameter name='project' value='{$config:project}'/>
        </forward>
       

    </dispatch>
    )
else if (starts-with($exist:path, "/thesaurus/getTreeFromMultipleConcepts/")) then
(:else if (starts-with($exist:path, "/" || $dbprefix ||"/concept/")) then:)
    (
    login:set-user($config:login-domain, (), false()),
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">

        <forward url="{concat($ausohnum-lib-path, '/modules/skosThesau/getFunctions.xql')}">
            <add-parameter name='conceptId' value='{if($exist:resource) then $exist:resource else ("C1")}'/>
            <add-parameter name='type' value='getTreeFromMultipleConcepts'/>
            <add-parameter name='lang' value='en'/>
            <add-parameter name='project' value='{$config:project}'/>
        </forward>
       

    </dispatch>
    ) 
else if (starts-with($exist:path, "/getConceptDetails/")) then
    (
    login:set-user($config:login-domain, (), false()),
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{concat($exist:controller, '/modules/skosThesau/', 'conceptDetails.xql')}">
            <add-parameter name='conceptId' value='{$exist:resource}'/>
            <add-parameter name='project' value='{$config:project}'/>
           <cache-control
                cache="no"/>
        </forward>
        <view>
            <forward url="{$exist:controller}/modules/view.xql">
            
            </forward>

        </view>
    </dispatch>
    )   
else if (ends-with($exist:path, "/apc/thesaurus/dashboard/")) then
    (
    login:set-user($config:login-domain, (), false()),
let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
               let $groups := string-join(sm:get-user-groups($user), ' ')
                    return
                            if(contains($groups, ($config:authorized-groups)))
                            then
        (
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <forward
                url="{concat($ausohnum-lib-path, '/modules/skosThesau/', 'dashboard.xql')}">
                <add-parameter name='project' value='patrimonium'/>
                <add-parameter
                    name='lang'
                    value='en'/>
                      <add-parameter
                                name='selectedLang'
                                value='en'/>
            </forward>
            <view>
                <forward url="{$exist:controller}/modules/view.xql">

                   <add-parameter name='lang' value='{ $userClientLang }'/>
                    
                </forward>
            </view>
        </dispatch>
        )
    else
        (
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{concat($ausohnum-lib-path, '/modules/teiEditor/getFunctions.xql')}">
                <add-parameter name="type" value="loginForm"/>
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value="{$config:project}"/>
            </forward>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                       <add-parameter name='lang' value='{ $userClientLang }'/>
                        
                    </forward>
                </view>
            </dispatch>
        )
    )







else if (starts-with($exist:path, "/thesaurus/get-data/starts-with-in-scheme")) then
    (
    login:set-user($config:login-domain, (), false()),

    let $currentConceptId := substring-before(substring-after($exist:path, "starts-with-in-scheme/"), '/')
    return
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{concat($ausohnum-lib-path, '/modules/skosThesau/', 'getData.xql')}">
            <add-parameter name='query-type' value='startswithinscheme'/>
            <add-parameter name='currentConceptId' value='{$currentConceptId}'/>
            <add-parameter name='project' value='ausohnum'/>
        </forward>
    </dispatch>
    )

else if (starts-with($exist:path, "/skosThesau/build-tree")) then
    (
    login:set-user($config:login-domain, (), false()),
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <!--<forward url="{concat('/ausohnum-library', '/modules/skosThesau/', 'build-tree.xql')}">-->
        <forward url="{concat($exist:controller, '/modules/skosThesau/', 'passDataToLibrary.xql')}">
            <add-parameter name='type' value='buildTree'/>
            <add-parameter name='lang' value='{$exist:resource}'/>
            
            <add-parameter name='project' value='{$config:project}'/>
            <add-parameter name="thesBaseUri" value="{$thesBaseUri}"/>
            <add-parameter name="loginDomain" value="{$config:login-domain}"/>
        </forward>
    </dispatch>
    )
else if (starts-with($exist:path, "/skosThesau/pass-data-to-library")) then
    (let $data := request:get-data()
    return
    login:set-user($config:login-domain, (), false()),
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{concat($exist:controller, '/modules/skosThesau/', 'passDataToLibrary.xql')}">
           <add-parameter name='lang' value='{ $userClientLang }'/>
            
            <add-parameter name='project' value='{$config:project}'/>
            <add-parameter name="type" value="{$exist:resource}"/>
        </forward>
    </dispatch>
    )
else if (starts-with($exist:path, "/skosThesau/save-data")) then
    (let $data := request:get-data()
    return
    login:set-user($config:login-domain, (), false()),
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{concat($ausohnum-lib-path, '/modules/skosThesau/', 'passDataToLibrary.xql')}">
           <add-parameter name='lang' value='{ $userClientLang }'/>
            
            <add-parameter name='project' value='{$config:project}'/>
            <add-parameter name="type" value="{$exist:resource}"/>
        </forward>
    </dispatch>
    )
else if (starts-with($exist:path, "/apc/people/")) then
    (
    login:set-user($config:login-domain, (), false()),
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{concat($exist:controller, '/data/people/people.xml#', $exist:resource)}">
            <add-parameter name='conceptId' value='{$exist:resource}'/>
           <add-parameter name='lang' value='{ $userClientLang }'/>
            <add-parameter name='project' value='patrimonium'/>
        </forward>
        <view>
            <forward url="{$exist:controller}/modules/view.xql">
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value='patrimonium'/>
            </forward>
        </view>
    </dispatch>
    )

else if (starts-with($exist:path, "/call-concept/")) then
    (
    login:set-user($config:login-domain, (), false()),
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{concat($ausohnum-lib-path, '/modules/skosThesau/', 'concept-call.xql')}">

            <add-parameter name='conceptId' value='{functx:substring-after-last(functx:substring-before-last($exist:path, '/'), '/')}'/>
            <add-parameter name='lang' value='{$exist:resource}'/>
        </forward>
        <view>
            <forward url="{$exist:controller}/modules/view.xql">
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value='patrimonium'/>
            </forward>

        </view>
    </dispatch>
    )

else if (starts-with($exist:path, "/json/get-annotations/")) then
    (
    (:    login:set-user($config:login-domain, (), false()),:)
    (: the html page is run through view.xql to expand templates :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{concat($exist:controller, '/modules/getAnnotations.xql')}">
            <add-parameter name='docid' value='{$exist:resource}'/>
        </forward>
        <error-handler>
            <forward url="{$exist:controller}/error-page.html" method="get"/>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </error-handler>
    </dispatch>
    )


else if (starts-with($exist:path, "/admin/concept/")) then
    (
    login:set-user($config:login-domain, (), false()),
let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
               let $groups := string-join(sm:get-user-groups($user), ' ')
                    return
                            if(contains($groups, ($config:authorized-groups))) then
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{$exist:controller || '/modules/skosThesau/concept-edit.xql?concept=' || $exist:resource}">
                <add-parameter name='concept' value='{$exist:resource}'/>
               <add-parameter name='lang' value='{ $userClientLang }'/>
            </forward>
            <view>
                <forward url="{$exist:controller}/modules/view.xql">
                   <add-parameter name='lang' value='{ $userClientLang }'/>
                    
                </forward>
            </view>
        </dispatch>
    else
        (
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{concat($exist:controller, '/login.html')}" />
            <view>
                <forward url="{$exist:controller}/modules/view.xql"/>
            </view>
        </dispatch>
        )
    )

else if (starts-with($exist:path, "/admin/new-concept/")) then
    (
    login:set-user($config:login-domain, (), false()),
let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
               let $groups := string-join(sm:get-user-groups($user), ' ')
                    return
                            if(contains($groups, ($config:authorized-groups)))
                            then
        (
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{concat($exist:controller, '/modules/skosThesau/concept-new.xql')}">
                <add-parameter name='scheme' value='{$exist:resource}'/>
               <add-parameter name='lang' value='{ $userClientLang }'/>
            </forward>
            <view>
                <forward url="{$exist:controller}/modules/view.xql">
                   <add-parameter name='lang' value='{ $userClientLang }'/>
                    
                </forward>
            </view>
        </dispatch>
        )
    else
        (
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{concat($exist:controller, '/modules/login-form.xql')}"/>
            <view>
                <forward url="{$exist:controller}/modules/view.xql"/>
            </view>
        </dispatch>
        )
    )


else if (starts-with($exist:path, "/admin/new-nt/")) then
    (
    login:set-user($config:login-domain, (), false()),
let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
               let $groups := string-join(sm:get-user-groups($user), ' ')
                    return
                            if(contains($groups, ($config:authorized-groups)))
                            then
        (
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{concat($exist:controller, '/modules/skosThesau/concept-new.xql')}">
                <add-parameter name='conceptId' value='{$exist:resource}'/>
               <add-parameter name='lang' value='{ $userClientLang }'/>
            </forward>
            <view>
                <forward url="{$exist:controller}/modules/view.xql">
                   <add-parameter name='lang' value='{ $userClientLang }'/>
                    
                </forward>
            </view>
        </dispatch>
        )
    else
        (
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{concat($exist:controller, '/modules/login-form.xql')}"/>
            <view>
                <forward url="{$exist:controller}/modules/view.xql"/>
            </view>
        </dispatch>
        )
    )
else if (starts-with($exist:path, "/admin/scheme/")) then
    (
    login:set-user($config:login-domain, (), false()),
let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
               let $groups := string-join(sm:get-user-groups($user), ' ')
                    return
                            if(contains($groups, ($config:authorized-groups)))
                            then
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{concat($exist:controller, '/modules/skosThesau/scheme-edit.xql')}">
                <add-parameter name='scheme' value='{$exist:resource}'/>
            </forward>
            <view>
                <forward url="{$exist:controller}/modules/view.xql">
                   <add-parameter name='lang' value='{ $userClientLang }'/>
                    
                </forward>
            </view>
        </dispatch>
    else
        (
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{concat($exist:controller, '/modules/login-form.xql')}">
            </forward>
            <view>
                <forward url="{$exist:controller}/modules/view.xql"/>
            </view>
        </dispatch>
        )
    )

else if (starts-with($exist:path, "/admin/new-scheme/")) then
    (
    login:set-user($config:login-domain, (), false()),
let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
               let $groups := string-join(sm:get-user-groups($user), ' ')
                    return
                            if(contains($groups, ($config:authorized-groups)))
                            then

        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{concat($exist:controller, '/modules/skosThesau/scheme-new.xql')}" />
            <view>
                <forward url="{$exist:controller}/modules/view.xql">
                   <add-parameter name='lang' value='{ $userClientLang }'/>
                    
                </forward>
            </view>
        </dispatch>
    else
    (
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{concat($exist:controller, '/modules/login-form.xql')}"/>
        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
    </dispatch>)
    )


else if (starts-with($exist:path, "/getfunction/")) then
    (
    login:set-user($config:login-domain, (), false()),
            let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
            let $groups := string-join(sm:get-user-groups($user), ' ')
    
                    return
                            if(contains($groups, ($config:authorized-groups)))

    then
        (
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <!--
            <forward url="{concat($ausohnum-lib-path, '/modules/spatiumStructor/getFunctions.xql')}">    
            -->
            <forward
                url="{concat($ausohnum-lib-path, '/modules/requestsHandler.xql')}">
                
               <add-parameter name='lang' value='{ $userClientLang }'/>
                    
                      
                        <add-parameter name='project' value='{$config:project}'/>
                        <add-parameter name="path" value="{$exist:path}"/>
                        <add-parameter name="existResource" value="{ $exist:resource }"/>
                        <set-header name="Cache-Control" value="no-cache"/>
                        <set-header name="Connection" value="close"/>
            </forward>

        </dispatch>
        )
    else
        (
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{concat($ausohnum-lib-path, '/modules/teiEditor/getFunctions.xql')}">
                <add-parameter name="type" value="loginForm"/>
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='project' value="{$config:project}"/>
            </forward>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                       <add-parameter name='lang' value='{ $userClientLang }'/>
                        
                    </forward>
                </view>
            </dispatch>
        )
    )



else if (ends-with($exist:resource, ".xql")) then
    (
    login:set-user($config:login-domain, (), false()),
        let $user := if(request:get-attribute($config:login-domain||".user") != "") then request:get-attribute($config:login-domain||".user")
                        else "guest"
       
        let $groups := string-join(sm:get-user-groups($user), ' ')
                    return
      if(contains($groups, ($config:authorized-groups)))
                            then
        (
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{$exist:resource}">
             <add-parameter name='lang' value='{ $userClientLang }'/>
                <add-parameter name='access' value='private-thot'/>
                <add-parameter name='project' value='{$config:project}'/>
                <add-parameter name='zoteroGroup' value='2094917'/>
            </forward>
            <cache-control cache="no"/>
        </dispatch>
        )
    else
        (
        <dispatch
            xmlns="http://exist.sourceforge.net/NS/exist">
            <forward
                url="{$exist:resource}">
                <add-parameter name='lang' value='{ $userClientLang }'/>
                <add-parameter
                    name='access'
                    value='public'/>
            </forward>
            <cache-control
                cache="no"/>
        </dispatch>
        )
    )



(:else if (ends-with($exist:resource, ".html")) then (
    login:set-user($config:login-domain, (), false()),
    let $resource :=
        if (contains($exist:path, "/templates/")) then
            "templates/" || $exist:resource
        else
            $exist:resource
    return
        (\: the html page is run through view.xql to expand templates :\)
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{$exist:controller}/{$resource}"/>
            <view>
                <forward url="{$exist:controller}/modules/view.xql"/>
            </view>
    		<error-handler>
    			<forward url="{$exist:controller}/error-page.html" method="get"/>
    			<forward url="{$exist:controller}/modules/view.xql"/>
    		</error-handler>
        </dispatch>
)    :)



else if ($exist:path eq "/") then (
(:Rule must be before that on ends-with and login.logout:)
login:set-user($config:login-domain, 'patrimonium.huma-num.fr', (), false()),


    (: forward root path to index.xql :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="index.html">
           <add-parameter name='lang' value='{ $userClientLang }'/>
        </forward>

        
         <view>
          <forward url="{$exist:controller}/modules/view.xql">
           <add-parameter name='lang' value='{ $userClientLang }'/>
           </forward>
         </view>
    </dispatch>
)

(:else if (ends-with($exist:path, "/")) then
    (
    (\: forward root path to index.xql :\)
    login:set-user($config:login-domain, (), false()),
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="index.html">
           <add-parameter name='lang' value='{ $userClientLang }'/>
        </forward>
        <view>
            <forward url="{$exist:controller}/modules/view.xql">
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='currentFile' value='{$exist:path}index.html'/>
            </forward>
        </view>
    </dispatch>
    )
:)


else
    if ($logout or $login) then
        (
        login:set-user($config:login-domain, 'patrimonium.huma-num.fr', (), false()),
        (: redirect successful login attempts to the original page, but prevent redirection to non-local websites:)
        let $referer := request:get-header("Referer")
        let $this-servers-scheme-and-domain := request:get-scheme() || "://" || request:get-server-name()


        return
            (
(:            console:log($referer),:)
            if (starts-with($referer, $this-servers-scheme-and-domain)) then
                <dispatch
                    xmlns="http://exist.sourceforge.net/NS/exist">
                    <redirect
                        url="{request:get-header("Referer")}"/>
                   <add-parameter name='lang' value='{ $userClientLang }'/>

                </dispatch>
            else
                <dispatch
                    xmlns="http://exist.sourceforge.net/NS/exist">
                    <redirect
                        url="{replace(request:get-uri(), "^(.*)\?", "$1")}"/>
                </dispatch>
            )
        )


else if (ends-with($exist:resource, ".html")) then
    (
    login:set-user($config:login-domain, (), false()),
(: the html page is run through view.xql to expand templates :)
    <dispatch
        xmlns="http://exist.sourceforge.net/NS/exist">
        <view>
            <forward url="{$exist:controller}/modules/view.xql">
               <add-parameter name='lang' value='{ $userClientLang }'/>
                
                <add-parameter name='currentFile' value='{$exist:path}'/>
                <add-parameter name='project' value='{$config:project}'/>
            </forward>
        </view>
        <error-handler>
            <forward url="{$exist:controller}/error-page.html" method="get"/>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </error-handler>
    </dispatch>
    )


(: Resource paths starting with $shared are loaded from the shared-resources app :)
(:else if (contains($exist:path, "/$shared/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="/shared-resources/{substring-after($exist:path, '/$shared/')}">
            <set-header name="Cache-Control" value="max-age=3600, must-revalidate"/>
        </forward>
    </dispatch>:)

(: Resource paths starting with $ausohnum-lib are loaded from the ausohnum-library app :)



else
    (: everything else is passed through :)
    (
(:    login:set-user($config:login-domain, (), false()),:)
    (:<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>
    :)
    )
