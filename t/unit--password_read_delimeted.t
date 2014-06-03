#!/bin/bash
. tlib/another-pass-tap.bash

# Test that password_read_delimeted works correctly

Test::Tap:plan tests 1

# Needs to test the terminal, not stdio

tap

# vim: set ft=sh fdm=marker:
