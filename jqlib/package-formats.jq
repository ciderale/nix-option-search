include "formatting";

def removeLegacyPackages: sub("[^.]*.[^.]*.";"");

def listing:
  to_entries | map([pad(.value.version;10), pad(.key|removeLegacyPackages;15), .value.description, .key]|@tsv) | .[];


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
  "====== Platform",
  (.platforms|sort|join(","))
] | join("\n");
