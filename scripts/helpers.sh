#!/bin/bash

function echo_error() {
  printf '\n\033[31mERROR:\033[0m %s\n' "$1"
  echo "$@"
}

function echo_warning() {
  printf '\n\033[33mWARNING:\033[0m %s\n' "$1"
  echo "$@"
}

function echo_done() {
  printf '\n\033[32mDONE:\033[0m %s\n' "$1"
  echo "$@"
}

function echo_info() {
  printf '\033[36m%s\033[0m ' "$1"
  shift 1
  echo "$@"
}
