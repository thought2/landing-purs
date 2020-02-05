{ runCommand }: {
  webserver = {
    deployment.targetHost = "stage.thought2.de";
    services.httpd.enable = true;
    services.httpd.documentRoot = runCommand "root" { } ''
      mkdir $out
      echo hello > $out/index.html
    '';
  };
}
