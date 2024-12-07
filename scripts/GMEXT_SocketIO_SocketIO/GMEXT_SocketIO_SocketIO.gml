// feather ignore once GM2017
function CreateSocketIO(_engine_io) {
	return instance_create_depth(-1, -1, 0, obj_engineio, { engine_io: _engine_io });
}

function event_to_string(_evt) {
	return chr(_evt + 48);
}

function SocketIOMessage(_type, _message) constructor {
	self.message_type = int64(0);
	self.message_text = "";
	
	if((typeof(_type) == "int64") && (typeof(_message) == "string")) {
		message_type = int64(_type);
		message_text = _message;
	}
}

function SocketIO(_url, _port, _scheme = "http", _path = "/socket.io/", _engine_version = 4) constructor {
	self.url = "";
	self.port = -1;
	self.scheme = "";
	self.path = "";
	self.transport = SOCKET_TRANSPORT.NONE;
	self.engine_version = 0;

	self.state = CONNECTION_STATE.NONE;

	self.inbound = -1;
	self.outbound = -1;
	self.websocket = -1;

	self.pingtime = -1;
	self.ping_id = -1;

    self.sid = "";
	self.ping_interval = 0;
    self.ping_imeout = 0;
    self.max_payload = 0;
	self.pingtime = 0;

	self.upgrade_available = [];
	self.upgrade_state = UPGRADE_STATE.NONE;

	self.http_response = new HTTPResponseParser(undefined);
	self.debug = false;
	
	self.queue = new MessageQueue(int64(128));
	self.queuesize = 0;
	
	if(		(typeof(_url) == "string") && 
			((typeof(_port) == "int64") || (typeof(_port) == "number")) && 
			(typeof(_scheme) == "string") && 
			(typeof(_path) == "string") && 
			((typeof(_engine_version) == "int64") || (typeof(_engine_version) == "number"))
		) {
		url = _url;
		port = int64(_port);
		scheme = _scheme;
		path = _path;
		transport = SOCKET_TRANSPORT.POLLING;
		engine_version = int64(_engine_version);
		
		if(string_char_at(path, 1) <> "/") {
			path = "/" + path;
		}
		
		if(string_char_at(path, string_length(path)) <> "/") {
			path = path + "/";
		}
		
		if((scheme <> "http") && (scheme <> "https")) {
			throw("Invalid scheme request");
		}

		randomize();
	
	} else {
		throw("EngineIO constructor failed");
	}
	
	static host = function() {
		if(port == 80) {
			return url;
		}
		return url + ":" + string(port);
	}
	
	static full_url = function() {
		return scheme + "://" + host();
	}
	
	static transport_type = function() {
		if(transport == SOCKET_TRANSPORT.POLLING) {
			return "polling";
		} else if(transport == SOCKET_TRANSPORT.WEBSOCKET) {
			return "websocket";
		} else {
			throw("Bad Transport");
		}
	}
	
	static query = function() {
		var _rval = "EIO=" + string(engine_version) + "&transport=" + transport_type();
		if(sid <> "") {
			_rval = _rval + "&sid=" + url_encode(sid);
		}
		return _rval;
	}
	
	static create_connection = function(_con) {
		if(instance_create_depth(-1, -1, 0, obj_connection, { con: _con } )) {
			return _con;
		} else {
			return undefined;
		}
	}

	static connect = function() {
		inbound = create_connection(new SocketConnection(self, SOCKET_TYPE.HTTP, SOCKET_USAGE.HTTP_GET));
		if(is_instanceof(inbound, SocketConnection)) {
			outbound = create_connection(new SocketConnection(self, SOCKET_TYPE.HTTP, SOCKET_USAGE.HTTP_POST));
			if(is_instanceof(outbound, SocketConnection)) {
				state = CONNECTION_STATE.READY;
				inbound.get();
			}
		} else {
			inbound = undefined;
		}
	}
	
	static emit = function(_evt, _msg = undefined, _callback = undefined) {
		if(transport == SOCKET_TRANSPORT.WEBSOCKET) {
			if(!is_undefined(_callback)) {
				websocket.websocket_send(event_to_string(ENGINEIO_MSG.MESSAGE) + event_to_string(SOCKETIO_MSG.EVENT) + json_stringify([_evt, _msg, _callback]), WEBSOCKET_TYPE.TEXT);
			} else if(!is_undefined(_msg)) {
				websocket.websocket_send(event_to_string(ENGINEIO_MSG.MESSAGE) + event_to_string(SOCKETIO_MSG.EVENT) + json_stringify([_evt, _msg]), WEBSOCKET_TYPE.TEXT);
			} else {
				websocket.websocket_send(event_to_string(ENGINEIO_MSG.MESSAGE) + event_to_string(SOCKETIO_MSG.EVENT) + json_stringify([_evt]), WEBSOCKET_TYPE.TEXT);
			}
		} else if(transport == SOCKET_TRANSPORT.POLLING) {
			if(!is_undefined(_callback)) {
				outbound.emit(ENGINEIO_MSG.MESSAGE,  event_to_string(SOCKETIO_MSG.EVENT) + json_stringify([_evt, _msg, _callback]));
			} else if(!is_undefined(_msg)) {
				outbound.emit(ENGINEIO_MSG.MESSAGE,  event_to_string(SOCKETIO_MSG.EVENT) + json_stringify([_evt, _msg]));
			} else {
				outbound.emit(ENGINEIO_MSG.MESSAGE,  event_to_string(SOCKETIO_MSG.EVENT) + json_stringify([_evt]));
			}
		} else {
			throw("Bad transport");
		}
	}
	
	static downgrade = function() {
	}
	
	static upgrade = function() {
		websocket = create_connection(new SocketConnection(self, SOCKET_TYPE.WEBSOCKET, SOCKET_USAGE.WEBSOCKET));
		if(is_instanceof(websocket, SocketConnection)) {
			transport = SOCKET_TRANSPORT.WEBSOCKET;
			state = CONNECTION_STATE.READY;
			upgrade_state = UPGRADE_STATE.PENDING;
		}
	}


	global.callback_map = ds_map_create();
	ds_map_add(global.callback_map, "io.emit", emit);
	ds_map_add(global.callback_map, "io.upgrade", upgrade);
	ds_map_add(global.callback_map, "io.downgrade", downgrade);

}