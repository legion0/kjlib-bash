
if [ -n "$__kjlib_echo__header_guard" ]; then return; fi
__kjlib_echo__header_guard=true

source kjlib_colors.sh || exit

function exception() {
	echo_err "$1"
	echo -ne "${__kjlib_colors__RED}" 1>&2
	print_stack_trace 1 1>&2
	echo -ne "${__kjlib_colors__NC}" 1>&2
	exit 1
}

function echo_err() {
	local msg=$1
	echo -e "${__kjlib_colors__RED}ERROR: ${msg}${__kjlib_colors__NC}" 1>&2
}

function die() {
	echo_err "$1"
	exit 1
}

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

function print_stack_trace() {
	local skip_frames=0
	[ $# -ge 0 ] && skip_frames=$1
	echo "Stack Trace:"
	local i=$skip_frames
	local frame=$(caller $i)
	local rv=$?
	while [ $rv -eq 0 ]; do
		frame=(${frame// / })
		local line=${frame[0]}
		local function=${frame[1]}
		local file=${frame[2]}
		echo "	at $function ($file:$line)"
		((i++))
		frame=$(caller $i)
		rv=$?
		
	done
}

