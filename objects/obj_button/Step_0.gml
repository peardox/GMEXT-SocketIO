/// @description Insert description here
// You can write your code in this editor

if(mouse_check_button_pressed(mb_left)) {
	if( (mouse_x >= rect.left) &&
		(mouse_x <= (rect.left + rect.width)) &&
		(mouse_y >= rect.top) &&
		(mouse_y <= (rect.top + rect.height))
		) {
			clicked = true;
			pressed = true;
		}
}  

if(mouse_check_button_released(mb_left)) {
	pressed = false;
}