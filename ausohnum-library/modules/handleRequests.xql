xquery version "3.1";
import module namespace prosopoManager="http://ausonius.huma-num.fr/prosopoManager"
      at "./prosopoManager/prosopoManager.xql";
import module namespace spatiumStructor="http://ausonius.huma-num.fr/spatiumStructor"
      at "./spatiumStructor/spatiumStructor.xql";

declare variable $type := request:get-parameter('type', ());
declare variable $data := request:get-data();
declare variable $project := request:get-parameter('project', ());
declare variable $username := request:get-parameter('user', ());
declare variable $path := request:get-parameter('path', ());
declare variable $resource := request:get-parameter('resource', ());
declare variable $format := request:get-parameter('format', ());
declare variable $query := request:get-parameter('query', ());

switch ($type)

   case "stsaveData" return spatiumStructor:saveData($data, $project)
   case "stsaveDataConceptHierarchy" return spatiumStructor:saveDataWithConceptHierarchy($data, $project)
   case "getPlaceHTML" return spatiumStructor:getPlaceHTML($resource)
   
   case "getPeopleHTML" return prosopoManager:getPeopleHTML($resource)
   case "saveDataPeople" return prosopoManager:saveData($data, $project)
   default return null