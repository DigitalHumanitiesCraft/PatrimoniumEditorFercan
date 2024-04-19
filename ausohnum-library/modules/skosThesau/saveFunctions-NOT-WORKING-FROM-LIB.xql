xquery version "3.1";

import module namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/"
      at "skosThesauApp.xql";

declare variable $type := request:get-parameter('type', ());
declare variable $data := request:get-data();


switch ($type)
   case "saveData" return skosThesau:saveData($data)
   case "addExistingConceptasNT" return skosThesau:addExistingConceptasNT($data)
   case "addNewConceptasNT" return skosThesau:addNewConceptasNT($data)
   case "addNewAltLabel" return skosThesau:addNewAltLabel($data)
   case "addNewAltLabel" return skosThesau:addNewPrefLabel($data)
   case "deletePrefLabel" return skosThesau:deleteLabel($data)
   
(:   case "addData" return skosThesau:addData($data):)
(:   case "removeItemFromList" return skosThesau:removeItemFromList($data):)
   
   default return null
