#!/usr/bin/env bash

. tests/helpers.sh

show_help() {
  cat <<EOF
USAGE:
        test_template [OPTIONS] -n <PROGRAM> ...<PROGRAM ARGUMENTS>

EXAMPLE:
        ./tests/test_template 'bin/mkfromtemplate' -n flexample -o 'out/' -t 'templates/flex.tmpl'

OPTIONS:
        -h, -?, --help          Display this help message.
        -n <PROJECT>            The project name.
        -o <OUT_DIR>            The output directory.
        -t <TEMPLATE>           The tempalte file to use.
EOF
}

while [[ $1 == -* ]]; do
  case "$1" in
  -h | --help | -\?)
    show_help
    exit 0
    ;;
  -n) if (($# > 1)); then
    project=$2
    shift 2
  else
    echo "-n requires an argument" 1>&2
    exit 1
  fi ;;
  -t) if (($# > 1)); then
    template_file=$2
    shift 2
  else
    echo "-t requires an argument" 1>&2
    exit 1
  fi ;;
  -o) if (($# > 1)); then
    out_dir=$2
    shift 2
  else
    echo "-o requires an argument" 1>&2
    exit 1
  fi ;;
  --)
    shift
    break
    ;;
  -*)
    echo "invalid option: $1" 1>&2
    show_help
    exit 1
    ;;
  esac
done

if (($# > 1)); then
  binary=$1
  shift 1
else
  binary=bin/mkfromtemplate
fi

debug() {
  echo -e "### DEGUB INFO ###"
  echo_info "template:" "$template_file"
  echo_info "output:" "$out_dir"
  echo_info "binário:" "$binary"
  echo_info "project name": "$project"
  echo_info "args:" "$@"
  echo -e "##################"
}

debug "$@"

./$binary -t "$template_file" "$project" "$out_dir" "$@"
