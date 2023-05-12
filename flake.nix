{
  description = "Zenu Dev Env";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.commandbox = {
    url = "github:FeliciousX/commandbox-flake";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-utils.follows = "flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, commandbox }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        javaVersion = 17;

        overlays = [
          (self: super:
            let jdk = super."jdk${toString javaVersion}";
            in {
              inherit jdk;
              gradle = super.gradle.override { java = jdk; };
              maven = super.maven.override { inherit jdk; };
            })
        ];
        pkgs = import nixpkgs { inherit overlays system; };
        box = commandbox.packages.${system}.default;
      in {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [ pkgs.bashInteractive ];
          packages = pkgs.lib.attrVals [ "nodejs-14_x" "playwright-test" ] pkgs ++ [ box ];

					PLAYWRIGHT_BROWSERS_PATH="${pkgs.playwright-driver.browsers}";
        };
      });
}
