// feather ignore GM2047


// runlog("== EngineIO End Step");

// feather ignore once GM1041
if(!is_instanceof(engine_io, SocketIO)) {
	exit;
}

if(engine_io.state <> CONNECTION_STATE.READY) {
	exit;
}

if(engine_io.outbound.state = CONNECTION_STATE.READY) {
	if(engine_io.queuesize > 0) {
		var _msg = engine_io.outbound.build_post_message();
		if(string_length(_msg) > 0) {
			engine_io.outbound.post(_msg);
		}
	}
}

