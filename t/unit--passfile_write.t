#!/bin/bash
. tlib/another-pass-tap.bash

# Test that passfile_write works correctly

Test::Tap:plan tests 41

prepare_passfile_write() {
  load_source
  rm -f "$tap_tmp"/{passfile_find,recipients_find,call_gpg,call_gpg_stdin,mv,rc_add}
  passfile_find() { echo "$@" >"$tap_tmp/passfile_find"; }
  recipients_find() { echo "$@" >"$tap_tmp/recipients_find"; recipients=(foo bar baz); }
  call_gpg() { echo "$@" >"$tap_tmp/call_gpg"; cat >"$tap_tmp/call_gpg_stdin"; }
  rc_add() { echo "$@" >"$tap_tmp/rc_add"; }
}

clean_passfile_write() {
  :
}

# Test environment

prepare_passfile_write
unset storedir
call_gpg() { touch "$tap_tmp/call_gpg_no_store"; }
passfile_write
[[ $? -eq 3 ]]
tap 'passfile_write fails if $storedir is not set'
[[ ! -e "$tap_tmp/call_gpg_no_store" ]]
tap '... and returns early'
clean_passfile_write

# Test arguments

prepare_passfile_write
storedir=set
passfile_write 2>/dev/null
[[ $? -eq 2 ]]
tap 'passfile_write returns 2 if called without any arguments'
clean_passfile_write

prepare_passfile_write
storedir=set
passfile_write --replace 2>/dev/null
[[ $? -eq 2 ]]
tap 'passfile_write returns 2 if called with only --replace'
clean_passfile_write

# Test extant files fail

prepare_passfile_write
mkdir "$tap_tmp/exists"
storedir="$tap_tmp/exists"
passfile_find() { echo "$@" >"$tap_tmp/passfile_find"; passfile=foo.gpg; return 0; }
passfile_write foo 2>/dev/null
[[ $? -eq 1 ]]
tap 'passfile_write fails if the password exists and $1 is not --replace'
clean_passfile_write

# Test with necessary overwrite and no echo

prepare_passfile_write
mkdir "$tap_tmp/exist-replace-noecho"
touch "$tap_tmp/exist-replace-noecho/foo.gpg"
storedir="$tap_tmp/exist-replace-noecho"
passfile_find() { passfile=foo.gpg; return 0; }
should_be=$'line 1\nline 2\n'
unset echo_tty
echo -n "$should_be" | passfile_write --replace foo >"$tap_tmp/passfile_write_stdout"
[[ "$(cat "$tap_tmp/recipients_find")" == foo.gpg ]]
tap 'passfile_write --replace foo looks for the correct file if it exists'
[[ "$(cat "$tap_tmp/call_gpg")" == "--encrypt foo bar baz" ]]
tap '... and calls call_gpg with its recipients'
echo -n "$should_be" >"$tap_tmp/call_gpg_stdin_shouldbe"
diff -u "$tap_tmp/call_gpg_stdin" "$tap_tmp/call_gpg_stdin_shouldbe"
tap '... and passes call_gpg its stdin'
[[ ! -s "$tap_tmp/passfile_write_stdout" ]]
tap '... and is silent (echo_tty not set)'
[[ ! -e "$tap_tmp/exist-replace-noecho/foo.gpg.tmp" ]]
tap '... and doesn'\''t leave a temp file'
[[ "$(cat "$tap_tmp/rc_add")" == "foo.gpg" ]]
tap '... and calls rc_add with the correct filename'
clean_passfile_write

# Test with unnecessary overwrite and no echo

prepare_passfile_write
mkdir "$tap_tmp/noexist-replace-noecho"
storedir="$tap_tmp/noexist-replace-noecho"
passfile_find() { passfile=foo.gpg; return 1; }
should_be=$'line 1\nline 2\n'
unset echo_tty
echo -n "$should_be" | passfile_write --replace foo >"$tap_tmp/passfile_write_stdout"
[[ "$(cat "$tap_tmp/recipients_find")" == foo.gpg ]]
tap 'passfile_write --replace foo looks for the correct file if it doesn'\''t exist'
[[ "$(cat "$tap_tmp/call_gpg")" == "--encrypt foo bar baz" ]]
tap '... and calls call_gpg with its recipients'
echo -n "$should_be" >"$tap_tmp/call_gpg_stdin_shouldbe"
diff -u "$tap_tmp/call_gpg_stdin" "$tap_tmp/call_gpg_stdin_shouldbe"
tap '... and passes call_gpg its stdin'
[[ ! -s "$tap_tmp/passfile_write_stdout" ]]
tap '... and is silent (echo_tty not set)'
[[ ! -e "$tap_tmp/noexist-replace-noecho/foo.gpg.tmp" ]]
tap '... and doesn'\''t leave a temp file'
[[ "$(cat "$tap_tmp/rc_add")" == "foo.gpg" ]]
tap '... and calls rc_add with the correct filename'
clean_passfile_write

# Test with necessary overwrite and echo

prepare_passfile_write
mkdir "$tap_tmp/exist-replace-echo"
touch "$tap_tmp/exist-replace-echo/foo.gpg"
storedir="$tap_tmp/exist-replace-echo"
passfile_find() { passfile=foo.gpg; return 0; }
should_be=$'line 1\nline 2\n'
echo_tty=1
echo -n "$should_be" | passfile_write --replace foo >"$tap_tmp/passfile_write_stdout"
[[ "$(cat "$tap_tmp/recipients_find")" == foo.gpg ]]
tap 'passfile_write --replace foo looks for the correct file if it exists'
[[ "$(cat "$tap_tmp/call_gpg")" == "--encrypt foo bar baz" ]]
tap '... and calls call_gpg with its recipients'
echo -n "$should_be" >"$tap_tmp/call_gpg_stdin_shouldbe"
diff -u "$tap_tmp/call_gpg_stdin" "$tap_tmp/call_gpg_stdin_shouldbe"
tap '... and passes call_gpg its stdin'
echo -n "$should_be" >"$tap_tmp/passfile_write_stdout_shouldbe"
diff -u "$tap_tmp/passfile_write_stdout" "$tap_tmp/passfile_write_stdout_shouldbe"
tap '... and is copies to stdout (echo_tty set)'
[[ ! -e "$tap_tmp/exist-replace-echo/foo.gpg.tmp" ]]
tap '... and doesn'\''t leave a temp file'
[[ "$(cat "$tap_tmp/rc_add")" == "foo.gpg" ]]
tap '... and calls rc_add with the correct filename'
clean_passfile_write

# Test with unnecessary overwrite and echo

prepare_passfile_write
mkdir "$tap_tmp/noexist-replace-echo"
storedir="$tap_tmp/noexist-replace-echo"
passfile_find() { passfile=foo.gpg; return 1; }
should_be=$'line 1\nline 2\n'
echo_tty=1
echo -n "$should_be" | passfile_write --replace foo >"$tap_tmp/passfile_write_stdout"
[[ "$(cat "$tap_tmp/recipients_find")" == foo.gpg ]]
tap 'passfile_write --replace foo looks for the correct file if it doesn'\''t exist'
[[ "$(cat "$tap_tmp/call_gpg")" == "--encrypt foo bar baz" ]]
tap '... and calls call_gpg with its recipients'
echo -n "$should_be" >"$tap_tmp/call_gpg_stdin_shouldbe"
diff -u "$tap_tmp/call_gpg_stdin" "$tap_tmp/call_gpg_stdin_shouldbe"
tap '... and passes call_gpg its stdin'
echo -n "$should_be" >"$tap_tmp/passfile_write_stdout_shouldbe"
diff -u "$tap_tmp/passfile_write_stdout" "$tap_tmp/passfile_write_stdout_shouldbe"
tap '... and is copies to stdout (echo_tty set)'
[[ ! -e "$tap_tmp/noexist-replace-echo/foo.gpg.tmp" ]]
tap '... and doesn'\''t leave a temp file'
[[ "$(cat "$tap_tmp/rc_add")" == "foo.gpg" ]]
tap '... and calls rc_add with the correct filename'
clean_passfile_write

# Test without overwrite and no echo

prepare_passfile_write
mkdir "$tap_tmp/noexist-noreplace-noecho"
storedir="$tap_tmp/noexist-noreplace-noecho"
passfile_find() { passfile=foo.gpg; return 1; }
should_be=$'line 1\nline 2\n'
unset echo_tty
echo -n "$should_be" | passfile_write foo >"$tap_tmp/passfile_write_stdout"
[[ "$(cat "$tap_tmp/recipients_find")" == foo.gpg ]]
tap 'passfile_write foo looks for the correct file'
[[ "$(cat "$tap_tmp/call_gpg")" == "--encrypt foo bar baz" ]]
tap '... and calls call_gpg with its recipients'
echo -n "$should_be" >"$tap_tmp/call_gpg_stdin_shouldbe"
diff -u "$tap_tmp/call_gpg_stdin" "$tap_tmp/call_gpg_stdin_shouldbe"
tap '... and passes call_gpg its stdin'
[[ ! -s "$tap_tmp/passfile_write_stdout" ]]
tap '... and is silent (echo_tty not set)'
[[ ! -e "$tap_tmp/noexist-noreplace-noecho/foo.gpg.tmp" ]]
tap '... and doesn'\''t leave a temp file'
[[ "$(cat "$tap_tmp/rc_add")" == "foo.gpg" ]]
tap '... and calls rc_add with the correct filename'
clean_passfile_write


# Test without overwrite and echo

prepare_passfile_write
mkdir "$tap_tmp/noexist-noreplace-echo"
storedir="$tap_tmp/noexist-noreplace-echo"
passfile_find() { passfile=foo.gpg; return 1; }
should_be=$'line 1\nline 2\n'
echo_tty=1
echo -n "$should_be" | passfile_write foo >"$tap_tmp/passfile_write_stdout"
[[ "$(cat "$tap_tmp/recipients_find")" == foo.gpg ]]
tap 'passfile_write foo looks for the correct file'
[[ "$(cat "$tap_tmp/call_gpg")" == "--encrypt foo bar baz" ]]
tap '... and calls call_gpg with its recipients'
echo -n "$should_be" >"$tap_tmp/call_gpg_stdin_shouldbe"
diff -u "$tap_tmp/call_gpg_stdin" "$tap_tmp/call_gpg_stdin_shouldbe"
tap '... and passes call_gpg its stdin'
echo -n "$should_be" >"$tap_tmp/passfile_write_stdout_shouldbe"
diff -u "$tap_tmp/passfile_write_stdout" "$tap_tmp/passfile_write_stdout_shouldbe"
tap '... and is copies to stdout (echo_tty set)'
[[ ! -e "$tap_tmp/noexist-noreplace-echo/foo.gpg.tmp" ]]
tap '... and doesn'\''t leave a temp file'
[[ "$(cat "$tap_tmp/rc_add")" == "foo.gpg" ]]
tap '... and calls rc_add with the correct filename'
clean_passfile_write

# vim: set ft=sh fdm=marker:
