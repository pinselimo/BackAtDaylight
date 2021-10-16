{ pkgs ? import <nixpkgs> {} }:
(pkgs.buildFHSUserEnv {
  name = "connect-iq-env";
  targetPkgs = pkgs: (with pkgs;
    [
    ]);
  runScript = "fish";
}).env
