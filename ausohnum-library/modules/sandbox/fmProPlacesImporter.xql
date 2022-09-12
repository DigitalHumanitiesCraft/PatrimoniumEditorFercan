xquery version "3.1";

import module namespace teiEditor="http://ausonius.huma-num.fr/teiEditor"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/teiEditor/teiEditorApp.xql";

import module namespace functx="http://www.functx.com";

import module namespace http="http://expath.org/ns/http-client" at "java:org.expath.exist.HttpClientModule";

declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace tei="http://www.tei-c.org/ns/1.0";


let $currentUser := xmldb:get-current-user()

let $now := fn:current-dateTime()
let $filename := "places-linked-to-docs.xml"
let $path2docs := "xmldb:exist:///db/apps/patrimoniumData/documents/"
let $logs := collection("xmldb:exist:///db/apps/patrimoniumData" || '/logs')
let $fmpPlaces := doc("xmldb:exist:///db/apps/patrimoniumData/fmProImports/" || $filename)

let $xslt := doc("xmldb:exist:///db/apps/ausohnum-library/xslt/fmProPlace2apcPlace.xsl")
let $xslParam :=
        <output:serialization-parameters
        xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
            <output:omit-xml-declaration value="no"/>
            <output:method value="xml"/>
            <output:indent value="yes"/>
            <output:item-separator value="\n"/>
            <output:undeclare-prefixes value="no"/>
        </output:serialization-parameters>


let $placesAsPleiades := transform:transform( $fmpPlaces, $xslt, $xslParam)

return $placesAsPleiades