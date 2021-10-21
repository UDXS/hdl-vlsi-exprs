`include "sqrtiu.v"

module anfsqrt_sqrt(
    input [31:0] query,
    output [15:0] result
);

    wire [31:0] att [0:32];
    wire [31:0] res [0:32];
    wire [31:0] eps [0:32];

    assign att[0] = 65536;
    assign res[0] = 0;
    assign eps[0] = query;

    genvar i;

    generate
        for(i=1; i <= 32; i = i + 1) begin
            anfsqrt_sqrtiu unit(.prev_att(att[i-1]),
                                .prev_eps(eps[i-1]), 
                                .prev_res(res[i-1]),
                                .this_att(att[i]),
                                .this_eps(eps[i]),
                                .this_res(res[i])
                                );
        end
    endgenerate

    assign result = res[32];

endmodule