xquery version "3.1";
declare namespace  scheduler="http://exist-db.org/xquery/scheduler";

import module namespace console="http://exist-db.org/xquery/console";
import module namespace functx="http://www.functx.com";
import module namespace spatiumStructor="http://ausonius.huma-num.fr/spatiumStructor" at "xmldb:exist:///db/apps/ausohnum-library/modules/spatiumStructor/spatiumStructor.xql"; 
let $projects := ("patrimonium", "gymnasia")
for $project in $projects
        let $projectName := functx:capitalize-first($project)
            let $scheduledJob := scheduler:get-scheduled-jobs()//scheduler:job[@name[contains(., ($projectName))]]
                return 
                    switch($scheduledJob//state/text())
                    case "NORMAL" return (console:log("Job already scheduled for ", $project))
                    case "COMPLETE" return (
                            scheduler:delete-scheduled-job("updatePlacesGazetteer" || $projectName),
                            spatiumStructor:setGazetteerSynchro($project),
                            console:log("Job for was Completed and rescheduled for ", $project))
                    default return (spatiumStructor:setGazetteerSynchro($project),
                                            console:log("Job created and scheduled for ", $project))
