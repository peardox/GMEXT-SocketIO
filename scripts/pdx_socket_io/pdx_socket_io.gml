function SocketIOMessage(_type, _message) constructor {
	self.message_type = int64(0);
	self.message_text = "";
	
	if((typeof(_type) == "int64") && (typeof(_message) == "string")) {
		message_type = int64(_type);
		message_text = _message;
	}
}

function SocketIO(_url, _port, _scheme = "http", _path = "/socket.io/", _transport = "polling") :
		 EngineIO(_url, _port, _scheme, _path, _transport) constructor {
			 
	inherited = {};
	// feather disable GM2043
	inherited.emit = emit;
	// feather enable GM2043


}