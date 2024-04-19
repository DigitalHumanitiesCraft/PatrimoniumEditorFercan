xquery version "3.1";
declare namespace skos="http://www.w3.org/2004/02/skos/core#";
declare namespace dc="http://purl.org/dc/elements/1.1/";
declare namespace dct="http://purl.org/dc/terms/";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace thot="http://thot.philo.ulg.ac.be/";
declare namespace json="http://www.json.org"; 
declare namespace functx = "http://www.functx.com"; 

(:declare option exist:serialize "method=xhtml media-type=text/html indent=yes";:)
declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=yes indent=yes";


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


let $data-collection := collection('/db/apps/thot/data/concepts') 
let $currentUser := data(sm:id()//sm:username)
let $userGroup := sm:get-user-primary-group($currentUser)
let $now := fn:current-dateTime()
let $logs := collection("/db/apps/thot/data/logs")

(: get the form data that has been "POSTed" to this XQuery :)
let $data := request:get-data()
let $schemeUri := data($data//./@rdf:about)
let $schemeNode := $data//skos:ConceptScheme
let $adminComment := $data//thot:adminComment

(:Save changes:)
let $saveAndupdateScheme := update replace $data-collection//skos:ConceptScheme[@rdf:about=$schemeUri] with $schemeNode

(:Gestion des LOGS:)

let $lognode := <thot:log type="scheme-update" when="{$now}" who='{$currentUser}' what='{$schemeUri}' scheme='{$schemeUri}'>
    {$schemeNode}
    {$adminComment}
    </thot:log>
                
let $loginjection := update insert $lognode into $logs/rdf:RDF/id('all-logs')

return null