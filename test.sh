#!/usr/bin/env bash

source kjlib_bash.sh || exit

kjlib::argparse::define_int name=c required=true

kjlib::argparse::define_int name=a default=5
kjlib::argparse::define_int name=b default=15

kjlib::argparse::init "$@"

echo ""
echo a=$(kjlib::argparse::get a)
echo b=$(kjlib::argparse::get b)
echo c=$(kjlib::argparse::get c)

