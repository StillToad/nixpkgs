{
  lib,
  fetchFromGitHub,
  testers,
  nix-update-script,
  phraze,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "phraze";
  version = "0.3.13";

  src = fetchFromGitHub {
    owner = "sts10";
    repo = "phraze";
    rev = "v${version}";
    hash = "sha256-xjkS1Ehqh2LfuIwAtj6V7Q9DcuERk7PyJKJEuDE7A34=";
  };

  doCheck = true;

  cargoHash = "sha256-jsQlcGRZqa4HHUS3Xc9OZUbI6pHalt9A3fVaz+Th1l0=";

  passthru = {
    updateScript = nix-update-script { };
    tests = {
      version = testers.testVersion { package = phraze; };
    };
  };

  meta = {
    description = "Generate random passphrases";
    homepage = "https://github.com/sts10/phraze";
    changelog = "https://github.com/sts10/phraze/releases/tag/v${version}";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [
      x123
      donovanglover
    ];
    mainProgram = "phraze";
  };
}
