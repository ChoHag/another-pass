#!/bin/bash
. tlib/another-pass-tap.bash

# Test that something works correctly

Test::Tap:plan tests 1

load_source

false
tap 'write some tests'

# vim: set ft=sh fdm=marker:
