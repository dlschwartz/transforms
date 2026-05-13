xquery version "3.1";

(: Vibe-coded using Copilot :)

import module namespace file="http://expath.org/ns/file";

(: =========================
   CONFIGURATION
   ========================= :)
declare variable $input-dir := "C:/Users/daniel.schwartz/Desktop/Schemas/NHSLSchemaTesting/tei"; 
declare variable $output-file := "C:/Users/daniel.schwartz/Downloads/xml_paths_with_attributes.txt";

(: =========================
   LOAD DOCUMENTS
   ========================= :)
let $docs := collection($input-dir)

(: =========================
   BUILD ELEMENT PATHS
   ========================= :)
let $element-paths :=
  for $node in $docs//*
  return concat("/", string-join($node/ancestor-or-self::* ! name(), "/"))

(: =========================
   BUILD ATTRIBUTE PATHS
   ========================= :)
let $attribute-paths :=
  for $node in $docs//*
  let $base-path :=
    concat("/", string-join($node/ancestor-or-self::* ! name(), "/"))
  for $attr in $node/@*
  return concat($base-path, "/@", name($attr))

(: =========================
   COMBINE ALL PATHS
   ========================= :)
let $all-paths := ($element-paths, $attribute-paths)

(: =========================
   GROUP + COUNT
   ========================= :)
let $counts :=
  for $p in distinct-values($all-paths)
  let $count := count($all-paths[. = $p])
  order by $p
  return concat($p, "&#9;", $count)

(: =========================
   FORMAT OUTPUT
   ========================= :)
let $text :=
  string-join(
    ("path&#9;count", $counts),
    "&#10;"
  )

(: =========================
   WRITE FILE
   ========================= :)
return file:write-text($output-file, $text)