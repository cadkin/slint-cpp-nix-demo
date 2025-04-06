{
  description = "Slint example application";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    slint.url   = github:cadkin/slint;
    utils.url   = github:numtide/flake-utils;
  };

  outputs = inputs @ { self, utils, ... }: utils.lib.eachDefaultSystem (system: let
    config = rec {
      pkgs = import inputs.nixpkgs {
        inherit system;
        inherit (import ./nix/nixpkgs/config.nix {
          slintOverlay = inputs.slint.overlays.${system}.default;
        }) config overlays;
      };

      stdenv = llvm.stdenv;

      llvm = rec {
        packages = pkgs.llvmPackages_18;
        stdenv   = packages.stdenv;

        tooling = rec {
          lldb = packages.lldb;
          clang-tools = packages.clang-tools;
          clang-tools-libcxx = clang-tools.override {
            enableLibcxx = true;
          };
        };
      };
    };
  in with config; rec {
    inherit config;

    lib = rec {
      # NOP
    } // config.pkgs.lib;

    packages = rec {
      default = slint-cpp-demo;

      slint-cpp-demo = stdenv.mkDerivation {
        pname   = "slint-cpp-demo";
        version = "0.0.1";

        src = self;

        nativeBuildInputs = [
          pkgs.cmake
        ];

        buildInputs = [
          pkgs.slint.api.cpp
          pkgs.libglvnd
        ];
      };
    };

    devShells = rec {
      default = slintDev;

      # Main developer shell.
      slintDev = pkgs.mkShell.override { inherit stdenv; } rec {
        name = "slint-dev";

        packages = [
          pkgs.git
          pkgs.jq

          pkgs.doxygen
          pkgs.graphviz

          llvm.tooling.lldb
          llvm.tooling.clang-tools
        ];
      };
    };
  });
}
