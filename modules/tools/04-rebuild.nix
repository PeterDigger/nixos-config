{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "rebuild" ''
#!/usr/bin/env bash

set -e
hostname=$(hostname)
pushd ~/nixos-config/
git diff -U0 *.nix
echo "NixOS Rebuilding..."
sudo nixos-rebuild switch --flake .#''$hostname &> nixos-switch.log || (cat nixos-switch.log | grep --color error && false)
gen=$(nixos-rebuild list-generations | grep current)
git commit -am "''$gen"
popd
    '')
  ];
}
