#!/usr/bin/env bats

load 'test_helper/test_helper.bash'

@test "dotty-help: Show summary of common commands without args" {
  run dotty-help
  assert_success
  assert_line "Usage: dotty <command> [<args>]"
  assert_line "Some useful dotty commands are:"
}

@test "dotty-help: Invalid command" {
  run dotty-help hello
  assert_failure 1
  assert_output "dotty: no such command \`hello'"
}

@test "dotty-help: show help for a specific command" {
  mkdir -p "${DOTTY_TEST_DIR}/bin"
  cat > "${DOTTY_TEST_DIR}/bin/dotty-hello" <<EOF
#!shebang
# Usage: dotty hello <world>
# Summary: Says "hello" to you, from dotty
# This command is useful for saying hello.
echo hello
EOF

  run dotty-help hello
  assert_success
  assert_output <<EOF
Usage: dotty hello <world>

This command is useful for saying hello.
EOF
}

@test "dotty-help: Replace missing extended help with summary text" {
  mkdir -p "${DOTTY_TEST_DIR}/bin"
  cat > "${DOTTY_TEST_DIR}/bin/dotty-hello" <<EOF
#!shebang
# Usage: dotty hello <world>
# Summary: Says "hello" to you, from dotty
echo hello
EOF

  run dotty-help hello
  assert_success
  assert_output <<EOF
Usage: dotty hello <world>

Says "hello" to you, from dotty
EOF
}

@test "dotty-help: Extract only usage" {
  mkdir -p "${DOTTY_TEST_DIR}/bin"
  cat > "${DOTTY_TEST_DIR}/bin/dotty-hello" <<EOF
#!shebang
# Usage: dotty hello <world>
# Summary: Says "hello" to you, from dotty
# This extended help won't be shown.
echo hello
EOF

  run dotty-help --usage hello
  assert_success
  assert_output "Usage: dotty hello <world>"
}

@test "dotty-help: Multiline usage section" {
  mkdir -p "${DOTTY_TEST_DIR}/bin"
  cat > "${DOTTY_TEST_DIR}/bin/dotty-hello" <<EOF
#!shebang
# Usage: dotty hello <world>
#        dotty hi [everybody]
#        dotty hola --translate
# Summary: Says "hello" to you, from dotty
# Help text.
echo hello
EOF

  run dotty-help hello
  assert_success
  assert_output <<EOF
Usage: dotty hello <world>
       dotty hi [everybody]
       dotty hola --translate

Help text.
EOF
}

@test "dotty-help: Multiline extended help section" {
  mkdir -p "${DOTTY_TEST_DIR}/bin"
  cat > "${DOTTY_TEST_DIR}/bin/dotty-hello" <<EOF
#!shebang
# Usage: dotty hello <world>
# Summary: Says "hello" to you, from dotty
# This is extended help text.
# It can contain multiple lines.
#
# And paragraphs.

echo hello
EOF

  run dotty-help hello
  assert_success
  assert_output <<EOF
Usage: dotty hello <world>

This is extended help text.
It can contain multiple lines.

And paragraphs.
EOF
}
