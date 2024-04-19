xquery version "3.1";

import module namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/skosThesau/skosThesauApp.xql";

declare variable $type := request:get-parameter('type', ());
declare variable $lang := request:get-parameter('lang', ());
declare variable $conceptId := request:get-parameter('conceptId', ());
declare variable $project:= request:get-parameter('project', ());
declare variable $data := request:get-data();
declare variable $conceptUri := "/concepts/" || $conceptId;
switch($type)
(: case "processData" return skosThesau:processData($type, $data, $lang, $conceptId, '', $project) :)
case "getTreeFromConcept" return skosThesau:getTreeFromConcept($project, $conceptUri, $lang)

default return ()