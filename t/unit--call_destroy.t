#!/bin/bash
. tlib/another-pass-tap.bash

# Test that call_gpg works correctly

Test::Tap:plan tests 1

load_source
rm() { echo "$@" >"$tap_tmp/destroy_args"; }
prepend="-f"

call_destroy foo bar baz

[[ "$(cat "$tap_tmp/destroy_args")" == "$prepend foo bar baz" ]]
tap 'call_destroy calls rm with -f'

# vim: set ft=sh fdm=marker:
