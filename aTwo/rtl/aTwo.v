/*
 *	UDXS "aTwo" Verilog Core
 *
 *	Implementing the "Amber II" ISA by NEON NIGHT 999
 */

`define SETUP_PARAM_MEMWRITE begin \
	r <= 0; \
	w <= 1; \
	mbus_addr <= mbus_rdat; \
end

`define SETUP_PARAM_MEMREAD begin \
	r <= 1; \
	w <= 0; \
	mbus_addr <= mbus_rdat; \
end

`define SETUP_PARAM_FETCH begin \
	stage <= STAGE_FETP; \
	`SETUP_PARAM_MEMREAD \
	mbus_addr <= ip + 1; \
	ip <= ip + 1; \
end

`define IF_EXEC if(stage == STAGE_EXEC)


module aTwo_core(
	input vdd,
	input gnd,
	input clk,
	input reset,
	input [7:0] iobus_i,
	output reg [7:0] iobus_o,
	input priv_mode,
	output reg [7:0] mbus_addr,
	input [7:0] mbus_rdat,
	output reg [7:0] mbus_wdat,
	output reg r,
	output reg w
);

	/*
		A simple Fetch-Execute-Writeback CPU

		Stages:
		Stage 0b00 - Fetch & Decode Instruction
		Stage 0b01 - Fetch Parameter Address (if memory-facing instruction)
		Srage 0b10 - Execute & Writeback
	*/

	localparam STAGE_FETCH = 2'b00;
	localparam STAGE_FETP = 2'b01;
	localparam STAGE_EXEC = 2'b10;
	reg [1:0] stage;
	reg [7:0] ip, ci;
	reg [7:0] RA, RB, RX, RY, A;

	always @(posedge clk) begin
		if(reset) begin
			ip <= 8'h00;
			ci = 8'h00;
			stage <= STAGE_FETCH;
		end

		if(stage == STAGE_FETCH) begin
			ci = mbus_rdat;
			stage <= STAGE_EXEC;
		end

		if(stage == STAGE_FETP) begin
			stage <= STAGE_EXEC;
		end

		if(stage == STAGE_EXEC) begin
			stage <= STAGE_FETCH;
			ip <= ip + 1;
			mbus_addr <= ip + 1;
		end

		r <= 0;
		w <= 0;

		case (ci[7:4])
			4'h0:	case(ci[3:0])
					4'h1: `IF_EXEC A <= RA + RB; // ADD
					4'h2: `IF_EXEC A <= RA - RB; // SUB
					4'h3: `IF_EXEC A <= RA & RB; // AND
					4'h4: `IF_EXEC A <= RA | RB; // OR
					4'h5: `IF_EXEC A <= RA ^ RB; // XOR
					4'h6: `IF_EXEC A <= ~RA; // NOA
					4'h7: `IF_EXEC A <= ~RB; // NOB
					4'h8: `IF_EXEC A <= RA + 1; // INA
					4'h9: `IF_EXEC A <= RB + 1; // INB
					4'hA: `IF_EXEC A <= RA - 1; // DEA
					4'hB: `IF_EXEC A <= RB - 1; // DEB
			endcase
			4'h1:	case(ci[3:0])
					4'h0: `IF_EXEC A <= {RA[6:0], 1'b0}; // LNA
					4'h1: `IF_EXEC A <= {1'b0, RA[7:1]}; // RNA
					4'h2: `IF_EXEC A <= {RA[6:0], RA[7]}; // LLA
					4'h3: `IF_EXEC A <= {RA[0], RA[7:1]}; // RLA
					4'h4: `IF_EXEC A <= {RB[6:0], 1'b0}; // LNB
					4'h5: `IF_EXEC A <= {1'b0, RB[7:1]}; // RNB
					4'h6: `IF_EXEC A <= {RB[6:0], RB[7]}; // LLB
					4'h7: `IF_EXEC A <= {RB[0], RB[7:1]}; // RLB
					// Missing MIA and MIB. It is undocumented.
			endcase
			4'h2:	case(ci[3:0])
				4'h0: `IF_EXEC iobus_o <= iobus_i; // TIO
				4'h1: `IF_EXEC iobus_o <= RX; // TXO
				4'h2: `IF_EXEC iobus_o <= RY; // TYO
				4'h3: `IF_EXEC iobus_o <= A; // TAO
				4'h4: `IF_EXEC RX <= iobus_i; // TIX
				4'h6: `IF_EXEC RX <= RY; // TYX
				4'h7: `IF_EXEC RX <= A; // TAX
				4'h8: `IF_EXEC RY <= iobus_i; // TIY
				4'h9: `IF_EXEC RY <= RX; // TXY
				4'hB: `IF_EXEC RY <= A; // TAY
				4'hC: `IF_EXEC A <= iobus_i; // TIA
				4'hD: `IF_EXEC A <= RX; // TXA
				4'hE: `IF_EXEC A <= RY; // TYA
			endcase
			4'h3: case(ci[3:0]) 
				4'h0: begin // TIM
					if(stage == STAGE_FETCH) `SETUP_PARAM_FETCH
					if(stage == STAGE_FETP) begin
						`SETUP_PARAM_MEMWRITE
						mbus_wdat <= iobus_i; 
					end
				end
				4'h1: begin // TXM
					if(stage == STAGE_FETCH) `SETUP_PARAM_FETCH
					if(stage == STAGE_FETP) begin
						`SETUP_PARAM_MEMWRITE
						mbus_wdat <= RX; 
					end
				end
				4'h2: begin // TYM
					if(stage == STAGE_FETCH) `SETUP_PARAM_FETCH
					if(stage == STAGE_FETP) begin
						`SETUP_PARAM_MEMWRITE
						mbus_wdat <= RY; 
					end
				end
				4'h3: begin // TAM
					if(stage == STAGE_FETCH) `SETUP_PARAM_FETCH
					if(stage == STAGE_FETP) begin
						`SETUP_PARAM_MEMWRITE
						mbus_wdat <= A; 
					end
				end
				4'h4: begin // TMO
					if(stage == STAGE_FETCH) `SETUP_PARAM_FETCH
					if(stage == STAGE_FETP) `SETUP_PARAM_MEMREAD
					if(stage == STAGE_EXEC) iobus_o <= mbus_rdat;
				end
				4'h5: begin // TMX
					if(stage == STAGE_FETCH) `SETUP_PARAM_FETCH
					if(stage == STAGE_FETP) `SETUP_PARAM_MEMREAD
					if(stage == STAGE_EXEC) RX <= mbus_rdat;
				end
				4'h6: begin // TMY
					if(stage == STAGE_FETCH) `SETUP_PARAM_FETCH
					if(stage == STAGE_FETP) `SETUP_PARAM_MEMREAD
					if(stage == STAGE_EXEC) RY <= mbus_rdat;
				end
				4'h7: begin // TMA
					if(stage == STAGE_FETCH) `SETUP_PARAM_FETCH
					if(stage == STAGE_FETP) `SETUP_PARAM_MEMREAD
					if(stage == STAGE_EXEC) A <= mbus_rdat;
				end
				4'h8: begin // DWO
					if(stage == STAGE_FETCH) begin
						`SETUP_PARAM_FETCH
						stage <= STAGE_EXEC;
					end
					if(stage == STAGE_EXEC) iobus_o <= mbus_rdat;
				end
				4'h9: begin // DWX
					if(stage == STAGE_FETCH) begin
						`SETUP_PARAM_FETCH
						stage <= STAGE_EXEC;
					end
					if(stage == STAGE_EXEC) RX <= mbus_rdat;
				end
				4'hA: begin // DWY
					if(stage == STAGE_FETCH) begin
						`SETUP_PARAM_FETCH
						stage <= STAGE_EXEC;
					end
					if(stage == STAGE_EXEC) RY <= mbus_rdat;
				end
				4'hB: begin // DWA
					if(stage == STAGE_FETCH) begin
						`SETUP_PARAM_FETCH
						stage <= STAGE_EXEC;
					end
					if(stage == STAGE_EXEC) A <= mbus_rdat;
				end
				4'hC: begin // JPM
					if(stage == STAGE_FETCH) `SETUP_PARAM_FETCH
					if(stage == STAGE_FETP) `SETUP_PARAM_MEMREAD
					if(stage == STAGE_EXEC) ip <= mbus_rdat;
				end
				4'hD: begin // JPD
					if(stage == STAGE_FETCH) begin
						`SETUP_PARAM_FETCH
						stage <= STAGE_EXEC;
					end
					if(stage == STAGE_EXEC) ip <= mbus_rdat;
				end
			endcase
			4'h4:  case(ci[3:0])
				4'h0: `IF_EXEC RA <= iobus_i; // RAI
				4'h1: `IF_EXEC RA <= RX; // RAX
				4'h2: `IF_EXEC RA <= RY; // RAY
				4'h3: `IF_EXEC RA <= A; // RAA
				4'h4: `IF_EXEC RB <= iobus_i; // RBI
				4'h5: `IF_EXEC RB <= RX; // RBX
				4'h6: `IF_EXEC RB <= RY; // RBY
				4'h7: `IF_EXEC RB <= A; // RBA
				4'h8: begin // RAM
					if(stage == STAGE_FETCH) `SETUP_PARAM_FETCH
					if(stage == STAGE_FETP) `SETUP_PARAM_MEMREAD
					if(stage == STAGE_EXEC) RA <= mbus_rdat;
				end
				4'h9: begin // RBM
					if(stage == STAGE_FETCH) `SETUP_PARAM_FETCH
					if(stage == STAGE_FETP) `SETUP_PARAM_MEMREAD
					if(stage == STAGE_EXEC) RB <= mbus_rdat;
				end
				4'hA: begin // RAD
					if(stage == STAGE_FETCH) begin
						`SETUP_PARAM_FETCH
						stage <= STAGE_EXEC;
					end
					if(stage == STAGE_EXEC) RA <= mbus_rdat;
				end
				4'hB: begin // RBD
					if(stage == STAGE_FETCH) begin
						`SETUP_PARAM_FETCH
						stage <= STAGE_EXEC;
					end
					if(stage == STAGE_EXEC) RB <= mbus_rdat;
				end
				4'hC: `IF_EXEC ip <= iobus_i; // JPI
				4'hD: `IF_EXEC ip <= RX; // JPX
				4'hE: `IF_EXEC ip <= RY; // JPY
				4'hF: `IF_EXEC ip <= A; // JPA
			endcase
		endcase
	end

endmodule