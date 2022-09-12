xquery version "3.1";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "json";
declare option output:media-type "application/javascript";

declare variable $project :=request:get-parameter('project', "");
declare variable $lang :=request:get-parameter('lang', "");

util:binary-to-string(
util:binary-doc("/db/apps/" || $project || "Data/lists/people.json")
)