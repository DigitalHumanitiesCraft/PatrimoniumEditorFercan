xquery version "3.1";
import module namespace functx="http://www.functx.com";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare boundary-space preserve;


let $docs := collection("/db/apps/patrimoniumData/documents/documents-ybroux")

return
    <results>{
    for $node in $docs//tei:listPerson
        let $teiDoc := root($node)
        let $newNode :=<node>
        <particDesc>
            { $node }
        </particDesc>
</node>
        let $updateNode :=
           update insert
                            ('&#xD;&#xa;',
                            functx:change-element-ns-deep($newNode, "http://www.tei-c.org/ns/1.0", "")/node())
                              into $teiDoc//tei:profileDesc 
        
        
         let $changeNode := <node>
           <change when="{ fn:current-dateTime() }" who="http://ausohnum.huma-num.fr/people/vrazanajao">Moved listPerson into particDesc</change></node>
         let $changeNodeRev := <node>
    <revisionDesc>
        <listChange>
           <change when="{ fn:current-dateTime() }" who="http://ausohnum.huma-num.fr/people/vrazanajao">Moved listPerson into particDesc</change>
       </listChange>
   </revisionDesc></node>
       
          let $insertRevisionChange :=
                if(not(exists($teiDoc//tei:listChange))) then
                    update insert
                            ('&#xD;&#xa;',
                            functx:change-element-ns-deep($changeNodeRev, "http://www.tei-c.org/ns/1.0", "")/node())
                              into $teiDoc//tei:teiHeader 
                   else  if($teiDoc//tei:change[contains(@when, "2022-02-25")]) then ()
                   else
                            update insert
                            ('&#xD;&#xa;',
                            functx:change-element-ns-deep($changeNode, "http://www.tei-c.org/ns/1.0", "")/node())
                              following $teiDoc//tei:revisionDesc/tei:listChange/tei:change[last()]
     
        let $deleteNode:= update delete $node
        return $teiDoc//ancestor-or-self::tei:TEI/@xml:id/string()
    }</results>