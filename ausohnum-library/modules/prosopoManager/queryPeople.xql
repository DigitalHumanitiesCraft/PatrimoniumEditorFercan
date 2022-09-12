xquery version "3.1";

import module namespace functx="http://www.functx.com";

import module namespace kwic="http://exist-db.org/xquery/kwic";

declare namespace apc="http://patrimonium.huma-num.fr/onto#";
declare namespace dcterms="http://purl.org/dc/terms/";

declare namespace foaf="http://xmlns.com/foaf/0.1/";
declare namespace geo = "http://www.w3.org/2003/01/geo/wgs84_pos#";

declare namespace json="http://www.json.org";
declare namespace lawd="http://lawd.info/ontology/";
declare namespace pleiades="https://pleiades.stoa.org/places/vocab#";

declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace snap="http://onto.snapdrgn.net/snap#";
declare namespace spatial="http://geovocab.org/spatial#";


declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

(: Switch to JSON serialization :)
declare option output:method "xhtml";
(:declare option output:media-type "application/xhtml";:)
declare option output:indent "yes";

declare variable $project :=request:get-parameter('project', ());
declare variable $query :=request:get-parameter('query', ());


let $people-collection := collection("/db/apps/" || $project || "Data/people/" )

return
<table id="peopleQueryResults" class="table">
    <thead>
        <tr>
        <td></td>
        <td>Name</td>
        <td class="sortingActive">uri</td>
        </tr>
        </thead>
        <tbody>

{


for $hit in $people-collection//lawd:person[.//lawd:personalName[ft:query(., $query[1])]]

let $personUri := data($hit//apc:people/@rdf:about)
let $expanded := util:expand($hit, "expand-xincludes=no")
let $matchedName := functx:change-element-names-deep(
 $expanded//lawd:personalName[exist:match],
 xs:QName('exist:match'),
 xs:QName('mark'))

order by ft:score($hit) descending
return
<tr>
<td></td>
<td>{$matchedName}</td>
<td><span onclick="displayPerson({substring-after($personUri, '/people/')})">{$personUri}</span></td>
</tr>
    }
    </tbody>
    
    </table>