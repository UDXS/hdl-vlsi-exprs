/*
UART Byte Transfer Engine

A UART byte transmission is done like so:

By default, the TX line is held high.
When transmitting, the line is held low
for one cycle (this is the start bit).

Then, each bit is transferred cycle-by-cycle
in a little endian format, from LSB to MSB 
with 0 being low and 1 being high.

Finally, the line is held high for 1 cycle
to indicate "stop". Another byte can be
transferred next cycle. 


Transferring a byte can be done by putting it
in data_in and then pulsing transfer_req when
transfer_ready is high.
At this point, the byte is committed to the
engine's buffer, so you can queue up another
byte in data_in as soon as needed though
precaution should be taken not to pulse
transfer_req until transfer_ready is high.
*/

`default_nettype none
`timescale 1ps/1ps

module uart_engine(
	input clk,
	input [7:0] data_in,
	input transfer_req,
	
	output reg uart_tx,
	output reg transfer_ready
);
	
	localparam STAGE_RESET = 2'b00;
	localparam STAGE_BIT_TRANSFER = 2'b01;
	localparam STAGE_STOP = 2'b10;
	
	reg [2:0] stage;
	reg [2:0] ctr;
	reg [7:0] data;
	
	always @(posedge clk) begin
		if(transfer_req) begin
			uart_tx <= 0; // start bit
			data <= data_in;
			
			transfer_ready <= 0;
			stage <= STAGE_BIT_TRANSFER;
			ctr <= 0;
		end

		case(stage)
			STAGE_BIT_TRANSFER: begin
				uart_tx <= data[ctr];
				ctr <= ctr + 3'd1;
				if(ctr == 7)
					stage <= STAGE_STOP;
			end
			
			STAGE_STOP: begin
				uart_tx <= 1;
				transfer_ready <= 1;
				stage <= STAGE_RESET;
			end
			default:;
		endcase
			
		
	end
	
	initial begin
		uart_tx = 1;
		transfer_ready = 1;
		stage = STAGE_RESET;
	end
	
endmodule


module uart_tb;

	reg reset;
	reg clk;
	wire uart_tx;
	reg [7:0] data;
	wire transfer_ready;
	reg transfer_req;

	uart_engine engine(
		.reset(reset),
		.clk(clk),
		.data_in(data),
		.transfer_req(transfer_req),
	
		.uart_tx(uart_tx),
		.transfer_ready(transfer_ready)
	);

	always begin
		clk = 1'b1;
		#20;
		
		clk = 1'b0;
		#20;
	end
	
	initial begin
		#20;
		data = 8'b11011010;
		
		transfer_req = 1;
		#40;
		transfer_req = 0;
		#(40*10)
		
		data = 8'b01011110;
		
		transfer_req = 1;
		#40;
		transfer_req = 0;
	end

endmodule