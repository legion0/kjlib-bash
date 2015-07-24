kjlib_argparse__names=()
kjlib_argparse__required=()
kjlib_argparse__defaults=()
kjlib_argparse__types=()
kjlib_argparse__values=()
kjlib_argparse__explicit=()
kjlib_argparse__size=0
kjlib_argparse__passthrough=()

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
	kjlib_argparse__types[$kjlib_argparse__size]="int"
	while [ $# -ne 0 ]; do
		local arg="$1"; shift
		arg=(${arg//=/ })
		case ${arg[0]} in
			name)
				kjlib_argparse__names[$kjlib_argparse__size]=${arg[1]}
			;;
			default)
				kjlib_argparse__defaults[$kjlib_argparse__size]=${arg[1]}
			;;
			required)
				kjlib_argparse__required[$kjlib_argparse__size]=${arg[1]}
			;;
			*)
				echo "OTHER ${arg[0]} = ${arg[1]} !!!"
			;;
		esac
	done
	((kjlib_argparse__size++))
	echo_var kjlib_argparse__size
	echo_arr kjlib_argparse__names
	echo_arr kjlib_argparse__required
	echo_arr kjlib_argparse__defaults
	echo_arr kjlib_argparse__types
	echo ""
}

function _bool() {
	[ "$1" == "true" ] && return 0|| return 1
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
#	echo_var slice_start
#	echo_var slice_size
	kjlib_argparse__passthrough=("${orig_argv[@]:$slice_start:$slice_size}")
	echo_arr kjlib_argparse__passthrough
	((slice_start--))
	local new_argv=("${orig_argv[@]:0:$slice_start}")
	echo_arr new_argv
	#set -- "${new_argv[@]}"
	#echo "${@}"
	local new_argc="${#new_argv[@]}"
#	echo_var new_argc

	# first parse positional args
	for idx in $(seq 0 $((kjlib_argparse__size-1))); do
		local required="${kjlib_argparse__required[$idx]}"
		if _bool $required; then 
			local name="${kjlib_argparse__names[$idx]}"
			echo_var name
			echo pos !!!!!!!!!!!!!!!!!!!!!! not implemented
		fi
	done
	# now extract named args
	for ((idx=0; idx < $kjlib_argparse__size; idx++)); do
		local required="${kjlib_argparse__required[$idx]}"
		if ! _bool $required; then
			local name="${kjlib_argparse__names[$idx]}"
			echo_var name
			local default="${kjlib_argparse__defaults[$idx]}"
			local type_="${kjlib_argparse__types[$idx]}"
			echo_var default
			echo_var type_
			local found=false
			for ((i=0; i < $new_argc; i++)); do
				local arg="${new_argv[$i]}"
				arg=(${arg//=/ })
				echo_arr arg
				if [ "${arg[0]}" == $name ]; then
					echo "yurica !!!"
					kjlib_argparse__values[$idx]="${arg[1]}"
					kjlib_argparse__explicit[$idx]=true
					break
				fi
			done
			[ "${kjlib_argparse__explicit[$idx]}" != "true" ] && kjlib_argparse__explicit[$idx]=false
		fi
	done
	echo_arr kjlib_argparse__values
	echo_arr kjlib_argparse__explicit
}

function print_stack_trace() {
	echo "Stack Trace:"
	echo "	[line] [function] [file]"
	local i=0
	local frame=$(caller $i)
	local rv=$?
	while [ $rv -eq 0 ]; do
		echo "	$frame"
		((i++))
		frame=$(caller $i)
		rv=$?
		
	done
}

function _exception() {
	local msg=$1
	echo "ERROR: $msg" 1>&2
	print_stack_trace 1>&2
	exit 1
}

function kjlib::argparse::get() {
	local req_name="${1}"
	[ "$req_name" != "" ] || _exception "Cannot get empty arg name"
	local found=false
	for ((idx=0; idx < $kjlib_argparse__size; idx++)); do
		local name="${kjlib_argparse__names[$idx]}"
		if [ "$name" == "$req_name" ]; then
			if _bool ${kjlib_argparse__explicit[$idx]}; then
				val="${kjlib_argparse__values[$idx]}"
			else
				val="${kjlib_argparse__defaults[$idx]}"
			fi
			found=true
			break
		fi
	done
	$found || _exception "No arg with the name: '$req_name'."
	echo $val
}





