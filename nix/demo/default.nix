{
  src, version,

  lib, stdenv,

  cmake,

  slint, libglvnd, makeWrapper,

  audit
}:

stdenv.mkDerivation {
  pname = "slint-cpp-demo";

  inherit src version;

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    slint.api.cpp
    libglvnd
    makeWrapper
  ];

  postFixup = ''
    wrapProgram $out/bin/my_application ${
      lib.pipe audit.env [
        (lib.mapAttrsToList (name: value: "--set-default ${name} ${value}"))
        builtins.toString
      ]
    }
  '';
}
