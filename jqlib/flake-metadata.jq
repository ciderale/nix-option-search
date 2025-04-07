include "formatting";

def flakeRef:
	if (.type == "tarball") then .url
	else .type + ":" + .owner +"/" + .repo + "/" +.rev
	end;

def flakeRefWithHash:
	(. | flakeRef) + "?narHash" + .narHash;

def myformat:
	{ref: . | flakeRefWithHash, lastModified: .lastModified | todateiso8601 };

def asList:
	to_entries | map(.value + {key: .key});

def padding:
	[.[0], pad(.[1];9), pad(.[2];20), pad(.[3];20), .[4]];

def display: .[] | padding | @tsv;

def header: [[
  "args",
	"Type",
	"Name",
	"Last Modified",
	"FlakeRef"
]] | display;


def packages:
	["packages,"+.ref, "packages", .key, .lastModified, .ref];

def detectOption:
	if .ref | contains("nixpkgs") then
		"nixos"
	elif .ref | contains("home-manager") then
		"home-manager"
	elif .ref | contains("devenv") then
		"devenv"
	elif .ref | contains("kubenix") then
		"kubenix"
	else
		empty
	end;

def options:
  (. | detectOption) as $optionType | [
	  "options,"+$optionType+","+.ref,
		"options", $optionType, .lastModified, .ref
  ];

def generateSelection:
	packages, options;

def root_inputs:
	.locks.nodes as $nodes | $nodes.root.inputs | map_values($nodes[.]);

def list:
	root_inputs | map_values(select(.locked) | .locked | myformat) | asList | map(generateSelection) | display;

def static: [
    ({ref: "nixpkgs", key: "nixpkgs", lastModified: "latest"} | packages),
    ({ref: "nixpkgs/nixpkgs-unstable", key: "nixpkgs-unstable", lastModified: "latest"}| packages),
    ({ref: "nixpkgs/nixpkgs-unstable", key: "nixos-unstable", lastModified: "latest"}| options),
    ({ref: "github:cachix/devenv", key: "devenv", lastModified: "latest"} | options),
    ({ref: "github:hall/kubenix", key: "kubenix", lastModified: "latest"} | options),
		empty
	] | display;
