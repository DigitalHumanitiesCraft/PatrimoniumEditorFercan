xquery version "3.1";

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
   
let $people := doc("/db/apps/patrimoniumData/people/people.xml")
let $bondTypes := doc("/db/apps/patrimoniumData/imports/fmProImports/bondTypes.xml")
let $newBonds := doc("/db/apps/patrimoniumData/imports/fmProImports/pivot-people-people.xml")
let $refs :=
(:<ref>{:)
    for $person in $people//apc:people
        let $bonds := $person//snap:hasBond
        
        return
            if(count($bonds)> 1) then 
                let $currentPersonId := substring-after($person/@rdf:about, "/people/")
                let $bondsOfCurrentPerson := $newBonds//bond[peopleId1 = $currentPersonId]
                
                let $newHasBondNodes :=
                    <nodes>
                        {
                     for $bond in $bondsOfCurrentPerson
                     let $bondCode := if($bondTypes//bondType[id = $bond/relationType/text()]/relationCode/text() != " ")
                                    then $bondTypes//bondType[id = $bond/relationType/text()]/relationCode/text()
                                    else "ERRORinType"
                     let $singleHasBond := <single>
                        <snap:hasBond rdf:type="{$bondCode}"
                     rdf:resource="https://patrimonium.huma-num.fr/people/{$bond/peopleId2/text()}"/>        </single>
                        return
                            $singleHasBond/node()
                            
                    }
                        
                    </nodes>
                
                return
                    
                
(:                    update delete $person//snap:hasBond,:)
(:                    update replace $person//snap:hasBond with text { "" },:)
(:                    update insert $newHasBondNodes/node() preceding $person//skos:note:)
                    for $bondNode at $pos in $person//snap:hasBond
                    
                        return
                            
                        switch (string($pos))
                        case "1" return
                            if ($newHasBondNodes//snap:hasBond[1] instance of element()) then
                                update replace $bondNode with $newHasBondNodes//snap:hasBond[1]
                                else update replace $bondNode with <error/>
                        case "2" return
                        if ($newHasBondNodes//snap:hasBond[2] instance of element()) then
                                update replace $bondNode with $newHasBondNodes//snap:hasBond[2]
                                else update replace $bondNode with <error/>
                        case "3" return
                            if ($newHasBondNodes//snap:hasBond[3] instance of element()) then
                                update replace $bondNode with $newHasBondNodes//snap:hasBond[3]
                                else update replace $bondNode with <error/>

                        case "4" return
                            if ($newHasBondNodes//snap:hasBond[4] instance of element()) then
                                update replace $bondNode with $newHasBondNodes//snap:hasBond[4]
                                else update replace $bondNode with <error/>
                        case "5" return
                         if ($newHasBondNodes//snap:hasBond[5] instance of element()) then
                                update replace $bondNode with $newHasBondNodes//snap:hasBond[5]
                                else update replace $bondNode with <error/>
                        case "6" return
                        update replace $bondNode with $newHasBondNodes//snap:hasBond[6]
                        case "7" return
                        update replace $bondNode with $newHasBondNodes//snap:hasBond[7]
                        case "8" return
                        update replace $bondNode with $newHasBondNodes//snap:hasBond[8]
                        case "9" return
                        update replace $bondNode with $newHasBondNodes//snap:hasBond[9]
                        case "10" return
                        update replace $bondNode with $newHasBondNodes//snap:hasBond[10]
                        case "11" return
                        update replace $bondNode with $newHasBondNodes//snap:hasBond[11]
                        case "12" return
                        update replace $bondNode with $newHasBondNodes//snap:hasBond[12]
                        case "13" return
                        update replace $bondNode with $newHasBondNodes//snap:hasBond[13]
                        case "14" return
                        update replace $bondNode with $newHasBondNodes//snap:hasBond[14]
                        case "15" return
                        update replace $bondNode with $newHasBondNodes//snap:hasBond[15]
                        default return 
                            
                        null
                    
                
            
            
            else ()
(:            update value $ptr/@target with $targetNew:)
(:     }</ref>   :)
 
return 
    $refs

