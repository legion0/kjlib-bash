#!/usr/bin/env bash

source kjlib.sh || exit

kjlib::argparse::define_int a
kjlib::argparse::define_int --b
kjlib::argparse::define_int --c default=3
kjlib::argparse::define_int --d default=4

kjlib::argparse::init 10 --b=20 --c=30


[ "$(kjlib::argparse::get a)" == "10" ] || die "a != 10"
$(kjlib::argparse::explicit a) || die "a is explicit"

[ "$(kjlib::argparse::get b)" == "20" ] || die "b != 20"
$(kjlib::argparse::explicit b) || die "b is explicit"

[ "$(kjlib::argparse::get c)" == "30" ] || die "c != 30"
$(kjlib::argparse::explicit c) || die "c is explicit"

[ "$(kjlib::argparse::get d)" == "4" ] || die "d != 4"
! $(kjlib::argparse::explicit d) || die "d is not explicit"

echo "All Tests Pass !"
