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
          stdenv.cc.cc
          glib
          libGL
          fontconfig
          freetype
          libxkbcommon
          dbus
          zlib
          ffmpeg_4.lib
        ] ++ [
          xorg.libxcb
          xorg.libX11
          xorg.libXrender
          xorg.libXcursor
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
