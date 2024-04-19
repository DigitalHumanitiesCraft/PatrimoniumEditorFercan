xquery version "3.1";

import module namespace functx="http://www.functx.com";
import module namespace httpclient="http://exist-db.org/xquery/httpclient" at "java:org.exist.xquery.modules.httpclient.HTTPClientModule";
import module namespace zoteroPlugin="http://ausonius.huma-num.fr/zoteroPlugin" at "./zoteroPlugin/zoteroPlugin.xql";

declare namespace dc="http://purl.org/dc/elements/1.1/";
declare namespace dct = "http://purl.org/dc/terms/";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace z = "http://www.zotero.org/namespaces/export#";

(:declare namespace periodo="http://perio.do/#";:)
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
import module namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/" at "./skosThesau/skosThesauApp.xql";

let $concept-collection := collection('xmldb:exist:///db/apps/' || "patrimonium-data/concepts")
let $zoteroGroup := "2221443"
let $resourceRef := "3RMCKV5S"
let $format := "bibtex"

let $HGV_metadata := collection("xmldb:exist:///db/apps/papyriInfo/data/HGV_meta_EpiDoc")
let $papiryInfoCollectionTranscr := collection("xmldb:exist:///db/apps/papyriInfo/data/DDB_EpiDoc_XML")
let $HGVNo := "11964"
let $tmNo := "9812"
let $filename1 := "sb.24.15909"

(:let $teiHeader :=    $HGV_metadata//tei:TEI[equals(.//tei:idno[equals(./@type, "filename")]/text(), $HGVNo)]:)
(:let $ddb-filename := $teiHeader//tei:idno[equals(./@type, "ddb-filename")]/text():)
(:let $teiText := $papiryInfoCollectionTranscr//tei:TEI[matches(.//tei:idno[equals(./@type,  "TM")], $tmNo)]//tei:div[matches(./@type, "edition")]:)
        

let $teiHeader := $HGV_metadata/id("hgv"|| $HGVNo)
let $ddb-filename := $teiHeader//tei:idno[equals(./@type, "ddb-filename")]/text()
let $teiText := $papiryInfoCollectionTranscr/id($ddb-filename)//tei:div[matches(./@type, "edition")]

        return
            $teiText/node()
(:            $ddb-filename:)
(:            $papiryInfoCollectionTranscr/id($filename1):)