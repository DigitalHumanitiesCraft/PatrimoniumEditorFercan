xquery version "3.1";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:indent "yes";
declare option output:method "json";
declare option output:media-type "text/javascript";
declare option output:json-ignore-whitespace-text-nodes "yes";
declare variable $project := request:get-parameter("project", ());
declare variable $list:= doc("/db/apps/" || $project || "Data/lists/list-documents.xml");

$list/documentsList/root