(:~
: AusoHNum Library - spatial data manager module
: This function serves as an interace between a project front-end and XQuery functions related to spatial data matters.
: @author Vincent Razanajao
: @param type is the paramater of the http request that calls this function
:)


xquery version "3.1";

import module namespace spatiumStructor="http://ausonius.huma-num.fr/spatiumStructor"
      at "./spatiumStructor.xql";

declare variable $type := request:get-parameter('type', ());
declare variable $data := request:get-data();
declare variable $project := request:get-parameter('project', ());
declare variable $username := request:get-parameter('user', ());
declare variable $path := request:get-parameter('path', ());
declare variable $resource := request:get-parameter('resource', ());
declare variable $format := request:get-parameter('format', ());
declare variable $query := request:get-parameter('query', ());

switch ($type)

   case "dashboard" return spatiumStructor:dashboard()
   case "places-manager" return spatiumStructor:placesManager()
   case "places-manager2" return spatiumStructor:placesManager2()
   case "archaeo-manager" return spatiumStructor:archaeoManager()
   case "map" return spatiumStructor:map()
   case "displayPlaceDetails" return spatiumStructor:displayPlaceDetails($resource, $path)
   case "newPlaceForm" return spatiumStructor:newPlaceForm()
   case "newArchaeoForm" return spatiumStructor:newArchaeoForm()
   case "createNewPlace" return spatiumStructor:createNewPlace($data, $project)
   case "createNewSubPlace" return spatiumStructor:createNewSubPlace($data, $project)
   
   case "buildPlaceTree" return spatiumStructor:buildPlaceTree()
   case "buildArchaeoTree" return spatiumStructor:buildArchaeoTree()
   case "getPlaceRdf" return spatiumStructor:getPlaceRdf($resource)
   case "getPlaceHTML" return spatiumStructor:getPlaceHTML($resource)
   case "getPlaceHTML2" return spatiumStructor:getPlaceHTML2($resource)
   case "getArchaeoHTML" return spatiumStructor:getArchaeoHTML($resource, $project)
   case "noPlaceFound" return spatiumStructor:noPlaceFound($resource)
   case "placeIntro" return spatiumStructor:placeIntro()
   case "processUrl" return spatiumStructor:processUrl($path, $resource, $project, $format)
    case "getPlacesGazetteer" return spatiumStructor:getProjectPlacesGazetteer($project, $resource, $format)
   
    case "saveData" return spatiumStructor:saveData($data, $project)
    case "addGroupData" return spatiumStructor:addGroupData($data, $project)
    case "saveXmlFile" return spatiumStructor:saveXmlFile($data, $project)
    case "updateLocation" return spatiumStructor:updateLocation($data, $project)
    case "saveTextarea" return spatiumStructor:saveTextarea($data, $project)
    case "addData" return spatiumStructor:addData($data, $project)
    case "addResourceToPlace" return spatiumStructor:addResourceToPlace($data, $project)
    case "addResource" return spatiumStructor:addResource($data, $project)
    case "addPlaceToPlace" return spatiumStructor:addPlaceToPlace($data, $project)
    case "removeItem" return spatiumStructor:removeItem($data, $project)
    case "removeResourceFromList" return spatiumStructor:removeResourceFromList($data, $project)
    case "removeSubPlace" return spatiumStructor:removeSubPlace($data, $project)
    case "changePlaceToNearTo" return spatiumStructor:changePlaceToNearTo($data, $project)
    case "getPeripleoPlaceDetails" return spatiumStructor:getPeripleoPlaceDetails($data, $project)
    
    
    case "searchPlace" return spatiumStructor:searchPlace($query)
    case "pleaseLogin" return spatiumStructor:pleaseLogin($project)
   (:case "loginForm" return teiEditor:loginForm($project, $username)
   case "newUserForm" return teiEditor:newUserForm($project)


   case "addPerson" return teiEditor:addPersonToDoc($data, $project)
   case "addPlace" return teiEditor:addPlaceToDoc($data, $project)

   case "removeItemFromList" return teiEditor:removeItemFromList($data, $project)
   case "saveText" return teiEditor:saveText($data, $project)
   case "saveFile" return teiEditor:saveFile($data, $project):)


   default return null
