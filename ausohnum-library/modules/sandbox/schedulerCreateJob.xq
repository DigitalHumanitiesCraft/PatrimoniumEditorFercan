xquery version "3.1";
import module namespace functx="http://www.functx.com";

let $projects := ("ausohnum")
(:let $deleteOld := scheduler:delete-scheduled-job("updatePlacesGazetteerPatrimonium"):)
for $project in $projects
    return
        scheduler:schedule-xquery-cron-job(
            "/db/apps/" || $project || "/modules/spatiumStructor/buildGazetteer.xql",
            "0/40 * * * * ?",
            "buildAndUpdatePlacesGazetteer" || functx:capitalize-first($project),
        <parameters>
            <param name="project" value="{ $project }"/>
        </parameters>
)
