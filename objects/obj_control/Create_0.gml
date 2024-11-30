runlog("Created Control")
var _test = 2;

instance_create_depth(room_width / 2, room_height / 2, 0, obj_button, {});

switch(_test) {
	case 1:
		instance_create_depth(-1, -1, 0, obj_engineio, { url: "192.168.1.18", port: 13378 } );
		break;
	case 2:
		instance_create_depth(-1, -1, 0, obj_engineio, { url: "cge.peardox.com", port : 3100 } );
		break;
	case 3:
		instance_create_depth(-1, -1, 0, obj_engineio, { url: "cge.peardox.com", port : 3200 } );
		break;
	default:
}
