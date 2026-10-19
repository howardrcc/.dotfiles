# T3 Code desktop app, wrapped from the official upstream AppImage.
# Update: ./update-t3code.sh [--check] [stable|preview|nightly]
{ appimageTools, fetchurl }:

let
  pname = "t3code";
  version = "0.1.0";

  src = fetchurl {
    url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/T3-Code-${version}-x86_64.AppImage";
    hash = "sha256-442cX7UTsezgpwi5BtM4O1tH7RmVdbOaMeQauINOt0Q=";
  };

  contents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${contents}/t3code.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/t3code.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=t3code'
    cp -r ${contents}/usr/share/icons $out/share
  '';

  meta = {
    description = "Desktop app for coding agents";
    homepage = "https://t3.codes";
    mainProgram = "t3code";
    platforms = [ "x86_64-linux" ];
  };
}
