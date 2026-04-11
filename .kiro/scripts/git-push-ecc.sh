#!/bin/bash
set -e

echo "=== Step 1: Check git status ==="
git status

echo "=== Step 2: Check remote ==="
git remote -v

echo "=== Step 3: Check if repo is initialized ==="
git rev-parse --is-inside-work-tree

echo "=== Step 4: Check existing branches ==="
git branch -a
