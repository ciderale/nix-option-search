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

PREVIEW='include "package-formats";preview'
LISTING='include "package-formats";listing'

(echo -e "Version  \tPackage   \tDescription  \tKey"
nix search "$NIXPKGS_EXPR" --json "${1:-.}" | jq -L "$JQLIB" -r "$LISTING"
) | fzf --exit-0 --sync \
    --exact --reverse \
    --preview "nix eval --json '$FLAKE#{4}.meta' --json | jq -L $JQLIB -r '$PREVIEW'" \
    --delimiter '\t' --with-nth ..3 --accept-nth 2 \
    --prompt="Nixpkgs Search (Press ? for help)> " \
    --bind "?:preview:echo \"$INFO\"" \
    --header-lines 1 \
    --no-hscroll \
    --preview-window=bottom,wrap \
    --tiebreak=chunk,begin
