`default_nettype none
`timescale 1ps/1ps

module scanline_streamer(
	input clk,
	
	input fifo_empty,
	input [159:0] scanline,
	output uart_tx,
	output reg fifo_ack
);

localparam STAGE_RESET = 1'b0;
localparam STAGE_TRANSFER = 1'b1;
 
reg [4:0] ctr;
reg [7:0] data;
reg stage;

reg transfer_req;
wire transfer_ready; 
 

uart_engine uart(
	.clk(clk),
	.data_in(data),
	.transfer_req(transfer_req),
	
	.uart_tx(uart_tx),
	.transfer_ready(transfer_ready)
);

always @(posedge clk) begin
	transfer_req <= 0;
	fifo_ack <= 0;
	
	case(stage)
		STAGE_RESET: begin
			
			if(!fifo_empty) begin
				ctr <= 5'd0;
				stage <= STAGE_TRANSFER;
			end
		end
		
		STAGE_TRANSFER: begin
			if(transfer_ready) begin
				ctr <= ctr + 5'd1;
				if(ctr == 19) begin
					fifo_ack <= 1;
					stage <= STAGE_RESET;
				end
				
				data <= scanline[ctr << 3 +: 8];
				transfer_req <= 1;
			end
		end
		
		
	endcase
		
end

initial begin
	ctr = 0;
	transfer_req = 0;
	fifo_ack = 0;
	stage = STAGE_RESET;
end

endmodule


module scanline_streamer_tb;

reg reset;
reg clk;
reg fifo_empty;
reg [159:0] scanline;
wire uart_tx;
wire fifo_ack;

	scanline_streamer streamer(
		.reset(reset),
		.clk(clk),
		.fifo_empty(fifo_empty),
		.scanline(scanline),
		.uart_tx(uart_tx),
		.fifo_ack(fifo_ack)
	);
	
	

always begin
	clk = 1'b1;
	#20;
	clk = 1'b0;
	#20;
	
	if (fifo_ack)
		fifo_empty <= 1;
end

initial begin
	fifo_empty = 1;
	#20;
	reset = 0;
	fifo_empty = 0;
	scanline = 160'h123456789012345678901234567890123456EFF0;
	
	
end


endmodule