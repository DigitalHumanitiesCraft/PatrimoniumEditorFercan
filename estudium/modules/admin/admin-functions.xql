xquery version "1.0";


module namespace newdoc="https://ausohnum.huma-num.fr/apps/eStudium/newdoc";

import module namespace templates="http://exist-db.org/xquery/templates" ;

declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace tei = "http://www.tei-c.org/ns/1.0";


declare namespace ev = "http://www.w3.org/2001/xml-events";
declare namespace thot = "http://thot.philo.ulg.ac.be/";
declare namespace xf = "http://www.w3.org/2002/xforms";
declare namespace dct = "http://purl.org/dc/terms/";
declare namespace local = "local";


declare option exist:serialize "method=xml media-type=text/html omit-xml-declaration=no indent=yes";
declare
    %templates:wrap
function newdoc:new-document($nodes as node(), $model as map(*)) {

let $now := fn:current-dateTime()
let $currentUser := sm:id()
let $userPrimaryGroup := sm:get-user-primary-group($currentUser)
let $template := collection('/db/apps/patrimonium/data/templates/')

let $model := <div
    id="xform_model"
>
    <xf:model
        id="m_document"
        xmlns:skos="http://www.w3.org/2004/02/skos/core#"
        xmlns:thot="http://thot.philo.ulg.ac.be/"
    >
        <xf:instance xmlns="" id="i_document">
            {$template}
        

</xf:instance>
</xf:model>
</div>

let $model2 := 
    <div
    id="xform_model"
        >
    <xf:model
        id="m_document"
        >
        <xf:instance xmlns="" id="i_document">
            <doc>
                <a>AAA</a>
                <b>BBB</b>
            </doc>
        

</xf:instance>
<xf:bind
            id="aa"
            ref="instance('i_document')/a"/>
        
</xf:model>
</div>


return
<div >
     
      {$model2}
      
       <div class="container">
        <div class="row">
            <div class="container-fluid">

                <div class="col-md-8">
                
                </div>
                </div>
                </div>
                </div>
   </div>


};