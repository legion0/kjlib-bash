#!/usr/bin/env bash

source kjlib.sh || exit

kjlib::argparse::define_int a help="Help A"
kjlib::argparse::define_int --b help="Help B"
kjlib::argparse::define_int --c default=3 help="Help C"
kjlib::argparse::define_int --d default=4 help="Help D"

kjlib::argparse::help

kjlib::argparse::init 10 --b=20 --c=30

[ "$(kjlib::argparse::get a)" == "10" ] || exception "a != 10"
$(kjlib::argparse::explicit a) || exception "a is explicit"

[ "$(kjlib::argparse::get b)" == "20" ] || exception "b != 20"
$(kjlib::argparse::explicit b) || exception "b is explicit"

[ "$(kjlib::argparse::get c)" == "30" ] || exception "c != 30"
$(kjlib::argparse::explicit c) || exception "c is explicit"

[ "$(kjlib::argparse::get d)" == "4" ] || exception "d != 4"
! $(kjlib::argparse::explicit d) || exception "d is not explicit"


kjlib::argparse::init 10 --b 20 --c 30

[ "$(kjlib::argparse::get b)" == "20" ] || exception "b != 20"
$(kjlib::argparse::explicit b) || exception "b is explicit"

[ "$(kjlib::argparse::get c)" == "30" ] || exception "c != 30"
$(kjlib::argparse::explicit c) || exception "c is explicit"


echo "All Tests Pass !"
