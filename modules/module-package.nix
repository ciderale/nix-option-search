ctx @ {
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.documentation.package-search;

  prefix = "nix-discover";

  package-search = pkgs.callPackage ../nix-package-search.nix {};
in {
  imports = [./module-base.nix];
  options.documentation.package-search = {
    enable = lib.mkEnableOption "nix-package-search";
    nixpkgs-expression = lib.options.mkOption {
      type = lib.types.str;
      description = ''
        flake reference to nixpkgs to be indexed.

        e.g. nixpkgs, github:nixos/nixpkgs

        Defaults to the current nixpkgs version if "inputs" is available in the module function inputs.
        In that case, the "revision & narHash from inputs.nixpkgs" is used to index your actual nixpkgs version.

        Some module systems (e.g. flake-parts) automatically make flake inputs available to modules.
        For others, the flake inputs can to be added via specialArgs in the module boostrap code, e.g:
           ```nix
           lib.evalModule {
               specialArgs = {inherit inputs;};
           }
           ```
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
        name = "${prefix}-package";
        runtimeInputs = [package-search];
        text = ''NIXPKGS_EXPR="${cfg.nixpkgs-expression}" nix-package-search "''${@}"'';
      };
    };
  };
  config = {
    documentation.packages = lib.optional cfg.enable cfg.package;
  };
}
