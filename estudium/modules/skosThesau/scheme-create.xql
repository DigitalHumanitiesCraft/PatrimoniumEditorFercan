xquery version "3.1";

import module namespace config="https://ausohnum.huma-num.fr/apps/eStudium/config" at "../config.xqm";

declare namespace skos="http://www.w3.org/2004/02/skos/core#";
declare namespace dc="http://purl.org/dc/elements/1.1/";
declare namespace dct="http://purl.org/dc/terms/";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/";
declare namespace json="http://www.json.org"; 
declare namespace functx = "http://www.functx.com"; 

declare option exist:serialize "method=xhtml media-type=text/html indent=yes";
(:declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=yes indent=yes";:)

declare function functx:escape-for-regex
  ( $arg as xs:string? )  as xs:string {

   replace($arg,
           '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')
 } ;

declare function functx:substring-after-last
  ( $arg as xs:string? ,
    $delim as xs:string )  as xs:string {

   replace ($arg,concat('^.*',functx:escape-for-regex($delim)),'')
 } ;

let $now := fn:current-dateTime()

let $logs := collection($config:data-collection || '/logs')

let $currentUser := data(sm:id()//sm:username)
let $userGroup := sm:get-user-primary-group($currentUser)
let $data := request:get-data()

let $newScheme := $data//.[@type="scheme"]/node()
let $newTT := $data//.[@type="conceptCreation"]/node()
let $schemeShortName := $newScheme//dc:title[@type="short"]/text()

let $URLTT := if($newTT//skos:prefLabel[@xml:lang='en']!= '') then
                data($newTT//@rdf:about)
                else(
                data($newScheme//skos:hasTopConcept/@rdf:resource)
                )

    
                    (:let $xsl :=              xs:anyURI("xmldb:exist:///db/apps/patrimonium/modules/admin/remove-empty-elements.xsl"):)

let $xsl-clean-newTT :=  xs:anyURI("xmldb:exist:///db/apps/patrimonium/modules/skosThesau/scheme-clean-new-topterm.xsl")
let $xsl-clean-scheme := xs:anyURI("xmldb:exist:///db/apps/patrimonium/modules/skosThesau/scheme-clean-new.xsl")
let $param :=
        <parameters>
            <param name="TTURL" value="{$URLTT}"/>
        </parameters>
let $paramXltTT :=
        <parameters>
            <param name="schemeShortName" value="{$schemeShortName}"/>
        </parameters>       


                                (:let $xslt-remove-empty :=transform:transform($data, $xsl, ($param)):)
        
let $cleaned-scheme :=transform:transform($newScheme, $xsl-clean-scheme, ($param))
let $cleaned-TT := transform:transform($newTT, $xsl-clean-newTT, ($paramXltTT))
                                    let $final-TT :=transform:transform($cleaned-TT, $xsl-clean-newTT, ($paramXltTT))
let $schemeFinal := <rdf:RDF xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:skosThesau="https://ausohnum.huma-num.fr/skosThesau/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:time="http://www.w3.org/2006/time#" xmlns:dct="http://purl.org/dc/terms/" xmlns:map="http://www.w3c.rl.ac.uk/2003/11/21-skos-mapping#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:periodo="http://perio.do/#" xmlns:skos="http://www.w3.org/2004/02/skos/core#">
                        {$cleaned-scheme}
                        {$cleaned-TT}
                        </rdf:RDF>


let $storeNewConceptScheme := xmldb:store("/db/apps/patrimonium/data/concepts", concat($newScheme//dc:title[@type="short"], '.rdf'), $schemeFinal)
                            
                            (:let $data-collection := collection('/db/apps/thot/data/concepts') 
                            
                            
                                :)




                                        (:let $dataWithoutEmptyNodes := $data//*[not(./text() = '') 
                                             and normalize-space()=''
                                              ]:)
                                        (:let $data-test := <test>
                                                
                                               { for $nodes in $data/skos:Concept/child::node()
                                                return 
                                                if ($nodes != "") then $nodes 
                                                else if ($nodes/@rdf:resource != "") then $nodes else() 
                                                
                                                
                                                }
                                                </test>
                                        :)
let $log:= update insert 
<skosThesau:log type='scheme-creation' when='{$now}' who='{$currentUser}' what="data($schemeFinal//skos:ConceptScheme/@rdf:about)">
    <data>{$data}</data>
     <newScheme>
    {$newScheme}</newScheme>
    <newTT>
    {$newTT}</newTT>
    
    <cleanedTT>
    {$cleaned-TT}</cleanedTT>
    <finalScheme>{$schemeFinal}</finalScheme>
    
</skosThesau:log> into $logs/rdf:RDF[@xml:id='all-logs']


return
null

(:<response>
<code>200</code>
<message>Scheme created</message></response>
:)
