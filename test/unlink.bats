#!/usr/bin/env bats

load 'test_helper/test_helper.bash'

@test "dotty-unlink: Simple unlinking" {
  # Create link first
  touch "${DOTTY_SOURCE_DIR}/test_link_source"
  echo "${DOTTY_TARGET_DIR}/test_link" >| "${DOTTY_TARGET_DIR}/.dotty-links"
  ln -s "${DOTTY_SOURCE_DIR}/test_link_source" "${DOTTY_TARGET_DIR}/test_link"
  assert_link_exist "${DOTTY_TARGET_DIR}/test_link"
  dotty-unlink
  assert_link_not_exist "${DOTTY_TARGET_DIR}/test_link"
  # Verify link file is deleted
  assert_not_exist "${DOTTY_TARGET_DIR}/.dotty-links"
}

@test "dotty-unlink: Unlinking only operates on known files" {
  touch "${DOTTY_SOURCE_DIR}/test_link_source"
  echo "${DOTTY_TARGET_DIR}/test_link" >| "${DOTTY_TARGET_DIR}/.dotty-links"
  ln -s "${DOTTY_SOURCE_DIR}/test_link_source" "${DOTTY_TARGET_DIR}/test_link"
  ln -s "${DOTTY_SOURCE_DIR}/test_link_source" "${DOTTY_TARGET_DIR}/test_link2"
  assert_link_exist "${DOTTY_TARGET_DIR}/test_link"
  assert_link_exist "${DOTTY_TARGET_DIR}/test_link2"
  dotty-unlink
  assert_link_not_exist "${DOTTY_TARGET_DIR}/test_link"
  assert_link_exist "${DOTTY_TARGET_DIR}/test_link2"
}

@test "dotty-unlink: Missing links are ignored" {
  echo "${DOTTY_TARGET_DIR}/test_link" >| "${DOTTY_TARGET_DIR}/.dotty-links"
  run dotty-unlink
  assert_success
  assert_output "Could not find ${DOTTY_TARGET_DIR}/test_link, skipping"
}

@test "dotty-unlink: Pruning behavior" {
  mkdir -p "${DOTTY_SOURCE_DIR}/test_dir" "${DOTTY_TARGET_DIR}/test_dir"
  touch "${DOTTY_SOURCE_DIR}/test_dir/test_link_source"
  echo "${DOTTY_TARGET_DIR}/test_dir/test_link" >| "${DOTTY_TARGET_DIR}/.dotty-links"
  ln -s "${DOTTY_SOURCE_DIR}/test_dir/test_link_source" "${DOTTY_TARGET_DIR}/test_dir/test_link"
  assert_link_exist "${DOTTY_TARGET_DIR}/test_dir/test_link"
  dotty-unlink
  assert_link_not_exist "${DOTTY_TARGET_DIR}/test_dir/test_link"
  assert_not_exist "${DOTTY_TARGET_DIR}/test_dir"

  mkdir -p "${DOTTY_SOURCE_DIR}/test_dir" "${DOTTY_TARGET_DIR}/test_dir"
  touch "${DOTTY_SOURCE_DIR}/test_dir/test_link_source"
  echo "${DOTTY_TARGET_DIR}/test_dir/test_link" >| "${DOTTY_TARGET_DIR}/.dotty-links"
  ln -s "${DOTTY_SOURCE_DIR}/test_dir/test_link_source" "${DOTTY_TARGET_DIR}/test_dir/test_link"
  assert_link_exist "${DOTTY_TARGET_DIR}/test_dir/test_link"
  dotty-unlink --no-prune
  assert_link_not_exist "${DOTTY_TARGET_DIR}/test_dir/test_link"
  assert_exist "${DOTTY_TARGET_DIR}/test_dir"
}
