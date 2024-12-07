// feather ignore once GM1041
if(!is_instanceof(con, SocketConnection)) {
	exit;
}

if(async_load == -1) {
	exit;
}

var _id = ds_map_find_value(async_load, "id");
var _status = ds_map_find_value(async_load, "status");
var _http_status = ds_map_find_value(async_load, "http_status");
var _result = ds_map_find_value(async_load, "result")
var _inspect_http = async_load;
var _response_headers = ds_map_find_value(async_load, "response_headers");

if((con.req_id == _id) && !is_undefined(_http_status)) {
	runlog("== Connection HTTP Network : " + string(con.req_id), true);
	// Is this rerq for me?
	switch(_http_status) {
		// Is this rerq for me?
		case 200:
			var _resp = con.handle_response(_result);
			if(_resp == -1) {
				show_debug_message("HTTP Socket Closed");
				exit;
			} else if(_resp == 0) {
				con.state = CONNECTION_STATE.READY;	
				runlog("ok : " + string(con.req_id), true);
			} else {
				con.state = CONNECTION_STATE.READY;	
				if(con.usage == SOCKET_USAGE.HTTP_GET) {
					con.get();
				}
			}
			break;
		case 101:
			break;
		default:
			show_debug_message("Error HTTP : " + string(_http_status));
			break;
	}
}

