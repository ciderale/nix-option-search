{
  writeShellApplication,
  nix-option-search-cli,
  nix-package-search,
  fzf,
  coreutils,
  jq,
}: let
  nix-discover-standalone = writeShellApplication {
    name = "nix-discover-standalone";
    runtimeInputs = [nix-option-search-cli nix-package-search fzf coreutils jq];
    runtimeEnv.JQLIB = ./jqlib;
    text = ''
      function option_json_path() {
        ARGS=(--no-link --print-out-paths)
        case "$TYPE" in
          nixos)
            ARGS+=(--impure --expr "(import (builtins.getFlake \"$FLAKE_REF\" + /nixos/release.nix) {}).options")
            JSON_PATH="/share/doc/nixos/options.json"
            ;;
          home-manager)
            ARGS+=("$FLAKE_REF#docs-json")
            JSON_PATH="/share/doc/home-manager/options.json"
            ;;
          devenv)
            ARGS+=("$FLAKE_REF#devenv-docs-options-json")
            JSON_PATH="/share/doc/nixos/options.json"
            ;;
          kubenix)
            ARGS+=("$FLAKE_REF#docs")
            JSON_PATH=""
            ;;
          *)
            echo "unknown uption type $TYPE"
            exit 1
            ;;
        esac
        JSON_DRV=$(nix build --no-link --print-out-paths "''${ARGS[@]}")
        echo "$JSON_DRV''${JSON_PATH}"
      }

      function local_flake_refs() {
        nix flake metadata --json | jq -L "$JQLIB" -r 'include "flake-metadata"; list' --exit-status
      }

      function global_flake_refs() {
        jq -L "$JQLIB" -n -r 'include "flake-metadata"; static'
      }

      function search_choices() {
        jq -L "$JQLIB" -n -r 'include "flake-metadata"; header'
        local_flake_refs;
        global_flake_refs
      }

      case "''${1:-default}" in
        packages)
          echo "seach packages $*"
          shift
          export NIXPKGS_EXPR=''${1}
          shift
          exec nix-package-search
          ;;

        options)
          shift
          TYPE=$1
          FLAKE_REF=$2
          shift
          echo "search options: $TYPE in $FLAKE_REF"
          OPTIONS_JSON=$(option_json_path "/share/doc/nixos/options.json")
          export OPTIONS_JSON
          nix-option-search
          ;;

        *)
          echo "select something using fzf"
          CHOICE=$(
            search_choices | fzf -e --sort \
                --header-lines 1 \
                --delimiter '\t' \
                --with-nth "2.." \
                --header 'What options would you like to search through?' \
                --query "''${1:-}" --select-1 \
                --accept-nth "{1}" \
                | tr -d '\n'
          )
          IFS="," read -r -a CHOICE_ARR <<< "$CHOICE"
          $0 "''${CHOICE_ARR[@]}"
          ;;
      esac
    '';
  };
in {
  inherit nix-discover-standalone;
  default = nix-discover-standalone;
}
