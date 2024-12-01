/// @description Insert description here
// You can write your code in this editor
runlog("== EngineIO End Step");

// feather ignore once GM1041
if(!is_instanceof(io, EngineIO)) {
	exit;
}

if(io.state <> CONNECTION_STATE.READY) {
	exit;
}

if(!io.inbound.connected || !io.outbound.connected) {
	exit;
}

if(io.outbound.state = CONNECTION_STATE.READY) {
	if(io.queuesize > 0) {
		var _msg = io.outbound.build_post_message();
		if(string_length(_msg) > 0) {
			io.outbound.post(_msg);
		}
	}
}

if(io.inbound.state = CONNECTION_STATE.READY) {
	io.inbound.get();
}