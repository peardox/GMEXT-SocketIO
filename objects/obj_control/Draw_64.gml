function get_state(_obj, _con) {
	var _stat = undefined;
	var _sock = undefined;
	var _net = undefined;
	var _cnt = 0;
	
	var _inst = _obj.engine_io;
	if(!is_undefined(_inst)) {
		var _val = struct_get(_inst, _con);
		if(!is_undefined(_val)) {
			var _state = struct_get(_val, "state");
			_sock = struct_get(_val, "socket_id");
			_net = struct_get(_val, "network_id");
			_cnt = struct_get(_val, "concount");
			switch(_state) {
				case CONNECTION_STATE.NONE:
					_stat = "None";
					break;
				case CONNECTION_STATE.IDLE:
					_stat = "Idle";
					break;
				case CONNECTION_STATE.READY:
					_stat = "Ready";
					break;
				case CONNECTION_STATE.ACTIVE:
					_stat = "Active";
					break;
				case CONNECTION_STATE.PAUSE:
					_stat = "Pause";
					break;
				case CONNECTION_STATE.UPGRADE:
					_stat = "Upgrade";
					break;
				case CONNECTION_STATE.WEBSOCKET:
					_stat = "WebSocket";
					break;
			}
		}
	}
	return { state: _stat, socket: _sock, network: _net, concount: _cnt };
}

draw_set_color(c_white);

draw_set_valign(fa_top);
draw_set_halign(fa_left);

var _inbound = get_state(obj_engineio, "inbound");
var _outbound = get_state(obj_engineio, "outbound");
var _websocket = get_state(obj_engineio, "websocket");

draw_text(16, 16, "Inbound Port   = " + string(_inbound.state) + " (" + string(_inbound.socket) + " / " + string(_inbound.network) + ") x " + string(_inbound.concount));
draw_text(16, 32, "Outbound Port  = " + string(_outbound.state) + " (" + string(_outbound.socket) + " / " + string(_outbound.network) + ") x " + string(_outbound.concount));
draw_text(16, 48, "WebSocket Port = " + string(_websocket.state) + " (" + string(_websocket.socket) + " / " + string(_websocket.network) + ") x " + string(_websocket.concount));
draw_text(16, 64, "SID = " + string(socketio_inst.engine_io.sid));

/*
draw_text(room_width / 2, 16, "Layout : Left : " + string(lay.left) +
							  ", Right : " + string(lay.right) +
							  ", Width : " + string(lay.width) +
							  ", Height : " + string(lay.height));
							  
draw_text(room_width / 2, 32, "Button : Columns : " + string(bp.columns) +
							  ", Rows : " + string(bp.rows) +
							  ", Width : " + string(bp.width) +
							  ", Height : " + string(bp.height));

if(has_response) {
	var _keys = variable_struct_get_names(response_struct);
	var _max_name = 0;
	for (var _k = 0; _k < array_length(_keys); _k++) {
		if(string_length(_keys[_k]) > _max_name) {
			_max_name = string_length(_keys[_k]);
		}
	}
	draw_text(16, 48, "HTTP Response = " + string(array_length(_keys)) + " entries");
	for (var _k = 0; _k < array_length(_keys); _k++) {
		draw_text(16, 64 + (_k * 16),
			"                " + 
			_keys[_k] + string_repeat(" ", _max_name - string_length(_keys[_k])) + " : " + response_struct[$ _keys[_k]]);
	}
} else {
	draw_text(16, 48, "HTTP Response = <None>");
}
*/