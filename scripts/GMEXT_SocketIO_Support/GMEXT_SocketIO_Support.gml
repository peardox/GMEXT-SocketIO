global.time = get_timer();
global.frame = 0;
global.elapsed = 0;
global.last_log = "";

enum ENGINEIO_MSG { OPEN, CLOSE, PING, PONG, MESSAGE, UPGRADE, NOOP }
enum SOCKETIO_MSG { CONNECT, DISCONNECT, EVENT, ACK, CONNECTION_ERROR, BINARY_EVENT, BINARY_ACK }
enum WEBSOCKET_OPCODE { CONTINUATION, TEXT, BINARY, CLOSE = 8, PING, PONG }
enum CONNECTION_STATE { NONE, IDLE, READY, ACTIVE, PAUSE, UPGRADE, WEBSOCKET }
enum UPGRADE_STATE { NONE, PENDING, INPROGRESS, ACTIVE, PAUSE, DOWNGRADE, IMMEDIATE }
enum WEBSOCKET_TYPE { TEXT, BINARY }
enum SOCKET_TYPE { NONE, HTTP, WEBSOCKET }
enum SOCKET_USAGE { NONE, HTTP_GET, HTTP_POST, WEBSOCKET }
enum SOCKET_TRANSPORT { NONE, POLLING, WEBSOCKET }

function runlog(_txt, _dupe = false) {
	if((global.last_log <> _txt) || _dupe) {
		show_debug_message(_txt);
		global.last_log = _txt;
	}
}

function EngineIOFrame(_message) constructor {
	self.message_type = int64(-1);
	self.message_text = "";
	
	if(typeof(_message) == "string") {
		var _sl = string_length(_message);
		if(_sl > 0) {
			var _mt = ord(string_char_at(_message, 1)) - 48;
			if((_mt >= ENGINEIO_MSG.OPEN) && (_mt <= ENGINEIO_MSG.NOOP)) {
				message_type = _mt;
				if(_sl > 1) {
					message_text = string_copy(_message, 2, _sl - 1);
				}
			}
		}
	} else {
		throw("Trying to create invalid EngineIOFrame");
	}
	
}

function WebSocketFrame(_buffer) constructor  {
	self.valid = true;
	self.fin = false;
	self.opcode = int64(-1);
	self.masked = false;
	self.datalen  = int64(0);
	self.data = undefined;
	
	static as_string = function() {
		if(!is_undefined(data)) {
			buffer_seek(data, buffer_seek_start, 0);
			return buffer_read(data, buffer_text);
		} else {
			return "";
		}
	}

	static _decode = function (_buf) {
		var _buflen = buffer_get_size(_buf);
		var _byte = 0;
	
		if(_buflen < 2) {
			// If the buffer is under 2 bytes this is a bad frame
			return _frame;
		}
	
		buffer_seek(_buf, buffer_seek_start, 0);
	
		// Decode first byte
		_byte = buffer_read(_buf, buffer_u8);
		if((_byte & $70) <> 0) {
			// If bits 4-6 are non-zero this is a bad frame
			return _frame;
		}
		fin = ((_byte & $80) <> 0);
		opcode = (_byte & $0000000F);
		if(((opcode > 2) && (opcode < 8)) || (opcode > 10)) {
			// Only opcodes 0, 1, 2, 8, 9 + 10 are valid this is a bad frame
			// Proper values are enumerated in WEBSOCKET_OPCODE
			return _frame;
		}
	
		// Decode second byte
		_byte = buffer_read(_buf, buffer_u8);
		masked = ((_byte & $80) <> 0);
		if(masked) {
			// We're a client, server responses are never masked so this is a bad frame
			return _frame;
		}
	
		datalen = (_byte & $7F);
		if(datalen == 0) {
			// This is a valid frame with no data - i.e. just an opcode
			valid = true;
			return _frame;
		}
	
		var _bufpos = 2;
		// Buffer is variable length so keep track of where it starts
	
		if(datalen == $7E) {
			if(_buflen < 4) {
				// Can't read next 2 bytes - bad frame
				return _frame;
			}
			// Network order WORD
			datalen = buffer_read(_buf, buffer_u8) << 8;
			datalen = data_len | buffer_read(_buf, buffer_u8);
			_bufpos = _bufpos + 2;
		}
	
		if(datalen == $7F) {
			if(_buflen < 6) {
				// Can't read next 4 bytes - bad frame
				return _frame;
			}
			// Network order WORD
			datalen = buffer_read(_buf, buffer_u8) << 24;
			datalen = data_len | (buffer_read(_buf, buffer_u8) << 16);
			datalen = data_len | (buffer_read(_buf, buffer_u8) << 8);
			datalen = data_len | buffer_read(_buf, buffer_u8);
			_bufpos = _bufpos + 4;
		}
	
		if(_buflen < (_bufpos + datalen)) {
			// Can't read entire buffer - bad frame
			return _frame;
		}
	
		data = buffer_create(datalen, buffer_fixed, 1);
		buffer_copy(_buf, _bufpos, datalen, data, 0);
	
		valid = true;
	}
	
	if((typeof(_buffer) == "ref") && buffer_exists(_buffer))  {
		_decode(_buffer);
	}

}

function websocket_text_frame(_data) {
	var _datalen = string_length(_data);
	var _buflen = _datalen + 2; // 2 byte header
	var _mask_length_bits = 0;
	var _mask;
	if(_datalen > 0) {
		_mask = array_create(4);
		_buflen = _buflen + 4;
		if((_datalen > 0) && (_datalen < 126)) {
			_mask_length_bits = _datalen;
		} else if((_datalen > 125) && (_datalen <= 65535)) {
			_buflen = _buflen + 2;
			_mask_length_bits = $7E;
		} else if(_datalen > 65535) {
			_buflen = _buflen + 4;
			_mask_length_bits = $7F;
		}
	}
		
	var _buffer = buffer_create(_buflen, buffer_fixed, 1);
	buffer_write(_buffer, buffer_u8, $81); 
	buffer_write(_buffer, buffer_u8, $80 | _mask_length_bits); 
	if(_mask_length_bits == $7E) {
		// Network order WORD
		buffer_write(_buffer, buffer_u8, (_datalen & $FF)); 
		buffer_write(_buffer, buffer_u8, ((_datalen >> 8 ) & $FF)); 
	} else if(_mask_length_bits == $7F) {
		// Network order QWORD
		buffer_write(_buffer, buffer_u8, (_datalen & $FF)); 
		buffer_write(_buffer, buffer_u8, ((_datalen >> 8 ) & $FF)); 
		buffer_write(_buffer, buffer_u8, ((_datalen >> 16 ) & $FF)); 
		buffer_write(_buffer, buffer_u8, ((_datalen >> 24 ) & $FF)); 
	}
		
	if(_datalen > 0) {
		for(var _i=0; _i < 4; _i++) {
			_mask[_i] = irandom(255);
			buffer_write(_buffer, buffer_u8, _mask[_i]); 
		}

		var _byte_index, _masked_data, _mask_byte, _mask_index;
		for(var _i=0; _i < _datalen; _i++) {
			_mask_index = _i mod 4;
			_mask_byte = _mask[_mask_index];
			_byte_index = _i + 1;
			_masked_data = ord(string_char_at(_data, _byte_index));
			_masked_data = _masked_data ^ _mask_byte;
			buffer_write(_buffer, buffer_u8, _masked_data ); 
		}
	}
	
	return _buffer;
}


function hex(_str) {
    var _result = int64(0);
    
    // special unicode values
    static _zero = ord("0");
    static _nine = ord("9");
    static _a = ord("A");
    static _f = ord("F");
    
    for (var _i = 1; _i <= string_length(_str); _i++) {
        var _c = ord(string_char_at(string_upper(_str), _i));
        // you could also multiply by 16 but you get more nerd points for bitshifts
        _result = _result << 4;
        // if the character is a number or letter, add the value
        // it represents to the total
        if ((_c >= _zero) && (_c <= _nine)) {
            _result = _result + (_c - _zero);
        } else if ((_c >= _a) && (_c <= _f)) {
            _result = _result + ((_c - _a) + 10);
        // otherwise complain
        } else {
            throw "bad input for hex(str): " + _str;
        }
    }
    
    return _result;
}

function base_64_encode_hex(_hex_str) {
	var _i, _hex_byte, _hex_byte_str, _buf, _rval;
	var _sl = string_length(_hex_str);
	
	if((_sl	== 0) || (_sl mod 2) == 1) {
		throw "bad input for base_64_encode_hex: " + _hex_str;
	}
	

	_buf = buffer_create(_sl / 2, buffer_fixed, 1);
	
	for(_i = 0; _i < (_sl / 2); _i++) {
		_hex_byte_str = string_copy(_hex_str, (_i * 2) + 1, 2);
		_hex_byte = hex(_hex_byte_str);
		buffer_write(_buf, buffer_u8, _hex_byte);
	}
	
	_rval = buffer_base64_encode(_buf, 0, _sl /2);
	
	buffer_delete(_buf);
	
	return _rval;
}

function validate_nonce(_nonce) {
	var _i, _rval, _sha1, _buf;
	var _s = _nonce  + "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";
	var _sl = string_length(_s);

	_buf = buffer_create(_sl, buffer_fixed, 1);

	if(buffer_write(_buf, buffer_text, _s) == 0) {
		_sha1 = buffer_sha1(_buf, 0, _sl);
	} else {
		throw "Buffer write failed: " + _s;
	}
	
	_rval = base_64_encode_hex(_sha1);	
	
	buffer_delete(_buf);
	
	return _rval;
}

function make_nonce() {
	var _buf = buffer_create(16, buffer_fixed, 1);
	for(var _i = 0; _i < 16; _i++) {
		buffer_write(_buf, buffer_u8, irandom(255));
	}
	var _ret = buffer_base64_encode(_buf, 0, 16);
	buffer_delete(_buf);
	return _ret;
}

function url_encode(_orig) {
	var _new = "";
	var _char = 0;
	var _tmp = 0;
	var _ans = 0;
	var _ps = 0;
	for (_ps=1; _ps<=string_length(_orig); _ps+=1)
	    {
	    _char = string_char_at(_orig,_ps);
	    _char = ord(_char);
	    if (_char < 32) || (_char > 126) || (_char == 36) || (_char == 38) || (_char == 43) || (_char == 44) || (_char == 47) || (_char == 58) || (_char == 59) || (_char == 61) || (_char == 63) || (_char == 64) || (_char == 32) || (_char == 34) || (_char == 60) || (_char == 62) || (_char == 35) || (_char == 37) || (_char == 123) || (_char == 125) || (_char == 124) || (_char == 92) || (_char == 94) || (_char == 126) || (_char == 91) || (_char == 93) || (_char == 96)
	        {
	        _tmp = floor(_char/16);
	        _ans = _char-_tmp*16;
	        _tmp = string(_tmp);
	        if (_tmp = "10") _tmp = "A";
	        if (_tmp = "11") _tmp = "B";
	        if (_tmp = "12") _tmp = "C";
	        if (_tmp = "13") _tmp = "D";
	        if (_tmp = "14") _tmp = "E";
	        if (_tmp = "15") _tmp = "F";
	        _ans = string(_ans);
	        if (_ans = "10") _ans = "A";
	        if (_ans = "11") _ans = "B";
	        if (_ans = "12") _ans = "C";
	        if (_ans = "13") _ans = "D";
	        if (_ans = "14") _ans = "E";
	        if (_ans = "15") _ans = "F";
	        _new = _new+"%"+_tmp+_ans;
	        }
	    else
	        {
	        _new = _new+chr(_char);
	        }
	   }
	return _new;
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
		status = int64(_http_line[1]);
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
