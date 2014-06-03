#!/bin/bash
. tlib/another-pass-tap.bash

# Test that storedir_find works correctly

Test::Tap:plan tests 18

load_source
storedir=test-already
PASSWORD_STORE_DIR=test-psd
storedir_find
[[ $storedir == test-already ]]
tap '$storedir is unchanged by storedir_find'

load_source
PASSWORD_STORE_DIR=test-psd
storedir_find
[[ $storedir == test-psd ]]
tap '$storedir is set to $PASSWORD_STORE_DIR'

load_source
unset PASSWORD_STORE_DIR
mkdir "$tap_tmp/asfile"
echo "test-file" >"$tap_tmp/asfile/.password-store"
HOME="$tap_tmp/asfile" storedir_find
[[ $storedir == test-file ]]
tap '$storedir is set to the contents of ~/.password-store if it'\''s a file' #'

load_source
unset PASSWORD_STORE_DIR
mkdir "$tap_tmp/asdir"
mkdir "$tap_tmp/asdir/.password-store"
HOME="$tap_tmp/asdir" storedir_find
[[ $storedir == "$tap_tmp/asdir/.password-store" ]]
tap '$storedir is set to ~/.password-store if it'\''s a directory' #'


load_source
touch "$tap_tmp/notdir"
storedir="$tap_tmp/notdir"
storedir_find 2>"$tap_tmp/silently"
[[ $? -eq 2 ]]
tap 'storedir_find fails with 2 if $storedir is not a directory'
[[ ! -s "$tap_tmp/silently" ]]
tap '... silently'
storedir_find --complain 2>"$tap_tmp/noisily"
[[ -s "$tap_tmp/noisily" ]]
tap '... and noisily with --complain'

load_source
mkdir "$tap_tmp/unreadable"
chmod -r "$tap_tmp/unreadable"
storedir="$tap_tmp/unreadable"
storedir_find 2>"$tap_tmp/silently"
[[ $? -eq 2 ]]
tap 'storedir_find fails with 2 if $storedir is not a readable directory'
[[ ! -s "$tap_tmp/silently" ]]
tap '... silently'
storedir_find --complain 2>"$tap_tmp/noisily"
[[ -s "$tap_tmp/noisily" ]]
tap '... and noisily with --complain'

load_source
mkdir "$tap_tmp/unopenable"
chmod -x "$tap_tmp/unopenable"
storedir="$tap_tmp/unopenable"
storedir_find 2>"$tap_tmp/silently"
[[ $? -eq 2 ]]
tap 'storedir_find fails with 2 if $storedir is not an openable directory'
[[ ! -s "$tap_tmp/silently" ]]
tap '... silently'
storedir_find --complain 2>"$tap_tmp/noisily"
[[ -s "$tap_tmp/noisily" ]]
tap '... and noisily with --complain'

# if not sd/.git and not skip_git, fail 3
#  -- loud if --complain
# if not sd/.git and skip_git, pass
# if sd dir and sd/.git exist, pass

load_source
mkdir "$tap_tmp/nogitbad"
storedir="$tap_tmp/nogitbad"
storedir_find 2>"$tap_tmp/silently"
[[ $? -eq 3 ]]
tap 'storedir_find fails with 3 if $storedir does not contain .git'
[[ ! -s "$tap_tmp/silently" ]]
tap '... silently'
storedir_find --complain 2>"$tap_tmp/noisily"
[[ -s "$tap_tmp/noisily" ]]
tap '... and noisily with --complain'

load_source
mkdir "$tap_tmp/nogitgood"
storedir="$tap_tmp/nogitgood"
skip_git=1
storedir_find
[[ $? -eq 0 ]]
tap 'storedir_find succeeds if $storedir has no .git but skip_git is set'

load_source
mkdir "$tap_tmp/withgit"
mkdir "$tap_tmp/withgit/.git"
storedir="$tap_tmp/withgit"
storedir_find
[[ $? -eq 0 ]]
tap 'storedir_find succeeds if $storedir has .git'

# vim: set ft=sh fdm=marker:
