function WebSocketFrame(_data, _is_client = true) constructor {
	self.fin = true;
	self.opcode = -1;
	self.mask = false;
	self.data_len = 0;
	self.is_client = 0;

	static parse = function(_data) {
		var _u8, _len;
		_u8 = buffer_read(_data, buffer_u8);
		fin = (_u8 & $80) = $80;
		opcode = (_u8 & $0F);
		_u8 = buffer_read(_data, buffer_u8);
		mask = (_u8 & $80) = $80;
		_len = (_u8 & $7F);
		if((_len >= 0) || (_len < 126)) {
			data_len = _len;
		} else if(_len == 126) {
			data_len = buffer_read(_data, buffer_u16);
		} else if(_len == 127) {
			data_len = buffer_read(_data, buffer_u32);
		} else {
			throw("WebSocketFrame : Bad Frame Length");
		}
		
		if(is_client && mask) {
			throw("WebSocketFrame : Mask found for client");
		} else if(!is_client && !mask) {
			throw("WebSocketFrame : Mask missing for server");
		}
		
		if(opcode == 0) {
		} else if(opcode == 0) {
			show_debug_message("Continuation Frame");
		} else if(opcode == 1) {
			show_debug_message("Text Frame");
		} else if(opcode == 2) {
			show_debug_message("Binary Frame");
		} else if(opcode == 8) {
			show_debug_message("Close Frame");
		} else if(opcode == 9) {
			show_debug_message("Ping Frame");
		} else if(opcode == 10) {
			show_debug_message("Pong Frame");
		} else {
			throw("WebSocketFrame : Got Reserved Opcode (" + string(opcode) + ")");
		}
	}
	
	static random_byte = function() {
		return irandom(255);
	}
	
	if((typeof(_data) == "ref") && buffer_exists(_data))  {
		is_client = _is_client;
		parse(_data);
	}
}

///@func HTTPResponseParser(data)
///@param {any} _data The buffer holding the full response.
///@desc HTTP Response Parser
function HTTPResponseParser(_data) constructor {
	self.http_method = "";
	self.status = 0;
	self.code = "";
	self.payload = "";
	self.headers = {};
	self.is_valid = false;

	static __parse = function(_data) {
		buffer_seek(_data, buffer_seek_start, 0);
		
		var _key, _value, _colon_pos, _header_len;
		var _buffer = buffer_read(_data, buffer_text);
		var _lines = string_split(_buffer, "\r\n");
		var _header_index = 1;
		var _http_line = string_split(_lines[0], " ", false, 2);
		
		if(array_length(_http_line) <> 3) {
			// There must be 3 parts to HTTP reponse
			throw("Malformed HTTP header");
		}
		
		http_method = _http_line[0];
		status = real(_http_line[1]);
		code = _http_line[2];
		
		while(_lines[_header_index] <> "") {
			_colon_pos = string_pos(":", _lines[_header_index]);
			_header_len = string_length(_lines[_header_index]);
			if((_colon_pos < 2) || (_colon_pos >= (_header_len - 1))) {
				// Colon can't be at start or end of string (with space after it)
				throw("Malformed Header");
			}
			_key = string_copy(_lines[_header_index], 1, _colon_pos - 1);
			_value = string_copy(_lines[_header_index], _colon_pos + 2, _header_len - _colon_pos - 1);
			struct_set(headers, _key, _value);
			_header_index++;
		}
		_header_index++;
		// Advance past blank line at end of headers
		if(_header_index < array_length(_lines)) {
			// Advance to start of payload
			payload = _lines[_header_index];
		}
		is_valid = true;
	}

	static parse = function(_data) {
		if((typeof(_data) <> "ref") && !buffer_exists(_data))  {
			__parse(_data);
		}
	}
	if((typeof(_data) == "ref") && buffer_exists(_data))  {
		__parse(_data);
	}
}
