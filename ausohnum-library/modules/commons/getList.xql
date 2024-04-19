xquery version "3.1";

import module namespace ausohnumCommons="http://ausonius.huma-num.fr/commons"
      at "./commonsApp.xql";
declare variable $type := request:get-parameter('listType', ());
declare variable $resourceId:= request:get-parameter('resourceId', ());

switch ($type)
case "relatedPlaces" return ausohnumCommons:getRelatedPlacesList($resourceId)
case "relatedPeople" return ausohnumCommons:getRelatedPeopleList($resourceId)
case "relatedDocuments" return ausohnumCommons:getRelatedDocumentsList($resourceId)
case "temporalScale" return ausohnumCommons:getTemporalScale($resourceId)
default return null