function MessageQueue(_size) constructor {
	self.queue_size = 0;
	self.members = array_create(0);
	self.head = -1;
	
	if((typeof(_size) == "number") || (typeof(_size) == "int64")) {
		array_resize(members, int64(_size));
		queue_size = int64(_size);
	} else {
		throw("Attempting to set array size to non-integer");
	}
	
	static push = function(_value) {
		head++;
		
		if(head < queue_size) {
			members[head] = _value;
//		} else {
//			throw("Trying to add too many messages");
		}
	}
	
	static pop_all = function() {
		var _rval = "";
		var _message_count = 0;
		for(var _i = 0; _i <= head; _i++) {
			if(!is_undefined(members[_i])) {
				if(is_instanceof(members[_i], EngineIOMessage)) {
					if(_message_count > 0) {
						_rval = _rval + chr(0x1E);
					}
					_rval = chr(members[_i].message_type + 48) + members[_i].message_text;
					_message_count++;

				}
			}
			members[_i] = undefined;
		}
		head = -1;
		return _rval;	
	}
}

function EngineIOMessage(_type, _message) constructor {
	self.message_type = int64(0);
	self.message_text = "";
	
	if((typeof(_type) == "int64") && (typeof(_message) == "string")) {
		message_type = _type;
		message_text = _message;
	} else {
		throw("Trying to queue invalid message");
	}
	
}

function EngineIO(_url, _port, _scheme = "http", _path = "/socket.io/", _transport = "polling", _engine_version = 4) constructor {
	self.url = "";
	self.port = -1;
	self.scheme = "";
	self.path = "";
	self.transport = "";
	self.engine_version = 0;
	self.state = CONNECTION_STATE.NONE;
	self.pingtime = -1;
	self.ping_id = -1;
	self.inbound = -1;
	self.outbound = -1;
    self.sid = "";
    self.upgrades = [];
    self.ping_interval = 0;
    self.ping_imeout = 0;
    self.max_payload = 0;
	self.http_response = new HTTPResponseParser(undefined);
	self.debug = false;
	
	self.queue = new MessageQueue(int64(128));
	self.queuesize = 0;

	if(		(typeof(_url) == "string") && 
			((typeof(_port) == "int64") || (typeof(_port) == "number")) && 
			(typeof(_scheme) == "string") && 
			(typeof(_path) == "string") && 
			(typeof(_transport) == "string") && 
			((typeof(_engine_version) == "int64") || (typeof(_engine_version) == "number"))
		) {
		url = _url;
		port = int64(_port);
		scheme = _scheme;
		path = _path;
		transport = _transport;
		engine_version = int64(_engine_version);
		
		if(string_char_at(path, 1) <> "/") {
			path = "/" + path;
		}
		
		if(string_char_at(path, string_length(path)) <> "/") {
			path = path + "/";
		}
		
		if((transport <> "polling") && (transport <> "websocket")) {
			throw("Invalid transport request");
		}

		if((scheme <> "http") && (scheme <> "https")) {
			throw("Invalid scheme request");
		}

		randomize();

		show_debug_message("EngineIO constructor completed");
		
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
	
	static query = function() {
		var _rval = "EIO=" + string(engine_version) + "&transport=" + transport;
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
		inbound = create_connection(new SocketConnection(self, "long_poll"));
		if(is_instanceof(inbound, SocketConnection)) {
			outbound = create_connection(new SocketConnection(self, "messanger"));
			if(is_instanceof(outbound, SocketConnection)) {
				state = CONNECTION_STATE.IDLE;
			} else {
				outbound = undefined;
			}
		} else {
			inbound = undefined;
		}
	}
	
	static activate = function() {
		if(state == CONNECTION_STATE.IDLE) {
			if((inbound.state == CONNECTION_STATE.READY) && (outbound.state == CONNECTION_STATE.READY)) {
				state = CONNECTION_STATE.READY;
			}
		}
	}
	
	static has_upgrade = function(_upgrade) {
		var _rval = false;
		
		for(var _i=0; _i<array_length(upgrades); _i++) {
			if(upgrades[_i] == _upgrade) {
				_rval = true;
				break;
			}
		}
		
		return _rval;
	}
	
	static reset = function(_all = false) {
		if(_all) {
			url = "";
			port = 0;
			scheme = "";
			path = "";
		}
		sid = "";
		upgrades = [];
		ping_interval = 0;
		ping_imeout = 0;
		max_payload = 0;
	}
	
	
	static split_engineio_message = function(_data) {
		if((typeof(_data) <> "string") && string_length(_data < 1)) {
			return [];
		}

		var _message_type, _payload, _paylen;
		var _parts = string_count("\x1E", _data) + 1;
		var _rval = array_create(_parts);
		var _split_parts = string_split(_data, "\x1E", true);
		
		for(var _i = 0; _i < _parts; _i++) {
			if(string_length(_split_parts[_i]) > 0) {
				_message_type = string_copy(_split_parts[_i], 1, 1);
				if((_message_type < "0") || (_message_type > "6")) {
					array_delete(_rval, 0, _parts);
					return [];
				}
				if(string_length(_split_parts[_i]) > 1) {
					_payload = string_copy(_split_parts[_i], 2, string_length(_split_parts[_i]) - 1);
				} else {
					_payload = "";
				}
				_rval[_i] = { message_type: int64(_message_type), payload: _payload };
			}
		}
		
		return _rval;
	}
	
	static decode_eio_buffer = function(_buf) {
		var _txt = buffer_read(_buf, buffer_string);
		buffer_seek(_buf, buffer_seek_start, 0);
		return split_engineio_message(_txt);
	}
	
	static decode_eio_message = function(_data) {
		return split_engineio_message(_data);
	}
	
	static add_message = function(_type, _message) {
		// feather ignore once GM1041
		queue.push(new EngineIOMessage(_type, _message));
		queuesize++;
	}
	
	static emit = function(_type, _message) {
		switch(_type) {
			case ENGINEIO_MSG.OPEN:
				add_message(ENGINEIO_MSG.MESSAGE, _message);
				break;
			case ENGINEIO_MSG.CLOSE:
				add_message(ENGINEIO_MSG.CLOSE, _message);
				break;
			case ENGINEIO_MSG.PING:
				add_message(ENGINEIO_MSG.PING, _message);
				break;
			case ENGINEIO_MSG.PONG:
				add_message(ENGINEIO_MSG.PONG, _message);
				break;
			case ENGINEIO_MSG.MESSAGE:
				add_message(ENGINEIO_MSG.MESSAGE, _message);
				break;
			case ENGINEIO_MSG.UPGRADE:
				add_message(ENGINEIO_MSG.UPGRADE, _message);
				break;
			case ENGINEIO_MSG.NOOP:
				add_message(ENGINEIO_MSG.NOOP, _message);
				break;
			default:
				throw("Attempted to add bad message");
		}
	}
	
	static parse_eio_open = function(_data) {
		var _json = json_parse(_data);
		var _good_rec = true;
		if(struct_exists(_json, "sid")) {
			sid = _json.sid;
		} else {
			_good_rec = false;
		}
		if(struct_exists(_json, "upgrades")) {
			if(is_array(_json.upgrades)) {
				upgrades = _json.upgrades;
			}
		} else {
			_good_rec = false;
		}
		// Feather ignore GM2017
		if(struct_exists(_json, "pingInterval")) {
			ping_interval = int64(_json.pingInterval);
			pingtime = ping_interval;
		} else {
			_good_rec = false;
		}
		if(struct_exists(_json, "pingTimeout")) {
			ping_timeout = _json.pingTimeout;
		} else {
			_good_rec = false;
		}
		if(struct_exists(_json, "maxPayload")) {
			max_payload = _json.maxPayload;
		} else {
			_good_rec = false;
		}
		// Feather enable GM2017
		
		if(!_good_rec) {
			reset();
			if(debug) {
				show_debug_message("Reset Polling")
			}
		}
		return _good_rec;
	}
}

