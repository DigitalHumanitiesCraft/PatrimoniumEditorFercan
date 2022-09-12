xquery version "3.1";

import module namespace mail="http://exist-db.org/xquery/mail" at "java:org.exist.xquery.modules.mail.MailModule";

declare namespace jmx="http://exist-db.org/jmx";

let $now := fn:current-dateTime()
let $receiversAdmin := "vincent.razanajao@u-bordeaux-montaigne.fr, vrazanajao@gmail.com"
let $receiversPatrimonium := "alberto.dallarosa@u-bordeaux-montaigne.fr, dierove@hotmail.com, Hernan.Gonzalez-Bordas@u-bordeaux-montaigne.fr, lina.girdvainyte@u-bordeaux-montaigne.fr, slavtcho.kirov@u-bordeaux-montaigne.fr, nicolas.solonakis@u-bordeaux-montaigne.fr, davide.faoro@u-bordeaux-montaigne.fr, yanne.broux@u-bordeaux-montaigne.fr, sofia.piacentin@u-bordeaux-montaigne.fr"

let $receiversGymnasia := "Matthias.Pichler@campus.lmu.de, julie.bernini338@gmail.com, chirica@gmail.com, jackschropp@yahoo.de"
let $title := "Server relaunched"
let $message := <div>
                <p>Dear All,</p>
                <p>Due to a memory issue, the server had to be relaucnhed. Please do not forget to log in again from the project home page before entering a restricted access page.</p>
                <p>Admin</p>
                </div>

let $email :=
<mail>
        <from>Exist-db Admin</from>
        {
            for $receiver in (
                tokenize($receiversAdmin, ", ")
                , tokenize($receiversPatrimonium, ", ")
                , tokenize($receiversGymnasia, ", ")
                )
            return <to>{ $receiver }</to>
            
        }
        <subject>Serveur Existdb has been relaunched</subject>
        <message>
            <xhtml>
                <html>
                    <head>
                        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
                        <title>Serveur Existdb has been relaunched</title>
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