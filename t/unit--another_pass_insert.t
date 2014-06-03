#!/bin/bash
. tlib/another-pass-tap.bash

# Test that insert works correctly

Test::Tap:plan tests 5

prepare_insert() {
  load_source
  storedir_find() { :; }
  password_read() { :; }
  rc_commit() { :; }
}

prepare_insert
storedir_find() { return 2; }
another_pass_insert >/dev/null 2>&1
[[ $? -eq 1 ]]
tap 'insert fails with 1 if storedir_find fails'

prepare_insert
password_read() { echo "$1" >"$tap_tmp/password_read"; }
rc_commit() { echo "$1" >"$tap_tmp/rc_commit"; }
another_pass_insert
[[ "$(cat "$tap_tmp/password_read")" == password ]]
tap 'insert without arguments calls password_read with "password"'
[[ "$(cat "$tap_tmp/rc_commit")" == "Insert default password" ]]
tap 'insert without arguments calls rc_commit with "Insert default password"'

prepare_insert
rm -f "$tap_tmp/password_read"
password_read() {
  # executes in a sub-shell
  id=$(cat "$tap_tmp/id" 2>/dev/null || echo 0)
  ((id++))
  echo "$id == $1" >> "$tap_tmp/password_read"
  echo $id >"$tap_tmp/id"
}
rc_commit() { echo "$1" >"$tap_tmp/rc_commit"; }
another_pass_insert foo bar baz
( echo '1 == foo'; echo '2 == bar'; echo '3 == baz' ) > "$tap_tmp/should_be"
diff -u "$tap_tmp/password_read" "$tap_tmp/should_be" >&2
tap 'insert calls password_read with each argument in turn'
[[ "$(cat "$tap_tmp/rc_commit")" == "Insert foo bar baz" ]]
tap 'insert calls rc_commit with "Insert <password list>"'

# vim: set ft=sh fdm=marker:
