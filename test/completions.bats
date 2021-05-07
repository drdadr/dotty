#!/usr/bin/env bats

load 'test_helper/test_helper.bash'

create_command() {
  bin="${DOTTY_TEST_DIR}/bin"
  mkdir -p "$bin"
  echo "$2" > "${bin}/$1"
  chmod +x "${bin}/$1"
}

@test "dotty-completions: Command with no completion support" {
  create_command "dotty-hello" "#!$BASH
    echo hello"

  run dotty-completions hello
  assert_success
  assert_output "--help"
}

@test "dotty-completions: Command with completion support" {
  create_command "dotty-hello" "#!$BASH
# Provide dotty completions
if [[ \$1 = --complete ]]; then
  echo hello
else
  exit 1
fi"

  run dotty-completions hello
  assert_success
  assert_output <<EOF
--help
hello
EOF
}

@test "dotty-completions: Forwards extra arguments" {
  create_command "dotty-hello" "#!$BASH
# provide dotty completions
if [[ \$1 = --complete ]]; then
  shift 1
  for arg; do echo \$arg; done
else
  exit 1
fi"

  run dotty-completions hello happy world
  assert_success
  assert_output <<EOF
--help
happy
world
EOF
}
