#!/bin/bash
. tlib/another-pass-tap.bash

## Need to test $proc

# Test that the environment is cleared out and set correctly

Test::Tap:plan tests 2

load_source 1 2 3
[[ $proc == test ]]
tap 'proc is set from the first argument'

[[ ${#arguments[@]} -eq 3 \
  && ${arguments[0]} == 1 \
  && ${arguments[1]} == 2 \
  && ${arguments[2]} == 3 ]]
tap 'arguments are collected'

