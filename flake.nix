{
  description = "Ad-hoc C++ project with Meson";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
        let
          pkgs = import nixpkgs { inherit system; };
          llvm = pkgs.llvmPackages_latest;
          lib = nixpkgs.lib;

        in
          {
            devShell = pkgs.stdenvNoCC.mkDerivation {
              name = "shell";
              nativeBuildInputs = [
                # builder
                # p.gnumake
                # p.bear
                pkgs.cmake  # for discovering libraries
                pkgs.pkg-config
                pkgs.meson
                pkgs.ninja
                # debugger
                llvm.lldb

                # XXX: the order of include matters
                (pkgs.clang-tools.override { llvmPackages = llvm; enableLibcxx = true; })
                llvm.libcxxClang
                llvm.libcxxabi
                llvm.libcxx

                pkgs.gtest
                pkgs.fmt
                pkgs.tl-expected
              ] ++ lib.optional pkgs.stdenv.isLinux [ pkgs.mold ]
              ;

              LD_LIBRARY_PATH = lib.strings.makeLibraryPath [ llvm.libcxx llvm.libcxxabi ];

              NIX_NO_SELF_RPATH = true;
              shellHook = ''
                # export LDFLAGS=''${NIX_LDFLAGS##+([[:space:]])}
              '';
            };
          }
    );
}
