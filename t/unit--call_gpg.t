#!/bin/bash
. tlib/another-pass-tap.bash

# Test that call_gpg works correctly

Test::Tap:plan tests 2

load_source
gpg() { echo "$@" >"$tap_tmp/gpg_args"; cat >"$tap_tmp/gpg_stdin"; }
prepend="--quiet --yes --batch --no-encrypt-to --no-default-recipient"

echo $'line 1\nline 2' | tee "$tap_tmp/should_be" | call_gpg foo bar baz

[[ "$(cat "$tap_tmp/gpg_args")" == "$prepend foo bar baz" ]]
tap 'call_gpg calls gpg with the correct arguments'

diff -u "$tap_tmp/gpg_stdin" "$tap_tmp/should_be" >&2
tap 'call_gpg pipes its stdin to gpg'

# vim: set ft=sh fdm=marker:
