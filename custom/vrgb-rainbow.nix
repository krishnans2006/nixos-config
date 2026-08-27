{ lib, stdenvNoCC, python3, makeWrapper, vrgb }:

stdenvNoCC.mkDerivation {
  pname = "vrgb-rainbow";
  version = "1.0";

  src = ./vrgb-rainbow.py;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ python3 vrgb ];

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/bin/vrgb-rainbow
    wrapProgram $out/bin/vrgb-rainbow --prefix PATH : ${lib.makeBinPath [ vrgb ]}

    runHook postInstall
  '';

  meta = {
    description = "Software rainbow cycle for ASUS Vivobook keyboard RGB (via vrgb)";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "vrgb-rainbow";
  };
}
