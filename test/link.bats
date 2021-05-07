#!/usr/bin/env bats

load 'test_helper/test_helper.bash'

@test "dotty-link: Simple linking" {
  mkdir -p "${DOTTY_SOURCE_DIR}/dir1"
  echo "Test Dotfile" >| "${DOTTY_SOURCE_DIR}/dir1/test_dot_file"
  run dotty-link dir1
  assert_success
  assert_symlink_to "${DOTTY_SOURCE_DIR}/dir1/test_dot_file" "${DOTTY_TARGET_DIR}/test_dot_file"
}

@test "dotty-link: Nested linking" {
  mkdir -p "${DOTTY_SOURCE_DIR}/dir1/nested_dir"
  echo "Test Dotfile" >| "${DOTTY_SOURCE_DIR}/dir1/nested_dir/test_dot_file"
  run dotty-link dir1
  assert_success
  assert_symlink_to "${DOTTY_SOURCE_DIR}/dir1/nested_dir/test_dot_file" "${DOTTY_TARGET_DIR}/nested_dir/test_dot_file"
}

@test "dotty-link: Missing target" {
  run dotty-link
  assert_failure
  assert_output "dotty: No targets given, no lock file present"
}

@test "dotty-link: Linking file with spaces" {
  mkdir -p "${DOTTY_SOURCE_DIR}/dir1"
  echo "Test Dotfile" >| "${DOTTY_SOURCE_DIR}/dir1/test dot file"
  run dotty-link dir1
  assert_success
  assert_symlink_to "${DOTTY_SOURCE_DIR}"/dir1/test\ dot\ file "${DOTTY_TARGET_DIR}"/test\ dot\ file
}

@test "dotty-link: Linking with actual dotfile" {
  mkdir -p "${DOTTY_SOURCE_DIR}/dir1"
  echo "Test Dotfile" >| "${DOTTY_SOURCE_DIR}/dir1/.test_dot_file"
  run dotty-link dir1
  assert_success
  assert_symlink_to "${DOTTY_SOURCE_DIR}/dir1/.test_dot_file" "${DOTTY_TARGET_DIR}/.test_dot_file"
}

@test "dotty-link: Linking with renaming" {
  mkdir -p "${DOTTY_SOURCE_DIR}/dir1/dot_dir"
  echo "Test Dotfile 1" >| "${DOTTY_SOURCE_DIR}/dir1/dot-test_1"
  echo "Test Dotfile 2" >| "${DOTTY_SOURCE_DIR}/dir1/dot_test_2"
  echo "Test Dotfile 3" >| "${DOTTY_SOURCE_DIR}/dir1/dot_dir/dot_test_3"
  run dotty-link dir1
  assert_success
  assert_symlink_to "${DOTTY_SOURCE_DIR}/dir1/dot-test_1" "${DOTTY_TARGET_DIR}/.test_1"
  assert_symlink_to "${DOTTY_SOURCE_DIR}/dir1/dot_test_2" "${DOTTY_TARGET_DIR}/.test_2"
  assert_symlink_to "${DOTTY_SOURCE_DIR}/dir1/dot_dir/dot_test_3" "${DOTTY_TARGET_DIR}/.dir/.test_3"
}

@test "dotty-link: Linking 2 modules" {
  mkdir -p "${DOTTY_SOURCE_DIR}/dir1" "${DOTTY_SOURCE_DIR}/dir2"
  echo "Test Dotfile 1" >| "${DOTTY_SOURCE_DIR}/dir1/test_dot_file_1"
  echo "Test Dotfile 2" >| "${DOTTY_SOURCE_DIR}/dir2/test_dot_file_2"
  run dotty-link dir1 dir2
  assert_success
  assert_symlink_to "${DOTTY_SOURCE_DIR}/dir1/test_dot_file_1" "${DOTTY_TARGET_DIR}/test_dot_file_1"
  assert_symlink_to "${DOTTY_SOURCE_DIR}/dir2/test_dot_file_2" "${DOTTY_TARGET_DIR}/test_dot_file_2"
}

@test "dotty-link: Call unlink for existing link file" {
  dotty-unlink () {
    echo "Called unlink"
  }
  export -f dotty-unlink
  mkdir -p "${DOTTY_SOURCE_DIR}/dir1"
  touch "${DOTTY_TARGET_DIR}/.dotty-links"
  run dotty-link dir1
  assert_success
  assert_output << EOF
Found existing links, unlinking first
Called unlink
EOF
}

@test "dotty-link: Correct link file" {
  mkdir -p "${DOTTY_SOURCE_DIR}/dir1" "${DOTTY_SOURCE_DIR}/dir2"
  echo "Test Dotfile 1" >| "${DOTTY_SOURCE_DIR}/dir1/test_dot_file_1"
  echo "Test Dotfile 2" >| "${DOTTY_SOURCE_DIR}/dir2/dot_file_2"
  run dotty-link dir1 dir2
  assert_success
  assert_file_not_empty "${DOTTY_TARGET_DIR}/.dotty-links"
  diff "${DOTTY_TARGET_DIR}/.dotty-links" - << EOF
${DOTTY_TARGET_DIR}/test_dot_file_1
${DOTTY_TARGET_DIR}/.file_2
EOF
}

@test "dotty-link: Correct lock file" {
  mkdir -p "${DOTTY_SOURCE_DIR}/dir1" "${DOTTY_SOURCE_DIR}/dir2"
  dotty-link dir1 dir2
  assert_file_not_empty "${DOTTY_TARGET_DIR}/.dotty-lock"
  diff "${DOTTY_TARGET_DIR}/.dotty-lock" - << EOF
dir1
dir2
EOF
  # Test that recalling link with an existing lock-file does work
  dotty-link
}

@test "dotty-link: Abort on existing file" {
  mkdir -p "${DOTTY_SOURCE_DIR}/dir1" "${DOTTY_SOURCE_DIR}/dir2"
  echo "Test Dotfile 1" >| "${DOTTY_SOURCE_DIR}/dir1/test_dot_file_1"
  echo "Test Dotfile 2" >| "${DOTTY_SOURCE_DIR}/dir2/dot_file_2"
  touch "${DOTTY_TARGET_DIR}/.file_2"
  run dotty-link dir1 dir2
  # Command should fail
  assert_failure
  assert_output --partial "is already existing, specify '--overwrite' or remove file"
  # First link should still be present
  assert_symlink_to "${DOTTY_SOURCE_DIR}/dir1/test_dot_file_1" "${DOTTY_TARGET_DIR}/test_dot_file_1"
  diff "${DOTTY_TARGET_DIR}/.dotty-links" - << EOF
${DOTTY_TARGET_DIR}/test_dot_file_1
EOF
  assert_not_symlink_to "${DOTTY_SOURCE_DIR}/dir2/dot_file_2" "${DOTTY_TARGET_DIR}/.file_2"
}

@test "dotty-link: Overwrite on existing file" {
  mkdir -p "${DOTTY_SOURCE_DIR}/dir1" "${DOTTY_SOURCE_DIR}/dir2"
  echo "Test Dotfile 1" >| "${DOTTY_SOURCE_DIR}/dir1/test_dot_file_1"
  echo "Test Dotfile 2" >| "${DOTTY_SOURCE_DIR}/dir2/dot_file_2"
  touch "${DOTTY_TARGET_DIR}/.file_2"
  dotty-link --overwrite dir1 dir2
  # TODO: Test that existing file is backed up
  assert_symlink_to "${DOTTY_SOURCE_DIR}/dir1/test_dot_file_1" "${DOTTY_TARGET_DIR}/test_dot_file_1"
  assert_symlink_to "${DOTTY_SOURCE_DIR}/dir2/dot_file_2" "${DOTTY_TARGET_DIR}/.file_2"
}
