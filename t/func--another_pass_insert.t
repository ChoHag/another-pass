#!/bin/bash
. tlib/another-pass-tap.bash

# Test that insert works correctly

Test::Tap:plan tests 286

# Tests to write:
#   multiple multiline passwords
#   delimeted passwords
#   failure modes:
#   # Missing storedir
#   # Missing .git unless skip_git
#   # Extant file without overwrite

init_gpg

prepare_insert() {
  dir="$(mktemp -d "$tap_tmp/pass.XXXXXXXX")"
  rmdir "$dir"
  load_source --store-directory "$dir" "$@"
  mkdir "$dir"
  test_git "$dir" init >/dev/null 2>&1
}

do_standard_tests() { # 3+4n
  r=$?

  if [[ $# -eq 0 ]]; then
    set -- password
    name="(default password)"
  else
    name="$@"
  fi

  [[ $r -eq 0 ]]
  tap "another_pass_insert $opts ($name) succeeds"

  if [[ -v want_stdout ]]; then
    [[ $(wc -l <"$tap_tmp/insert_out") -eq $want_stdout ]]
  else
    [[ ! -s "$tap_tmp/insert_out" ]]
  fi
  tap "another_pass_insert $opts ($name) ... stdout is ${want_stdout:+not }silent"

  if [[ -v want_stderr ]]; then
    [[ $(wc -l <"$tap_tmp/insert_err") -eq $want_stderr ]]
  else
    [[ ! -s "$tap_tmp/insert_err" ]]
  fi
  tap "another_pass_insert $opts ($name) ... stderr is ${want_stderr:+not }silent"

  for password; do
    [[ -e "$dir/$password.gpg" ]]
    tap "another_pass_insert $opts ($name) ... it creates \$dir/$password.gpg"

    [[ $(stat -c%a "$dir/$password.gpg") == "600" ]]
    tap "another_pass_insert $opts ($name) ... with the correct access rights"

    gpg --quiet --batch --decrypt "$dir/$password.gpg" >"$tap_tmp/decrypted"
    tap "another_pass_insert $opts ($name) ... which is decryptable"

    diff -u "$tap_tmp/decrypted" "$tap_tmp/should_be"
    tap "another_pass_insert $opts ($name) ... has the correct encrypted contents"
  done
}

do_git_tests() { # 6
  if [[ $# -eq 0 ]]; then
    set -- password
    name="default password"
  else
    name="$@"
  fi

  # This needs to be better thought out
  l=0
  while read -r line; do
    case $l in
      0) r="Insert $name\$" ;;
      1) r="^$# files? changed" ;;
      2) r="^create mode [0-7]+ " ;;
    esac
    [[ $line =~ $r ]]
    tap "another_pass_insert $opts ($name) ... line $l is correct"
    ((l++))
  done <"$tap_tmp/insert_out"

  test_git "$dir" status >/dev/null
  tap "another_pass_insert $opts ($name) ... the git directory is clean"

  test_git "$dir" log --pretty=oneline | head -n1 >"$tap_tmp/lastlog"
  sed 's/[0-9a-f]* //' <"$tap_tmp/lastlog" >"$tap_tmp/lastlog_bare"
  [[ "$(cat "$tap_tmp/lastlog_bare")" == "Insert $name" ]]
  tap "another_pass_insert $opts ($name) ... the git log is correct"
}

once=$'secret\n'
good=$'secret\nsecret\n'
bad=$'wrong\nsecret\n'
multiline=$'secret\nwith\nother\nlines'

# Without git, no repeat
opts="--skip-git --once"

##   default password
prepare_insert $opts
echo -n "$once" >"$tap_tmp/should_be"
echo -n "$once" | another-pass -s "$dir" $opts insert >"$tap_tmp/insert_out" 2>"$tap_tmp/insert_err"
do_standard_tests

##   password in root
prepare_insert $opts
echo -n "$once" >"$tap_tmp/should_be"
echo -n "$once" | another-pass -s "$dir" $opts insert "foo" >"$tap_tmp/insert_out" 2>"$tap_tmp/insert_err"
do_standard_tests "foo"

##   password in subdir
prepare_insert $opts
echo -n "$once" >"$tap_tmp/should_be"
echo -n "$once" | another-pass -s "$dir" $opts insert "bar/baz/bing" >"$tap_tmp/insert_out" 2>"$tap_tmp/insert_err"
do_standard_tests "bar/baz/bing"

##   multiple passwords
prepare_insert $opts
echo -n "$once" >"$tap_tmp/should_be"
echo -n "$once$once$once" | another-pass -s "$dir" $opts insert "foo" "bar/baz/bing" "bar/baz" >"$tap_tmp/insert_out" 2>"$tap_tmp/insert_err"
do_standard_tests "foo" "bar/baz/bing" "bar/baz"


# Without git, repeat password
opts="--skip-git"

##   default password
prepare_insert $opts
echo -n "$once" >"$tap_tmp/should_be"
echo -n "$good" | another-pass -s "$dir" $opts insert >"$tap_tmp/insert_out" 2>"$tap_tmp/insert_err"
do_standard_tests

##   password in root
prepare_insert $opts
echo -n "$once" >"$tap_tmp/should_be"
echo -n "$good" | another-pass -s "$dir" $opts insert "foo" >"$tap_tmp/insert_out" 2>"$tap_tmp/insert_err"
do_standard_tests "foo"

##   password in subdir
prepare_insert $opts
echo -n "$once" >"$tap_tmp/should_be"
echo -n "$good" | another-pass -s "$dir" $opts insert "bar/baz/bing" >"$tap_tmp/insert_out" 2>"$tap_tmp/insert_err"
do_standard_tests "bar/baz/bing"

##   multiple passwords
prepare_insert $opts
echo -n "$once" >"$tap_tmp/should_be"
echo -n "$good$good$good" | another-pass -s "$dir" $opts insert "foo" "bar/baz/bing" "bar/baz" >"$tap_tmp/insert_out" 2>"$tap_tmp/insert_err"
do_standard_tests "foo" "bar/baz/bing" "bar/baz"


# Without git, multiline password
opts="--skip-git --multiline"

##   default password
prepare_insert $opts
echo -n "$multiline" >"$tap_tmp/should_be"
echo -n "$multiline" | another-pass -s "$dir" $opts insert >"$tap_tmp/insert_out" 2>"$tap_tmp/insert_err"
do_standard_tests

###   password in root
prepare_insert $opts
echo -n "$multiline" >"$tap_tmp/should_be"
echo -n "$multiline" | another-pass -s "$dir" $opts insert "foo" >"$tap_tmp/insert_out" 2>"$tap_tmp/insert_err"
do_standard_tests "foo"

##   password in subdir
prepare_insert $opts
echo -n "$multiline" >"$tap_tmp/should_be"
echo -n "$multiline" | another-pass -s "$dir" $opts insert "bar/baz/bing" >"$tap_tmp/insert_out" 2>"$tap_tmp/insert_err"
do_standard_tests "bar/baz/bing"

##   multiple passwords
#prepare_insert $opts
#echo -n "$multiline" >"$tap_tmp/should_be"
#echo -n "$multiline$multiline$multiline" | another-pass -s "$dir" $opts insert "foo" "bar/baz/bing" "bar/baz" >"$tap_tmp/insert_out" 2>"$tap_tmp/insert_err"
#do_standard_tests "foo" "bar/baz/bing" "bar/baz"


# Without git, delimeted multiline password
## Unimplemented


# With git, no repeat
opts="--once"

##   default password
prepare_insert $opts
echo -n "$once" >"$tap_tmp/should_be"
echo -n "$once" | another-pass -s "$dir" $opts insert >"$tap_tmp/insert_out" 2>"$tap_tmp/insert_err"
want_stdout=3 do_standard_tests
do_git_tests

##   password in root
prepare_insert $opts
echo -n "$once" >"$tap_tmp/should_be"
echo -n "$once" | another-pass -s "$dir" $opts insert "foo" >"$tap_tmp/insert_out" 2>"$tap_tmp/insert_err"
want_stdout=3 do_standard_tests "foo"
do_git_tests "foo"

##   password in subdir
prepare_insert $opts
echo -n "$once" >"$tap_tmp/should_be"
echo -n "$once" | another-pass -s "$dir" $opts insert "bar/baz/bing" >"$tap_tmp/insert_out" 2>"$tap_tmp/insert_err"
want_stdout=3 do_standard_tests "bar/baz/bing"
do_git_tests "bar/baz/bing"

##   multiple passwords
prepare_insert $opts
echo -n "$once" >"$tap_tmp/should_be"
echo -n "$once$once$once" | another-pass -s "$dir" $opts insert "foo" "bar/baz/bing" "bar/baz" >"$tap_tmp/insert_out" 2>"$tap_tmp/insert_err"
want_stdout=5 do_standard_tests "foo" "bar/baz/bing" "bar/baz"
do_git_tests "foo" "bar/baz/bing" "bar/baz"


# With git, repeat password
opts=""

##   default password
prepare_insert $opts
echo -n "$once" >"$tap_tmp/should_be"
echo -n "$good" | another-pass -s "$dir" $opts insert >"$tap_tmp/insert_out" 2>"$tap_tmp/insert_err"
want_stdout=3 do_standard_tests

##   password in root
prepare_insert $opts
echo -n "$once" >"$tap_tmp/should_be"
echo -n "$good" | another-pass -s "$dir" $opts insert "foo" >"$tap_tmp/insert_out" 2>"$tap_tmp/insert_err"
want_stdout=3 do_standard_tests "foo"

##   password in subdir
prepare_insert $opts
echo -n "$once" >"$tap_tmp/should_be"
echo -n "$good" | another-pass -s "$dir" $opts insert "bar/baz/bing" >"$tap_tmp/insert_out" 2>"$tap_tmp/insert_err"
want_stdout=3 do_standard_tests "bar/baz/bing"

##   multiple passwords
prepare_insert $opts
echo -n "$once" >"$tap_tmp/should_be"
echo -n "$good$good$good" | another-pass -s "$dir" $opts insert "foo" "bar/baz/bing" "bar/baz" >"$tap_tmp/insert_out" 2>"$tap_tmp/insert_err"
want_stdout=5 do_standard_tests "foo" "bar/baz/bing" "bar/baz"


# With git, multiline password
opts="--multiline"

##   default password
prepare_insert $opts
echo -n "$multiline" >"$tap_tmp/should_be"
echo -n "$multiline" | another-pass -s "$dir" $opts insert >"$tap_tmp/insert_out" 2>"$tap_tmp/insert_err"
want_stdout=3 do_standard_tests

###   password in root
prepare_insert $opts
echo -n "$multiline" >"$tap_tmp/should_be"
echo -n "$multiline" | another-pass -s "$dir" $opts insert "foo" >"$tap_tmp/insert_out" 2>"$tap_tmp/insert_err"
want_stdout=3 do_standard_tests "foo"

##   password in subdir
prepare_insert $opts
echo -n "$multiline" >"$tap_tmp/should_be"
echo -n "$multiline" | another-pass -s "$dir" $opts insert "bar/baz/bing" >"$tap_tmp/insert_out" 2>"$tap_tmp/insert_err"
want_stdout=3 do_standard_tests "bar/baz/bing"

##   multiple passwords
#prepare_insert $opts
#echo -n "$multiline" >"$tap_tmp/should_be"
#echo -n "$multiline$multiline$multiline" | another-pass -s "$dir" $opts insert "foo" "bar/baz/bing" "bar/baz" >"$tap_tmp/insert_out" 2>"$tap_tmp/insert_err"
#do_standard_tests "foo" "bar/baz/bing" "bar/baz"


# With git, delimeted multiline password
## Unimplemented


# With git, file extant, no repeat
opts="--overwrite --once"

##   default password
prepare_insert $opts
touch "$dir/password.gpg"
echo -n "$once" >"$tap_tmp/should_be"
echo -n "$once" | another-pass -s "$dir" $opts insert >"$tap_tmp/insert_out" 2>"$tap_tmp/insert_err"
want_stdout=3 do_standard_tests
do_git_tests

##   password in root
prepare_insert $opts
echo -n "$once" >"$tap_tmp/should_be"
echo -n "$once" | another-pass -s "$dir" $opts insert "foo" >"$tap_tmp/insert_out" 2>"$tap_tmp/insert_err"
want_stdout=3 do_standard_tests "foo"
do_git_tests "foo"

##   password in subdir
prepare_insert $opts
echo -n "$once" >"$tap_tmp/should_be"
echo -n "$once" | another-pass -s "$dir" $opts insert "bar/baz/bing" >"$tap_tmp/insert_out" 2>"$tap_tmp/insert_err"
want_stdout=3 do_standard_tests "bar/baz/bing"
do_git_tests "bar/baz/bing"

##   multiple passwords
#prepare_insert $opts
#echo -n "$once" >"$tap_tmp/should_be"
#echo -n "$once$once$once" | another-pass -s "$dir" $opts insert "foo" "bar/baz/bing" "bar/baz" >"$tap_tmp/insert_out" 2>"$tap_tmp/insert_err"
#want_stdout=5 do_standard_tests "foo" "bar/baz/bing" "bar/baz"
#do_git_tests "foo" "bar/baz/bing" "bar/baz"


# With git, file extant, repeat password
opts="--overwrite"

##   default password
prepare_insert $opts
echo -n "$once" >"$tap_tmp/should_be"
echo -n "$good" | another-pass -s "$dir" $opts insert >"$tap_tmp/insert_out" 2>"$tap_tmp/insert_err"
want_stdout=3 do_standard_tests

##   password in root
prepare_insert $opts
echo -n "$once" >"$tap_tmp/should_be"
echo -n "$good" | another-pass -s "$dir" $opts insert "foo" >"$tap_tmp/insert_out" 2>"$tap_tmp/insert_err"
want_stdout=3 do_standard_tests "foo"

##   password in subdir
prepare_insert $opts
echo -n "$once" >"$tap_tmp/should_be"
echo -n "$good" | another-pass -s "$dir" $opts insert "bar/baz/bing" >"$tap_tmp/insert_out" 2>"$tap_tmp/insert_err"
want_stdout=3 do_standard_tests "bar/baz/bing"

##   multiple passwords
#prepare_insert $opts
#echo -n "$once" >"$tap_tmp/should_be"
#echo -n "$good$good$good" | another-pass -s "$dir" $opts insert "foo" "bar/baz/bing" "bar/baz" >"$tap_tmp/insert_out" 2>"$tap_tmp/insert_err"
#want_stdout=5 do_standard_tests "foo" "bar/baz/bing" "bar/baz"


# With git, file extant, multiline password
opts="--multiline --overwrite"

##   default password
prepare_insert $opts
echo -n "$multiline" >"$tap_tmp/should_be"
echo -n "$multiline" | another-pass -s "$dir" $opts insert >"$tap_tmp/insert_out" 2>"$tap_tmp/insert_err"
want_stdout=3 do_standard_tests

###   password in root
prepare_insert $opts
echo -n "$multiline" >"$tap_tmp/should_be"
echo -n "$multiline" | another-pass -s "$dir" $opts insert "foo" >"$tap_tmp/insert_out" 2>"$tap_tmp/insert_err"
want_stdout=3 do_standard_tests "foo"

##   password in subdir
prepare_insert $opts
echo -n "$multiline" >"$tap_tmp/should_be"
echo -n "$multiline" | another-pass -s "$dir" $opts insert "bar/baz/bing" >"$tap_tmp/insert_out" 2>"$tap_tmp/insert_err"
want_stdout=3 do_standard_tests "bar/baz/bing"

##   multiple passwords
#prepare_insert $opts
#echo -n "$multiline" >"$tap_tmp/should_be"
#echo -n "$multiline$multiline$multiline" | another-pass -s "$dir" $opts insert "foo" "bar/baz/bing" "bar/baz" >"$tap_tmp/insert_out" 2>"$tap_tmp/insert_err"
#do_standard_tests "foo" "bar/baz/bing" "bar/baz"


# With git, file extant, delimeted multiline password
## Unimplemented


# vim: set ft=sh fdm=marker:
