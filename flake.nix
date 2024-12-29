{
  description = "A very basic flake";

  inputs = { nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable"; };

  outputs = { self, nixpkgs }:
    let pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {

      packages.x86_64-linux.tui-sudoku = pkgs.writeShellApplication {
        name = "tui-sudoku";
        checkPhase = ":"; # complains about non encodable chars
        #excludeShellChecks = [ "SC2004" "SC2162" ];
        bashOptions = [ ];
        runtimeInputs = with pkgs; [ qqwing lolcat ];
        text = builtins.readFile ./tui-sudoku.sh;
      };

      packages.x86_64-linux.default = self.packages.x86_64-linux.tui-sudoku;

    };
}
