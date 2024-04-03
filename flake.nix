{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        lib-path = let
          xorg-deps = with pkgs.xorg; [
            libX11
            libXau
            libXcursor
            libXdmcp
            libXrender
            libxcb
          ];

         qt-deps = with pkgs.libsForQt5; [
          qtbase
          qtsvg
         ];

        in with pkgs; lib.makeLibraryPath ([
          dbus
          ffmpeg_4.lib
          fontconfig
          freetype
          glib
          libGL
          libkrb5
          libxkbcommon
          stdenv.cc.cc
          zlib
        ] ++ xorg-deps ++ qt-deps);
      in
      {
        formatter = pkgs.nixpkgs-fmt;

        devShells.default = pkgs.mkShell {
          QT_DEBUG_PLUGINS = 1;
          LD_LIBRARY_PATH = lib-path;
        };
      });
}
