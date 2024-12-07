GMEXT-SocketIO

This repo partially re-creates the socket.io protocol

It currently allows long-polling but breaks then the socket is upgraded to a websocket owing to Gamemaker sending an unsolicited Websockets Continuation Frame

If GM didn't send this frame then the upgrade could be completed successfully and work could proceed on implementing the rest of the socket.io protocol.

Websockets are fairly essential to the functioning of this project as long-polling sends a lot of irrelevant data and is limited in the types of data it can send. Websockets, on the other hand, can send both text and binary data and has minimal overhead.

As the socket.io protocol is in high use by web programmers using node as well as a mature and stable message-passing system it is desirable to have it available for one's own projects.

Some useful examples of what sockets.io would provide would be chat systems (your own Chat / micro-Discord, Lobbys etc), data passing for Multi-Player games and Binary package delivery for seamless project updates

