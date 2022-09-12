xquery version "3.1";

declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos="http://www.w3.org/2004/02/skos/core#";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "json";
declare option output:media-type "application/json";
declare option output:indent "yes";

let  $conceptCollection := collection("/db/apps/patrimonium/data/concepts")
let $query := request:get-parameter("query", "")
(:let $lang := request:get-parameter("lang", "")
let $test := request:get-parameter("test", "")
let $data-type := request:get-parameter("data-type","")
:)
(:let $conceptid:= request:get-parameter("concept", ""):)
(:let $concept:=$conceptCollection//skos:Concept[@xml:id=$conceptid]:)

return
    
    <results>
        {
        if ($conceptCollection//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][starts-with(lower-case(.), lower-case($query))]
            )
            then (
                for $match in 
                    $conceptCollection//skos:prefLabel[starts-with(lower-case(.), lower-case($query))]
                    
                  order by $match
                return
                <matching>
                    <label>{string($match)}</label>
                    <value>{string($match)}</value>
                    <id>{if($match/parent::node()/@rdf:about) then (
                    string($match/parent::node()/@rdf:about)) else(string($match/parent::node()/parent::skos:exactMatch/parent::node()/@rdf:about))}</id>
                </matching>
                )
             else (
             <matching>
                    <label>No matching</label>
                    <value>No matching!</value>
                    <id>0</id>
                    </matching>)}
       </results>
    
    