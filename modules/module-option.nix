{
  pkgs,
  lib,
  options,
  config,
  ...
}: let
  cfg = config.documentation.option-search;

  option-search = pkgs.callPackages ../nix-option-search.nix {};

  # removes the prefix if the modules is imported as a submodule (e.g. devenv in flake-parts)
  # since all options (referenced from here) have this prefix, it's worth dropping the prefix
  dropPrefix = let
    len = lib.strings.stringLength;
    someOptionPath = "documentation.option-search.enable";
    someOption = lib.attrsets.getAttrFromPath (lib.strings.splitString "." someOptionPath) options;
    optionPrefixLen = (len "${someOption}") - (len someOptionPath);
  in
    optionName: builtins.substring optionPrefixLen (len optionName) optionName;

  cli = option-search.documentOptions {
    inherit options dropPrefix;
    inherit (cfg) name;
  };
in {
  imports = [./module-base.nix];
  options.documentation.option-search = {
    enable = lib.mkEnableOption "nix-option-search";
    name = lib.options.mkOption {
      type = lib.types.str;
      default = "nix-option-search";
      description = "The name of the option-search wrapper command";
      example = "docs";
    };
    package = lib.options.mkOption {
      type = lib.types.package;
      description = ''
        the nix-option-search wrapper including the options.json.

        the derivation provides options.json derivation via attribute ".optionsJson"
      '';
      default = cli.cli;
      readOnly = true;
    };
  };
  config = {
    documentation.packages = lib.optional cfg.enable cfg.package;
  };
}
