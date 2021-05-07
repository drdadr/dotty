load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'
load 'test_helper/bats-file/load'

unset DOTTY_TARGET_DIR
unset DOTTY_SOURCE_DIR

setup() {
  shared_setup
}

teardown() {
  temp_del "$DOTTY_TEST_DIR"
}


shared_setup() {
  # echo "# Run shared setup" >&3
  # Clean up dotty env variables
  unset DOTTY_TARGET_DIR
  unset DOTTY_SOURCE_DIR

  # Create temporary testing directory
  DOTTY_TEST_DIR="$(temp_make)"
  export HOME="${DOTTY_TEST_DIR}/home"
  mkdir -p "$HOME"

  # Set Dotty env variables
  export DOTTY_TARGET_DIR="$HOME"
  export DOTTY_SOURCE_DIR="$DOTTY_TEST_DIR/dotfiles"
  mkdir -p "$DOTTY_SOURCE_DIR"

  # Clean up PATH
  local bats_dir="$(realpath $(dirname $(which bats)))"
  PATH="${bats_dir}:usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

  PATH="${DOTTY_TEST_DIR}/bin:$PATH"
  PATH="${BATS_TEST_DIRNAME}/../libexec:$PATH"
  PATH="${BATS_TEST_DIRNAME}/libexec:$PATH"
  export PATH
}

# Helper function to abort execution in case of errors
abort() {
  { if [ "$#" -eq 0 ]; then cat -
    else echo "dotty: $*"
    fi
  } >&2
  exit 1
}
export -f abort
