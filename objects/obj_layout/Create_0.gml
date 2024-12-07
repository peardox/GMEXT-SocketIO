fp_root = flexpanel_create_node(
	{ width: "100%", height: "100%", alignItems:"center", justifyContent: "center", nodes: [
	{ width: "100%", height: "100%", flexDirection: "column", nodes: [
		{ width: "100%", height: "20%", flexDirection: "column" },
		{ width: "100%", height: "60%", flexDirection: "column" },
		{ width: "100%", height: "20%", flexDirection: "column", nodes: [
			{ width: "90%", height: "100%", marginLeft: "5%", marginRight: "5%", flexDirection: "row", justifyContent: "center", nodes: [
				{ width: "20%", marginRight: "6.666%", data: { class: "button", color: c_red,    text: "Upgrade", callback: { fname: "io.upgrade", args: []}}},
				{ width: "20%", marginRight: "6.666%", data: { class: "button", color: c_green,  text: "Downgrade", callback: { fname: "io.downgrade", args: []}}},
				{ width: "20%", marginRight: "6.666%", data: { class: "button", color: c_blue,   text: "Add User", callback: { fname: "io.emit", args: ["add user", "Gamemaker"]}}},
				{ width: "20%",                        data: { class: "button", color: c_maroon, text: "Hello World", callback: { fname: "io.emit", args: ["new message", "Hello World"]}}}
				] }
			] }
		] }
	] } 
	);
	
////// Calculate layout
flexpanel_calculate_layout(fp_root, room_width, room_height, flexpanel_direction.LTR);

////// Generate object instances
function generate_instance(_node, _depth)
{
	// Get layout data and apply scaling
	var _pos = flexpanel_node_layout_get_position(_node, false);
	var _data = flexpanel_node_get_data(_node);

	// Create instance
	var _obj_struct = { rect: _pos, data: _data, sio: sio };
	if(struct_exists(_data, "class")) {
		instance_create_depth(0, 0, _depth, obj_button, _obj_struct);
	} else {
		instance_create_depth(0, 0, _depth, obj_guideline, _obj_struct);
	}
	show_debug_message(string(_depth) + " - " + json_stringify({x1: _pos.left, _y1: _pos.top, x2: _pos.right, y2: _pos.bottom, width: _pos.width, height: _pos.height}));

	// Call for children (recursive)
	var _children_count = flexpanel_node_get_num_children(_node);
	for (var _i = 0; _i < _children_count; _i++)
	{
		var _child = flexpanel_node_get_child(_node, _i);
		generate_instance(_child, _depth - 1);
	}
}
show_debug_message("--------------------------------------");
generate_instance(fp_root, 0);
show_debug_message("--------------------------------------");
