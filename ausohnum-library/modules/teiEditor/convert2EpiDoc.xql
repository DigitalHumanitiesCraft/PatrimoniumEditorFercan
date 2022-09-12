xquery version "3.1";

let $textInput := 
"A[elio – – –
Tu[lli – – –"

(:New lines:)
 (:Line numbers         :)
let $lineSeparator := if (contains($textInput, "/")) then "/" else "\n"
let $lineNumber := count(tokenize($textInput,  $lineSeparator))
                    
let $textInput := 
 "<lb n='1'/> " || string-join(
                            (for $line at $count in tokenize($textInput, $lineSeparator)
                                
                                let $newLine :=
                                    if (contains($line, "-")) then
                                    
                                     replace($line, '-', '') || codepoints-to-string(10) || "<lb n='"||
                                        $count +1 || "' break='no'/>"
                                else 
                                    $line || codepoints-to-string(10) || 
                                    (if ($count < $lineNumber)
                                        then "<lb n='"||$count +1 || "'/>"
                                         else ()
                                    )
                            return 
                            $newLine),
                    "")
(:let $textInput := "<lb n='1'/> " || $textInput:)

        
(:let $regex := "\\n|\\r":)
(:let $replacement := '\\n' || "ff":)
(:let $textInput := replace($textInput,:)
(:                            $regex,:)
(:                            $replacement, 'm':)
(:                       ):)


(::)
(:Corrections:)
(::)
(:<t>]:)
let $regex := "<(\w*)>"
let $replacement := "<supplied reason='omitted'>$1</supplied>"
let $textInput := replace($textInput,
                            $regex,
                            $replacement, "")
(::)
(:Superfluous:)
(::)

let $regex := "\{(\w*)\}"
let $replacement := "<surplus>$1</surplus>"
let $textInput := replace($textInput,
                            $regex,
                            $replacement, "")

(::)
(:Gaps and Lacunaes:)
(::)

(:Line in Lacuna [— — — —]:)
let $regex := "\[(— — — —)\]"
let $replacement := "<gap unit='line'/>"
let $textInput := replace($textInput,
                            $regex,
                            $replacement, "")

let $regex := "\-"    (:CANNOT GET HYPHEN:)
let $replacement := "<gap unit='line'/>"
let $textInput := replace($textInput,
                            $regex,
                            $replacement, "")
  
let $regex := "\[(\w*)\((\w*)\)(\])"
let $replacement := "<supplied reason='lost'><expan><abbr>$1</abbr><ex>$2</ex></expan></supplied>"
let $textInput := replace($textInput,
                            $regex,
                            $replacement, "")




(:Abbreviations in lacunae:)
let $regex := "\[(\w*)\((\w*)\)(\])"
let $replacement := "<supplied reason='lost'><expan><abbr>$1</abbr><ex>$2</ex></expan></supplied>"
let $textInput := replace($textInput,
                            $regex,
                            $replacement, "")

(:Abbreviation with uncertain resolution:)
let $regex := "(\w*)\((\w*)\?\)"
let $replacement := "<expan><abbr>$1</abbr><ex cert='low'>$2</ex></expan>"
let $textInput := replace($textInput,
                            $regex,
                            $replacement, "")

(:Basic Abbreviations:)
let $regex := '(\w*[aA-zZ]*)\((\w*[aA-zZ]*)\)'
let $replacement := '<expan><abbr>$1</abbr><ex>$2</ex></expan>'
let $textInput := replace($textInput,
                            $regex,
                            $replacement, "")

(:Lacunae not ended in original text:)
let $regex := "\[(\w*)\s*(— — —)*"
let $replacement := "<supplied reason='lost'>$1</supplied><gap reason='lost' extent='unknown'/>"
let $textInput := replace($textInput,
                            $regex,
                            $replacement, "")

 
 (:supplied:)
let $textInput := replace($textInput, '\[', "<supplied reason='lost'>")
let $textInput := replace($textInput, '\]', '</supplied>')

(:Dotted letters:)
let $regex := '(\w)̣'
let $replacement := '<unclear>$1</unclear>'
let $textInput := replace($textInput,
                            $regex,
                            $replacement, "")
    
return
    $textInput
(:    parse-xml("<ab>" || $textInput || "</ab>"):)