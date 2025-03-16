# this defines a perSystem.package.flake-parts-option-search
# with the option.json of the entire flake-parts module
top: {
  config.perSystem = ps @ {pkgs, ...}: let
    optionsearch = pkgs.callPackages ../nix-option-search.nix {};
    flake-parts-option-search = optionsearch.documentOptions {
      # ensure that options have a proper 'pkgs' argument
      options = top.options // {perSystem = {};} // ps.options;
      name = "flake-parts-option-search";
    };
    cli = flake-parts-option-search.cli;
  in {
    packages.flake-parts-option-search = cli;
  };
}
