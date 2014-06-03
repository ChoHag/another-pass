#!/bin/bash
. tlib/another-pass-tap.bash

# Test that rc_commit works correctly

Test::Tap:plan tests 7

prepare_rc_commit() {
  load_source
  git() { :; }
}

prepare_rc_commit
unset storedir
rc_commit
[[ $? -eq 2 ]]
tap 'rc_commit fails with 2 if $storedir is not set'

prepare_rc_commit
mkdir "$tap_tmp/nogit"
storedir="$tap_tmp/nogit"
skip_git=1
git() { touch "$tap_tmp/test-git"; }
rc_commit
[[ $? -eq 0 ]]
tap 'rc_commit succeeds if skip_git is set'
[[ ! -e "$tap_tmp/test-git" ]]
tap 'rc_commit doesn'\''t call git if skip_git is set' #'

prepare_rc_commit
mkdir "$tap_tmp/withgit"
mkdir "$tap_tmp/withgit/.git"
storedir="$tap_tmp/withgit"
git() {
  echo $PWD >"$tap_tmp/gitpwd"
  echo "$@" >"$tap_tmp/gitargs"
}
rc_commit foo
[[ $? -eq 0 ]]
tap 'rc_commit succeeds if .git exists'
[[ "$(cat "$tap_tmp/gitargs")" == "commit -m foo" ]]
tap 'rc_commit calls git with the correct arguments'
[[ "$(cat "$tap_tmp/gitpwd")" == "$tap_tmp/withgit" ]]
tap 'rc_commit calls git inside the store directory'
[[ $PWD == $startdir ]]
tap 'rc_commit does not change $PWD'

# vim: set ft=sh fdm=marker:
