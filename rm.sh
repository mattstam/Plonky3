#!/bin/bash

# Function to remove dev-dependencies from Cargo.toml files
remove_dev_dependencies() {
  find . -name "Cargo.toml" | while read -r file; do
    echo "Removing dev-dependencies from $file"
    # Use awk to remove the [dev-dependencies] section
    awk '/\[dev-dependencies\]/{flag=1; next} /\[/{flag=0} !flag' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
  done
}

# Function to restore dev-dependencies from backup files
restore_dev_dependencies() {
  find . -name "Cargo.toml.bak" | while read -r file; do
    original_file="${file%.bak}"
    echo "Restoring dev-dependencies to $original_file"
    mv "$file" "$original_file"
  done
}

# Backup and remove dev-dependencies
find . -name "Cargo.toml" | while read -r file; do cp "$file" "$file.bak"; done
remove_dev_dependencies

# Compile and publish the crates
cargo build --release
# cargo publish
cargo publish-workspace --target-version 0.0.0 --token $CARGO_REGISTRY_TOKEN --crate-prefix '' -- --allow-dirty

# Restore dev-dependencies
restore_dev_dependencies
