xquery version "3.1";

import module namespace spatiumStructor="http://ausonius.huma-num.fr/spatiumStructor"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/spatiumStructor/spatiumStructor.xql";
import module namespace ausohnumSearch="http://ausonius.huma-num.fr/search"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/commons/search.xql";

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
   case "executeBuiltQuery" return ausohnumSearch:executeBuiltQuery($project, $data)
   case "searchDisplayResults" return ausohnumSearch:displayResults($data)
   case "executeftSearch" return ausohnumSearch:executeftSearch()
   case "getTextPreview" return ausohnumSearch:displayTextPreviewWithHighlight($project, $resource)

   default return null