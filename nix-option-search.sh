#!/usr/bin/env bash
# set -x #debugging

OPTIONSEARCH=$0

LISTING=${LISTING:-1}
function formatOptions() {
      jq -L "$JQLIB" --raw-output0 'include "option-formats";'" listing$LISTING" < "${OPTIONS_JSON}"
}

# the fzf search wrapper
function search() {
      formatOptions \
            | fzf --exit-0 --exact \
            --read0 --delimiter '\t' --with-nth 2.. \
            --reverse \
            --no-sort \
            --prompt="Nix Module Options (Press ? for help)> " \
            --bind '?:preview:echo -e "ctrl-v view source file\nctrl-u go to parent path of current option"' \
            --preview="bash $OPTIONSEARCH preview {1}" \
            --preview-window=wrap,down \
            --bind="ctrl-u:become(bash $OPTIONSEARCH refine {1} {q})" \
            --bind="ctrl-v:become(bash $OPTIONSEARCH source {1} {q} )" \
            --track \
            --query "$QUERY"
}

if [ $# == 0 ]; then

      if [ "${OPTIONS_JSON:-}" == "" ]; then
            echo "Missing OPTIONS_JSON. Define path via env var."
            echo ""
            echo "EnvVar: LISTING=1 (option only) or LISTING=2 (option+description)"
            exit 1
      fi

      QUERY="" search
elif [ "$1" == "source" ]; then
      shift 1;
      DECLARATION=$(jq -L "$JQLIB" 'include "option-formats"; declaration($option)' \
            --arg option "$1" -r < "$OPTIONS_JSON")
      exec vim "$DECLARATION"

elif [ "$1" == "preview" ]; then
      # set -x # debugging
      shift 1;
      jq -L "$JQLIB" 'include "option-formats"; preview($option)' \
            --arg option "$1" -r < "$OPTIONS_JSON"

elif [ "$1" == "refine" ]; then
      shift 1;

      SELECTED="$1"
      CURRENT_QUERY="$2"

      if [ "${LAST_QUERY:-nopreviousquery}" == "$CURRENT_QUERY" ]; then
            # consecutive calls to "refine" => go one level up
            # strip away right most part with '.' or '^' as separator
            # the ^ corresponds to the top-most element
            QUERY="${CURRENT_QUERY%[\^.]*}"
      else
            # define the parent of the selection as query
            QUERY="^${SELECTED%.*}"
      fi

      LAST_QUERY="$QUERY" search
fi;
