{pkgs}: {
  pname,
  fname,
  version,
  repo,
  owner,
  sha256,
}:
pkgs.stdenv.mkDerivation rec {
  name = "${pname}-${version}";

  src = pkgs.fetchurl {
    url =
      if version == "latest"
      then "https://github.com/${owner}/${repo}/releases/latest/download/${fname}"
      else "https://github.com/${owner}/${repo}/releases/download/${version}/${fname}";
    inherit sha256;
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/${pname}
    chmod +x $out/bin/${pname}
  '';
}
