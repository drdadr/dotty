#!/usr/bin/env bats

load 'test_helper/test_helper.bash'

setup() {
  shared_setup
  mkdir -p "${DOTTY_SOURCE_DIR}/dir1" "${DOTTY_SOURCE_DIR}/dir2" "${DOTTY_SOURCE_DIR}/dir3"
}

@test "dotty-targets: Single target" {
  # Test result can be used to declare an array
  declare -a "test_targets=$(dotty-targets dir1)"
  assert [ ${#test_targets[@]} == 1 ]
  assert [ "${test_targets[0]}" == "dir1" ]
}

@test "dotty-targets: Multiple modules" {
  # Test result can be used to declare an array
  declare -a "test_targets=$(dotty-targets dir1 dir2 dir3)"
  assert [ ${#test_targets[@]} == 3 ]
  assert [ "${test_targets[0]}" == "dir1" ]
  assert [ "${test_targets[1]}" == "dir2" ]
  assert [ "${test_targets[2]}" == "dir3" ]
}

@test "dotty-targets: Simple recipe and module" {
  echo "recipe_1=dir1" >| "$DOTTY_SOURCE_DIR/Dottyfile"
  # Test result can be used to declare an array
  declare -a "test_targets=$(dotty-targets recipe_1 dir2)"
  assert [ ${#test_targets[@]} == 2 ]
  assert [ "${test_targets[0]}" == "dir1" ]
  assert [ "${test_targets[1]}" == "dir2" ]
}

@test "dotty-targets: Recipe that calls another recipe" {
  echo "recipe_1=recipe_2 dir1" >| "$DOTTY_SOURCE_DIR/Dottyfile"
  echo "recipe_2=dir2" >> "$DOTTY_SOURCE_DIR/Dottyfile"
  # Test result can be used to declare an array
  declare -a "test_targets=$(dotty-targets dir1 dir2)"
  assert [ ${#test_targets[@]} == 2 ]
  assert [ "${test_targets[0]}" == "dir1" ]
  assert [ "${test_targets[1]}" == "dir2" ]
}

@test "dotty-targets: Recipes with circular dependency" {
  echo "recipe_1=recipe_2 dir1" >| "$DOTTY_SOURCE_DIR/Dottyfile"
  echo "recipe_2=recipe_1 dir3" >> "$DOTTY_SOURCE_DIR/Dottyfile"
  # Test result can be used to declare an array
  declare -a "test_targets=$(dotty-targets recipe_1 recipe_2)"
  assert [ ${#test_targets[@]} == 2 ]
  assert [ "${test_targets[0]}" == "dir1" ]
  assert [ "${test_targets[1]}" == "dir3" ]
}
