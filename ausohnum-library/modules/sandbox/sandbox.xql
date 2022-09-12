xquery version "3.1";

import module namespace importTM="http://ausonius.huma-num.fr/importTM" at "./egyptianMaterial-NewPeople.xql";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";


(:importTM:getApcNo("https://www.trismegistos.org/person/120317"):)
   let $indexStart := 10001
   let $indexEnd := 30000
   let $newPeople := importTM:buildPeople($indexStart, $indexEnd)
   
   let $logPeople := console:log($newPeople)
   return(
       $newPeople
       ,
   importTM:createPeopleFile($newPeople, $indexStart, $indexEnd)
)

(:   let $changeMod := sm:chmod(xs:anyURI(concat($doc-collection-path, "/", $filename)), "rw-rw-r--"):)
(:   let $changeGroup := sm:chgrp(xs:anyURI(concat($doc-collection-path, "/", $filename)), "documents-ybroux"):)
  
  
(: let $tmNo := "https://www.trismegistos.org/person/120317":)
(: let  $provPeople := doc("/db/apps/patrimoniumData/egyptianMaterial/meta/peopleProv4import.xml"):)
(:return:)
(:    if(data($provPeople//person[./@tm = $tmNo]/@apc) != "") then data($provPeople//person[./@tm = $tmNo]/@apc)    :)
(:    else $tmNo:)