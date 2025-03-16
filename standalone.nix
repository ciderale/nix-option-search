{
  writeShellApplication,
  nix-option-search-cli,
  nix-package-search,
  fzf,
  coreutils,
}: let
  nix-discover-standalone = writeShellApplication {
    name = "nix-discover-standalone";
    runtimeInputs = [nix-option-search-cli nix-package-search fzf coreutils];
    text = ''
      function option_json_path() {
        JSON_PATH=$1
        shift
        JSON_DRV=$(nix build --no-link --print-out-paths "''${@}")
        echo "$JSON_DRV''${JSON_PATH}"
      }

      if [ -z "''${OPTIONS_JSON:-}" ]; then
        KNOWN="nixpkgs|packages:nixpkgs/nixpkgs-unstable|packages:.|devenv|home-manager|nixos|kubenix"
        EXTRA="hm|custom"
        case "''${1:-fzf}" in
          nixpkgs|packages*)
            export NIXPKGS_EXPR=''${1#*:}
            shift
            exec nix-package-search "''${@}"
            ;;

          home-manager|hm)
            OPTIONS_JSON=$(option_json_path "/share/doc/home-manager/options.json" "home-manager#docs-json")
            ;;

          nixos)
            OPTIONS_JSON=$(option_json_path "/share/doc/nixos/options.json" --impure --expr '(import (builtins.getFlake "nixpkgs" + /nixos/release.nix) {}).options')
            ;;

          devenv)
            OPTIONS_JSON=$(option_json_path "/share/doc/nixos/options.json" "github:cachix/devenv#devenv-docs-options-json")
            ;;

          kubenix)
            OPTIONS_JSON=$(option_json_path "" "github:hall/kubenix#docs");
            ;;

          custom)
            shift 1
            echo "Using custom definition: $*"
            OPTIONS_JSON=$(option_json_path "''${@}")
            ;;

          usage|--help|-h)
            echo "Usage: $(basename "$0") [tool]"
            echo "  no-arguments:   fzf-based selection of tool"
            echo "  tool:           any of $KNOWN|$EXTRA"
            echo "  custom: arg2-*: nix build argument for options.json derivation build"
            echo "  custom: arg1  : path to options.json within the above built derivation"
            echo "$KNOWN"
            exit 1
            ;;

          fzf|*)
            SELECTION="$(echo "$KNOWN" | tr '|' '\n' | fzf --no-sort --header 'What options would you like to search through?')"
            if [ -n "$SELECTION" ]; then
              exec $0 "$SELECTION"
            fi
            ;;
        esac
      fi
      export OPTIONS_JSON
      nix-option-search
    '';
  };
in {
  inherit nix-discover-standalone;
  default = nix-discover-standalone;
}
