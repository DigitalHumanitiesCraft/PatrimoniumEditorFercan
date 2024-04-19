xquery version "3.1";
declare variable $conceptId := request:get-parameter("conceptId", ());
declare variable $lang := request:get-parameter("lang", "en");


<div
    id="conceptContent"
    data-template="processConcept:fullConcept"
    data-template-conceptId="{$conceptId}"
    data-template-language="{$lang}"/>
