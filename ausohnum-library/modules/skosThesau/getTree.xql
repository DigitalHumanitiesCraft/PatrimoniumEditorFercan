xquery version "3.1";

declare namespace json="http://www.json.org";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
(:declare option output:method "adaptative";:)
(:declare option output:media-type "application/json";:)

let $project :=request:get-parameter('project', ())
        let $lang := request:get-parameter('lang', ())
        let $dataFormat:= request:get-parameter('dataFormat', ())
        let $appParam := doc('/db/apps/' || $project || '/data/app-general-parameters.xml')
        let $thesaurus-app := $appParam//thesaurus-app/text()
        let $currentUser := sm:id()//sm:real/sm:username/string()
        let $groups := string-join(sm:get-user-groups($currentUser), ' ')
        let $userGroups := 
                for $group in tokenize($groups, " ") return (string($group))
        let $concepts := doc('/db/apps/' || $thesaurus-app || 'Data/thesaurus/thesaurus-as-tree.xml')//thesaurus[@xml:lang=$lang]
         
        let $thesaurus :=
                if(contains($groups, ('thesaurus_editors'))) then 
                        $concepts//children[@groups]        
                else (
                        
                        $concepts//children[@groups][contains(./@status, "published")],
                        $concepts//children[contains(./@groups, $userGroups)])
        return
        switch($dataFormat)
            case "json" return
        (serialize(
        <children xmlns:json="http://www.json.org" json:array="true">
    <title>Thesaurus ausohnum</title>
    <id>c1</id>
    <key>c1</key>
    <isFolder>true</isFolder>
    <orderedCollection json:literal="true">true</orderedCollection>
    <lang>en</lang>
        { $thesaurus }
        </children>,  <output:serialization-parameters>
                <output:method>{ $dataFormat}</output:method>
                <output:media-type>application/{ $dataFormat }</output:media-type>
            </output:serialization-parameters>
        ),
        response:set-header("media-type", "application/json"),
        response:set-header("method", "json")
        )
        case "xml" return 
            ((<children xmlns:json="http://www.json.org" json:array="true">
                <title>Thesaurus ausohnum</title>
                <id>c1</id>
                <key>c1</key>
                <isFolder>true</isFolder>
                <orderedCollection json:literal="true">true</orderedCollection>
                <lang>en</lang>
            { $thesaurus}
            </children>),
            response:set-header("media-type", "application/xml"),
            response:set-header("method", "xml"))
        default return 
        <children xmlns:json="http://www.json.org" json:array="true">
                <title>Thesaurus ausohnum</title>
                <id>c1</id>
                <key>c1</key>
                <isFolder>true</isFolder>
                <orderedCollection json:literal="true">true</orderedCollection>
                <lang>en</lang>
            { $thesaurus}
            </children>

