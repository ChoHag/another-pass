#!/bin/bash
. tlib/another-pass-tap.bash

# Test that call_gpg works correctly

Test::Tap:plan tests 1

load_source
diff() { echo "$@" >"$tap_tmp/diff_args"; }
prepend="-u"

call_diff foo bar baz

[[ "$(cat "$tap_tmp/diff_args")" == "$prepend foo bar baz" ]]
tap 'call_diff calls diff with -u'

# vim: set ft=sh fdm=marker:
