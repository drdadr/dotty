#!/usr/bin/env bats

load 'test_helper/test_helper.bash'

@test "dotty-commands: List all commands" {
  run dotty-commands
  assert_success
  assert_line "link"
  assert_line "list"
  assert_line "unlink"
  refute_line "shell"
  refute_line "hello"
  assert_line "echo"
}

@test "dotty-commands: Path with spaces" {
  path="${DOTTY_TEST_DIR}/my commands"
  cmd="${path}/dotty-hello"
  mkdir -p "$path"
  touch "$cmd"
  chmod +x "$cmd"

  PATH="${path}:$PATH" run dotty-commands
  assert_success
  assert_line "hello"
}
