xquery version "3.1";

declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos="http://www.w3.org/2004/02/skos/core#";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "json";
declare option output:media-type "application/json";
declare option output:indent "yes";

let $query := request:get-parameter("query", "Please start to enter a term")
let $query-type := request:get-parameter("query-type", "")
let $lang := request:get-parameter("lang", "")
let $project := request:get-parameter("project", "")
let $data-type := request:get-parameter("data-type","")
let $currentConceptId := request:get-parameter("currentConceptIdBis", "")


let  $conceptCollection := collection('/db/apps/' || $project || 'Data/concepts')

(:let $conceptid:= request:get-parameter("concept", "")
let $concept:=$conceptCollection//skos:Concept[@xml:id=$conceptid]
:)
return
switch($query-type)
    case "startswith"
    
return
    <data>
    <when>{fn:current-dateTime()}</when>
    <list>
        {for $match in subsequence($conceptCollection//skos:prefLabel[starts-with(lower-case(.), lower-case($query))]|$conceptCollection//dc:title[starts-with(lower-case(.), lower-case($query))], 1, 20)
        
        return
        <matching>
            <label>{$match/text()}</label>
            <value>{$match/text()}</value>
            <id>{$match/parent::node()/@rdf:about/string()}</id>
        </matching>}
        </list>
    </data>
    
    case "startswithinscheme" return
        let $schemeUri := data($conceptCollection/id($currentConceptId)//skos:inScheme/@rdf:resource)
        let $schemeCollection := $conceptCollection//.[skos:inScheme[@rdf:resource=$schemeUri]]
        return
                <data>
                <when>{fn:current-dateTime()}</when>
                 <list>
                     <matching>
                          <label>Adding NT to { $currentConceptId } - search for "{ $query }" in schemme "{ $schemeUri }" matches {count($schemeCollection//skos:prefLabel[starts-with(lower-case(.), lower-case($query))])} Concept{if (count($schemeCollection//skos:prefLabel[starts-with(lower-case(.), lower-case($query))]) >1) then "s" else()}</label>
                          <id>URI</id>
                          </matching>
                      {for $match in subsequence($schemeCollection//skos:prefLabel[starts-with(lower-case(.), lower-case($query))]
                      |
                      $schemeCollection//skos:altLabel[starts-with(lower-case(.), lower-case($query))]
                      , 1, 20
                      )
                      
                      return
                      <matching>
                          <label>{data($match)}</label>
                          <value>{$match/text()}</value>
                          <id>{data($match/parent::node()/@rdf:about)}</id>
                      </matching>}
                 </list>
             </data>
             
    default return null