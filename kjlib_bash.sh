kjlib_argparse__names=()
kjlib_argparse__defaults=()
kjlib_argparse__types=()
kjlib_argparse__values=()
kjlib_argparse__idx=-1

function echo_arr() {
	local n=$1
	local a=""
	local s=0
	eval "a=(\"\${${1}[@]}\")"
	eval "s=(\"\${#${1}[@]}\")"
	echo "$n ($s): ${a[@]}"
}
function echo_var() {
	local n=$1
	local v=""
	eval "v=\${$1}"
	echo "$n=$v"
}

function kjlib::argparse::define_int() {
	echo "$FUNCNAME: $# { $@ }"
	((kjlib_argparse__idx++))
	kjlib_argparse__types[$kjlib_argparse__idx]="int"
	while [ $# -ne 0 ]; do
		local arg="$1"; shift
		arg=(${arg//=/ })
		case ${arg[0]} in
			name)
				kjlib_argparse__names[$kjlib_argparse__idx]=${arg[1]}
			;;
			default)
				kjlib_argparse__defaults[$kjlib_argparse__idx]=${arg[1]}
			;;
			*)
				echo "OTHER ${arg[0]} = ${arg[1]} !!!"
			;;
		esac
	done
	echo_var kjlib_argparse__idx
	echo_arr kjlib_argparse__names
	echo_arr kjlib_argparse__defaults
	echo_arr kjlib_argparse__types
	echo ""
}

function kjlib::argparse::init() {
	echo "$FUNCNAME: $# { $@ }"

	local orig_argv=($@)
	local orig_argc=$#
	# Slice extra args
	local slice_start=$orig_argc
	for ((i=0; i < $orig_argc; i++)); do
		if [ "${orig_argv[${i}]}" == "--" ]; then
			slice_start=$i
			break
		fi
	done
	((slice_start++))
	local slice_size=$(($orig_argc - $slice_start))
	echo_var slice_start
	echo_var slice_size
	extra_args=("${orig_argv[@]:$slice_start:$slice_size}")
	echo_arr extra_args
	return 0

	# extract all named args
	for idx in $(seq 0 $kjlib_argparse__idx); do
		local name="${kjlib_argparse__names[$idx]}"
		echo_var name
		if [ "$name" != "" ]; then
			local default="${kjlib_argparse__defaults[$idx]}"
			local type_="${kjlib_argparse__types[$idx]}"
			echo_var default
			echo_var type_
			for arg_idx in "$(seq 0 $#)"; do
				echo "$arg_idx"
				continue
				[ "$arg" == "--" ] && break
				echo_var arg
				arg=(${arg//=/ })
				if [ "${arg[0]}" == $name ]; then
					kjlib_argparse__values[$idx]="${arg[1]}"
					found=true
					break
				fi
			done
		fi
	done
	echo_arr kjlib_argparse__values
}
