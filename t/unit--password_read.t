#!/bin/bash
. tlib/another-pass-tap.bash

# Test that password_read works correctly

Test::Tap:plan tests 11

#  if [[ -v multiline ]]; then
#    if [[ -v delimeter ]]; then
#      password_read_delimeted "$P" | passfile_write "$P"
#    else
#      if [[ -v echo_tty ]]; then
#	echo "Enter contents of $P, terminated with EOF (ctrl-d):"
#      fi
#      passfile_write "$P"
#    fi
#  else
#    password_read_single "$P" | passfile_write "$P"
#  fi

# if m & d; password_read_delimeted $1 | passfile_write $1
# if m &!d &!e; passfile_write $1
# if m &!d & e; check stdout; passfile_write $1
# if !m; password_read_delimeted $1 | passfile_write $1

prepare_password_read() {
  load_source
  password_read_delimeted() { :; }
  password_read_single() { :; }
  passfile_write() { :; }
}

prepare_password_read
multiline=1
delimeter=xxx
password_read_delimeted() {
  echo "delimeted 1"
  echo "delimeted 2"
}
passfile_write() {
  cat >"$tap_tmp/multiline-delimeted-$1"
}
password_read foo
tap 'multiline delimeter password_read succeeds'
[[ -e "$tap_tmp/multiline-delimeted-foo" ]]
tap '... calls passfile_write with the password name'
( echo "delimeted 1"; echo "delimeted 2" ) >"$tap_tmp/should_be"
diff -u "$tap_tmp/multiline-delimeted-foo" "$tap_tmp/should_be" >&2
tap '... pipes password_read_delimeted into passfile_write'

prepare_password_read
multiline=1
unset delimeter
unset echo_tty
passfile_write() {
  cat >"$tap_tmp/multiline-undelimeted-$1"
}
( echo "delimeted 1"; echo "delimeted 2" ) >"$tap_tmp/should_be"
<"$tap_tmp/should_be" password_read foo >"$tap_tmp/silent"
tap 'multiline no delimeter no echo_tty password_read succeeds'
[[ -e "$tap_tmp/multiline-undelimeted-foo" ]]
tap '... calls passfile_write with the password name'
diff -u "$tap_tmp/multiline-undelimeted-foo" "$tap_tmp/should_be" >&2
tap '... pipes stdin into passfile_write'
[[ ! -s "$tap_tmp/silent" ]]
tap '... is silent'

prepare_password_read
multiline=1
unset delimeter
echo_tty=1
passfile_write() {
  cat >"$tap_tmp/multiline-undelimeted-$1"
}
( echo "delimeted 1"; echo "delimeted 2" ) >"$tap_tmp/should_be"
<"$tap_tmp/should_be" password_read foo >"$tap_tmp/noisy"
tap 'multiline no delimeter echo_tty password_read succeeds'
[[ -e "$tap_tmp/multiline-undelimeted-foo" ]]
tap '... calls passfile_write with the password name'
diff -u "$tap_tmp/multiline-undelimeted-foo" "$tap_tmp/should_be" >&2
tap '... pipes stdin into passfile_write'
[[ "$(cat "$tap_tmp/noisy")" == "Enter contents of foo, terminated with EOF (ctrl-d):" ]]
tap '... talks to the user on stdout'

# vim: set ft=sh fdm=marker:
