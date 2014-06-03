#!/bin/bash
. tlib/another-pass-tap.bash

# Test that init works correctly

Test::Tap:plan tests 11

prepare_init() {
  load_source
  storedir_find() { return 2; }
  mkdir() { :; }
  rc_init() { :; }
}

clean_init() {
  unset mkdir
}


# Test arguments

prepare_init
storedir=set
another_pass_init foo bar 2>/dev/null
[[ $? -eq 2 ]]
tap 'init with >1 argument fails if $storedir is set'

prepare_init
storedir=set
another_pass_init foo 2>/dev/null
[[ $? -eq 2 ]]
tap 'init with 1 argument fails if $storedir is set'

prepare_init
another_pass_init foo bar 2>/dev/null
[[ $? -eq 2 ]]
tap 'init with >1 argument fails if $storedir is not set'

prepare_init
another_pass_init foo 2>/dev/null
tap 'init with 1 argument succeeds if $storedir is not set'
[[ $storedir == foo ]]
tap 'init with 1 argument sets $storedir to it'
clean_init

prepare_init
storedir_find() { storedir=set_here; return 2; }
another_pass_init 2>/dev/null
tap 'init with 0 arguments succeeds if $storedir is not set'
[[ $storedir == set_here ]]
tap 'init with 0 arguments sets $storedir via storedir_find'
clean_init


# Test failure

mkdir "$tap_tmp/enotgit"
load_source
! another_pass_init "$tap_tmp/enotgit" 2>/dev/null
tap 'init fails if the storedir exists'


# Test action

load_source
another_pass_init "$tap_tmp/xnoskip" 2>/dev/null
[[ -d "$tap_tmp/xnoskip" ]]
tap 'init creates the store directory'
[[ -d "$tap_tmp/xnoskip/.git" ]]
tap 'init creates .git inside the store directory'

load_source
skip_git=1
another_pass_init "$tap_tmp/xskipgit" 2>/dev/null
[[ ! -d "$tap_tmp/xskipgit/.git" ]]
tap 'init doesn'\''t create .git if $skip_git is set'

# vim: set ft=sh fdm=marker:
