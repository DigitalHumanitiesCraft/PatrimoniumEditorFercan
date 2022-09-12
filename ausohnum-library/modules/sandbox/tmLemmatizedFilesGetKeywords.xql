xquery version "3.1";

import module namespace kwic="http://exist-db.org/xquery/kwic";


import module namespace http="http://expath.org/ns/http-client" at "java:org.expath.exist.HttpClientModule";
import module namespace teiEditor="http://ausonius.huma-num.fr/teiEditor"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/teiEditor/teiEditorApp.xql";
import module namespace prosopoManager="http://ausonius.huma-num.fr/prosopoManager"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/prosopoManager/prosopoManager.xql";

import module namespace functx="http://www.functx.com";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace lawd="http://lawd.info/ontology/";
declare namespace pleiades="https://pleiades.stoa.org/places/vocab#";
declare namespace owl="http://www.w3.org/2002/07/owl#";
declare namespace skos="http://www.w3.org/2004/02/skos/core#"; 
declare namespace geo="http://www.w3.org/2003/01/geo/wgs84_pos#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace dcterms="http://purl.org/dc/terms/";
declare namespace ausohnum="http://ausonius.huma-num.fr/onto";
declare namespace spatial="http://geovocab.org/spatial#";
declare boundary-space preserve;

let $now := fn:current-dateTime()
let $currentUser := data(sm:id()//sm:username)
    
let $logs := doc('xmldb:exist:///db/apps/patrimoniumData/logs/logs-import-egyptianMaterial.xml')
let $teiTemplate := doc("xmldb:exist:///db/apps/patrimonium/data/teiEditor/docTemplates/teiTemplatePatrimoniumEgypt.xml")
let $collectionPrefix := "apcd"
let $doc-collection-path :=  "/db/apps/patrimoniumData/documents/documents-ybroux"
let $documents := collection("xmldb:exist:///db/apps/patrimoniumData/documents/documents-ybroux")
let $people := collection("xmldb:exist:///db/apps/patrimoniumData/people")
let $project-places-collection := collection("xmldb:exist:///db/apps/patrimoniumData/places/patrimonium")
let $lemmatizedCorpus := collection("xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/docYanneBroux")


return
    <keyWords>
        {for $file at $pos in $lemmatizedCorpus//file
        
        let $keywordsRaw := data($file/@keywords)
        where $keywordsRaw != ""
(:        where $pos <100:)
        return
            for $keyword in tokenize($keywordsRaw, ";")
            where $keyword != ""
            return 
                
            <keywords>{ functx:trim($keyword) }</keywords>
            
        }
        </keyWords>
    