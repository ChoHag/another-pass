#!/bin/bash
. tlib/another-pass-tap.bash

# Test that passfile_edit works correctly

Test::Tap:plan tests 18

prepare_passfile_edit() {
  load_source "$@"
  unset test_tempfiles
  call_mktemp() {
    new_tmp="$(mktemp "$tap_tmp/XXXXXXXX")"
    test_tempfiles+=("$new_tmp")
    eval ${1:-tempfile}="$new_tmp"
  }
  passfile_find() { :; }
  passfile_read() { :; }
  call_editor() { :; }
  passfile_write() { :; }
  call_destroy() { :; }
  rc_add() { :; }
}

clean_passfile_edit() {
  for t in "${test_tempfiles[@]}"; do
    rm -f "$t"
  done
  unset test_tempfiles
}

prepare_passfile_edit
passfile_find() { return 1; }
unset edit_create
passfile_edit foo 2>"$tap_tmp/noexist_stderr"
[[ $? -eq 1 ]]
tap 'passfile_edit returns 1 if the file does not exist'
[[ -s "$tap_tmp/noexist_stderr" ]]
tap 'passfile_edit complains on stderr if the file does not exist'
clean_passfile_edit

prepare_passfile_edit
passfile_find() { return 1; }
edit_create=1
passfile_edit foo 2>"$tap_tmp/noexist_stderr"
tap 'passfile_edit returns 0 if the file does not exist but $edit_create is set'
[[ ! -s "$tap_tmp/noexist_stderr" ]]
tap 'passfile_edit is silent if the file does not exist but $edit_create is set'
clean_passfile_edit

prepare_passfile_edit
passfile_read() {
  echo line 1
  echo line 2
}
passfile_edit foo
tap 'passfile_edit succeeds when the password is read'
echo $'line 1\nline 2' >"$tap_tmp/should_be"
diff -u "${test_tempfiles[0]}" "$tap_tmp/should_be"
tap 'passfile_edit puts the stdout from passfile_read into a tmpfile'
clean_passfile_edit

prepare_passfile_edit
call_editor() { echo "$@" >"$tap_tmp/call_editor"; }
passfile_edit foo
tap 'passfile_edit succeeds when the editor is called'
[[ "$(cat "$tap_tmp/call_editor")" == "${test_tempfiles[0]}" ]]
tap 'passfile_edit calls the editor with the temporary file'
clean_passfile_edit

# copy...
prepare_passfile_edit
passfile_read() {
  echo line 1
  echo line 2
}
call_editor() {
  (
    echo different line 1
    echo different line 2
  ) >"$1"
}
passfile_write() {
  echo "$@" >"$tap_tmp/passfile_write_args"
  cat >"$tap_tmp/passfile_write"
}
passfile_edit foo
tap 'passfile_edit succeeds when the file is changed'
[[ "$(cat "$tap_tmp/passfile_write_args")" == "--replace foo" ]]
tap 'passfile_edit calls passfile_write with the name of the password'
echo $'different line 1\ndifferent line 2' >"$tap_tmp/should_be"
diff -u "$tap_tmp/passfile_write" "$tap_tmp/should_be"
tap 'passfile_edit passes the changed file to the stdin of passfile_write'
clean_passfile_edit

# pasta!
prepare_passfile_edit
# except:
  passfile_find() { return 1; }
  edit_create=1
passfile_read() {
  echo line 1
  echo line 2
}
call_editor() {
  (
    echo different line 1
    echo different line 2
  ) >"$1"
}
passfile_write() {
  echo "$@" >"$tap_tmp/passfile_write_args"
  cat >"$tap_tmp/passfile_write"
}
passfile_edit foo
tap 'passfile_edit succeeds when a new password is created'
[[ "$(cat "$tap_tmp/passfile_write_args")" == foo ]]
tap 'passfile_edit (new) calls passfile_write with the name of the password'
echo $'different line 1\ndifferent line 2' >"$tap_tmp/should_be"
diff -u "$tap_tmp/passfile_write" "$tap_tmp/should_be"
tap 'passfile_edit (new) passes the changed file to the stdin of passfile_write'
clean_passfile_edit

prepare_passfile_edit
call_destroy() { echo "$@" >"$tap_tmp/call_destroy_args"; }
passfile_edit foo
tap 'passfile_edit succeeds when the file is destroyed'
[[ "$(cat "$tap_tmp/call_destroy_args")" == "${test_tempfiles[0]}" ]]
tap 'passfile_edit destroys the temp file'
clean_passfile_edit

prepare_passfile_edit
rc_add() { echo "$@" >"$tap_tmp/rc_add_args"; }
passfile_edit foo
tap 'passfile_edit succeeds when the file is destroyed'
[[ "$(cat "$tap_tmp/rc_add_args")" == foo ]]
tap 'passfile_edit adds the password to git'
clean_passfile_edit

# vim: set ft=sh fdm=marker:
