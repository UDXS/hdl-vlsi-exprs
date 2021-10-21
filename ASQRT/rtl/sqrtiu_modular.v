`include "sq.v"
/*
    SQRT Iteration Unit
    This unit makes a single attempt at iterating the square root.
    This works like the contents of the 'while' loop inside src/algo.js.
    
    SQRTIUs operate combinationally and thus can be chained together and controlled by a clocked dispatcher.
    This allows a choice between large/single-cycle, compact/variable-cycle, or a balance. 
	It is also possible to use fewer cycles by starting at the MSB of the argument.
	Alternatively, it is may be possible to operate with an "epsilon threshold" that reduces cycle count by lowering precision.

    An SQRTIU takes the attempted value of the previous iteration, the epsilon of the previous iteration, and the result of the previous iteration.
    It outputs the same information but for the current iteration.
*/

module anfsqrt_sqrtiu (
    input [31:0] prev_att,
    input [31:0] prev_eps,
    input [31:0] prev_res,

    output [31:0] this_att,
    output [31:0] this_eps,
    output [31:0] this_res
);

    assign this_att = {1'b0, prev_att[31:1]};

	wire [31:0] this_delta_term1_half;
	wire [31:0] this_delta;
	wire [31:0] this_att_sq;
	wire [4:0] this_att_msb;

	anfsqrt_sq att_sq_unit (.n(this_att), .res(this_att_sq));
	anfsqrt_msb att_msb_unit (.n(this_att), .res(this_att_msb));

	assign this_delta_term1_half = prev_res << this_att_msb;
	assign this_delta = {this_delta_term1_half[30:0], 1'b0} + this_att_sq;

	wire cond_met;
	assign cond_met = this_delta <= prev_eps;
	assign this_eps = cond_met ? prev_eps - this_delta : prev_eps; 
	assign this_res = cond_met ? prev_res | this_att : prev_res; 

endmodule