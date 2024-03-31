{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-qt515.url = "github:NixOS/nixpkgs/983465f13a42075925f78c69950b79d4e41397b5";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, nixpkgs-qt515, flake-utils, ... }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pkgs-qt515 = nixpkgs-qt515.legacyPackages.${system};

        zlib129 = pkgs.stdenv.mkDerivation rec {
          pname = "zlib";
          version = "1.2.9";

          src = pkgs.fetchurl {
            url = "https://www.zlib.net/fossils/zlib-${version}.tar.gz";
            hash = "sha256-c6swLvMe0edIldKvVvUvWFPyawNw8+8hlUNHrOxeqiE=";
          };

          strictDeps = true;
          outputs = [ "out" ];
          setOutputFlags = false;

          configureFlags = [ "--shared" ];
          dontDisableStatic = true;
          dontAddStaticConfigureFlags = true;
          configurePlatforms = [ ];
          enableParallelBuilding = true;
          doCheck = true;

          makeFlags = [
            "PREFIX=${pkgs.stdenv.cc.targetPrefix}"
            "SHARED_MODE=1"
          ];
        };

        lib-path = with pkgs; lib.makeLibraryPath ([
          stdenv.cc.cc
          glib
          libGL
          fontconfig
          freetype
          libxkbcommon
          dbus
          zlib129
          ffmpeg_4.lib
        ] ++ [
          xorg.libxcb
          xorg.libX11
          xorg.libXrender
          xorg.libXcursor
        ] ++ [
          pkgs-qt515.qt5.qtbase
          pkgs-qt515.qt5.qtsvg
        ]);
      in
      {
        formatter = pkgs.nixpkgs-fmt;

        devShells.default = pkgs.mkShell {
          QT_DEBUG_PLUGINS = 1;
          LD_LIBRARY_PATH = lib-path;
        };
      });
}
