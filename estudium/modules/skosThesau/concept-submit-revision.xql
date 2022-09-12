xquery version "3.1";
declare namespace skos="http://www.w3.org/2004/02/skos/core#";
declare namespace dc="http://purl.org/dc/elements/1.1/";
declare namespace dct="http://purl.org/dc/terms/";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace thot="http://thot.philo.ulg.ac.be/";
declare namespace json="http://www.json.org"; 
declare namespace functx = "http://www.functx.com"; 

declare option exist:serialize "method=xhtml media-type=text/html indent=yes";


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

let $input := collection("/db/apps/thot/data/concepts")
let $data := request:get-data()
let $data-collection := collection("/db/apps/thot/data/requests")
let $now := fn:current-dateTime()
let $user := data(sm:id()//sm:username)
let $thotPeople := sm:get-group-members('thot')
let $logs := collection("/db/apps/thot/data/logs")

let $updatedConcept:= $data//thot:xfinstance[@type='update']/*[self::skos:Concept or self::skos:Collection]
let $schemeURI := data($updatedConcept/skos:inScheme/@rdf:resource)
let $conceptId := data($updatedConcept/@xml:id)

let $schemeEditors := $input//rdf:RDF/skos:ConceptScheme[@rdf:about=$updatedConcept/skos:inScheme/@rdf:resource]//dc:creator[@role='editor']/@ref/string()


let $idList := for $id in $data-collection//thot:request
       return
       <item>
       {substring-after($id/@xml:id, 'request-')}
       </item>

let $last-id:= fn:max($idList)
let $newId := concat('request-', fn:sum(($last-id, 1)))
let $request :=

  <thot:request scheme="{$schemeURI}" object="{$conceptId}" creator="{$user}"
  assignee="{$schemeEditors}"
  created="{$now}" priority="major"
   status="revision-new" xml:id="{$newId}">
    <dc:title>Suggestion of revision</dc:title>
    <description>{$data//thot:xfinstance[@type='admin']/thot:adminComment/text()}</description>
    
 {$updatedConcept}
    
  </thot:request>


let $storeNewRequest := xmldb:store("/db/apps/thot/data/requests", concat($newId, '.xml'), $request)

let $lognode := <thot:log type="revision-submission" when="{$now}" who='{$user}' what='{$conceptId}' scheme='{$schemeURI}'>
    {$request}
    </thot:log>
let $loginjection := update insert $lognode into $logs/rdf:RDF/id('all-logs')

return

<response>
    <code>200</code>
    <message>Request created</message>
</response>