(:This file is used to populate the Tree in the left-hand menu in Digital TopBib:)
(:At the bottom is code about how top level items are displayed:)
xquery version "3.0";

import module namespace config="https://ausohnum.huma-num.fr/apps/eStudium/config" at "../config.xqm";

declare namespace json="http://www.json.org";
declare namespace skos="http://www.w3.org/2004/02/skos/core#";
declare namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/";

declare namespace dc="http://purl.org/dc/elements/1.1/";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace xf = "http://www.w3.org/2002/xforms";

declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=yes indent=yes";

let $data-collection := collection($config:data-collection || "/concepts")

let $schemeShortName := request:get-parameter('scheme', '')
let $schemeUri :=request:get-parameter('schemeUri', '')

return
<data>
{for $concepts in $data-collection//.[skos:inScheme/@rdf:resource= $schemeUri]
  order by $concepts/skos:prefLabel[@xml:lang='en']/text()
  
  return
    <concept scheme="{data($concepts/skos:inScheme/@rdf:resource)}" >
       <label>{$concepts/skos:prefLabel[@xml:lang = 'en']/text()} ({data($concepts/@xml:id)})</label>
       <url>{data($concepts/@rdf:about)}</url>
    </concept>
    }
 </data>