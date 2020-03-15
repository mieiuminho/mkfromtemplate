#!/usr/bin/env bash

. tests/helpers.sh

show_help() {
  cat <<EOF
USAGE:
        test_template [OPTIONS] <PROGRAM>

EXAMPLE:
        ./tests/test_template -t 'templates/flex.tmpl' flexample

OPTIONS:
        -h, --help              Display this help message.
        -o <OUT_DIR>            The output directory.
        -t <TEMPLATE>           The tempalte file to use.
EOF
}

while [[ $1 == -* ]]; do
  case "$1" in
  -h | --help)
    show_help
    exit 0
    ;;
  -t) if (($# > 1)); then
    template_file=$2
    shift 2
  else
    echo "-t requires an argument" 1>&2
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

project=$@

./bin/mkfromtemplate -t "$template_file" "$project"
