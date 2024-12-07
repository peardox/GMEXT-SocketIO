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
		members[head] = _value;

		if(head < queue_size) {
			array_resize(members, queue_size + 20);
			queue_size = queue_size + 20
		}
	}
	
	static pop_all = function() {
		var _rval = "";
		var _message_count = 0;
		for(var _i = 0; _i <= head; _i++) {
			if(!is_undefined(members[_i])) {
				// feather ignore once GM1041
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

function SocketConnection(_owner, _type, _usage) constructor {
	self.owner = -1;
	self.socket_id = -1;
	self.network_id = -1;
	self.connected = false;
	self.state = CONNECTION_STATE.NONE;
	self.debug = true;
	self.nonse = "";
	self.req_id = -1;
	self.type = SOCKET_TYPE.NONE;
	self.concount = int64(0);
	self.usage = SOCKET_USAGE.NONE;
	
//	self.queue = new MessageQueue(int64(128));
//	self.queuesize = 0;
	
	static new_connection = function() {
		if(type == SOCKET_TYPE.WEBSOCKET) {
			socket_id = network_create_socket(network_socket_tcp);
			if(socket_id < 0) {
				throw("Socket Creation Failed");
			}

			network_id = network_connect_raw_async( socket_id, owner.url, owner.port );
			if(network_id < 0) {
				throw("Network Connect Failed");
			}
			concount++;
		} else {
			state = CONNECTION_STATE.READY;
		}
			
	}
		
	static close = function() {
		if(type == SOCKET_TYPE.WEBSOCKET) {
			network_destroy(socket_id);
			socket_id = -1;
			network_id = -1;
			connected = false;
			state = CONNECTION_STATE.NONE;
			type = SOCKET_TYPE.NONE;
		}
	}
	
	static reconnect = function(_force = false) {
		if(state <> CONNECTION_STATE.PAUSE) {
			if((state <> CONNECTION_STATE.WEBSOCKET) || (_force == true)) {
				if(owner.websocket <> self) {
					close();
					new_connection();
				}
			}
		}
	}
	
	if(_owner) {
		owner = _owner;
		type = _type;
		usage = _usage;
		
		new_connection();
		if(type == SOCKET_TYPE.WEBSOCKET) {
			show_debug_message("Socket Connected");
		}
		
		return self;
	}
	
	static get_http = function() {
		if(owner.upgrade_state <> UPGRADE_STATE.NONE) {
			return -1;
		}
		var _url = owner.full_url() + owner.path + "?" + owner.query();
		var _headers = ds_map_create();
		ds_map_add(_headers, "Accept:", "*/*");
		ds_map_add(_headers, "User-Agent:", "SocketTests");
		ds_map_add(_headers, "Connection:", "keep-alive");
		ds_map_add(_headers, "Cache-Control:", "no-cache");
		ds_map_add(_headers, "Content-Type", "text/plain;charset=UTF-8");
		ds_map_add(_headers, "Origin:", owner.full_url());
		ds_map_add(_headers, "Referer:", owner.full_url() + "/");
		ds_map_add(_headers, "Accept-Encoding:", "gzip, deflate");
		ds_map_add(_headers, "Accept-Language:", "en-GB,en-US;q=0.9,en;q=0.8,af;q=0.7,en-CA;q=0.6");
		req_id = http_request(_url, "GET", _headers, "");
		ds_map_destroy(_headers);
		concount++;
		state = CONNECTION_STATE.ACTIVE;
		show_debug_message("HTTP GET (" + string(req_id) + ") : " + _url);
		if(req_id == 1) {
			show_debug_message("1 = HTTP GET (" + string(req_id) + ") : " + _url);
		}
	}
	
	static get_async = function() {
		if(debug) {
			show_debug_message("Async GET " + owner.path + "?" + owner.query());
		}
		
		var _extra_headers = "";
		
		if(owner.upgrade_state = UPGRADE_STATE.PENDING) {
			// Set the upgrade headers
			owner.nonce = make_nonce(); // "AQIDBAUGBwgJCgsMDQ4PEC==";
			// Create a nonce for Sec-WebSocket-Key
			_extra_headers = "Connection: Upgrade\r\n" +
							 "Upgrade: websocket\r\n" +
							 "Sec-WebSocket-Key: " + owner.nonce + "\r\n" +
							 "Sec-WebSocket-Version: 13\r\n" +
							 "sec-websocket-extensions: permessage-deflate; client_max_window_bits\r\n";
			owner.upgrade_state = UPGRADE_STATE.INPROGRESS;
			show_debug_message("=======> Upgrade Requested <=======");
		}

		
		var _http_message = "GET " + owner.path + "?" + owner.query() + " HTTP/1.1\r\n" +
							"Host: " + owner.host() + "\r\n" +
							"Accept: */*\r\n" +
							"User-Agent: SocketTests\r\n" +
							"Connection: keep-alive\r\n" + 
							"Cache-Control: no-cache\r\n" + 
						    "Origin: " + owner.full_url() + "\r\n" +
						    "Referer: " + owner.full_url() + "/\r\n" +
						    "Accept-Encoding: gzip, deflate\r\n" +
						    "Accept-Language: en-GB,en-US;q=0.9,en;q=0.8,af;q=0.7,en-CA;q=0.6\r\n" +
							_extra_headers +
							"\r\n";
						
		var _sl = string_length(_http_message);
		var _sock_buffer = buffer_create(0, buffer_grow, 1);
		buffer_write(_sock_buffer, buffer_text, _http_message);
		var _bytes = network_send_raw(network_id, _sock_buffer,  _sl);
		buffer_delete(_sock_buffer);
		if(_bytes <> _sl) {
			if(debug) {
				if(_bytes == -1) {
					show_debug_message("Socket Get Failed");
				} else {
					show_debug_message("Socket Get Sent Wrong Data Length");
				}
			}
			state = CONNECTION_STATE.NONE;
			owner.state = CONNECTION_STATE.NONE;
			return false;
		}
		if(debug) {
			show_debug_message("Sent Get");
		}
		state = CONNECTION_STATE.ACTIVE;
		return true;
	}

	static get = function() {
		switch(type) {
			case SOCKET_TYPE.HTTP:
				get_http();
				break;
			case SOCKET_TYPE.WEBSOCKET:
				get_async();
				break;
		}
	}

	static build_post_message = function() {
		var _rval = owner.queue.pop_all();	
		owner.queuesize = 0;
		return _rval;
	}
	
	static post_http = function(_message) {
		if(owner.upgrade_state <> UPGRADE_STATE.NONE) {
			return -1;
		}
		var _url = owner.full_url() + owner.path + "?" + owner.query();
		var _headers = ds_map_create();
		ds_map_add(_headers, "Accept:", "*/*");
		ds_map_add(_headers, "User-Agent:", "SocketTests");
		ds_map_add(_headers, "Connection:", "keep-alive");
		ds_map_add(_headers, "Cache-Control:", "no-cache");
		ds_map_add(_headers, "Content-Type", "text/plain;charset=UTF-8");
		ds_map_add(_headers, "Origin:", owner.full_url());
		ds_map_add(_headers, "Referer:", owner.full_url() + "/");
		ds_map_add(_headers, "Accept-Encoding:", "gzip, deflate");
		ds_map_add(_headers, "Accept-Language:", "en-GB,en-US;q=0.9,en;q=0.8,af;q=0.7,en-CA;q=0.6");
		req_id = http_request(_url, "POST", _headers, _message);
		ds_map_destroy(_headers);
		concount++;
		state = CONNECTION_STATE.ACTIVE;
		show_debug_message("HTTP POST (" + string(req_id) + ") : " + _message);
		if(req_id == 1) {
			show_debug_message("1 = HTTP POST (" + string(req_id) + ") : " + _url);
		}
	}
	
	static post_async = function(_message) {
		if(debug) {
			show_debug_message("POST " + owner.path + "?" + owner.query() + " : " + _message);
		}
		
		var _message_length = string_length(_message);
		var _http_message = "POST " + owner.path + "?" + owner.query() + " HTTP/1.1\r\n" +
							"Host: " + owner.host() + "\r\n" +
							"Accept: */*\r\n" +
							"User-Agent: SocketTests\r\n" +
							"Connection: keep-alive\r\n" + 
							"Content-Type: text/plain;charset=UTF-8\r\n" +
							"Content-Length: " + string(_message_length) + "\r\n" + 
							"Cache-Control: no-cache\r\n" + 
						    "Origin: " + owner.full_url() + "\r\n" +
						    "Referer: " + owner.full_url() + "/\r\n" +
						    "Accept-Encoding: gzip, deflate\r\n" +
						    "Accept-Language: en-GB,en-US;q=0.9,en;q=0.8,af;q=0.7,en-CA;q=0.6\r\n" +
							"\r\n" +
							_message;
						
		var _sl = string_length(_http_message);
		var _sock_buffer = buffer_create(0, buffer_grow, 1);
		buffer_write(_sock_buffer, buffer_text, _http_message);
		var _bytes = network_send_raw(network_id, _sock_buffer,  _sl);
		buffer_delete(_sock_buffer);
		if(_bytes <> _sl) {
			if(debug) {
				if(_bytes == -1) {
					show_debug_message("Socket Post Failed");
				} else {
					show_debug_message("Socket Post Sent Wrong Data Length");
				}
			}
			state = CONNECTION_STATE.NONE;
			owner.state = CONNECTION_STATE.NONE;
			return false;
		}
		if(debug) {
			show_debug_message("Sent Post");
		}
		
		reconnect();		
		return true;
	}
	
	static post = function(_message) {
		switch(type) {
			case SOCKET_TYPE.HTTP:
				post_http(_message);
				break;
			case SOCKET_TYPE.WEBSOCKET:
				post_async(_message);
				break;
		}
	}
	
	static websocket_send = function(_message, _type) {
		if(debug) {
			if(_type == WEBSOCKET_TYPE.TEXT ) {
				show_debug_message("WebSocket " + _message);
			}
		}
		var _buf;
		if(_type == WEBSOCKET_TYPE.TEXT ) {
			_buf = websocket_text_frame(_message);
		}
		
		var _blen = buffer_get_size(_buf);
		var _bytes = network_send_raw(network_id, _buf,  _blen);
		buffer_delete(_buf);
		if(_bytes <> _blen) {
			if(debug) {
				if(_bytes == -1) {
					show_debug_message("Socket Post Failed");
				} else {
					show_debug_message("Socket Post Sent Wrong Data Length");
				}
			}
			return false;
		}
		if(debug) {
			show_debug_message("Sent WebSocket : " + _message);
		}
		
		return true;
	}
	
	static handle_upgrade = function(_headers) {
		var _expecting = validate_nonce(owner.nonce);
		var _valid = struct_get(_headers, "Sec-WebSocket-Accept");
		if(is_string(_valid) && (_valid == _expecting)) {
			state = CONNECTION_STATE.WEBSOCKET;
			owner.emit(ENGINEIO_MSG.PING, "probe");
			return true;
		}
		return false;
	}
	
	static handle_response = function(_hdr) {
		if((_hdr == "ok") || (_hdr == "")) {
			return 0;
		}
		var _msg = decode_eio_message(_hdr);
		var _mcnt = array_length(_msg);
		for(var _i=0; _i < _mcnt; _i++) {
			show_debug_message(string(_msg[_i].message_type) + " : " + _msg[_i].payload);
			switch(_msg[_i].message_type) {
				case ENGINEIO_MSG.OPEN:
					if(parse_eio_open(_msg[_i].payload)) {
						emit(ENGINEIO_MSG.MESSAGE, "0");
					}
					break;
				case ENGINEIO_MSG.CLOSE:
					owner.outbound.close();
					close();
					return -1;
					// break;
				case ENGINEIO_MSG.PING:
					emit(ENGINEIO_MSG.PONG, _msg[_i].payload);
					break;
				case ENGINEIO_MSG.PONG:
					emit(ENGINEIO_MSG.PING, _msg[_i].payload);
					break;
				case ENGINEIO_MSG.MESSAGE:
//					if(string_copy(_msg[_i].payload, 1, 1) == "0") {
//						socket.connect_async();
//					}
					break;
				case ENGINEIO_MSG.UPGRADE:
					break;
				case ENGINEIO_MSG.NOOP:
					break;
				default:
					show_debug_message("Bad Message : " + string(_msg[_i]) + "  <= " + _hdr.payload);
			}
			
			return 1;
		}
		
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
		owner.queue.push(new EngineIOMessage(_type, _message));
		owner.queuesize++;
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
			owner.sid = _json.sid;
		} else {
			_good_rec = false;
		}
		if(struct_exists(_json, "upgrades")) {
			if(is_array(_json.upgrades)) {
				owner.upgrade_available = _json.upgrades;
		//		if((upgrade = UPGRADE_STATE.IMMEDIATE) && (has_upgrade("websocket"))) {
		//			upgrade = UPGRADE_STATE.PENDING;
		//		}
			}
		} else {
			_good_rec = false;
		}
		// Feather ignore GM2017
		if(struct_exists(_json, "pingInterval")) {
			owner.ping_interval = int64(_json.pingInterval);
			owner.pingtime =  int64(_json.pingInterval);
		} else {
			_good_rec = false;
		}
		if(struct_exists(_json, "pingTimeout")) {
			owner.ping_timeout = _json.pingTimeout;
		} else {
			_good_rec = false;
		}
		if(struct_exists(_json, "maxPayload")) {
			owner.max_payload = _json.maxPayload;
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
	
