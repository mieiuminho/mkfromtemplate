#!/usr/bin/env bash

# shellcheck source=scripts/helpers.sh
. scripts/helpers.sh

hyperfine --warmup 5 \
  --runs 20 \
  --prepare "rm -rf out/bench_java" \
  "rm -rf out/bench_java; ./bin/mkfromtemplate -o out/bench_java -c tests/config.ini -t tests/bench.tmpl benchjava"
