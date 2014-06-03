#!/bin/bash
. tlib/another-pass-tap.bash

# Test that password_read_single works correctly

Test::Tap:plan tests 1

# in all cases, password and password_repeat should not be set
# if -v once, send a password once
#   password should be output to stdout
#   with -v echo_tty, stderr should be "Enter password for $1: "
# otherwise, send an ok password twice, should go to stdout
#     with -v echo_tty, stderr ...
#   send a bad pair followed by ok, should go to stdout
#     with -v echo_tty, stderr ...

# Needs to test the terminal, not stdio

tap

# vim: set ft=sh fdm=marker:
