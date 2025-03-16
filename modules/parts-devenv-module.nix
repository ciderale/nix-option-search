# defines the perSystem.pacakges.flake-parts-option-search like
# parts-module, but also provides a devenv.sh option to allow for
# installing that package into a selected devshell.
{
  imports = [./parts-module.nix];
  perSystem = {config, ...}: let
    prefix = "nix-discover";
    name = "${prefix}-flake-parts-options";
    package = config.packages.${name};
    devenvPackage = {
      lib,
      config,
      ...
    }: {
      options.documentation.option-search.flake-parts.enable = lib.mkEnableOption "flake-parts-option-search";
      config = lib.mkIf config.documentation.option-search.flake-parts.enable {
        documentation.packages = [package];
      };
    };
  in {devenv.modules = [./module.nix devenvPackage];};
}
