xquery version "3.1";

declare default element namespace "http://www.tei-c.org/ns/1.0";

(: --- 1. THE PROCESSING FUNCTION --- :)
declare function local:copy($node as node()) as node()* {
    if ($node instance of document-node()) then
        (: Process everything at the top level: PIs, Comments, and the Root Element :)
        $node/node() ! local:copy(.)
    else if ($node instance of processing-instruction()) then
        (: This captures your xml-model declarations :)
        $node
    else if ($node instance of comment()) then
        $node
    else if ($node instance of element()) then
        let $ghosts := ('part', 'org', 'sample', 'full', 'status', 'anchored', 'default')
        let $clean-attrs := $node/@*[not(local-name(.) = $ghosts)]
        
        return
            if (local-name($node) eq 'ptr' and $node/@type eq 'noteAnchor') then
                element {node-name($node)} {
                    $clean-attrs[local-name(.) ne 'n'],
                    attribute n { count($node/preceding::*:ptr[@type='noteAnchor']) + 1 },
                    $node/node() ! local:copy(.)
                }
            else if (local-name($node) eq 'note') then
                element {node-name($node)} {
                    $clean-attrs[local-name(.) ne 'n'],
                    attribute n { count($node/preceding::*:note) + 1 },
                    $node/node() ! local:copy(.)
                }
            else if (local-name($node) eq 'ab') then
                element {node-name($node)} {
                    $clean-attrs[local-name(.) ne 'n'],
                    attribute n { count($node/preceding::*:ab) + 1 },
                    $node/node() ! local:copy(.)
                }
            else
                element {node-name($node)} {
                    $clean-attrs,
                    $node/node() ! local:copy(.)
                }
    else
        $node
};

(: --- 2. THE BATCH PROCESSING LOGIC --- :)

(: Update these paths! Use forward slashes even on Windows :)
let $input-path := "C:/Users/daniel.schwartz/Documents/GitHub/syriac-translations/PalladiusParadise/"
let $output-path := "C:/Users/daniel.schwartz/Desktop/BaseXOutput/"

let $serialization := 
  <output:serialization-parameters>
    <output:omit-xml-declaration value="no"/>
    <output:indent value="yes"/>
    <output:encoding value="UTF-8"/>
  </output:serialization-parameters>

for $file in file:list($input-path, false(), "*.xml")
    let $doc := doc($input-path || $file)
    (: We generate a sequence of nodes (PIs + Root) :)
    let $processed-sequence := local:copy($doc)
    
    return file:write($output-path || $file, $processed-sequence, $serialization)