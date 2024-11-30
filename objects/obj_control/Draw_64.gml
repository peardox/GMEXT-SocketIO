function get_state(_obj, _con) {
	var _rval = undefined;
	var _inst = _obj.socket;
	if(!is_undefined(_inst)) {
		var _val = struct_get(_inst, _con);
		if(!is_undefined(_val)) {
			var _state = struct_get(_val, "state");
			switch(_state) {
				case CONNECTION_STATE.NONE:
					_rval = "None";
					break;
				case CONNECTION_STATE.IDLE:
					_rval = "Idle";
					break;
				case CONNECTION_STATE.READY:
					_rval = "Ready";
					break;
				case CONNECTION_STATE.ACTIVE:
					_rval = "Active";
					break;
			}
		}
	}
	return _rval;
}

draw_set_color(c_white);

draw_set_valign(fa_top);
draw_set_halign(fa_left);

var _inbound = get_state(obj_engineio, "inbound");
var _outbound = get_state(obj_engineio, "outbound");

draw_text(16, 16, "Inbound       = " + string(_inbound));
draw_text(16, 32, "Outbound      = " + string(_outbound));
/*
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