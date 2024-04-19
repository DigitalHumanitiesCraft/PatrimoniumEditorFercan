(:~
 : This is the main XQuery which will (by default) be called by controller.xql
 : to process any URI ending with ".html". It receives the HTML from
 : the controller and passes it to the templating system.
 :)
xquery version "3.1";

import module namespace templates="http://exist-db.org/xquery/templates" ;

(: 
 : The following modules provide functions which will be called by the 
 : templating.
 :)
import module namespace config="https://ausohnum.huma-num.fr/apps/eStudium/config" at "config.xqm";
import module namespace app="https://ausohnum.huma-num.fr/apps/eStudium/templates" at "app.xql";
import module namespace newdoc="https://ausohnum.huma-num.fr/apps/eStudium/newdoc" at "admin/new-document.xql";
(:import module namespace processConcept="https://ausohnum.huma-num.fr/skosThesau/processConcept" at "xmldb:exist:///db/apps/ausohnum-library/modules/skosThesau/concept-process.xql";:)
import module namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/" at "xmldb:exist:///db/apps/ausohnum-library/modules/skosThesau/skosThesauApp.xql";
import module namespace teiEditor="http://ausonius.huma-num.fr/teiEditor" at "xmldb:exist:///db/apps/ausohnum-library/modules/teiEditor/teiEditorApp.xql";
import module namespace spatiumStructor="http://ausonius.huma-num.fr/spatiumStructor" at "xmldb:exist:///db/apps/ausohnum-library/modules/spatiumStructor/spatiumStructor.xql";
import module namespace ausohnumCommons="http://ausonius.huma-num.fr/commons" at "xmldb:exist:///db/apps/ausohnum-library/modules/commons/commonsApp.xql";
import module namespace ausohnumSearch="http://ausonius.huma-num.fr/search" at "xmldb:exist:///db/apps/ausohnum-library/modules/commons/search.xql";

import module namespace i18n="http://exist-db.org/xquery/i18n/templates" at "lib/i18n-templates.xql";
(:import module namespace browse="http://www.tei-c.org/tei-simple/templates" at "lib/browse.xql";:)

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "xhtml";
declare option output:media-type "text/html";

let $config := map {
    $templates:CONFIG_APP_ROOT : $config:app-root,
    $templates:CONFIG_STOP_ON_ERROR : true()
}
(:
 : We have to provide a lookup function to templates:apply to help it
 : find functions in the imported application modules. The templates
 : module cannot see the application modules, but the inline function
 : below does see them.
 :)
let $lookup := function($functionName as xs:string, $arity as xs:int) {
    try {
        function-lookup(xs:QName($functionName), $arity)
    } catch * {
        ()
    }
}
(:
 : The HTML is passed in the request from the controller.
 : Run it through the templating system and return the result.
 :)
let $content := request:get-data()
return
    templates:apply($content, $lookup, (), $config)