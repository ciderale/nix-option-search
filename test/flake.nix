{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
    devenv.inputs.nix.follows = "";
    devenv.inputs.cachix.follows = "";
    #nix-discover.url = "github:ciderale/nix-option-search";
    nix-discover.url = "path:..";
    nix-discover.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      debug = true;
      imports = [
        inputs.devenv.flakeModule
        flake-parts.flakeModules.modules
        flake-parts.flakeModules.flakeModules
        # inputs.nix-discover.modules.flake-parts
        inputs.nix-discover.modules.flake-parts-devenv
      ];
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      perSystem = {
        inputs',
        config,
        lib,
        ...
      }: {
        devenv.shells.default = {
          containers = lib.mkForce {};
          packages = [inputs'.nix-discover.packages.default];
          documentation.nix-discover = {
            option-search.enable = true;
            package-search.enable = true;
            flake-parts-option-search.enable = true; # provided by flake-parts-devenv
          };
          # manually add when not using flake-parts-devenv
          # imports = [inputs.nix-discover.modules.default];
          #packages = [config.packages.nix-discover-flake-parts-options];
        };
      };
    };
}
