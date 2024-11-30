runlog("== Connection Async Network");

// feather ignore once GM1041
if(!is_instanceof(con, SocketConnection)) {
	exit;
}

if(async_load == -1) {
	exit;
}

var _id = ds_map_find_value(async_load, "id");
var _socket = ds_map_find_value(async_load, "socket");
var _buffer = ds_map_find_value(async_load, "buffer");
var _type = ds_map_find_value(async_load, "type")
var _inspect_http = async_load;

if((con.network_id == _id) ) {
	show_debug_message("==> Async - Networking : " + string(con.socket_id) + "/" + string(con.network_id));
	if(_type == network_type_connect) {
		show_debug_message("Socket Connected - Blocking");
	} else if(_type == network_type_non_blocking_connect) {
		// type = 4
		show_debug_message("Socket Connected - Non Blocking");
		con.connected = true;
		con.state = CONNECTION_STATE.READY;
		con.owner.activate();
	} else if(_type == network_type_disconnect) {
		show_debug_message("Socket Disconnect");
		con.connected = false;
	} else if(_type == network_type_data) {
		show_debug_message("Socket Data");
		if(con.state = CONNECTION_STATE.ACTIVE) {
			var _resp = con.handle_response(_buffer);
			if(_resp == -1) {
				show_debug_message("Socket Closed");
				exit;
			} else if(_resp == 0) {
				con.state = CONNECTION_STATE.READY;	
			} else {
				if(con.owner.sid <> "") {
					con.state = CONNECTION_STATE.READY;	
				} else {
					con.state = CONNECTION_STATE.IDLE;	
				}
			}
		}
	}
}
