#!/bin/bash
. tlib/another-pass-tap.bash

# Test that call_editor works correctly

Test::Tap:plan tests 3

load_source
vi() { echo "vi $@" >"$tap_tmp/vi_args"; }
editor() { echo "editor $@" >"$tap_tmp/editor_args"; }
visual() { echo "visual $@" >"$tap_tmp/visual_args"; }

EDITOR=editor
unset VISUAL
call_editor foo bar baz
[[ "$(cat "$tap_tmp/editor_args")" == "editor foo bar baz" ]]
tap 'call_editor honours $EDITOR'
rm -f "$tap_tmp"/*_args

EDITOR=editor
VISUAL=visual
call_editor foo bar baz
[[ "$(cat "$tap_tmp/visual_args")" == "visual foo bar baz" ]]
tap 'call_editor honours $VISUAL over $EDITOR'
rm -f "$tap_tmp"/*_args

unset EDITOR
unset VISUAL
call_editor foo bar baz
[[ "$(cat "$tap_tmp/vi_args")" == "vi foo bar baz" ]]
tap 'call_editor falls back to vi'
rm -f "$tap_tmp"/*_args

# vim: set ft=sh fdm=marker:
