let
  pkgs = import <nixpkgs> {};
in pkgs.mkShell {
  nativeBuildInputs = [
    pkgs.python3
  ];
}
