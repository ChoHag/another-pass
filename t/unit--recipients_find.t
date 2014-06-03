#!/bin/bash
. tlib/another-pass-tap.bash

# Test that recipients_find works correctly

Test::Tap:plan tests 23

# Test that storedir is set

load_source
recipients_find
[[ $? -eq 2 ]]
tap 'recipients_find returns 2 if $storedir is not set'

# Tests in an empty directory

mkdir "$tap_tmp/empty"
storedir="$tap_tmp/empty"
default_recipients=(default)

recipients_find
tap 'recipients_find succeeds if $storedir is set to an empty directory'
[[ ${#recipients[@]} -eq 1 && ${recipients[0]} == default ]]
tap 'recipients_find returns $default_recipients'

recipients_find foo
tap 'recipients_find foo succeeds if $storedir is set to an empty directory'
[[ ${#recipients[@]} -eq 1 && ${recipients[0]} == default ]]
tap '... and returns $default_recipients'

recipients_find foo/bar
tap 'recipients_find foo/bar succeeds if $storedir is set to an empty directory'
[[ ${#recipients[@]} -eq 1 && ${recipients[0]} == default ]]
tap '... and returns $default_recipients'

# Tests with a single .keyids

mkdir "$tap_tmp/withids"
echo "id-foo" >>"$tap_tmp/withids/.keyids"
echo "id-bar" >>"$tap_tmp/withids/.keyids"
storedir="$tap_tmp/withids"
default_recipients=(default)

unset recipients
recipients_find
tap 'recipients_find succeeds if $storedir has a .keyids file'
[[ ${#recipients[@]} -eq 4 \
  && ${recipients[0]} == --recipient && ${recipients[1]} == id-foo \
  && ${recipients[2]} == --recipient && ${recipients[3]} == id-bar ]]
tap 'recipients_find returns /.keyids'

unset recipients
recipients_find foo
tap 'recipients_find foo succeeds if $storedir has a .keyids file'
[[ ${#recipients[@]} -eq 4 \
  && ${recipients[0]} == --recipient && ${recipients[1]} == id-foo \
  && ${recipients[2]} == --recipient && ${recipients[3]} == id-bar ]]
tap '... and returns /.keyids'

unset recipients
recipients_find foo/bar
tap 'recipients_find foo/bar succeeds if $storedir has a .keyids file'
[[ ${#recipients[@]} -eq 4 \
  && ${recipients[0]} == --recipient && ${recipients[1]} == id-foo \
  && ${recipients[2]} == --recipient && ${recipients[3]} == id-bar ]]
tap '... and returns /.keyids'

# Tests with a second .keyids

mkdir "$tap_tmp/with2ids"
echo "id-top-foo" >>"$tap_tmp/with2ids/.keyids"
echo "id-top-bar" >>"$tap_tmp/with2ids/.keyids"
mkdir "$tap_tmp/with2ids/foo"
echo "id-2nd-foo" >>"$tap_tmp/with2ids/foo/.keyids"
echo "id-2nd-bar" >>"$tap_tmp/with2ids/foo/.keyids"
storedir="$tap_tmp/with2ids"
default_recipients=(default)

unset recipients
recipients_find
tap 'recipients_find succeeds if $storedir has a second .keyids file'
[[ ${#recipients[@]} -eq 4 \
  && ${recipients[0]} == --recipient && ${recipients[1]} == id-top-foo \
  && ${recipients[2]} == --recipient && ${recipients[3]} == id-top-bar ]]
tap '... and returns only /.keyids'

unset recipients
recipients_find foo
tap 'recipients_find foo succeeds if $storedir has a second .keyids file'
[[ ${#recipients[@]} -eq 4 \
  && ${recipients[0]} == --recipient && ${recipients[1]} == id-top-foo \
  && ${recipients[2]} == --recipient && ${recipients[3]} == id-top-bar ]]
tap '... and returns only /.keyids'

unset recipients
recipients_find foo/bar
tap 'recipients_find foo/bar succeeds if $storedir has a second .keyids file'
[[ ${#recipients[@]} -eq 8 \
  && ${recipients[0]} == --recipient && ${recipients[1]} == id-top-foo \
  && ${recipients[2]} == --recipient && ${recipients[3]} == id-top-bar \
  && ${recipients[4]} == --recipient && ${recipients[5]} == id-2nd-foo \
  && ${recipients[6]} == --recipient && ${recipients[7]} == id-2nd-bar ]]
tap '... and returns both /.keyids'\' #'

# Tests with a .keyids-reset

mkdir "$tap_tmp/withreset"
echo "id-top-foo" >>"$tap_tmp/withreset/.keyids"
echo "id-top-bar" >>"$tap_tmp/withreset/.keyids"
mkdir "$tap_tmp/withreset/foo"
echo "id-2nd-foo" >>"$tap_tmp/withreset/foo/.keyids"
echo "id-2nd-bar" >>"$tap_tmp/withreset/foo/.keyids"
mkdir "$tap_tmp/withreset/foo/bar"
touch "$tap_tmp/withreset/foo/bar/.keyids-reset"
storedir="$tap_tmp/withreset"
default_recipients=(default)

unset recipients
recipients_find foo/bar/baz
tap 'recipients_find foo/bar/baz succeeds if $storedir has a .keyids-reset file'
[[ ${#recipients[@]} -eq 4 \
  && ${recipients[0]} == --recipient && ${recipients[1]} == id-top-foo \
  && ${recipients[2]} == --recipient && ${recipients[3]} == id-top-bar ]]
tap '... and returns only /.keyids'

# Tests with a .keyids-reset and then a .keyids

mkdir "$tap_tmp/withresetandmore"
echo "id-top-foo" >>"$tap_tmp/withresetandmore/.keyids"
echo "id-top-bar" >>"$tap_tmp/withresetandmore/.keyids"
mkdir "$tap_tmp/withresetandmore/foo"
echo "id-2nd-foo" >>"$tap_tmp/withresetandmore/foo/.keyids"
echo "id-2nd-bar" >>"$tap_tmp/withresetandmore/foo/.keyids"
mkdir "$tap_tmp/withresetandmore/foo/bar"
touch "$tap_tmp/withresetandmore/foo/bar/.keyids-reset"
echo "id-3rd-foo" >>"$tap_tmp/withresetandmore/foo/bar/.keyids"
echo "id-3rd-bar" >>"$tap_tmp/withresetandmore/foo/bar/.keyids"
storedir="$tap_tmp/withresetandmore"
default_recipients=(default)

unset recipients
recipients_find foo/bar/baz
tap 'recipients_find foo/bar/baz succeeds if $storedir has a .keyids-reset and .keyids file'
[[ ${#recipients[@]} -eq 8 \
  && ${recipients[0]} == --recipient && ${recipients[1]} == id-top-foo \
  && ${recipients[2]} == --recipient && ${recipients[3]} == id-top-bar \
  && ${recipients[4]} == --recipient && ${recipients[5]} == id-3rd-foo \
  && ${recipients[6]} == --recipient && ${recipients[7]} == id-3rd-bar ]]
tap '... and returns the default & 3rd-level .keyids'

# vim: set ft=sh fdm=marker:
