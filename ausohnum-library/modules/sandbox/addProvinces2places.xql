xquery version "3.1";

import module namespace http="http://expath.org/ns/http-client" at "java:org.expath.exist.HttpClientModule";
import module namespace teiEditor="http://ausonius.huma-num.fr/teiEditor"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/teiEditor/teiEditorApp.xql";
import module namespace prosopoManager="http://ausonius.huma-num.fr/prosopoManager"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/prosopoManager/prosopoManager.xql";

import module namespace functx="http://www.functx.com";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare namespace lawd="http://lawd.info/ontology/";
declare namespace apc="http://patrimonium.huma-num.fr/onto#";
declare namespace foaf="http://xmlns.com/foaf/0.1/"; 
declare namespace pleiades="https://pleiades.stoa.org/places/vocab#";
declare namespace owl="http://www.w3.org/2002/07/owl#";
declare namespace skos="http://www.w3.org/2004/02/skos/core#"; 
declare namespace geo="http://www.w3.org/2003/01/geo/wgs84_pos#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace dcterms="http://purl.org/dc/terms/";
declare namespace ausohnum="http://ausonius.huma-num.fr/onto";
declare namespace spatial="http://geovocab.org/spatial#";
declare boundary-space preserve;
declare variable $project := "patrimonium";
declare variable $placeCollection := collection("/db/apps/" || $project || "Data/places/" || $project );
declare variable $provinceTypeUris := "https://ausohnum.huma-num.fr/concept/c22264", "https://ausohnum.huma-num.fr/concept/c23737";
declare variable $adminDistrict := "https://ausohnum.huma-num.fr/concept/c23621";
declare variable $romanProvinces := ($placeCollection//pleiades:Place[pleiades:hasFeatureType[@rdf:resource="https://ausohnum.huma-num.fr/concept/c22264"]]
   ,
     $placeCollection//pleiades:Place[pleiades:hasFeatureType[@rdf:resource="https://ausohnum.huma-num.fr/concept/c23737"]]
   );
declare variable $romanProvincesUriList := string-join($romanProvinces//@rdf:about, " ");

let $places := collection('xmldb:exist:///db/apps/patrimoniumData/places/patrimonium')

    return <result>{ $romanProvinces }</result>