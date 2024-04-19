xquery version "3.1";

(:import module namespace spatiumStructor="http://ausonius.huma-num.fr/spatiumStructor" at "./spatiumStructor.xql";:)
import module namespace functx="http://www.functx.com";
(:import module namespace spatiumStructor="http://ausonius.huma-num.fr/spatiumStructor" at "prosopoManager.xql";:)
declare namespace json="http://www.json.org";

declare namespace apc="http://patrimonium.huma-num.fr/onto#";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace dct = "http://purl.org/dc/terms/";
declare namespace dcterms="http://purl.org/dc/terms/";
declare namespace ev = "http://www.w3.org/2001/xml-events";
declare namespace geo = "http://www.w3.org/2003/01/geo/wgs84_pos#";
declare namespace http="http://expath.org/ns/http-client";

declare namespace lawd="http://lawd.info/ontology/";
declare namespace owl="http://www.w3.org/2002/07/owl#";
declare namespace pleiades="https://pleiades.stoa.org/places/vocab#";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfs = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace spatial="http://geovocab.org/spatial#";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace thot = "http://thot.philo.ulg.ac.be/";
declare namespace xf = "http://www.w3.org/2002/xforms";
declare namespace local = "local";


(:declare option exist:serialize "method=xml media-type=xml";:)

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare boundary-space preserve;


(: Switch to JSON serialization :)
declare option output:method "json";
declare option output:media-type "text/javascript";

declare variable $project :=request:get-parameter('project', "patrimonium");
declare variable $peopleCollection := collection("/db/apps/" || $project || "Data/people");
  <root>{
  for $person in $peopleCollection//lawd:person
      let $name := $person//lawd:personalName[1]/text()
      let $uri := $person/@rdf:about
      let $id := substring-before(functx:substring-after-last($uri, "/"), "#")
      let $exactMacthes := string-join($person//skos:exactMatch/@rdf:resource, " ")
      order by $name

      return
                <data json:array="true">
                    <name>{$name}</name>
                    <id>{ $id }</id>
                    <exactMatches>{$exactMacthes}</exactMatches></data>}
  </root>
