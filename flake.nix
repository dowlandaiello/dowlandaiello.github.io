{
  description = "My site :3";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    hugo-papermod = {
      url = "github:adityatelange/hugo-papermod";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, flake-utils, hugo-papermod }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages.default = pkgs.stdenv.mkDerivation {
          name = "website";
          src = self;
          buildInputs = [ pkgs.git pkgs.hugo pkgs.nodePackages.prettier ];
          buildPhase = ''
            mkdir -p themes
            ln -s ${inputs.hugo-papermod} themes/papermod
            ${pkgs.hugo}/bin/hugo --gc --minify
            ${pkgs.nodePackages.prettier}/bin/prettier -w public '!**/*.{js,css}'
          '';
          installPhase = "cp -r public $out";
        };
        devShell = pkgs.mkShell {
          buildInputs = [ pkgs.hugo ];
          shellHook = ''
            mkdir -p themes
            ln -s ${inputs.hugo-papermod} themes/papermod
          '';
        };
      });
}
