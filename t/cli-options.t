#!/bin/bash
. tlib/another-pass-tap.bash

# Test options which should set variables

Test::Tap:plan tests 36

set_arguments=(
  "c:          edit_create"
  "create:     edit_create"
  "d:          diff"
  "diff:       diff"
  "e:          echo_tty"
  "echo:       echo_tty"
  "g:          skip_git"
  "skip-git:   skip_git"
  "H:          headings"
  "headings:   headings"
  "m:          multiline"
  "multiline:  multiline"
  "o:          read_once"
  "once:       read_once"
  "O:          overwrite"
  "overwrite:  overwrite"
  "r:          recursive"
  "recurse:    recursive"
  "recursive:  recursive"
  "R:          reset_keyids"
  "reset-keyids: reset_keyids"
  "U:          use_unsafe_tempdir"
  "use-unsafe-tempdir: use_unsafe_tempdir"
)

unset_arguments=(
  "n:          generate_symbols"
  "no-symbols: generate_symbols"
)

value_arguments=(
  "l:          generate_length"
  "length:     generate_length"
  "t:          tempdir"
  "tempdir:    tempdir"
  "s:          storedir"
  "store:      storedir"
  "store-directory: storedir"
)

for argument in "${set_arguments[@]}"; do
  arg=-${argument%%:*}
  if [[ ${#arg} -ne 2 ]]; then arg="-$arg"; fi
  var=${argument##*:* }
  unset $var
  load_source $arg
  [[ -v $var ]]
  tap "$arg sets \$$var"
done

for argument in "${unset_arguments[@]}"; do
  arg=-${argument%%:*}
  if [[ ${#arg} -ne 2 ]]; then arg="-$arg"; fi
  var=${argument##*:* }
  eval "$var=1"
  load_source $arg
  [[ ! -v $var ]]
  tap "$arg unsets \$$var"
done

for argument in "${value_arguments[@]}"; do
  arg=-${argument%%:*}
  if [[ ${#arg} -ne 2 ]]; then arg="-$arg"; fi
  var=${argument##*:* }
  eval "$var=bar"
  load_source $arg foo
  eval "[[ -v \$var && \$$var == foo ]]"
  tap "$arg set \$$var to a value"
done


# Test more magical options

unset default_recipients

load_source -k test

[[ $key == test ]]
tap '$key is set to argument of -k'
[[ ${#default_recipients[@]} -eq 2 \
  && ${default_recipients[0]} == '--recipient' \
  && ${default_recipients[1]} == 'test' ]]
tap '$default_recipients is set to argument of -k'

load_source --key test
[[ $key == test ]]
tap '$key is set to argument of --key'
[[ ${#default_recipients[@]} -eq 2 \
  && ${default_recipients[0]} == '--recipient' \
  && ${default_recipients[1]} == 'test' ]]
tap '$default_recipients is set to argument of --key'

# vim: set ft=sh fdm=marker:
