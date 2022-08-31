/*
	Clocked SQRT Unit
	Copyright (C) 2022 Davit Margarian
*/

module anfsqrt_sqrt(
	input reset,
	input clk,
	input [31:0] query,
	output reg query_ready,
	input query_valid,
	output reg [15:0] result,
	output reg result_valid
);

	reg [31:0] att;
	reg [31:0] res;
	reg [31:0] eps;

	wire [31:0] att_next;
	wire [31:0] res_next;
	wire [31:0] eps_next;

	anfsqrt_sqrtiu iterator(.prev_att(att),
						.prev_eps(eps), 
						.prev_res(res),
						.this_att(att_next),
						.this_eps(eps_next),
						.this_res(res_next)
						);

	localparam STATE_RESET = 2'b00;
	localparam STATE_PERFORM = 2'b01;
	localparam STATE_FINALIZE = 2'b10;

	reg [1:0] state;
	reg [4:0] iteration;
	
	always @(posedge clk) begin
		if(reset) begin
			state <= STATE_RESET;
			query_ready <= 1;
			result_valid <= 0;
		end else begin
			case (state)
				STATE_RESET: begin
					result_valid <= 0;
					if(query_valid) begin
						state <= STATE_PERFORM;
						res <= 0;
						eps <= query;
						att <= 1 << 15;
						iteration <= 0;
						query_ready <= 0;
					end
				end
				STATE_PERFORM: begin
				if (iteration != 16 && eps != 0) begin
						att <= att_next;
						eps <= eps_next;
						res <= res_next;
						iteration <= iteration + 1;
					end else begin
						result <= res;
						result_valid <= 1;
						state <= STATE_FINALIZE;
					end
				end
				STATE_FINALIZE: begin
					result_valid <= 0;
					query_ready <= 1;
					state <= STATE_RESET;
				end
			endcase
		end
	end
	

endmodule