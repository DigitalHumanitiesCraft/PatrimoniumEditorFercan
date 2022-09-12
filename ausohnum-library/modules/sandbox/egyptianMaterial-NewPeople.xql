xquery version "3.1";

module namespace importTM="http://ausonius.huma-num.fr/importTM";

import module namespace functx="http://www.functx.com";
(:import module util="http://exist-db.org/xquery/util" ;:)
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization"; 
declare namespace prod = "http://datypic.com/prod"; 

declare namespace apc="http://patrimonium.huma-num.fr/onto#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace snap="http://onto.snapdrgn.net/snap#";
declare namespace skos="http://www.w3.org/2004/02/skos/core#";
declare boundary-space preserve;

declare option output:method "xml"; 
declare option output:indent "yes"; 

declare variable $importTM:provPeople := doc("/db/apps/patrimoniumData/egyptianMaterial/meta/peopleProv4import.xml");
declare variable $importTM:projectdata-path := "xmldb:exist:///db/apps/patrimoniumData/";
declare function importTM:getApcNo($tmNo as xs:string?){
(:    Return tmNo if no apcNo:)


    if(data($importTM:provPeople//person[./@tm = $tmNo]/@apc) != "") then data($importTM:provPeople//person[./@tm = $tmNo]/@apc)    
    else $tmNo
};

declare function importTM:buildPeople($indexStart as xs:int?, $indexEnd as xs:int?){
let $now := fn:current-dateTime()
let $currentUser := data(sm:id()//sm:username)
    
let $logs := doc('xmldb:exist:///db/apps/patrimoniumData/logs/logs-import-egyptianMaterial.xml')
let $teiTemplate := doc("xmldb:exist:///db/apps/patrimonium/data/teiEditor/docTemplates/teiTemplatePatrimoniumEgypt.xml")
let $collectionPrefix := "apcd"

let $doc-collection-path := "xmldb:exist:///db/apps/patrimoniumData/documents/documents-ybroux"


let $project := "patrimonium"
let $baseUri := "https://patrimonium.huma-num.fr"
let $peopleImportFile := util:binary-to-string(util:binary-doc("xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/meta/people.txt"))
let $peopleImport := tokenize($peopleImportFile, '\r')
(:let $bondsImportFile := util:binary-to-string(util:binary-doc("xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/meta/PerRelations.csv")):)
let $bonds := doc("/db/apps/patrimoniumData/egyptianMaterial/meta/bonds.xml")
let $apcpeople := collection("/db/apps/patrimoniumData/people")
let $provPeople := doc("/db/apps/patrimoniumData/egyptianMaterial/meta/peopleProv4import.xml")


(:let $peopleNumberList := for $people in $apcpeople//apc:people:)
(:        return:)
(:            <item>:)
(:            {functx:substring-after-last($people/@rdf:about, "/" )}:)
(:            </item>:)
(:        let $personIdPrefix := doc("/db/apps/" || $project || "/data/app-general-parameters.xml")//idPrefix[@type='people']/text():)
(:        let $last-id:= fn:max($peopleNumberList):)
(:        :)
(::)
(:let $provPeopleForUris:=:)
(:    <provPeople>{:)
(:    for $person at $pos in $peopleImport:)
(:        :)
(:        let $newId := fn:sum(($last-id, 1)):)
(:        let $newUri := $baseUri|| "/" || "people" || "/" || fn:sum(($last-id, $pos)):)
(:         let $personDetails := tokenize($person, '","'):)
(:        let $tmNo := substring-after($personDetails[1], '"'):)
(:        return:)
(:            <person tm="{ $tmNo }" apc="{ $newUri }"/>}:)
(:    </provPeople>:)
(::)

return
    
    
    <rdf:RDF 
        xmlns:apc="http://patrimonium.huma-num.fr/onto#"
        xmlns:lawd="http://lawd.info/ontology/"
        xmlns:pleiades="https://pleiades.stoa.org/places/vocab#"
        xmlns:dcterms="http://purl.org/dc/terms/"
        xmlns:foaf="http://xmlns.com/foaf/0.1/"
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"         
        xmlns:skos="http://www.w3.org/2004/02/skos/core#"
        xmlns:snap="http://onto.snapdrgn.net/snap#" >
{
(:    for $person at $pos in $peopleImport[$index]:)
    for $person at $pos in $peopleImport
        where $pos >= $indexStart and $pos <= $indexEnd
(:        let $peopleNumberList := for $people in $apcpeople//apc:people:)
(:        return:)
(:            <item>:)
(:            {functx:substring-after-last($people/@rdf:about, "/" )}:)
(:            </item>:)
(:        let $personIdPrefix := doc("/db/apps/" || $project || "/data/app-general-parameters.xml")//idPrefix[@type='people']/text():)
(:        let $last-id:= fn:max($peopleNumberList):)
(:        let $newId := fn:sum(($last-id, 1)):)
(:        let $newUri := $baseUri|| "/" || "people" || "/" || fn:sum(($last-id, $pos)):)
        
        let $personDetails := tokenize($person, '","')
        let $tmNo := substring-after($personDetails[1], '"')
        let $newUri := $provPeople//person[./@tm = $tmNo]/@apc
        let $sex := switch(substring-before($personDetails[3], '"'))
                        case ("Man") return "Male"
                        case("Woman") return "Female"
                        case ("Unknown") return "Sex undeterminable"
                        default return (substring-before($personDetails[3], '"'))
        let $standardizedName := if(contains($personDetails[2], "..."))
                                then (
                                    switch($sex)
                                        case("Male") return "Ignotus"
                                        case("Female") return "Ignota"
                                        default return $personDetails[2])
                                else $personDetails[2]
        let $sexUri := switch($sex)
                        case ("Male") return "https://ausohnum.huma-num.fr/concept/c23492"
                        case("Female") return "https://ausohnum.huma-num.fr/concept/c23491"
                        case ("Sex undeterminable") return "https://ausohnum.huma-num.fr/concept/c23493"
                        default return ()
        let $personalStatus := ""
        let $socialStatus:= ""
        let $juridicalStatus := ""
        let $personalStatusUri := ""
        let $socialStatusUri := ""
        let $juridicalStatusUri := ""
        
        let $hasBonds := $bonds//bond[matches(./@person, $tmNo)]
        let $isFatherOf := importTM:getApcNo($bonds//bond[matches(./@father, $tmNo)][1]/@person)
        let $isMotherOf := importTM:getApcNo($bonds//bond[matches(./@mother, $tmNo)][1]/@person)
        let $isMasterOf := importTM:getApcNo($bonds//bond[matches(./@master, $tmNo)][1]/@person)                            
        let $isSpouse1Of := importTM:getApcNo($bonds//bond[matches(./@spouse1, $tmNo)][1]/@person)
        let $isSpouse2Of := importTM:getApcNo($bonds//bond[matches(./@spouse2, $tmNo)][1]/@person)
let $newPersonRecord :=<person>
<lawd:person rdf:about="{$newUri}#this">
    <skos:exactMatch rdf:resource="{ $tmNo }"/>
     <foaf:primaryTopicOf>
        <apc:people rdf:about="{$newUri}">
            <lawd:personalName xml:lang="en">{ $standardizedName }</lawd:personalName>
            <apc:sex rdf:resource="{ $sexUri }">{ $sex }</apc:sex>
            {
            if ($personalStatusUri != "") then <apc:personalStatus rdf:resource="{ $personalStatusUri }">{ $personalStatus }</apc:personalStatus>
            else <apc:personalStatus rdf:resource=""/>
            }
            {
            if ($socialStatusUri != "") then <apc:socialStatus rdf:resource="{ $socialStatusUri }">{ $socialStatus }</apc:socialStatus>
            else <apc:socialStatus rdf:resource=""/>
            }
            {
            if ($juridicalStatusUri != "") then <apc:juridicalStatus rdf:resource="{ $juridicalStatusUri }">{ $juridicalStatus }</apc:juridicalStatus>
            else <apc:juridicalStatus rdf:resource=""/>
            }{
            if($hasBonds/@father != "") then
                <snap:hasBond rdf:type="ChildOf" rdf:resource="{ importTM:getApcNo($hasBonds[1]/@father)}"/>
                else()}{
            if($hasBonds/@mother != "") then
                <snap:hasBond rdf:type="ChildOf" rdf:resource="{importTM:getApcNo($hasBonds[1]/@mother)}"/>
                else()}{
            if($hasBonds/@master != "") then
                <snap:hasBond rdf:type="SlaveOf" rdf:resource="{importTM:getApcNo($hasBonds[1]/@master)}"/>
                else()}{
            if($hasBonds/@spouse1 != "") then
                <snap:hasBond rdf:type="SpouseOf" rdf:resource="{importTM:getApcNo($hasBonds[1]/@spouse1)}"/>
                else()}{
            if($hasBonds/@spouse2 != "") then
                <snap:hasBond rdf:type="SpouseOf" rdf:resource="{importTM:getApcNo($hasBonds[1]/@spouse2)}"/>
                else()}{
            if($isFatherOf != "") then
                <snap:hasBond rdf:type="FatherOf" rdf:resource="{$isFatherOf}"/>
                else()}{
            if($isMotherOf != "") then
                <snap:hasBond rdf:type="MotherOf" rdf:resource="{$isMotherOf}"/>
                else()}{
            if($isMasterOf != "") then
                <snap:hasBond rdf:type="MasterOf" rdf:resource="{$isMasterOf}"/>
                else()}{
            if($isSpouse1Of != "") then
                <snap:hasBond rdf:type="SpouseOf" rdf:resource="{$isSpouse1Of}"/>
                else()}{
            if($isSpouse2Of != "") then
                <snap:hasBond rdf:type="SpouseOf" rdf:resource="{$isSpouse2Of}"/>
                else()}
            <skos:note/>
         </apc:people>
             <skos:note type="private"/>
    </foaf:primaryTopicOf>
</lawd:person></person>
return
$newPersonRecord/node()
    }
</rdf:RDF> 
};

declare function importTM:createPeopleFile($newPeople, $indexStart, $indexEnd){
  let $now := fn:current-dateTime()
  return
    xmldb:store($importTM:projectdata-path || "egyptianMaterial/meta/people/",
            "peopleEgypt-no-" || $indexStart || "-to-" || $indexEnd || "-"
            || substring(replace($now, ":", "-"), 1, 16) || ".xml", $newPeople)
};