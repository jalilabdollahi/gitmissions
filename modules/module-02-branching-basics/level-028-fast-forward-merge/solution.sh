#!/usr/bin/env bash
set -e
git log --oneline --graph --all
git merge --ff-only add-lunch-ideas
