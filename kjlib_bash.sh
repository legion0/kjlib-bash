kjlib_argparse__names=()
declare -A kjlib_argparse__positional=()
declare -A kjlib_argparse__defaults=()
declare -A kjlib_argparse__required=()
declare -A kjlib_argparse__types=()
declare -A kjlib_argparse__values=()
declare -A kjlib_argparse__explicit=()
kjlib_argparse__size=0
kjlib_argparse__passthrough=()

RED='\033[0;31m'
NC='\033[0m'

function echo_arr() {
	local n=$1
	local v=""
	local s=0
	eval "k=(\"\${!${1}[@]}\")"
	eval "v=(\"\${${1}[@]}\")"
	eval "s=(\"\${#${1}[@]}\")"
	echo -n "$n ($s): { "
	for key in "${k[@]}"; do
		eval "val=\"\${${1}[$key]}\""
		echo -n "$key=$val "
	done
	echo "}"
}
function echo_var() {
	local n=$1
	local v=""
	eval "v=\${$1}"
	echo "$n=$v"
}


function kjlib::argparse::define_int() {
	echo "$FUNCNAME: $# { $@ }"
	local name="$1"; shift
	local positional=true
	if [[ "$name" == "--"* ]]; then
		local name_len=${#name}
		((name_len--))
		name="${name:2:$name_len}"
		positional=false
	fi
	kjlib_argparse__names[$kjlib_argparse__size]=$name
	kjlib_argparse__types[$name]='int'
	((kjlib_argparse__size++))
	local has_default=false
	local default=""
	while [ $# -ne 0 ]; do
		local arg="$1"; shift
		arg=(${arg//=/ })
		case ${arg[0]} in
			default)
				has_default=true
				default=${arg[1]}
			;;
			*)
				echo "OTHER ${arg[0]} = ${arg[1]} !!!"
			;;
		esac
	done
	local required=false
	{ $positional || ! $has_default;} && required=true
	$required && $has_default && _die "$name is required and has a redundant default value"
	kjlib_argparse__positional[$name]=$positional
	kjlib_argparse__required[$name]=$required
	if $has_default; then
		kjlib_argparse__defaults[$name]=$default
	fi

	echo_var kjlib_argparse__size
	echo_arr kjlib_argparse__names
	echo_arr kjlib_argparse__required
	echo_arr kjlib_argparse__positional
	echo_arr kjlib_argparse__defaults
	echo ""
}

function _is_val_not_named_arg() {
	local val="$1"
	local name=""
	for name in "${kjlib_argparse__names[@]}"; do
		if [[ "$val" == "--${name}="* ]]; then
			return 1
		fi
	done
	return 0
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
	local i=0
	for name in "${kjlib_argparse__names[@]}"; do
		local positional="${kjlib_argparse__positional[$name]}"
		if $positional; then 
			echo_var name
			local val="${new_argv[$i]}"
			echo_var val
			_is_val_not_named_arg "$val" || _die "$name is missing or malformed"
			kjlib_argparse__values[$name]="$val"
			kjlib_argparse__explicit[$name]=true
			((i++))
		fi
	done

	echo ""

	local first_optional=$i
	# now extract named args
	for name in "${kjlib_argparse__names[@]}"; do
		local positional="${kjlib_argparse__positional[$name]}"
		local explicit=false
		if ! $positional; then
#			echo_var name
			local val=""
			local required="${kjlib_argparse__required[$name]}"
			if ! $required ]; then
				val="${kjlib_argparse__defaults[$name]}"
			fi
			for ((i=$first_optional; i < $new_argc; i++)); do
				local arg="${new_argv[$i]}"
				if [[ "$arg" == "--${name}="* ]]; then
					arg=(${arg//=/ })
#					echo_arr arg
					val="${arg[1]}"
					explicit=true
					break
				fi
			done
			$required && ! $explicit && _die "$name is a required argument"
			kjlib_argparse__explicit[$name]=$explicit
			kjlib_argparse__values[$name]="$val"
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
	echo -e "${RED}ERROR: $msg" 1>&2
	print_stack_trace 1>&2
	echo -ne "$NC"
	exit 1
}

function _die() {
	local msg=$1
	echo -e "${RED}ERROR: ${msg}${NC}" 1>&2
	exit 1
}

function kjlib::argparse::get() {
	local name="${1}"
	local val=""
	[ "$name" != "" ] || _exception "Cannot get empty arg name"
	echo "${kjlib_argparse__values[$name]}"
}

function kjlib::argparse::explicit() {
	local name="${1}"
	local val=""
	[ "$name" != "" ] || _exception "Cannot get empty arg name"
	echo "${kjlib_argparse__explicit[$name]}"
}





