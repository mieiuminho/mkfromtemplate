#!/usr/bin/env bash

# shellcheck source=scripts/helpers.sh
. scripts/helpers.sh

show_help() {
  cat <<EOF
USAGE:
        test_template [OPTIONS] <PROGRAM>

EXAMPLE:
        ./tests/test_template -t 'templates/flex.tmpl' -o 'out/flexamples/' flexample

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
  -t)
    if (($# > 1)); then
      template_file=$2
      shift 2
    else
      echo "-t requires an argument" 1>&2
      exit 1
    fi
    ;;
  -o)
    if (($# > 1)); then
      output_dir=$2
      shift 2
    else
      echo "-o requires an argument" 1>&2
      exit 1
    fi
    ;;
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

project=$1

rm -rf "$output_dir"

./bin/mkfromtemplate -o "$output_dir" -t "$template_file" "$project"

expected_output_tree="$(dirname $0)/$(basename $template_file).tree"
expected_output_blob="$(dirname $0)/$(basename $template_file).blob"

if test "$(tree $output_dir | tail -n +2)" = "$(cat $expected_output_tree)" && test "$(find $output_dir -type f | xargs cat -v)" = "$(cat -v $expected_output_blob)"; then
  echo_done "Test for template ${template_file} passed"
else
  echo_error "Test for template ${template_file} failed"
  diff <(tree $output_dir | tail -n +2) <(cat $expected_output_tree) --color=always
  diff <(find $output_dir -type f | xargs cat -v) <(cat -v $expected_output_blob) --color=always
fi
