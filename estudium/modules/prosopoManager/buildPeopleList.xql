xquery version "3.1";


import module namespace functx="http://www.functx.com";
declare namespace json="http://www.json.org";

declare namespace apc="https://ausohnum.huma-num.fr/apps/eStudium/onto#";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace dct = "http://purl.org/dc/terms/";
declare namespace dcterms="http://purl.org/dc/terms/";
declare namespace ev = "http://www.w3.org/2001/xml-events";
declare namespace geo = "http://www.w3.org/2003/01/geo/wgs84_pos#";
declare namespace http="http://expath.org/ns/http-client";

declare namespace lawd="http://lawd.info/ontology/";
declare namespace owl="http://www.w3.org/2002/07/owl#";
declare namespace pleiades="https://pleiades.stoa.org/places/vocab#";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfs = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace snap="http://onto.snapdrgn.net/snap#";
declare namespace spatial="http://geovocab.org/spatial#";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace thot = "http://thot.philo.ulg.ac.be/";
declare namespace xf = "http://www.w3.org/2002/xforms";
declare namespace local = "local";


(:declare option exist:serialize "method=xml media-type=xml";:)

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare boundary-space preserve;

(:declare option output:indent "yes";
declare option output:method "xml";
declare option output:media-type "xml";
declare option output:json-ignore-whitespace-text-nodes "yes";:)
declare option exist:serialize "method=json media-type=application/javascript";
declare variable $project :=request:get-parameter('project', "");
declare variable $lang :="en"(:request:get-parameter('lang', ""):);
declare variable $thesaurus-app  := doc('/db/apps/' || $project || '/data/app-general-parameters.xml')//thesaurus-app/text();
declare variable $conceptCollection := collection('/db/apps/'|| $thesaurus-app || "Data/concepts");

declare variable $peopleCollection := collection("/db/apps/" || $project || "Data/people");

declare function local:getLabelFromConcept($conceptUri as xs:string?, $lang as xs:string){
    try {
        let $concept := $conceptCollection//skos:Concept[@rdf:about = $conceptUri]
        let $prefLabelCurrentLang := $concept//skos:prefLabel[@xml:lang=$lang]/text()
        let $label := if( $prefLabelCurrentLang != "") then $prefLabelCurrentLang
            else functx:if-empty($concept//skos:prefLabel[1]/text(),"No preferred label")
            
        return functx:capitalize-first(normalize-space($label))
    
    }
    catch * { " "}
};



let $newList := 
<root xmlns:json="http://www.json.org">{
  for $person in $peopleCollection//lawd:person[@rdf:about != ""]
      let $name := $person//lawd:personalName[1]/text()
      let $uri := $person/@rdf:about
      let $id := substring-before(functx:substring-after-last($uri, "/"), "#")
      
      let $sex := local:getLabelFromConcept($person//apc:sex/@rdf:resource, $lang)
      
      let $exactMatches :=
               for $exactMatch in $person//skos:exactMatch return 
                        '<a href="' || data($exactMatch/@rdf:resource) || '" target="about" class="label label-primary labelInTable" title="Open record in new tab" 
                style="">' || "TM:" || functx:substring-after-last($exactMatch/@rdf:resource, "/") || '</a>'
      let $personFunctions :=
            for $function in distinct-values(data($person//apc:hasFunction/@rdf:resource))
                return 
                '<span temphref="' || $function || '" target="about" title="Open record in new tab" class="label label-primary labelInTable">' || local:getLabelFromConcept($function, $lang) || '</span>'
      let $personalStatus := if($person//apc:personalStatus/@rdf:resource != "") then local:getLabelFromConcept($person//apc:personalStatus/@rdf:resource, $lang) else " "
      let $socialStatus := if($person//apc:socialStatus/@rdf:resource != "") then local:getLabelFromConcept($person//apc:socialStatus/@rdf:resource, $lang) else " "
      let $juridicalStatus := if($person//apc:juridicalStatus/@rdf:resource != "") then local:getLabelFromConcept($person//apc:juridicalStatus/@rdf:resource, $lang) else " "
      let $biblio := for $ref in $person//lawd:Citation[@type = "apcDocument"]
                        return
                            <a href="{ $ref/@rdf:resource }" target="_blank" class="labelInTable label label-primary">{ substring-after($ref/@rdf:resource, "documents/")}</a>
(:                            if($ref/@type = "apcDocument"):)
(:                                then <a href="{ $ref/@rdf:resource }" target="_blank" class="labelInTable label label-primary">{ substring-after($ref/@rdf:resource, "documents/")}</a>:)
(:                                else  <span class="labelInTable label label-primary">{ $ref/text() }</span>:)
      let $dataNode := <dataNode>    <data json:array="true">
                <id>{ $id }</id>
                <name>{ functx:if-empty($name, " ") }</name>
                <sex>{ if($sex != "") then functx:capitalize-first($sex) else " "}</sex>
                <personalStatus>{ $personalStatus }</personalStatus>
                <personalStatusUri>{ data($person//apc:personalStatus/@rdf:resource) }</personalStatusUri>
                <citizenship>{ $juridicalStatus }</citizenship>
                <citizenshipUri>{ data($person//apc:juridicalStatus/@rdf:resource) }</citizenshipUri>
                <socialStatus>{ $socialStatus }</socialStatus>
                <socialStatusUri>{ data($person//apc:socialStatus/@rdf:resource) }</socialStatusUri>
                <functions>{ if(data($personFunctions) != "") then $personFunctions else " "}</functions>
                <exactMatch>{if($exactMatches != "") then $exactMatches else " "}</exactMatch>
                <temporalRangeStart>{ functx:if-empty($person//snap:associatedDate/@notBefore/string(), " ") }</temporalRangeStart>
                <temporalRangeEnd>{ functx:if-empty($person//snap:associatedDate/@notAfter/string(), " ") }</temporalRangeEnd>
                <biblio>{ serialize($biblio) }</biblio>
          </data>
    </dataNode>
      order by $name
 return $dataNode/node()
      }</root>
                 
let $list := doc("/db/apps/" || $project || "Data/lists/list-people.xml")
let $updateList := update replace $list/peopleList/root with $newList
let $updateDate :=
        update value $list/peopleList/@lastUpdate with fn:current-dateTime()
let $updateDocNumber := update value $list/peopleList/@documentsNumber with count($peopleCollection//lawd:person[@rdf:about != ""])


return
<response status="ok">
            <message>List of people updated for project { $project }</message>
</response>