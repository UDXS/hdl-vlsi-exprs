module anfsqrt_msb
(
    input [31:0] n,
    output reg[4:0] res
);
    integer i;

    always @* begin
        res = 0;
        for (i=0; i<32;i++) begin
			if(n == (1 << i)) res = i[4:0];
        end
    end

endmodule