#!/bin/bash
. tlib/another-pass-tap.bash

# Test that passfile_find works correctly

Test::Tap:plan tests 31

load_source
storedir_find() { echo "$@" >"$tap_tmp/storedir_find"; }
passfile_find
[[ "$(cat "$tap_tmp/storedir_find")" == --complain ]]
tap 'passfile_find calls storedir_find --complain'

load_source
passfile_find
[[ $? -eq 4 ]]
tap 'passfile_find returns 4 if nothing is passed in'
[[ ! -v passfile ]]
tap '... and $passfile is unset'

# Test for full paths

load_source
storedir_find() { return 0; }
mkdir "$tap_tmp/gpgexists"
mkdir "$tap_tmp/gpgexists/foo"
touch "$tap_tmp/gpgexists/foo/bar.gpg"
storedir="$tap_tmp/gpgexists"
passfile_find "foo/bar.gpg"
tap 'paths ending .gpg should succeed when the file exists'
[[ $passfile == foo/bar.gpg ]]
tap '... and pass through as-is'

load_source
storedir_find() { return 0; }
mkdir "$tap_tmp/gpgnotexists"
storedir="$tap_tmp/gpgnotexists"
! passfile_find "foo/bar.gpg"
tap 'paths ending .gpg should fail when the file doesn'\''t exist' #'
[[ $passfile == foo/bar.gpg ]]
tap '... but still pass through as-is'


load_source
storedir_find() { return 0; }
mkdir "$tap_tmp/ascexists"
mkdir "$tap_tmp/ascexists/foo"
touch "$tap_tmp/ascexists/foo/bar.asc"
storedir="$tap_tmp/ascexists"
passfile_find "foo/bar.asc"
tap 'paths ending .asc should succeed when the file exists'
[[ $passfile == foo/bar.asc ]]
tap '... and pass through as-is'

load_source
storedir_find() { return 0; }
mkdir "$tap_tmp/ascnotexists"
storedir="$tap_tmp/ascnotexists"
! passfile_find "foo/bar.asc"
tap 'paths ending .asc should fail when the file doesn'\''t exist' #'
[[ $passfile == foo/bar.asc ]]
tap '... but still pass through as-is'

# Test for the conflict warning

load_source
storedir_find() { return 0; }
mkdir "$tap_tmp/conflictnogit"
touch "$tap_tmp/conflictnogit/foo.gpg"
touch "$tap_tmp/conflictnogit/foo.asc"
storedir="$tap_tmp/conflictnogit"
passfile_find "foo" 2>"$tap_tmp/should_be"
[[ $? -eq 2 ]]
tap 'passfile_find returns 2 when a gpg and asc file both exist'
should_be="WARNING: Password foo has asc and gpg file."
[[ "$(cat "$tap_tmp/should_be")" == $should_be ]]
tap '... and warns on stderr'
[[ $passfile == 'foo.gpg' ]]
tap '... and sets passfile to the .gpg file'

# There can't be a conflict if storedir_find returns 2 (doesn't exist)

load_source
storedir_find() { return 3; }
mkdir "$tap_tmp/conflictwithgit"
touch "$tap_tmp/conflictwithgit/foo.gpg"
touch "$tap_tmp/conflictwithgit/foo.asc"
storedir="$tap_tmp/conflictwithgit"
passfile_find "foo" 2>"$tap_tmp/should_be"
[[ $? -eq 2 ]]
tap 'passfile_find returns 2 when a gpg and asc file both exist without .git'
should_be="WARNING: Password foo has asc and gpg file."
[[ "$(cat "$tap_tmp/should_be")" == $should_be ]]
tap '... and warns on stderr'
[[ $passfile == 'foo.gpg' ]]
tap '... and sets passfile to the .gpg file'

# Test for using an asc file if it exists and returning test

load_source
storedir_find() { return 0; }
mkdir "$tap_tmp/withgpg"
touch "$tap_tmp/withgpg/foo.gpg"
storedir="$tap_tmp/withgpg"
passfile_find "foo"
tap 'passfile_find succeeds when a gpg file exists'
[[ $passfile == 'foo.gpg' ]]
tap '... and sets passfile'

load_source
storedir_find() { return 0; }
mkdir "$tap_tmp/withasc"
touch "$tap_tmp/withasc/foo.asc"
storedir="$tap_tmp/withasc"
passfile_find "foo"
tap 'passfile_find succeeds when a asc file exists'
[[ $passfile == 'foo.asc' ]]
tap '... and sets passfile'

load_source
storedir_find() { return 0; }
mkdir "$tap_tmp/empty"
storedir="$tap_tmp/empty"
passfile_find "foo"
[[ $? -eq 1 ]]
tap 'passfile_find returns 1 when no file exists'
[[ $passfile == 'foo.gpg' ]]
tap '... and sets passfile to $1.gpg'

load_source
storedir_find() { return 2; }
passfile_find "foo"
[[ $? -eq 3 ]]
tap 'passfile_find returns 3 when $storedir doesn'\''t exist' #'
[[ $passfile == 'foo.gpg' ]]
tap '... and sets passfile to $1.gpg'

load_source
storedir_find() { return 3; }
mkdir "$tap_tmp/withgpgnogit"
touch "$tap_tmp/withgpgnogit/foo.gpg"
storedir="$tap_tmp/withgpgnogit"
passfile_find "foo"
[[ $? -eq 3 ]]
tap 'passfile_find returns 3 when $storedir isn'\''t a git directory' #'
[[ $passfile == 'foo.gpg' ]]
tap '... and sets passfile to $1.gpg if $1.gpg exists'

load_source
storedir_find() { return 3; }
mkdir "$tap_tmp/emptynogit"
storedir="$tap_tmp/emptynogit"
passfile_find "foo"
[[ $? -eq 3 ]]
tap 'passfile_find returns 3 when $storedir isn'\''t a git directory' #'
[[ $passfile == 'foo.gpg' ]]
tap '... and sets passfile to $1.gpg'

load_source
storedir_find() { return 3; }
mkdir "$tap_tmp/withascnogit"
touch "$tap_tmp/withascnogit/foo.asc"
storedir="$tap_tmp/withascnogit"
passfile_find "foo"
[[ $? -eq 3 ]]
tap 'passfile_find returns 3 when $storedir isn'\''t a git directory' #'
[[ $passfile == 'foo.asc' ]]
tap '... and sets passfile to $1.asc if $1.asc exists'

# vim: set ft=sh fdm=marker:
