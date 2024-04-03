{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};


        lib-path = with pkgs; lib.makeLibraryPath ([
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
        ] ++ [
          xorg.libX11
          xorg.libXau
          xorg.libXcursor
          xorg.libXdmcp
          xorg.libXrender
          xorg.libxcb
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
