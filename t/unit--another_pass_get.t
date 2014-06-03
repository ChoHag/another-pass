#!/bin/bash
. tlib/another-pass-tap.bash

# Test that get works correctly

Test::Tap:plan tests 7

prepare_get() {
  load_source
  storedir_find() { :; }
  passfile_read() {
    echo "$1 line 1"
    echo "$1 line 2"
    echo "$1 line 3"
  }
}

prepare_get
storedir_find() { return 2; }
another_pass_get >/dev/null 2>&1
[[ $? -eq 1 ]]
tap 'get fails with 1 if storedir_find fails'

prepare_get
passfile_read() { echo "$1" > "$tap_tmp/passfile_read"; }
another_pass_get
[[ "$(cat "$tap_tmp/passfile_read")" == password ]]
tap 'get without arguments calls passfile_read with "password"'

prepare_get
rm -f "$tap_tmp/passfile_read"
passfile_read() {
  # executes in a sub-shell
  id=$(cat "$tap_tmp/id" 2>/dev/null || echo 0)
  ((id++))
  echo "$id == $1" >> "$tap_tmp/passfile_read"
  echo $id >"$tap_tmp/id"
}
another_pass_get foo bar baz
( echo '1 == foo'; echo '2 == bar'; echo '3 == baz' ) > "$tap_tmp/should_be"
diff -u "$tap_tmp/passfile_read" "$tap_tmp/should_be" >&2
tap 'get calls passfile_read with each argument in turn'

prepare_get
another_pass_get foo >"$tap_tmp/is"
echo "foo line 1" >"$tap_tmp/should_be"
diff -u "$tap_tmp/is" "$tap_tmp/should_be" >&2
tap 'get returns only the first line'

prepare_get
another_pass_get foo bar >"$tap_tmp/is"
( echo "foo line 1"; echo "bar line 1" ) >"$tap_tmp/should_be"
diff -u "$tap_tmp/is" "$tap_tmp/should_be" >&2
tap 'get concatenates each file'

prepare_get
headings=1
another_pass_get foo >"$tap_tmp/is"
echo "foo line 1" >"$tap_tmp/should_be"
diff -u "$tap_tmp/is" "$tap_tmp/should_be" >&2
tap 'get with headings does not add a heading to one password'

prepare_get
headings=1
another_pass_get foo bar >"$tap_tmp/is"
( echo "foo: foo line 1"; echo "bar: bar line 1" ) >"$tap_tmp/should_be"
diff -u "$tap_tmp/is" "$tap_tmp/should_be" >&2
tap 'get concatenates each file with headings'

# vim: set ft=sh fdm=marker:
