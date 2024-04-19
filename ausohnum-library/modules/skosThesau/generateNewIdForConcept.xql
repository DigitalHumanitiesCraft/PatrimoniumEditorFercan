xquery version "3.1";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";

let $idPrefix := "c"
let $idList := for $id in (collection("/db/apps/ausohnumData/concepts")//skos:Concept[contains(./@xml:id, $idPrefix)],
                        collection("/db/apps/ausohnumData/concepts")//skos:Collection[contains(./@xml:id, $idPrefix)])
        return
        <item>
        {substring-after($id/@xml:id, $idPrefix)}
        </item>

    let $last-id:= fn:max($idList)
 return $idPrefix || fn:sum(($last-id, 1))