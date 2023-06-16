{ stdenv
, lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, openssl
, Security
}:

rustPlatform.buildRustPackage rec {
  pname = "mpd-discord-rpc";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "JakeStanger";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-/B9ar9Q+d1MbBh6zIzf0QmlfgugxECLWHuiYSGUjdmg=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "discord-rpc-client-0.3.0" = "sha256-NzrsJYRe4jCZBkIEXbTG9xbHHJHQyIVnDWGx73of8Tw=";
    };
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ] ++ lib.optional stdenv.isDarwin Security;

  meta = with lib; {
    description = "Rust application which displays your currently playing song / album / artist from MPD in Discord using Rich Presence";
    homepage = "https://github.com/JakeStanger/mpd-discord-rpc";
    license = licenses.mit;
    maintainers = with maintainers; [ kranzes ];
  };
}
