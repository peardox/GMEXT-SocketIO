/// @description Insert description here
// You can write your code in this editor
runlog("== EngineIO End Step");

if(!is_instanceof(socket, EngineIO)) {
	exit;
}

if(socket.state <> CONNECTION_STATE.READY) {
	exit;
}

if(!socket.inbound.connected || !socket.outbound.connected) {
	exit;
}

if(socket.outbound.state = CONNECTION_STATE.READY) {
	if(socket.queuesize > 0) {
		var _msg = socket.outbound.build_post_message();
		if(string_length(_msg) > 0) {
			socket.outbound.post(_msg);
		}
	}
}

if(socket.inbound.state = CONNECTION_STATE.READY) {
	socket.inbound.get();
}