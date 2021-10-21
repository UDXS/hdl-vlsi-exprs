/*
ScreenPort Asterix is simple gateware for transfering
framebuffer data from the nRF52840DK board to a PC by
simulating the SHARP LS013B7DH05 Asterix devices are
based on.
When SCS is driven high, the 160 bits of scanline data
are read into a basic shift register. When this transfer
is completed, the data is committed to a small scanline FIFO.
This data is then committed to UART at 12 Mbaud.

*/


module top(input reset, input CLK12M, input DISP_SCS, input DISP_SCK, input DISP_MISO, output UART_TX);
	
	
	wire [159:0] scanline_in;
	wire [159:0] scanline_out;
	wire fifo_ack;
	wire fifo_write;
	wire fifo_empty;
	
	scanline_fifo fifo (
		.data(scanline_in),
		.rdclk(CLK12M),
		.rdreq(fifo_ack),
		.wrclk(DISP_SCK),
		.wrreq(fifo_write),
		.q(scanline_out),
		.rdempty(fifo_empty),
		.wrfull()
	);
	
	
	spi_reader reader(
		.scanline(scanline_in),
		.sl_write(fifo_write),
		.spi_cs(DISP_SCS),
		.spi_data(DISP_MISO),
		.spi_ck(DISP_SCK)
	);
	
	scanline_streamer streamer(
		.clk(CLK12M),
		.fifo_empty(fifo_empty),
		.scanline(scanline_out),
		.uart_tx(UART_TX),
		.fifo_ack(fifo_ack)
	);
	

endmodule