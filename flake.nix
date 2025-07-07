{
  description = "Dioxus CLI builds from different branches";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        buildDioxusCli =
          { pname, src }:
          pkgs.rustPlatform.buildRustPackage {
            inherit pname src;
            version = "git";

            cargoLock = {
              lockFile = "${src}/Cargo.lock";
            };

            cargoBuildFlags = [
              "--package"
              "dioxus-cli"
            ];

            nativeBuildInputs = with pkgs; [
              pkg-config
            ];

            buildInputs = with pkgs; [
              openssl
            ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
              pkgs.darwin.apple_sdk.frameworks.Security
              pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
            ];

            meta = with pkgs.lib; {
              description = "Dioxus CLI tool";
              homepage = "https://github.com/DioxusLabs/dioxus";
              license = licenses.mit;
              maintainers = [ ];
              mainProgram = "dx";
            };
          };
      in
      {
        packages = {
          v7 = buildDioxusCli {
            pname = "dioxus-cli_v7";
            src = pkgs.fetchFromGitHub {
              owner = "DioxusLabs";
              repo = "dioxus";
              # rev = "main";
              rev = "ddc94cf44c5e2ead5fb15c1db98741ba3242e6e3";
              sha256 = "sha256-0cbKCVOC6JW9mYNv+yvKcV3+M11knmYhH+mjhs73lHY";
            };
          };

          v6 = buildDioxusCli {
            pname = "dioxus-cli_v6";
            src = pkgs.fetchFromGitHub {
              owner = "DioxusLabs";
              repo = "dioxus";
              # rev = "v0.6";
              rev = "30f760c";
              sha256 = "sha256-MeYjPyGOQD5AkXj0v64eP+HokMvX4+EJ16bjNk9QQBM=";
            };
          };
        };

        defaultPackage = self.packages.${system}.dx7;
      }
    );
}
