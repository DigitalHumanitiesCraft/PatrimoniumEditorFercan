(:~
: AusoHNum Library - spatial data manager module
: This function updates  the project place gazetteer. This should be used through a job-scheduler so that it is run each time a modification is made on a  place.
: @author Vincent Razanajao
: @param name of the project
: @return This function updates the place gazetteer stored in the front-end project application for Data > /places/project-places-gazetteer.xml, and returns an empty sequence.
:)


xquery version "3.1";


(:import module namespace spatiumStructor="http://ausonius.huma-num.fr/spatiumStructor" at "./spatiumStructor.xql";:)
import module namespace functx="http://www.functx.com";
import module namespace spatiumStructor="http://ausonius.huma-num.fr/spatiumStructor" at "spatiumStructor.xql";
import module namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/" at "../skosThesau/skosThesauApp.xql";
import module namespace util = "http://exist-db.org/xquery/util";

declare namespace trigger = "http://exist-db.org/xquery/trigger";

declare namespace json="http://www.json.org";

declare namespace apc="http://patrimonium.huma-num.fr/onto#";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace dct = "http://purl.org/dc/terms/";
declare namespace dcterms="http://purl.org/dc/terms/";
declare namespace ev = "http://www.w3.org/2001/xml-events";
declare namespace geo = "http://www.w3.org/2003/01/geo/wgs84_pos#";
declare namespace http="http://expath.org/ns/http-client";

declare namespace lawdi="http://lawd.info/ontology/";
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

declare option output:indent "yes";
(: Switch to JSON serialization :)
(:
declare option output:method "xml";
declare option output:media-type "text/xml";:)

declare variable $local:project external;

(:let $project := "patrimonium":)
let $library-path := "/db/apps/ausohnum-library/"
let $places := collection("/db/apps/" || $local:project || "Data/places" || "/" || $local:project)//rdf:RDF
let $appVariables := doc("/db/apps/" || $local:project || "/data/app-general-parameters.xml")
let $placesGazetteer := doc("/db/apps/" || $local:project || "Data/places/project-places-gazetteer.xml")
let $now := fn:current-dateTime()
let $currentUser := data(sm:id()//sm:username)

let $lastUpdate := xs:dateTime(data(spatiumStructor:getLastUpdatePlace($local:project)[1]/@lastModified))
let $gazetteerDate := xs:dateTime( doc("/db/apps/" || $local:project || "Data/places/project-places-gazetteer.xml")//last-update/text())
(:let $updateGazetteer := 
            if ($lastUpdate > $gazetteerDate ) then 
        update replace doc("/db/apps/" || $project || "Data/places/project-places-gazetteer.xml")//places with spatiumStructor:buildProjectPlacesCatalogue($project)
                else (util:log("INFO", "No update"))         :)   
return 
         if ($lastUpdate > $gazetteerDate ) then (
         update replace doc("/db/apps/" || $local:project || "Data/places/project-places-gazetteer.xml")//places with spatiumStructor:buildProjectPlacesCatalogue($local:project),
         util:log("INFO", "Places gazetteer of project " || $local:project || " updated after a place record had been updated.")
         )
                else ()






