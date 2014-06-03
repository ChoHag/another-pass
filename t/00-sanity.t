#!/bin/bash
. tlib/another-pass-tap.bash

# Test for basic sanity

Test::Tap:plan tests 5

[[ -x "$srcdir/another-pass" ]]
tap 'another-pass is executable'

another-pass --help >"$tap_tmp/help"
tap 'help is successful'

[[ "$(cat "$tap_tmp/help")" == "There is no documentation" ]]
tap 'help is helpful'

load_source
[[ $in_test == testing ]]
tap 'execution calls the correct function'

# source another-pass as though it were called as "pass-test"
output=$(bash -c 'exec -a pass-test bash -c "another_pass_test() { echo in_test; }; . another-pass"')
[[ $output == in_test ]]
tap '$0 is parsed correctly'

# vim: set ft=sh fdm=marker:
