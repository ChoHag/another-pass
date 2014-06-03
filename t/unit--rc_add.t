#!/bin/bash
. tlib/another-pass-tap.bash

# Test that rc_add works correctly

Test::Tap:plan tests 7

prepare_rc_add() {
  load_source
  git() { :; }
}

prepare_rc_add
unset storedir
rc_add
[[ $? -eq 2 ]]
tap 'rc_add fails with 2 if $storedir is not set'

prepare_rc_add
mkdir "$tap_tmp/nogit"
storedir="$tap_tmp/nogit"
skip_git=1
git() { touch "$tap_tmp/test-git"; }
rc_add
[[ $? -eq 0 ]]
tap 'rc_add succeeds if skip_git is set'
[[ ! -e "$tap_tmp/test-git" ]]
tap 'rc_add doesn'\''t call git if skip_git is set' #'

prepare_rc_add
mkdir "$tap_tmp/withgit"
mkdir "$tap_tmp/withgit/.git"
storedir="$tap_tmp/withgit"
git() {
  echo $PWD >"$tap_tmp/gitpwd"
  echo "$@" >"$tap_tmp/gitargs"
}
rc_add foo bar
[[ $? -eq 0 ]]
tap 'rc_add succeeds if .git exists'
[[ "$(cat "$tap_tmp/gitargs")" == "add ./foo ./bar" ]]
tap 'rc_add calls git with the correct arguments'
[[ "$(cat "$tap_tmp/gitpwd")" == "$tap_tmp/withgit" ]]
tap 'rc_add calls git inside the store directory'
[[ $PWD == $startdir ]]
tap 'rc_add does not change $PWD'

# vim: set ft=sh fdm=marker:
