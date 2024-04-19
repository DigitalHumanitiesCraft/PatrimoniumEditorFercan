xquery version "3.1";

let $collection := "documents/documents-hgonzalez"
let $permissions := "rw-rw-r--"
let $group := "patrimonium"

let $resources := xmldb:get-child-resources(xs:anyURI(concat("/db/apps/patrimoniumData/" , $collection)))

for $item in $resources

return 
    (
    sm:chgrp(xs:anyURI(concat("/db/apps/patrimoniumData/" || $collection, "/", $item)), $group),
    sm:chmod(xs:anyURI(concat("/db/apps/patrimoniumData/"|| $collection, "/", $item)), $permissions)
)