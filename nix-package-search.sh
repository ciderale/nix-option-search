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
HEADER='include "package-formats";header'

(
jq -L "$JQLIB" -n -r "$HEADER" --raw-output0
nix search "$NIXPKGS_EXPR" --json "${1:-.}" | jq -L "$JQLIB" "$LISTING" --raw-output0 --exit-status
) | fzf --exit-0 \
    --exact --reverse \
    --header-border --header-label "Flake: $NIXPKGS_EXPR" --header-label-pos 3 \
    --preview "nix eval --json '$FLAKE#{1}.meta' --json | jq -L $JQLIB -r '$PREVIEW'" \
    --read0 --delimiter '\t' --accept-nth 1 --with-nth 2.. \
    --prompt="Nix Packages Search (Press ? for help)> " \
    --bind "?:preview:echo \"$INFO\"" \
    --header-lines 1 \
    --no-hscroll \
    --preview-window=bottom,wrap \
    --tiebreak=chunk,begin
