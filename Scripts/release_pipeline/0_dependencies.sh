#!/bin/zsh

# Fetch external dependencies
echo "🗃 Resolving dependencies"
tuist fetch
tuist generate -n
