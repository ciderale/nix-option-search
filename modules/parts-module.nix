# this defines a perSystem.package.flake-parts-option-search
# with the option.json of the entire flake-parts module
top: {
  config.perSystem = ps @ {pkgs, ...}: let
    prefix = "nix-discover";
    name = "${prefix}-flake-parts-options";
    optionsearch = pkgs.callPackages ../nix-option-search.nix {};
    optionsearchWithOptiohs = optionsearch.documentOptions {
      # ensure that options have a proper 'pkgs' argument
      options = top.options // {perSystem = {};} // ps.options;
      inherit name;
    };
  in {
    packages."${name}" = optionsearchWithOptiohs.cli;
  };
}
