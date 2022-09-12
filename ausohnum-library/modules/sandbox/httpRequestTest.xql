xquery version "3.1";

import module namespace hc="http://expath.org/ns/http-client";


let $url4httpRequest := xs:anyURI("https://pleiades.stoa.org/places/579885/rdf")

 let $http-request-data := <hc:request xmlns="http://expath.org/ns/http-client"
    method="get" href="{$url4httpRequest}" >
        <hc:header name="Content-Type" value="text/plain; charset=utf-8/"/>
        <!--
        <http:body media-type="application/rdf+xml"
        method="xml" encoding="utf-8"
         omit-xml-declaration="no">a</http:body>
         -->
    </hc:request>

let $request-headers :=<hc:header name="Content-Type" value="text/plain; charset=utf-8/"/>

    let $responses :=
    hc:send-request($http-request-data)
    
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
return $responses