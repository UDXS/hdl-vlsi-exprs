`default_nettype none


module spi_reader(
	output reg [159:0] scanline,
	output reg sl_write,
	input spi_cs,
	input spi_data,
	input spi_ck
);


localparam LEN_COMMAND = 8'd8;
localparam LEN_LINEADDR = 8'd8;
localparam LEN_PIXELDATA = 8'd144;
localparam LEN_SCANLINE_ONLY = LEN_LINEADDR + LEN_PIXELDATA;
localparam LEN_SCANLINE_COMMAND = LEN_COMMAND + LEN_SCANLINE_ONLY;
localparam LEN_DATA_WRITE = 8'd16;

localparam STAGE_RESET = 2'b00;
localparam STAGE_COMMAND_SCANLINE = 2'b01;
localparam STAGE_SCANLINE_ONLY = 2'b10;
localparam STAGE_DATA_WRITE_PERIOD = 2'b11;

reg [1:0] stage;
reg [7:0] ctr;
reg data_write_period;
reg prev_cs;


always @(posedge spi_ck) begin
	prev_cs <= spi_cs;
	sl_write <= 0;
	
	if(!spi_cs) begin
		stage <= STAGE_RESET;
	end
	
	if(spi_cs && spi_cs != prev_cs) begin
		stage <= STAGE_COMMAND_SCANLINE;
		ctr <= 0;
	end

	ctr <= ctr + 8'd1;
	
	case(stage)
		STAGE_COMMAND_SCANLINE: begin
			scanline[ctr] <= spi_data;			
			if(ctr == LEN_SCANLINE_COMMAND-1) begin
				stage <= STAGE_DATA_WRITE_PERIOD;
				sl_write <= 1;
				ctr <= 0;
			end
		end
		
		STAGE_SCANLINE_ONLY: begin
			scanline[ctr] <= spi_data;			
			if(ctr == LEN_SCANLINE_ONLY-1) begin
				stage <= STAGE_DATA_WRITE_PERIOD;
				sl_write <= 1;
				ctr <= 0;
			end
		end
		
		STAGE_DATA_WRITE_PERIOD: begin
			if(ctr == LEN_DATA_WRITE-1) begin
				stage <= STAGE_SCANLINE_ONLY;
				ctr <= 0;
			end
		end
		
		default:;
	endcase
	
end

initial begin
	prev_cs = 0;
	stage = STAGE_RESET;
end


endmodule