{
  description = "Slint example application";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    slint.url   = github:cadkin/slint/flake;
    utils.url   = github:numtide/flake-utils;
    lasm = {
      url = github:DDoSolitary/ld-audit-search-mod;
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "utils";
      };
    };
  };

  outputs = inputs @ { self, utils, ... }: utils.lib.eachDefaultSystem (system: let
    config = rec {
      pkgs = import inputs.nixpkgs {
        inherit system;
        inherit (import ./nix/nixpkgs/config.nix {
          inputOverlays = with inputs; [
            lasm.overlays.default
            slint.overlays.${system}.default
          ];
        }) config overlays;
      };

      stdenv = llvm.stdenv;

      llvm = rec {
        packages = pkgs.llvmPackages_19;
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
      mkPackages = { pkgs, stdenv ? pkgs.stdenv }: rec {
        nixpkgs = pkgs;

        audit = rec {
          package = pkgs.ld-audit-search-mod;
          config  = import ./nix/nixpkgs/audit.nix {};

          env = {
            LD_AUDIT = "${package}/lib/libld-audit-search-mod.so";
            LD_AUDIT_SEARCH_MOD_CONFIG = builtins.toString config;
          };
        };

        slint-cpp-demo = pkgs.callPackage ./nix/demo {
          src     = self;
          version = "0.0.1";

          inherit audit;
        };
      };
    } // config.pkgs.lib;

    legacyPackages = rec {
      inherit ( lib.mkPackages { inherit pkgs stdenv; } ) nixpkgs slint-cpp-demo;
    };

    packages = rec {
      default = slint-cpp-demo;

      inherit (legacyPackages) slint-cpp-demo;
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

        env = audit.env;
      };
    };
  });
}
