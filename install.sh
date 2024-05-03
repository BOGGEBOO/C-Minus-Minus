#!/bin/bash

# Function to check if alias exists in shell config file
exists() {
    local config_file="$1"
    grep -q "^cmm(){" "$config_file"
}

# Get the basename of the shell executable
shell_basename=$(basename "$SHELL")

# Check if the user is using Bash
if [ "$shell_basename" = "bash" ]; then
    echo "Adding alias to .bashrc..."
    if ! exists ~/.bashrc; then
        echo "cmm(){" >> ~/.bashrc
        echo "    ruby ~/Desktop/tdp019/cmm.rb \$1" >> ~/.bashrc
        echo "}" >> ~/.bashrc
        echo 'Alias added to "~/.bashrc". Please restart your terminal'
    else
        echo "'CMM' already exists on you machine. Skipping..."
    fi
# Check if the user is using Zsh
elif [ "$shell_basename" = "zsh" ]; then
    echo "Adding alias to .zshrc..."
    if ! exists ~/.zshrc; then
        echo "cmm(){" >> ~/.zshrc
        echo "    ruby ~/Desktop/tdp019/cmm.rb \$1" >> ~/.zshrc
        echo "}" >> ~/.zshrc
        echo 'Alias added to "~/.zshrc". Please restart your terminal'
    else
        echo "'CMM' already exists on your machine. Skipping..."
    fi
else
    echo "Unsupported shell. Please add the alias manually."
fi
