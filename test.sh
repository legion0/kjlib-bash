#!/usr/bin/env bash

source kjlib_bash.sh || exit

kjlib::argparse::define_int name=a default=0
kjlib::argparse::define_int

kjlib::argparse::init "$@"

