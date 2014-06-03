#!/bin/bash
. tlib/another-pass-tap.bash

# Test that edit works correctly

Test::Tap:plan tests 5

prepare_edit() {
  load_source
  storedir_find() { :; }
  passfile_edit() { :; }
  rc_commit() { :; }
}

prepare_edit
storedir_find() { return 2; }
another_pass_edit >/dev/null 2>&1
[[ $? -eq 1 ]]
tap 'edit fails with 1 if storedir_find fails'

prepare_edit
passfile_edit() { echo "$1" >"$tap_tmp/passfile_edit"; }
rc_commit() { echo "$1" >"$tap_tmp/rc_commit"; }
another_pass_edit
[[ "$(cat "$tap_tmp/passfile_edit")" == password ]]
tap 'edit without arguments calls passfile_edit with "password"'
[[ "$(cat "$tap_tmp/rc_commit")" == "Edit default password" ]]
tap 'edit without arguments calls rc_commit with "Insert default password"'

prepare_edit
rm -f "$tap_tmp/passfile_edit"
passfile_edit() {
  # executes in a sub-shell
  id=$(cat "$tap_tmp/id" 2>/dev/null || echo 0)
  ((id++))
  echo "$id == $1" >> "$tap_tmp/passfile_edit"
  echo $id >"$tap_tmp/id"
}
rc_commit() { echo "$1" >"$tap_tmp/rc_commit"; }
another_pass_edit foo bar baz
( echo '1 == foo'; echo '2 == bar'; echo '3 == baz' ) > "$tap_tmp/should_be"
diff -u "$tap_tmp/passfile_edit" "$tap_tmp/should_be" >&2
tap 'edit calls passfile_edit with each argument in turn'
[[ "$(cat "$tap_tmp/rc_commit")" == "Edit foo bar baz" ]]
tap 'edit calls rc_commit with "Edit <password list>"'

# vim: set ft=sh fdm=marker:
