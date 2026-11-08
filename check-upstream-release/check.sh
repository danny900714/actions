#!/usr/bin/env bash

version_ge() {
  [ "$(printf "%s\n" "$1" "$2" | sort -V | head -n 1)" = "$2" ]
}

version_gt() {
  [ "$1" != "$2" ] && version_ge "$1" "$2"
}

check() {
  # Get the latest release version of the upstream repository
  # If the command fails, exit with the command status
  if upstream_version=$(gh release view -R "$UPSTREAM_REPOSITORY" --json tagName -q .tagName); then
    echo "Upstream latest release tag: $upstream_version"
  else
    code=$?
    echo "::error::Failed to get the latest release's tag name of the upstream repository"
    exit $code
  fi
  upstream_triplet=$(grep -oE "$SEMVER_VERSION_CORE_REGEX" <<< "$upstream_version")
  echo "::debug::upstream_triplet=$upstream_triplet"

  # Get the latest release version of the current repository
  # Based on the value of IF_CURRENT_RELEASE_NOT_FOUND, there are different behaviors if the command fails:
  #   "lowest-version": set the current_version to "0.0.0"
  #   "error": exit with status code 1
  if current_version=$(gh release view -R "$CURRENT_REPOSITORY" --json tagName -q .tagName); then
    echo "Current latest release tag: $current_version"
  elif [[ $IF_CURRENT_RELEASE_NOT_FOUND = "error" ]]; then
    echo "::error::Failed to get the latest release's tag name of the current repository"
    exit 1
  elif [[ $IF_CURRENT_RELEASE_NOT_FOUND = "lowest-version" ]]; then
    current_version="0.0.0"
  else
    echo "::error::Unsupported if-current-release-not-found value: $IF_CURRENT_RELEASE_NOT_FOUND"
    exit 1
  fi
  current_triplet=$(grep -oE "$SEMVER_VERSION_CORE_REGEX" <<< "$current_version")
  echo "::debug::current_triplet=$current_triplet"

  if version_gt "$upstream_triplet" "$current_triplet"; then
    echo "new-upstream-version=${upstream_version}" >> "$GITHUB_OUTPUT"
    echo "## There's a new release in the upstream repository" >> "$GITHUB_STEP_SUMMARY"
  else
    echo "## The current version is in sync with the upstream" >> "$GITHUB_STEP_SUMMARY"
  fi

  {
    echo "| Repository | Latest release |"
    echo "| --- | --- |"
    echo "| Upstream | $upstream_version |"
    echo "| Current | $current_version |"
  } >> "$GITHUB_STEP_SUMMARY"
}

check
