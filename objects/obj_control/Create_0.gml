runlog("Created Control")
#macro TXTPAD 8


var _test = 4;
var _io;
global.counter = 0;

switch(_test) {
	case 0:
		_io = new SocketIO( "cge.peardox.com", 3000 );
		break;
	case 1:
		_io = new SocketIO( "192.168.1.18", 13378 );
		break;
	case 2:
		_io = new SocketIO( "cge.peardox.com", 3100 );
		break;
	case 3:
		_io = new SocketIO( "cge.peardox.com", 3200 );
		break;
	case 4:
		_io = new SocketIO( "piserv.co.uk", 80 );
		break;
	default:
}

socketio_inst = CreateSocketIO(_io);
_io.debug = true;
// _io.upgrade = UPGRADE_STATE.IMMEDIATE;
_io.connect();


instance_create_depth(0, 0, 0, obj_layout, { sio: socketio_inst});
#macro EIO obj_engineio.engine_io