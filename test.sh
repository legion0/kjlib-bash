#!/usr/bin/env bash

source kjlib.sh || exit

kjlib::argparse::define_int a
kjlib::argparse::define_int --b
kjlib::argparse::define_int --c default=3
kjlib::argparse::define_int --d default=4

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

[ "$(kjlib::argparse::get b)" == "200" ] || exception "b != 20"
$(kjlib::argparse::explicit b) || exception "b is explicit"

[ "$(kjlib::argparse::get c)" == "30" ] || exception "c != 30"
$(kjlib::argparse::explicit c) || exception "c is explicit"


echo "All Tests Pass !"
