#!/bin/bash
. tlib/another-pass-tap.bash

# Test that show works correctly

Test::Tap:plan tests 7

prepare_show() {
  load_source
  storedir_find() { :; }
  passfile_read() {
    echo "$1 line 1"
    echo "$1 line 2"
    echo "$1 line 3"
  }
}

prepare_show
storedir_find() { return 2; }
another_pass_show >/dev/null 2>&1
[[ $? -eq 1 ]]
tap 'show fails with 1 if storedir_find fails'

prepare_show
passfile_read() { echo "$1" > "$tap_tmp/passfile_read"; }
another_pass_show
[[ "$(cat "$tap_tmp/passfile_read")" == password ]]
tap 'show without arguments calls passfile_read with "password"'

prepare_show
rm -f "$tap_tmp/passfile_read"
passfile_read() {
  # executes in a sub-shell
  id=$(cat "$tap_tmp/id" 2>/dev/null || echo 0)
  ((id++))
  echo "$id == $1" >> "$tap_tmp/passfile_read"
  echo $id >"$tap_tmp/id"
}
another_pass_show foo bar baz
( echo '1 == foo'; echo '2 == bar'; echo '3 == baz' ) > "$tap_tmp/should_be"
diff -u "$tap_tmp/passfile_read" "$tap_tmp/should_be" >&2
tap 'show calls passfile_read with each argument in turn'

prepare_show
another_pass_show foo >"$tap_tmp/is"
(
  echo -n $'foo line 1\nfoo line 2\nfoo line 3\n' #'
) >"$tap_tmp/should_be"
diff -u "$tap_tmp/is" "$tap_tmp/should_be" >&2
tap 'show returns the entire file'

prepare_show
another_pass_show foo bar >"$tap_tmp/is"
(
  echo -n $'foo line 1\nfoo line 2\nfoo line 3\n' #'
  echo -n $'bar line 1\nbar line 2\nbar line 3\n' #'
) >"$tap_tmp/should_be"
diff -u "$tap_tmp/is" "$tap_tmp/should_be" >&2
tap 'show concatenates each file'

prepare_show
headings=1
another_pass_show foo >"$tap_tmp/is"
(
  echo -n $'foo line 1\nfoo line 2\nfoo line 3\n' #'
) >"$tap_tmp/should_be"
diff -u "$tap_tmp/is" "$tap_tmp/should_be" >&2
tap 'show with headings does not add a heading to one password'

prepare_show
headings=1
another_pass_show foo bar >"$tap_tmp/is"
(
  echo -n $'foo: foo line 1\nfoo line 2\nfoo line 3\n' #'
  echo ---
  echo -n $'bar: bar line 1\nbar line 2\nbar line 3\n' #'
  echo ---
) >"$tap_tmp/should_be"
diff -u "$tap_tmp/is" "$tap_tmp/should_be" >&2
tap 'show concatenates each file with headings'

# vim: set ft=sh fdm=marker:
