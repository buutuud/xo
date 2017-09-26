shell_path="$(dirname "$0")" && IPA="$1" && STEP=1


if [ ! -n "$IPA" ] ;then
	echo "Error -> Please Input PPHelper Crack iQiYiPhoneVideo Path"
	exit 1
fi

function make_dylib() {
	echo '$STEP. Make DyLib' && let STEP=STEP+1
    make clean && make && cp .theos/obj/debug/xo.dylib dylib
}

function local_substrate() {
	otool -L $1/xo.dylib > /tmp/dep.log
	grep "/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate" /tmp/dep.log > /tmp/depo.log
	if [[ $? -eq 0 ]]; then
		echo '$STEP. CydiaSubstrate 依赖替换' && let STEP=STEP+1
	    install_name_tool -change /Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate @loader_path/libsubstrate.dylib $1/xo.dylib
	fi
}

function unzip_ipa() {
	echo '$STEP. Unzip iQiYiPhoneVideo IPA' && let STEP=STEP+1
	[ -d tmp ] && { rm -rf tmp; }
	unzip -qo $IPA -d tmp
}

function insert_dylib() {
	echo '$STEP. Insert DyLib ' && let STEP=STEP+1
	rm -rf tmp/Payload/iQiYiPhoneVideo.app/*Watch*
	local_substrate dylib
	cp dylib/*.dylib tmp/Payload/iQiYiPhoneVideo.app
	optool install -c load -p "@executable_path/xo.dylib" -t tmp/Payload/iQiYiPhoneVideo.app/iQiYiPhoneVideo
}

make_dylib

unzip_ipa

insert_dylib
