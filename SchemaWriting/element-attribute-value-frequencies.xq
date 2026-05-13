xquery version "3.1";

(: Vibe-coded using Copilot :)

import module namespace file="http://expath.org/ns/file";

(: =========================
   CONFIGURATION
   ========================= :)
declare variable $input-dir := "C:/Users/daniel.schwartz/Desktop/Schemas/NHSLSchemaTesting/tei"; 
declare variable $output-file := "C:/Users/daniel.schwartz/Downloads/element_attribute_value_frequencies.tsv";

(: =========================
   LOAD DOCUMENTS
   ========================= :)
let $docs := collection($input-dir)

(: =========================
   FIND DISTINCT (ELEMENT, ATTRIBUTE) PAIRS
   ========================= :)
let $pairs :=
  distinct-values(
    for $node in $docs//*[@*]
    let $e := name($node)
    for $attr in $node/@*
    return concat($e, "|||", name($attr))
  )

(: =========================
   PROCESS EACH PAIR
   ========================= :)
let $results :=
  for $p in $pairs
  let $parts := tokenize($p, "\|\|\|")
  let $e := $parts[1]
  let $a := $parts[2]

  (: Collect all tokenized values :)
  let $all-values :=
    for $attr in $docs//*[name() = $e]/@*[name() = $a]
    return tokenize(normalize-space(string($attr)), "\s+")

  let $distinct-values := distinct-values($all-values)

  (: Only include attributes with <= 20 unique values :)
  where count($distinct-values) le 20

  (: Count each value :)
  for $v in $distinct-values
  let $count := count($all-values[. = $v])

  order by $e, $a, $count descending

  return concat($e, "&#9;", $a, "&#9;", $v, "&#9;", $count)

(: =========================
   HEADER + OUTPUT
   ========================= :)
let $tsv :=
  string-join(
    ("element&#9;attribute&#9;value&#9;count", $results),
    "&#10;"
  )

return file:write-text($output-file, $tsv)