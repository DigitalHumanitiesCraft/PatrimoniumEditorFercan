
xquery version "3.1";
import module namespace functx="http://www.functx.com";
  
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare boundary-space preserve;

let $project :=request:get-parameter('project', ())
let $lang :=request:get-parameter('lang', ())

let $docs := collection("/db/apps/" || $project || "Data/documents")
let $generalIndex:= doc("/db/apps/" || $project || "Data/lists/general-index.xml")
let $appParam := doc('/db/apps/' || $project || '/data/app-general-parameters.xml')
let $thesaurus-app := $appParam//thesaurus-app/text()

let $concept-collection := collection('/db/apps/' ||  $thesaurus-app || 'Data/concepts')

let $max:= 300
let $now := fn:current-dateTime()
let $currentUser := data(sm:id()//sm:username)
(:  let $generalIndexLastUpdate :=xs:dateTime(data($generalIndex/@lastModified)) :)
let $length:= if(not(exists($max))) then 100 else $max
let $terms := $docs//tei:term
let $rs := $docs//tei:body//tei:rs
let $concepts := distinct-values((data($terms/@ref), data($rs/@ref)))
let $total:= count(($terms, $rs))
let $keywordsList := <keywordsList>
    {
    for $item in $concepts
        let $conceptId:=functx:substring-after-last($item, "/")
        let $label := if($concept-collection/id($conceptId)//skos:prefLabel[@xml:lang=$lang])
                    then $concept-collection/id($conceptId)//skos:prefLabel[@xml:lang=$lang]
                    else $concept-collection/id($conceptId)//skos:prefLabel[1]
        let $weight := count((($terms[./@ref = $item]), ($rs[./@ref = $item])))
        order by $weight descending
          return 
              if($label="") then () else
                <keyword conceptId="{ $conceptId }" conceptUri="{ $item }" weight="{ $weight }">{ $label }</keyword>
      }
    </keywordsList>
  let $updateDate := update value $generalIndex//ancestor-or-self::generalIndex/@lastUpdate with $now
  let $updateGeneralIndex :=  update replace $generalIndex//keywordsList with $keywordsList
  
  return 

  $keywordsList
