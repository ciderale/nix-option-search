include "formatting";

def removeLegacyPackages: sub("[^.]*.[^.]*.";"");

# tab separated column, with 1 element being the full package name
def listing_padding:
  [.[0], pad(.[1]; 10), pad(.[2]; 20), .[3]] | @tsv;

def header: [
  "Key",
  "Version",
  "Package",
  "Descrition"
] | listing_padding;

def listing: to_entries | map([
  .key,
  .value.version,
  (.key|removeLegacyPackages),
  .value.description
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
