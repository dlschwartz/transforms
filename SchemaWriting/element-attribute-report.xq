xquery version "3.1";

(: Vibe-coded using Copilot :)

import module namespace file="http://expath.org/ns/file";

(: =========================
   CONFIGURATION
   ========================= :)
declare variable $input-dir := "C:/Users/daniel.schwartz/Desktop/Schemas/NHSLSchemaTesting/tei"; 
declare variable $output-file := "C:/Users/daniel.schwartz/Downloads/element_attributes.tsv";

(: =========================
   LOAD DOCUMENTS
   ========================= :)
let $docs := collection($input-dir)

(: =========================
   UNIQUE + SORTED ELEMENTS
   ========================= :)
let $elements :=
  sort(
    distinct-values($docs//*[name()]/name())
  )

(: =========================
   MAP ELEMENT -> ATTRIBUTES
   ========================= :)
let $element-attrs :=
  for $e in $elements
  let $attrs :=
    sort(
      distinct-values(
        $docs//*[name() = $e]/@*/name()
      )
    )
  return map {
    "element": $e,
    "attributes": $attrs
  }

(: =========================
   MAX ATTRIBUTE COUNT
   ========================= :)
let $max-attrs :=
  max(
    for $ea in $element-attrs
    return count($ea?attributes)
  )

(: =========================
   HEADER ROW (TSV)
   ========================= :)
let $header :=
  string-join(
    (
      "elements",
      for $i in 1 to $max-attrs
      return concat("attribute", $i)
    ),
    "&#9;"   (: tab :)
  )

(: =========================
   DATA ROWS
   ========================= :)
let $rows :=
  for $ea in $element-attrs
  let $attrs := $ea?attributes

  (: pad attributes so all rows have equal columns :)
  let $padded :=
    (
      $attrs,
      for $i in 1 to ($max-attrs - count($attrs))
      return ""
    )

  return string-join(
    ($ea?element, $padded),
    "&#9;"   (: tab :)
  )

(: =========================
   FINAL TSV CONTENT
   ========================= :)
let $tsv :=
  string-join(($header, $rows), "&#10;")  (: newline :)

(: =========================
   WRITE FILE
   ========================= :)
return file:write-text($output-file, $tsv)