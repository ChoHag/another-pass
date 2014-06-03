#!/bin/bash
. tlib/another-pass-tap.bash

# Test that init works correctly

Test::Tap:plan tests 7

load_source --store-directory "$tap_tmp/new"
another_pass_init >"$tap_tmp/init_out" 2>"$tap_tmp/init_err"
tap 'another_pass_init $tap_tmp/new succeeds'

[[ -d "$tap_tmp/new" ]]
tap '... it creates $tap_tmp/new'

[[ -d "$tap_tmp/new/.git" ]]
tap '... and $tap_tmp/new/.git' ]]

test_git $tap_tmp/new status >/dev/null
tap '... and is a valid git directory'

[[ ! -s "$tap_tmp/init_out" ]]
tap '... stdout is silent'

should_be="Initialized empty Git repository in $tap_tmp/new/.git/"
[[ "$(cat "$tap_tmp/init_err")" == $should_be ]]
tap '... stderr has git'\''s transcript' #'

[[ $storedir == "$tap_tmp/new" ]]
tap '... sets $storedir'

# vim: set ft=sh fdm=marker:
