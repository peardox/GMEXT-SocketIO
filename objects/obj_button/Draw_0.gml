/// @description Insert description here
// You can write your code in this editor
if(!pressed) {
	draw_set_color(data.color);
} else {
	draw_set_color(c_gray);
}

function invoke_callback(_sio, _data) {
// callback: { fname: "io.emit", args: ["chat message", "Hello World", "${socket.id}-${counter++}"]}
	var _fname = undefined;
	var _args = [];
	
	if(struct_exists(_data, "callback")) {
		if(struct_exists(_data.callback, "args")) {
			_args = _data.callback.args;
			if(struct_exists(_data.callback, "fname")) {
				if (ds_map_exists(global.callback_map, _data.callback.fname)) {
				_fname = ds_map_find_value(global.callback_map, _data.callback.fname);
				with(sio.engine_io) {
					method_call(_fname, _args);
				}
				}
			}
		}
		
	}

}

draw_button(rect.left, rect.top, rect.left + rect.width, rect.top + rect.height, !pressed);
draw_set_color(c_white);
draw_text(rect.left + TXTPAD, rect.top + TXTPAD, data.text);
draw_text(rect.left + TXTPAD, rect.top + TXTPAD + 16, "Left : " + string(rect.left));
draw_text(rect.left + TXTPAD, rect.top + TXTPAD + 32, "Top : " + string(rect.top));
draw_text(rect.left + TXTPAD, rect.top + TXTPAD + 48, "Right : " + string(rect.right));
draw_text(rect.left + TXTPAD, rect.top + TXTPAD + 64, "Bottom : " + string(rect.bottom));
draw_text(rect.left + TXTPAD, rect.top + TXTPAD + 80, "Width : " + string(rect.width));
draw_text(rect.left + TXTPAD, rect.top + TXTPAD + 96, "Height : " + string(rect.height));

if(clicked) {
	// feather ignore once GM1041
	invoke_callback(sio, data);


	clicked = false;
}