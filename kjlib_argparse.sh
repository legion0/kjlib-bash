
if [ -n "$__kjlib_argparse__header_guard" ]; then return; fi
__kjlib_argparse__header_guard=true

source kjlib_echo.sh || exit


function kjlib::argparse::define_int() {
#	echo "$FUNCNAME: $# { $@ }"
	local name="$1"; shift
	local positional=true
	if [[ "$name" == "--"* ]]; then
		local name_len=${#name}
		((name_len--))
		name="${name:2:$name_len}"
		positional=false
	fi
	__kjlib_argparse__names[$__kjlib_argparse__size]=$name
	__kjlib_argparse__types[$name]='int'
	((__kjlib_argparse__size++))
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
	$required && $has_default && die "$name is required and has a redundant default value"
	__kjlib_argparse__positional[$name]=$positional
	__kjlib_argparse__required[$name]=$required
	if $has_default; then
		__kjlib_argparse__defaults[$name]=$default
	fi

#	echo_var __kjlib_argparse__size
#	echo_arr __kjlib_argparse__names
#	echo_arr __kjlib_argparse__required
#	echo_arr __kjlib_argparse__positional
#	echo_arr __kjlib_argparse__defaults
#	echo ""
}

function kjlib::argparse::init() {
#	echo "$FUNCNAME: $# { $@ }"

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
	__kjlib_argparse__passthrough=("${orig_argv[@]:$slice_start:$slice_size}")
#	echo_arr __kjlib_argparse__passthrough
	((slice_start--))
	local new_argv=("${orig_argv[@]:0:$slice_start}")
#	echo_arr new_argv
	#set -- "${new_argv[@]}"
	#echo "${@}"
	local new_argc="${#new_argv[@]}"
#	echo_var new_argc

	# first parse positional args
	local i=0
	for name in "${__kjlib_argparse__names[@]}"; do
		local positional="${__kjlib_argparse__positional[$name]}"
		if $positional; then 
#			echo_var name
			local val="${new_argv[$i]}"
#			echo_var val
			__kjlib_argparse__is_val_not_named_arg "$val" || die "$name is missing or malformed"
			__kjlib_argparse__values[$name]="$val"
			__kjlib_argparse__explicit[$name]=true
			((i++))
		fi
	done

#	echo ""

	local first_optional=$i
	# now extract named args
	for name in "${__kjlib_argparse__names[@]}"; do
		local positional="${__kjlib_argparse__positional[$name]}"
		local explicit=false
		if ! $positional; then
#			echo_var name
			local val=""
			local required="${__kjlib_argparse__required[$name]}"
			if ! $required ]; then
				val="${__kjlib_argparse__defaults[$name]}"
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
			$required && ! $explicit && die "$name is a required argument"
			__kjlib_argparse__explicit[$name]=$explicit
			__kjlib_argparse__values[$name]="$val"
		fi
	done
#	echo_arr __kjlib_argparse__values
#	echo_arr __kjlib_argparse__explicit
#	echo_var __kjlib_argparse__size
#	echo_arr __kjlib_argparse__names
#	echo_arr __kjlib_argparse__required
#	echo_arr __kjlib_argparse__positional
#	echo_arr __kjlib_argparse__defaults
}

function kjlib::argparse::get() {
	local name="${1}"
	local val=""
	[ "$name" != "" ] || _exception "Cannot get empty arg name"
	echo "${__kjlib_argparse__values[$name]}"
}

function kjlib::argparse::explicit() {
	local name="${1}"
	local val=""
	[ "$name" != "" ] || _exception "Cannot get empty arg name"
	echo "${__kjlib_argparse__explicit[$name]}"
}

# Private vars

__kjlib_argparse__names=()
declare -A __kjlib_argparse__positional=()
declare -A __kjlib_argparse__defaults=()
declare -A __kjlib_argparse__required=()
declare -A __kjlib_argparse__types=()
declare -A __kjlib_argparse__values=()
declare -A __kjlib_argparse__explicit=()
__kjlib_argparse__size=0
__kjlib_argparse__passthrough=()

# Private functions

function __kjlib_argparse__is_val_not_named_arg() {
	local val="$1"
	local name=""
	for name in "${__kjlib_argparse__names[@]}"; do
		if [[ "$val" == "--${name}="* ]]; then
			return 1
		fi
	done
	return 0
}

