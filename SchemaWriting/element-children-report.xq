xquery version "3.1";

import module namespace file="http://expath.org/ns/file";

(: =========================
   CONFIGURATION
   ========================= :)
declare variable $input-dir := "C:/Users/daniel.schwartz/Desktop/Schemas/NHSLSchemaTesting/tei"; 
declare variable $output-file := "C:/Users/daniel.schwartz/Downloads/element_children_report.tsv";

(: =========================
   LOAD DOCUMENTS
   ========================= :)
let $docs := collection($input-dir)

(: =========================
   GET DISTINCT ELEMENTS
   ========================= :)
let $elements :=
  sort(
    distinct-values($docs//* ! name())
  )

(: =========================
   MAP ELEMENT -> CHILDREN (+ text test)
   ========================= :)
let $element-children :=
  for $e in $elements

  (: child elements :)
  let $child-elements :=
    distinct-values(
      $docs//*[name() = $e]/* ! name()
    )

  (: text node test :)
  let $has-text :=
    exists(
      $docs//*[name() = $e]/text()[matches(., "\w")]
    )

  (: combine children + optional text() :)
  let $children :=
    sort(
      (
        $child-elements,
        if ($has-text) then "text()" else ()
      )
    )

  return map {
    "element": $e,
    "children": $children
  }

(: =========================
   MAX CHILD COUNT
   ========================= :)
let $max-children :=
  max(
    for $ec in $element-children
    return count($ec?children)
  )

(: =========================
   HEADER
   ========================= :)
let $header :=
  string-join(
    (
      "element",
      for $i in 1 to $max-children
      return concat("child", $i)
    ),
    "&#9;"
  )

(: =========================
   ROWS
   ========================= :)
let $rows :=
  for $ec in $element-children
  let $children := $ec?children

  let $padded :=
    (
      $children,
      for $i in 1 to ($max-children - count($children))
      return ""
    )

  return string-join(
    ($ec?element, $padded),
    "&#9;"
  )

(: =========================
   FINAL TSV
   ========================= :)
let $tsv :=
  string-join(($header, $rows), "&#10;")

return file:write-text($output-file, $tsv)