`include "sqrt.v"
`timescale 1ns/1ns

module anfsqrt_sqrt_tb();
    reg [31:0] query;
    wire [15:0] result;

    anfsqrt_sqrt DUT (query, result);

    initial begin
        query = 18000000;
        #1 $display("Query: ", query, " Result:", result);
    end

endmodule