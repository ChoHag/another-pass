#!bash

# An extremely thin wrapper around Ingy's bash test harness:
# https://github.com/ingydotnet/test-tap-bash

. tlib/tap.bash

Test::Tap:init

tap() {
  if [[ $? -eq 0 ]]; then
    Test::Tap:pass "$@"
  else
    Test::Tap:fail "$@"
  fi
}

tap_tmp=$(mktemp -d)
startdir=$PWD
srcdir=$PWD
while [[ ! -d "$srcdir/t" ]]; do srcdir="$srcdir/.."; done
export PATH=$srcdir:$srcdir/tlib:$PATH

trap tap_exit EXIT
tap_exit() {
  rm -rf "$tap_tmp"
  Test::Tap:END
}

load_source() {
  in_test=0
  another_pass_test() { in_test=${1:-testing}; }
  set -- test "$@"
  . another-pass
  set +e
}

export GNUPGHOME="$tap_tmp/gpg"
init_gpg() {
  mkdir "$GNUPGHOME"
  chmod 700 "$GNUPGHOME"
  gen1=$'Key-Type: DSA\nKey-Length: 512\n'
  gen2=$'Subkey-Type: ELG-E\nSubkey-Length: 1024\n'
  gen3=$'Name-Real: Testing Key\nExpire-Date: 1d\n'
  gen="$gen1$gen2$gen3"
  echo "$gen" | gpg --gen-key --batch --logger-fd 1 2>/dev/null >"$tap_tmp/gpgid"
  gpgid=$(cut -d' ' -f3 <"$tap_tmp/gpgid")
}

test_git() {
  pushd "$1" >/dev/null
  shift
  git "$@"
  r=$?
  popd >/dev/null
  return $r
}

