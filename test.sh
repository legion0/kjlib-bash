#!/usr/bin/env bash

source kjlib_bash.sh || exit

kjlib::argparse::define_int a
kjlib::argparse::define_int --b
kjlib::argparse::define_int --c default=3
kjlib::argparse::define_int --d default=4

kjlib::argparse::init 10 --b=20 --c=30


[ "$(kjlib::argparse::get a)" == "10" ] || _die "a != 10"
$(kjlib::argparse::explicit a) || _die "a is explicit"

[ "$(kjlib::argparse::get b)" == "20" ] || _die "b != 20"
$(kjlib::argparse::explicit b) || _die "b is explicit"

[ "$(kjlib::argparse::get c)" == "30" ] || _die "c != 30"
$(kjlib::argparse::explicit c) || _die "c is explicit"

[ "$(kjlib::argparse::get d)" == "4" ] || _die "d != 4"
! $(kjlib::argparse::explicit d) || _die "d is not explicit"

