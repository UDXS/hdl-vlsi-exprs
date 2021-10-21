`include "sqrtiu.v"
`timescale 1ns/1ns

module anfsqrt_sqrtiu_tb();
    reg clk;
    reg [31:0] cyc;

    reg [31:0] prev_att;
    reg [31:0] prev_eps;
    reg [31:0] prev_res;

    wire [31:0] this_att;
    wire [31:0] this_eps;
    wire [31:0] this_res;

    anfsqrt_sqrtiu DUT (prev_att, prev_eps, prev_res, this_att, this_eps, this_res);

    always @(posedge clk) begin
        $display("Cycle", cyc, " Attempting:", this_att, " Epsilon: ", this_eps, " Current Result:", this_res);
        prev_att <= this_att;
        prev_eps <= this_eps;
        prev_res <= this_res;
        cyc <= cyc + 1;
    end

    initial begin
        prev_att = 1 << 16;
        prev_eps = 256;
        prev_res = 0;
        clk = 0;
        cyc = 0;

        repeat (64) begin
        #1 clk = !clk;
        end
    end

endmodule