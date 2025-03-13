#!/usr/bin/env bash
NIXPKGS_EXPR=${NIXPKGS_EXPR:-nixpkgs}
FLAKE=${NIXPKGS_EXPR%%\#*}
INFO="$(cat <<EOF
    First word of Query is sent to nix search

    Additional words are filtering in fzf:
    - ! Prefix to exclude matches
    - ' To require exact matches
EOF
)"

NO_LEGACY_PACKAGE='def packageName: sub("[^.]*.[^.]*.";"")'
PAD='def pad(x;n): x + (" "*(x | n - length ))'
FMT='to_entries | map([pad(.value.version;10), pad(.key|packageName;15), .value.description, .key]|@tsv) | .[]'
LISTING="$PAD; $NO_LEGACY_PACKAGE; $FMT"
DETAIL='
[
    ([
        (if (.available) then "Available" else "" end),
        (if (.unsupported) then "Unsupported" else "" end),
        (if (.broken) then "Broken" else "" end),
        (if (.unfree) then "Unfree" else "" end),
        (if (.insecure) then "Insecure" else "" end)
        ] | join("\t")
    ),
    "======",
    "Name:       \t" + .name,
    "Homepage:   \t" + .homepage,
    "Description:\t" + .description,
    (if (.longDescription>"") then "====== Long Description\n"+ .longDescription else "" end),
    "====== Platform",
    (.platforms|sort|join(","))
] | join("\n")
'

(echo -e "Version  \tPackage   \tDescription  \tKey"
nix search "$NIXPKGS_EXPR" --json "${1:-.}" | jq -r "$LISTING"
) | fzf --exit-0 --sync \
    --exact --reverse \
    --preview "nix eval --json '$FLAKE#{4}.meta' --json | jq -r '$DETAIL'" \
    --delimiter '\t' --with-nth ..3 --accept-nth 2 \
    --prompt="Nixpkgs Search (Press ? for help)> " \
    --bind "?:preview:echo \"$INFO\"" \
    --header-lines 1 \
    --no-hscroll \
    --preview-window=bottom,wrap \
    --tiebreak=chunk,begin
