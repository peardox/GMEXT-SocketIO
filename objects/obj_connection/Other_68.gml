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
count++;
		show_debug_message("Socket Data = " + string(count));
		if(count == 2) {
			show_debug_message("3probe");
		}
		var _buffer = ds_map_find_value(async_load, "buffer");
		// var _size = ds_map_find_value(async_load, "size")
		if(con.state = CONNECTION_STATE.WEBSOCKET) {
			var _websocket_message = buffer_read(_buffer, buffer_string);
			if(con.owner.upgrade_state == UPGRADE_STATE.ACTIVE) {
				show_debug_message("==> WebSocket : " + _websocket_message);
			} else if(con.owner.upgrade_state == UPGRADE_STATE.INPROGRESS) {
				if(1) {// _websocket_message == "3probe") {
					show_debug_message("3probe");
					con.owner.emit(ENGINEIO_MSG.UPGRADE);
					con.owner.upgrade_state = UPGRADE_STATE.ACTIVE;
				}
			}
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
	}
}
