runlog("== EngineIO Create");
// wsr = -9; // Web Socket Request ID
// ws = -9; // Web Socket ID if upgraded
sid = ""; // Web Socket SID if not upgraded
status = "Created Object";
response = "<Empty>";
http_code = "N/A";
has_response = false;
response_struct = {};

counter = 0;
triggered_breakpoint = false;
once = false;


/*
url = "http://192.168.1.18:13378/socket.io/";
// Using socket.io so have to append the route
wsr = http_get(url+"?EIO=4&transport=polling");
// Go try getting a web socket
*/
socket = new EngineIO(url, port);
socket.connect();
socket.debug = true;
