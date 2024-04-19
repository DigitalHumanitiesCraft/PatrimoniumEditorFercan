xquery version "3.1";

import module namespace teiEditor="http://ausonius.huma-num.fr/teiEditor"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/teiEditor/teiEditorApp.xql";

import module namespace functx="http://www.functx.com";

import module namespace http="http://expath.org/ns/http-client" at "java:org.expath.exist.HttpClientModule";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $type := request:get-parameter('type', ());
declare variable $project:= request:get-parameter('project', ());
declare variable $data := request:get-data();


let $externalDocUri := "http://mama.csad.ox.ac.uk/monuments/MAMA-XI-176.html"

let $url4httpRequest := 
                    if($externalDocUri !='' ) then 
                               (if(contains($externalDocUri, 'edh-www.adw.uni-heidelberg.de/edh/inschrift/')) then
                                            $externalDocUri || ".xml"
                               else if(contains($externalDocUri, 'http://papyri.info/ddbdp')) then
                                            $externalDocUri || "/source"
                               else if(contains($externalDocUri, 'http://mama.csad.ox.ac.uk/monuments/MAMA-XI')) then
                                            (
                                            let $externalDocId := substring-before(substring-after($externalDocUri, "http://mama.csad.ox.ac.uk/monuments/"), ".html")
                                            return 
                                            "http://mama.csad.ox.ac.uk/xml/" || $externalDocId || ".xml"
                                            )
                                            else())
                            else ()





let $http-request-data := <request xmlns="http://expath.org/ns/http-client"
    method="GET" href="{$url4httpRequest}"/>
let $responses :=
    http:send-request($http-request-data)
let $response :=
    <results>
      {if ($responses[1]/@status ne '200')
         then
             <failure>{$responses[1]}</failure>
         else
           <success>
             {$responses[2]}
             {'' (: todo - use string to JSON serializer lib here :) }
           </success>
      }
    </results>
let $textDiv := $response//tei:div[@type='edition']
let $apparatusDiv := $response//tei:div[@type='apparatus']
return $apparatusDiv