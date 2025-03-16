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
    documentation.module-system-name = lib.mkDefault "devenv";
  };
  nixos = lib.optionalAttrs (options ? environment.defaultPackages) {
    environment.defaultPackages = packages;
    documentation.module-system-name = lib.mkDefault "nixos";
  };
  home-manager = lib.optionalAttrs (options ? home.packages) {
    home.packages = packages;
    documentation.module-system-name = lib.mkDefault "home-manager";
  };
in {
  options.documentation = {
    packages = lib.options.mkOption {
      type = lib.types.listOf lib.types.package;
      description = ''List of documentation related packages to include'';
      default = [];
      internal = true;
    };
    module-system-name = lib.options.mkOption {
      type = lib.types.str;
      description = ''
        The name of the module system.

        This field is heuristically auto-filled for most common module systems
        like devenv, nixos, and home-manager. If this module is used in another
        module system, fill it with an appropriate value;
      '';
      example = ''nixos'';
    };
  };
  config = lib.mkMerge [devenv nixos home-manager];
}
