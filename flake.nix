{
  description = "Nix Module Option Search";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: let
    forAllSystems = function:
      nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed
      (system: function nixpkgs.legacyPackages.${system});
  in {
    nixosModules.default = ./modules/module.nix; # deprecated, use 'modules.*'
    modules = {
      default = ./modules/module.nix;
      flake-parts = ./modules/parts-module.nix;
      flake-parts-devenv = ./modules/parts-devenv-module.nix;
    };
    packages = forAllSystems (
      pkgs: let
        nix-option-search-cli = (pkgs.callPackages ./nix-option-search.nix {}).cli;
        nix-package-search = pkgs.callPackage ./nix-package-search.nix {};
      in
        {inherit nix-package-search nix-option-search-cli;}
        // (pkgs.callPackages ./standalone.nix {inherit nix-option-search-cli nix-package-search;})
    );
    devShells = forAllSystems (pkgs: {
      default =
        (nixpkgs.lib.modules.evalModules {
          modules = [self.modules.default ./test.nix];
          specialArgs = {inherit pkgs inputs;};
        })
        .config
        .devsh;
    });
    debug = forAllSystems (pkgs: {
      default = nixpkgs.lib.modules.evalModules {
        modules = [self.modules.default ./test.nix];
        specialArgs = {inherit pkgs;};
      };
    });
  };
}
