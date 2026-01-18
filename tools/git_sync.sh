#!/usr/bin/env bash
set -e

echo "Fetching from private..."
git fetch private

echo "Fetching from public..."
git fetch public

echo "Sync complete."
