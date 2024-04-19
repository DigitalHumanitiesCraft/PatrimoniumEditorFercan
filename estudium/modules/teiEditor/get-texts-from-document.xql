xquery version "3.1";

import module namespace config="http://ausonius.huma-num.fr/ausohnum-library/config" at "../config.xqm";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace patrimonium = "https://ausohnum.huma-num.fr/apps/eStudium/onto#";
declare namespace functx = "http://www.functx.com";
(:declare default element namespace "http://www.tei-c.org/ns/1.0";:)
declare option output:method "xml";

declare option output:media-type "application/xml";
declare option output:undeclare-prefixes "yes";
declare option output:omit-xml-declaration "yes"; 
declare option output:indent "yes";
declare option output:suppress-indentation "ab div";


let $docid := request:get-parameter('docid', '')
let $doc-collection := collection('/db/apps/' || $config:project || '-data/documents')
let $teiDoc := $doc-collection/id($docid)
(:let $xsl := xs:anyURI("xmldb:exist:///db/apps/ausohnum-library/xslt/cleanTextEdition.xsl")
let $text :=
    if (exists($teiDoc//*[local-name() = 'div'][@type="edition"]/*[local-name() = 'div'][@type="edition"])) then
        $teiDoc/*[local-name() = 'text']/*[local-name()='body']/*[local-name() = 'div'][@type='edition']/*[local-name()='div'][@type='textpart']/*[local-name()='ab']    
    else(
        $teiDoc/*[local-name() = 'text']/*[local-name()='body']/*[local-name() = 'div'][@type='edition']/*[local-name()='ab']
        )
let $cleanedText := transform:transform($text, $xsl, ())
:)
return
<data>
    {
    if (exists($teiDoc//*[local-name() = 'div'][@type="edition"]/*[local-name() = 'div'][@type="edition"])) then
    (
    for $text in $teiDoc/*[local-name() = 'text']/*[local-name()='body']/*[local-name() = 'div'][@type='edition']//*[local-name()='div'][@type='textpart']
    return
    $text/*[local-name()='ab'])
    else (
    <ab>{$teiDoc/*[local-name() = 'text']/*[local-name()='body']/*[local-name() = 'div'][@type='edition']//*[local-name()='ab']/node()}</ab>
    )
    }     
</data>
  


