{
  writeShellApplication,
  jq,
  fzf,
  coreutils,
}:
writeShellApplication {
  name = "nix-package-search";
  runtimeInputs = [jq fzf coreutils];
  text = builtins.readFile ./nix-package-search.sh;
  runtimeEnv.JQLIB = ./jqlib;
}
