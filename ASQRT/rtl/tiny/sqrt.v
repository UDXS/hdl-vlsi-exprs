/*
	Clocked SQRT Unit
	Copyright (C) 2022 Davit Margarian
*/

module anfsqrt_sqrt(
	input clk,
	input [6:0] query,
	output reg [6:0] result
);

	reg [6:0] att;
	reg [6:0] eps;
	reg [6:0] res;

	wire [6:0] att_next;
	wire [6:0] res_next;
	wire [6:0] eps_next;

	anfsqrt_sqrtiu iterator(.prev_att(att),
						.prev_eps(eps), 
						.prev_res(res),
						.this_att(att_next),
						.this_eps(eps_next),
						.this_res(res_next)
						);

	reg [2:0] iteration;
	
	always @(posedge clk) begin
		if (iteration != 7) begin
				att <= att_next;
				eps <= eps_next;
				res <= res_next;
				iteration <= iteration + 1;
			end else begin
				result <= res;
				eps <= query;
				att <= 1 << 4;
				res <= 0;
				iteration <= 0;
			end
	end
	

endmodule