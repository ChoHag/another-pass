#!/bin/bash
. tlib/another-pass-tap.bash

# Test that passfile_read works correctly

Test::Tap:plan tests 9

prepare_passfile_read() {
  load_source
  passfile_find() { :; }
  call_gpg() { :; }
}

# must have 1 arg
prepare_passfile_read
! passfile_read
tap 'passfile_read fails with 0 arguments'

prepare_passfile_read
! passfile_read foo bar
tap 'passfile_find fails with 2 arguments'

prepare_passfile_read
passfile_find() { return 1; }
! passfile_read foo 2>"$tap_tmp/passfile_read_stderr"
tap 'passfile_read fails if the password file does not exist'
[[ -s "$tap_tmp/passfile_read_stderr" ]]
tap 'passfile_read fails noisily if the password file does not exist'

prepare_passfile_read
passfile_find() { return 2; }
passfile_read foo 2>"$tap_tmp/passfile_read_stderr"
tap 'passfile_read succeeds if a gpg and asc file both exist'
[[ ! -s "$tap_tmp/passfile_read_stderr" ]]
tap 'passfile_read succeeds quietly if a gpg and asc file both exist'

prepare_passfile_read
passfile=bar
storedir=$tap_tmp
echo $'line 1\nline 2' >"$tap_tmp/fake_crypt"
passfile_find() { passfile=fake_crypt; }
call_gpg() {
  echo "$@" >"$tap_tmp/call_gpg_args"
  cat >"$tap_tmp/call_gpg_stdin"
}
passfile_read foo
tap 'passfile_read succeeds when gpg is called'
[[ "$(cat "$tap_tmp/call_gpg_args")" == --decrypt ]]
tap 'passfile_read calls gpg --decrypt'
echo $'line 1\nline 2' >"$tap_tmp/should_be"
diff -u "$tap_tmp/call_gpg_stdin" "$tap_tmp/should_be"
tap 'passfile_edit calls gpg with the correct stdin'

# vim: set ft=sh fdm=marker:
