xquery version "3.1";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare variable $data := request:get-data();
    let $now := fn:current-dateTime()    
    let $firstName := $data//newUserFirstName/text()
    let $lastName := $data//newUserLastName/text()
    let $username := $data//newUserUsername/text()
    let $password := $data//newUserPassword/text()
    let $logs := collection("/db/apps/ausohnumData/logs")
    let $log :=  update insert
         <log>{$firstName || " " || $lastName || " " || $username || " " || $password }</log>
         into $logs/rdf:RDF/id('all-logs')

    
    let $createUser := sm:create-account( $username ,
                                                                $password, 
                                                                "sandbox",
                                                                $firstName  || " " || $lastName, 
                                                                "Self created account on " || $now)
    let $cleanGroup := sm:remove-group($username)
    return
    "OK"