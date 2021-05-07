#!/usr/bin/env bats

load 'test_helper/test_helper.bash'

setup() {
  shared_setup
  export GIT_DIR="${DOTTY_TEST_DIR}/.git"
  git config --global user.name  "Tester"
  git config --global user.email "tester@test.local"
  cd "$DOTTY_TEST_DIR"
}

teardown() {
  # Due to permission errors, the .git folder blocks temp_del
  rm -rf "$GIT_DIR"
  temp_del "$DOTTY_TEST_DIR"
}

git_commit() {
  git commit --quiet --allow-empty -m "empty"
}

@test "dotty-version: Default version" {
  run dotty---version
  assert_success
  assert_output --regexp '^dotty [0-9]+\.[0-9]+\.[0-9]$'
}

@test "dotty-version: Doesn't read version from non-dotty repo" {
  git init
  git remote add origin https://github.com/homebrew/homebrew.git
  git_commit
  git tag v1.0

  run dotty---version
  assert_success
  assert_output --regexp '^dotty [0-9]+\.[0-9]+\.[0-9]$'
}

@test "dotty-version: Reads version from git repo" {
  git init
  git remote add origin https://github.com/drdadr/dotty.git
  git_commit
  git tag v0.4.1
  git_commit
  git_commit

  run dotty---version
  assert_success
  assert_output 'dotty 0.4.1-2-g'$(git rev-parse --short HEAD)
}

@test "dotty-version: Prints default version if no tags in git repo" {
  git init
  git remote add origin https://github.com/drdadr/dotty.git
  git_commit

  run dotty---version
  assert_output --regexp '^dotty [0-9]+\.[0-9]+\.[0-9]$'
}
