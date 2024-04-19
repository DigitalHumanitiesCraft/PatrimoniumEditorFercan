xquery version "3.1";
declare variable $conceptId :=  request:get-parameter("conceptId", ());
declare variable $lang :=  request:get-parameter("lang", "en");
declare variable $project :=  request:get-parameter("project", ());

<div id="conceptContent" data-template="skosThesau:templatingProcessConcept" data-template-conceptId="{$conceptId}" 
data-template-language="{$lang}" data-template-project="{$project}"/>
