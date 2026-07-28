#!/bin/bash

BAL_EXAMPLES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BAL_CENTRAL_DIR="$HOME/.ballerina/repositories/central.ballerina.io"
BAL_HOME_DIR="$BAL_EXAMPLES_DIR/../ballerina"

set -e

case "$1" in
build)
  BAL_CMD="build"
  ;;
run)
  BAL_CMD="run"
  ;;
*)
  echo "Invalid command provided: '$1'. Please provide 'build' or 'run' as the command."
  exit 1
  ;;
esac

# Read Ballerina package name
BAL_PACKAGE_NAME=$(awk -F'"' '/^name/ {print $2}' "$BAL_HOME_DIR/Ballerina.toml")

# Push the package to the local repository
cd "$BAL_HOME_DIR" &&
  bal pack &&
  bal push --repository=local

# Remove the cache directories in the repositories
for dir in "$BAL_CENTRAL_DIR"/cache-*; do
  [ -d "$dir" ] && rm -r "$dir"
done
echo "Successfully cleaned the cache directories"

# Create the package directory in the central repository, this will not be present if no modules are pulled
mkdir -p "$BAL_CENTRAL_DIR/bala/ballerinax/$BAL_PACKAGE_NAME"

# Update the central repository
BAL_DESTINATION_DIR="$HOME/.ballerina/repositories/central.ballerina.io/bala/ballerinax/$BAL_PACKAGE_NAME"
BAL_SOURCE_DIR="$HOME/.ballerina/repositories/local/bala/ballerinax/$BAL_PACKAGE_NAME"
[ -d "$BAL_DESTINATION_DIR" ] && rm -r "$BAL_DESTINATION_DIR"
[ -d "$BAL_SOURCE_DIR" ] && cp -r "$BAL_SOURCE_DIR" "$BAL_DESTINATION_DIR"
echo "Successfully updated the local central repositories"

# Loop through examples in the examples directory
cd "$BAL_EXAMPLES_DIR"
while IFS= read -r -d '' dir; do
  # Skip the build directory
  if [[ "$dir" == *build ]]; then
    continue
  fi
  (cd "$dir" && bal "$BAL_CMD" --offline && cd ..);
done < <(find "$BAL_EXAMPLES_DIR" -type d -maxdepth 1 -mindepth 1 -print0)

# Remove generated JAR files
while IFS= read -r -d '' JAR_FILE; do
  rm "$JAR_FILE"
done < <(find "$BAL_HOME_DIR" -maxdepth 1 -type f -name "*.jar" -print0)
