xquery version "3.1";

import module namespace mail="http://exist-db.org/xquery/mail" at "java:org.exist.xquery.modules.mail.MailModule";

declare namespace jmx="http://exist-db.org/jmx";

let $now := fn:current-dateTime()
let $receiversAdmin := "vincent.razanajao@u-bordeaux-montaigne.fr"
(:, "alberto.dallarosa@u-bordeaux-montaigne.fr"):)
let $data := request:get-data()

let $receiversGymnasia := "Matthias.Pichler@campus.lmu.de, julie.bernini338@gmail.com, chirica@gmail.com, jackschropp@yahoo.de"
let $title := "Server relaunched"
let $message := <div>
                <p>Dear Patrimonium Admin</p>
                <p>The following message has been sent by { $data//name/text()} through the Contact Form:</p>
                <p>{ $data//message/text()}</p>
                </div>

let $email :=
<mail>
        <from>Patrimonium Contact Form</from>
        {
            for $receiver in $receiversAdmin
                return <to>{ $receiver }</to>
        }
        <subject>[Patrimonium] Message from { $data//name/text()}</subject>
        <message>
            <xhtml>
                <html>
                    <head>
                        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
                        <title>[Patrimonium] Message from { $data//name/text()}</title>
                    </head>
                    <body>
                        {$message}
                    </body>
                </html>
            </xhtml>
        </message>
        
    </mail>

return

mail:send-email($email, (), "UTF-8")