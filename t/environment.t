#!/bin/bash
. tlib/another-pass-tap.bash

# Test that the environment is cleared out and set correctly

Test::Tap:plan tests 20

variables=(
  echo_tty
  edit_create
  diff
  headings
  key
  multiline
  overwrite
  read_once
  recursive
  reset_keyids
  skip_git
  storedir
  tempdir
  tempfiles
  use_unsafe_tempdir
)

for v in "${variables[@]}"; do
  eval "$v=1"
done

unset default_recipients
unset generate_symbols
unset generate_length
unset GPG_TTY

load_source

for v in "${variables[@]}"; do
  [[ ! -v $v ]]
  tap "\$$v is unset"
done

[[ ${#default_recipients[@]} -eq 1 ]]
tap '$default_recipients is an array of 1'

[[ ${default_recipients[0]} == '--default-recipient-self' ]]
tap '$default_recipients includes self'

[[ -v generate_symbols && -n "$generate_symbols" ]]
tap '$generate_symbols is set'

[[ -v generate_length && $generate_length -eq 12 ]]
tap '$generate_length is set to 12'

[[ $(sh -c 'echo $GPG_TTY') == "$(tty)" ]]
tap '$GPG_TTY is set to the controlling terminal end exported'

# vim: set ft=sh fdm=marker:
