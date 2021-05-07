#!/usr/bin/env bats

load 'test_helper/test_helper.bash'

@test "dotty-list: List links" {
  echo "Link 1" >| "${DOTTY_TARGET_DIR}/.dotty-links"
  echo "Link 2" >> "${DOTTY_TARGET_DIR}/.dotty-links"
  run dotty-list links
  assert_success
  assert_output << EOF
Link 1
Link 2
EOF
}

@test "dotty-list: List modules" {
  mkdir -p "${DOTTY_SOURCE_DIR}/dir1" "${DOTTY_SOURCE_DIR}/dir 2"
  run dotty-list modules
  assert_success
  assert_output << EOF
dir1
dir 2
EOF
}

@test "dotty-list: List recipes" {
  echo "recipe_1=dir1" >| "$DOTTY_SOURCE_DIR/Dottyfile"
  echo "recipe space=dir1 dir2" >> "$DOTTY_SOURCE_DIR/Dottyfile"
  run dotty-list recipes
  assert_success
  assert_output << EOF
recipe space
recipe_1
EOF
}
