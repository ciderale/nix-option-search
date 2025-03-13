include "formatting";

def removeLegacyPackages: sub("[^.]*.[^.]*.";"");

def listing_padding:
  [pad(.[0]; 10), pad(.[1]; 20), .[2], .[3]] | @tsv;

def header: [
  "Version",
  "Package",
  "Descrition",
  "Key"
] | listing_padding;

def listing: to_entries | map([
  .value.version,
  (.key|removeLegacyPackages),
  .value.description, .key
] | listing_padding ) | .[];


def preview: [
  "======",
  colored_text("Name:       \t";"bold") + colored_text(.name; "blue"),
  colored_text("Homepage:   \t";"bold") + .homepage,
  colored_text("Description:\t";"bold") + .description,
  ([
   flagText(.available;"Available";"green"),
   flagText(.unsupported;"Unsupported";"yellow"),
   flagText(.broken;"Broken";"red"),
   flagText(.unfree;"Unfree";"yellow"),
   flagText(.insecure;"Insecure";"red")
  ] | join("\t")
  ),
  (if (.longDescription>"") then "====== Long Description\n"+ .longDescription else "" end),
  (if (.platforms) then "====== Platform\n" + (.platforms|sort|join(",")) else "" end)
] | join("\n");
