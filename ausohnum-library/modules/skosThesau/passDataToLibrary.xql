xquery version "3.1";

import module namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/skosThesau/skosThesauApp.xql";

declare option exist:timeout "60000";

declare variable $type := request:get-parameter('type', ());
declare variable $lang := request:get-parameter('lang', ());
declare variable $dataFormat := request:get-parameter('dataFormat', ());
declare variable $conceptId := request:get-parameter('conceptId', ());
declare variable $conceptUri := request:get-parameter('conceptUri', ());
declare variable $project:= request:get-parameter('project', ());
declare variable $data := request:get-data();


skosThesau:processData($type, $data, $lang, $conceptId, $conceptUri, $project, $dataFormat)