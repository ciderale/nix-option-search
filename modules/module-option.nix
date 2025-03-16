{
  pkgs,
  lib,
  options,
  config,
  ...
}: let
  prefix = "nix-discover";
  cfgBase = config.documentation.${prefix};
  cfg = cfgBase.option-search;
  someOptionPath = "documentation.${prefix}.option-search.enable";

  module-system-name = cfgBase.module-system-name;
  defaultToolName = "${prefix}-${module-system-name}-options";

  option-search = pkgs.callPackages ../nix-option-search.nix {};

  # removes the prefix if the modules is imported as a submodule (e.g. devenv in flake-parts)
  # since all options (referenced from here) have this prefix, it's worth dropping the prefix
  dropPrefix = let
    len = lib.strings.stringLength;
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
  options.documentation.${prefix}.option-search = {
    enable = lib.mkEnableOption "nix-option-search";
    name = lib.options.mkOption {
      type = lib.types.str;
      default = defaultToolName;
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
    documentation.${prefix}.packages = lib.optional cfg.enable cfg.package;
  };
}
