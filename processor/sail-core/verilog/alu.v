`include "../include/rv32i-defines.v"
`include "../include/sail-core-defines.v"

/*
 *	Not all instructions are fed to the ALU. As a result, the ALUctl
 *	field is only unique across the instructions that are actually
 *	fed to the ALU.
 */
module alu(ALUctl, A, B, ALUOut, ALUEnable, Branch_Enable);
	input [6:0]		ALUctl;
	input [31:0]		A;
	input [31:0]		B;
	input ALUEnable;
	output reg [31:0]	ALUOut;
	output reg		Branch_Enable;

	initial begin
		ALUOut = 32'b0;
		Branch_Enable = 1'b0;
	end

	wire [31:0] opa = A & {32{ALUEnable}};
	wire [31:0] opb = B & {32{ALUEnable}};

	always @(ALUctl, opa, opb) begin
		case (ALUctl[3:0])
			/*
			 *	AND (the fields also match ANDI and LUI)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_AND:	ALUOut = opa & opb;

			/*
			 *	OR (the fields also match ORI)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_OR:	ALUOut = opa | opb;

			/*
			 *	ADD (the fields also match AUIPC, all loads, all stores, and ADDI)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_ADD:	ALUOut = opa + opb;

			/*
			 *	SUBTRACT (the fields also matches all branches)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SUB:	ALUOut = opa - opb;

			/*
			 *	SLT (the fields also matches all the other SLT variants)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLT:	ALUOut = $signed(opa) < $signed(opb) ? 32'b1 : 32'b0;

			/*
			 *	SRL (the fields also matches the other SRL variants)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRL:	ALUOut = opa >> opb[4:0];

			/*
			 *	SRA (the fields also matches the other SRA variants)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRA:	ALUOut = $signed(opa) >>> opb[4:0];

			/*
			 *	SLL (the fields also match the other SLL variants)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLL:	ALUOut = opa << opb[4:0];

			/*
			 *	XOR (the fields also match other XOR variants)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_XOR:	ALUOut = opa ^ opb;

			/*
			 *	CSRRW  only
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRW:	ALUOut = opa;

			/*
			 *	CSRRS only
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRS:	ALUOut = opa | opb;

			/*
			 *	CSRRC only
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRC:	ALUOut = (~opa) & opb;

			/*
			 *	Should never happen.
			 */
			default:					ALUOut = 0;
		endcase
	end

	always @(ALUctl, ALUOut, opa, opb) begin
		case (ALUctl[6:4])
			`kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BEQ:	Branch_Enable = (ALUOut == 0);
			`kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BNE:	Branch_Enable = !(ALUOut == 0);
			`kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BLT:	Branch_Enable = ($signed(opa) < $signed(opb));
			`kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BGE:	Branch_Enable = ($signed(opa) >= $signed(opb));
			`kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BLTU:	Branch_Enable = ($unsigned(opa) < $unsigned(opb));
			`kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BGEU:	Branch_Enable = ($unsigned(opa) >= $unsigned(opb));

			default:					Branch_Enable = 1'b0;
		endcase
	end
endmodule
