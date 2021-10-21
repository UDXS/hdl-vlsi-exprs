const SerialPort = require("serialport");
const fs = require("fs");

let data = Buffer.alloc(0);

const port = new SerialPort("COM8", {
	baudRate: 12000000,

}, () => console.log("port init"));
let cnt = 0;

port.on("data", (buf) => {
	data = Buffer.concat([data, buf]);
	if (data.byteLength >= 20 * 168) {
		data = data.subarray(0, 20 * 168);
		fs.writeFileSync("screen.bin", data, {encoding: "binary"});
		console.log("buffer write complete.");
		throw "BufferWriteComplete";

	}
});