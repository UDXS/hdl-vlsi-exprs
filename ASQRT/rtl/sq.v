`include "msb.v"

module anfsqrt_sq
(
    input [31:0] n,
    output [31:0] res
);
    wire [4:0] n_exp;

    anfsqrt_msb curN (.n(n), .res(n_exp));

    wire [4:0] sq_exp;

    assign sq_exp = {n_exp, 1'b0};
    assign res = 1 << sq_exp;

endmodule