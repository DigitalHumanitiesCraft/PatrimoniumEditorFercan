xquery version "3.1";
import module namespace functx="http://www.functx.com";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare boundary-space preserve;


let $docs := collection("/db/apps/gymnasiaData/documents")


for $doc at $pos in $docs//tei:TEI[tei:text/tei:body/tei:div[@type ="bibliography"][not(exists(@subtype="secondary"))]]
where $pos <3

let $secondaryDiv := <node>
    <div type="bibliography" subtype="secondary">
                <listBibl>
                </listBibl>
    </div>
    </node>
let $insertSecondaryBibl :=
    update insert 
        functx:change-element-ns-deep($secondaryDiv/node(),
                                    "http://www.tei-c.org/ns/1.0", "")
            following $doc//tei:div[@type ="bibliography"][@subtype ="edition"]

return 
    
    <result doc="{$doc/@xml:id}">
    {$doc//tei:body}
    </result>