xquery version "3.1";

import module namespace config="https://ausohnum.huma-num.fr/apps/eStudium/config" at "../config.xqm";

declare namespace apc="https://ausohnum.huma-num.fr/apps/eStudium/onto#";
declare namespace skos="http://www.w3.org/2004/02/skos/core#";
declare namespace dc="http://purl.org/dc/elements/1.1/";
declare namespace dct="http://purl.org/dc/terms/";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/";
declare namespace json="http://www.json.org"; 
declare namespace functx = "http://www.functx.com"; 

declare variable $appVariables := doc($config:data-root || '/app-general-parameters.xml');

(:declare option exist:serialize "method=xhtml media-type=text/html indent=yes";:)

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

let $data-collection := collection($config:data-collection || '/concepts')
let $logs := collection($config:data-collection || '/logs')
let $baseUri := $appVariables//uriBase/text()
let $idPrefix := $appVariables//idPrefix[@type='concept']/text()

let $currentUser := data(sm:id()//sm:username)
(:let $userGroup := sm:get-user-primary-group($currentUser):)
let $data := request:get-data()
let $nodeLabel := data($data//@nodeLabel)
(:let $orderedCollection := data($data//@type):)
(:let $conceptNode := $data/skos:Concept/node():)
 
let $idList := for $id in $data-collection//.[contains(./@xml:id, $idPrefix)]
        return
        <item>
        {substring-after($id/@xml:id, $idPrefix)}
        </item>
 
 let $last-id:= fn:max($idList)
(: let $increment-id := fn:sum($last-id, '1'):)
let $newId := $idPrefix || fn:sum(($last-id, 1))

  let $xsl := xs:anyURI($appVariables//uriBase/text() || "/modules/skosThesau/concept-clean-new.xsl")
  let $param :=
        <parameters>
            <param name="newId" value="{$newId}"/>
            <param name="baseURI" value="{$baseUri}/apc/concept/"/>
        </parameters>
let $data-with-removed-empty :=transform:transform($data, $xsl, ($param))

let $BTID := functx:substring-after-last(data($data-with-removed-empty/skos:broader/@rdf:resource), '/')

let $scheme := $data-with-removed-empty//skos:inScheme/@rdf:resource/string()

let $logInjection:= update insert <skosThesau:log type='concept-creation' when='{$now}' what="{$newId}" who='{$currentUser}' scheme='{$scheme}'>dee</skosThesau:log> into $logs/rdf:RDF/id('all-logs')
               
               
let $createConcept := update insert $data-with-removed-empty into $data-collection//rdf:RDF[node()/@xml:id=$BTID]

let $addNewConceptAsNT := 
            for $child in $data-with-removed-empty//skos:broader
                let $BTID := substring-after($child/@rdf:resource, '/apc/concept/')
                return
                (if(exists($data-collection//node()[@xml:id=$BTID]/skos:narrower)) then(
                update insert <skos:narrower rdf:resource="{$data-with-removed-empty/@rdf:about}"/> 
                    following $data-collection//node()[@xml:id=$BTID]/skos:narrower[last()]
                    )else (
                    update insert <skos:narrower rdf:resource="{$data-with-removed-empty/@rdf:about}"/> 
                    into $data-collection//node()[@xml:id=$BTID]
                    )
                )
                

let $addNewConceptAsBTofNT :=
            for $child in $data-with-removed-empty//skos:narrower
            let $ntId := substring-after($child/@rdf:resource, '/apc/concept/')
            return
            update insert <skos:broader rdf:resource="{$data-with-removed-empty//@rdf:about}"/>
                following $data-collection//node()[@xml:id = $ntId]//skos:broader


                                (:let $logInjection:= update insert <thot:log type='concept-creation' when='{$now}' what="{data($data-with-removed-empty/@xml:id)}" who='{$currentUser}'>
                                                    {$data-with-removed-empty /thot:adminComment/text()}
                                               </thot:log> into $logs/rdf:RDF[@xml:id='all-logs']
                                :)


return 
    null


