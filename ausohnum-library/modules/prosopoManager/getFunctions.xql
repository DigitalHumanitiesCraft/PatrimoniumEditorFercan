(:~
: AusoHNum Library - prosopographical module
: This function serves as an interace between a project front-end and XQuery functions related to prosopographical matters.
: @author Vincent Razanajao
: @param type is the paramater of the http request that calls this function
:)

xquery version "3.1";

import module namespace prosopoManager="http://ausonius.huma-num.fr/prosopoManager"
      at "./prosopoManager.xql";

declare option exist:timeout "60000";

declare variable $type := request:get-parameter('type', ());
declare variable $data := request:get-data();
declare variable $project := request:get-parameter('project', ());
declare variable $username := request:get-parameter('user', ());
declare variable $path:= request:get-parameter('path', ());
declare variable $resource:= request:get-parameter('resource', ());
declare variable $format:= request:get-parameter('format', ());
switch ($type)
   case "dashboard" return prosopoManager:dashboard()
   case "people-manager" return prosopoManager:peopleManager()
   case "people-manager2" return prosopoManager:peopleManager2()
(:   case "displayPlaceDetails" return prosopoManager:displayPlaceDetails($resource, $path):)
   case "getPeopleRdf" return prosopoManager:getPeopleRdf($resource)
   case "getPeopleHTML" return prosopoManager:getPeopleHTML($resource)
   case "getPeopleHTML2" return prosopoManager:getPeopleHTML2($resource)
   case "buildPeopleTree" return prosopoManager:buildPeopleTree()
   case "newPersonForm" return prosopoManager:newPersonForm()
   case "createNewPerson" return prosopoManager:createNewPerson($data, $project)
   case "processUrl" return prosopoManager:processUrl($path, $resource, $project, $format)
    case "saveData" return prosopoManager:saveData($data, $project)
    case "saveTextarea" return prosopoManager:saveTextarea($data, $project)
    case "addData" return prosopoManager:addData($data, $project)
    case "getBondTypeReverse" return prosopoManager:getBondTypeReverse($data, $project)
    case "addBond" return prosopoManager:addBond($data, $project)
    case "addFunction" return prosopoManager:addFunction($data, $project)
    case "moveFunction" return prosopoManager:moveFunction($data, $project)
    case "removeRelationship" return prosopoManager:removeRelationship($data, $project)
    case "confirmRelationshipDeletion" return prosopoManager:confirmRelationshipDeletion($data, $project)
    case "addResourceToPerson" return prosopoManager:addResourceToPerson($data, $project)
    case "removeResourceFromList" return prosopoManager:removeResourceFromList($data, $project)
    case "addResource" return prosopoManager:addResource($data, $project)
    case "removeItem" return prosopoManager:removeItem($data, $project)
    case "changePlaceToNearTo" return prosopoManager:changePlaceToNearTo($data, $project)
    case "saveXmlFile" return prosopoManager:saveXmlFile($data, $project)
   (:case "loginForm" return teiEditor:loginForm($project, $username)
   case "newUserForm" return teiEditor:newUserForm($project)


   case "addPerson" return teiEditor:addPersonToDoc($data, $project)
   case "addPlace" return teiEditor:addPlaceToDoc($data, $project)

   case "removeItemFromList" return teiEditor:removeItemFromList($data, $project)
   case "saveText" return teiEditor:saveText($data, $project)
   case "saveFile" return teiEditor:saveFile($data, $project):)


   default return null
