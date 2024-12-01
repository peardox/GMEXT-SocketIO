runlog("Created Control")
var _test = 2;

instance_create_depth(0, 0, 0, obj_button, {});

switch(_test) {
	case 0:
		io = new EngineIO( "cge.peardox.com", 3000 );
		break;
	case 1:
		io = new EngineIO( "192.168.1.18", 13378 );
		break;
	case 2:
		io = new EngineIO( "cge.peardox.com", 3100 );
		break;
	case 3:
		io = new EngineIO( "cge.peardox.com", 3200 );
		break;
	default:
}

CreateSocketIO(io);
io.debug = true;
io.connect();

