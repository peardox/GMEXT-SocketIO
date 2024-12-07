/// @description Create EngineIO object
//

runlog("== EngineIO Create");
// feather ignore once GM1041
if(!is_instanceof(engine_io, SocketIO)) {
	throw("Bad EngineIO creation");
}
