xquery version "3.1";
import module namespace functx="http://www.functx.com";
declare default element namespace "http://www.tei-c.org/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare boundary-space preserve;

let $mentionsToBeProcessed := <peopleInLemmatizedFile>
    <file name="bgu.1.181" tm="8943" HVG="8943" xml:lang="grc">
        <mention corresp="https://trismegistos.org/person/34693" row="1" token="1">
            <persName type="regularized">Γαίωι</persName>
            <persName type="original">Γαίωι</persName>
        </mention>
        <mention corresp="https://trismegistos.org/person/34693" row="1" token="2">
            <persName type="regularized">Ἰουλείωι</persName>
            <persName type="original">Ἰουλείωι</persName>
        </mention>
        <mention corresp="https://trismegistos.org/person/34693" row="1" token="3">
            <persName type="regularized">Ἀσινιανῶι</persName>
            <persName type="original">[Ἀσινιανῶι]</persName>
        </mention>
        <mention corresp="https://trismegistos.org/person/313901" row="3" token="2">
            <persName type="regularized">Ἀπολλωνίου</persName>
            <persName type="original">Ἀπολλωνίου</persName>
        </mention>
        <mention corresp="https://trismegistos.org/person/313901" row="3" token="4">
            <persName type="regularized">Ἀπολλωνίου</persName>
            <persName type="original">Ἀπολλωνίου</persName>
        </mention>
        <mention corresp="https://trismegistos.org/person/392037" row="13" token="2">
            <persName type="regularized">Ὀρσενοῦφις</persName>
            <persName type="original">Ὀρσενοῦφις</persName>
        </mention>
        <mention corresp="https://trismegistos.org/person/393315" row="14-15" token="1">
            <persName type="regularized">Κον|gap=20|ούφιος</persName>
            <persName type="original">Κον|gap=20|ού-φιος</persName>
        </mention>
        <mention corresp="https://trismegistos.org/person/393316" row="15" token="3">
            <persName type="regularized">Ἀλεξάνδρου</persName>
            <persName type="original">Ἀλεξά[νδρου]</persName>
        </mention>
    </file>
        
    </peopleInLemmatizedFile>


 return 
     <result xmlns="http://www.tei-c.org/ns/1.0">{
     for $file in $mentionsToBeProcessed//file
        let $name := $file/@name
        let $text := collection("xmldb:exist:///db/apps/patrimoniumData/documents/documents-ybroux")//tei:TEI[.//tei:idno[equals(., $name)]]/tei:text/tei:body/tei:div[equals(./@type, "edition")]
        
        return 
            <file xmlns="http://www.tei-c.org/ns/1.0" name="{ $file/@name }">{
            for $mention at $pos in $file//mention
            let $lineNo := $mention/@row
            let $lineNoEnd := xs:integer(functx:substring-after-if-contains($lineNo, "-")) + 1
            let $line := $text//tei:lb[matches(./@n, $lineNo)][1]/following-sibling::node()
            let $line2 := $text//tei:lb[matches(./@n, $lineNo)]/following-sibling::node()[following-sibling::tei:lb[matches(./@n, $lineNo)] and preceding-sibling::tei:lb[matches(./@n, $lineNoEnd)]]/node() 
                
            let $token := tokenize($line, " ")[$mention/@token]
            
(:            let $word := if(contains($line, $mention/persName[@type, "original"])):)
(:                    then replace(string($line), $mention/persName[@type, "original"][1],:)
(:                    "<rs>" || $mention/persName[@type, "original"][1] || "</rs>" ):)
(:                    else:)
(:                        if(contains($mention/persName[@type, "original"], "[")) then:)
(:                                replace(replace($mention/persName[@type, "original"], "[", '<supplied reason="lost">'), ']', '</rs>'):)
(:                        else():)
                return   
                    <mention xmlns="http://www.tei-c.org/ns/1.0" n="{ $pos }">
                        {$line2}
                    </mention>
            }</file>
            }</result>        
        