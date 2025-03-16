{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    devsh = lib.options.mkOption {
      type = lib.types.package;
      description = "the devshell";
      internal = true;
    };
    packages = lib.options.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
    };
    home.packages = lib.options.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
    };
    environment.defaultPackages = lib.options.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
    };
  };
  config = {
    documentation.nix-discover = {
      module-system-name = "test"; # avoid 'has conflicting definition values'
      option-search.enable = true;
      package-search.enable = true;
    };
    devsh = pkgs.mkShellNoCC {
      buildInputs = config.packages or [];
    };
  };
}
