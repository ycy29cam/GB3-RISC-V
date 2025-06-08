module adder(input1, input2, out);
	input [31:0]	input1;
	input [31:0]	input2;
	output [31:0]	out;

	assign		out = input1 + input2;
endmodule

/* ALU Control */
`include "../include/rv32i-defines.v"
`include "../include/sail-core-defines.v"

module ALUControl(FuncCode, ALUCtl, Opcode);
	input [3:0]		FuncCode;
	input [6:0]		Opcode;
	output reg [6:0]	ALUCtl;

	initial begin
		ALUCtl = 7'b0;
	end

	/*
	 *	TODO:
	 *
	 *	(1) Please replace the values being assigned to ALUCtl with the corresponding `defines in sail-core-defines.v
	 *	(2) Please replace the FuncCode constants with the corresponding `defines in sail-core-defines.v
	 */

	always @(*) begin
		case (Opcode)
			/*
			 *	LUI, U-Type
			 */
			`kRV32I_INSTRUCTION_OPCODE_LUI:
				ALUCtl = 7'b0000010;

			/*
			 *	AUIPC, U-Type
			 */
			`kRV32I_INSTRUCTION_OPCODE_AUIPC:
				ALUCtl = 7'b0000010;

			/*
			 *	JAL, UJ-Type
			 */
			`kRV32I_INSTRUCTION_OPCODE_JAL:
				ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;

			/*
			 *	JALR, I-Type
			 */
			`kRV32I_INSTRUCTION_OPCODE_JALR:
				ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;

			/*
			 *	Branch, SB-Type
			 */
			`kRV32I_INSTRUCTION_OPCODE_BRANCH:
				case (FuncCode[2:0])
					3'b000:
						ALUCtl = 7'b0010110; //BEQ conditions
					3'b001:
						ALUCtl = 7'b0100110; //BNE conditions
					3'b100:
						ALUCtl = 7'b0110110; //BLT conditions
					3'b101:
						ALUCtl = 7'b1000110; //BGE conditions
					3'b110:
						ALUCtl = 7'b1010110; //BLTU conditions
					3'b111:
						ALUCtl = 7'b1100110; //BGEU conditions
					default:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
				endcase

			/*
			 *	Loads, I-Type
			 */
			`kRV32I_INSTRUCTION_OPCODE_LOAD:
				case (FuncCode[2:0])
					3'b000:
						ALUCtl = 7'b0000010; //LB
					3'b001:
						ALUCtl = 7'b0000010; //LH
					3'b010:
						ALUCtl = 7'b0000010; //LW
					3'b100:
						ALUCtl = 7'b0000010; //LBU
					3'b101:
						ALUCtl = 7'b0000010; //LHU
					default:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
				endcase

			/*
			 *	Stores, S-Type
			 */
			`kRV32I_INSTRUCTION_OPCODE_STORE:
				case (FuncCode[2:0])
					3'b000:
						ALUCtl = 7'b0000010; //SB
					3'b001:
						ALUCtl = 7'b0000010; //SH
					3'b010:
						ALUCtl = 7'b0000010; //SW
					default:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
				endcase

			/*
			 *	Immediate operations, I-Type
			 */
			`kRV32I_INSTRUCTION_OPCODE_IMMOP:
				case (FuncCode[2:0])
					3'b000:
						ALUCtl = 7'b0000010; //ADDI
					3'b010:
						ALUCtl = 7'b0000111; //SLTI
					3'b011:
						ALUCtl = 7'b0000111; //SLTIU
					3'b100:
						ALUCtl = 7'b0001000; //XORI
					3'b110:
						ALUCtl = 7'b0000001; //ORI
					3'b111:
						ALUCtl = 7'b0000000; //ANDI
					3'b001:
						ALUCtl = 7'b0000101; //SLLI
					3'b101:
						case (FuncCode[3])
							1'b0:
								ALUCtl = 7'b0000011; //SRLI
							1'b1:
								ALUCtl = 7'b0000100; //SRAI
							default:
								ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
						endcase
					default:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
				endcase

			/*
			 *	ADD SUB & logic shifts, R-Type
			 */
			`kRV32I_INSTRUCTION_OPCODE_ALUOP:
				case (FuncCode[2:0])
					3'b000:
						case(FuncCode[3])
							1'b0:
								ALUCtl = 7'b0000010; //ADD
							1'b1:
								ALUCtl = 7'b0000110; //SUB
							default:
								ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
						endcase
					3'b001:
						ALUCtl = 7'b0000101; //SLL
					3'b010:
						ALUCtl = 7'b0000111; //SLT
					3'b011:
						ALUCtl = 7'b0000111; //SLTU
					3'b100:
						ALUCtl = 7'b0001000; //XOR
					3'b101:
						case(FuncCode[3])
							1'b0:
								ALUCtl = 7'b0000011; //SRL
							1'b1:
								ALUCtl = 7'b0000100; //SRA untested
							default:
								ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
						endcase
					3'b110:
						ALUCtl = 7'b0000001; //OR
					3'b111:
						ALUCtl = 7'b0000000; //AND
					default:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
				endcase

			`kRV32I_INSTRUCTION_OPCODE_CSRR:
				case (FuncCode[1:0]) //use lower 2 bits of FuncCode to determine operation
					2'b01:
						ALUCtl = 7'b0001001; //CSRRW
					2'b10:
						ALUCtl = 7'b0001010; //CSRRS
					2'b11:
						ALUCtl = 7'b0001011; //CSRRC
					default:
						ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
				endcase

			default:
				ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
		endcase
	end
endmodule

/* ALU */
`include "../include/rv32i-defines.v"
`include "../include/sail-core-defines.v"

/*
 *	Not all instructions are fed to the ALU. As a result, the ALUctl
 *	field is only unique across the instructions that are actually
 *	fed to the ALU.
 */
module alu(ALUctl, A, B, ALUOut, Branch_Enable);
	input [6:0]		ALUctl;
	input [31:0]		A;
	input [31:0]		B;
	output reg [31:0]	ALUOut;
	output reg		Branch_Enable;

	initial begin
		ALUOut = 32'b0;
		Branch_Enable = 1'b0;
	end

	always @(ALUctl, A, B) begin
		case (ALUctl[3:0])
			/*
			 *	AND (the fields also match ANDI and LUI)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_AND:	ALUOut = A & B;

			/*
			 *	OR (the fields also match ORI)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_OR:	ALUOut = A | B;

			/*
			 *	ADD (the fields also match AUIPC, all loads, all stores, and ADDI)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_ADD:	ALUOut = A + B;

			/*
			 *	SUBTRACT (the fields also matches all branches)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SUB:	ALUOut = A - B;

			/*
			 *	SLT (the fields also matches all the other SLT variants)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLT:	ALUOut = $signed(A) < $signed(B) ? 32'b1 : 32'b0;

			/*
			 *	SRL (the fields also matches the other SRL variants)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRL:	ALUOut = A >> B[4:0];

			/*
			 *	SRA (the fields also matches the other SRA variants)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRA:	ALUOut = $signed(A) >>> B[4:0];

			/*
			 *	SLL (the fields also match the other SLL variants)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLL:	ALUOut = A << B[4:0];

			/*
			 *	XOR (the fields also match other XOR variants)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_XOR:	ALUOut = A ^ B;

			/*
			 *	CSRRW  only
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRW:	ALUOut = A;

			/*
			 *	CSRRS only
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRS:	ALUOut = A | B;

			/*
			 *	CSRRC only
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRC:	ALUOut = (~A) & B;

			/*
			 *	Should never happen.
			 */
			default:					ALUOut = 0;
		endcase
	end

	always @(ALUctl, ALUOut, A, B) begin
		case (ALUctl[6:4])
			`kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BEQ:	Branch_Enable = (ALUOut == 0);
			`kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BNE:	Branch_Enable = !(ALUOut == 0);
			`kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BLT:	Branch_Enable = ($signed(A) < $signed(B));
			`kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BGE:	Branch_Enable = ($signed(A) >= $signed(B));
			`kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BLTU:	Branch_Enable = ($unsigned(A) < $unsigned(B));
			`kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BGEU:	Branch_Enable = ($unsigned(A) >= $unsigned(B));

			default:					Branch_Enable = 1'b0;
		endcase
	end
endmodule

module branch_decision (Branch, Predicted, Branch_Enable, Jump, Mispredict, Decision, Branch_Jump_Trigger);
	input	Branch;
	input	Predicted;
	input	Branch_Enable;
	input	Jump;
	output	Mispredict;
	output	Decision;
	output	Branch_Jump_Trigger;

	assign	Branch_Jump_Trigger	= ((!Predicted) & (Branch & Branch_Enable)) | Jump;
	assign	Decision		= (Branch & Branch_Enable);
	assign	Mispredict		= (Predicted & (!(Branch & Branch_Enable)));
endmodule

module branch_predictor(
		clk,
		actual_branch_decision,
		branch_decode_sig,
		branch_mem_sig,
		in_addr,
		offset,
		branch_addr,
		prediction
	);

	/*
	 *	inputs
	 */
	input		clk;
	input		actual_branch_decision;
	input		branch_decode_sig;
	input		branch_mem_sig;
	input [31:0]	in_addr;
	input [31:0]	offset;

	/*
	 *	outputs
	 */
	output [31:0]	branch_addr;
	output		prediction;

	/*
	 *	internal state
	 */
	reg [1:0]	s;

	reg		branch_mem_sig_reg;

	/*
	 *	The `initial` statement below uses Yosys's support for nonzero
	 *	initial values:
	 *
	 *		https://github.com/YosysHQ/yosys/commit/0793f1b196df536975a044a4ce53025c81d00c7f
	 *
	 *	Rather than using this simulation construct (`initial`),
	 *	the design should instead use a reset signal going to
	 *	modules in the design and to thereby set the values.
	 */
	initial begin
		s = 2'b00;
		branch_mem_sig_reg = 1'b0;
	end

	always @(negedge clk) begin
		branch_mem_sig_reg <= branch_mem_sig;
	end

	/*
	 *	Using this microarchitecture, branches can't occur consecutively
	 *	therefore can use branch_mem_sig as every branch is followed by
	 *	a bubble, so a 0 to 1 transition
	 */
	always @(posedge clk) begin
		if (branch_mem_sig_reg) begin
			s[1] <= (s[1]&s[0]) | (s[0]&actual_branch_decision) | (s[1]&actual_branch_decision);
			s[0] <= (s[1]&(!s[0])) | ((!s[0])&actual_branch_decision) | (s[1]&actual_branch_decision);
		end
	end

	assign branch_addr = in_addr + offset;
	assign prediction = s[1] & branch_decode_sig;
endmodule

module control(
		opcode,
		MemtoReg,
		RegWrite,
		MemWrite,
		MemRead,
		Branch,
		ALUSrc,
		Jump,
		Jalr,
		Lui,
		Auipc,
		Fence,
		CSRR
	);

	input	[6:0] opcode;
	output	MemtoReg, RegWrite, MemWrite, MemRead, Branch, ALUSrc, Jump, Jalr, Lui, Auipc, Fence, CSRR;

	assign MemtoReg = (~opcode[5]) & (~opcode[4]) & (~opcode[3]) & (opcode[0]);
	assign RegWrite = ((~(opcode[4] | opcode[5])) | opcode[2] | opcode[4]) & opcode[0];
	assign MemWrite = (~opcode[6]) & (opcode[5]) & (~opcode[4]);
	assign MemRead = (~opcode[5]) & (~opcode[4]) & (~opcode[3]) & (opcode[1]);
	assign Branch = (opcode[6]) & (~opcode[4]) & (~opcode[2]);
	assign ALUSrc = ~(opcode[6] | opcode[4]) | (~opcode[5]);
	assign Jump = (opcode[6]) & (opcode[5]) & (~opcode[4]) & (opcode[2]);
	assign Jalr = (opcode[6]) & (opcode[5]) & (~opcode[4]) & (~opcode[3]) & (opcode[2]);
	assign Lui = (~opcode[6]) & (opcode[5]) & (opcode[4]) & (~opcode[3]) & (opcode[2]);
	assign Auipc = (~opcode[6]) & (~opcode[5]) & (opcode[4]) & (~opcode[3]) & (opcode[2]);
	assign Fence = (~opcode[5]) & opcode[3] & (opcode[2]);
	assign CSRR = (opcode[6]) & (opcode[4]);
endmodule

module csr_file (clk, write, wrAddr_CSR, wrVal_CSR, rdAddr_CSR, rdVal_CSR);
	input clk;
	input write;
	input [11:0] wrAddr_CSR;
	input [31:0] wrVal_CSR;
	input [11:0] rdAddr_CSR;
	output reg[31:0] rdVal_CSR;

	reg [31:0] csr_file [0:2**10-1];

	always @(posedge clk) begin
		if (write) begin
			csr_file[wrAddr_CSR] <= wrVal_CSR;
		end
		rdVal_CSR <= csr_file[rdAddr_CSR];
	end

endmodule

module data_mem (clk, addr, write_data, memwrite, memread, sign_mask, read_data, led, clk_stall);
	input			clk;
	input [31:0]		addr;
	input [31:0]		write_data;
	input			memwrite;
	input			memread;
	input [3:0]		sign_mask;
	output reg [31:0]	read_data;
	output [7:0]		led;
	output reg		clk_stall;	//Sets the clock high

	/*
	 *	led register
	 */
	reg [31:0]		led_reg;

	/*
	 *	Current state
	 */
	integer			state = 0;

	/*
	 *	Possible states
	 */
	parameter		IDLE = 0;
	parameter		READ_BUFFER = 1;
	parameter		READ = 2;
	parameter		WRITE = 3;

	/*
	 *	Line buffer
	 */
	reg [31:0]		word_buf;

	/*
	 *	Read buffer
	 */
	wire [31:0]		read_buf;

	/*
	 *	Buffer to identify read or write operation
	 */
	reg			memread_buf;
	reg			memwrite_buf;

	/*
	 *	Buffers to store write data
	 */
	reg [31:0]		write_data_buffer;

	/*
	 *	Buffer to store address
	 */
	reg [31:0]		addr_buf;

	/*
	 *	Sign_mask buffer
	 */
	reg [3:0]		sign_mask_buf;

	/*
	 *	Block memory registers
	 *
	 *	(Bad practice: The constant for the size should be a `define).
	 */
	reg [31:0]		data_block[0:1023];

	/*
	 *	wire assignments
	 */
	wire [9:0]		addr_buf_block_addr;
	wire [1:0]		addr_buf_byte_offset;

	wire [31:0]		replacement_word;

	assign			addr_buf_block_addr	= addr_buf[11:2];
	assign			addr_buf_byte_offset	= addr_buf[1:0];

	/*
	 *	Regs for multiplexer output
	 */
	wire [7:0]		buf0;
	wire [7:0]		buf1;
	wire [7:0]		buf2;
	wire [7:0]		buf3;

	assign 			buf0	= word_buf[7:0];
	assign 			buf1	= word_buf[15:8];
	assign 			buf2	= word_buf[23:16];
	assign 			buf3	= word_buf[31:24];

	/*
	 *	Byte select decoder
	 */
	wire bdec_sig0;
	wire bdec_sig1;
	wire bdec_sig2;
	wire bdec_sig3;

	assign bdec_sig0 = (~addr_buf_byte_offset[1]) & (~addr_buf_byte_offset[0]);
	assign bdec_sig1 = (~addr_buf_byte_offset[1]) & (addr_buf_byte_offset[0]);
	assign bdec_sig2 = (addr_buf_byte_offset[1]) & (~addr_buf_byte_offset[0]);
	assign bdec_sig3 = (addr_buf_byte_offset[1]) & (addr_buf_byte_offset[0]);


	/*
	 *	Constructing the word to be replaced for write byte
	 */
	wire[7:0] byte_r0;
	wire[7:0] byte_r1;
	wire[7:0] byte_r2;
	wire[7:0] byte_r3;

	assign byte_r0 = (bdec_sig0==1'b1) ? write_data_buffer[7:0] : buf0;
	assign byte_r1 = (bdec_sig1==1'b1) ? write_data_buffer[7:0] : buf1;
	assign byte_r2 = (bdec_sig2==1'b1) ? write_data_buffer[7:0] : buf2;
	assign byte_r3 = (bdec_sig3==1'b1) ? write_data_buffer[7:0] : buf3;

	/*
	 *	For write halfword
	 */
	wire[15:0] halfword_r0;
	wire[15:0] halfword_r1;

	assign halfword_r0 = (addr_buf_byte_offset[1]==1'b1) ? {buf1, buf0} : write_data_buffer[15:0];
	assign halfword_r1 = (addr_buf_byte_offset[1]==1'b1) ? write_data_buffer[15:0] : {buf3, buf2};

	/* a is sign_mask_buf[2], b is sign_mask_buf[1], c is sign_mask_buf[0] */
	wire write_select0;
	wire write_select1;

	wire[31:0] write_out1;
	wire[31:0] write_out2;

	assign write_select0 = ~sign_mask_buf[2] & sign_mask_buf[1];
	assign write_select1 = sign_mask_buf[2];

	assign write_out1 = (write_select0) ? {halfword_r1, halfword_r0} : {byte_r3, byte_r2, byte_r1, byte_r0};
	assign write_out2 = (write_select0) ? 32'b0 : write_data_buffer;

	assign replacement_word = (write_select1) ? write_out2 : write_out1;
	/*
	 *	Combinational logic for generating 32-bit read data
	 */

	wire select0;
	wire select1;
	wire select2;

	wire[31:0] out1;
	wire[31:0] out2;
	wire[31:0] out3;
	wire[31:0] out4;
	wire[31:0] out5;
	wire[31:0] out6;
	/* a is sign_mask_buf[2], b is sign_mask_buf[1], c is sign_mask_buf[0]
	 * d is addr_buf_byte_offset[1], e is addr_buf_byte_offset[0]
	 */

	assign select0 = (~sign_mask_buf[2] & ~sign_mask_buf[1] & ~addr_buf_byte_offset[1] & addr_buf_byte_offset[0]) | (~sign_mask_buf[2] & addr_buf_byte_offset[1] & addr_buf_byte_offset[0]) | (~sign_mask_buf[2] & sign_mask_buf[1] & addr_buf_byte_offset[1]); //~a~b~de + ~ade + ~abd
	assign select1 = (~sign_mask_buf[2] & ~sign_mask_buf[1] & addr_buf_byte_offset[1]) | (sign_mask_buf[2] & sign_mask_buf[1]); // ~a~bd + ab
	assign select2 = sign_mask_buf[1]; //b

	assign out1 = (select0) ? ((sign_mask_buf[3]==1'b1) ? {{24{buf1[7]}}, buf1} : {24'b0, buf1}) : ((sign_mask_buf[3]==1'b1) ? {{24{buf0[7]}}, buf0} : {24'b0, buf0});
	assign out2 = (select0) ? ((sign_mask_buf[3]==1'b1) ? {{24{buf3[7]}}, buf3} : {24'b0, buf3}) : ((sign_mask_buf[3]==1'b1) ? {{24{buf2[7]}}, buf2} : {24'b0, buf2});
	assign out3 = (select0) ? ((sign_mask_buf[3]==1'b1) ? {{16{buf3[7]}}, buf3, buf2} : {16'b0, buf3, buf2}) : ((sign_mask_buf[3]==1'b1) ? {{16{buf1[7]}}, buf1, buf0} : {16'b0, buf1, buf0});
	assign out4 = (select0) ? 32'b0 : {buf3, buf2, buf1, buf0};

	assign out5 = (select1) ? out2 : out1;
	assign out6 = (select1) ? out4 : out3;

	assign read_buf = (select2) ? out6 : out5;

	initial begin
		$readmemh("verilog/data.hex", data_block);
		clk_stall = 0;
	end

	/*
	 *	LED register interfacing with I/O
	 */
	always @(posedge clk) begin
		if(memwrite == 1'b1 && addr == 32'h2000) begin
			led_reg <= write_data;
		end
	end

	/*
	 *	State machine
	 */
	always @(posedge clk) begin
		case (state)
			IDLE: begin
				clk_stall <= 0;
				memread_buf <= memread;
				memwrite_buf <= memwrite;
				write_data_buffer <= write_data;
				addr_buf <= addr;
				sign_mask_buf <= sign_mask;

				if(memwrite==1'b1 || memread==1'b1) begin
					state <= READ_BUFFER;
					clk_stall <= 1;
				end
			end

			READ_BUFFER: begin
				/*
				 *	Subtract out the size of the instruction memory.
				 *	(Bad practice: The constant should be a `define).
				 */
				word_buf <= data_block[addr_buf_block_addr - 32'h1000];
				if(memread_buf==1'b1) begin
					state <= READ;
				end
				else if(memwrite_buf == 1'b1) begin
					state <= WRITE;
				end
			end

			READ: begin
				clk_stall <= 0;
				read_data <= read_buf;
				state <= IDLE;
			end

			WRITE: begin
				clk_stall <= 0;

				/*
				 *	Subtract out the size of the instruction memory.
				 *	(Bad practice: The constant should be a `define).
				 */
				data_block[addr_buf_block_addr - 32'h1000] <= replacement_word;
				state <= IDLE;
			end

		endcase
	end

	assign led = led_reg[7:0];
endmodule

module sign_mask_gen(func3, sign_mask);
	input [2:0]	func3;
	output [3:0]	sign_mask;

	reg [2:0]	mask;

	/*
	 *	sign - for LBU and LHU the sign bit is 0, indicating read data should be zero extended, otherwise sign extended
	 *	mask - for determining if the load/store operation is on word, halfword or byte
	 *
	 *	TODO - a Karnaugh map should be able to describe the mask without case, the case is for reading convenience
	*/

	always @(*) begin
		case(func3[1:0])
			2'b00: mask = 3'b001;	// byte only
			2'b01: mask = 3'b011;	// halfword
			2'b10: mask = 3'b111;	// word
			default: mask = 3'b000;	// should not happen for loads/stores
		endcase
	end

	assign sign_mask = {(~func3[2]), mask};
endmodule

module ForwardingUnit(rs1, rs2, MEM_RegWriteAddr, WB_RegWriteAddr, MEM_RegWrite, WB_RegWrite, EX_CSRR_Addr, MEM_CSRR_Addr, WB_CSRR_Addr, MEM_CSRR, WB_CSRR, MEM_fwd1, MEM_fwd2, WB_fwd1, WB_fwd2);
	input [4:0]	rs1;
	input [4:0]	rs2;
	input [4:0]	MEM_RegWriteAddr;
	input [4:0]	WB_RegWriteAddr;
	input		MEM_RegWrite;
	input		WB_RegWrite;
	input [11:0]	EX_CSRR_Addr;
	input [11:0]	MEM_CSRR_Addr;
	input [11:0]	WB_CSRR_Addr;
	input		MEM_CSRR;
	input		WB_CSRR;
	output		MEM_fwd1;
	output		MEM_fwd2;
	output		WB_fwd1;
	output		WB_fwd2;

	/*
	 *	if data hazard detected, assign RegWrite to decide if...
	 *	result MEM or WB stage should be rerouted to ALU input
	 */
	assign MEM_fwd1 = (MEM_RegWriteAddr != 5'b0 && MEM_RegWriteAddr ==  rs1)?MEM_RegWrite:1'b0;
	assign MEM_fwd2 = (MEM_RegWriteAddr != 5'b0 && MEM_RegWriteAddr ==  rs2 && MEM_RegWrite == 1'b1) || (EX_CSRR_Addr == MEM_CSRR_Addr && MEM_CSRR == 1'b1)?1'b1:1'b0;

	/*
	 *	from wb stage
	 */
	assign WB_fwd1 = (WB_RegWriteAddr != 5'b0 && WB_RegWriteAddr ==  rs1 && WB_RegWriteAddr != MEM_RegWriteAddr)?WB_RegWrite:1'b0;
	assign WB_fwd2 = (WB_RegWriteAddr != 5'b0 && WB_RegWriteAddr ==  rs2 && WB_RegWrite == 1'b1 && WB_RegWriteAddr != MEM_RegWriteAddr) || (EX_CSRR_Addr == WB_CSRR_Addr && WB_CSRR == 1'b1 && MEM_CSRR_Addr != WB_CSRR_Addr)?1'b1:1'b0;

endmodule

module imm_gen(inst, imm);

	input [31:0]		inst;
	output reg [31:0]	imm;

	initial begin
		imm = 32'b0;
	end

	always @(inst) begin
		case ({inst[6:5], inst[3:2]})
			4'b0000: //I-type
				imm = { {21{inst[31]}}, inst[30:20] };
			4'b1101: //I-type JALR
				imm = { {21{inst[31]}}, inst[30:21], 1'b0 };
			4'b0100: //S-type
				imm = { {21{inst[31]}}, inst[30:25], inst[11:7] };
			4'b0101: //U-type
				imm = { inst[31:12], 12'b0 };
			4'b0001: //U-type
				imm = { inst[31:12], 12'b0 };
			4'b1111: //UJ-type
				imm = { {12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0 };
			4'b1100: //SB-type
				imm = { {20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0 };
			default : imm = { {21{inst[31]}}, inst[30:20] };
		endcase
	end
endmodule

module instruction_memory(addr, out);
	input [31:0]		addr;
	output [31:0]		out;

	/*
	 *	Size the instruction memory.
	 *
	 *	(Bad practice: The constant should be a `define).
	 */
	reg [31:0]		instruction_memory[0:2**12-1];

	/*
	 *	According to the "iCE40 SPRAM Usage Guide" (TN1314 Version 1.0), page 5:
	 *
	 *		"SB_SPRAM256KA RAM does not support initialization through device configuration."
	 *
	 *	The only way to have an initializable memory is to use the Block RAM.
	 *	This uses Yosys's support for nonzero initial values:
	 *
	 *		https://github.com/YosysHQ/yosys/commit/0793f1b196df536975a044a4ce53025c81d00c7f
	 *
	 *	Rather than using this simulation construct (`initial`),
	 *	the design should instead use a reset signal going to
	 *	modules in the design.
	 */
	initial begin
		/*
		 *	read from "program.hex" and store the instructions in instruction memory
		 */
		$readmemh("verilog/program.hex",instruction_memory);
	end

	assign out = instruction_memory[addr >> 2];
endmodule

module mux2to1(input0, input1, select, out);
	input [31:0]	input0, input1;
	input		select;
	output [31:0]	out;

	assign out = (select) ? input1 : input0;
endmodule

/* IF/ID pipeline registers */ 
module if_id (clk, data_in, data_out);
	input			clk;
	input [63:0]		data_in;
	output reg[63:0]	data_out;

	/*
	 *	This uses Yosys's support for nonzero initial values:
	 *
	 *		https://github.com/YosysHQ/yosys/commit/0793f1b196df536975a044a4ce53025c81d00c7f
	 *
	 *	Rather than using this simulation construct (`initial`),
	 *	the design should instead use a reset signal going to
	 *	modules in the design.
	 */
	initial begin
		data_out = 64'b0;
	end

	always @(posedge clk) begin
		data_out <= data_in;
	end
endmodule



/* ID/EX pipeline registers */ 
module id_ex (clk, data_in, data_out);
	input			clk;
	input [177:0]		data_in;
	output reg[177:0]	data_out;

	/*
	 *	The `initial` statement below uses Yosys's support for nonzero
	 *	initial values:
	 *
	 *		https://github.com/YosysHQ/yosys/commit/0793f1b196df536975a044a4ce53025c81d00c7f
	 *
	 *	Rather than using this simulation construct (`initial`),
	 *	the design should instead use a reset signal going to
	 *	modules in the design and to thereby set the values.
	 */
	initial begin
		data_out = 178'b0;
	end

	always @(posedge clk) begin
		data_out <= data_in;
	end
endmodule



/* EX/MEM pipeline registers */ 
module ex_mem (clk, data_in, data_out);
	input			clk;
	input [154:0]		data_in;
	output reg[154:0]	data_out;

	/*
	 *	The `initial` statement below uses Yosys's support for nonzero
	 *	initial values:
	 *
	 *		https://github.com/YosysHQ/yosys/commit/0793f1b196df536975a044a4ce53025c81d00c7f
	 *
	 *	Rather than using this simulation construct (`initial`),
	 *	the design should instead use a reset signal going to
	 *	modules in the design and to thereby set the values.
	 */
	initial begin
		data_out = 155'b0;
	end

	always @(posedge clk) begin
		data_out <= data_in;
	end
endmodule



/* MEM/WB pipeline registers */ 
module mem_wb (clk, data_in, data_out);
	input			clk;
	input [116:0]		data_in;
	output reg[116:0]	data_out;

	/*
	 *	The `initial` statement below uses Yosys's support for nonzero
	 *	initial values:
	 *
	 *		https://github.com/YosysHQ/yosys/commit/0793f1b196df536975a044a4ce53025c81d00c7f
	 *
	 *	Rather than using this simulation construct (`initial`),
	 *	the design should instead use a reset signal going to
	 *	modules in the design and to thereby set the values.
	 */
	initial begin
		data_out = 117'b0;
	end

	always @(posedge clk) begin
		data_out <= data_in;
	end
endmodule

module program_counter(inAddr, outAddr, clk);
	input			clk;
	input [31:0]		inAddr;
	output reg[31:0]	outAddr;

	/*
	 *	This uses Yosys's support for nonzero initial values:
	 *
	 *		https://github.com/YosysHQ/yosys/commit/0793f1b196df536975a044a4ce53025c81d00c7f
	 *
	 *	Rather than using this simulation construct (`initial`),
	 *	the design should instead use a reset signal going to
	 *	modules in the design.
	 */
	initial begin
		outAddr = 32'b0;
	end

	always @(posedge clk) begin
		outAddr <= inAddr;
	end
endmodule

module regfile(clk, write, wrAddr, wrData, rdAddrA, rdDataA, rdAddrB, rdDataB);
	input		clk;
	input		write;
	input [4:0]	wrAddr;
	input [31:0]	wrData;
	input [4:0]	rdAddrA;
	output [31:0]	rdDataA;
	input [4:0]	rdAddrB;
	output [31:0]	rdDataB;

	/*
	 *	register file, 32 x 32-bit registers
	 */
	reg [31:0]	regfile[31:0];

	/*
	 *	buffer to store address at each positive clock edge
	 */
	reg [4:0]	rdAddrA_buf;
	reg [4:0]	rdAddrB_buf;

	/*
	 *	registers for forwarding
	 */
	reg [31:0]	regDatA;
	reg [31:0]	regDatB;
	reg [31:0]	wrAddr_buf;
	reg [31:0]	wrData_buf;
	reg		write_buf;

	/*
	 *	The `initial` statement below uses Yosys's support for nonzero
	 *	initial values:
	 *
	 *		https://github.com/YosysHQ/yosys/commit/0793f1b196df536975a044a4ce53025c81d00c7f
	 *
	 *	Rather than using this simulation construct (`initial`),
	 *	the design should instead use a reset signal going to
	 *	modules in the design and to thereby set the values.
	 */

	/*
	 *	Sets register 0 to 0
	 */
	initial begin
		regfile[0] = 32'b0;
	end

	always @(posedge clk) begin
		if (write==1'b1 && wrAddr!=5'b0) begin
			regfile[wrAddr] <= wrData;
		end
		wrAddr_buf	<= wrAddr;
		write_buf	<= write;
		wrData_buf	<= wrData;
		rdAddrA_buf	<= rdAddrA;
		rdAddrB_buf	<= rdAddrB;
		regDatA		<= regfile[rdAddrA];
		regDatB		<= regfile[rdAddrB];
	end

	assign	rdDataA = ((wrAddr_buf==rdAddrA_buf) & write_buf & wrAddr_buf!=32'b0) ? wrData_buf : regDatA;
	assign	rdDataB = ((wrAddr_buf==rdAddrB_buf) & write_buf & wrAddr_buf!=32'b0) ? wrData_buf : regDatB;
endmodule