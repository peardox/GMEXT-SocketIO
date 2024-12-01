// runlog("== EngineIO Async Network");
/*
if(async_load == -1) {
	exit;
}

var _id = ds_map_find_value(async_load, "id");
var _buffer = ds_map_find_value(async_load, "buffer");
var _type = ds_map_find_value(async_load, "type")
var _inspect_http = async_load;

status = "None";

show_debug_message("==> Async - Networking : " + string(socket.socket_id));
if(!is_undefined(_id) && (socket.socket_id == _id) ) {
	if(_type == network_type_connect) {
		show_debug_message("Socket Connected - Blocking");
		status = "Socket Connected - Blocking";
	} else if(_type == network_type_non_blocking_connect) {
		// type = 4
		show_debug_message("Socket Connected - Non Blocking");
		socket.connect_async();
		status = "Socket Connected - Non Blocking";
	} else if(_type == network_type_disconnect) {
		show_debug_message("Socket Disconnect");
		status = "Socket Disconnected";
	} else if(_type == network_type_data) {
		// type = 3
		show_debug_message("Socket Data");
		status = "Socket Data";
		var _hdr = new HTTPResponseParser(_buffer);
		var _msg = socket.decode_eio_message(_hdr.payload);
		if(socket.sid == "") {
			if(socket.parse_eio_open(_msg[0].payload)) {
				sid = socket.sid;
			}
		}
		socket.connect_async();
	
	
	
	
	
		
		show_debug_message("#" + string(counter) + " : " + _hdr.payload);
		counter++;

		if(triggered_breakpoint) {
			show_debug_message("triggered_breakpoint");
			triggered_breakpoint := false;
		}
		
		var _msg = socket.decode_eio_message(_hdr.payload);
		var _mcnt = array_length(_msg);
		if(_mcnt == 0) {
			if(_hdr.payload == "ok") {
				show_debug_message("Reconnect");
				socket.connect_async();
			} else {
				show_debug_message("No Message : Header Payload = " + _hdr.payload);
			}
		}
		for(var _i=0; _i < _mcnt; _i++) {
			show_debug_message(string(_msg[_i].message_type) + " : " + _msg[_i].payload);
			switch(_msg[_i].message_type) {
				case ENGINEIO_MSG.OPEN:
					if(socket.parse_eio_open(_msg[_i].payload)) {
						socket.emit(ENGINEIO_MSG.MESSAGE, "0");
					}
					break;
				case ENGINEIO_MSG.CLOSE:
					network_destroy(socket.post_socket_id);
					network_destroy(socket.socket_id);
					break;
				case ENGINEIO_MSG.PING:
					socket.emit(ENGINEIO_MSG.PONG, _msg[_i].payload);
					break;
				case ENGINEIO_MSG.PONG:
					socket.emit(ENGINEIO_MSG.PING, _msg[_i].payload);
					break;
				case ENGINEIO_MSG.MESSAGE:
					if(string_copy(_msg[_i].payload, 1, 1) == "0") {
						socket.connect_async();
					}
					break;
				case ENGINEIO_MSG.UPGRADE:
					break;
				case ENGINEIO_MSG.NOOP:
					break;
				default:
					show_debug_message("Bad Message : " + string(_msg[_i]) + "  <= " + _hdr.payload);
			}
		}
		delete(_hdr);

	}
}

*/