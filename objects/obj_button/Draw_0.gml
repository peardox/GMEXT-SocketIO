/// @description Insert description here
// You can write your code in this editor
draw_button(room_width - 200, room_height - 60, room_width - 20, room_height - 20, !mouse_check_button(mb_left));
if(mouse_check_button_pressed(mb_left)) {
	show_debug_message("==> Message");
	obj_engineio.socket.emit(ENGINEIO_MSG.MESSAGE, "2" + json_stringify(["chat message", "hello"]));
}