xquery version "3.1";
module namespace zoteroPlugin="http://ausonius.huma-num.fr/zoteroPlugin";

import module namespace hc="http://expath.org/ns/http-client" at "java:org.expath.exist.HttpClientModule";

declare function zoteroPlugin:get-bibItem($zoteroGroup as xs:string, $zoteroItemId as xs:string, $format as xs:string){

    let $headerTeiBibRef := <headers><header name="content" value="{$format}"/>
                                            </headers>
    let $urlTeiBibRef :=
                if(starts-with($zoteroItemId, "http") ) then $zoteroItemId
                else "https://api.zotero.org/groups/" || $zoteroGroup ||"/items/" || $zoteroItemId 
                    || "?format=" || $format
    
    let $url4httpRequest := "https://api.zotero.org/groups/" || $zoteroGroup ||"/items/" || $zoteroItemId 
                    || "?format=" || $format

let $http-request-data := <request xmlns="http://expath.org/ns/http-client"
method="GET" href="{$url4httpRequest}"/>

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
return $response
    
};
declare function zoteroPlugin:get-zoteroItem($zoteroGroup as xs:string, $zoteroItemId as xs:string, $format as xs:string){

(:    let $headerTeiBibRef := <headers><header name="content" value="{$format}"/></headers>:)
    let $urlTeiBibRef := "https://api.zotero.org/groups/" || $zoteroGroup ||"/items/" || $zoteroItemId 
                    || "?format=" || $format
    
    let $url4httpRequest := "https://api.zotero.org/groups/" || $zoteroGroup ||"/items/" || $zoteroItemId 
                    || "?format=" || $format 

let $http-request-data := <request xmlns="http://expath.org/ns/http-client"
method="GET" href="{$url4httpRequest}"/>



                let $responses :=hc:send-request($http-request-data)
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
          
          
(:let $response := hc:get(xs:anyURI($url4httpRequest), true(), (), ())          :)
          
          return $response
    
    
    
    
    
    
    
    
    
    (:let $teiBibRef := httpclient:get(xs:anyURI($urlTeiBibRef), true(), $headerTeiBibRef)
        return
           $teiBibRef/httpclient:body:)
};

