include "formatting";

def default_str:
  if .readOnly then ("READONLY: " + .default.text)
  else .default.text // empty
  end;

def format_declarations:
  tostring | sub("{";"{\n  ") | sub("}";"\n}") | sub(",";"\n  ");

def example_block:
  if .example.text > 0
  then [
    "──────────────────────────────────────────────────────────────",
    colored_text("Example:"; "bold"),
    "",
    colored_text(.example.text; "yellow")
    ]
  else []
  end;

def main_block(name): [
  colored_text("Name:"; "bold") + "\t\t" + name,
  colored_text("Type:"; "bold") + "\t\t" + .type,
  colored_text("Declaration:"; "bold") + "\t" + colored_text(.declarations[] | format_declarations; "blue"),
  colored_text("Default:"; "bold") + "\t" + (. | default_str),
  "──────────────────────────────────────────────────────────────",
  colored_text("Description:"; "bold"),
  "",
  .description,
  ""
];

def preview(name): .[name] | (main_block(name) + example_block) | join("\n");
def declaration(name): .[name].declarations[];

# tab separated column, with 1 element being the option
def listing1:
  keys | map([.,.] |@tsv) | .[];

def listing2_detail:
  "   " + (.value.description // empty) | gsub("\\n"; " ");

def listing2: to_entries | map(
  [ ([.key, .key] | @tsv), listing2_detail, "" ] | join("\n")
) | .[];
