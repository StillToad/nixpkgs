{
  acpica-tools,
  bc,
  coreutils,
  fetchFromGitHub,
  gawk,
  gnugrep,
  gnused,
  linuxPackages,
  lib,
  pciutils,
  powertop,
  makeWrapper,
  stdenv,
  unstableGitUpdater,
  util-linux,
  xorg,
  xxd,
}:

let
  deps = [
    acpica-tools
    bc
    coreutils
    gawk
    gnugrep
    gnused
    linuxPackages.turbostat
    pciutils
    powertop
    util-linux
    xorg.xset
    xxd
  ];
in
stdenv.mkDerivation {
  pname = "s0ix-selftest-tool";
  version = "0-unstable-2024-08-13";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "S0ixSelftestTool";
    rev = "a9fcb3117ff733e7c307bb579c612065b64bf4b7";
    hash = "sha256-DcXefQPI4VpkeFH/YM899WEZHIs5IfWOWoUuZV6Ew7M=";
  };

  # don't use the bundled turbostat binary
  postPatch = ''
    substituteInPlace s0ix-selftest-tool.sh --replace '"$DIR"/turbostat' 'turbostat'
  '';

  nativeBuildInputs = [ makeWrapper ];
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm555 s0ix-selftest-tool.sh "$out/bin/s0ix-selftest-tool"
    wrapProgram "$out/bin/s0ix-selftest-tool" --prefix PATH : ${lib.escapeShellArg deps}
    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    homepage = "https://github.com/intel/S0ixSelftestTool";
    description = "Tool for testing the S2idle path CPU Package C-state and S0ix failures";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ adamcstephens ];
    mainProgram = "s0ix-selftest-tool";
  };
}
