#!/usr/bin/env bats

load 'test_helper/test_helper.bash'

setup() {
  shared_setup
  INSTALL_DIR="$DOTTY_SOURCE_DIR"/dir1/dotty-install
  export INSTALL_DIR
  mkdir -p "$INSTALL_DIR"
  echo "dir1" >| "${DOTTY_TARGET_DIR}/.dotty-lock"
}

@test "dotty-install: Script with shebang" {
  echo "#!/usr/bin/env python" >| "$INSTALL_DIR/shebang_script"
  echo "import sys; sys.stdout.write(\"Ran in Python\")" >> "$INSTALL_DIR/shebang_script"
  chmod +x "$INSTALL_DIR/shebang_script"

  run dotty-install
  assert_success
  assert_output "Ran in Python"
}

@test "dotty-install: Script with system file extension" {
  echo "echo \"Ran in bash\"" >| "$INSTALL_DIR/script.bash"
  chmod +x "$INSTALL_DIR/script.bash"

  run dotty-install
  assert_success
  assert_output "Ran in bash"
}

@test "dotty-install: Script with plugin file extension" {
  echo "" >| "$INSTALL_DIR/script.test"
  chmod +x "$INSTALL_DIR/script.test"

  run dotty-install
  assert_success
  assert_output "Called test install plugin"
}

@test "dotty-install: Directly run install file" {
  echo "echo \"Ran in bash\"" >| "$DOTTY_TEST_DIR/script.bash"
  chmod +x "$DOTTY_TEST_DIR/script.bash"

  run dotty-install "$DOTTY_TEST_DIR/script.bash"
  assert_success
  assert_output "Ran in bash"
}

@test "dotty-install: Fail on error" {
  echo "exit 1" >| "$INSTALL_DIR/script.bash"
  chmod +x "$INSTALL_DIR/script.bash"

  run dotty-install --fail
  assert_failure
}

@test "dotty-install: Continue on error" {
  echo "exit 1" >| "$INSTALL_DIR/script.bash"
  chmod +x "$INSTALL_DIR/script.bash"

  run dotty-install --continue
  assert_success
}
