#!/usr/bin/env bats

load 'test_helper/test_helper.bash'

@test "dotty-recipes: Simple recipe with one target" {
  echo "recipe_1=dir1" >| "$DOTTY_SOURCE_DIR/Dottyfile"
  output=$(dotty-recipes)
  # Test result can be used to declare an associative array
  declare -A "test_recipes=$(dotty-recipes)"
  assert [ ${#test_recipes[@]} == 1 ]
  # Test stored string can be used to declare an array
  declare -a "recipe_targets=${test_recipes[recipe_1]}"
  assert [ ${#recipe_targets[@]} == 1 ]
  assert [ "${recipe_targets[0]}" == "dir1" ]
}

@test "dotty-recipes: Recipe with multiple targets" {
  echo "recipe_2=dir1 dir2" >| "$DOTTY_SOURCE_DIR/Dottyfile"
  output=$(dotty-recipes)
  # Test result can be used to declare an associative array
  declare -A "test_recipes=$(dotty-recipes)"
  assert [ ${#test_recipes[@]} == 1 ]
  # Test stored string can be used to declare an array
  declare -a "recipe_targets=${test_recipes[recipe_2]}"
  assert [ ${#recipe_targets[@]} == 2 ]
  assert [ "${recipe_targets[0]}" == "dir1" ]
  assert [ "${recipe_targets[1]}" == "dir2" ]
}

@test "dotty-recipes: Recipe target directory with space" {
  echo "recipe_3=dir1 \"dir with space\"" >| "$DOTTY_SOURCE_DIR/Dottyfile"
  output=$(dotty-recipes)
  # Test result can be used to declare an associative array
  declare -A "test_recipes=$(dotty-recipes)"
  assert [ ${#test_recipes[@]} == 1 ]
  # Test stored string can be used to declare an array
  declare -a "recipe_targets=${test_recipes[recipe_3]}"
  assert [ ${#recipe_targets[@]} == 2 ]
  assert [ "${recipe_targets[0]}" == "dir1" ]
  assert [ "${recipe_targets[1]}" == "dir with space" ]
}

@test "dotty-recipes: Recipe with space" {
  echo "recipe space=dir1" >| "$DOTTY_SOURCE_DIR/Dottyfile"
  output=$(dotty-recipes)
  # Test result can be used to declare an associative array
  declare -A "test_recipes=$(dotty-recipes)"
  assert [ ${#test_recipes[@]} == 1 ]
  # Test stored string can be used to declare an array
  declare -a "recipe_targets=${test_recipes["recipe space"]}"
  assert [ ${#recipe_targets[@]} == 1 ]
  assert [ "${recipe_targets[0]}" == "dir1" ]
}

@test "dotty-recipes: Multiple recipes" {
  echo "recipe_1=dir1" >| "$DOTTY_SOURCE_DIR/Dottyfile"
  echo "recipe_2=dir1 dir2" >> "$DOTTY_SOURCE_DIR/Dottyfile"
  output=$(dotty-recipes)
  # Test result can be used to declare an associative array
  declare -A "test_recipes=$(dotty-recipes)"
  assert [ ${#test_recipes[@]} == 2 ]
  # Test stored string can be used to declare an array
  declare -a "recipe1_targets=${test_recipes[recipe_1]}"
  assert [ ${#recipe1_targets[@]} == 1 ]
  assert [ "${recipe1_targets[0]}" == "dir1" ]
  declare -a "recipe2_targets=${test_recipes[recipe_2]}"
  assert [ ${#recipe2_targets[@]} == 2 ]
  assert [ "${recipe2_targets[0]}" == "dir1" ]
  assert [ "${recipe2_targets[1]}" == "dir2" ]
}

@test "dotty-recipes: Recipe with leading and trailing whitespace" {
  echo " recipe_1 = dir1  " >| "$DOTTY_SOURCE_DIR/Dottyfile"
  output=$(dotty-recipes)
  # Test result can be used to declare an associative array
  declare -A "test_recipes=$(dotty-recipes)"
  assert [ ${#test_recipes[@]} == 1 ]
  # Test stored string can be used to declare an array
  declare -a "recipe_targets=${test_recipes[recipe_1]}"
  assert [ ${#recipe_targets[@]} == 1 ]
  assert [ "${recipe_targets[0]}" == "dir1" ]
}

@test "dotty-recipes: Recipe with comments and blank lines" {
  echo "# This is a header comment"      >| "$DOTTY_SOURCE_DIR/Dottyfile"
  echo "  # Comment with space in front" >> "$DOTTY_SOURCE_DIR/Dottyfile"
  echo "     "                           >> "$DOTTY_SOURCE_DIR/Dottyfile"
  echo ""                                >> "$DOTTY_SOURCE_DIR/Dottyfile"
  echo "recipe_1=dir1 # Inline comment"  >> "$DOTTY_SOURCE_DIR/Dottyfile"
  echo "# Finishing commenting"          >> "$DOTTY_SOURCE_DIR/Dottyfile"
  output=$(dotty-recipes)
  # Test result can be used to declare an associative array
  declare -A "test_recipes=$(dotty-recipes)"
  assert [ ${#test_recipes[@]} == 1 ]
  # Test stored string can be used to declare an array
  declare -a "recipe_targets=${test_recipes[recipe_1]}"
  assert [ ${#recipe_targets[@]} == 1 ]
  assert [ "${recipe_targets[0]}" == "dir1" ]
}
