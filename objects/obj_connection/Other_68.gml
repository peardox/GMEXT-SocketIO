runlog("== Connection Async Network");

// feather ignore GM2047
// feather ignore once GM1041
if(!is_instanceof(con, SocketConnection)) {
	exit;
}

if(async_load == -1) {
	exit;
}

var _id = ds_map_find_value(async_load, "id");
var _socket = ds_map_find_value(async_load, "socket");
var _type = ds_map_find_value(async_load, "type")
var _inspect_http = async_load;

if((con.network_id == _id) ) {
	show_debug_message("==> Async - Networking : " + string(con.socket_id) + "/" + string(con.network_id));
	if(_type == network_type_connect) {
		show_debug_message("Socket Connected - Blocking");
	} else if(_type == network_type_non_blocking_connect) {
		// type = 4
		show_debug_message("Socket (" + string(_socket) + ") Connected - Non Blocking");
		var _succeeded = ds_map_find_value(async_load, "succeeded");
		if(_succeeded) {
			con.connected = true;
			con.state = CONNECTION_STATE.READY;
			// con.owner.activate();
			if(con.owner.upgrade_state == UPGRADE_STATE.PENDING) {
				con.get_async();
			}
		} else {
			show_debug_message("Socket (" + string(_socket) + ") Failed to Connect - Closing it down");
			con.close();
		}
	} else if(_type == network_type_disconnect) {
		show_debug_message("Socket Disconnect");
		con.connected = false;
	} else if(_type == network_type_data) {
		show_debug_message("Socket Data = " + string(++count));
		var _buffer = ds_map_find_value(async_load, "buffer");
		if(con.state = CONNECTION_STATE.WEBSOCKET) {
			var _frame = new WebSocketFrame(_buffer);
			if(_frame.valid) {
				if(con.owner.upgrade_state == UPGRADE_STATE.ACTIVE) {
					show_debug_message("==> WebSocket : " );
					if(_frame.opcode == WEBSOCKET_OPCODE.TEXT) {
						var _eio = new EngineIOFrame(_frame.as_string());
						switch(_eio.message_type) {
							case ENGINEIO_MSG.PING: 
								con.websocket_send(event_to_string(ENGINEIO_MSG.PONG) + _eio.message_text, WEBSOCKET_TYPE.TEXT);
								show_debug_message("Got SocketIO Ping : " + _eio.message_text);
								break;
							case ENGINEIO_MSG.PONG: 
								show_debug_message("Got SocketIO Pong : " + _eio.message_text);
								break;
							case ENGINEIO_MSG.MESSAGE: 
								show_debug_message("Got SocketIO Message : " + _eio.message_text);
								break;
							default:
								show_debug_message("Unhandled SocketIO Message : " + string(_eio.message_type) + " = " + _eio.message_text);
								break;
						}
					}
				} else if(con.owner.upgrade_state == UPGRADE_STATE.INPROGRESS) {
					if(_frame.opcode == WEBSOCKET_OPCODE.TEXT) {// _websocket_message == "3probe") {
						var _eio = new EngineIOFrame(_frame.as_string());
						if((_eio.message_type == ENGINEIO_MSG.PONG) && (_eio.message_text == "probe")) {
							show_debug_message("3probe");
							con.websocket_send(event_to_string(ENGINEIO_MSG.UPGRADE), WEBSOCKET_TYPE.TEXT);
							con.owner.upgrade_state = UPGRADE_STATE.ACTIVE;
						}
						delete(_eio);
					}
				}
			}
			delete(_frame);
		} else if(con.state = CONNECTION_STATE.ACTIVE) {
			var _hdr = new HTTPResponseParser(_buffer);
			switch(_hdr.status) {
				case 101:
					if(con.owner.upgrade_state == UPGRADE_STATE.INPROGRESS) {
						if(con.handle_upgrade(_hdr.headers)) {
							show_debug_message("===== Upgrade =====");
						} else {
							con.owner.upgrade_state = UPGRADE_STATE.NONE;
						}
					} else {
						con.owner.upgrade_state = UPGRADE_STATE.NONE;
					}
					break;
				default:
					throw("Bad HTTP code");
					break;
			}
		}
	} else {
		show_debug_message("Unexpected network type");
	}
}
