ctx @ {
  pkgs,
  lib,
  options,
  config,
  ...
}: let
  cfg = config.documentation.option-search;
  cfg2 = config.documentation.package-search;

  option-search = pkgs.callPackages ./nix-option-search.nix {};
  package-search = pkgs.callPackage ./nix-package-search.nix {};

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
  options.documentation.package-search = {
    enable = lib.mkEnableOption "nix-package-search";
    nixpkgs-expression = lib.options.mkOption {
      type = lib.types.str;
      description = ''
        flake reference to nixpkgs to be indexed.

        e.g. nixpkgs, github:nixos/nixpkgs

        Defaults to the current nixpkgs version
        if "inputs" is available in the module inputs.

        The above default is obtained by adding
           "specialArgs = {inherit inputs;};"
        in your module boostrap code. In that case, the
           "revision & narHash from inputs.nixpkgs"
        is used to index your actual nixpkgs version.
      '';
      example = "github:nixos/nixpkgs";
      default =
        if (ctx ? inputs.nixpkgs)
        then let
          nixpkgs = ctx.inputs.nixpkgs;
        in "github:nixos/nixpkgs/${nixpkgs.sourceInfo.rev}?narHash=${nixpkgs.narHash}"
        else "nixpkgs";
    };
    package = lib.options.mkOption {
      type = lib.types.package;
      description = "the nix-package-search wrapper including the nixpkgs flake reference";
      default = pkgs.writeShellApplication {
        name = "nix-package-search";
        runtimeInputs = [package-search];
        text = ''NIXPKGS_EXPR="${cfg2.nixpkgs-expression}" nix-package-search "''${@}"'';
      };
    };
  };
  config = {
    documentation.packages = (lib.optional cfg.enable cfg.package) ++ (lib.optional cfg2.enable cfg2.package);
  };
}
