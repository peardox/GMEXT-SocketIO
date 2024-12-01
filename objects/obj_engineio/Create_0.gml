runlog("== EngineIO Create");
// wsr = -9; // Web Socket Request ID
// ws = -9; // Web Socket ID if upgraded
/*sid = ""; // Web Socket SID if not upgraded
status = "Created Object";
response = "<Empty>";
http_code = "N/A";
has_response = false;
response_struct = {};

counter = 0;
triggered_breakpoint = false;
once = false;
*/

show_debug_message("========>" + typeof(self));
if(!is_instanceof(io, EngineIO)) {
	throw("Bad EngineIO creation");
}
