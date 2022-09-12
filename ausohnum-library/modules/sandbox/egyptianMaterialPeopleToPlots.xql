xquery version "3.1";

import module namespace http="http://expath.org/ns/http-client" at "java:org.expath.exist.HttpClientModule";
import module namespace teiEditor="http://ausonius.huma-num.fr/teiEditor"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/teiEditor/teiEditorApp.xql";
import module namespace prosopoManager="http://ausonius.huma-num.fr/prosopoManager"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/prosopoManager/prosopoManager.xql";

import module namespace functx="http://www.functx.com";


declare namespace lawd="http://lawd.info/ontology/";
declare namespace apc="http://patrimonium.huma-num.fr/onto#";
declare namespace foaf="http://xmlns.com/foaf/0.1/"; 
declare namespace pleiades="https://pleiades.stoa.org/places/vocab#";
declare namespace owl="http://www.w3.org/2002/07/owl#";
declare namespace skos="http://www.w3.org/2004/02/skos/core#"; 
declare namespace geo="http://www.w3.org/2003/01/geo/wgs84_pos#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace dcterms="http://purl.org/dc/terms/";
declare namespace ausohnum="http://ausonius.huma-num.fr/onto";
declare namespace spatial="http://geovocab.org/spatial#";
declare boundary-space preserve;

declare variable $people := collection('xmldb:exist:///db/apps/patrimoniumData/people/egyptianMaterialPeople');
declare variable $places := collection('xmldb:exist:///db/apps/patrimoniumData/places/patrimonium/imports');


declare function local:addFunction($pos as xs:int, $personID as xs:string, $apcPlaceUriShort as xs:string){
    let $conceptUriBase := "https://ausohnum.huma-num.fr/concept/"
    let $code4Admin := "c23690"  (:$plotDetails[2 AND 3 ]:)
    let $code4Georgos := "c23687" (:$plotDetails[4 AND 5]:)
    let $code4Mistothes := "c23688" (:$plotDetails[6 AND 7]:)
    let $functionUri := switch($pos)
                case 2 case 3 return $conceptUriBase || $code4Admin
                case 4 case 5 return $conceptUriBase || $code4Georgos
                case 6 case 7 return $conceptUriBase || $code4Mistothes
                default return "CHECK"

     let $tmPerson := "https://www.trismegistos.org/person/" || $personID
    let $apcPerson := $people//lawd:person[skos:exactMatch[@rdf:resource = $tmPerson]]/foaf:primaryTopicOf/apc:people
    let $functionNode := <data><apc:hasFunction rdf:resource="{ $functionUri}" target="{ $apcPlaceUriShort }"/>
            </data>
        return
         (<addition>Person { data($apcPerson/@rdf:about) } - Function: { $functionNode/node() }</addition>
         ,
            update replace $apcPerson/apc:hasFunction[@target="https://patrimonium.huma-num.fr/places/56389"] with $functionNode/node() 
         )
            
};
let $now := fn:current-dateTime()
let $currentUser := data(sm:id()//sm:username)
let $nl := '&#xa;'
    

let $plotsRaw := util:binary-to-string(util:binary-doc('xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/landplots/peopleOfPlots.csv'))
let $plots := tokenize(replace($plotsRaw, '"', ''), "\r\n")



    
return 
    <result>{
for $plot at $pos in $plots 
        where $pos > 2
    let $plotDetails := tokenize($plot, ",")
    let $ousiaRefId := "https://www.trismegistos.org/ousiaRefId/" || $plotDetails[1]
    let $apcPlaceUriLong := data($places//spatial:Feature[skos:exactMatch[@rdf:resource= $ousiaRefId]]/@rdf:about)
    let $apcPlaceUriShort := substring-before($apcPlaceUriLong, '#this') 
    
    let $admin1 := if($plotDetails[2]!= "") then local:addFunction(2, $plotDetails[2], $apcPlaceUriShort) else ()
    let $admin2 := if($plotDetails[3]!= "") then local:addFunction(3, $plotDetails[3], $apcPlaceUriShort) else ()
    let $georgos1 := if($plotDetails[4]!= "") then local:addFunction(4, $plotDetails[4], $apcPlaceUriShort) else ()
    let $georgos2 := if($plotDetails[5]!= "") then local:addFunction(5, $plotDetails[5], $apcPlaceUriShort) else ()
    let $mistothes1 := if($plotDetails[6]!= "") then local:addFunction(6, $plotDetails[6], $apcPlaceUriShort) else ()
    let $mistothes2 := if($plotDetails[7]!= "") then local:addFunction(7, $plotDetails[7], $apcPlaceUriShort) else ()    
    return 
($nl, "Plot " || (number($pos)-1) || $nl, $admin1, 
         $admin2, 
         $georgos1,
         $georgos2,
         $mistothes1,
         $mistothes2
        )
    }
    </result>
    
    
    
    
    
    
    
    