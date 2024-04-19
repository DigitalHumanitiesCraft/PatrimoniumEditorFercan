xquery version "3.1";

(:import module namespace xqjson="http://xqilla.sourceforge.net/lib/xqjson";:)
import module namespace login="http://exist-db.org/xquery/login" at "resource:org/exist/xquery/modules/persistentlogin/login.xql";
(:import module namespace app="http://thot.philo.ulg.ac.be/templates" at "app.xql";:)

import module namespace config="https://ausohnum.huma-num.fr/apps/eStudium/config" at "../config.xqm";
import module namespace functx="http://www.functx.com";

declare namespace json="http://www.json.org";
declare namespace skos="http://www.w3.org/2004/02/skos/core#";
declare namespace dc="http://purl.org/dc/elements/1.1/";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";


declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
(:declare option output:method "xml";
declare option output:media-type "text/xml";
:)
declare option output:method "json";
declare option output:media-type "application/json";
declare option output:indent "yes";

declare variable $lang:= request:get-parameter('lang', 'en');
declare variable $access:= request:get-parameter('access', '');

declare variable $appParamaters := doc("/db/apps/" || $config:project || "/data/app-general-parameters.xml");

declare variable $thesBaseUri := $appParamaters//uriBase[@type="thesaurus"]/text() ;
declare variable $thesaurus-app := $appParamaters//thesaurus-app/text();
declare variable $data-collection := collection('/db/apps/' || $thesaurus-app || 'Data/concepts');
(:declare variable $user := request:get-attribute($config:login-domain || ".user");:)
(:declare variable $user := request:get-attribute("thot.philo.ulg.ac.be" || ".user");:)

(: declare variable $user := login:set-user($config:login-domain, (), false()); :)
(: declare variable $hasaccess := sm:has-access (xs:anyURI('/db/apps/thot/modules/4access.xql') , 'r-x'); :)


declare function local:nodes($nodes, $visited, $renderingOrder){


            for $childnodes in $nodes except $visited
                let $uri := substring-after($childnodes/@rdf:resource, "/apc/concept/")
                let $ntSkosConcept :=
                    $data-collection/id($uri)

                (:let $ntSkosConceptz := $ntSkosConceptAll/.[thot:admin/@status='published']:)

                let $order := data($ntSkosConcept/node()/@ype)
                let $status := data($ntSkosConcept//@status)
                let $user := request:get-attribute($config:login-domain || ".user")
                order by
                    if ($renderingOrder = "ordered") then reverse($childnodes)
                    else (
                    $ntSkosConcept/skos:prefLabel[@xml:lang=$lang]/text()
                    )

            return

             if($status='published') then(
                if ($ntSkosConcept//skos:narrower)
                  then(
                       <children json:array="true" status="{data($ntSkosConcept//@status)}" type="collectionItem">
                                <title>{if ($ntSkosConcept/name() ='skos:Collection')then(concat('&#60;', ' ')) else('')}
                                {functx:capitalize-first($ntSkosConcept/skos:prefLabel[@xml:lang=$lang]/text())}
                                {functx:capitalize-first($ntSkosConcept/dc:title[1]/text())}
                                {if ($ntSkosConcept/name() ='skos:Collection')then(concat(' ', '&#62;')) else('')}
                                </title>
                                <id>{data($ntSkosConcept/@xml:id)}</id>
                                <key>{data($ntSkosConcept/@xml:id)}</key>
                                <lang>{$lang}</lang>
                                <isFolder>true</isFolder>
                                {local:nodes($ntSkosConcept//skos:narrower, ($visited, $childnodes), data($ntSkosConcept/@type))}
                        </children>
                    )
                    else
                    (
                    <children json:array="false" status="{data($ntSkosConcept//@status)}" type="collectionItem">
                        <title>
                        {if(exists($ntSkosConcept/skos:prefLabel[@xml:lang=$lang])) then
                                (
                                concat(functx:capitalize-first($ntSkosConcept/skos:prefLabel[@xml:lang=$lang]/text()),
                                functx:capitalize-first($ntSkosConcept/dc:title/text()))
                                )else
                                (concat(functx:capitalize-first($ntSkosConcept/skos:prefLabel[@xml:lang='en']/text()),
                                functx:capitalize-first($ntSkosConcept/dc:title[1]/text())))
                                }
                        </title>
                        <id>{data($ntSkosConcept/@xml:id)}</id>
                        <key>{data($ntSkosConcept/@xml:id)}</key>
                        <lang>{$lang}</lang>
                    </children>
                    )
           )
        else(
        
       
)
};


declare function local:build-root($rootNodes){
(:            let $children :=xmldb:get-child-collections($rootNodes):)

                        for $child in $rootNodes

                        let $nts := $child//skos:narrower
                        let $order :=data($child/@type)
                        order by
                              $child/skos:prefLabel[@xml:lang=$lang]/text()

                      return

                      <children json:array="true" status="{data($child//@status)}" type="collectionItem">
                         <title>{functx:capitalize-first($child/skos:prefLabel[@xml:lang=$lang]/text())}</title>
                         <id>{data($child/@xml:id)}</id>
                         <key>{data($child/@xml:id)}</key>
                         <lang>{$lang}</lang>

                         <isFolder>true</isFolder>
                         {local:nodes($nts, (), data($child/@type))}
                      </children>

};



let $topConceptsURI :=
(:let $user := request:get-attribute($config:login-domain || ".user")
return:)
(
(:   login:set-user($config:login-domain, 'thot.philo.ulg.ac.be', (), false()), :)
(:        if (sm:has-access (xs:anyURI('/db/apps/thot/modules/4access.xql') , 'r-x' )) then:)

(:          if ($user) then:)
if ($access = 'private-thot') then
            (
            for $tcs in $data-collection//skos:ConceptScheme[@rdf:about[starts-with(., $thesBaseUri)]]
                return
                    $tcs//skos:hasTopConcept/@rdf:resource
            )
        else
            (
            for $tcs in $data-collection//skos:ConceptScheme[node()/@status='published'][@rdf:about[starts-with(., $thesBaseUri)]]
            return
                $tcs//skos:hasTopConcept/@rdf:resource
            )
 )

let $topConceptNode := $data-collection/id("c22031")

let $rootNodes :=
    for $uri in $topConceptsURI
    return
        $data-collection/id(substring-after($uri, "/concept/"))



return
     <children xmlns:json="http://www.json.org" json:array="true">
                     <title>APC Thesaurus from { $thesaurus-app }z{ data($topConceptsURI)}y</title>
                     <key>apc-thesaurus</key>

                     <isFolder>true</isFolder>
                     <orderedCollection json:literal="true">true</orderedCollection>
                            <lang>{$lang}</lang>
                        {local:build-root($topConceptNode)}
    </children>
