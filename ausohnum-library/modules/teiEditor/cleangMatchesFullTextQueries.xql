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
let $paramMap :=
        map {
            "method": "xml",
            "indent": false(),
            "item-separator": ""
            }

let $teiDoc := $documents/id("egydoc604")
let $originalLemma := replace("Καρανίδ(ος)",  "\[|\(|\]|\)", " ")
return
   let $matches := $teiDoc//tei:div[@type="edition"]//tei:ab[ft:query(., $originalLemma)]
                
            
            let $expandedResult := util:expand($matches, "expand-xincludes=no")
            let $resultAsString := serialize(<results>{ $expandedResult } </results>)
            
           
            
            let $resultAsString := 
                replace(
                    replace(
                    $resultAsString, '</exist:match></supplied><exist:match xmlns:exist="http://exist.sourceforge.net/NS/exist">',
                                 '</supplied>' )
                        , '</exist:match><supplied reason="lost"><exist:match xmlns:exist="http://exist.sourceforge.net/NS/exist">', '<supplied reason="lost">')
            let $resultAsString := 
(:                expan simple, without supplied:)
                replace(
                    replace(
                        replace(
                    $resultAsString
                    , '<expan><exist:match xmlns:exist="http://exist.sourceforge.net/NS/exist">', '<exist:match xmlns:exist="http://exist.sourceforge.net/NS/exist"><expan>')
                    
                    ,'</exist:match><ex><exist:match xmlns:exist="http://exist.sourceforge.net/NS/exist">',
                                 '</ex>' )
                    , '</exist:match></ex></expan>', '</ex></expan></exist:match>')
                    let $resultAsString := 
(:                expan with supplied:)
                replace(
                    replace(
                        replace(
                    $resultAsString
                    , '<expan><supplied reason="lost"><exist:match xmlns:exist="http://exist.sourceforge.net/NS/exist">', '<exist:match xmlns:exist="http://exist.sourceforge.net/NS/exist"><expan><supplied reason="lost">')
                    
                    ,'</exist:match><ex><exist:match xmlns:exist="http://exist.sourceforge.net/NS/exist">',
                                 '</ex>' )
                    , '</exist:match></ex></expan>', '</ex></expan></exist:match>')
return       
    $resultAsString