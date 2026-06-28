{
  imports = [
    (fetchTarball "https://github.com/msteen/nixos-vscode-server/tarball/master")
  ];


  #systemctl --user enable auto-fix-vscode-server.service
  #systemctl --user start auto-fix-vscode-server.service
  services.vscode-server.enable = true;


}
