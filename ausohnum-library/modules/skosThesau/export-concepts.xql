xquery version "3.1";

import module namespace functx = "http://www.functx.com" at "/db/system/repo/functx-1.0/functx/functx.xql";
(:import module namespace response "java:org.exist.xquery.functions.response.ResponseModule";:)
declare namespace dc = "http://purl.org/dc/elements/1.1/";

declare namespace periodo="http://perio.do/#";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace time = "http://www.w3.org/2006/time#";
declare option exist:serialize "method=text media-type=text/plain";

let $logs := collection('/db/apps/thot/data/logs')
let $now := fn:current-dateTime()

let $data :=  collection("/db/apps/thot/data/concepts")
let $thesaurusShortTitle := request:get-parameter('thesaurus', ())

(:let $thesaurusUri := "http://thot.philo.ulg.ac.be/thesaurus/languages/":)

let $thesaurus := $data//node()[skos:ConceptScheme[dc:title[@type='short'] = $thesaurusShortTitle]]
let $separatorValue := request:get-parameter('separator', ())

let $nl := "&#10;"
let $tab := '&#9;' (: tab :)

let $separator := switch ($separatorValue) 
   case "tab" return "&#9;"
   case "comma" return ', '
   default return ", " 

let $lang2export := request:get-parameter('lang', ())
let $langs := distinct-values($thesaurus//skos:prefLabel/@xml:lang)
let $langlist := if ($lang2export = 'all-languages') then
        (string-join(
        for $lang in $langs
                    order by $lang
                    return
        
                ($lang, $separator))
                ) 
                else ($lang2export)
                
let $dateRangeHeader :=
        if(request:get-parameter('daterange', ()) = 'daterange') then ($separator || "earliest date" || $separator || "lastest date")
        else ()
let $headerOLD := string("Thot no.") || $separator || "en" ||$separator || $lang2export ||$dateRangeHeader        
let $header := string("Thot no.") || $separator  
                || $langlist
                ||$dateRangeHeader

let $concepts := string-join(
      for $concept in $thesaurus//skos:Concept[not(ancestor-or-self::skos:exactMatch)]
            let $englishPrefLabel := if(exists($concept//skos:prefLabel[@xml:lang="en"][not(ancestor-or-self::skos:exactMatch)])) then
                replace($concept//skos:prefLabel[@xml:lang="en"][not(ancestor-or-self::skos:exactMatch)]/text(), $nl, '')
                else $concept//dc:title[@xml:lang="en"]
          
          let $prefLabels := 
                    if ($lang2export = 'all-languages') then(
                    string-join(
                    for $lang in $langs
                    order by $lang
                    return
                        normalize-space(functx:trim($concept//skos:prefLabel[@xml:lang=$lang][not(ancestor-or-self::skos:exactMatch)/text()])) || $separator
                    ))
                    else(
                        if (exists($concept//skos:prefLabel[@xml:lang=$lang2export])) then
                            (
                            $englishPrefLabel
                            ||
                            normalize-space(functx:trim($concept//skos:prefLabel[@xml:lang=$lang2export][not(ancestor-or-self::skos:exactMatch)]/text())))
                                  else ("")
                            )
    
    let $dateRange := if(exists($concept//time:hasMember) and request:get-parameter('daterange', ()) = 'daterange') then
        ($separator || $concept//time:hasMember/time:TemporalEntity[1]/periodo:earliestYear || $separator || $concept//time:hasMember/time:TemporalEntity[1]/periodo:latestYear)
        else()
            return
                (
                    data($concept/@xml:id) 
                    || $separator 
                    ||
                    $prefLabels ||
                    $dateRange
                    || $nl 
                 ), ''
                )
         
 let $fileContent :=
    $header ||
    $nl ||
    $concepts
let $filenameExt := switch ($separator)
    case "tab" return ".txt"
    case "comma" return ".csv"
    default return ".txt" 
let $filename := "thot-" || $thesaurusShortTitle 
|| "-export-" ||$separator || substring($now, 1, 10) ||'-' || replace(substring($now, 12, 5), ':', '')|| $filenameExt 

return
(:    $target-path:)
    
 
 response:stream-binary(util:string-to-binary($fileContent), "text/csv", $filename)