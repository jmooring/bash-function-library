#!/usr/bin/env bash

#------------------------------------------------------------------------------
# @file
# Defines function: bfl::path_prepend().
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# @function
# Searches path in the variable like PATH. If not found, add directory path to the beginning of string
# This help to exclude duplicates
#
# Standart Linux path functions. The string ONLY single line
#
# @param string $directory
#   The directory to be searching and remove.
#
# @param string $path_variable (optional)
#   The variable to be changed. By default, PATH
#
# @example
#   bfl::path_prepend '/usr/local/lib' LD_LIBRARY_PATH
#------------------------------------------------------------------------------
bfl::path_prepend() {
# Original:
#  pathremove $1 $2
#  export $PATHVARIABLE="$1${!PATHVARIABLE:+:${!PATHVARIABLE}}"
  [[ -z "$1" ]] && return 1
  local s
  s=`bfl::trimLR "$1" ':' ' '`

  local PATHVARIABLE=${2:-PATH}
  local str="${!PATHVARIABLE}"  # значение переменной по ее имени

  # если переменная даже не объявлена
  [[ -z "$str" ]] && export $PATHVARIABLE="$s" && return 0
  # если нет необходимости что-то менять
  [[ "$str" == "$s" ]] && return 0

  local b=false
  if [[ "$s" =~ ':' ]]; then
    local d arr
    arr=()
    IFS=$':' read -r -a arr <<< "$str"

    s=":$s:"
    for d in ${arr[@]}; do
      s=`echo "$s" | sed "s|:$d:|:|g"`
    done
    unset IFS
    [[ "$s" == ':' ]] && s=''
    [[ -n "$s" ]] && s="${s:1:-1}"
  else
    b=`bfl::_is_directory_in_PATH "$s" "$str"`
    $b && return 0  # нет необходимости что-то менять
  fi

  if [[ -n "$s" ]]; then
    str=`bfl::_fix_PATH_colons "$str"`
    export $PATHVARIABLE="$s:$str"
  fi

  return 0
  }