#!/usr/bin/env bash

[[ -z $(echo "$BASH_SOURCE" | sed -n '/bash-function-library/p') ]] && return 0 || _bfl_temporary_var=$(echo "$BASH_SOURCE" | sed 's|^.*/lib/\([^/]*\)/\([^/]*\)\.sh$|_GUARD_BFL_\1\2|')
[[ ${!_bfl_temporary_var} -eq 1 ]] && return 0 || readonly $_bfl_temporary_var=1
#------------------------------------------------------------------------------
# ------------ https://github.com/Jarodiv/bash-function-libraries -------------
#
# Library of functions related to the build tool Apache Maven
#
# @author  Michael Strache
#
# @file
# Defines function: bfl::update_maven_project_dependency_version().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Update the version of a dependency in the a pom.xml.
# See: http://stackoverflow.com/questions/34957616/is-it-possible-to-use-sed-to-replace-dependenciess-version-in-a-pom-file
#
# @param string $POM
#   pom.xml file to search in.
#
# @param string $GROUP_ID
#   Group-id of the dependency.
#
# @param string $ARTIFACT_ID
#   Artifact-id of the dependency.
#
# @param string $NEW_VERSION
#   Version to be set.
#
# @example
#   bfl::update_maven_project_dependency_version ....
#------------------------------------------------------------------------------
#
bfl::update_maven_project_dependency_version() {
  bfl::verify_arg_count "$#" 3 3 || exit 1  # Verify argument count.

  local -r POM="${1:-}"
  local -r GROUP_ID="${2:-}"
  local -r ARTIFACT_ID="${3:-}"
  local -r NEW_VERSION="${4:-}"

  # if the version is not found, we better should not try to replace it
  bfl::get_maven_project_dependency_version "$POM" "$GROUP_ID" "$ARTIFACT_ID" || return 1

  sed -i'' -e '/<dependency>/ {
      :start
      N
      /<\/dependency>$/!b start
      /<artifactId>'"$ARTIFACT_ID"'<\/artifactId>/ {
          s/\(<version>\).*\(<\/version>\)/\1'"$NEW_VERSION"'\2/
      }
  }' "$POM" > "$LOG_FILE" 2>&1
  }