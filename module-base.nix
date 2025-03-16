{
  config,
  options,
  lib,
  ...
}: let
  packages = config.documentation.packages;
  # the following are heuristic auto-detection for common module systems
  devenv = lib.optionalAttrs (options ? packages) {
    packages = packages;
  };
  nixos = lib.optionalAttrs (options ? environment.defaultPackages) {
    environment.defaultPackages = packages;
  };
  home-manager = lib.optionalAttrs (options ? home.packages) {
    home.packages = packages;
  };
in {
  options.documentation.packages = lib.options.mkOption {
    type = lib.types.listOf lib.types.package;
    description = ''List of documentation related packages to include'';
    default = [];
    internal = true;
  };
  config = lib.mkMerge [devenv nixos home-manager];
}
