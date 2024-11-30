function SocketConnection(_owner, _type) constructor {
	self.owner = -1;
	self.socket_id = -1;
	self.network_id = -1;
	self.connected = false;
	self.state = CONNECTION_STATE.NONE;
	self.debug = true;
	self.type = "";
	
	static new_connection = function() {
		// var _ip = network_resolve(owner.url);
		socket_id = network_create_socket(network_socket_tcp);
		if(socket_id < 0) {
			throw("Socket Creation Failed");
		}
		
		network_id = network_connect_raw_async( socket_id, owner.url, owner.port );
		if(network_id < 0) {
			throw("Network Connect Failed");
		}
	}
		
	static close = function() {
		network_destroy(socket_id);
		socket_id = -1;
		network_id = -1;
		connected = false;
		state = CONNECTION_STATE.NONE;
	}
	
	if(_owner) {
		owner = _owner;
		type = _type;
		
		new_connection();
		
		show_debug_message("Socket Connected");
		
		return self;
	}
	
	static get = function() {
		if(debug) {
			show_debug_message("GET " + owner.path + "?" + owner.query());
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

	static build_post_message = function() {
		var _rval = owner.queue.pop_all();	
		owner.queuesize = 0;
		return _rval;
	}
	
	static post = function(_message) {
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
		
		close();
		new_connection();
		
		return true;
	}
	
	static handle_response = function(_buffer) {
		var _hdr = new HTTPResponseParser(_buffer);
		if((_hdr.payload) == "ok") {
			return 0;
		}
		var _msg = owner.decode_eio_message(_hdr.payload);
		var _mcnt = array_length(_msg);
		for(var _i=0; _i < _mcnt; _i++) {
			show_debug_message(string(_msg[_i].message_type) + " : " + _msg[_i].payload);
			switch(_msg[_i].message_type) {
				case ENGINEIO_MSG.OPEN:
					if(owner.parse_eio_open(_msg[_i].payload)) {
						owner.emit(ENGINEIO_MSG.MESSAGE, "0");
					}
					break;
				case ENGINEIO_MSG.CLOSE:
					owner.outbound.close();
					close();
					return -1;
					// break;
				case ENGINEIO_MSG.PING:
					owner.emit(ENGINEIO_MSG.PONG, _msg[_i].payload);
					break;
				case ENGINEIO_MSG.PONG:
					owner.emit(ENGINEIO_MSG.PING, _msg[_i].payload);
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
}
	
