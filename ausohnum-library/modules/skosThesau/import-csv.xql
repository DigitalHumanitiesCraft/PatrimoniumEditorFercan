xquery version "3.1";

import module namespace config="http://ausonius.huma-num.fr/ausohnum-library/config" at "../config.xqm";
import module namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/" at "skosThesauApp.xql";
import module namespace functx="http://www.functx.com";

declare namespace dc="http://purl.org/dc/elements/1.1/";
declare namespace dct = "http://purl.org/dc/terms/";

declare namespace periodo="http://perio.do/#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
(:declare namespace skosThesau = "https://ausohnum.huma-num.fr/skosThesau/";:)
declare variable $thesaurus := "ausohnum";
declare variable $project :=request:get-parameter('project', 'ausohnum');
declare variable $dbName := doc('xmldb:exist:///db/apps/' || $project || '/data/app-general-parameters.xml')//idPrefix[@type='db']/text();
declare variable $baseUri := doc('xmldb:exist:///db/apps/' || $project || '/data/app-general-parameters.xml')//uriBase[@type="thesaurus"]/text();
declare variable $thesaurusPrefix := doc('xmldb:exist:///db/apps/' || $project || '/data/app-general-parameters.xml')//idPrefix[@type='thesaurus']/text();
declare variable $conceptPrefix := doc('xmldb:exist:///db/apps/' || $project || '/data/app-general-parameters.xml')//idPrefix[@type='concept']/text();
declare variable $conceptBaseUri := $baseUri || "/concept/";

declare variable $peopleRepo := collection("xmldb:exist:///db/data/" || $project || "/accounts");

(:let $logs := collection("db/apps/" || $thesaurus || "/logs"):)
let $now := fn:current-dateTime()
let $currentUser := sm:id()
let $personRecord := $peopleRepo/id($currentUser)
let $userName := $personRecord//firstname || ' ' || $personRecord//lastname

let  $conceptCollection := collection('xmldb:exist:///db/apps/' || $thesaurus || "Data/concepts")


let $csv-input-sample :=
"|en
|Thesaurus FISCUS
	|Document features
		|Type of document
			|Archaelogical sources
			|Parchment documents
				|Diploma
					|Imperial/royal diploma
					|Marquisal/ducal diploma
					|Episcopal diploma
				|Placitum
				|Cartula
					|Venditio
					|Commutatio
					|Libellus/precaria/emphyteusis
					|Offersio/donatio
					|Promissio
					|Ordinatio
					|Testamentum/iudicatum
					|Morgengabe
				|Breve
					|List/inventory
					|Judicial breve
					|Transactional breve
				|Littera/mandatum
			|Epigraphic documents
			|Papyrological documents
			|Literary sources
				|Author
			|Juridical sources
				|Lex
				|Capitulum
		|Language
			|Latin
			|Greek
		|Writer
			|Copyist
		|Intercessory
	|Geography
		|Geographic regions
		|Cities
		|Villages/settlements
			|Vici
			|Burgi
		|Castra/castella
		|Areas
			|Fines
		|Modern places
		|Natural landscape
			|Rivers
			|Lakes
			|Marshes/lagoons/tombolos
			|Islands
			|Sea
			|Mountains
	|Economy
		|Production units
			|Villas
			|Curtes
			|Gai
			|Massae
			|Salae
			|Generic sundria
			|Generic domnicata
			|Casali
			|Mansi
			|Casae/cassinae massaricie
			|Casalini/fundamenta
			|Petiae
			|Mines
			|Quarries
			|Forests
				|Gualdi
				|Cafagia
			|Fisheries
			|Saltworks
			|Other basins
			|Processing units
				|Mills
				|Kilns
			|Storing units
				|Granaries
				|Barns
			|Workshops
				|Gynaecea
		|Value
			|Price
			|Meritum/launechild
			|Penalty
		|Size
		|Production
			|Cereals
				|Maiores
				|Minores
			|Legumes
			|Wine
			|Oil
			|Fruits/vegetables
			|Dried fruits
			|Chestnuts
			|Acorns
			|Hay
			|Honey
			|Cheese
			|Eggs
			|Soap
			|Papyrus
			|Reed
			|Stone
				|Marble
				|Granite
				|Porphyry
				|Soapstone
					|Steatite
					|Pietra ollare
				|Gypsum
				|Limestone
				|Sandstone
				|Slate
				|Verrucano
			|Metals
				|Gold
				|Silver
				|Iron
				|Copper
				|Lead
				|Argentiferous lead
			|Salt
				|Sea salt
				|Rock salt
			|Alum
			|Sulphur
			|Gems
			|Wood
			|Garum
			|Bread
			|Glass
			|Bricks
			|Tiles
			|Ceramics
			|Weapons
			|Wool
			|Tissues
				|Silk
				|Linen
				|Hemp
			|Leather
			|Pigments
				|Woad
			|Clothings
			|Animals
				|Cows
				|Goats
				|Horses
				|Fish
				|Pigs
				|Sheep
				|Game
				|Poultry
				|Wildfowl
				|Birds of prey
		|Fiscal property
			|Occurrence
				|Object
				|Quote
			|Holder
				|Emperor/king
				|Queen
				|Marquis/duke
				|Count
				|Countess
				|Palatine count
				|Viscount
				|Gastald/vicegastald
				|Sculdahis
				|Marepahis
				|Other palatine official
				|Other minor official
			|Function
				|Residential
				|Redistributive
				|Exceptuative
					|Dowry
					|Land reserve
			|Acquisitions
				|Inheritance
				|Confiscation
				|Purchase
				|Forced purchase
				|Gift
			|Alienations
				|Allocation to individuals
				|Allocation to groups
				|Allocation to churches
				|Counter-gift
			|Works of art
			|Furniture
			|Jewels
			|Luxury clothes
			|Exotic animals
			|Exotic coins
			|Books
			|Residences
				|Palatium
				|Laubia/topia
				|Spolia
			|Management
				|Contractors
					|Conductores
					|Actionarii/actores
				|Coloni/tenants
					|Manentes
					|Condomae
				|Estate supervisors/vilici
					|Gualdemanni/silvani
					|Porcarii
		|Rent type
			|Rent in kind
			|Rent in money
			|Exenia
			|Operae
		|Work and workers
			|Paid workforce
			|Slave labour
			|Agricultural workers
			|Unskilled workers
			|Specialized workers
			|Stonemasons
			|Miners
			|Moneyers
		|Fortifications
			|Castle
			|Tower
			|Clusae/doors
			|Walls
			|Carbonaria
			|Defensive elements
		|Infrastructures
			|Ports
			|Storage buildings
			|Roads
			|Aqueducts
			|Cisterns/pits
			|Fountains
			|Bridges/pontoons
			|Canals
		|Mints
		|Finance
			|Interest bearing loans
			|Loans with no interest
		|Trade
			|Maritime trade
			|Overland transport
			|Fluvial transport
			|Transport contracts
			|Navicularii
			|Local markets
			|Periodic markets
	|Administration
		|Emperor/king
		|Queen
		|Marquis/duke
		|Count
		|Countess
		|Palatine count
		|Viscount
		|Gastald/vicegastald
		|Sculdahis
		|Marepahis
		|Other palatine official
		|Other minor official
		|Court clergyman
			|Chancellor
			|Chaplain
		|Professional of the pen
			|Notary
			|Judge
		|Consiliarius regis
		|Missus
			|Missus regis
			|Missus of other public authorities
		|Advocatus
			|Advocatus regis
			|Advocatus of other public authorities
		|Camera
			|Camera regis
			|Camera of other public authorities
		|Administrative units
			|Iudiciaria
			|Comitatus
			|Fines
			|Actio
			|Subactio
			|Dioecesis
			|Plebs
		|Assembly
		|Army
		|Armed group
			|Hungarians
			|Masnada
		|Levies
			|Decima
			|Nona et decima
		|Revenues
			|Fodrum
			|Albergaria/gifori
			|Profits of justice
			|Profits of mining/minting
			|Tolls
			|Teloneum
			|Rights of use on woods/pastures/waters
		|Malus usus
		|Privileges
			|Immunity
			|Exemption
			|Incastellamento
			|Coinage
		|Royal ordinances
		|Letters from public authorities
		|Substitution of a beneficium
		|Itinerary
		|Scufiae/transport service
		|Extortions by officials
	|Law
		|Property of persons without heirs
		|Property of criminals/political traitors
		|Boundary disputes
		|Boundary settings
	|Local institutions
		|City authorities
			|Consules
			|Potestas
		|City assembly
		|City territory
		|Local elites
			|Scabini
			|Lociservatores
			|Boni viri/boni homines
		|Village/castle representatives
		|Village/castle territory
		|Embassies/ambassadors
		|Rural communities
		|Common land
	|Religion
		|Churches/religious bodies
			|Churches
			|Baptismal churches
			|Collegiate churches
			|Mother churches
			|Monasteries
			|Cells/hermitages
			|Hospitals
		|Altars
		|Funerary rituals
		|Funerary monuments/cemeteries
		|Popular devotions
		|Religious festivals
		|Processions
		|Pilgrimages
		|Clergy/religious persons
			|Bishops
			|Priests
			|Deacons
			|Subdeacons
			|Other clerics
			|Abbots
			|Abbesses
			|Monks
			|Nuns/sanctimoniales
	|Society
		|Personal statuses
			|Freeborn
			|Aldius
			|Slave
			|Freedman
			|Royal slave
			|Royal freedman
			|Royal aldius
			|Arimannus
			|Lambardus
		|Transactional statuses
			|Vassus
			|Gasindius
			|Fidelis/miles
			|Dominus/senior
			|Homo de
		|Personal rank
			|Vir devotus/vir honestus
			|Vir magnificus
			|Vir clarissimus
			|Vir spectabilis
			|Vir inluster
			|Vir gloriosus/vir sublimis
			|Consul/hypatos
			|Patricius
		|Natio
			|Roman
			|Lombard
			|Salian
			|Ripuarian
			|Bavarian
			|Burgundian
			|Alamannian
		|Public rituals
			|Adventus/occursus
			|Deditio
		|Public decorum
		|Conviviality
		|Beneficium
		|Feudum
		|Honor
		|Munus
		|Meritum/launechild
		|Private foundations
		|Joint foundations
		|Distributions of moveable goods
		|Marriages
		|Clerical concubinage
		|Nutritus
		|Compater
		|Manumission"

let $lines := tokenize($csv-input-sample, '\n')
let $header := $lines[1]
let $entryHeaders := tokenize($header, '\|')
let $nl := "&#10;"
let $space := "&#032;"
let $tab3 := "    "
let $tab2 :="\t"
let $tab   := "&#009;"



let $idList := for $id in $conceptCollection//.[contains(./@xml:id, $conceptPrefix)]
        let $int := data(substring-after($id/@xml:id, $conceptPrefix))
        order by number($int) ascending
        return
        <item>
        { $int }
        </item>

        
let $last-id:= 
(:fn:max($idList) :)
  data($idList[last()])

(:let $newId := $conceptPrefix || fn:sum(($last-id, 1)):)
let $newId := $conceptPrefix || fn:sum(($last-id, 1))
let $thesaurusLabel:= 
    lower-case(tokenize(tokenize($lines[2]), '\|')[2])
 
 let $idTopConcept := $newId



return
    (
        
<rdf:RDF xmlns:dct="http://purl.org/dc/terms/" xmlns:periodo="http://perio.do/#"
    xmlns:skosThesau="https://ausohnum.huma-num.fr/skosThesau/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:time="http://www.w3.org/2006/time#"
    xmlns:map="http://www.w3c.rl.ac.uk/2003/11/21-skos-mapping#"
    xmlns:dc="http://purl.org/dc/elements/1.1/">



{ element {"skos:ConceptScheme"}
            {attribute {"rdf:about"} {$baseUri || '/' || $thesaurusPrefix || '/' || $thesaurusLabel || '/'},
            element {"dc:title"}
                    {attribute {"type"} {"full"},
                    $thesaurusLabel},
            element {"dc:title"}
                    {attribute {"type"} {"short"},
                    $thesaurusLabel},
            element {"skos:hasTopConcept"}
                    {attribute {"rdf:resource"} {$conceptBaseUri || $idTopConcept}},
            
        element {"dc:creator"} {$userName},
        element {"dc:publisher"} {"Ausonius Institute"},
        element {"dct:created"} {$now},
        element {"skosThesau:admin"}
                {attribute{"status"}{"draft"}} }
    
    
}
{

  for $line at $pos in $lines
            where $pos > 1
    let $indent := string-length(functx:substring-before-last($line, "    "))
    let $entries := tokenize($line, '\|')
    let $level := string-length($entries[1])
    let $text := functx:substring-after-last($line, $tab)
    let $id := $conceptPrefix ||sum(($last-id, number($pos), -1))
    let $fields := tokenize($text, '\|')
  
    let $previousNodesReverse := reverse(subsequence($lines, 1, $pos))
    let $previousLines := 
        <list>
            {for $previousLine at $revPos in $previousNodesReverse
                where $revPos > 1
(:            let $previousIndent := string-length(functx:substring-before-last($previousLine, $tab)):)
            let $prevEntries := tokenize($previousLine, '\|')
            let $prevLevel :=  string-length($prevEntries[1])
            let $idParent := $conceptPrefix || ($last-id + $pos - $revPos)
            return
                <node><level>{ if ($prevLevel < $level) then $prevLevel else ($level) }</level><reversePos>{ $revPos }</reversePos><parent ref="{$idParent}">{ $prevEntries[2]}</parent></node>
                }
            </list>
    
    let $parent := $previousLines//node[level < $level][1]
        let $parents := for $broader in $parent
                where $pos >2
            return
                element {"skos:broader"}
                {attribute{"rdf:resource"}{data($conceptBaseUri || $broader//parent/@ref)}}
    
    
    
    let $followingSeq := subsequence($lines, $pos+1)
    let $followingLines :=
            <list>
                {for $followingLine at $followingPos in $followingSeq
                
                let $followingEntries := tokenize($followingLine, '\|')   
                let $followingLevel :=  string-length($followingEntries[1])   
                let $idChild := $conceptPrefix || ($pos + $followingPos)
                
                return 
                  <child level="{ if($followingLevel) then  $followingLevel else 4 }" ref="{$idChild}" label="{$followingEntries[2]}"/>
            }
                </list>
    let $previousLevel := number($level - 4)
    let $firstSameLevelNode :=if($followingLines//child[@level = number($level)]) then
            (

                functx:index-of-node($followingLines/child, $followingLines/child[@level = number($level)][1])
                )
            else (count($lines))
     let $followingSeq4Children := subsequence($lines, $pos+1, $firstSameLevelNode )

    
    let $childrenNodes :=
            <list>
                {for $followingLine2 at $followingPos2 in $followingSeq4Children
                
                let $followingEntries2 := tokenize($followingLine2, '\|')   
                let $followingLevel2 :=  string-length($followingEntries2[1])   
                let $idChild2 := $conceptBaseUri  || $conceptPrefix || ($last-id + $pos + $followingPos2 -1)
                
                return 
                    
                    <child level="{ if($followingLevel2) then  $followingLevel2 else 0}">
                    <level>{ data(if($followingLevel2) then  $followingLevel2 else "Same")}</level>
                    <skos:narrower rdf:resource="{$idChild2}"/></child>
            }
                </list>
    
    
    
    let $children := $childrenNodes//.[@level = data($level+4)]//skos:narrower
    
    (:let $parent := 
            for $nodes in $previousNodesReverse
            where 
      :)      
  
  return
        
  element {"skos:Concept"}
  {attribute {"xml:id"} {$id},
   attribute {"rdf:about"} {$conceptBaseUri || $id},
(:   attribute {"indent"} {$level},:)
        for $field at $posInFields in $fields
        where $posInFields > 1 and  $posInFields < 5
        return
            if($field) then
            <skos:prefLabel xml:lang="{data($entryHeaders[$posInFields])}">{$field}</skos:prefLabel>
            else (),
            $parents,
            $children,
            
        element {"skos:inScheme"} 
            {attribute {"rdf:resource"} {$baseUri || '/' || $thesaurusPrefix || '/' || $thesaurusLabel || '/'}},
        element {"dct:created"} {$now},
        element {"skosThesau:admin"}
                {attribute{"status"}{"draft"}}
(:                ,:)
(:                "level: ", $level,:)
(:                "previouslevel: ", $previousLevel,:)
(:                "$firstSameLevelNode: ", $firstSameLevelNode,:)
(:                $followingLines,:)
(:                $followingSeq4Children,:)
(:                $childrenNodes:)
  }
}
   
</rdf:RDF>
)