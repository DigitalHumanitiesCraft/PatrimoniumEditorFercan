xquery version "3.1";

import module namespace teiEditor="http://ausonius.huma-num.fr/teiEditor"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/teiEditor/teiEditorApp.xql";

declare option exist:timeout "30000";

declare variable $type := request:get-parameter('type', ());
declare variable $data := request:get-data();
declare variable $project := request:get-parameter('project', ());
declare variable $username := request:get-parameter('user', ());
declare variable $corpus := request:get-parameter('corpus', ());


switch ($type)
   case "dashboard" return teiEditor:dashboard(())
   case "dashboard4corpus" return teiEditor:dashboard($corpus)
   case "loginForm" return teiEditor:loginForm($project, $username)
   case "newUserForm" return teiEditor:newUserForm($project) 
   case "createUser" return teiEditor:createUser($data, $project)
   case "newDocument" return teiEditor:newDocument($data, $project)
   case "newDocumentFromExternalResource" return teiEditor:newDocumentFromExternalResource($data, $project)
   case "newCollection" return teiEditor:newCollection($data, $project)
   case "saveData" return teiEditor:saveData($data, $project)
   case "addData" return teiEditor:addData($data, $project)
   case "addGroupData" return teiEditor:addGroupData($data, $project)
   
   case "addBiblio" return teiEditor:addBiblio($data, $project)
   case "addProjectPerson" return teiEditor:addProjectPersonToDoc($data, $project)
   case "addPlace" return teiEditor:addPlaceToDoc($data, $project)
   case "addProjectPlace" return teiEditor:addProjectPlaceToDoc($data, $project)


   case "removeItemFromList" return teiEditor:removeItemFromList($data, $project)
   case "saveText" return teiEditor:saveText($data, $project)
   case "saveTextarea" return teiEditor:saveTextarea($data, $project)
   case "saveFile" return teiEditor:saveFile($data, $project)
   
  case "epiconverter" return teiEditor:epiConverter()
   
   default return null
